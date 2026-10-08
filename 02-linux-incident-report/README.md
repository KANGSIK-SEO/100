# 2. 컴퓨터가 갑자기 느려지거나 멈췄을 때 원인 찾아 고치기 (Linux와 OS, 40시간, 필수) — 마감 10/5

## 1. 미션 소개
Memory Leak, CPU Spike, Deadlock. 이 세 가지 중 하나가 실서버에서 터지면 어떻게 해야 할까요? 로그 없이 재부팅부터 하면 원인이 묻히고, 같은 장애가 두 번, 세 번 반복됩니다. 관제 데이터를 근거로 원인을 추론하고, GitHub Issue 형태의 기술 리포트로 남기는 것까지 직접 해봅니다.

개발자가 작성한 코드는 운영체제 위에서 프로세스 형태로 실행됩니다. 이 미션에서는 빌드된 프로그램을 운영 환경에서 실행하며 발생하는 시스템 장애(Memory Leak/OOM, CPU Spike, Deadlock) 분석을 다룹니다.

단순히 "프로그램이 꺼졌다!"는 결과만 보는 것이 아니라, 관제 데이터와 로그를 통해 장애의 원인을 추론해야 합니다. 이를 바탕으로 현업 개발자처럼 GitHub Issue 형태의 기술 리포트를 작성하며 실전적인 트러블슈팅 및 협업 커뮤니케이션 역량을 기르는 것이 최종 목표입니다.

## 2. 최종 결과물
산출물을 PDF 또는 GitHub Repository 링크 형태로 제출한다.

### 시스템 장애 분석 및 이슈 리포트 (3건)
- 3가지 장애 유형(OOM Crash, CPU Latency, Deadlock) 각각에 대해 작성된 GitHub Issue 형태의 기술 보고서
- 각 리포트 필수 포함 항목: 발생 현상 / 재현 경로 및 증거(로그, 명령어 출력, 스크린샷) / 근본 원인 / 조치 내용(환경변수 조정 등 임시 조치와 결과) / 결과 확인(Before & After)

### 이슈 리포트 마크다운 템플릿
```
[Bug] {장애 유형} - {한 줄 요약}
## 1. Description (현상 설명): 어떤 현상이, 언제 어떤 조건에서 발생했는가
## 2. Evidence & Logs (증거 자료): monitor.sh 관제 로그, 프로그램 실행 로그 핵심 구간, 시스템 도구(ps, top 등) 출력
## 3. Root Cause Analysis (원인 분석): 증거 기반 기술적 원인 분석, 관련 OS 동작 원리
## 4. Workaround & Verification (조치 및 검증): 어떤 환경변수를 어떻게 조정했는가, Before & After 비교, 근본 해결 추가 제안(선택)
```

### 케이스별 필수 증거 최소 요건
- **OOM**: monitor.sh 결과(메모리 상승 수치), 종료 직전/직후 실행 로그("Memory limit exceeded…", "SELF-TERMINATED…"), MEMORY_LIMIT 변경 전후 비교(최소 2회 실행)
- **CPU**: CPU 사용률 급상승 구간(top/ps/관제) 캡처, 종료 로그("WATCHDOG… SIGTERM"), CPU_MAX_OCCUPY 변경 전후 비교
- **Deadlock**: PID 존재 증거(`ps -ef | grep …`), CPU/MEM 변화 정체 증거(`top -H` 또는 `ps -L`), 마지막 로그 지점("WAITING… BLOCKED"), 스레드/락 대기 추론 근거

## 3. 미션 목표
- 메모리 구조를 이해하고, 메모리 누수가 시스템 전체에 미치는 영향을 설명할 수 있다.
- 특정 프로세스의 CPU 과점유가 시스템 지연을 유발하는 원리를 설명할 수 있다.
- 교착상태(Deadlock)의 개념을 이해하고, 프로세스가 멈춘 상태를 시스템 도구로 식별하여 진단할 수 있다.
- 로그와 관제 데이터를 증거로 제시하여 육하원칙에 맞게 장애 상황을 기술하고, GitHub Issue를 통해 동료 개발자와 명확하게 소통할 수 있다.

## 4. 기능 요구 사항
### 사전 준비 사항
제공 어플리케이션 agent-leak-app 실행 조건 (미충족 시 부트 시퀀스에서 자동 실패)

