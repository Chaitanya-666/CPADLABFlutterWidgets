// take_screenshots.js — Lab 03 Comprehensive Screenshot Capture
// Uses Playwright to drive a headless Chromium against the Flutter web build.
//
// Usage:
//   1. flutter build web   (already done)
//   2. node take_screenshots.js
//
// The script serves build/web/ locally, waits for Flutter to fully render,
// seeds sample expenses through the UI, then captures every required state.

const { chromium } = require('playwright');
const http = require('http');
const fs = require('fs');
const path = require('path');

const IMAGES_DIR = path.join(__dirname, 'images');
const PORT = 8765;

// ── Viewport presets ────────────────────────────────────────────────
const VIEWPORTS = {
  phone_portrait:     { width: 390,  height: 844 },
  phone_landscape:    { width: 844,  height: 390 },
  tablet_portrait:    { width: 800,  height: 1024 },
  tablet_landscape:   { width: 1024, height: 768 },
  desktop_wide:       { width: 1400, height: 900 },
  narrow_320:         { width: 320,  height: 568 },
  w500:               { width: 500,  height: 900 },
  w800:               { width: 800,  height: 900 },
  w1200:              { width: 1200, height: 900 },
};

// ── Sample expenses to seed ─────────────────────────────────────────
const EXPENSES = [
  { title: 'Groceries',          amount: '2450',  category: 'Food' },
  { title: 'Uber to College',    amount: '350',   category: 'Transport' },
  { title: 'Movie Night',        amount: '500',   category: 'Entertainment' },
  { title: 'Electricity Bill',   amount: '1800',  category: 'Bills' },
  { title: 'New Headphones',     amount: '1299',  category: 'Shopping' },
  { title: 'Gym Membership',     amount: '999',   category: 'Health' },
];

// ── Simple static file server for build/web ─────────────────────────
function startServer() {
  return new Promise((resolve) => {
    const webDir = path.join(__dirname, 'build', 'web');
    const server = http.createServer((req, res) => {
      let filePath = path.join(webDir, req.url === '/' ? 'index.html' : req.url);
      // Remove query strings
      filePath = filePath.split('?')[0];
      const ext = path.extname(filePath).toLowerCase();
      const mimeTypes = {
        '.html': 'text/html', '.js': 'application/javascript',
        '.css': 'text/css', '.json': 'application/json',
        '.png': 'image/png', '.jpg': 'image/jpeg',
        '.wasm': 'application/wasm', '.otf': 'font/otf',
        '.ttf': 'font/ttf',
      };
      fs.readFile(filePath, (err, data) => {
        if (err) {
          // Try index.html for SPA routing
          fs.readFile(path.join(webDir, 'index.html'), (err2, data2) => {
            if (err2) { res.writeHead(404); res.end('Not Found'); return; }
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(data2);
          });
          return;
        }
        res.writeHead(200, { 'Content-Type': mimeTypes[ext] || 'application/octet-stream' });
        res.end(data);
      });
    });
    server.listen(PORT, () => {
      console.log(`  [server] Serving build/web on http://localhost:${PORT}`);
      resolve(server);
    });
  });
}

// ── Wait for Flutter to finish rendering ────────────────────────────
// Flutter web renders into a <canvas> or <flt-glass-pane>. The loading
// spinner is a CircularProgressIndicator drawn on the canvas itself,
// so we can't simply check for a DOM element. Instead we:
//  1. Wait for the main.dart.js to be loaded (networkidle)
//  2. Wait extra time for the canvas to paint the actual UI
//  3. Check that the page title or specific text is rendered
async function waitForFlutterReady(page, timeoutMs = 30000) {
  console.log('  [wait] Waiting for Flutter to render...');
  
  // Wait for network to settle (scripts loaded)
  await page.waitForLoadState('networkidle', { timeout: timeoutMs });
  
  // Flutter web needs extra time after scripts load to:
  //  - Initialize the engine
  //  - Run the first frame
  //  - Load SharedPreferences (localStorage)
  //  - Build the widget tree
  // We poll for the "Expense Tracker" text in the accessibility tree
  // or simply wait a generous amount of time.
  
  const startTime = Date.now();
  while (Date.now() - startTime < timeoutMs) {
    // Check if Flutter has rendered by looking for accessibility semantics
    // or by checking if the loading spinner is gone
    const hasContent = await page.evaluate(() => {
      // Flutter web creates flt-semantics elements for accessibility
      const semantics = document.querySelectorAll('flt-semantics');
      if (semantics.length > 5) return true;
      
      // Also check for role="heading" or aria-label containing our app text
      const allEls = document.querySelectorAll('[aria-label]');
      for (const el of allEls) {
        if (el.getAttribute('aria-label')?.includes('Expense')) return true;
      }
      
      // Check for flt-glass-pane with canvas children that have drawn content
      const canvas = document.querySelector('canvas');
      if (canvas && canvas.width > 100 && canvas.height > 100) {
        // Canvas exists and has real dimensions
        return true;
      }
      
      return false;
    });
    
    if (hasContent) {
      // Give a little extra time for animations to settle
      await page.waitForTimeout(2000);
      console.log(`  [wait] Flutter ready after ${Date.now() - startTime}ms`);
      return;
    }
    await page.waitForTimeout(500);
  }
  
  // Fallback: just wait a flat 8 seconds
  console.log('  [wait] Fallback wait (semantics not detected, using flat delay)');
  await page.waitForTimeout(8000);
}

