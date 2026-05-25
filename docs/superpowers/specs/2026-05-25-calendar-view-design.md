# Calendar View Design Spec

**Date:** 2026-05-25
**Status:** Approved
**Stack:** Flutter + Riverpod + drift + table_calendar + Custom Time Grid

## Overview

Add month/week/day calendar views to TickTick, replacing the current Today tab. Users can browse tasks by date on a month grid, week time grid, or day time grid. Tasks without specific times are displayed in an "all-day" section. New tasks can be created by clicking on a date or time slot.

## Architecture

Reuse existing Clean Architecture layers. Calendar extends the data layer with date-range queries. The presentation layer adds calendar-specific views and providers without modifying existing entities or database schemas.

```
Data layer:  TaskDao.getTasksForDateRange() → TaskRepository → calendarMonthTasksProvider
UI layer:    CalendarPage → PageView(MonthView | WeekView | DayView)
```

### New Dependency

- `table_calendar: ^3.1.3` — month grid rendering, date selection, dot markers

## Data Layer Changes

### DAO — `lib/data/database/dao/task_dao.dart`

New method:

```dart
Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end) {
  return (select(tasks)
    ..where((t) =>
      t.dueDate.isSmallerOrEqualValue(end) &
      t.dueDate.isBiggerOrEqualValue(start) &
      t.parentId.isNull())
    ..orderBy([(t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc)]))
    .get();
}
```

### Repository — `lib/domain/repositories/task_repository.dart`

New methods in `TaskRepository` interface:

```dart
Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end);
Stream<List<Task>> watchTasksForDateRange(DateTime start, DateTime end);
```

### Repository Impl — `lib/data/repositories/task_repository_impl.dart`

Implement the new methods using the DAO query, with `_toEntity` mapping.

### Providers — `lib/providers/task_providers.dart`

Two new providers:

```dart
final calendarMonthTasksProvider =
    FutureProvider.family<List<Task>, DateTime>((ref, month) {
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0);
  return ref.read(taskRepositoryProvider).getTasksForDateRange(start, end);
});

final calendarDateTasksProvider =
    FutureProvider.family<List<Task>, DateTime>((ref, date) {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));
  return ref.read(taskRepositoryProvider).getTasksForDateRange(start, end);
});
```

## Navigation Changes

### Bottom Nav

Replace Tab 0 from "Today" (`/today`) to "Calendar" (`/calendar`):

| Index | Before | After |
|-------|--------|-------|
| 0 | `/today` — TodayPage | `/calendar` — CalendarPage |
| 1 | `/lists` | `/lists` (unchanged) |
| 2 | `/search` | `/search` (unchanged) |
| 3 | `/settings` | `/settings` (unchanged) |

`initialLocation` changes from `/today` to `/calendar`.

### CalendarPage Internal Navigation

```
CalendarPage
├── AppBar: title reflects current view + "Today" button
├── ViewSwitcher: 月 | 周 | 日 (segmented control)
├── PageView (horizontal swipe)
│   ├── MonthView (table_calendar)
│   ├── WeekView (custom time grid, 7 columns)
│   └── DayView (custom time grid, 1 column)
└── Selected day task list (below grid in month view)
```

- Swipe left/right navigates: month → prev/next month, week → prev/next week, day → prev/next day
- Tapping the view switcher changes the PageView page and updates the AppBar title
- "Today" button in AppBar resets to today's date in current view

## Month View

### Implementation

Use `table_calendar` package with:
- `startingDayOfWeek: StartingDayOfWeek.monday`
- `locale: 'zh_CN'`
- `calendarFormat: CalendarFormat.month`
- `firstDay: DateTime.utc(2020)`, `lastDay: DateTime.utc(2035)`

### Day Cell Markers

Each day cell shows up to 3 colored dots representing the highest 3 priority levels found among tasks on that day:

| Priority | Color | Hex |
|----------|-------|-----|
| High (3) | Red | `#E74C3C` |
| Medium (2) | Orange | `#F5A623` |
| Low (1) | Blue | `#4A90D9` |

A day with high+medium tasks shows red and orange dots. A day with only low-priority tasks shows a single blue dot. Days without tasks show no dots.

### Interaction
- **Tap date** → selects it, shows that day's task list below the calendar
- **Tap empty date** → quick-create dialog with date pre-filled
- **Swipe** → PageView switches to previous/next month
- **Below calendar** → selected day's tasks rendered as TaskTile list

