# 🏠 우리 가족 기록장

아빠 · 엄마 · 서진(중2) · 리아(7살) 네 사람이 함께 쓰는 모바일 웹앱입니다.
빌드 도구 없이 **순수 HTML/CSS/JS**만으로 만들어져서, 폴더째 올리면 바로 열립니다.

- 앱: `index.html` (한 파일에 화면·기능 전부)
- 이미지: `assets/` (가족 캐릭터 4종 + 앱 아이콘, 모두 이 프로젝트용 오리지널 생성 이미지)
- 설정: `manifest.json` (홈 화면에 추가할 때 쓰는 앱 정보)

## 주요 기능

| 구분 | 내용 |
| --- | --- |
| 가족 홈 | 송도 실시간 날씨·초미세먼지(Open-Meteo, 실패 시 저장값), 오늘의 가족 일정, 아빠 상태 배지(출근/현장/귀가/휴식), 사용자 전환 |
| ① 용돈·별 적립 | 서진: 할 일 체크 시 원 단위 용돈 적립 + 💰 플로팅, 리아: 칭찬 별 + ⭐ 플로팅, 별 20개 → 보상 쿠폰 |
| ② 가족 미션 | 오늘의 미션 카드, `다 같이 했어요` / `다른 미션 뽑기`, 완료 시 서진 +500원·리아 +별2 |
| ③ 하이파이브 | 한 사람의 할 일을 모두 끝내면 ✋ 축하 팝업 + 색종이 + 효과음 |
| ④ 도장판 | 월~일 주간 도장판(🎯 미션 / ✅ 할 일 / 🌟 둘 다), 연속 달성 일수, 월간 달력 모달 |
| ⑤ 가족 채팅 | 프로필별 텍스트, 큰 스티커 6종, MediaRecorder 음성 메시지(미지원·권한 거부 시 안내) |
| ⑥ 공부 타이머 | 25분/50분/자유 타이머, Web Audio 알림음, 오늘·이번 주 집중 기록, 태블릿 끄기 시각 알람 |
| 알림 피로 | 아침·저녁 2번으로 묶는 설정(기본 08:00 / 20:00), 휴대폰 알림은 선택 허용 |
| 저장 | localStorage 자동 저장 + JSON 백업/복원, Supabase 연결 시 가족 폰·태블릿 동기화(20초 폴링) |

## 쓰는 법

1. 폰 브라우저에서 주소를 연다.
2. **아이폰 Safari**: 공유 → 홈 화면에 추가 / **안드로이드 Chrome**: 메뉴 → 앱 설치.
3. 오른쪽 위 `기기 저장` 배지를 누르면 가족 동기화를 설정할 수 있다.
4. 설정 → 기록 백업에서 JSON을 내려받아 두면 기기를 바꿔도 복원된다.

## 가족과 함께 쓰기 (Supabase, 선택)

한 기기에서만 쓰면 아무 설정도 필요 없습니다. 가족 폰·태블릿이 같은 기록을 함께 쓰려면:

1. [supabase.com](https://supabase.com) 무료 프로젝트 생성
2. **SQL Editor**에서 아래 실행

```sql
create table if not exists public.family_state (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.family_state enable row level security;
create policy "family read" on public.family_state for select using (true);
create policy "family insert" on public.family_state for insert with check (true);
create policy "family update" on public.family_state for update using (true);
```

3. **Project Settings → API**의 Project URL과 anon public key를 앱의 동기화 설정에 붙여넣기
4. 20초마다 다른 기기의 기록을 확인하고, 변경이 있으면 자동으로 올립니다.

> ⚠️ 위 정책은 주소와 anon key를 아는 사람이 읽고 쓸 수 있는 가족용 설정입니다.
> 민감한 정보(전화번호·주소·비밀번호·계좌)는 절대 넣지 마세요.
> anon key는 원래 공개되는 키지만, 이 저장소 파일에는 **어떤 키도 넣지 않았습니다** (브라우저에만 저장).

## 배포

GitHub Pages 기준:

```
저장소 → Settings → Pages → Source: Deploy from a branch → Branch: main / (root)
```

빌드 단계가 없어서 `index.html`이 바로 서빙됩니다. Vercel·Netlify도 폴더를 그대로 올리면 됩니다.

## 개인정보

- 전화번호·집 주소·학교·계정 정보는 코드에 없습니다.
- 검색엔진 노출을 막기 위해 `noindex,nofollow`를 넣었습니다.
- 날씨는 송도 좌표(37.3923, 126.6344)로 Open-Meteo에 요청합니다. 개인 식별 정보는 보내지 않습니다.
- 공개 주소를 아는 사람은 페이지를 열 수 있으니, 가족만의 민감한 메모는 쓰지 마세요.

## 검증

390×844 모바일 뷰포트에서 주요 동작(사용자 전환·할 일 적립·미션·도장·채팅·타이머·알람·백업·동기화)을 확인했습니다.
같은 폴더의 `screenshot-*.png`는 검증 중에 찍은 화면입니다(예시 데이터가 들어 있어요).

- `screenshot-01-home.png` 메인 홈
- `screenshot-02-home-allowance.png` 용돈 적립 애니메이션
- `screenshot-03-highfive.png` 하이파이브
- `screenshot-04-mission-stamps.png` 주간 도장판
- `screenshot-05-calendar.png` 월간 달력
- `screenshot-06-chat.png` 가족 채팅(텍스트·스티커·음성)
- `screenshot-07-timer.png` 공부 타이머
- `screenshot-08-alarm.png` 태블릿 끄기 알람
- `screenshot-09-sync.png` 동기화 설정
- `screenshot-10-kid-home.png`, `screenshot-14-kid-tasks.png` 리아 눈높이 모드
- `screenshot-12-timer-done.png` 집중 완료 알림
