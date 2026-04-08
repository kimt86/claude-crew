# Claude Crew

Claude Code용 멀티 에이전트 개발 파이프라인. 하나의 커맨드로 아이디어부터 배포까지, 전문 AI 에이전트 크루가 함께 일합니다.

## Claude Crew란?

Claude Crew는 **7명의 전문 에이전트**를 오케스트레이션합니다. 각 에이전트는 별도의 컨텍스트에서 독립적으로 사고하며 작업합니다:

| 에이전트 | 역할 | 특기 |
|---------|------|------|
| **Planner** | 아키텍트 | 아키텍처 설계, 태스크 분해 |
| **Builder** | 개발자 | 프로덕션 수준 코드 작성 |
| **Reviewer** | 코드 리뷰어 | 새로운 시각으로 리뷰 (Write 권한 없음) |
| **Critic** | 외부 피드백 | 요구사항 충족 여부 평가 (Write 권한 없음) |
| **Tester** | QA 엔지니어 | 테스트 실행 및 생성 |
| **Deployer** | DevOps | 커밋, 푸시, PR 생성 |
| **Logger** | 테크니컬 라이터 | 모든 것을 기록 (백그라운드) |

**Supervisor** (메인 세션)가 크루를 지휘하고, 사용자와 대화하며, 파이프라인을 관리합니다.

## 파이프라인

```text
/crew-run "React로 할일 앱 만들기"

  아이디어 → 계획 → 구현 ⟷ 리뷰 ⟷ 피드백 → 테스트 → 배포
     │        │       │       │       │         │        │
    사용자  Planner  Builder Reviewer Critic   Tester  Deployer
    대화    아키텍처  코딩    코드     요구사항   테스트   프로덕션
    with    설계     구현    리뷰     평가      + 수정    배포
  Supervisor
```

### 구현-리뷰-피드백 루프

모든 구현 사이클은 **3개의 독립 에이전트**를 거칩니다:

```text
Builder (구현) → Reviewer (코드 리뷰) → Critic (외부 피드백)
       ↑                                        │
       └──────── 이슈 발견 시 ──────────────────┘
                  (최대 3회)
```

1. **Builder**가 태스크를 구현합니다
2. **Reviewer**가 코드 품질, 버그, 보안을 검사합니다 (별도 컨텍스트 — 새로운 시각)
3. **Critic**이 요구사항 충족, 완성도, 실제 사용 준비 상태를 평가합니다 (별도 컨텍스트 — 외부 관점)

Reviewer와 Critic **모두** 승인해야 다음 태스크로 진행합니다.

### 게이트 (사용자가 항상 컨트롤)

파이프라인은 3곳에서 승인을 기다립니다:

1. **아이디어 후** — "요구사항이 맞나요?"
2. **계획 후** — "이 아키텍처를 승인하시겠습니까?"
3. **테스트 통과 후** — "배포할 준비가 되었나요?"

그 외는 모두 자동입니다. Builder↔Reviewer↔Critic 피드백 루프와 Tester→Planner→Builder 수정 루프 포함.

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
| 에이전트 (7개) | `crew-planner`, `crew-builder`, `crew-reviewer`, `crew-critic`, `crew-tester`, `crew-deployer`, `crew-logger` | `agents/crew-*.md` |

### 삭제

```bash
# 글로벌
rm -rf ~/.claude/skills/crew-* ~/.claude/agents/crew-*

# 프로젝트별
rm -rf .claude/skills/crew-* .claude/agents/crew-*
```

## 사용법

### 원커맨드 (전체 파이프라인)

```text
/crew-run "블로그용 REST API를 인증 기능과 함께 만들어줘"
```

### 개별 단계

```text
/crew-idea "CLI 도구를 만들고 싶은데..."    # 아이디어 정립
/crew-plan                                  # 아키텍처 설계
/crew-build                                 # 구현
/crew-test                                  # 테스트
/crew-deploy                                # 배포
```

### 유틸리티

```text
/crew-status      # 파이프라인 진행 상태 대시보드
/crew-continue    # 중단된 작업 재개
```

### 부분 파이프라인

```text
/crew-run --from build            # build 단계부터 재개
/crew-run --to plan "내 아이디어"  # plan까지만 실행
```

## 작동 원리

### 진짜 멀티 에이전트 (역할극이 아닙니다)

각 에이전트는 Claude Code의 Agent tool을 통해 **별도 컨텍스트**에서 실행됩니다:

- Reviewer는 Builder의 사고 과정을 본 적이 없습니다 — 진짜 새로운 시각
- Critic은 Builder와 Reviewer 모두와 독립적으로 평가합니다 — 진짜 외부 피드백
- 에이전트를 병렬 실행 가능 (Builder + Logger)
- 에이전트별 도구 제한 (Reviewer와 Critic은 코드 수정 불가)

### 명시적 에이전트 스폰

모든 스킬 파일은 Supervisor가 Agent tool을 통해 에이전트를 스폰하도록 명시적으로 지시합니다. Supervisor는 절대로 직접 코드를 작성하거나, 리뷰하거나, 테스트하지 않습니다 — 항상 전문 에이전트에게 위임합니다. 이것이 단일 에이전트 역할극이 아닌, 진짜 멀티 에이전트 동작을 보장합니다.

### 파일 기반 통신

에이전트들은 `.crew/` 파일을 통해 소통합니다:

```text
.crew/
  state.md          ← 파이프라인 상태 (모든 에이전트 참조)
  plan.md           ← 아키텍처 (Planner 작성, 나머지 참조)
  tasks.md          ← 태스크 체크리스트 (Planner 생성, Builder 업데이트)
  build-result.md   ← 구현 결과 (Builder → Reviewer/Critic)
  reviews/          ← 코드 리뷰 피드백 (Reviewer → Builder)
  feedback/         ← 외부 피드백 (Critic → Builder)
  tests/            ← 테스트 결과 (Tester → Planner)
  log.md            ← 전체 개발 로그 (Logger 관리)
  report.md         ← 최종 프로젝트 보고서
```

### 구현 ⟷ 리뷰 ⟷ 피드백 루프

```text
Builder 구현 → Reviewer 리뷰 → Critic 평가
                                    │
                     모두 승인? ────┤
                     │               │
                   예             이슈 발견
                     │               │
                 다음 태스크    Builder 수정 → Reviewer → Critic
                                  (최대 3회)
```

### 테스트 → 수정 루프

```text
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