| 항목 | 조건 |
|------|------|
| 실행 계정 | root가 아닌 일반 사용자 |
| AGENT_HOME | 필수 환경변수 설정 |
| AGENT_PORT | 15034 (고정) |
| AGENT_UPLOAD_DIR | `$AGENT_HOME/upload_files` (디렉터리 존재 필수) |
| AGENT_KEY_PATH | `$AGENT_HOME/api_keys` (경로 존재 필수) |
| AGENT_LOG_DIR | 로그 디렉터리 (존재 + 쓰기 권한) |
| MEMORY_LIMIT | 정수, 50~512 범위 (MB) |
| CPU_MAX_OCCUPY | 정수, 10~100 범위 (%) |
| MULTI_THREAD_ENABLE | true/false (1/0, yes/no 허용) |
| secret.key 파일 | `$AGENT_HOME/api_keys/secret.key` 존재, 내용: `agent_api_key_test` |
| 네트워크 | 0.0.0.0:15034 바인딩 가능 |

### 메모리 누수 원인 규명 및 리포팅
- monitor.sh를 활용하여 agent-leak-app의 물리 메모리 사용량이 시간 경과에 따라 증가하는 패턴 관측
- 프로세스가 예고 없이 중단되었을 때 로그를 분석하여 메모리 임계치 초과로 MemoryGuard에 의해 강제 종료되었음을 나타내는 핵심 로그 식별
- MEMORY_LIMIT를 조정하여 더 오래 생존하는 것을 확인하고 Before & After 기록

### CPU 과점유 분석 및 리포팅
- 시스템 전체 부하가 아닌 특정 프로세스(agent-leak-app)의 CPU 사용률이 급격히 상승하는 구간 식별
- 해당 종료가 오류가 아닌 Watchdog 정책에 따른 보호 조치였음을 입증
- CPU_MAX_OCCUPY를 조정하여 종료 여부/생존 시간 변화를 확인하고 Before & After 기록

### 교착상태(Deadlock) 진단 및 리포팅
- 프로세스가 살아있으나(PID 존재) CPU/메모리 변화 없고 로그도 멈춘 무응답 상태 식별
- 마지막 로그를 분석하여 서로 다른 스레드가 상대방의 자원을 무한히 기다리는 상태임을 논리적으로 증명
- MULTI_THREAD_ENABLE을 조정하여 데드락 재현/회피 비교 결과 기록
- 참고 키워드: 식사하는 철학자들 문제, 교착상태 4대 조건(상호 배제, 점유 대기, 비선점, 순환 대기)

## 5. 보너스 과제 (선택)
### 스케줄링 알고리즘 추론
- 로그의 타임스탬프를 기반으로 프로세스 간 실행 순서와 교체 주기를 패턴화
- 도출된 패턴을 근거로 Round-Robin, FCFS, Priority 중 무엇인지 논리적으로 추론
- 추론한 알고리즘의 장단점과 적합한 서비스 성격(실시간 웹 서버 vs 배치 서버 등) 분석

## 6. 개발 환경
- 제공된 바이너리(Python 기반)를 실행할 수 있는 리눅스 환경
- 로컬 또는 격리된 환경(Docker 컨테이너 등)에서 실행 권장
- 공유 네트워크 환경에서는 방화벽 설정에 유의
- 바이너리 디컴파일 및 리버스 엔지니어링 시도 금지

## 7. 제약 사항
monitor.sh, ps, top, htop, pstree, kill 등 리눅스 표준 명령어 및 라이브러리 사용

## 8. 결과 예시 (OOM 케이스)
**[Bug] 프로세스 실행 10분 후 메모리 보호 정책에 의한 비정상 강제 종료**

1. **Description**: agent-leak-app 실행 약 10분 경과 시 SELF-TERMINATED 메시지와 함께 프로세스 종료, MemoryGuard에 의한 강제 종료 반복
2. **Evidence & Logs**: monitor.log에서 MEM이 5.1% → 35.4% → 68.2% → 89.5% → 96.8%로 선형 상승, CPU는 안정적. 실행 로그:
   ```
   [CRITICAL] [MemoryGuard] Memory limit exceeded (256MB >= 256MB)
   Self-terminating process
   >>> [SYSTEM] SELF-TERMINATED (Memory Limit Exceeded) <<<
   ```
3. **Root Cause Analysis**: 힙 메모리에서 데이터를 해제하지 않고 쌓는 메모리 누수 결함. MEMORY_LIMIT 도달 시 MemoryGuard가 SIGKILL로 강제 종료
4. **Workaround & Verification**: MEMORY_LIMIT을 256MB → 512MB로 상향, 30분 이상 생존 확인. 근본 해결은 소스 코드 리팩토링 필요

## 데이터 파일
- agent-app-leak.zip (agent-app-leak-x86: Intel chip / agent-app-leak-arm64: Apple chip)
- 단위문제 PDF