// ── Clear localStorage to start fresh ───────────────────────────────
async function clearData(page) {
  await page.evaluate(() => localStorage.clear());
}

// ── Add an expense through the UI ───────────────────────────────────
async function addExpense(page, { title, amount, category }) {
  console.log(`  [seed] Adding expense: ${title} (₹${amount}, ${category})`);
  
  // Click the FAB "Add Expense" button
  // Flutter renders semantics — look for the button
  await page.waitForTimeout(500);
  
  // Click the FAB — it's in the bottom-right, use coordinates relative to viewport
  const viewport = page.viewportSize();
  // The FAB is at bottom-right. Click it via accessibility label.
  const fabClicked = await page.evaluate(() => {
    const els = document.querySelectorAll('flt-semantics[role="button"]');
    for (const el of els) {
      const label = el.getAttribute('aria-label') || '';
      if (label.includes('Add Expense') || label.includes('Add')) {
        el.click();
        return true;
      }
    }
    // Try tapping the last button-like element
    if (els.length > 0) {
      els[els.length - 1].click();
      return true;
    }
    return false;
  });
  
  if (!fabClicked) {
    // Fallback: click at the FAB's expected position (bottom-right)
    await page.mouse.click(viewport.width - 80, viewport.height - 40);
  }
  
  await page.waitForTimeout(1500);
  
  // Now we're on the Add Expense screen
  // Fill Title field — click on it and type
  // Flutter web text fields are <input> or <textarea> elements overlaid on the canvas
  const inputs = await page.$$('input, textarea');
  
  if (inputs.length >= 2) {
    // First input = Title, Second input = Amount
    await inputs[0].click();
    await inputs[0].fill(title);
    await page.waitForTimeout(300);
    
    await inputs[1].click();
    await inputs[1].fill(amount);
    await page.waitForTimeout(300);
  } else {
    // Fallback: use keyboard to navigate
    // Click near the Title field area
    await page.mouse.click(viewport.width / 2, 100);
    await page.waitForTimeout(500);
    await page.keyboard.type(title, { delay: 30 });
    await page.keyboard.press('Tab');
    await page.waitForTimeout(300);
    await page.keyboard.type(amount, { delay: 30 });
  }
  
  // Select category via the dropdown
  // Find the dropdown semantics element
  const dropdownClicked = await page.evaluate((cat) => {
    const els = document.querySelectorAll('flt-semantics');
    for (const el of els) {
      const label = el.getAttribute('aria-label') || '';
      if (label.includes('Category') || el.getAttribute('role') === 'combobox' || 
          el.getAttribute('role') === 'listbox') {
        el.click();
        return true;
      }
    }
    return false;
  }, category);
  
  if (dropdownClicked) {
    await page.waitForTimeout(800);
    // Click the desired category option
    const optionClicked = await page.evaluate((cat) => {
      const els = document.querySelectorAll('flt-semantics');
      for (const el of els) {
        const label = el.getAttribute('aria-label') || el.textContent || '';
        if (label === cat || label.includes(cat)) {
          el.click();
          return true;
        }
      }
      // Try role=option elements
      const options = document.querySelectorAll('[role="option"]');
      for (const opt of options) {
        if ((opt.getAttribute('aria-label') || '').includes(cat)) {
          opt.click();
          return true;
        }
      }
      return false;
    }, category);
    await page.waitForTimeout(500);
  }
  
  // Click "Add Expense" / Save button
  await page.waitForTimeout(300);
  const saveClicked = await page.evaluate(() => {
    const els = document.querySelectorAll('flt-semantics[role="button"]');
    for (const el of els) {
      const label = el.getAttribute('aria-label') || '';
      if (label.includes('Add Expense') && !label.includes('Edit')) {
        el.click();
        return 'clicked: ' + label;
      }
    }
    // If we can't find it by label, click the last prominent button
    for (const el of els) {
      const rect = el.getBoundingClientRect();
      // The save button should be wide (full-width) and below the form fields
      if (rect.width > 200 && rect.top > 300) {
        el.click();
        return 'clicked fallback button';
      }
    }
    return false;
  });
  
  if (!saveClicked) {
    // Click where the save button should be (center-bottom of form)
    await page.mouse.click(viewport.width / 2, viewport.height - 200);
  }
  
  await page.waitForTimeout(1500);
  console.log(`  [seed] Done: ${title}`);
}

