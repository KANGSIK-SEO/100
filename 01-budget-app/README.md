# 1. 나만의 용돈 기입장 프로그램 만들기 (필수) — 마감 10/1

## 1. 미션 소개
'작은 서비스'란 기능이 많은 게 아니라 예외 상황에서도 데이터가 안전한 것을 말합니다. 이번에 만드는 건 콘솔 가계부인데, 제너레이터 스트리밍, 데코레이터 분리, 타입 힌트까지 구조를 제대로 챙깁니다. 단순한 프로그램이 아니라, 유지보수 가능한 설계로 완성한다는 관점으로 접근하세요.

이번 미션은 Python으로 파일 입출력 기반의 가계부 콘솔 프로그램을 구현하는 과제입니다. 수입과 지출 내역을 단순히 저장하는 수준을 넘어, 수정/삭제, 검색, 월별 요약, 카테고리 관리, 예산 초과 경고까지 포함한 "작은 서비스" 형태로 완성합니다.

학습자는 터미널에서 명령어를 입력해 내역을 추가하고(add), 목록을 조회하며(list), 특정 조건으로 검색하고(search), 월별 요약과 카테고리 리포트를 출력하고(summary), 데이터를 내보내고(export), 기존 파일을 가져오는(import) 기능을 구현합니다. 데이터는 프로그램 종료 후에도 유지되도록 JSONL 또는 CSV 파일로 영구 저장해야 합니다.

또한, 저장 파일을 한 번에 모두 읽지 않고 제너레이터로 스트리밍 처리하며, 데코레이터로 공통 기능(예외 처리, 실행 로그, 실행 시간 측정 등)을 분리합니다. 타입 힌트를 적용해 함수와 데이터 구조의 계약을 명확히 하고, 모듈 분리로 유지보수 가능한 구조를 설계합니다.

## 2. 최종 결과물
다음 10가지 기능이 정상 동작하는 애플리케이션 1개를 완성한다.
- 거래 추가(add): 대화형 입력(날짜, 타입, 카테고리, 금액, 메모/태그) → 저장 성공 메시지 + 생성된 거래 id
- 거래 목록(list): `--limit` 등 옵션 → 최신순 거래 리스트(스트리밍 처리)
- 거래 검색(search): `--from/--to`, `--category`, `--type`, `--q`, `--tag` → 조건에 맞는 거래 리스트(최신순)
- 월별 요약(summary): `--month YYYY-MM`, `--top N` → 총수입/총지출/잔액 + 카테고리별 지출 TOP N
- 예산 설정/조회(budget): `budget set --month YYYY-MM --amount 금액` → 저장 성공 메시지 + summary에서 예산 사용률/초과 경고
- 카테고리 관리(category): `category add/list/remove` → 카테고리 목록/추가/삭제 결과(사용 중 카테고리 처리 포함)
- 거래 수정(update): `--id` 기반(옵션 방식 또는 대화형 중 1개로 고정) → 수정 성공/실패 메시지(없는 id 처리 포함)
- 거래 삭제(delete): `delete --id <id>` → 삭제 성공/실패 메시지(없는 id 처리 포함)
- 가져오기/내보내기(import/export): `import --from <csv>`, `export --out <csv> --month ...` 또는 `--from/--to` → 처리 건수 출력 + CSV 파일 생성/반영 확인

추가 조건(최종 결과물의 필수 구성)
- 데이터는 3개 이상 파일로 영구 저장되어야 한다. (예: transactions / categories / budgets)
- README.md에 실행 방법, 저장 파일 위치/형식, 주요 명령 예시, import/export CSV 스키마가 포함되어야 한다.

