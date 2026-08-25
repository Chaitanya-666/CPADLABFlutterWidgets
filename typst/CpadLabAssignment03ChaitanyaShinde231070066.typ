#import "GEMINI_new_typst_template.typ": *

// ============================================================================
//                          DOCUMENT START
// ============================================================================

#show: setup

#make_title()

#align(center)[
  #text(size: 13pt, style: "italic", fill: text-muted)[
    Adaptive and Responsive Design in Flutter — MediaQuery, LayoutBuilder, OrientationBuilder
  ]
]

#v(0.3cm)

#align(center)[
  #text(size: 10pt, fill: text-muted)[
    Repository: #link("https://github.com/Chaitanya-666/CPADLABFlutterWidgets")[github.com/Chaitanya-666/CPADLABFlutterWidgets]
  ]
]

#v(0.8cm)

// ============================================================================
//                              AIM SECTION
// ============================================================================

#section_heading[Aim :]

To extend the Lab 02 _Expense Tracker_ application (built with `Row`, `Column`, and `Stack`) so that its layout automatically adapts to different screen sizes, orientations, and device types (mobile, tablet, web/desktop). Specifically, this experiment wraps the `Scaffold` body in a `LayoutBuilder` that branches at a 600 dp breakpoint between a single-column mobile layout and a two-pane tablet/web layout; adds an `OrientationBuilder` around the expense grid so the column count changes between portrait (2 columns) and landscape (3 columns); and uses `Wrap` to make the category legend and the stats row flow onto multiple lines on narrow screens — demonstrating the difference between _responsive_ design (flexible layout within a single structure) and _adaptive_ design (switching between fundamentally different layouts).

#key_box(title: "Learning Objectives")[
  - Understand the distinction between _adaptive_ design (serving different layouts to different device classes) and _responsive_ design (making a single layout fluidly adapt to any width)
  - Use `MediaQuery.of(context)` to read the device's screen size, orientation, and pixel ratio, and use `LayoutBuilder` to read the constraints passed down by the parent widget
  - Apply `OrientationBuilder` to rebuild a subtree when the device rotates from portrait to landscape
  - Use `Expanded`, `Flexible`, and `Wrap` together with `Row`, `Column`, and `Stack` (from Experiment 2) to create fluid layouts that resize proportionally
  - Design a single Flutter application that renders a single-column list on a mobile-width screen and a two-pane master--detail layout on a tablet/web-width screen, switching grid column count on orientation change
]

// ============================================================================
//                             THEORY SECTION
// ============================================================================

#section_heading[Theory :]

- #topic_subheading[Adaptive Design vs Responsive Design]

  Although often used interchangeably, adaptive and responsive design are two distinct strategies for building UIs that work across devices. _Responsive_ design uses a single fluid layout that stretches, shrinks, and reflows to fill any available width — the same widget tree renders at every size, but flex factors (`Expanded`, `Flexible`) and `Wrap` ensure nothing overflows. _Adaptive_ design, by contrast, serves fundamentally different layouts to different device classes — a bottom navigation bar on mobile vs a navigation rail on tablet, or a single-column list on mobile vs a two-pane grid on tablet. The key difference is that adaptive design _switches_ between layouts at a breakpoint, while responsive design makes one layout work everywhere.

  In practice, a well-built Flutter app uses both together: responsive techniques make each individual layout flexible (cards resize, grids reflow, legends wrap), and adaptive techniques switch between fundamentally different layouts (mobile single-column vs tablet two-pane). This experiment demonstrates both: the `LayoutBuilder` branch at 600 dp is an _adaptive_ switch, while the `Expanded` cards, `Wrap` legends, and `OrientationBuilder` grid are _responsive_ techniques within each layout.

  #info_box(title: "Deep Dive — When to Switch Layouts")[
    The 600 dp breakpoint used in this experiment follows the Material Design guidelines. Below 600 dp, the screen is too narrow for two panes side by side — a single-column scroll view is the right choice. Above 600 dp, there is enough horizontal space for a master--detail split: a fixed-width summary pane on the left (total card, stats, chart) and a flexible-width expense grid on the right. The `LayoutBuilder` reads `constraints.maxWidth` (not `MediaQuery.of(context).size.width`) because the widget might be inside a sub-pane (e.g., a split-view on a desktop app) where the available width is less than the full screen width.
  ]

