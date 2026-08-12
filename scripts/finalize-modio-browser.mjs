import fs from 'node:fs';

const args = process.argv.slice(2);
const command = args.shift();
const options = new Map();
for (let index = 0; index < args.length; index += 1) {
  const key = args[index];
  if (!key.startsWith('--')) fail(`Неизвестный аргумент: ${key}`);
  const next = args[index + 1];
  const value = next && !next.startsWith('--') ? args[++index] : '';
  options.set(key, value);
}

const slug = options.get('--slug') ?? 'bg3-underslumber-patch-relay';
const timeoutSeconds = Number(options.get('--timeout-seconds') ?? 900);
const resultPath = options.get('--result');
const adminUrl = `https://mod.io/g/baldursgate3/m/${slug}/admin/settings#files`;
const profileAdminUrl = `https://mod.io/g/baldursgate3/m/${slug}/admin/settings`;
const publicUrl = `https://mod.io/g/baldursgate3/m/${slug}`;
const sleep = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));

function fail(message) {
  throw new Error(message);
}

async function getPages() {
  const response = await fetch('http://127.0.0.1:9222/json/list');
  if (!response.ok) fail(`CDP вернул HTTP ${response.status}.`);
  return response.json();
}

async function findPage() {
  const pages = await getPages();
  return pages.find((page) => page.type === 'page' && page.url.includes(slug) && page.url.includes('/admin/settings'))
    ?? pages.find((page) => page.type === 'page' && page.url.includes(slug))
    ?? pages.find((page) => page.type === 'page');
}

async function cdp(page, method, params = {}) {
  return new Promise((resolve, reject) => {
    const socket = new WebSocket(page.webSocketDebuggerUrl);
    const requestId = 1;
    const timer = setTimeout(() => {
      socket.close();
      reject(new Error(`CDP ${method}: превышено время ожидания.`));
    }, 30000);
    socket.onerror = () => {
      clearTimeout(timer);
      reject(new Error(`CDP ${method}: соединение не установлено.`));
    };
    socket.onopen = () => socket.send(JSON.stringify({ id: requestId, method, params }));
    socket.onmessage = (event) => {
      const message = JSON.parse(event.data);
      if (message.id !== requestId) return;
      clearTimeout(timer);
      socket.close();
      if (message.error) reject(new Error(`CDP ${method}: ${message.error.message}`));
      else resolve(message.result);
    };
  });
}

async function evaluate(expression) {
  const page = await findPage();
  if (!page) fail('В CDP не найдена вкладка браузера.');
  const result = await cdp(page, 'Runtime.evaluate', {
    expression,
    returnByValue: true,
    awaitPromise: true,
  });
  if (result.exceptionDetails) fail(`Ошибка JavaScript на mod.io: ${result.exceptionDetails.text}`);
  return result.result.value;
}

async function navigate(url) {
  const page = await findPage();
  if (!page) fail('В CDP не найдена вкладка браузера.');
  await cdp(page, 'Page.navigate', { url });
  await sleep(3000);
}

async function pressSpace() {
  const page = await findPage();
  if (!page) fail('В CDP не найдена вкладка браузера.');
  const key = { key: ' ', code: 'Space', windowsVirtualKeyCode: 32, nativeVirtualKeyCode: 32 };
  await cdp(page, 'Input.dispatchKeyEvent', { type: 'keyDown', ...key });
  await cdp(page, 'Input.dispatchKeyEvent', { type: 'keyUp', ...key });
}

async function waitFor(description, probe, timeout = timeoutSeconds * 1000, interval = 3000) {
  const deadline = Date.now() + timeout;
  let lastValue;
  while (Date.now() < deadline) {
    try {
      lastValue = await probe();
      if (lastValue) return lastValue;
    } catch (error) {
      lastValue = error.message;
    }
    await sleep(interval);
  }
  fail(`${description}: превышено время ожидания. Последнее состояние: ${JSON.stringify(lastValue)}`);
}

