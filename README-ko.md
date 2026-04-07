# Claude Crew

Claude Code용 멀티 에이전트 개발 파이프라인. 하나의 커맨드로 아이디어부터 배포까지, 전문 AI 에이전트 크루가 함께 일합니다.

## Claude Crew란?

Claude Crew는 **6명의 전문 에이전트**를 오케스트레이션합니다. 각 에이전트는 별도의 컨텍스트에서 독립적으로 사고하며 작업합니다:

| 에이전트 | 역할 | 특기 |
|---------|------|------|
| **Planner** | 아키텍트 | 아키텍처 설계, 태스크 분해 |
| **Builder** | 개발자 | 프로덕션 수준 코드 작성 |
| **Reviewer** | 코드 리뷰어 | 새로운 시각으로 리뷰 (Write 권한 없음) |
| **Tester** | QA 엔지니어 | 테스트 실행 및 생성 |
| **Deployer** | DevOps | 커밋, 푸시, PR 생성 |
| **Logger** | 테크니컬 라이터 | 모든 것을 기록 (백그라운드) |

**Supervisor** (메인 세션)가 크루를 지휘하고, 사용자와 대화하며, 파이프라인을 관리합니다.

## 파이프라인

```
/crew-run "React로 할일 앱 만들기"

  아이디어 → 계획 → 구현 ⟷ 리뷰 → 테스트 → 배포
     │        │       │       │        │        │
    사용자  Planner  Builder Reviewer Tester  Deployer
    대화    아키텍처  코딩    독립적    테스트   프로덕션
    with    설계     구현    리뷰     + 수정    배포
  Supervisor
```

### 게이트 (사용자가 항상 컨트롤)

파이프라인은 3곳에서 승인을 기다립니다:
1. **아이디어 후** — "요구사항이 맞나요?"
2. **계획 후** — "이 아키텍처를 승인하시겠습니까?"
3. **테스트 통과 후** — "배포할 준비가 되었나요?"

그 외는 모두 자동입니다. Builder↔Reviewer 수정 루프와 Tester→Planner→Builder 수정 루프 포함.

## 설치

### 빠른 설치 (권장)

```bash
curl -fsSL https://raw.githubusercontent.com/kimt86/claude-crew/main/install.sh | bash
```

스킬과 에이전트를 `~/.claude/`에 **글로벌 설치**합니다. 모든 프로젝트에서 `/crew-*` 커맨드를 사용할 수 있습니다.

### 프로젝트별 설치

```bash
curl -fsSL https://raw.githubusercontent.com/kimt86/claude-crew/main/install.sh | bash -s -- --project
```

현재 디렉토리의 `.claude/`에 설치합니다. 특정 프로젝트에서만 사용하고 싶을 때 유용합니다.

### 수동 설치

```bash
git clone https://github.com/kimt86/claude-crew.git
cd claude-crew

# 글로벌 설치
cp -r skills/crew-* ~/.claude/skills/
cp agents/crew-*.md ~/.claude/agents/

# 또는 프로젝트별 설치
cp -r skills/crew-* .claude/skills/
cp agents/crew-*.md .claude/agents/
```

### 설치되는 파일

| 종류 | 파일 | 위치 |
|------|------|------|
| 스킬 (8개) | `crew-run`, `crew-idea`, `crew-plan`, `crew-build`, `crew-test`, `crew-deploy`, `crew-status`, `crew-continue` | `skills/crew-*/SKILL.md` |
| 에이전트 (6개) | `crew-planner`, `crew-builder`, `crew-reviewer`, `crew-tester`, `crew-deployer`, `crew-logger` | `agents/crew-*.md` |

### 삭제

```bash
# 글로벌
rm -rf ~/.claude/skills/crew-* ~/.claude/agents/crew-*

# 프로젝트별
rm -rf .claude/skills/crew-* .claude/agents/crew-*
```

## 사용법

### 원커맨드 (전체 파이프라인)

```
/crew-run "블로그용 REST API를 인증 기능과 함께 만들어줘"
```

### 개별 단계

```
/crew-idea "CLI 도구를 만들고 싶은데..."    # 아이디어 정립
/crew-plan                                  # 아키텍처 설계
/crew-build                                 # 구현
/crew-test                                  # 테스트
/crew-deploy                                # 배포
```

### 유틸리티

```
/crew-status      # 파이프라인 진행 상태 대시보드
/crew-continue    # 중단된 작업 재개
```

### 부분 파이프라인

```
/crew-run --from build            # build 단계부터 재개
/crew-run --to plan "내 아이디어"  # plan까지만 실행
```

## 작동 원리

### 진짜 멀티 에이전트 (역할극이 아닙니다)

각 에이전트는 Claude Code의 Agent tool을 통해 **별도 컨텍스트**에서 실행됩니다:
- Reviewer는 Builder의 사고 과정을 본 적이 없습니다 — 진짜 새로운 시각
- 에이전트를 병렬 실행 가능 (Builder + Logger)
- 에이전트별 도구 제한 (Reviewer는 코드 수정 불가)

### 파일 기반 통신

에이전트들은 `.crew/` 파일을 통해 소통합니다:

```
.crew/
  state.md          ← 파이프라인 상태 (모든 에이전트 참조)
  plan.md           ← 아키텍처 (Planner 작성, 나머지 참조)
  tasks.md          ← 태스크 체크리스트 (Planner 생성, Builder 업데이트)
  build-result.md   ← 구현 결과 (Builder → Reviewer)
  reviews/          ← 리뷰 피드백 (Reviewer → Builder)
  tests/            ← 테스트 결과 (Tester → Planner)
  log.md            ← 전체 개발 로그 (Logger 관리)
  report.md         ← 최종 프로젝트 보고서
```

### 구현 ⟷ 리뷰 루프

```
Builder 구현 → Reviewer 리뷰
                    │
          승인? ────┤
          │          │
        예         수정 필요
          │          │
       다음 태스크  Builder 수정 → Reviewer 재리뷰
                       (최대 3회)
```

### 테스트 → 수정 루프

```
Tester 테스트 실행
       │
    통과? ────┐
    │          │
   예        실패
    │          │
  배포     Planner 분석 → Builder 수정 → Tester 재테스트
                              (최대 3회)
```

## 선택 사항: gstack 통합

[gstack](https://github.com/kimt86/gstack)이 설치되어 있으면 Claude Crew가 자동으로 감지하여 에이전트를 강화합니다:

| 에이전트 | gstack 스킬 | 향상 |
|---------|------------|------|
| Planner | `/plan-eng-review` | 7차원 아키텍처 스코어링 |
| Reviewer | `/review` + `/cso` | 심층 보안 감사 |
| Tester | `/qa` | 구조화된 QA 시나리오 |
| Deployer | `/ship` | 자동 PR 본문 생성 |

설정 불필요 — gstack이 있으면 자동 활용, 없으면 독립 실행.

## 요구 사항

- [Claude Code](https://claude.ai/code) (CLI, VS Code, 또는 JetBrains)
- Git (배포 기능용)
- `gh` CLI (선택, 자동 PR 생성용)

## 라이선스

MIT