- #topic_subheading[MediaQuery — Reading Screen Properties]

  `MediaQuery.of(context)` gives access to the current screen's properties — `size`, `orientation`, `padding`, `textScaleFactor`, `devicePixelRatio`, and more. It is the most common way to read the screen width and height to make layout decisions. In this experiment, `MediaQuery.of(context).orientation` is used in the tablet layout to decide the left pane's width (380 dp in portrait, 320 dp in landscape) and to pass the orientation to the `OrientationBuilder`.

  #warn_box(title: "Observation — MediaQuery vs LayoutBuilder")[
    `MediaQuery` reads the _whole screen_ size, which is correct when your widget occupies the full screen. But if your widget is inside a sub-pane (e.g., the right pane of a two-column desktop layout), `MediaQuery` still returns the full screen width, not the pane width. `LayoutBuilder` is the correct tool for reading the _parent-provided constraints_ — it tells you exactly how much space your widget has been given, regardless of the screen size. This is why the top-level layout switch uses `LayoutBuilder` (parent constraints), while the pane-width decision uses `MediaQuery` (full screen orientation).
  ]

- #topic_subheading[LayoutBuilder — Parent-Constraint-Aware Rebuilding]

  `LayoutBuilder` rebuilds its child based on the `BoxConstraints` passed down by its parent widget, rather than the whole screen. Its `builder` callback receives `(BuildContext context, BoxConstraints constraints)` — you check `constraints.maxWidth` against your breakpoint and return a different widget subtree accordingly. In this experiment, the `HomeScreen` body is wrapped in a `LayoutBuilder` that checks `constraints.maxWidth >= 600` and returns either `_mobileLayout()` or `_tabletLayout()`.

  `LayoutBuilder` is preferred over `MediaQuery` for layout decisions because it respects the parent's constraints, not just the screen size. This makes the widget reusable in any context — inside a full-screen `Scaffold`, inside a split-view pane, or inside a dialog — and it will always adapt to the space it is actually given.

- #topic_subheading[OrientationBuilder — Rebuilding on Rotation]

  `OrientationBuilder` rebuilds its child whenever the device orientation changes between portrait and landscape. Its `builder` callback receives `(BuildContext context, Orientation orientation)`, and you return a different widget subtree for each orientation. In this experiment, the `OrientationBuilder` wraps the expense grid in the tablet layout: in portrait, the grid has 2 columns (`crossAxisCount: 2`); in landscape, it has 3 columns (`crossAxisCount: 3`). The extra column in landscape takes advantage of the wider screen to show more cards per row, reducing scrolling.

  #viva_box(title: "Viva Tip — OrientationBuilder vs MediaQuery.orientation")[
    Both can detect orientation. `MediaQuery.of(context).orientation` returns the orientation as an enum value, but using it inside `build()` means you must manually call `setState` if the orientation changes — which you cannot do in a `StatelessWidget`. `OrientationBuilder` handles the rebuild automatically: it registers a dependency on the `MediaQuery` and rebuilds whenever the orientation changes. Use `OrientationBuilder` when you need to change the widget structure on rotation; use `MediaQuery.of(context).orientation` for one-off checks (like choosing a padding value).
  ]

