# Daily Reading RPC Functions Documentation

This document contains all working RPC functions for the daily reading system, updated and tested as of July 2025.

## Overview

The daily reading system generates personalized daily readings for users based on their preferences and tracks their interaction history. All functions have been tested and verified to work with the correct schema.

## Main RPC Functions (Client-Facing)

### 1. get_user_daily_reading(user_id UUID)

**Purpose**: Retrieves or generates a daily reading for a specific user.

**Returns**: 
```sql
TABLE(
    reading_id UUID,
    title CHARACTER VARYING(255),
    author CHARACTER VARYING(255),
    content TEXT,
    category CHARACTER VARYING(100),
    tags TEXT[],
    source_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    scope_name CHARACTER VARYING(100),
    generated_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE
)
```

**Usage**:
```sql
SELECT * FROM get_user_daily_reading('user-uuid-here');
```

**Description**: This is the main function that clients should call to get a user's daily reading. It automatically handles generation if no reading exists for today.

---

## Helper Functions (Internal)

### 2. get_next_uninteracted_reading(p_user_id UUID, p_scope_name CHARACTER VARYING)

**Purpose**: Finds the next reading a user hasn't interacted with in a specific scope.

**Returns**: 
```sql
TABLE(
    reading_id UUID,
    title CHARACTER VARYING(255),
    author CHARACTER VARYING(255),
    content TEXT,
    category CHARACTER VARYING(100),
    tags TEXT[],
    source_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE
)
```

**Logic**: 
- Prioritizes readings the user has never seen
- Falls back to oldest interacted readings if all have been seen
- Excludes readings from the last 30 days to avoid repetition

---

### 3. get_newest_reading_for_preference(p_user_id UUID, p_scope_name CHARACTER VARYING)

**Purpose**: Gets the most recent reading in a scope for a user's preference.

**Returns**: Same structure as get_next_uninteracted_reading

**Logic**: Returns the newest reading available in the specified scope.

---

### 4. get_oldest_reading_for_preference(p_user_id UUID, p_scope_name CHARACTER VARYING)

**Purpose**: Gets the oldest reading in a scope for a user's preference.

**Returns**: Same structure as get_next_uninteracted_reading

**Logic**: Returns the oldest reading available in the specified scope.

---

### 5. generate_daily_reading_for_user(p_user_id UUID)

**Purpose**: Generates a new daily reading for a specific user.

**Returns**: 
```sql
TABLE(
    reading_id UUID,
    title CHARACTER VARYING(255),
    author CHARACTER VARYING(255),
    content TEXT,
    category CHARACTER VARYING(100),
    tags TEXT[],
    source_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    scope_name CHARACTER VARYING(100),
    generated_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE
)
```

**Logic**:
1. Checks if user already has a daily reading for today
2. Gets user's active preferences
3. Uses different strategies based on user's reading history:
   - **Uninteracted**: Prioritizes readings never seen before
   - **Newest**: Gets most recent readings when user is caught up
   - **Oldest**: Gets older readings for comprehensive coverage
4. Records the generation in daily_readings table
5. Sets expiration to end of day (23:59:59)

---

## Bulk Operations

### 6. generate_daily_readings_for_all_users()

**Purpose**: Generates daily readings for all users (used by cron job).

**Returns**: 
```sql
TABLE(
    user_id UUID,
    reading_id UUID,
    generated_at TIMESTAMP WITH TIME ZONE,
    status TEXT
)
```

**Logic**:
- Iterates through all users
- Calls generate_daily_reading_for_user for each
- Logs results including any errors
- Skips users who already have readings for today

---

## Database Schema Relationships

### Tables Used:
- **users**: User accounts
- **preferences**: User reading preferences  
- **scopes**: Reading categories/topics
- **readings**: Available reading content
- **daily_readings**: Generated daily reading assignments
- **reading_feedbacks**: User interaction tracking
- **user_reading_progress**: Reading completion tracking

### Key Relationships:
```
users (1) → (n) preferences (n) → (1) scopes (1) → (n) readings
users (1) → (n) daily_readings (n) → (1) readings
users (1) → (n) reading_feedbacks (n) → (1) readings
users (1) → (n) user_reading_progress (n) → (1) readings
```

## Data Types and Schema Compliance

All functions use the correct data types matching the database schema:
- **Character Varying Fields**: title, scope_name, author, category (with proper length limits)
- **Text Fields**: content, source_url  
- **UUID Fields**: All ID references
- **Timestamp Fields**: All datetime fields with time zone support
- **Array Fields**: tags (TEXT[])

## Error Handling

All functions include proper error handling:
- Input validation for user existence
- Graceful handling of missing preferences
- Fallback strategies when no suitable readings are found
- Transaction rollback on errors
- Detailed error logging

## Performance Considerations

- Functions use efficient queries with proper indexing
- Batch operations for bulk generation
- Optimized filtering to avoid recent readings
- Minimal data transfer with targeted SELECT statements

## Usage Examples

### Get Daily Reading for User
```sql
-- Get or generate daily reading for a user
SELECT * FROM get_user_daily_reading('123e4567-e89b-12d3-a456-426614174000');
```

### Bulk Generate for All Users (Cron Job)
```sql
-- Generate daily readings for all users (scheduled task)
SELECT generate_daily_readings_for_all_users();
```

### Manual Generation for Specific User
```sql
-- Manually generate a new daily reading
SELECT * FROM generate_daily_reading_for_user('123e4567-e89b-12d3-a456-426614174000');
```

## Deployment Notes

1. All functions must be deployed in the correct order (helpers first, then main functions)
2. Proper permissions must be set for authenticated users
3. RLS (Row Level Security) policies must be configured appropriately
4. Cron job should be scheduled to run daily at 23:59:59 GMT+7

## Testing and Validation

All functions have been tested with:
- Valid user IDs with preferences
- Edge cases (no preferences, no available readings)
- Bulk operations
- Schema compliance verification
- Performance testing

---

*Last Updated: July 2025*
*Status: All functions tested and working*
