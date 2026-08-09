#!/usr/bin/env python3
"""Обновляет строку зависимости в meta.lsx по meta.lsx патчируемого мода.

Блок Dependencies/ModuleShortDesc должен повторять ModuleInfo родителя: иначе игра
считает зависимость неудовлетворённой или подтягивает не ту версию. Версия там меняется
с каждым апдейтом чужого мода, поэтому руками её не держат.

Источник по умолчанию — соседний клон ../bg3dnd; с --parent-url данные берутся с GitHub.
Нужный блок находится по UUID родителя, так что лишние ModuleShortDesc (Conflicts,
другие зависимости) не задеваются.
"""

from __future__ import annotations

import argparse
import re
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from xml.sax.saxutils import quoteattr

REQUIRED_FIELDS = ("Folder", "MD5", "Name", "PublishHandle", "UUID", "Version64")

REPO_ROOT = Path(__file__).resolve().parent.parent
MOD_FOLDER = "PatchRelay_146ee64d-4202-44ea-bd9a-87fbcc4aa36e"
PARENT_FOLDER = "DnD2024_897914ef-5c96-053c-44af-0be823f895fe"

DEFAULT_PARENT_PATH = REPO_ROOT.parent / "bg3dnd" / "Mods" / PARENT_FOLDER / "meta.lsx"
DEFAULT_PARENT_URL = (
    "https://raw.githubusercontent.com/Yoonmoonsik/bg3dnd/main/"
    f"Mods/{PARENT_FOLDER}/meta.lsx"
)
DEFAULT_TARGET_PATH = REPO_ROOT / "Mods" / MOD_FOLDER / "meta.lsx"

MODULE_SHORT_DESC = re.compile(r'(?s)<node id="ModuleShortDesc">.*?</node>')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--parent-path", type=Path, default=DEFAULT_PARENT_PATH,
                        help=f"meta.lsx патчируемого мода (по умолчанию {DEFAULT_PARENT_PATH})")
    parser.add_argument("--parent-url", default=None,
                        help=f"взять meta.lsx родителя по URL вместо файла; без значения — {DEFAULT_PARENT_URL}",
                        nargs="?", const=DEFAULT_PARENT_URL)
    parser.add_argument("--target-path", type=Path, default=DEFAULT_TARGET_PATH,
                        help="meta.lsx этого мода")
    parser.add_argument("--check", action="store_true",
                        help="только сообщить о расхождениях, ничего не записывать")
    return parser.parse_args()


def read_parent(args: argparse.Namespace) -> str:
    if args.parent_url:
        with urllib.request.urlopen(args.parent_url, timeout=30) as response:
            return response.read().decode("utf-8-sig")

    if not args.parent_path.exists():
        raise SystemExit(
            f"meta.lsx родителя не найден: {args.parent_path}\n"
            "Укажите путь через --parent-path или возьмите файл с GitHub через --parent-url."
        )
    return args.parent_path.read_text(encoding="utf-8-sig")


def parent_module_info(parent_raw: str, source: str) -> dict[str, str]:
    """Забирает из ModuleInfo родителя поля, которые обязана повторять зависимость."""
    root = ET.fromstring(parent_raw)
    module_info = root.find('./region/node/children/node[@id="ModuleInfo"]')
    if module_info is None:
        raise SystemExit(f"В {source} нет узла ModuleInfo")

    values: dict[str, str] = {}
    for field in REQUIRED_FIELDS:
        attribute = module_info.find(f'./attribute[@id="{field}"]')
        if attribute is None:
            raise SystemExit(f"В ModuleInfo из {source} нет поля {field}")
        # MD5 у родителя обычно пуст — это нормальное значение, а не отсутствие поля.
        values[field] = attribute.get("value", "")

    if not values["UUID"].strip():
        raise SystemExit(f"В ModuleInfo из {source} пустой UUID — синхронизировать не по чему")
    return values


def assert_dependency_exists(target_raw: str, parent_uuid: str, target_path: Path) -> None:
    root = ET.fromstring(target_raw)
    for node in root.findall('./region/node/children/node[@id="Dependencies"]/children/node[@id="ModuleShortDesc"]'):
        uuid_attribute = node.find('./attribute[@id="UUID"]')
        if uuid_attribute is not None and uuid_attribute.get("value") == parent_uuid:
            return
    raise SystemExit(
        f"В {target_path} нет зависимости с UUID {parent_uuid}.\n"
        "Патч по новому чужому моду начинается с записи в Dependencies — добавьте её вручную."
    )


def update_block(block: str, values: dict[str, str]) -> tuple[str, list[str]]:
    changed: list[str] = []
    for field in REQUIRED_FIELDS:
        pattern = re.compile(rf'(<attribute id="{re.escape(field)}" type="[^"]+" value=)("[^"]*")(\s*/>)')
        match = pattern.search(block)
        if match is None:
            raise SystemExit(f"В блоке зависимости нет поля {field}")

        new_value = quoteattr(values[field])
        if match.group(2) != new_value:
            changed.append(f"{field}: {match.group(2)} -> {new_value}")
            block = pattern.sub(lambda m: m.group(1) + new_value + m.group(3), block, count=1)
    return block, changed


def main() -> int:
    args = parse_args()
    source = args.parent_url if args.parent_url else str(args.parent_path)

    if not args.target_path.exists():
        raise SystemExit(f"meta.lsx не найден: {args.target_path}")

    parent_raw = read_parent(args)
    values = parent_module_info(parent_raw, source)

    target_raw = args.target_path.read_text(encoding="utf-8", newline="")
    assert_dependency_exists(target_raw, values["UUID"], args.target_path)

    changed: list[str] = []

    def replace(match: re.Match[str]) -> str:
        nonlocal changed
        block = match.group(0)
        uuid_match = re.search(r'<attribute id="UUID" type="[^"]+" value="([^"]*)"', block)
        if not uuid_match or uuid_match.group(1) != values["UUID"]:
            return block
        block, block_changed = update_block(block, values)
        changed += block_changed
        return block

    updated_raw = MODULE_SHORT_DESC.sub(replace, target_raw)

    print(f"Родитель: {source}")
    print(f"Версия родителя: {decode_version64(values['Version64'])} (Version64 {values['Version64']})")

    if not changed:
        print("Зависимость уже совпадает с родителем.")
        return 0

    for line in changed:
        print(f"  {line}")

    if args.check:
        print("Расхождения найдены (--check: файл не изменён).")
        return 1

    args.target_path.write_text(updated_raw, encoding="utf-8", newline="")
    print(f"Обновлено: {args.target_path}")
    print("Не забудьте про PATCHES.md: версия родителя в реестре тоже устарела.")
    return 0


def decode_version64(value: str) -> str:
    """Version64 — упакованный int64: major<<55 | minor<<47 | revision<<31 | build."""
    try:
        packed = int(value)
    except ValueError:
        return "?"
    return f"{(packed >> 55) & 0xFF}.{(packed >> 47) & 0xFF}.{(packed >> 31) & 0xFFFF}.{packed & 0x7FFFFFFF}"


if __name__ == "__main__":
    raise SystemExit(main())
