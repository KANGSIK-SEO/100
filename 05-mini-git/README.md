# 5. 파일이 언제 어떻게 바뀌었는지 기록하는 작은 프로그램 만들기 — Mini Git (자료구조와 알고리즘, 80시간, 필수) — 마감 10/22

## 1. 미션 소개
Git의 커밋 하나에는 그래프 자료구조와 해시가 담겨 있습니다. 이걸 알고 쓰면 rebase, merge, cherry-pick이 다르게 보이고, 알고리즘 공부와도 연결됩니다. Mini Git을 직접 구현하면서 그 안의 구조를 손으로 확인합니다.

이번 미션에서는 Git의 핵심 구조를 직접 구현하며 CLI 기반 Mini Git을 완성합니다. 커밋 구조를 구축하고 브랜치를 관리하는 기능, 커밋을 검색하고 정렬하는 시스템 등을 만들며 실제 Git의 동작 원리를 체득합니다.

## 2. 최종 결과물
CLI 기반 Mini Git 프로그램 1개
- **저장소 및 브랜치 관리**: `INIT <user_name>`, `BRANCH <branch_name>`, `SWITCH <branch_name>`, `COMMIT <message>`
- **커밋 로그 및 탐색**: `LOG`, `PATH <commit1> <commit2>`, `ANCESTORS <commit_hash>`
- **검색 및 정렬**: `SEARCH <keyword>`, `SEARCH --author=<name>`, `LOG --sort-by=date|author`
- **CLI 인터페이스(REPL)**: `mini-git>` 프롬프트, exit/quit로 종료
- **필수 제출물**: 엔트리 포인트(예: main.py) 1개 + README.md 1개, 실행 `python main.py`

## 3. 과제 목표
- 커밋 그래프를 구현하고, Git의 커밋 구조가 왜 DAG인지 설명할 수 있다.
- "부모가 먼저 출력되는 로그"를 만들기 위해 어떤 접근(위상 정렬)이 필요한지 설명할 수 있다.
- 두 커밋 사이의 최단 경로와 특정 커밋의 모든 조상 탐색 방법을 설명할 수 있다.
- 정렬 알고리즘을 직접 구현하고, 평균/최악 시간복잡도 및 안정 정렬 여부를 설명할 수 있다.
- 역색인의 동작 원리와, 순회 검색보다 빠른 이유를 시간복잡도 관점에서 설명할 수 있다.

## 4. 기능 요구 사항
### CLI 공통 규칙
- 명령어는 대소문자 구분 없음 (INIT, init 모두 허용)
- 문자열 인자는 공백 포함 가능, 공백 포함 시 따옴표 (예: `COMMIT "Add login feature"`)
- 옵션 표기: `SEARCH --author=<name>`, `LOG --sort-by=date|author`
- 에러 메시지 표준화: `Invalid args`, `Unknown branch: <name>`, `Unknown commit: <hash>`

### 커밋 그래프(핵심 자료구조)
- 커밋 노드 최소 필드: hash, message, author, timestamp, parents
- 각 커밋은 0개 이상의 부모, 그래프는 DAG
- 커밋 저장소는 hash로 빠르게 찾을 수 있어야 함(해시맵 기반)
- 커밋 hash는 세션 내 유일(증가 카운터/난수 등 자유, 중복 방지)

### 역색인(Inverted Index)
- 모든 커밋을 순회하지 않고 후보를 빠르게 가져옴
- 커밋 메시지를 공백 기준 split, lower로 정규화한 토큰을 키워드로 저장
- 최소 2종 인덱스: keyword -> commit_hash 목록, author -> commit_hash 목록

### 정렬 알고리즘 직접 구현
- sorted(), list.sort() 금지
- 비교 기준을 바꿔 정렬 가능(날짜, 작성자)

### 명령어 기능
- `INIT <user_name>`: 저장소 초기화, main 브랜치 생성 및 HEAD 설정, 현재 사용자(author) 설정
- `BRANCH <branch_name>`: 현재 커밋(HEAD)을 가리키는 새 브랜치 생성
- `SWITCH <branch_name>`: HEAD를 지정한 브랜치로 이동
- `COMMIT <message>`: 현재 HEAD를 부모로 하는 새 커밋 생성, 역색인 갱신
- `LOG`: 부모 커밋이 항상 자식 커밋보다 먼저 출력(위상 정렬), hash/author/timestamp/message 식별 가능
- `LOG --sort-by=date|author`: timestamp 또는 작성자 기준 정렬(동률 처리 자유)
- `PATH <commit1> <commit2>`: 커밋-부모 연결을 무방향 간선으로 간주한 최단 경로(간선 수 최소), 없으면 `No path`, 여러 개면 "hash1->hash2->..." 문자열 사전순 최소 경로
- `ANCESTORS <commit_hash>`: 도달 가능한 모든 조상 커밋 출력
- `SEARCH <keyword>`: 키워드 포함 커밋 출력(역색인 기반)
- `SEARCH --author=<name>`: 특정 작성자 커밋 출력(역색인 기반)

## 5. 보너스 과제 (선택)
- Diff: `diff <file1> <file2>`로 두 텍스트 파일을 줄 단위 비교(추가/삭제/공통)
- Merge: `merge <branch_name>`으로 부모가 2개인 merge commit 생성
- 정렬 알고리즘 성능 비교: 2개 이상 구현하고 입력 크기별 실행 시간 비교

## 6. 개발 환경
Python 3.10 이상

## 7. 제약 사항
- 실행: `python main.py`
- 그래프 전용 라이브러리 금지, sorted()/list.sort() 등 정렬 API 금지
- 기본 자료형(list, dict, set), 문자열/파일 입출력/시간 처리는 사용 가능
- 알고리즘 로직(탐색/정렬/인덱싱)은 독립된 함수/클래스로 분리, 주석 또는 docstring
- 파일 내용 추적, 네트워크 통신 구현 안 함, 데이터 영속성 불필요

## 8. 결과 예시
```
mini-git> init "Alice"
Initialized repository.
Current branch: main
Current user: Alice
mini-git> commit "Initial commit"
[main a1b2c3] Initial commit
mini-git> branch feature
Created branch: feature
mini-git> switch feature
Switched to branch: feature
mini-git> commit "Add login feature"
[feature d4e5f6] Add login feature
mini-git> switch main
Switched to branch: main
mini-git> commit "Add payment feature"
[main g7h8i9] Add payment feature
mini-git> log
commit a1b2c3 (Alice, 2024-01-15 09:00:00) [main]
Initial commit
commit d4e5f6 (Alice, 2024-01-15 09:15:00) [feature]
Add login feature
commit g7h8i9 (Alice, 2024-01-15 09:30:00) [main]
Add payment feature
mini-git> path a1b2c3 g7h8i9
Path: a1b2c3 -> g7h8i9
mini-git> search "login"
Found 1 commit:
- d4e5f6: Add login feature
mini-git> log --sort-by=author
(작성자 기준 정렬 출력)
```
