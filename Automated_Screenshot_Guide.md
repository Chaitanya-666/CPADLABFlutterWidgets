# Automated Screenshot Capture Guide (Lab 03)

This document provides exact, step-by-step instructions for an automated agent (e.g., using Puppeteer, Playwright, or Flutter Integration Tests) equipped with screenshot capabilities to capture the 10 required images for the Lab 03 report. 

## 1. Environment & Setup
- **Launch Command**: Run the app locally on a web server using `flutter run -d web-server --web-port=8080`.
- **Target URL**: Navigate your automation browser to `http://localhost:8080`.
- **Wait for Render**: Flutter web requires time to render the canvas. Ensure your agent waits for the `flutter-view` DOM element to become fully visible before taking captures, or wait for network idle.

## 2. Viewport Definitions
The app uses a `LayoutBuilder` with a strict `600.0` pixel breakpoint for tablet vs mobile, and an `OrientationBuilder` that checks if `width > height`.

* **Mobile Portrait**: Width: `390`, Height: `844` (e.g., iPhone 12/13/14)
* **Tablet Portrait**: Width: `768`, Height: `1024` (e.g., iPad Mini)
* **Tablet Landscape**: Width: `1024`, Height: `768` (e.g., iPad Mini rotated)

---

## 3. Step-by-Step Capture Sequence

### Screenshot 1: Empty State (`04_empty_state.png`)
* **Viewport**: Mobile Portrait (`390x844`)
* **State**: Fresh launch, local storage empty.
* **Action**: Ensure no expenses exist. The screen should show the "No expenses yet. Tap + to add one." text and receipt icon. 
* **Capture**: Full screen.

### Seeding Data (Prerequisite for next shots)
Interact with the UI to create 3 sample expenses:
1. Tap the `+` FAB (Floating Action Button).
2. Enter Title: `Groceries`, Amount: `45.50`, Category: `Food`, Date: `Today`. Save.
3. Tap `+`. Enter Title: `Bus Ticket`, Amount: `2.50`, Category: `Transport`, Date: `Yesterday`. Save.
4. Tap `+`. Enter Title: `Movie Ticket`, Amount: `15.00`, Category: `Entertainment`, Date: `Yesterday`. Save.

### Screenshot 2: Mobile Portrait Layout (`01_mobile_portrait.png`)
* **Viewport**: Mobile Portrait (`390x844`)
* **State**: Home screen with the 3 seeded expenses.
* **Capture**: Full screen. Ensures the single-column list layout is visible.

### Screenshot 3: Stats Row Closeup (`06_stats_row_closeup.png`)
* **Viewport**: Mobile Portrait (`390x844`)
* **State**: Same as above.
* **Capture**: Element screenshot or crop of the `StatsRow` widget at the top (showing Total Expenses vs Budget).

### Screenshot 4: Expense Card Closeup (`07_expense_card_badge_closeup.png`)
* **Viewport**: Mobile Portrait (`390x844`)
* **State**: Same as above.
* **Capture**: Element screenshot or crop of a single `ExpenseCard` (e.g., "Groceries"), ensuring the Category badge and date are clearly visible.

### Screenshot 5: Tablet Portrait Layout (`02_tablet_portrait.png`)
* **Viewport**: Resize browser to Tablet Portrait (`768x1024`)
* **State**: Home screen with data.
* **Validation**: The UI should transition to a 2-column grid layout.
* **Capture**: Full screen. 

### Screenshot 6: Tablet Landscape Layout (`03_tablet_landscape.png`)
* **Viewport**: Resize browser to Tablet Landscape (`1024x768`)
* **State**: Home screen with data.
* **Validation**: The UI should transition to a 3-column grid layout because `width > height`.
* **Capture**: Full screen.

### Screenshot 7: Layout Comparison Diagram (`08_layout_comparison.png`)
* **Action**: Use image processing tools to stitch `01_mobile_portrait.png` and `03_tablet_landscape.png` side-by-side. 
* **Capture**: Save the stitched composite image.

### Screenshot 8: Add Expense Form (`05_add_expense_form.png`)
* **Viewport**: Mobile Portrait (`390x844`)
* **Action**: Click the `+` Floating Action Button to open the `AddExpenseScreen`.
* **Capture**: Full screen of the empty form.

### Screenshot 9: Category Dropdown Open (`09_category_dropdown_open.png`)
* **Viewport**: Mobile Portrait (`390x844`)
* **State**: Inside the `AddExpenseScreen`.
* **Action**: Click the Category `DropdownButtonFormField`.
* **Wait**: Wait for the dropdown menu items (Food, Transport, etc.) to render in the DOM overlay.
* **Capture**: Full screen or cropped to the dropdown area.

### Screenshot 10: Date Picker Open (`10_date_picker_open.png`)
* **Viewport**: Mobile Portrait (`390x844`)
* **State**: Inside the `AddExpenseScreen`.
* **Action**: Dismiss the dropdown (if open). Click the "Select Date" button or text field.
* **Wait**: Wait for the Material Date Picker dialog overlay to appear.
* **Capture**: Full screen showing the modal calendar dialogue. 

---

## 4. Teardown
- Close the browser context.
- Terminate the `flutter run` background task.