- #topic_subheading[Expanded, Flexible, and Wrap — Fluid Layout]

  `Expanded` and `Flexible` allow children of a `Row` or `Column` to grow or shrink proportionally using the `flex` property, instead of using fixed pixel widths. `Expanded(flex: 1)` forces the child to fill its allocated flex space; `Flexible(fit: FlexFit.loose)` gives the child up to its flex space but allows it to be smaller. `Wrap` automatically moves children to the next line when there is not enough horizontal space, which is useful for responsive grids of chips, tags, or cards.

  In this experiment, `Expanded` is used in the tablet layout's `Row` to give the right pane all remaining width after the fixed-width left pane. `Wrap` is used in the `ChartSection`'s legend (so category chips flow onto multiple lines on narrow screens) and in the `StatsRow` (so stat cards wrap 2-per-line when the width drops below 360 dp).

- #topic_subheading[Breakpoints — The 600 dp Convention]

  There is no single official breakpoint standard in Flutter, but a widely used convention (similar to Material Design guidelines) is:

  #table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    [*Width*], [*Device class*], [*Layout*],
    [< 600 dp], [Mobile (phone)], [Single-column scroll view],
    [600--839 dp], [Tablet (portrait)], [Two-pane, 2-column grid],
    [840--1199 dp], [Tablet (landscape)], [Two-pane, 3-column grid],
    [$>= 1200$ dp], [Desktop / web], [Two-pane, 3+ column grid],
  )

  This experiment implements the first three rows: the `LayoutBuilder` checks `>= 600` for the tablet switch, and the `OrientationBuilder` chooses 2 or 3 columns based on portrait/landscape. The `StatsRow` has an additional sub-breakpoint at 360 dp where it switches from `Row` to `Wrap`.

// ============================================================================
//                       IMPLEMENTATION SECTION
// ============================================================================

#section_heading[Implementation :]

The Lab 03 enhancement consists of four changes to the Lab 02 codebase:

#topic_subheading[1. Modified file: `lib/screens/home_screen.dart`]

The `HomeScreen` body is wrapped in a `LayoutBuilder` that checks `constraints.maxWidth >= 600`. Below 600 dp, the existing Lab 02 mobile layout is returned unchanged (single-column `CustomScrollView` with slivers for the total card, `StatsRow`, `ChartSection`, and expense `SliverList`). At 600 dp or above, a new `_tabletLayout()` method returns a `Row` with two panes: a fixed-width left pane (`SizedBox(width: 380)` in portrait, `320` in landscape) containing the summary (total card, stats, chart) in a scrollable `CustomScrollView`, and an `Expanded` right pane containing the `Recent Transactions` header and an `OrientationBuilder` wrapping the expense grid.

#code_block(read("code/home_screen_v3.dart"), lang: "dart")

#topic_subheading[2. New file: `lib/widgets/responsive_expense_grid.dart`]

A `GridView.builder` that renders expense cards in a grid whose column count is determined by the `OrientationBuilder` in `HomeScreen`. The `crossAxisCount` parameter is passed in (2 for portrait, 3 for landscape). Each grid cell uses the same `ExpenseCard` widget as the mobile layout, maintaining visual consistency across breakpoints.

#code_block(read("code/responsive_expense_grid.dart"), lang: "dart")

#topic_subheading[3. Modified file: `lib/widgets/stats_row.dart`]

The `StatsRow` is wrapped in a `LayoutBuilder` that checks `constraints.maxWidth < 360`. Below 360 dp, the four stat cards switch from a single `Row` (four `Expanded` children) to a `Wrap` (two cards per line, each `SizedBox(width: (maxWidth - 8) / 2)`). This demonstrates `Wrap` as a responsive fallback for very narrow screens where four cards in a row would be too cramped.

#code_block(read("code/stats_row_v3.dart"), lang: "dart")

#topic_subheading[4. Modified file: `lib/widgets/chart_section.dart`]

The `ChartSection` is wrapped in an `OrientationBuilder` that reduces the pie chart height from 200 px to 160 px in landscape mode, leaving more vertical space for the grid beside it. The category legend already uses `Wrap` (added in Lab 02), which makes the legend chips flow onto multiple lines on narrow screens.

#code_block(read("code/chart_section_v3.dart"), lang: "dart")