// ── Take a screenshot ───────────────────────────────────────────────
async function capture(page, name, viewportKey) {
  if (viewportKey) {
    const vp = VIEWPORTS[viewportKey];
    await page.setViewportSize(vp);
    await page.waitForTimeout(1500); // Let Flutter re-layout
  }
  const filepath = path.join(IMAGES_DIR, `${name}.png`);
  await page.screenshot({ path: filepath, fullPage: false });
  console.log(`  [shot] ${name}.png (${page.viewportSize().width}x${page.viewportSize().height})`);
}

// ── Main ────────────────────────────────────────────────────────────
(async () => {
  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log('║  Lab 03 — Comprehensive Screenshot Capture (Playwright)    ║');
  console.log('╚══════════════════════════════════════════════════════════════╝\n');

  // Ensure images directory exists
  if (!fs.existsSync(IMAGES_DIR)) fs.mkdirSync(IMAGES_DIR, { recursive: true });

  // Start the static server
  const server = await startServer();
  const URL = `http://localhost:${PORT}`;

  // Launch browser
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-gpu'],
  });
  
  const context = await browser.newContext({
    viewport: VIEWPORTS.phone_portrait,
    deviceScaleFactor: 2, // Retina-quality screenshots
  });
  const page = await context.newPage();

  try {
    // ──────────────────────────────────────────────────────────────
    // PHASE 1: Empty state captures
    // ──────────────────────────────────────────────────────────────
    console.log('\n── Phase 1: Empty state ────────────────────────');
    await page.goto(URL, { waitUntil: 'domcontentloaded' });
    await clearData(page);
    await page.reload({ waitUntil: 'domcontentloaded' });
    await waitForFlutterReady(page);
    
    // Shot 1: Empty state — mobile portrait
    await capture(page, '01_mobile_portrait_empty', 'phone_portrait');

    // ──────────────────────────────────────────────────────────────
    // PHASE 2: Seed expenses through the UI
    // ──────────────────────────────────────────────────────────────
    console.log('\n── Phase 2: Seeding expenses ───────────────────');
    await page.setViewportSize(VIEWPORTS.phone_portrait);
    await page.waitForTimeout(1000);
    
    for (const exp of EXPENSES) {
      await addExpense(page, exp);
      // After each save, we should be back on home screen
      await page.waitForTimeout(1000);
    }

    // Give Flutter time to re-render with all data
    await page.waitForTimeout(2000);
    
    // ──────────────────────────────────────────────────────────────
    // PHASE 3: Tier-1 screenshots — populated states
    // ──────────────────────────────────────────────────────────────
    console.log('\n── Phase 3: Tier-1 captures ────────────────────');
    
    // Shot 2: Mobile portrait with data
    await capture(page, '02_mobile_portrait_data', 'phone_portrait');
    
    // Shot 3: Tablet portrait (≥600dp) — two-pane, 2-col grid
    await capture(page, '03_tablet_portrait', 'tablet_portrait');
    
    // Shot 4: Tablet landscape — two-pane, 3-col grid
    await capture(page, '04_tablet_landscape', 'tablet_landscape');
    
    // Shot 5: Phone landscape (crosses 600dp breakpoint)
    await capture(page, '05_phone_landscape', 'phone_landscape');
    
    // Shot 6: Desktop wide
    await capture(page, '06_desktop_wide', 'desktop_wide');
    
    // Shot 7: Narrow 320dp — no overflow test
    await capture(page, '07_narrow_320dp', 'narrow_320');
    
    // ──────────────────────────────────────────────────────────────
    // PHASE 4: Add Expense form screenshots
    // ──────────────────────────────────────────────────────────────
    console.log('\n── Phase 4: Add Expense form ───────────────────');
    await page.setViewportSize(VIEWPORTS.phone_portrait);
    await page.waitForTimeout(1500);
    
    // Navigate to Add Expense
    const fabClick2 = await page.evaluate(() => {
      const els = document.querySelectorAll('flt-semantics[role="button"]');
      for (const el of els) {
        const label = el.getAttribute('aria-label') || '';
        if (label.includes('Add Expense') || label.includes('Add')) {
          el.click();
          return true;
        }
      }
      return false;
    });
    if (!fabClick2) {
      const vp = page.viewportSize();
      await page.mouse.click(vp.width - 80, vp.height - 40);
    }
    await page.waitForTimeout(2000);
    
    // Shot 8: Add expense form (mobile)
    await capture(page, '08_add_expense_form_mobile');
    
    // Shot 9: Add expense form (tablet width)
    await capture(page, '09_add_expense_form_tablet', 'tablet_portrait');
    
    // Try opening category dropdown
    await page.setViewportSize(VIEWPORTS.phone_portrait);
    await page.waitForTimeout(1000);
    
    const dropdownOpened = await page.evaluate(() => {
      const els = document.querySelectorAll('flt-semantics');
      for (const el of els) {
        const label = el.getAttribute('aria-label') || '';
        if (label.includes('Category') || label.includes('Food')) {
          el.click();
          return true;
        }
      }
      return false;
    });
    await page.waitForTimeout(1000);
    
    // Shot 10: Category dropdown open
    await capture(page, '10_category_dropdown_open');
    
    // Dismiss dropdown by pressing Escape
    await page.keyboard.press('Escape');
    await page.waitForTimeout(800);
    
    // Click the date field to open date picker
    const dateClicked = await page.evaluate(() => {
      const els = document.querySelectorAll('flt-semantics');
      for (const el of els) {
        const label = el.getAttribute('aria-label') || '';
        if (label.includes('Date') || label.includes('Aug') || 
            label.includes('calendar') || label.includes('Select')) {
          el.click();
          return true;
        }
      }
      return false;
    });
    await page.waitForTimeout(1500);
    
    // Shot 11: Date picker open
    await capture(page, '11_date_picker_open');
    
    // Dismiss date picker
    await page.keyboard.press('Escape');
    await page.waitForTimeout(500);
    
    // Go back to home screen
    const backClicked = await page.evaluate(() => {
      const els = document.querySelectorAll('flt-semantics[role="button"]');
      for (const el of els) {
        const label = el.getAttribute('aria-label') || '';
        if (label.includes('Back') || label.includes('back') || 
            label.includes('navigate') || label.includes('arrow')) {
          el.click();
          return true;
        }
      }
      return false;
    });
    if (!backClicked) {
      await page.mouse.click(25, 25); // Top-left back arrow area
    }
    await page.waitForTimeout(1500);
    
    // ──────────────────────────────────────────────────────────────
    // PHASE 5: Tier-2 extras — resize ladder
    // ──────────────────────────────────────────────────────────────
    console.log('\n── Phase 5: Resize ladder ─────────────────────');
    
    // Shot 12: 500dp width
    await capture(page, '12_w500', 'w500');
    
    // Shot 13: 800dp width
    await capture(page, '13_w800', 'w800');
    
    // Shot 14: 1200dp width
    await capture(page, '14_w1200', 'w1200');
    
    // ──────────────────────────────────────────────────────────────
    // PHASE 6: Close-ups (crop from full screenshots)
    // ──────────────────────────────────────────────────────────────
    console.log('\n── Phase 6: Close-ups ─────────────────────────');
    
    // For stats row closeup — capture at mobile width with a clip
    await page.setViewportSize(VIEWPORTS.phone_portrait);
    await page.waitForTimeout(1500);
    
    // Shot 15: Stats row area (top portion of mobile layout)
    await page.screenshot({
      path: path.join(IMAGES_DIR, '15_stats_row_closeup.png'),
      clip: { x: 0, y: 200, width: 390 * 2, height: 180 * 2 },
    });
    console.log('  [shot] 15_stats_row_closeup.png (clipped)');
    
    // Shot 16: Expense card closeup
    await page.screenshot({
      path: path.join(IMAGES_DIR, '16_expense_card_closeup.png'),
      clip: { x: 0, y: 700, width: 390 * 2, height: 250 * 2 },
    });
    console.log('  [shot] 16_expense_card_closeup.png (clipped)');

    console.log('\n══════════════════════════════════════════════════');
    console.log(`  ✅ All screenshots saved to: ${IMAGES_DIR}`);
    console.log('══════════════════════════════════════════════════\n');
    
  } catch (err) {
    console.error('  ❌ Error:', err.message);
    // Take an error state screenshot for debugging
    await page.screenshot({ path: path.join(IMAGES_DIR, 'ERROR_debug.png') });
    console.log('  [debug] Error screenshot saved');
  } finally {
    await browser.close();
    server.close();
  }
})();