async function openAdmin() {
  await navigate(adminUrl);
  await waitFor('страница управления файлами Patch Relay', async () => evaluate(
    `location.href.includes(${JSON.stringify(slug)}) && document.body.innerText.includes('File manager')`,
  ), 60000, 2000);
  const signedIn = await evaluate(
    `location.href.includes('/admin/settings') && document.body.innerText.includes('BG3 Underslumber - Patch Relay')`,
  );
  if (!signedIn) fail('Авторизованная страница управления Patch Relay недоступна.');
}

const rowsExpression = `([...document.querySelectorAll('tbody tr')].map((row) => {
  const href = row.querySelector('a[href*="/files/"]')?.href ?? '';
  const id = (href.match(/files\\/(\\d+)/) ?? [])[1];
  const cells = [...row.querySelectorAll('td')];
  return id ? {
    id,
    version: cells[2]?.innerText.trim() ?? '',
    scanOk: Boolean(cells[4]?.querySelector('svg.tw-text-success')),
    publishDisabled: Boolean([...row.querySelectorAll('button')]
      .find((button) => button.innerText.trim() === 'Publish')?.disabled),
  } : null;
}).filter(Boolean))`;

async function readRows() {
  return evaluate(rowsExpression);
}

async function writeResult(value) {
  const json = `${JSON.stringify(value, null, 2)}\n`;
  if (resultPath) fs.writeFileSync(resultPath, json, 'utf8');
  process.stdout.write(json);
}

async function snapshot() {
  await openAdmin();
  const rows = await readRows();
  process.stdout.write(rows.map((row) => row.id).join(','));
}

async function check() {
  await openAdmin();
  const rows = await readRows();
  await navigate(publicUrl);
  const publicFileIds = await evaluate(`([...document.querySelectorAll('a[href*="/files/"]')]
    .map((link) => (link.href.match(/files\\/(\\d+)/) ?? [])[1])
    .filter(Boolean))`);
  await writeResult({ ok: true, adminUrl, fileCount: rows.length, rows, publicFileIds });
}

async function closeAdmin() {
  const pages = (await getPages()).filter((page) => page.type === 'page' && page.url.includes(slug));
  for (const page of pages) await cdp(page, 'Page.close');
  await writeResult({ ok: true, closedPages: pages.length });
}

async function profileCheck() {
  await navigate(profileAdminUrl);
  await waitFor('профиль Patch Relay', async () => evaluate(
    `location.href.includes('/admin/settings') && document.body.innerText.includes('Mod profile')`,
  ), 60000, 2000);
  await waitFor('редактор описания Patch Relay', async () => evaluate(
    `Boolean(globalThis.tinymce?.activeEditor?.initialized)`,
  ), 60000, 1000);
  const fields = await evaluate(`(() => ({
    inputs: [...document.querySelectorAll('input')].map((input) => ({
      name: input.name, type: input.type, placeholder: input.placeholder,
      ariaLabel: input.getAttribute('aria-label'), value: input.value,
    })),
    textareas: [...document.querySelectorAll('textarea')].map((input) => ({
      name: input.name, placeholder: input.placeholder,
      ariaLabel: input.getAttribute('aria-label'), value: input.value,
      className: input.className,
      outerHTML: input.outerHTML,
      context: input.parentElement?.parentElement?.innerText?.trim() ?? '',
      contextHTML: input.parentElement?.parentElement?.outerHTML?.slice(0, 4000) ?? '',
    })),
    contenteditables: [...document.querySelectorAll('[contenteditable="true"]')].map((input) => ({
      role: input.getAttribute('role'), ariaLabel: input.getAttribute('aria-label'),
      className: input.className, text: input.innerText,
    })),
    buttons: [...document.querySelectorAll('button')].map((button) => button.innerText.trim())
      .filter(Boolean),
    frames: [...document.querySelectorAll('iframe')].map((frame) => ({
      title: frame.title, src: frame.src, className: frame.className,
      text: frame.contentDocument?.body?.innerText ?? '',
      html: frame.contentDocument?.body?.innerHTML ?? '',
    })),
    roleTextboxes: [...document.querySelectorAll('[role="textbox"]')].map((input) => ({
      tagName: input.tagName, ariaLabel: input.getAttribute('aria-label'),
      className: input.className, text: input.innerText, value: input.value,
      outerHTML: input.outerHTML.slice(0, 4000),
    })),
  }))()`);
  await writeResult({ ok: true, profileAdminUrl, fields });
}