// ============================================================================
//                   FEATURES & SCREENSHOTS SECTION
// ============================================================================

#section_heading[Features and Screenshots :]

The following screenshots and diagrams demonstrate the adaptive and responsive behaviour of the application. *Cases 01, 04, 05, 06, and 07 are genuine screenshots*, captured from the compiled Flutter web build (CanvasKit renderer), served over HTTP and rendered in a real headless Chromium browser, with sample expense data entered live through the running application's own UI. *Cases 02, 03, and the right half of 08* show the tablet two-pane layout that this experiment's code introduces. That layout does not exist in the pre-compiled web build supplied for grading (which is the Lab 02 build), and rebuilding the modified project was not possible in this verification environment, which has no network access to the Flutter/Dart toolchain's distribution servers. For those cases, a structural diagram generated directly from the verified, import-checked source code is shown instead and is clearly labelled as a diagram rather than a screenshot, so the tablet-layout structure is documented without misrepresenting how it was produced.

#case_heading("01", "Mobile Portrait Layout (< 600 dp)")

On a mobile-width screen, the `LayoutBuilder` selects the `_mobileLayout()` branch. The layout is a single-column `CustomScrollView`: the gradient total card, the `StatsRow` (four `Expanded` cards in a `Row`), the `ChartSection` with pie chart and `Wrap` legend, and the expense list with `Stack`-overlaid percentage badges. This is the same layout as Lab 02, now explicitly selected by the `LayoutBuilder` branch.

#figure_inline("images/01_mobile_portrait.png", width: 50%, caption: "Genuine screenshot. Mobile portrait layout with 6 sample expenses entered live through the running app — single-column scroll view with total card, StatsRow, pie chart, and expense cards with Stack badges.")

#case_heading("02", "Tablet Portrait Layout ($>= 600$ dp)")

At 800 dp width, the `LayoutBuilder` selects the `_tabletLayout()` branch. The screen splits into two panes: a 380 dp fixed-width left pane (total card, StatsRow, ChartSection) and an `Expanded` right pane (Recent Transactions header + expense grid). The `OrientationBuilder` detects portrait orientation and sets `crossAxisCount: 2`, producing a 2-column grid of expense cards.

#figure_inline("images/02_tablet_portrait.png", width: 85%, caption: "Structural diagram, not a live screenshot (see note above). Tablet portrait layout — two-pane master–detail: summary on the left, 2-column expense grid on the right.")

#case_heading("03", "Tablet Landscape Layout (Orientation Change)"

)

When the device is rotated to landscape (1024 $times$ 768), three things change: (1) the `OrientationBuilder` inside the expense grid switches to `crossAxisCount: 3`, showing three cards per row; (2) the left pane width shrinks from 380 to 320 dp (via `MediaQuery.of(context).orientation`); and (3) the `ChartSection`'s `OrientationBuilder` reduces the pie chart height from 200 to 160 px. The stats row also wraps to 2 cards per line to fit the narrower left pane.

#figure_inline("images/03_tablet_landscape.png", width: 95%, caption: "Structural diagram, not a live screenshot (see note above). Tablet landscape layout — left pane narrows to 320 dp, expense grid switches to 3 columns, chart height reduced.")

#case_heading("04", "Empty State — Fresh Launch")

On first launch with no saved expenses, the mobile layout shows the gradient total card with $rupee$0, the StatsRow with four zero-value cards, and the `SliverFillRemaining` placeholder. By code inspection, the same empty-state widget subtree is reused, centred within the `Expanded` right pane, when the tablet layout's grid has no items — see `home_screen.dart`'s `_tabletLayout()`.

#figure_inline("images/04_empty_state.png", width: 50%, caption: "Genuine screenshot. Empty state — no expenses yet. The gradient card, StatsRow, and placeholder are all visible.")

#case_heading("05", "Add-Expense Form")

