import fs from 'node:fs';

const args = process.argv.slice(2);
const command = args.shift();
const options = new Map();
for (let index = 0; index < args.length; index += 2) {
  options.set(args[index], args[index + 1]);
}

const slug = options.get('--slug') ?? 'bg3-underslumber-patch-relay';
const timeoutSeconds = Number(options.get('--timeout-seconds') ?? 900);
const resultPath = options.get('--result');
const adminUrl = `https://mod.io/g/baldursgate3/m/${slug}/admin/settings#files`;
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
  return pages.find((page) => page.type === 'page' && page.url.includes(slug))
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
    windowsLive: Boolean(cells[5]?.querySelector('svg.tw-text-success:not(.tw-opacity-50)')),
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
  await writeResult({ ok: true, adminUrl, fileCount: rows.length });
}

async function publish() {
  const expectedPrefix = options.get('--expected-version-prefix');
  if (!expectedPrefix) fail('Не задан --expected-version-prefix.');
  const baseline = new Set((options.get('--baseline-file-ids') ?? '').split(',').filter(Boolean));

  await openAdmin();
  const candidate = await waitFor('новый проверенный файл mod.io', async () => {
    const rows = await readRows();
    return rows.find((row) => !baseline.has(row.id)
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
    if (checkboxes.length < 4) return { ok: false, reason: 'platform checkboxes not found' };
    if (!checkboxes[0].checked) checkboxes[0].click();
    return { ok: true, windows: checkboxes[0].checked };
  })()`);
  if (!platformResult?.ok || !platformResult.windows) fail('Не удалось выбрать платформу Windows.');

  const saved = await waitFor('кнопка Save', async () => evaluate(`(() => {
    const buttons = [...document.querySelectorAll('button')];
    const save = buttons.reverse().find((button) => button.innerText.trim() === 'Save');
    if (!save || save.disabled) return false;
    save.click();
    return true;
  })()`), 30000, 1000);
  if (!saved) fail(`Не удалось сохранить платформу файла ${candidate.id}.`);

  await waitFor('закрытие формы редактирования', async () => evaluate(
    `!document.body.innerText.includes('File ID: ${candidate.id}')`,
  ), 60000, 1500);

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

  const liveRow = await waitFor('активная Windows-версия файла', async () => {
    await navigate(adminUrl);
    await waitFor('обновлённая таблица файлов', async () => evaluate(
      `document.body.innerText.includes('File manager')`,
    ), 30000, 1000);
    const rows = await readRows();
    return rows.find((row) => row.id === candidate.id && row.scanOk
      && row.windowsLive && row.publishDisabled) ?? false;
  }, timeoutSeconds * 1000, 5000);

  await navigate(publicUrl);
  const publicDownload = await waitFor('публичная ссылка на новый File ID', async () => evaluate(
    `Boolean(document.querySelector('a[href*="/files/${candidate.id}/download"]'))`,
  ), 60000, 3000);
  if (!publicDownload) fail(`Публичная страница не указывает на файл ${candidate.id}.`);

  await writeResult({
    ok: true,
    fileId: candidate.id,
    version: candidate.version,
    scan: 'No virus detected',
    platform: 'windows',
    live: liveRow.windowsLive,
    publicUrl,
  });
}

if (!['check', 'snapshot', 'publish'].includes(command)) {
  fail('Команда должна быть check, snapshot или publish.');
}

try {
  if (command === 'check') await check();
  if (command === 'snapshot') await snapshot();
  if (command === 'publish') await publish();
} catch (error) {
  console.error(error.stack ?? error.message);
  process.exitCode = 1;
}