## 3. 과제 목표
- 파일 기반 저장(JSONL/CSV)으로 데이터를 영구 저장하고, CRUD/검색/요약/입출력을 구현할 수 있다.
- 콘솔 프로그램을 클래스/모듈로 구조화하고, 각 계층(모델/저장소/서비스/CLI)의 책임을 설명할 수 있다.
- yield 기반 제너레이터로 대용량 파일도 스트리밍 처리하는 이유와 동작 방식을 설명할 수 있다.
- 데코레이터로 공통 관심사(로그/예외/시간 측정)를 분리한 구조와 이유를 설명할 수 있다.
- 타입 힌트를 통해 입출력 계약을 명확히 했을 때 얻는 이점을 실제 코드 예로 설명할 수 있다.

## 4. 기능 요구 사항
### 실행 및 입력 방식
- 실행 예시: `python -m budget_app <command> [options]`
- 모든 명령은 `--help` 옵션으로 사용 방법이 출력되어야 합니다.
- 입력 기본 방식은 "대화형"입니다. 예: add 실행 시 날짜/타입/카테고리/금액 등을 input()으로 순차 입력
- 단, search, list, summary, export, import, delete는 옵션 인자 방식도 허용(권장)
- update는 "옵션 방식 또는 대화형" 중 하나를 선택해도 되나, 문서에 명확히 고정해야 합니다.
- 옵션 표기는 리눅스 표준인 `--`로 통일 (`--help`, `--limit`, `--from`, `--to`, `--month`)

### 데이터 모델
- 거래 내역(Transaction) 최소 필드: id(유일), type(income/expense), date(YYYY-MM-DD), amount(양수), category, memo(선택), tags(선택)
- 데이터 모델은 dataclass 또는 그에 준하는 구조로 정의
- 최소 2개 이상의 클래스 사용 (예: Transaction, TransactionRepository, BudgetStore, CategoryStore, BudgetService 등)

### 입력 검증
- 날짜 형식 오류, 음수/0 금액, 허용되지 않은 type, 존재하지 않는 category 등은 재입력 요구 또는 오류 메시지 출력으로 처리

### 저장 정책
- 저장 포맷은 JSONL 또는 CSV 중 1개 선택
- 저장 파일은 3개 이상(필수)으로 분리: `transactions.<fmt>`, `categories.<fmt>`, `budgets.<fmt>`
- 기본 저장 폴더는 `./data` 권장, 옵션으로 변경 가능(예: `--data-dir`)

### 초기 실행(저장 파일이 없을 때)
- 파일이 없으면 자동 생성하거나, "초기화 안내 메시지" 출력
- 카테고리 파일이 비어있으면: (안 A) 기본 카테고리 자동 생성(food, transport, rent, etc) 또는 (안 B) category add를 먼저 하도록 안내하고 add를 막음

### add(거래 추가)
- 대화형으로 필드를 입력받아 거래 저장
- category는 등록된 목록에 존재해야 함(없으면 안내 후 재입력/등록 유도)
- 저장 완료 시 생성된 id 출력

### list(목록 조회)
- 최신순 출력, `--limit N` 옵션 지원(기본값 제공)
- 파일 전체를 한 번에 로드하지 않고 제너레이터 기반 스트리밍 처리

### update/delete(수정/삭제)
- `delete --id <id>`로 특정 거래 삭제, 없는 id는 "없는 데이터"로 처리
- update는 (안 A) 옵션 기반: `update --id <id> [--date ...] [--type ...] [--category ...] [--amount ...] [--memo ...] [--tags ...]` 또는 (안 B) 대화형 기반 중 하나로 고정
- 파일 기반 저장에서 update/delete는 "전체 재작성/임시 파일/원자적 교체(권장)" 등 안정성 고려

### search(검색)
- 기간(`--from`, `--to`), 카테고리(`--category`), 타입(`--type`), 메모 키워드(`--q`), 태그(`--tag`)
- 결과 최신순, 스트리밍 처리 유지

### summary(월별 요약)
- `summary --month YYYY-MM` → 총 수입, 총 지출, 잔액(총수입-총지출), 카테고리별 지출 합계 TOP N(`--top` 옵션)
- 데이터가 없는 달은 "데이터 없음" 출력