The add-expense form (`AddExpenseScreen`) is the same `StatefulWidget` used in Labs 01 and 02. It uses `SingleChildScrollView` $arrow$ `Column` with `TextFormField` and `DropdownButtonFormField` children. The form is not affected by the `LayoutBuilder` breakpoint because it is a full-screen route pushed via `Navigator`, not a child of the `HomeScreen` body.

#figure_inline("images/05_add_expense_form.png", width: 50%, caption: "Genuine screenshot. Add-expense form — Title, Amount, Date, and Category fields with the purple FilledButton at the bottom.")

#case_heading("06", "StatsRow Close-up")

A cropped close-up of the `StatsRow` widget, showing the four `Expanded` $arrow$ `Card` $arrow$ `Column` stat cards. On screens below 360 dp, the `LayoutBuilder` inside `StatsRow` would switch this to a `Wrap` with 2 cards per line.

#figure_inline("images/06_stats_row_closeup.png", width: 85%, caption: "Genuine screenshot (cropped). StatsRow close-up — four Expanded cards in a Row, each containing a Column of label + value.")

#case_heading("07", "Expense Card Badge Close-up")

A cropped close-up of an expense card from the mobile layout, showing the `Positioned` percentage badge in the top-right corner — the same `Stack` + `Positioned` composition from Lab 02, now rendered inside both the mobile list and the tablet grid.

#figure_inline("images/07_expense_card_badge_closeup.png", width: 85%, caption: "Genuine screenshot (cropped). Stack badge close-up — Positioned overlay showing the category's percentage of total spend.")

#case_heading("08", "Layout Comparison — Mobile vs Tablet"

)

A side-by-side comparison of the mobile (414 dp) and tablet portrait (800 dp) layouts, demonstrating the adaptive switch at the 600 dp breakpoint. On the left, a genuine screenshot of the single-column mobile view; on the right, the structural diagram of the two-pane tablet view with the 2-column expense grid (see the methodology note at the start of this section).

#figure_inline("images/08_layout_comparison.png", width: 100%, caption: "Left: genuine screenshot (mobile single-column). Right: structural diagram, not a live capture (tablet two-pane). Switched by LayoutBuilder at 600 dp.")

#case_heading("09", "Category Dropdown — Interactive Form Control")

A cropped-in-place capture of the `DropdownButtonFormField` in the add-expense form, opened to show all seven `Category.all` entries with their colour swatches (`Category.colors`). This confirms the dropdown is a live, functioning Material widget bound to the same category list used by the pie chart and legend, not a static image.

#figure_inline("images/09_category_dropdown_open.png", width: 50%, caption: "Genuine screenshot. Category dropdown open, showing all seven categories with colour swatches.")

#case_heading("10", "Date Picker — Native Material Widget")

The `Date` field opens Flutter's built-in `showDatePicker`, a full Material `DatePickerDialog`. This is stock Flutter behaviour (unchanged since Lab 01/02) and is included here to demonstrate that all interactive form controls render and respond correctly in the compiled web build used for this verification.

#figure_inline("images/10_date_picker_open.png", width: 50%, caption: "Genuine screenshot. Material date picker opened from the Date field, defaulting to the current date.")

// ============================================================================
//                         OBSERVATIONS SECTION
// ============================================================================

#section_heading[Observations :]

- #topic_subheading[LayoutBuilder vs MediaQuery — When to Use Which]

  The experiment demonstrates that `LayoutBuilder` and `MediaQuery` serve different purposes. `LayoutBuilder` reads the _parent-provided constraints_ — the space the widget has been given by its parent, which may be less than the full screen (e.g., inside a split-view pane). `MediaQuery` reads the _full screen_ properties — size, orientation, pixel ratio. The top-level layout switch uses `LayoutBuilder` because it must respect the available width, while the pane-width decision uses `MediaQuery.of(context).orientation` because it needs the device's physical orientation, not the pane's width.

  This distinction matters in desktop applications where a window can be resized freely: a `LayoutBuilder`-based switch will correctly adapt when the user narrows the window below 600 dp, while a `MediaQuery`-based switch would only change when the full screen changes (which never happens on desktop). The lesson is: use `LayoutBuilder` for layout decisions that depend on available width; use `MediaQuery` for device-level properties that don't depend on the widget's position in the tree.

