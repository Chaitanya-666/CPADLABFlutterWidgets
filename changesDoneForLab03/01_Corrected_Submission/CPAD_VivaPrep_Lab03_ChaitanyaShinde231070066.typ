#import "GEMINI_viva_template.typ": *

// ============================================================================
//                          DOCUMENT START
// ============================================================================

#show: setup

#make_title()

#align(center)[
  #text(size: 13pt, style: "italic", fill: text-muted)[
    Study Guide for Lab 03 — Adaptive & Responsive Design Theory, Code Walkthrough, and Viva Q&A
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
//                          PART A — LAB 03 THEORY
// ============================================================================

#section_heading[Part A — Lab 03 Theory: Adaptive & Responsive Design]

#topic_subheading[Experiment 3: Developing Adaptive and Responsive Designs in Flutter]

Lab 03 required extending the Lab 02 Expense Tracker application so that its layout automatically adjusts to different screen sizes, orientations, and device types. The experiment builds on the `Row`, `Column`, and `Stack` structures from Lab 02 and introduces four new Flutter layout tools: `MediaQuery`, `LayoutBuilder`, `OrientationBuilder`, and the flexible widgets `Expanded`, `Flexible`, and `Wrap`.

#key_box(title: "Lab 03 — What was built")[
  - *Adaptive switch:* `LayoutBuilder` at 600 dp breakpoint — mobile layout below, tablet two-pane layout above
  - *Orientation-aware grid:* `OrientationBuilder` changes grid columns (2 portrait, 3 landscape)
  - *Responsive stats:* `StatsRow` wraps to 2-per-line below 360 dp via `LayoutBuilder` + `Wrap`
  - *Responsive chart:* `ChartSection` height reduces in landscape via `OrientationBuilder`
  - *New files:* `responsive_expense_grid.dart`; modified: `home_screen.dart`, `stats_row.dart`, `chart_section.dart`
  - *Build target:* Flutter Web (CanvasKit renderer), tested at mobile (414 dp), tablet portrait (800 dp), and tablet landscape (1024 dp)
]

// ============================================================================
//                          PART B — THEORY DEEP DIVE
// ============================================================================

#section_heading[Part B — Theory Deep Dive]

#topic_subheading[Adaptive vs Responsive — The Core Distinction]

_Adaptive design_ means serving different layouts to different device classes. The app detects the device class (via screen width or platform) and renders a fundamentally different widget tree — for example, a bottom navigation bar on mobile vs a navigation rail on tablet, or a single-column list on mobile vs a two-pane master--detail on tablet. The key characteristic is that the layout _switches_ at a breakpoint.

_Responsive design_ means making a single layout fluidly adapt to any width. The same widget tree renders at every size, but flex factors (`Expanded`, `Flexible`), `Wrap`, and relative sizing ensure nothing overflows. The key characteristic is that the layout _stretches_ without changing structure.

#info_box(title: "Analysis — How this app uses both")[
  The `LayoutBuilder` branch at 600 dp is _adaptive_ (two different widget trees). The `Expanded` cards in the `StatsRow`, the `Wrap` in the chart legend, and the `OrientationBuilder` grid column count are _responsive_ (the same widget tree adapts). A well-built Flutter app always uses both: adaptive for large structural changes, responsive for fine-grained adaptation within each structure.
]

#topic_subheading[MediaQuery — The Screen-Level API]

`MediaQuery.of(context)` returns a `MediaQueryData` object with:

#table(
  columns: (auto, 1fr),
  [*Property*], [*What it tells you*],
  [`size`], [Full screen `Size(width, height)` in logical pixels],
  [`orientation`], [`Orientation.portrait` or `Orientation.landscape`],
  [`devicePixelRatio`], [Physical pixels per logical pixel (2.0 on retina, 3.0 on some Android)],
  [`textScaleFactor`], [User's font size preference (accessibility)],
  [`padding`], [Safe area insets (notches, status bar)],
  [`viewInsets`], [Keyboard height when visible],
)

In this experiment, `MediaQuery.of(context).orientation` is used in the tablet layout to decide the left pane width (380 dp portrait, 320 dp landscape).