async function syncProfile() {
  const profileFile = options.get('--profile-file');
  if (!profileFile) fail('Не задан --profile-file.');
  const profile = JSON.parse(fs.readFileSync(profileFile, 'utf8'));
  const summary = profile.summary?.trim();
  const descriptionHtml = profile.descriptionHtml?.trim();
  if (!summary || !descriptionHtml) fail('В профиле нужны summary и descriptionHtml.');
  if (summary.length > 250) fail(`Summary длиннее 250 символов: ${summary.length}.`);

  await navigate(profileAdminUrl);
  await waitFor('профиль Patch Relay', async () => evaluate(
    `location.href.includes('/admin/settings') && document.body.innerText.includes('Mod profile')`,
  ), 60000, 2000);
  await waitFor('редактор описания Patch Relay', async () => evaluate(
    `Boolean(globalThis.tinymce?.activeEditor?.initialized)`,
  ), 60000, 1000);

  const changed = await evaluate(`(() => {
    const requestedSummary = ${JSON.stringify(summary)};
    const requestedDescription = ${JSON.stringify(descriptionHtml)};
    const summaryInput = [...document.querySelectorAll('textarea')]
      .find((input) => input.placeholder?.includes('Tell us about the changes'));
    const editor = globalThis.tinymce?.activeEditor;
    if (!summaryInput) return { ok: false, reason: 'Summary textarea not found' };
    if (!editor) return { ok: false, reason: 'TinyMCE editor not found' };

    const textareaSetter = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value')?.set;
    textareaSetter?.call(summaryInput, requestedSummary);
    summaryInput.dispatchEvent(new Event('input', { bubbles: true }));
    summaryInput.dispatchEvent(new Event('change', { bubbles: true }));
    editor.setContent(requestedDescription);
    editor.fire('input');
    editor.fire('change');
    editor.save();

    const save = [...document.querySelectorAll('button')]
      .find((button) => button.innerText.trim() === 'Save' && !button.disabled);
    if (!save) return { ok: false, reason: 'Save button not found' };
    save.click();
    return { ok: true };
  })()`);
  if (!changed?.ok) fail(`Не удалось заполнить профиль: ${changed?.reason ?? 'unknown error'}.`);

  await sleep(3000);
  await navigate(profileAdminUrl);
  await waitFor('сохранённый профиль Patch Relay', async () => evaluate(`(() => {
    const expectedSummary = ${JSON.stringify(summary)};
    const summaryInput = [...document.querySelectorAll('textarea')]
      .find((input) => input.placeholder?.includes('Tell us about the changes'));
    const editor = globalThis.tinymce?.activeEditor;
    const descriptionText = editor?.getContent({ format: 'text' }) ?? '';
    return summaryInput?.value === expectedSummary
      && descriptionText.includes('Aligns item mechanics, status durations, conditions and resource formulas')
      && descriptionText.includes('Full patch list, affected versions and source details');
  })()`), 60000, 2000);

  await navigate(publicUrl);
  const publicText = await waitFor('обновлённое описание на публичной странице', async () => evaluate(`(() => {
    const body = document.body.innerText;
    const summaryProbe = ${JSON.stringify(summary.slice(0, 80))};
    const descriptionProbe = 'Aligns item mechanics, status durations, conditions and resource formulas';
    return body.includes(summaryProbe) && body.includes(descriptionProbe) ? body : false;
  })()`), 60000, 3000);
  await writeResult({
    ok: true,
    profileAdminUrl,
    publicUrl,
    summary,
    descriptionVerified: publicText.includes('Full patch list, affected versions and source details'),
  });
}