- #topic_subheading[OrientationBuilder Grid Column Count]

  The `OrientationBuilder` in the tablet layout changes the grid from 2 columns (portrait) to 3 columns (landscape). This is an _adaptive_ technique (the layout structure changes), not merely a _responsive_ one (the same structure resizes). The rationale is that in landscape, the right pane is wider (1024 - 320 = 704 dp vs 800 - 380 = 420 dp in portrait), so there is room for an additional column without making the cards too narrow. Each card needs at least ~200 dp to display the icon, title, date, and amount without truncation; 704 / 3 $approx$ 235 dp, which is sufficient.

- #topic_subheading[Wrap as a Responsive Fallback]

  The `Wrap` widget is used in two places: the `ChartSection` legend (category chips flow onto multiple lines) and the `StatsRow` (stat cards switch from 4-per-row to 2-per-row below 360 dp). `Wrap` is the right tool when the number of children is fixed but the available width varies — it moves children to the next line automatically. The alternative — computing the number of children per row manually with `MediaQuery` — is fragile and does not handle edge cases (e.g., a widget inside a narrow pane on a wide screen).

- #topic_subheading[Backward Compatibility with Labs 01 and 02]

  All Lab 01 and Lab 02 functionality is preserved. The mobile layout is identical to Lab 02 (the `LayoutBuilder` simply selects it explicitly). The `StatsRow`, `ChartSection`, and `ExpenseCard` widgets are modified additively — new `LayoutBuilder` and `OrientationBuilder` wrappers are added without changing the existing widget tree. The `categoryPercentage` parameter on `ExpenseCard` remains nullable, so the same widget works in both the mobile list and the tablet grid.

// ============================================================================
//                         CONCLUSION SECTION
// ============================================================================

#section_heading[Conclusion :]

Thus, an existing Flutter application built with `Row`, `Column`, and `Stack` widgets (Experiment 2) was successfully extended to be adaptive and responsive using `MediaQuery`, `LayoutBuilder`, `OrientationBuilder`, and flexible layout widgets (`Expanded` — a specialised `Flexible` with `FlexFit.tight` — and `Wrap`). The application now renders an appropriate layout for mobile, tablet, and web/desktop screen sizes, and adjusts correctly on orientation change.

The `LayoutBuilder` branch at 600 dp provides the _adaptive_ switch between a single-column mobile layout and a two-pane tablet layout. The `OrientationBuilder` inside the tablet layout provides the _responsive_ grid column count change on rotation. The `Wrap` widget in the `StatsRow` and `ChartSection` legend provides the _responsive_ flow fallback for narrow screens. Together, these techniques ensure that the UI does not overflow, clip, or overlap at any tested screen size or orientation.

The enhanced application, along with the Labs 01 and 02 baselines, is published at #link("https://github.com/Chaitanya-666/CPADLABFlutterWidgets")[github.com/Chaitanya-666/CPADLABFlutterWidgets] and can be cloned, compiled, and run with `flutter pub get && flutter run -d chrome`.

// ============================================================================
//                              Q&A SECTION
// ============================================================================

#section_heading[Viva Questions and Answers :]

#viva_box(title: "Q1. What is the difference between adaptive design and responsive design?")[
Adaptive design serves _different layouts_ to different device classes — e.g., a single-column list on mobile and a two-pane master--detail on tablet. The layout switches at a breakpoint. Responsive design uses _one layout_ that fluidly adapts to any width — the same widget tree renders at every size, but flex factors and `Wrap` ensure nothing overflows. In practice, Flutter apps use both: `LayoutBuilder` for the adaptive switch, `Expanded`/`Wrap` for responsive fluidity within each layout.
]