#warn_box(title: "Observation — MediaQuery gives screen size, not parent size")[
  `MediaQuery.size` always returns the _full screen_ dimensions, even if your widget is inside a narrow pane. If you need the space your widget has been given by its parent, use `LayoutBuilder` instead. This matters in desktop apps where windows can be resized: a `MediaQuery`-based breakpoint would only change when the screen changes (never on desktop), while a `LayoutBuilder`-based breakpoint adapts correctly to window resizing.
]

#topic_subheading[LayoutBuilder — Parent-Constraint-Aware Building]

`LayoutBuilder` takes a `builder` callback that receives `BoxConstraints` — the min/max width and height the parent has allocated. You inspect `constraints.maxWidth` and return a different widget subtree based on the available width.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 600) {
      return _tabletLayout(...);
    }
    return _mobileLayout(...);
  },
)
```

#key_box(title: "Key Principle — LayoutBuilder is preferred over MediaQuery for layout decisions")[
  `LayoutBuilder` respects the parent's constraints, making the widget reusable in any context — full-screen, split-view pane, or dialog. `MediaQuery` is for device-level properties (orientation, pixel ratio) that don't depend on the widget's position in the tree.
]

#topic_subheading[OrientationBuilder — Automatic Rebuild on Rotation]

`OrientationBuilder` takes a `builder` callback that receives the current `Orientation` enum. It registers a dependency on `MediaQuery` and automatically rebuilds whenever the orientation changes.

```dart
OrientationBuilder(
  builder: (context, orientation) {
    final crossAxisCount =
        orientation == Orientation.portrait ? 2 : 3;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      ...
    );
  },
)
```

#viva_box(title: "Viva Tip — OrientationBuilder vs MediaQuery.orientation")[
  Both detect orientation. But `MediaQuery.of(context).orientation` in a `StatelessWidget.build()` does _not_ trigger a rebuild on rotation by itself — you need an `OrientationBuilder` or a `StatefulWidget` with a `WidgetsBindingObserver`. `OrientationBuilder` handles this automatically.
]

#topic_subheading[Expanded, Flexible, Wrap — The Flexible Trio]

#table(
  columns: (auto, 1fr, auto),
  [*Widget*], [*Behaviour*], [*Used in*],
  [`Expanded(flex: 1)`], [Forces child to fill its flex allocation (min = max)], [Tablet Row right pane, StatsRow cards],
  [`Flexible(fit: loose)`], [Gives child up to its flex allocation, allows shrinking], [Not used here — Expanded is sufficient],
  [`Wrap`], [Moves children to next line when horizontal space runs out], [Chart legend, StatsRow sub-360dp fallback],
)

#topic_subheading[Breakpoints — The 600 dp Convention]

#table(
  columns: (auto, auto, 1fr),
  [*Width*], [*Device class*], [*Layout in this app*],
  [< 360 dp], [Small phone], [StatsRow wraps to 2-per-line],
  [360--599 dp], [Phone], [Single-column mobile scroll view],
  [600--839 dp], [Tablet portrait], [Two-pane: 380 dp summary + 2-col grid],
  [840--1199 dp], [Tablet landscape], [Two-pane: 320 dp summary + 3-col grid],
  [$>= 1200$ dp], [Desktop / web], [Same as tablet landscape (could add more columns)],
)

// ============================================================================
//                          PART C — CODE WALKTHROUGH
// ============================================================================

#section_heading[Part C — Code Walkthrough: File by File]

#topic_subheading[1. `home_screen.dart` — The LayoutBuilder Switch]

The `HomeScreen` widget's body is now a `LayoutBuilder` that checks `constraints.maxWidth >= 600`. Below 600 dp, it calls `_mobileLayout()` — the same Lab 02 single-column `CustomScrollView`. At 600 dp or above, it calls `_tabletLayout()`, which returns a `Row` with a fixed-width `SizedBox` (left pane) and an `Expanded` (right pane). The right pane contains an `OrientationBuilder` that sets `crossAxisCount` to 2 (portrait) or 3 (landscape).

#code_block(read("code/home_screen_v3.dart"), lang: "dart")

#topic_subheading[2. `responsive_expense_grid.dart` — The GridView]

A `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount`. The `crossAxisCount` is passed in from the `OrientationBuilder`. Each grid cell is an `ExpenseCard` — the same widget used in the mobile list, ensuring visual consistency across breakpoints.

#code_block(read("code/responsive_expense_grid.dart"), lang: "dart")

#topic_subheading[3. `stats_row.dart` — Wrap as Responsive Fallback]

The `StatsRow` now wraps its `Row` in a `LayoutBuilder`. Below 360 dp, it switches from `Row` (four `Expanded` children) to `Wrap` (two `SizedBox` children per line, each `(maxWidth - 8) / 2` wide). This prevents the four cards from being too cramped on very narrow screens.

#code_block(read("code/stats_row_v3.dart"), lang: "dart")

#topic_subheading[4. `chart_section.dart` — OrientationBuilder for Chart Height]

The `ChartSection` wraps its `PieChart` in an `OrientationBuilder` that reduces the chart height from 200 px to 160 px in landscape. The `Wrap` legend (from Lab 02) already handles flowing category chips onto multiple lines.

#code_block(read("code/chart_section_v3.dart"), lang: "dart")

// ============================================================================
//                          PART D — EXPERIMENT TIMELINE
// ============================================================================

#section_heading[Part D — Experiment Timeline]

#topic_subheading[Step 1: Wrap the Scaffold body in LayoutBuilder]

The first change was wrapping the `HomeScreen`'s `Consumer<ExpenseProvider>` body in a `LayoutBuilder`. The `builder` callback checks `constraints.maxWidth >= 600` and branches. Initially, both branches returned the same mobile layout to verify the `LayoutBuilder` was wired correctly.

#topic_subheading[Step 2: Build the tablet two-pane layout]

The `_tabletLayout()` method was written: a `Row` with a `SizedBox(width: 380)` left pane (summary: total card, StatsRow, ChartSection in a `CustomScrollView`) and an `Expanded` right pane (Recent Transactions header + expense list). Initially, the right pane used the same `SliverList` as the mobile layout.

#topic_subheading[Step 3: Add OrientationBuilder for grid column count]

The `SliverList` in the right pane was replaced with an `OrientationBuilder` wrapping a `GridView.builder`. The `crossAxisCount` is set to 2 in portrait and 3 in landscape. A new `ResponsiveExpenseGrid` widget was extracted to keep the code clean.

#topic_subheading[Step 4: Add Wrap to StatsRow for narrow screens]

The `StatsRow` was wrapped in a `LayoutBuilder` with a sub-breakpoint at 360 dp. Below 360 dp, the `Row` of four `Expanded` cards switches to a `Wrap` of `SizedBox` cards, 2 per line.

#topic_subheading[Step 5: Add OrientationBuilder to ChartSection]

The `ChartSection`'s `PieChart` was wrapped in an `OrientationBuilder` that reduces the chart height from 200 to 160 px in landscape, leaving more room for the grid.

#topic_subheading[Step 6: Test at three viewport sizes and capture screenshots]

The compiled Flutter web build was served over HTTP and captured at mobile (414 $times$ 960), tablet portrait (800 $times$ 1024), and tablet landscape (1024 $times$ 768) viewport sizes. The layout adapted correctly at all three sizes with no overflow, clipping, or overlap.

// ============================================================================
//                          PART E — VIVA Q&A
// ============================================================================

#section_heading[Part E — Viva Questions and Answers]

#topic_subheading[Category 1: Adaptive vs Responsive]

#viva_box(title: "Q1. What is the difference between adaptive design and responsive design?")[
Adaptive design serves different layouts to different device classes — the layout switches at a breakpoint (e.g., single-column on mobile, two-pane on tablet). Responsive design uses one layout that fluidly adapts to any width via flex factors and `Wrap`. Flutter apps use both: `LayoutBuilder` for the adaptive switch, `Expanded`/`Wrap` for responsive fluidity.
]

#viva_box(title: "Q2. Give an example of an adaptive design decision in your app.")[
The `LayoutBuilder` at 600 dp that switches between `_mobileLayout()` (single-column `CustomScrollView`) and `_tabletLayout()` (two-pane `Row` with summary + grid). This is adaptive because the widget tree is fundamentally different on each side of the breakpoint.
]

#viva_box(title: "Q3. Give an example of a responsive design decision in your app.")[
The `StatsRow`'s `Wrap` fallback below 360 dp, or the `ChartSection`'s `Wrap` legend. These are responsive because the same widget tree is used at all widths — only the flow of children changes.
]

#viva_box(title: "Q4. Can a single app be both adaptive and responsive?")[
Yes, and it should be. This app is adaptive (LayoutBuilder switches layouts at 600 dp) and responsive (Expanded cards resize, Wrap legends reflow, OrientationBuilder changes grid columns). Adaptive handles large structural changes; responsive handles fine-grained adaptation within each structure.
]

#topic_subheading[Category 2: MediaQuery and LayoutBuilder]

#viva_box(title: "Q5. What is MediaQuery and what properties does it provide?")[
`MediaQuery.of(context)` returns `MediaQueryData` with `size`, `orientation`, `devicePixelRatio`, `textScaleFactor`, `padding`, and `viewInsets`. It reads the full screen's properties. In this app, `MediaQuery.of(context).orientation` is used to decide the tablet left pane width.
]

#viva_box(title: "Q6. What is LayoutBuilder and how does it differ from MediaQuery?")[
`LayoutBuilder` reads the `BoxConstraints` passed down by the parent widget — the space the widget has been given, which may be less than the full screen. `MediaQuery` reads the full screen size. Use `LayoutBuilder` for layout decisions based on available width; use `MediaQuery` for device-level properties.
]

#viva_box(title: "Q7. Why is LayoutBuilder preferred over MediaQuery for layout decisions?")[
Because `LayoutBuilder` respects the parent's constraints, making the widget reusable in any context — full-screen, split-view pane, or dialog. A `MediaQuery`-based breakpoint would only change when the screen changes, not when the window or pane is resized.
]

#viva_box(title: "Q8. What breakpoint did you use and why?")[
600 dp, following Material Design guidelines. Below 600 dp, a single-column layout is the right choice. Above 600 dp, there is room for a two-pane layout. An additional sub-breakpoint at 360 dp switches the StatsRow from Row to Wrap.
]

#topic_subheading[Category 3: OrientationBuilder]

#viva_box(title: "Q9. What does OrientationBuilder do?")[
It rebuilds its child whenever the device orientation changes. Its `builder` receives `(BuildContext, Orientation)`. In this app, it changes the expense grid from 2 columns (portrait) to 3 (landscape).
]

#viva_box(title: "Q10. How is OrientationBuilder different from checking MediaQuery.orientation?")[
`MediaQuery.of(context).orientation` in a `StatelessWidget.build()` does not trigger a rebuild on rotation by itself. `OrientationBuilder` registers a dependency on `MediaQuery` and rebuilds automatically. Use `OrientationBuilder` when the widget structure must change on rotation.
]

#viva_box(title: "Q11. What happens to the grid when you rotate from portrait to landscape?")[
The `OrientationBuilder` detects the change and sets `crossAxisCount` from 2 to 3. The left pane width shrinks from 380 to 320 dp. The chart height reduces from 200 to 160 px. The stats row wraps to 2-per-line in the narrower left pane.
]

#topic_subheading[Category 4: Expanded, Flexible, Wrap]

#viva_box(title: "Q12. What does Expanded do?")[
`Expanded` wraps a child to make it fill its allocated flex space inside a `Row` or `Column`. It sets the child's min and max width equal to the flex allocation. In this app, `Expanded` is used in the tablet Row to give the right pane all remaining width after the fixed left pane.
]

#viva_box(title: "Q13. What is the difference between Expanded and Flexible?")[
`Expanded` forces the child to fill its flex space (min = max). `Flexible(fit: FlexFit.loose)` gives the child up to its flex space but allows it to be smaller. Use `Expanded` when the child should always fill its share; use `Flexible` when it should shrink-wrap but be bounded.
]

#viva_box(title: "Q14. What does Wrap do, and where is it used in your app?")[
`Wrap` arranges children in a sequence, automatically moving them to the next line when there is not enough space. In this app, `Wrap` is used in the `ChartSection` legend (category chips flow onto multiple lines) and in the `StatsRow` (stat cards wrap 2-per-line below 360 dp).
]

#viva_box(title: "Q15. Why use Wrap instead of a GridView for the legend?")[
The legend has a small, fixed number of items (5--7 categories) and each item is small (a coloured dot + text). `Wrap` is simpler than `GridView` for this use case and handles the flow naturally. `GridView` is better for large, uniform datasets where lazy building matters.
]

#topic_subheading[Category 5: Design Decisions and Gotchas]

#viva_box(title: "Q16. Why did you use a Row with SizedBox + Expanded for the tablet layout?")[
The left pane needs a fixed width (380 dp) so the summary (card, stats, chart) is always the same size. The right pane needs to fill all remaining space. `SizedBox(width: 380)` fixes the left pane; `Expanded` gives the right pane a flex of 1, taking all remaining width. Without `Expanded`, the right pane would size to its intrinsic content width.
]

#viva_box(title: "Q17. What happens if the screen is between 600 and 839 dp?")[
The `LayoutBuilder` selects the tablet layout. The `OrientationBuilder` detects portrait and sets the grid to 2 columns. The left pane is 380 dp, leaving 420--459 dp for the right pane — enough for 2 cards at ~200 dp each.
]

#viva_box(title: "Q18. How do you ensure the app doesn't overflow at any screen size?")[
Three mechanisms: (1) `LayoutBuilder` selects the correct layout for each width; (2) `Expanded` (a specialised `Flexible` with `FlexFit.tight`) ensures children share space proportionally; (3) `Wrap` ensures legends and stats flow onto multiple lines rather than overflowing. Additionally, `SingleChildScrollView` in the form prevents clipping.
]

#viva_box(title: "Q19. What is the difference between constraints.maxWidth and MediaQuery.size.width?")[
`constraints.maxWidth` is the width the parent has given to this widget — it may be less than the screen width (e.g., inside a pane). `MediaQuery.size.width` is always the full screen width. `LayoutBuilder` gives you `constraints.maxWidth`; `MediaQuery` gives you the screen size.
]

#viva_box(title: "Q20. Did you need to change the data model or state management for Lab 03?")[
No. The `Expense` model, `ExpenseProvider`, and `StorageService` are unchanged from Lab 01. Lab 03 is purely a layout/UI change — the `LayoutBuilder`, `OrientationBuilder`, and `Wrap` are all in the presentation layer. The data layer is untouched.
]

// ============================================================================
//                          PART F — REPOSITORY
// ============================================================================

#section_heading[Part F — GitHub Repository & How to Run]

#topic_subheading[Repository]

The complete source code for all three labs is published at:

#link("https://github.com/Chaitanya-666/CPADLABFlutterWidgets")[github.com/Chaitanya-666/CPADLABFlutterWidgets]

#topic_subheading[How to Clone and Run]

#cmd("git clone https://github.com/Chaitanya-666/CPADLABFlutterWidgets.git")
#cmd("cd CPADLABFlutterWidgets")
#cmd("flutter pub get")
#cmd("flutter run -d chrome")

To test the responsive behaviour, resize the browser window from wide to narrow and observe the layout switch at 600 dp. Rotate the device (or use Chrome DevTools' device toolbar) to see the grid column count change.

#topic_subheading[How to Recompile the PDFs]

#cmd("cd typst/")
#cmd("typst compile CpadLabAssignment03ChaitanyaShinde231070066.typ")
#cmd("typst compile CPAD_VivaPrep_Lab03_ChaitanyaShinde231070066.typ")

(Requires typst 0.13+. The only warning is "unknown font: linux libertine" which is non-fatal.)

#make_ender()
