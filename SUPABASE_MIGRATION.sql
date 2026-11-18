-- ============================================================
-- 우리 가족 기록장 · 2026-11-18 (기록 탭 4종: 펫·독서·키/몸무게·주간 리포트)
--
-- ▶ 이번 업데이트는 Supabase 마이그레이션이 필요 없습니다.
--   새 기능은 모두 기존 가족 상태 JSON(public.family_state.data) 안에
--   pet / books / growth 키로만 저장됩니다.
--   - 테이블 추가 없음
--   - 컬럼 추가 없음
--   - RLS/정책 변경 없음
--   기존 README의 아래 SQL(처음 연결할 때 쓴 것)이 이미 적용돼 있으면 그대로 동작합니다.
--
--     create table if not exists public.family_state (
--       id text primary key,
--       data jsonb not null default '{}'::jsonb,
--       updated_at timestamptz not null default now()
--     );
--
--   이 파일은 "정말 바뀐 게 없는지" 눈으로 확인하고 싶을 때 쓰는 선택 쿼리 모음입니다.
--   실행해도 데이터가 바뀌지 않습니다(전부 SELECT).
-- ============================================================


-- (1) 테이블 구조가 그대로인지 확인 — 위 3개 컬럼만 나오면 정상
select column_name, data_type, is_nullable
from information_schema.columns
where table_schema = 'public' and table_name = 'family_state'
order by ordinal_position;


-- (2) 가족 행이 하나 있는지, 새 키가 저장됐는지 확인
--     pet/books/growth 가 null 이면 아직 새 버전 앱으로 저장한 적이 없다는 뜻입니다.
select id,
       updated_at,
       jsonb_typeof(data -> 'pet')   as pet_type,
       jsonb_typeof(data -> 'books') as books_type,
       jsonb_typeof(data -> 'growth') as growth_type,
       jsonb_array_length(coalesce(data -> 'books', '[]'::jsonb))  as book_count,
       jsonb_array_length(coalesce(data -> 'growth', '[]'::jsonb)) as growth_count
from public.family_state
where id = 'family';


-- (3) 펫 상태 요약 (이름·종류·경험치·마지막 돌봄)
select data -> 'pet' ->> 'name'  as pet_name,
       data -> 'pet' ->> 'kind'  as pet_kind,
       (data -> 'pet' ->> 'exp')::int as exp,
       to_timestamp(((data -> 'pet' -> 'at' ->> 'feed')::bigint) / 1000) as last_fed_at,
       jsonb_array_length(coalesce(data -> 'pet' -> 'care', '[]'::jsonb)) as care_count
from public.family_state
where id = 'family';


-- (4) 최근 책 5권
select b ->> 'date'  as read_date,
       b ->> 'who'   as reader,
       b ->> 'title' as title,
       (b ->> 'rating')::int as rating
from public.family_state f
cross join lateral jsonb_array_elements(coalesce(f.data -> 'books', '[]'::jsonb)) b
where f.id = 'family'
order by b ->> 'date' desc
limit 5;


-- (5) 가족별 최근 키·몸무게
select g ->> 'who' as who,
       g ->> 'date' as measured_on,
       (g ->> 'height')::numeric as height_cm,
       (g ->> 'weight')::numeric as weight_kg
from public.family_state f
cross join lateral jsonb_array_elements(coalesce(f.data -> 'growth', '[]'::jsonb)) g
where f.id = 'family'
order by g ->> 'who', g ->> 'date' desc;


-- 참고: 새 기능을 쓰지 않던 예전 기기 페이지가 새 버전보다 먼저 저장(push)하면
--       pet/books/growth 키가 빠진 JSON으로 덮어써질 수 있습니다(기존과 같은 전체 덮어쓰기 방식).
--       배포 후 가족 기기에서 한 번씩 새로고침하면 이후에는 문제없습니다.