## Week View

### Structure
```
┌──────────────────────────────────────────┐
│ All-Day Area (tasks without dueTime)      │
├──────┬──────┬──────┬──────┬──────┬──────┬──────┤
│ Mon  │ Tue  │ Wed  │ Thu  │ Fri  │ Sat  │ Sun  │  ← day headers
├──────┼──────┼──────┼──────┼──────┼──────┼──────┤
│      │      │      │      │      │      │      │ 06:00
│ task │      │      │      │      │      │      │
│      │      │      │      │      │      │      │ 07:00
│      │      │      │      │      │      │      │ ...
│      │      │      │      │      │      │      │ 24:00
└──────┴──────┴──────┴──────┴──────┴──────┴──────┘
```

- 7 columns × 18 hour rows (6:00–24:00)
- Each hour row = 60px height, total grid height = 1080px
- Scrollable vertically; 7 columns scroll in sync
- Left side: hour labels (6, 7, 8...24)
- Day headers show: day of week + date number, today highlighted

### Task Cards

Positioned absolutely in the correct day column and time row:

```
┌─ 09:00 ──────┬──────────┐
│              │ ┌──────┐ │
│              │ │ 周会  │ │  ← position: top = hour*60px + minute fraction
│              │ │ 09:30 │ │     background color: list color
│              │ └──────┘ │     left border: priority color
│              │          │
└──────────────┴──────────┘
```

### Interaction
- **Tap task card** → navigate to `/task/:id`
- **Tap empty time slot** → quick-create with date+time pre-filled
- **Horizontal swipe** → previous/next week
- **Vertical scroll** → all columns synchronized

## Day View

### Structure

Same as week view but single column:

```
┌──────────────────────┐
│ All-Day Area          │
├──────────────────────┤
│ 06:00 ───────────────│
│ 07:00 ───────────────│
│ 08:00 ┌ 晨会         │
│ 09:00 │              │
│ 10:00 ───────────────│
│ ...                  │
│ 24:00 ───────────────│
└──────────────────────┘
```

- 1 column × 18 hour rows (6:00–24:00)
- All-day tasks at top
- Same task card design as week view
- Horizontal swipe → previous/next day

### Interaction
- **Tap task card** → navigate to task detail
- **Tap empty time slot** → quick-create with date+time
- **Horizontal swipe** → previous/next day

## Task Creation from Calendar

- **From month view:** tap a date → quick-create dialog with `dueDate` pre-filled
- **From week/day view:** tap empty time slot → quick-create with `dueDate` and `dueTime` pre-filled
- The quick-create is a minimal bottom sheet: title TextField, pressing Enter creates the task; tap "More" opens the full TaskFormPage
- Tasks created from calendar default to the user's first list (Inbox) or a configurable default list

## File Changes Summary

| File | Action |
|------|--------|
| `lib/data/database/dao/task_dao.dart` | Add `getTasksForDateRange()` |
| `lib/domain/repositories/task_repository.dart` | Add 2 method signatures |
| `lib/data/repositories/task_repository_impl.dart` | Implement 2 new methods |
| `lib/providers/task_providers.dart` | Add 2 new providers |
| `lib/app.dart` | Change Tab 0: `/today` → `/calendar`, update initialLocation |
| `lib/presentation/calendar/calendar_page.dart` | **Create** — calendar shell with PageView + ViewSwitcher |
| `lib/presentation/calendar/month_view.dart` | **Create** — table_calendar wrapper |
| `lib/presentation/calendar/week_view.dart` | **Create** — 7-column time grid |
| `lib/presentation/calendar/day_view.dart` | **Create** — 1-column time grid |
| `lib/presentation/calendar/all_day_section.dart` | **Create** — all-day task strip |
| `lib/presentation/calendar/task_card.dart` | **Create** — calendar-specific task card widget |
| `lib/presentation/today/today_page.dart` | **Remove** (or keep as utility) |
| `pubspec.yaml` | Add `table_calendar: ^3.1.3` |

## Out of Scope

- Drag-and-drop to reschedule (change task dueDate by dragging card)
- Multi-day events (task spanning multiple days)
- Calendar sync / iCal / Google Calendar integration
- Color coding by list instead of priority
- Week start day preference (hardcoded Monday)
