# CPAD Lab 03 — Final Verified Package
Chaitanya Shinde · 231070066 · Adaptive & Responsive Design in Flutter

This zip contains the fully verified, corrected, and re-compiled Lab 03 deliverable,
plus two new supporting documents. Read in this order:

## 1. 02_Verification_Report/LAB03_VERIFICATION_REPORT.docx
**Read this first.** An independent, from-scratch audit of the whole submission:
what was checked, what was found (including one real compile-blocking bug and a
set of broken screenshots in the original submission), what was fixed, and the
final compliance verdict against every objective in the assignment brief.

## 2. 03_Viva_Defense_Guide/LAB03_VIVA_DEFENSE_GUIDE.docx
**Read this before the viva.** A plain-English walkthrough of exactly what the
code does and why, file by file, plus a full rehearsal Q&A section written in
the exact style a viva examiner would ask. If you didn't write this code
yourself, or don't remember why it works, this is what will let you explain it
confidently.

## 3. 01_Corrected_Submission/ — the actual lab deliverable
This is the corrected version of what you submit / have already submitted:

- `CpadLabAssignment03ChaitanyaShinde231070066.pdf` — the lab report, recompiled.
  Contains 10 screenshots (up from the original 8, two bonus ones added), all
  captions now honestly state which are genuine live app captures and which
  are code-derived diagrams (see the Verification Report, Finding F4, for why
  two views couldn't be captured live).
- `CPAD_VivaPrep_Lab03_ChaitanyaShinde231070066.pdf` — the viva prep document,
  recompiled with one small wording fix (Finding F3).
- `code/` — the 10 Dart source files exactly as they should be submitted.
  `responsive_expense_grid.dart` has one fixed line (a missing import — see
  Finding F1 in the Verification Report).
- `images/` — all 10 screenshots used in the report, at full resolution.
- `lib_full_project/` — a convenience copy of the complete Flutter `lib/`
  folder (all files, Lab 02 + Lab 03 merged) in normal Flutter project
  structure, in case you want to drop it straight into an existing project.
- `.typ` files — the Typst source for both PDFs, in case you need to edit and
  recompile them again later (`pip install typst`, then
  `python3 -c "import typst; typst.compile('file.typ', output='file.pdf')"`).

## Honest disclosure about the screenshots
7 of the 10 images are genuine screenshots — the actual compiled Flutter web
app, running in a real browser, with real sample data entered through the
app's own UI. The 2 tablet-layout images are clearly-labelled structural
diagrams generated from the verified source code, because compiling the
modified project to capture live tablet screenshots wasn't possible in the
verification sandbox (no network access to the Flutter/Dart toolchain's
servers — see Finding F4 in the Verification Report for full detail and what
to do if your instructor needs live tablet photos too).