async function publish() {
  const expectedPrefix = options.get('--expected-version-prefix');
  if (!expectedPrefix) fail('Не задан --expected-version-prefix.');
  const baseline = new Set((options.get('--baseline-file-ids') ?? '').split(',').filter(Boolean));
  const candidateFileId = options.get('--candidate-file-id');
  const changelogFile = options.get('--changelog-file');
  const changelog = (changelogFile ? fs.readFileSync(changelogFile, 'utf8') : '').trim();

  await openAdmin();
  const candidate = await waitFor('новый проверенный файл mod.io', async () => {
    const rows = await readRows();
    return rows.find((row) => (candidateFileId ? row.id === candidateFileId : !baseline.has(row.id))
      && row.version.startsWith(expectedPrefix)
      && row.scanOk) ?? false;
  });

  const opened = await evaluate(`(() => {
    const row = [...document.querySelectorAll('tbody tr')].find((item) =>
      item.querySelector('a[href*="/files/${candidate.id}/download"]'));
    const button = row?.querySelector('svg[data-icon="pencil-alt"]')?.closest('button');
    if (!button) return false;
    button.click();
    return true;
  })()`);
  if (!opened) fail(`Не удалось открыть редактирование файла ${candidate.id}.`);

  await waitFor('форма редактирования файла', async () => evaluate(
    `document.body.innerText.includes('File ID: ${candidate.id}')`,
  ), 30000, 1000);

  const platformResult = await evaluate(`(() => {
    const checkboxes = [...document.querySelectorAll('input[type="checkbox"]')];
    const windows = checkboxes.find((input) => input.closest('label')?.innerText.trim() === 'Windows');
    if (!windows) return { ok: false, reason: 'Windows checkbox not found' };
    const alreadySelected = windows.checked;
    const visual = windows.closest('label').querySelector('span');
    if (!alreadySelected) visual.scrollIntoView({ block: 'center', inline: 'center' });
    const rect = visual.getBoundingClientRect();
    const x = rect.left + rect.width / 2;
    const y = rect.top + rect.height / 2;
    if (!alreadySelected) windows.focus();
    return { ok: alreadySelected || Boolean(document.elementFromPoint(x, y)), alreadySelected, x, y };
  })()`);
  if (!platformResult?.ok) fail('Не удалось выбрать платформу Windows.');
  if (!platformResult.alreadySelected) await pressSpace();
  await sleep(500);
  const changelogChanged = await evaluate(`(() => {
    const requestedChangelog = ${JSON.stringify(changelog)};
    const changelogInput = [...document.querySelectorAll('textarea')]
      .find((input) => input.closest('label')?.innerText.includes('Changelog')
        || input.getAttribute('placeholder')?.includes('Enter each change'));
    if (!requestedChangelog || !changelogInput
      || changelogInput.value.trim() === requestedChangelog) return false;
    const setter = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value')?.set;
    setter?.call(changelogInput, requestedChangelog);
    changelogInput.dispatchEvent(new Event('input', { bubbles: true }));
    changelogInput.dispatchEvent(new Event('change', { bubbles: true }));
    return true;
  })()`);
  if (changelogChanged) await sleep(500);
  const platformState = await evaluate(`(() => {
    const windows = [...document.querySelectorAll('input[type="checkbox"]')]
      .find((input) => input.closest('label')?.innerText.trim() === 'Windows');
    const buttons = [...document.querySelectorAll('button')];
    const saveAndPublish = buttons.find((button) => button.innerText.trim() === 'Save & publish');
    const save = buttons.reverse().find((button) => button.innerText.trim() === 'Save');
    let saved = false;
    let publishedDirect = false;
    if (windows?.checked && saveAndPublish && !saveAndPublish.disabled) {
      saveAndPublish.click();
      saved = true;
      publishedDirect = true;
    } else if (windows?.checked && save && !save.disabled) {
      save.click();
      saved = true;
    }
    return { checked: windows?.checked, saved, publishedDirect };
  })()`);

  if (platformResult.alreadySelected && !changelogChanged) {
    const closed = await evaluate(`(() => {
      const cancel = [...document.querySelectorAll('button')]
        .find((button) => button.innerText.trim() === 'Cancel' && !button.disabled);
      if (!cancel) return false;
      cancel.click();
      return true;
    })()`);
    if (!closed) fail(`Не удалось закрыть форму файла ${candidate.id}.`);
  } else {
    if (!platformState.saved) fail(`Не удалось сохранить платформу файла ${candidate.id}.`);
  }

  await waitFor('закрытие формы редактирования', async () => evaluate(
    `!document.body.innerText.includes('File ID: ${candidate.id}')`,
  ), 60000, 1500);

  if (!candidate.publishDisabled && !platformState.publishedDirect) {
    const publishClicked = await waitFor('кнопка Publish нового файла', async () => evaluate(`(() => {
      const row = [...document.querySelectorAll('tbody tr')].find((item) =>
        item.querySelector('a[href*="/files/${candidate.id}/download"]'));
      const button = [...(row?.querySelectorAll('button') ?? [])]
        .find((item) => item.innerText.trim() === 'Publish');
      if (!button || button.disabled) return false;
      button.click();
      return true;
    })()`), 60000, 1500);
    if (!publishClicked) fail(`Не удалось нажать Publish для файла ${candidate.id}.`);

    await sleep(1200);
    await evaluate(`(() => {
      const candidates = [...document.querySelectorAll('button')].filter((button) =>
        button.innerText.trim() === 'Publish' && !button.disabled && !button.closest('tbody tr'));
      const confirmation = candidates.at(-1);
      if (confirmation) confirmation.click();
      return Boolean(confirmation);
    })()`);
  }

  const liveRow = await waitFor('опубликованный проверенный файл', async () => {
    await navigate(adminUrl);
    await waitFor('обновлённая таблица файлов', async () => evaluate(
      `document.body.innerText.includes('File manager')`,
    ), 30000, 1000);
    const rows = await readRows();
    return rows.find((row) => row.id === candidate.id && row.scanOk
      && row.publishDisabled) ?? false;
  }, timeoutSeconds * 1000, 5000);

  await navigate(publicUrl);
  const publicDownload = await waitFor('публичная ссылка на новый File ID', async () => evaluate(
    `Boolean(document.querySelector('a[href*="/files/${candidate.id}/download"]'))`,
  ), 60000, 3000);
  if (!publicDownload) fail(`Публичная страница не указывает на файл ${candidate.id}.`);

  let savedChangelog = '';
  if (changelog) {
    await navigate(adminUrl);
    await waitFor('обновлённая таблица файлов', async () => evaluate(
      `document.body.innerText.includes('File manager')`,
    ), 30000, 1000);
    await evaluate(`(() => {
      const row = [...document.querySelectorAll('tbody tr')].find((item) =>
        item.querySelector('a[href*="/files/${candidate.id}/download"]'));
      row?.querySelector('svg[data-icon="pencil-alt"]')?.closest('button')?.click();
    })()`);
    savedChangelog = await waitFor('сохранённый changelog файла', async () => evaluate(`(() => {
      const input = [...document.querySelectorAll('textarea')]
        .find((item) => item.getAttribute('placeholder')?.includes('Enter each change'));
      return input?.value?.trim() || false;
    })()`), 30000, 1000);
    if (savedChangelog !== changelog) fail(`Changelog файла ${candidate.id} не сохранился.`);
  }

  await writeResult({
    ok: true,
    fileId: candidate.id,
    version: candidate.version,
    scan: 'No virus detected',
    platform: 'windows',
    changelog: savedChangelog,
    live: true,
    publicUrl,
  });
}

if (!['check', 'snapshot', 'close-admin', 'profile-check', 'profile-sync', 'publish'].includes(command)) {
  fail('Команда должна быть check, snapshot, close-admin, profile-check, profile-sync или publish.');
}

try {
  if (command === 'check') await check();
  if (command === 'snapshot') await snapshot();
  if (command === 'close-admin') await closeAdmin();
  if (command === 'profile-check') await profileCheck();
  if (command === 'profile-sync') await syncProfile();
  if (command === 'publish') await publish();
} catch (error) {
  console.error(error.stack ?? error.message);
  process.exitCode = 1;
}
