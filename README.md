# Mac Catalyst Popover Drag & Drop Bug Example

This repository demonstrates an issue with drag and drop functionality within popovers on Mac Catalyst, where behavior differs between built-in and external displays.

This is not present when running in the "Designed for iPad" mode instead.

## Steps to Reproduce

1. Build and run Mac Catalyst build on a Mac with both built-in and external displays, or only built in display
2. Click the "Show List" button to open the popover
3. Attempt to drag and drop items to reorder them
4. Observe that:
  - On built-in display: Drag and drop fails silently, items cannot be reordered
  - On external display: Drag and drop works

## Technical Details
- Simple SwiftUI implementation using standard drag/drop APIs
- Issue occurs even in this minimal example without custom gestures or modifiers

## Contents
- Single view implementation demonstrating the issue
- Standard Catalyst build settings
- No external dependencies

## Feedback Report
- FB16270571

## Notes
The issue appears to be system-level, as changing displays while the app is running immediately affects the drag/drop behavior without any code changes or app restart.
