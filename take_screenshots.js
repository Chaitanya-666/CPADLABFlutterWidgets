const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function takeScreenshots() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  // Create screenshots directory
  const screenshotDir = path.join(__dirname, 'screenshots_lab03');
  if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir, { recursive: true });
  }
  
  // Navigate to the web app
  await page.goto('http://localhost:8080', { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(3000);
  
  // 1. Mobile Portrait - Empty State
  await page.setViewportSize({ width: 414, height: 960 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(screenshotDir, '01_mobile_portrait_empty.png'), fullPage: true });
  
  // Add sample expenses via localStorage
  const rawJson = `[{"id":"1","title":"Groceries","amount":1200.0,"date":"2023-10-01T10:00:00.000","category":"Food"},{"id":"2","title":"Uber","amount":350.0,"date":"2023-10-02T10:00:00.000","category":"Transport"},{"id":"3","title":"Movie","amount":500.0,"date":"2023-10-03T10:00:00.000","category":"Entertainment"},{"id":"4","title":"Electricity Bill","amount":1500.0,"date":"2023-10-04T10:00:00.000","category":"Bills"},{"id":"5","title":"Snacks","amount":150.0,"date":"2023-10-05T10:00:00.000","category":"Food"}]`;
  
  await page.evaluate((data) => {
    localStorage.setItem('flutter.expenses', data);
  }, rawJson);
  
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(3000);
  
  // 2. Mobile Portrait with data
  await page.setViewportSize({ width: 414, height: 960 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(screenshotDir, '02_mobile_portrait.png'), fullPage: true });
  
  // 3. Tablet Portrait
  await page.setViewportSize({ width: 800, height: 1024 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(screenshotDir, '03_tablet_portrait.png'), fullPage: true });
  
  // 4. Tablet Landscape
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(screenshotDir, '04_tablet_landscape.png'), fullPage: true });
  
  // 5. Desktop Wide
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(screenshotDir, '05_desktop_wide.png'), fullPage: true });
  
  // 6. Add Expense Form - click FAB
  await page.setViewportSize({ width: 414, height: 960 });
  await page.waitForTimeout(500);
  
  // Try to click the FAB - it's usually bottom right
  const fab = page.locator('button:has-text("Add Expense"), [aria-label="Add Expense"], .floating-action-button, button.fab').first();
  if (await fab.count() > 0) {
    await fab.click();
  } else {
    // Try clicking approximate FAB position
    await page.mouse.click(380, 900);
  }
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(screenshotDir, '06_add_expense_form.png'), fullPage: true });
  
  // 7. Close form and get Stats Row closeup
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
  await page.setViewportSize({ width: 414, height: 960 });
  await page.waitForTimeout(500);
  await page.screenshot({ 
    path: path.join(screenshotDir, '07_stats_row_closeup.png'), 
    clip: { x: 0, y: 180, width: 414, height: 120 } 
  });
  
  // 8. Expense card badge closeup
  await page.screenshot({ 
    path: path.join(screenshotDir, '08_expense_card_badge.png'), 
    clip: { x: 0, y: 400, width: 414, height: 150 } 
  });
  
  // 9. Category dropdown open
  await page.setViewportSize({ width: 414, height: 960 });
  await page.waitForTimeout(500);
  // Click on the add expense again
  await page.mouse.click(380, 900);
  await page.waitForTimeout(1500);
  // Click the category dropdown
  const dropdown = page.locator('select, [role="combobox"], .dropdown').first();
  if (await dropdown.count() > 0) {
    await dropdown.click();
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(screenshotDir, '09_category_dropdown.png'), fullPage: true });
  }
  
  // 10. Date picker open
  const dateField = page.locator('input[type="date"], [aria-label*="date" i], input:has-text("Date")').first();
  if (await dateField.count() > 0) {
    await dateField.click();
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(screenshotDir, '10_date_picker.png'), fullPage: true });
  }
  
  // 11. Layout comparison (side by side mobile and tablet)
  await page.setViewportSize({ width: 1200, height: 900 });
  await page.waitForTimeout(500);
  await page.screenshot({ path: path.join(screenshotDir, '11_layout_comparison.png'), fullPage: true });
  
  await browser.close();
  console.log('All screenshots saved to:', screenshotDir);
}

takeScreenshots().catch(console.error);
