const puppeteer = require('puppeteer');
const http = require('http');
const fs = require('fs');
const path = require('path');
const handler = require('serve-handler');

(async () => {
  // 1. Start a simple HTTP server
  const server = http.createServer((request, response) => {
    return handler(request, response, { public: path.join(__dirname, 'build/web') });
  });

  server.listen(8080, () => {
    console.log('Running at http://localhost:8080');
  });

  // 2. Launch Puppeteer
  console.log('Launching browser...');
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  
  // Set viewport to a standard mobile size for a good layout
  const vpWidth = 414;
  const vpHeight = 896;
  await page.setViewport({ width: vpWidth, height: vpHeight });

  console.log('Navigating to app...');
  await page.goto('http://localhost:8080', { waitUntil: 'networkidle0', timeout: 60000 });
  
  // Wait for Flutter CanvasKit to finish rendering (give it 8 seconds to be safe)
  console.log('Waiting for Flutter app to render...');
  await new Promise(r => setTimeout(r, 8000));

  // Screenshot 1: Full Home Screen
  console.log('Taking full home screenshot...');
  await page.screenshot({ path: 'home_full.png' });

  // Screenshot 2: Stats Row Close-up (approximation of coordinates based on layout)
  // Gradient card is roughly 150px tall, stats row is right below it
  console.log('Taking stats row close-up...');
  await page.screenshot({ 
    path: 'stats_row.png', 
    clip: { x: 0, y: 180, width: vpWidth, height: 120 } 
  });

  // Screenshot 3: List with badges (scroll down slightly or just crop bottom part)
  console.log('Taking list close-up...');
  await page.screenshot({ 
    path: 'list_with_badges.png', 
    clip: { x: 0, y: 350, width: vpWidth, height: 400 } 
  });

  // Screenshot 4: Click the FAB to open Add Expense form
  // FAB is typically bottom-right, roughly 16px from edges, 56x56 in size. Center is ~44px from bottom-right.
  console.log('Clicking FAB...');
  await page.mouse.click(vpWidth - 44, vpHeight - 44);
  
  // Wait for the modal animation
  await new Promise(r => setTimeout(r, 2000));
  
  console.log('Taking add expense form screenshot...');
  await page.screenshot({ path: 'add_expense.png' });

  // Cleanup
  console.log('Closing browser and server...');
  await browser.close();
  server.close();
  
  console.log('Done!');
})();
