# TickTick MVP Design Spec

**Date:** 2026-05-20
**Status:** Approved
**Stack:** Flutter + Riverpod + drift (SQLite) + Clean Architecture

## Overview

A local-only Android clone of TickTick (滴答清单) core features. Data stored locally via SQLite with JSON export/import support. MVP scope covers task management essentials; architecture is designed to accommodate calendar view, kanban, habit tracker, and other features in later iterations.

## Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Framework | Flutter 3.x (Dart) | Cross-platform, user's choice |
| State | Riverpod + riverpod_annotation | Compile-time safety, testable |
| Database | drift (SQLite ORM) | Type-safe, great for relational data |
| Routing | go_router | Declarative, deep-link friendly |
| Notifications | flutter_local_notifications | Local system notifications |
| Serialization | freezed + json_serializable | Immutable entities, JSON codegen |
| Export/Import | file_picker + share_plus | File selection and sharing |
| Date/Time | intl | Locale-aware formatting |

## Architecture

Clean Architecture with three layers, dependency flowing inward:

```
Presentation → Domain ← Data
```

- **Presentation:** Screens, widgets, Riverpod providers. Observes state, renders UI, dispatches user actions.
- **Domain:** Pure Dart. Entities, repository interfaces, use cases. Zero framework dependency.
- **Data:** Repository implementations, drift DAOs, notification scheduler, export/import service.

## Data Model

### TaskList
| Column | Type | Notes |
|--------|------|-------|
| id | int (PK, auto-increment) | |
| name | text | e.g. "Work", "Personal" |
| color | text | Hex color string |
| icon | text? | Optional icon code |
| sortOrder | int | For manual ordering |
| createdAt | datetime | |
| updatedAt | datetime | |

### Task
| Column | Type | Notes |
|--------|------|-------|
| id | int (PK, auto-increment) | |
| listId | int (FK → TaskList) | |
| title | text | |
| note | text? | |
| priority | int | 0=none, 1=low, 2=medium, 3=high |
| dueDate | datetime? | Date portion |
| dueTime | text? | "HH:mm" string |
| isCompleted | bool | Default false |
| completedAt | datetime? | |
| sortOrder | int | |
| parentId | int? (self-ref FK) | For subtasks |
| recurringRuleId | int? (FK → RecurringRule) | |
| createdAt | datetime | |
| updatedAt | datetime | |

### RecurringRule
| Column | Type | Notes |
|--------|------|-------|
| id | int (PK, auto-increment) | |
| type | text | daily, weekly, monthly, yearly |
| interval | int | Every N days/weeks/etc. |
| daysOfWeek | text? | "1,3,5" for weekly (Mon=1) |
| dayOfMonth | int? | For monthly |
| endDate | datetime? | |
| maxCount | int? | Max occurrences |

### Tag
| Column | Type | Notes |
|--------|------|-------|
| id | int (PK, auto-increment) | |
| name | text | Unique |
| color | text | Hex string |

### TaskTag
| Column | Type | Notes |
|--------|------|-------|
| taskId | int (FK → Task) | Composite PK |
| tagId | int (FK → Tag) | Composite PK |

### Key Design Decisions
- Subtasks via `Task.parentId` self-reference — supports arbitrary nesting, MVP uses 1 level.
- Recurring tasks: when a recurring task is completed, generate the next instance based on the rule.
- Priority 0-3 scale matching TickTick semantics.

## Feature Modules

### 1. Today Tab
- Shows tasks due today + overdue tasks, grouped by list.
- Quick-complete via checkbox; swipe to postpone (tomorrow / next week).
- Time-grouped sections: Morning, Afternoon, Evening.
- Pull-to-refresh.

### 2. Lists Tab
- Manage task lists: create, rename, delete, reorder, change color.
- Tap a list to view its tasks.
- Within a list: add tasks, reorder via drag, collapse completed tasks.
- FAB for quick-add (title-only, rest defaults).

### 3. Task Detail
- View/edit full task: title, note, priority, due date/time, list, tags, recurring rule, subtasks.
- Subtask management: add, toggle, delete inline.
- Delete task with confirmation dialog.

### 4. Search Tab
- Full-text search across task titles and notes.
- Filter by: list, priority, completion status.
- Results link to task detail.

### 5. Settings Tab
- Export all data to JSON (nested format with version field).
- Import JSON (validate format, merge into local DB).
- App version info.

## Navigation

Bottom navigation bar with 4 tabs:
```
[ 今天 ] [ 列表 ] [ 搜索 ] [ 设置 ]
```

Routes (go_router):
- `/today` — Today overview
- `/lists` — List management
- `/lists/:id` — Tasks within a list
- `/task/:id` — Task detail (edit mode)
- `/task/new?listId=:id` — New task form
- `/search` — Search
- `/settings` — Settings

## Export/Import Format

JSON structure:

```json
{
  "version": "1.0",
  "exportedAt": "2026-05-20T12:00:00Z",
  "lists": [
    {
      "id": 1,
      "name": "Work",
      "color": "#4A90D9",
      "icon": null,
      "tasks": [
        {
          "id": 1,
          "title": "Finish report",
          "note": "Q1 report",
          "priority": 3,
          "dueDate": "2026-05-21",
          "dueTime": "14:00",
          "isCompleted": false,
          "completedAt": null,
          "subtasks": [],
          "recurring": null,
          "tags": ["urgent"]
        }
      ]
    }
  ]
}
```

- Nested: each list contains its tasks, each task contains its subtasks.
- `recurring` is the full RecurringRule serialized inline (or null).
- `tags` is a string array (tag names only — tags are resolved by name on import).
- Import: validate version, upsert by id, generate new ids for conflicts.

## Project File Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme.dart
│   └── utils.dart
├── domain/
│   ├── entities/
│   │   ├── task_list.dart
│   │   ├── task.dart
│   │   ├── recurring_rule.dart
│   │   └── tag.dart
│   ├── enums/
│   │   ├── priority.dart
│   │   └── recurring_type.dart
│   └── repositories/
│       ├── task_repository.dart
│       ├── list_repository.dart
│       └── tag_repository.dart
├── data/
│   ├── database/
│   │   ├── database.dart
│   │   ├── tables.dart
│   │   └── dao/
│   ├── repositories/
│   ├── notification_service.dart
│   └── export_import_service.dart
├── presentation/
│   ├── today/
│   ├── lists/
│   ├── search/
│   ├── settings/
│   ├── task_detail/
│   └── widgets/
└── providers/
```

## Out of Scope (Future Iterations)

- Calendar view (month/week/day)
- Kanban board view
- Habit tracker
- Pomodoro timer
- Desktop widgets
- Cloud sync
- Collaboration / shared lists
- Attachments / file uploads
