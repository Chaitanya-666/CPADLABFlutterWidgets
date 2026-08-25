const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function takeScreenshots() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  // Create screenshots directory
  const screenshotDir = path.join(__dirname, 'finalPackage/01_Corrected_Submission/screenshots_comprehensive');
  if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir, { recursive: true });
  }
  
  // Navigate to the web app
  await page.goto('http://127.0.0.1:8080', { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(3000);
  
  // Inject sample data via localStorage
  const rawJson = `[{"id":"1","title":"Groceries","amount":1200.0,"date":"2023-10-01T10:00:00.000","category":"Food"},{"id":"2","title":"Uber","amount":350.0,"date":"2023-10-02T10:00:00.000","category":"Transport"},{"id":"3","title":"Movie","amount":500.0,"date":"2023-10-03T10:00:00.000","category":"Entertainment"},{"id":"4","title":"Electricity Bill","amount":1500.0,"date":"2023-10-04T10:00:00.000","category":"Bills"},{"id":"5","title":"Snacks","amount":150.0,"date":"2023-10-05T10:00:00.000","category":"Food"},{"id":"6","title":"Medicine","amount":800.0,"date":"2023-10-06T10:00:00.000","category":"Health"},{"id":"7","title":"New Shoes","amount":2500.0,"date":"2023-10-07T10:00:00.000","category":"Shopping"},{"id":"8","title":"Netflix","amount":199.0,"date":"2023-10-08T10:00:00.000","category":"Entertainment"},{"id":"9","title":"Bus Pass","amount":500.0,"date":"2023-10-09T10:00:00.000","category":"Transport"},{"id":"10","title":"Water Bill","amount":600.0,"date":"2023-10-10T10:00:00.000","category":"Bills"}]`;
  
  await page.evaluate((data) => {
    localStorage.setItem('flutter.expenses', data);
  }, rawJson);
  
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(3000);
  
  console.log("App loaded with sample data, starting screenshot capture...");
  
  // Helper function
  const shot = async (name, options = {}) => {
    const fullPath = path.join(screenshotDir, name);
    await page.screenshot({ path: fullPath, ...options });
    console.log(`  ✓ ${name}`);
  };
  
  // ===== VIEWPORT MATRIX =====
  
  // 1. Mobile Portrait (375x667 - iPhone SE/8)
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(1000);
  await shot("01_mobile_375x667.png", { fullPage: true });
  
  // 2. Mobile Portrait (414x896 - iPhone 11/XR)
  await page.setViewportSize({ width: 414, height: 896 });
  await page.waitForTimeout(1000);
  await shot("02_mobile_414x896.png", { fullPage: true });
  
  // 3. Mobile Landscape (896x414)
  await page.setViewportSize({ width: 896, height: 414 });
  await page.waitForTimeout(1000);
  await shot("03_mobile_landscape_896x414.png", { fullPage: true });
  
  // 4. Tablet Portrait (768x1024 - iPad)
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.waitForTimeout(1000);
  await shot("04_tablet_portrait_768x1024.png", { fullPage: true });
  
  // 5. Tablet Landscape (1024x768 - iPad)
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.waitForTimeout(1000);
  await shot("05_tablet_landscape_1024x768.png", { fullPage: true });
  
  // 6. Tablet Portrait Large (800x1280)
  await page.setViewportSize({ width: 800, height: 1280 });
  await page.waitForTimeout(1000);
  await shot("06_tablet_portrait_800x1280.png", { fullPage: true });
  
  // 7. Tablet Landscape Large (1280x800)
  await page.setViewportSize({ width: 1280, height: 800 });
  await page.waitForTimeout(1000);
  await shot("07_tablet_landscape_1280x800.png", { fullPage: true });
  
  // 8. Desktop Small (1280x720)
  await page.setViewportSize({ width: 1280, height: 720 });
  await page.waitForTimeout(1000);
  await shot("08_desktop_1280x720.png", { fullPage: true });
  
  // 9. Desktop Standard (1440x900)
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.waitForTimeout(1000);
  await shot("09_desktop_1440x900.png", { fullPage: true });
  
  // 10. Desktop Large (1920x1080)
  await page.setViewportSize({ width: 1920, height: 1080 });
  await page.waitForTimeout(1000);
  await shot("10_desktop_1920x1080.png", { fullPage: true });
  
  // 11. Ultra-wide (2560x1080)
  await page.setViewportSize({ width: 2560, height: 1080 });
  await page.waitForTimeout(1000);
  await shot("11_ultrawide_2560x1080.png", { fullPage: true });
  
  console.log("Basic viewport screenshots done. Now detail shots...");
  
  // ===== EMPTY STATES =====
  
  // 12. Empty State - clear localStorage and reload
  await page.evaluate(() => { localStorage.removeItem('flutter.expenses'); });
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);
  
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  await shot("12_empty_state_mobile.png", { fullPage: true });
  
  // 13. Empty State Tablet
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.waitForTimeout(500);
  await shot("13_empty_state_tablet.png", { fullPage: true });
  
  // Restore data
  await page.evaluate((data) => { localStorage.setItem('flutter.expenses', data); }, rawJson);
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);
  
  // ===== ADD EXPENSE FORM =====
  
  // 14. Add Expense Form - Mobile
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  // Click FAB - try clicking bottom right area
  await page.mouse.click(340, 600);
  await page.waitForTimeout(1500);
  await shot("14_add_expense_form_mobile.png", { fullPage: true });
  
  // 15. Add Expense Form - Tablet
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.waitForTimeout(500);
  await page.mouse.click(700, 950);
  await page.waitForTimeout(1500);
  await shot("15_add_expense_form_tablet.png", { fullPage: true });
  
  // Close form
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
  
  // 16. Category Dropdown Open - Mobile
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  await page.mouse.click(340, 600);
  await page.waitForTimeout(1000);
  // Click category dropdown - find the dropdown trigger
  const dropdown = page.locator('select, [role="combobox"], [aria-label*="category" i]').first();
  if (await dropdown.count() > 0) {
    await dropdown.click();
    await page.waitForTimeout(500);
    await shot("16_category_dropdown_mobile.png", { fullPage: true });
  } else {
    // Try clicking the dropdown area directly
    await page.mouse.click(180, 400);
    await page.waitForTimeout(500);
    await shot("16_category_dropdown_mobile.png", { fullPage: true });
  }
  
  // 17. Date Picker Open - Mobile
  const dateField = page.locator('input[type="date"], [aria-label*="date" i]').first();
  if (await dateField.count() > 0) {
    await dateField.click();
    await page.waitForTimeout(500);
    await shot("17_date_picker_mobile.png", { fullPage: true });
  } else {
    // Try clicking date area
    await page.mouse.click(180, 320);
    await page.waitForTimeout(500);
    await shot("17_date_picker_mobile.png", { fullPage: true });
  }
  
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
  
  // ===== DETAIL CLOSEUPS =====
  
  // 18. Stats Row Closeup - Mobile
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  await shot("18_stats_row_closeup_mobile.png", { clip: { x: 0, y: 180, width: 375, height: 120 } });
  
  // 19. Expense Card Badge Closeup - Mobile
  await shot("19_expense_card_badge_mobile.png", { clip: { x: 0, y: 350, width: 375, height: 150 } });
  
  // 20. Chart Section Closeup - Mobile
  await shot("20_chart_section_mobile.png", { clip: { x: 0, y: 320, width: 375, height: 250 } });
  
  // 21. Stats Row Closeup - Tablet (left pane)
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.waitForTimeout(500);
  await shot("21_stats_row_closeup_tablet.png", { clip: { x: 0, y: 20, width: 380, height: 120 } });
  
  // 22. Chart Section Closeup - Tablet
  await shot("22_chart_section_tablet.png", { clip: { x: 0, y: 160, width: 380, height: 250 } });
  
  // 23. Expense Grid - Tablet Portrait (2 columns, right pane)
  await shot("23_expense_grid_tablet_portrait.png", { clip: { x: 380, y: 20, width: 388, height: 980 } });
  
  // 24. Expense Grid - Tablet Landscape (3 columns, right pane)
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.waitForTimeout(500);
  await shot("24_expense_grid_tablet_landscape.png", { clip: { x: 320, y: 20, width: 704, height: 728 } });
  
  // 25. Layout Comparison - Side by side
  await page.setViewportSize({ width: 1200, height: 900 });
  await page.waitForTimeout(500);
  await shot("25_layout_comparison.png", { fullPage: true });
  
  // ===== BREAKPOINT DEMONSTRATION =====
  
  // 26. Breakpoint Transition - 599px (just under tablet breakpoint - mobile layout)
  await page.setViewportSize({ width: 599, height: 900 });
  await page.waitForTimeout(1000);
  await shot("26_breakpoint_599px_mobile.png", { fullPage: true });
  
  // 27. Breakpoint Transition - 600px (tablet breakpoint - tablet layout)
  await page.setViewportSize({ width: 600, height: 900 });
  await page.waitForTimeout(1000);
  await shot("27_breakpoint_600px_tablet.png", { fullPage: true });
  
  // 28. Breakpoint Transition - 359px (just under stats wrap breakpoint - Wrap layout)
  await page.setViewportSize({ width: 359, height: 900 });
  await page.waitForTimeout(1000);
  await shot("28_breakpoint_359px_stats_wrap.png", { fullPage: true });
  
  // 29. Breakpoint Transition - 360px (stats row breakpoint - Row layout)
  await page.setViewportSize({ width: 360, height: 900 });
  await page.waitForTimeout(1000);
  await shot("29_breakpoint_360px_stats_row.png", { fullPage: true });
  
  // ===== DARK MODE =====
  
  // 30. Dark Mode - Mobile
  await page.setViewportSize({ width: 375, height: 667 });
  await page.emulateMedia({ colorScheme: 'dark' });
  await page.waitForTimeout(500);
  await shot("30_dark_mode_mobile.png", { fullPage: true });
  
  // 31. Dark Mode - Tablet
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.waitForTimeout(500);
  await shot("31_dark_mode_tablet.png", { fullPage: true });
  
  // 32. Dark Mode - Desktop
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.waitForTimeout(500);
  await shot("32_dark_mode_desktop.png", { fullPage: true });
  
  // Reset to light mode
  await page.emulateMedia({ colorScheme: 'light' });
  await page.waitForTimeout(500);
  
  // ===== ORIENTATION CHANGE SEQUENCE =====
  
  // 33. Orientation Change - Tablet Portrait
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.waitForTimeout(1000);
  await shot("33_orientation_portrait_start.png", { fullPage: true });
  
  // 34. Orientation Change - Tablet Landscape
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.waitForTimeout(1000);
  await shot("34_orientation_landscape_end.png", { fullPage: true });
  
  // ===== SCROLL STATES =====
  
  // 35. Scroll Position - Scrolled down mobile
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  await page.mouse.wheel(0, 500);
  await page.waitForTimeout(500);
  await shot("35_scrolled_mobile.png", { fullPage: true });
  
  // 36. Scroll Position - Scrolled down tablet
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.waitForTimeout(500);
  await page.mouse.wheel(0, 500);
  await page.waitForTimeout(500);
  await shot("36_scrolled_tablet.png", { fullPage: true });
  
  // ===== INTERACTION STATES =====
  
  // 37. Dismissible Expense Card - Swipe to delete (mobile)
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  // Simulate swipe on first expense card
  await page.mouse.move(20, 450);
  await page.mouse.down();
  await page.mouse.move(-200, 450);
  await page.mouse.up();
  await page.waitForTimeout(500);
  await shot("37_swipe_delete_mobile.png", { fullPage: true });
  
  // Reload to restore data
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);
  
  // 38. Form Validation - Empty form
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  await page.mouse.click(340, 600);
  await page.waitForTimeout(1000);
  await page.click('button:has-text("Add Expense"), button[type="submit"]').catch(() => {});
  await page.waitForTimeout(500);
  await shot("38_form_validation_empty.png", { fullPage: true });
  
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
  
  // 39. Keyboard Focus States
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  await page.mouse.click(340, 600);
  await page.waitForTimeout(1000);
  // Tab through form fields
  await page.keyboard.press('Tab');
  await page.waitForTimeout(200);
  await page.keyboard.press('Tab');
  await page.waitForTimeout(200);
  await shot("39_keyboard_focus.png", { fullPage: true });
  
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
  
  // 40. Large Dataset - Many expenses
  // Add more expenses
  const manyExpenses = [];
  for (let i = 1; i <= 20; i++) {
    const categories = ['Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Health', 'Other'];
    const cat = categories[Math.floor(Math.random() * categories.length)];
    manyExpenses.push({
      id: `${i}`,
      title: `Expense ${i}`,
      amount: Math.floor(Math.random() * 2000) + 100,
      date: `2023-10-${String(Math.floor(Math.random() * 28) + 1).padStart(2, '0')}T10:00:00.000`,
      category: cat
    });
  }
  await page.evaluate((data) => { localStorage.setItem('flutter.expenses', JSON.stringify(data)); }, manyExpenses);
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(3000);
  
  await page.setViewportSize({ width: 375, height: 667 });
  await page.waitForTimeout(500);
  await shot("40_many_expenses_mobile.png", { fullPage: true });
  
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.waitForTimeout(500);
  await shot("41_many_expenses_tablet.png", { fullPage: true });
  
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.waitForTimeout(500);
  await shot("42_many_expenses_desktop.png", { fullPage: true });
  
  await browser.close();
  console.log('\n✅ All screenshots saved to:', screenshotDir);
}

takeScreenshots().catch(console.error);
