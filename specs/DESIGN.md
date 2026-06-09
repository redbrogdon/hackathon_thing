# Peejays - UI & Visual Design Specification

This document details the interface layout, wireframes, and design guidelines for the **Peejays** journaling application.

---

## 1. Screen 1: Journal List Screen
The home screen displays the list of journal entries in a card-based scrollable feed.

```text
+-------------------------------------------------+
|  Peejays                                     [🔍]  |
|  [ Search entries...                  ] [ ⇕ ]  |
+-------------------------------------------------+
|                                                 |
|  +-------------------------------------------+  |
|  | My First Adventure            June 9, 2026 |  |
|  | Today was amazing. I woke up early and     |  |
|  | hiked up the trail to catch the sunrise...|  |
|  | [ Travel ] [ Outdoors ]                    |  |
|  +-------------------------------------------+  |
|                                                 |
|  +-------------------------------------------+  |
|  | Coding and Coffee             June 8, 2026 |  |
|  | Releasing the new beta today. The coffee   |  |
|  | in the kitchen is fresh and hot.           |  |
|  | [ Tech ]                                   |  |
|  +-------------------------------------------+  |
|                                                 |
|                                         +----+  |
|                                         |  + |  |
|                                         +----+  |
+-------------------------------------------------+
```

#### Screen Elements & Styling Guidelines:
- **App Bar**: Features a title "Peejays" styled with clean, elegant typography (e.g., Outfit or Inter).
- **Search & Sort Trigger**: Simple, modern line-art icons that animate/expand when tapped.
- **Journal Cards**: Rounded corners with subtle drop shadows to create hierarchy.
  - *Title*: Bold text, maximum of 2 lines.
  - *Date*: Right-aligned or subtitle styled, soft gray color.
  - *Content snippet*: Standard body weight text, maximum of 3 lines, fading out or using an ellipsis for truncation.
  - *Tags*: Displayed as small rounded chips (pills) with distinct but low-saturation background colors.
- **Floating Action Button (FAB)**: Placed in the bottom right, utilizing the primary brand color with a simple "+" icon.

---

## 2. Screen 2: Journal View Screen
A clean, distraction-free reading viewport for viewing the full contents of an existing entry.

```text
+-------------------------------------------------+
|  [←]                                [🗑️] [📝]  |
+-------------------------------------------------+
|                                                 |
|  My First Adventure                             |
|  June 9, 2026 at 08:30 AM                       |
|  Tags: Travel, Outdoors                         |
|                                                 |
|  Today was amazing. I woke up early and hiked   |
|  up the trail to catch the sunrise. The air was |
|  crisp and cold, but the view at the peak was   |
|  absolutely worth it.                           |
|                                                 |
+-------------------------------------------------+
```

#### View Screen Styling Guidelines:
- **Header Actions**: Contains a clear back navigation button, a trash bin icon for deletion, and an edit pencil icon to navigate to the Edit Screen.
- **Typography**: Uses larger, editorial headline fonts for titles.
- **Readability**: High contrast body text, comfortable line height (e.g., 1.5 - 1.6), and generous side paddings for an immersive reading experience.

---

## 3. Screen 3: Journal Edit Screen
A form-based writing canvas used for creating and updating entries.

```text
+-------------------------------------------------+
|  [Cancel]                              [ Save ] |
+-------------------------------------------------+
|                                                 |
|  Title:                                         |
|  [ My First Adventure                         ] |
|                                                 |
|  Tags (comma-separated):                        |
|  [ Travel, Outdoors                           ] |
|                                                 |
|  Body:                                          |
|  [ Today was amazing. I woke up early and     ] |
|  [ hiked up the trail to catch the sunrise.   ] |
|  [ The air was crisp and cold, but the view   ] |
|  [ at the peak was absolutely worth it.       ] |
|                                                 |
+-------------------------------------------------+
```

#### Edit Screen Styling Guidelines:
- **Interactive Form Fields**: Clean borders that highlight/glow when focused.
- **Placeholder text**: Lighter, italicized text guides (e.g., "Title your entry...", "Start writing here...").
- **Dynamic Input**: The body content text area expands automatically to fit longer entries without cramming.
- **Header Actions**: Top-level text actions ("Cancel" and "Save") aligned with primary brand colors.