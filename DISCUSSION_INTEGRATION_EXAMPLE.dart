// INTEGRATION EXAMPLE: How to add Discussion Button to DailyReadingDetailScreen
// This shows where and how to integrate the JoinDiscussionButton

// 1. Add import at the top of daily_reading_detail_screen.dart
import '../../../discussions/presentation/widgets/join_discussion_button.dart';

// 2. In the _buildContent method, add the discussion button after the main content
// Here's an example of where to place it:

Widget _buildContent(DailyReading reading, String userId) {
  return CustomScrollView(
    slivers: [
      // Existing content...
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Existing reading content widgets...
              _buildReadingHeader(reading),
              16.height,
              _buildReadingContent(reading),
              16.height,
              _buildKeyInsight(reading),
              16.height,
              _buildTomorrowHint(reading),
              24.height,

              // NEW: Add discussion button here
              _buildDiscussionSection(reading),

              24.height,
              _buildCompletionSection(reading, userId),
            ],
          ),
        ),
      ),
    ],
  );
}

// 3. Add this new method to build the discussion section
Widget _buildDiscussionSection(DailyReading reading) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.forum_outlined,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          8.width,
          Text(
            'Diskusi & Nimbrung',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
      8.height,

      // For now, use the ComingSoonDiscussionButton
      // Later, replace with JoinDiscussionButton when feature is ready
      ComingSoonDiscussionButton(readingTitle: reading.title),

      // When discussion feature is ready, use this instead:
      /*
      JoinDiscussionButton(
        readingId: reading.readingId,
        readingTitle: reading.title,
        participantCount: reading.discussionParticipantCount, // Add to entity
        commentCount: reading.discussionCommentCount, // Add to entity  
        isEnabled: reading.isCompleted, // Only allow if reading is completed
      ),
      */
    ],
  );
}

// 4. Optional: Add discussion stats to DailyReading entity (for future use)
/*
In daily_reading.dart entity, add these optional fields:

final int? discussionParticipantCount;
final int? discussionCommentCount;
final bool? hasActiveDiscussion;

// And in the constructor:
const DailyReading({
  // ... existing fields
  this.discussionParticipantCount,
  this.discussionCommentCount, 
  this.hasActiveDiscussion,
});
*/

// 5. Update the RPC function to include discussion stats (for future)
/*
In SQL, modify get_today_reading to include:

SELECT 
  dr.id as reading_id,
  -- ... existing fields
  COALESCE(rd.total_participants, 0) as discussion_participant_count,
  COALESCE(rd.total_comments, 0) as discussion_comment_count,
  (rd.id IS NOT NULL) as has_active_discussion
FROM daily_readings dr
-- ... existing joins
LEFT JOIN reading_discussions rd ON rd.reading_id = dr.id
*/