### budget(예산)
- `budget set --month YYYY-MM --amount <금액>`으로 월 예산 저장
- summary 실행 시 예산이 설정되어 있으면 예산 대비 사용률(%), 초과 여부(초과 시 경고 문구) 출력
- 예산 데이터도 반드시 영구 저장

### category(카테고리 관리)
- category add/list/remove 제공
- 카테고리 삭제 시 사용 중인 내역이 있으면 삭제를 막거나 대체 카테고리를 요구

### import/export(가져오기/내보내기)
- `import --from <csv>`로 거래를 일괄 등록
- `export --out <csv>`로 조건에 맞는 거래를 CSV로 저장
- export는 `--month YYYY-MM` 또는 `--from YYYY-MM-DD --to YYYY-MM-DD` 중 하나 이상 조건을 필수로 받음
- CSV 최소 스키마(UTF-8, 헤더 포함)

| 컬럼 | 필수 | 형식 |
|------|------|------|
| date | Y | YYYY-MM-DD |
| type | Y | income/expense |
| category | Y | 등록된 카테고리 |
| amount | Y | 양수 정수 |
| memo | N | 문자열 |
| tags | N | 쉼표 구분 문자열 |

### 데코레이터(Decorator)
- 공통 관심사(예외 처리/로그/시간 측정) 데코레이터를 1개 이상 구현하고 실제 적용

### 예외 처리 및 종료 코드
- 오류는 스택트레이스 대신 원인 + 해결 힌트로 출력
- 정상 종료는 0, 오류 종료는 0이 아닌 값

### 모듈화(구조화)
- 최소 3개 이상 모듈로 분리 (권장: CLI / 서비스 / 저장소(파일 I/O) / 모델)

## 5. 보너스 과제 (선택)
- 백업 기능: backup 실행 시 타임스탬프가 포함된 백업 파일 생성
- 반복 내역 기능: 월급/월세처럼 반복되는 내역을 등록하고 특정 월에 자동 생성
- 출력 포맷 테이블 정렬: 외부 라이브러리 없이 문자열 정렬로 가독성 개선
- 저장 원자성 강화: update/delete 시 임시 파일에 쓰고 rename으로 교체

## 6. 개발 환경
Python 3.10 이상

## 7. 제약 사항
- 표준 라이브러리만 사용 가능, 외부 라이브러리 사용 금지
- JSONL 또는 CSV 중 1개 선택, 저장 파일은 3개 이상 분리
- 옵션 표기는 `--`로 통일
- 스택트레이스 출력 금지(원인 + 해결 힌트), 오류 종료 시 exit code는 0이 아니어야 함

## 8. 결과 예시
```
$ python -m budget_app add
날짜(YYYY-MM-DD): 2024-01-15
타입(income/expense): expense
카테고리: food
금액(양수): 15000
메모(선택): 점심
태그(쉼표로 구분, 없으면 엔터): meal
[저장 완료] id=TX-000012

$ python -m budget_app list --limit 3
TX-000012 | 2024-01-15 | expense | food | 15000 | 점심
TX-000011 | 2024-01-14 | income  | salary | 3000000 |
TX-000010 | 2024-01-12 | expense | transport | 20000 |

$ python -m budget_app category add
카테고리명: food
[저장 완료] category=food

$ python -m budget_app category list
- food
- transport

$ python -m budget_app budget set --month 2024-01 --amount 500000
[저장 완료] 2024-01 예산 500000원

$ python -m budget_app summary --month 2024-01 --top 3
총 수입: 3000000원
총 지출: 215000원
잔액: 2785000원
예산: 500000원 (사용률 43.0%)
지출 TOP 3
1) rent 150000원
2) food 45000원
3) transport 20000원

$ python -m budget_app export --out export.csv --month 2024-01
[완료] export.csv (12 records)

$ python -m budget_app import --from import.csv
[완료] imported=5, skipped=0

$ python -m budget_app add
날짜(YYYY-MM-DD): 2024-13-40
[오류] 날짜 형식이 올바르지 않습니다 (YYYY-MM-DD).
[힌트] 예: 2024-01-15
```
