# SUBJECT ROTATION IMPLEMENTATION GUIDE

## Overview

The new subject rotation system allows users to read different subjects on different days, automatically cycling through all available subjects.

## How Rotation Works

### Day-by-Day Example (3 subjects: Flutter, Marketing, UI/UX)

```
Day 1: Flutter (Day 1)         → Subject index 0, Day 1 of Flutter
Day 2: Marketing (Day 1)       → Subject index 1, Day 1 of Marketing
Day 3: UI/UX (Day 1)          → Subject index 2, Day 1 of UI/UX
Day 4: Flutter (Day 2)         → Subject index 0, Day 2 of Flutter
Day 5: Marketing (Day 2)       → Subject index 1, Day 2 of Marketing
Day 6: UI/UX (Day 2)          → Subject index 2, Day 2 of UI/UX
...and so on
```

### Rotation Formula

```
current_subject_index = total_days_read % subject_count
subject_day_sequence = (total_days_read / subject_count) + 1
```

## SQL Functions Updated

### 1. `get_today_reading(user_id, target_day)` - With Rotation

- **Purpose**: Get the reading for today with automatic subject rotation
- **Parameters**:
  - `user_id`: UUID of the user
  - `target_day`: Optional day number (for testing/simulation)
- **Returns**: Single reading from the subject that should be read today
- **Rotation Logic**: Uses total completed readings to determine which subject to show

### 2. `get_today_readings(user_id)` - All Current Readings

- **Purpose**: Get current reading for ALL subjects (for home page display)
- **Parameters**: `user_id` only
- **Returns**: List of current readings for each subject based on individual progress
- **Usage**: Home page showing progress in all subjects simultaneously

### 3. `get_rotation_schedule(user_id, days_ahead)` - Preview Schedule

- **Purpose**: See upcoming rotation schedule
- **Parameters**:
  - `user_id`: UUID of the user
  - `days_ahead`: Number of days to preview (default 7)
- **Returns**: Schedule showing which subject will be read on which day
- **Usage**: Planning and preview functionality

### 4. `complete_reading()` - Updated for Rotation

- **Purpose**: Mark reading as completed and update rotation progress
- **Updates**: Progress tracking now properly supports rotation system
- **Returns**: Success status and info about next subject in rotation

## Database Schema Requirements

The rotation system uses existing tables but relies on:

### Key Tables:

1. **`reading_subjects`** - All available subjects for a preference
2. **`daily_readings`** - Reading content per subject per day
3. **`user_reading_progress`** - Tracks progress per subject per user
4. **`reading_completions`** - Records completed readings

### Progress Tracking:

- **Per Subject**: `user_reading_progress.current_day` tracks progress in each subject
- **Total Progress**: Sum of `total_completed` across all subjects determines rotation

## Flutter Integration

### Current Implementation Works

The existing Flutter code will work with the new rotation system because:

1. **`getTodayReading()`** still calls `get_today_reading` - now with rotation
2. **Home page display** can use `get_today_readings` to show all subjects
3. **Progress tracking** remains the same - per subject tracking is preserved

### What Changes

- **Automatic Rotation**: Users no longer manually choose subjects
- **Balanced Learning**: Each subject gets equal attention over time
- **Predictable Schedule**: Users can see upcoming rotation schedule

## Benefits

### 1. Automatic Subject Management

- No need for users to manually switch subjects
- Ensures balanced learning across all topics
- Prevents users from neglecting certain subjects

### 2. Flexible Progress Tracking

- Each subject maintains its own day sequence
- Total progress determines rotation position
- Individual subject progress is preserved

### 3. Predictable Learning Path

- Users know what subject comes next
- Can plan their learning schedule
- Maintains engagement through variety

## Migration from Current System

### For Existing Users:

1. **Preserve Progress**: All existing `user_reading_progress` data is kept
2. **Continue from Current Day**: Each subject continues from where user left off
3. **Start Rotation**: Total completed readings determine starting position in rotation

### For New Users:

1. **Start at Day 1**: Begin with first subject, day 1
2. **Follow Rotation**: Automatic cycling through all subjects
3. **Build Progress**: Each completion advances both subject and total progress

## Testing the Rotation

### SQL Testing:

```sql
-- Test rotation for first 10 days
SELECT * FROM get_today_reading('user-id', 1);  -- Day 1
SELECT * FROM get_today_reading('user-id', 2);  -- Day 2
...

-- See rotation schedule
SELECT * FROM get_rotation_schedule('user-id', 7);

-- Check all current readings
SELECT * FROM get_today_readings('user-id');
```

### Flutter Testing:

The existing Flutter code should work immediately with improved rotation behavior.

## Configuration

### Subject Order:

Subjects rotate in the order they were created (`ORDER BY rs.created_at, rs.name`)

### Rotation Customization:

Future enhancements could include:

- Custom rotation schedules per user
- Subject priority weights
- Skip patterns for certain days
- Manual subject selection override