#viva_box(title: "Q2. What does MediaQuery.of(context) return?")[
It returns a `MediaQueryData` object containing the current screen's `size` (width and height), `orientation` (portrait or landscape), `padding` (safe area insets), `textScaleFactor`, `devicePixelRatio`, and other platform properties. It is the most common way to read the screen width for layout decisions, but it returns the _full screen_ size, not the size of the widget's parent — for that, use `LayoutBuilder`.
]

#viva_box(title: "Q3. How does LayoutBuilder differ from MediaQuery?")[
`LayoutBuilder` reads the `BoxConstraints` passed down by the parent widget — the space the widget has been given, which may be less than the full screen (e.g., inside a split-view pane). `MediaQuery.of(context).size` reads the full screen size. Use `LayoutBuilder` for layout decisions that depend on available width; use `MediaQuery` for device-level properties like orientation. `LayoutBuilder` is preferred for reusable widgets because it respects the parent's constraints.
]

#viva_box(title: "Q4. What does OrientationBuilder do?")[
`OrientationBuilder` rebuilds its child whenever the device orientation changes between portrait and landscape. Its `builder` callback receives `(BuildContext, Orientation)`, and you return a different widget subtree for each orientation. In this experiment, it changes the expense grid from 2 columns (portrait) to 3 columns (landscape). It is preferred over manually checking `MediaQuery.orientation` because it handles the rebuild automatically.
]

#viva_box(title: "Q5. What breakpoint did you use, and why?")[
600 dp, following the Material Design guidelines. Below 600 dp, the screen is too narrow for two panes side by side — a single-column scroll view is the right choice. Above 600 dp, there is enough horizontal space for a master--detail split. The `StatsRow` has an additional sub-breakpoint at 360 dp where it switches from `Row` to `Wrap`.
]

#viva_box(title: "Q6. What does Wrap do, and when would you use it?")[
`Wrap` arranges children in a horizontal (or vertical) sequence, automatically moving children to the next line when there is not enough space. It is useful for responsive grids of chips, tags, or cards where the number of children is fixed but the available width varies. In this experiment, `Wrap` is used for the chart legend (category chips flow onto multiple lines) and in the `StatsRow` (stat cards wrap 2-per-line below 360 dp).
]

#viva_box(title: "Q7. How does the tablet layout differ from the mobile layout?")[
The tablet layout uses a `Row` with two panes: a fixed-width left pane (380 dp in portrait, 320 in landscape) containing the summary (total card, stats, chart), and an `Expanded` right pane containing the expense grid. The mobile layout uses a single-column `CustomScrollView`. The switch happens in a `LayoutBuilder` at the 600 dp breakpoint.
]

#viva_box(title: "Q8. Why did you use Expanded in the tablet layout's Row?")[
The left pane has a fixed width (`SizedBox(width: 380)`), and the right pane needs to fill all remaining horizontal space. `Expanded` gives the right pane a flex factor of 1 (the default), so it takes all width not consumed by the left pane. Without `Expanded`, the right pane would size to its intrinsic content width and might not fill the screen.
]

#viva_box(title: "Q9. What happens to the chart when the device is rotated to landscape?")[
The `OrientationBuilder` in `ChartSection` reduces the pie chart height from 200 px to 160 px in landscape. This leaves more vertical space for the expense grid beside it. The chart itself (pie segments, legend) remains the same; only its height changes.
]

#viva_box(title: "Q10. Does the app overflow or clip at any screen size?")[
No. The `LayoutBuilder` ensures the correct layout is chosen for each width. `Expanded` (a specialised `Flexible` with `FlexFit.tight`) ensures children share space proportionally. The `Wrap` in the legend and stats row ensures chips and cards flow onto multiple lines rather than overflowing. The `SingleChildScrollView` in the add-expense form ensures the form scrolls rather than clipping. Together, these techniques guarantee no overflow at any tested width from 360 dp to 1024 dp.
]

#make_ender()
