# V-STUDY database design

The Supabase database is PostgreSQL. `profiles.id` is the application profile
for `auth.users.id`; there is no application-facing `public.users` table.

## Migration order

1. `supabase/migrations/202611070001_create_profiles.sql`
2. `supabase/migrations/202611090002_create_core_schema.sql`

Run both files in the Supabase SQL Editor, in this order. The second migration
ends by requesting a PostgREST schema reload.

## ERD

```mermaid
erDiagram
  AUTH_USERS ||--|| PROFILES : has
  AUTH_USERS ||--o{ DEADLINES : owns
  SUBJECTS ||--o{ DEADLINES : categorizes
  SUBJECTS ||--o{ QUIZZES : contains
  QUIZZES ||--o{ QUIZ_QUESTIONS : has
  QUIZ_QUESTIONS ||--o{ QUIZ_OPTIONS : has
  AUTH_USERS ||--o{ QUIZ_ATTEMPTS : makes
  QUIZZES ||--o{ QUIZ_ATTEMPTS : receives
  QUIZ_ATTEMPTS ||--o{ ATTEMPT_ANSWERS : contains
  QUIZ_QUESTIONS ||--o{ ATTEMPT_ANSWERS : answers
  SUBJECTS ||--o{ DOCUMENTS : groups
  AUTH_USERS ||--o{ DOCUMENT_PROGRESS : tracks
  DOCUMENTS ||--o{ DOCUMENT_PROGRESS : tracked_by
  AUTH_USERS ||--o{ AI_PLANS : owns

  PROFILES {
    uuid id PK
    text email
    text role
    boolean is_locked
  }
  SUBJECTS {
    uuid id PK
    text code UK
    text name
    boolean is_active
  }
  DEADLINES {
    uuid id PK
    uuid owner_id FK
    uuid subject_id FK
    timestamptz due_at
    text status
    text priority
  }
  QUIZZES {
    uuid id PK
    uuid subject_id FK
    boolean is_published
  }
  QUIZ_QUESTIONS {
    uuid id PK
    uuid quiz_id FK
    integer sort_order
  }
  QUIZ_OPTIONS {
    uuid id PK
    uuid question_id FK
    smallint option_index
    boolean is_correct
  }
  QUIZ_ATTEMPTS {
    uuid id PK
    uuid owner_id FK
    uuid quiz_id FK
    numeric score
  }
  ATTEMPT_ANSWERS {
    uuid id PK
    uuid attempt_id FK
    uuid question_id FK
    boolean is_correct
  }
  DOCUMENTS {
    uuid id PK
    uuid subject_id FK
    text category
    text file_path
    boolean is_published
  }
  DOCUMENT_PROGRESS {
    uuid id PK
    uuid owner_id FK
    uuid document_id FK
    numeric progress
  }
  AI_PLANS {
    uuid id PK
    uuid owner_id FK
    jsonb plan_json
    text status
  }
```

## Tables and authorization

- `subjects`: admin-managed subject catalog; authenticated users can read active subjects.
- `deadlines`: student-owned schedule/deadline records. Students can only access their own rows; admins can manage all rows.
- `quizzes`, `quiz_questions`, `quiz_options`: admin-managed content. Students can read only published quizzes and their related content.
- `quiz_attempts`, `attempt_answers`: student-owned quiz history. Answer rows are authorized through their parent attempt.
- `documents`: admin-managed Storage metadata. Students can read only published metadata; Storage bucket policies must use the same publication rule.
- `document_progress`: per-student saved/downloaded/read progress for documents.
- `ai_plans`: per-student cached plans and source snapshots returned by the Edge Function.

All owner tables use `auth.uid()` checks. Admin checks use the existing
`public.is_admin_user()` security-definer function from the profiles migration.
The schema uses `updated_at` triggers and indexes for owner/date, subject,
publication, quiz ordering, attempts, and document progress queries.

Conflict resolution for the later offline-sync phase is last-write-wins by
`updated_at`; this migration does not yet add the local Drift queue.
