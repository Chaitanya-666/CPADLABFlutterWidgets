const puppeteer = require('puppeteer');
const http = require('http');
const path = require('path');
const handler = require('serve-handler');

(async () => {
  const server = http.createServer((request, response) => {
    return handler(request, response, { public: path.join(__dirname, 'build/web') });
  });

  server.listen(8080, () => console.log('Running at http://localhost:8080'));

  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox', '--disable-setuid-sandbox'] });
  const page = await browser.newPage();
  
  console.log('Navigating to app (Empty State)...');
  await page.setViewport({ width: 414, height: 960 });
  await page.goto('http://localhost:8080', { waitUntil: 'networkidle0', timeout: 60000 });
  await new Promise(r => setTimeout(r, 6000));
  
  await page.screenshot({ path: '04_empty_state.png' });
  
  // Set expenses by injecting directly to local storage the exact string SharedPreferences expects
  // In Flutter web SharedPreferences, strings are stored with the prefix flutter. and just the string.
  // Wait, no, it might be stored with quotes. Let's provide both or just the string.
  // The safest way is to inject the exact JSON string. SharedPreferences stores strings with `"` around them if it's string type? No, actually strings are stored as plain string in localStorage.
  
  const rawJson = `[{"id":"1","title":"Groceries","amount":1200.0,"date":"2023-10-01T10:00:00.000","category":"Food"},{"id":"2","title":"Uber","amount":350.0,"date":"2023-10-02T10:00:00.000","category":"Transport"},{"id":"3","title":"Movie","amount":500.0,"date":"2023-10-03T10:00:00.000","category":"Entertainment"},{"id":"4","title":"Electricity Bill","amount":1500.0,"date":"2023-10-04T10:00:00.000","category":"Bills"},{"id":"5","title":"Snacks","amount":150.0,"date":"2023-10-05T10:00:00.000","category":"Food"}]`;

  // Sometimes SharedPreferences wraps strings in double quotes for web: '"[...]"'
  // Let's set both flutter.expenses and flutter.expenses (with quotes) just in case, but let's do plain first.
  // Actually, we can just use SharedPreferences by writing it via page.evaluate
  
  await page.evaluate((data) => {
    // Flutter shared_preferences web stores strings prefixed with flutter. and the value is exactly the string, but wait, older versions wrapped them.
    // We will write the raw json wrapped in quotes just in case, or without.
    // Modern shared_preferences_web stores it prefixed with `flutter.`. The value is just the string.
    // But since it's json, we can just do:
    localStorage.setItem('flutter.expenses', data);
    // and for older shared_preferences:
    // localStorage.setItem('flutter.expenses', JSON.stringify(data));
  }, rawJson);
  
  // Let's also add one using the UI to be safe
  await page.reload({ waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 5000));

  console.log('Mobile Portrait');
  await page.setViewport({ width: 414, height: 960 });
  await new Promise(r => setTimeout(r, 1000));
  await page.screenshot({ path: '01_mobile_portrait.png' });

  console.log('Tablet Portrait');
  await page.setViewport({ width: 800, height: 1024 });
  await new Promise(r => setTimeout(r, 1000));
  await page.screenshot({ path: '02_tablet_portrait.png' });

  console.log('Tablet Landscape');
  await page.setViewport({ width: 1024, height: 768 });
  await new Promise(r => setTimeout(r, 1000));
  await page.screenshot({ path: '03_tablet_landscape.png' });

  console.log('Stats row');
  await page.setViewport({ width: 414, height: 960 });
  await new Promise(r => setTimeout(r, 1000));
  await page.screenshot({ path: '06_stats_row_closeup.png', clip: { x: 0, y: 190, width: 414, height: 100 } });

  console.log('Expense card badge');
  await page.screenshot({ path: '07_expense_card_badge_closeup.png', clip: { x: 0, y: 550, width: 414, height: 70 } });

  console.log('Add expense form');
  await page.mouse.click(414 - 30, 960 - 30); // Approximate FAB click
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: '05_add_expense_form.png' });

  await browser.close();
  server.close();
})();
