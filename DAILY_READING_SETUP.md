# Daily Reading System Setup Instructions

## 1. Apply SQL Schema to Supabase

To implement the daily reading system, you need to apply the SQL schema to your Supabase database:

1. Open your Supabase dashboard
2. Go to the SQL Editor
3. Copy and paste the content from `sql/daily_reading_system_updated.sql`
4. Run the SQL script

This will create:

- `user_preferences` table
- `scopes` table
- `readings` table
- `daily_readings` table
- `reading_feedbacks` table
- Required indexes
- RPC functions: `get_daily_reading`, `submit_reading_feedback`, `mark_reading_as_read`

## 2. Sample Data (Optional)

The SQL script includes sample data for testing. You can modify or remove this section before applying.

## 3. Testing the Implementation

Once the SQL is applied, the Flutter app will automatically:

- Fetch daily readings for authenticated users
- Display personalized content based on user preferences
- Support feedback (thumbs up/down)
- Mark readings as read when users go to discussions
- Rotate subjects automatically based on weights

## 4. User Preferences Setup

Users need to have preferences set up to get personalized readings. You can:

- Add default preferences for existing users
- Create a preference setup flow in your app
- Import preference data if you have it from another source

## 5. Readings Content

Add your reading content to the `readings` table. Each reading should:

- Have a title and content
- Optionally include a quote
- Be linked to a scope for proper weighting
- Be marked as active (is_active = true)

The system will automatically select readings based on user preferences and avoid recently read content.
