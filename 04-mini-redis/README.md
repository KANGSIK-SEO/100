# 4. 정보를 엄청 빠르게 찾아주는 작은 저장소 만들기 — Mini Redis (자료구조와 알고리즘, 80시간, 필수) — 마감 10/16

## 1. 미션 소개
Redis를 써봤는데 왜 이렇게 빠른지 설명해보라고 하면 막히는 분들이 많습니다. 내부의 자료구조를 직접 구현해본 사람이 드물기 때문입니다. 해시맵, 이중 연결 리스트, 힙을 밑바닥부터 짜면서 LRU와 TTL이 어떻게 동작하는지 손으로 확인합니다.

이번 미션에서는 Redis의 핵심 기능을 직접 구현하며 CLI 기반 Mini Redis를 완성합니다. 실제 Redis가 메모리 제한 환경에서 LRU 방식으로 오래된 데이터를 자동 제거하고, TTL을 통해 만료 시간을 관리하는지 직접 구현하며 체득합니다.

## 2. 최종 결과물
CLI 기반 Mini Redis 프로그램 1개
- **String 타입 기본 명령어 (6개)**: SET(LRU 갱신), GET(LRU 갱신), DEL, EXISTS, DBSIZE, KEYS(패턴 매칭 없음)
- **메모리 관리 명령어 (2개)**: CONFIG SET maxmemory(바이트 단위), INFO memory(사용량, 제한, 제거된 키 개수)
- **TTL 관리 명령어 (2개)**: EXPIRE(초 단위), TTL(남은 시간)
- **CLI 인터페이스**: REPL 환경, 명령어 파싱/실행/결과 출력 반복

## 3. 과제 목표
- 해시맵의 해시 함수와 충돌 해결 방식(체이닝)을 구현 코드를 기반으로 설명할 수 있다.
- 이중 연결 리스트와 해시맵을 조합하여 O(1) LRU 추적이 가능한 이유를 설명할 수 있다.
- 힙이 TTL 만료 시간 관리에 적합한 이유를 설명할 수 있다.
- 메모리 제한 환경에서 LRU 정책으로 데이터를 제거하는 전체 흐름(used_memory 갱신 포함)을 설명할 수 있다.

## 4. 기능 요구 사항
### 기본 자료구조 직접 구현 (내장 Key-Value 컬렉션으로 대체 금지)
- **이중 연결 리스트**: 노드(prev, next, data), 메서드 insert_front, insert_back, remove_front, remove_back, remove_node, move_to_front, 모든 연산 O(1)
- **해시맵(체이닝)**: 메서드 put, get, remove, contains, keys, size / 해시 함수 직접 설계 / 체이닝(이중 연결 리스트 재사용 권장) / 로드 팩터 0.75 초과 시 버킷 2배 확장
- **힙(최소 힙)**: 메서드 push, pop, peek, size / _heapify_up, _heapify_down / (expire_at, key) 형태 요소 처리

### String 타입 명령어
Redis 스타일 출력: `OK`, `(nil)`, `(integer) N`, `(error) ...`
- 키 기반 명령어는 실행 전 만료 여부 먼저 확인 (만료된 키는 삭제 후 없는 키처럼 처리)
- `SET key value`: 성공 시 OK, 메모리 초과 시 LRU 제거, 기존 키 덮어쓰기 시 TTL 초기화(삭제)
- `GET key`: 없거나 만료 시 (nil), 존재 시 "value", 성공 시에만 LRU 갱신
- `DEL key`: 성공 (integer) 1, 없으면 (integer) 0, LRU/TTL 구조에서도 함께 제거
- `EXISTS key`: (integer) 1 / 0
- `DBSIZE`: (integer) N
- `KEYS`: 전체 키 목록 배열 출력, 비어있으면 (empty array)

### 메모리 관리 + LRU 자동 제거
- `CONFIG SET maxmemory bytes`: 0 이상 정수, 0은 무제한, 성공 시 OK
- `INFO memory`: used_memory:<number> maxmemory:<number> evicted_keys:<number>
- used_memory = Σ( len(utf8(key)) + len(utf8(value)) ), 자료구조 오버헤드 제외
- LRU 제거 규칙: maxmemory > 0이고 SET 이후 used_memory가 초과하면 이하가 될 때까지 가장 오래 사용되지 않은 키부터 제거, evicted_keys 누적
- 단일 엔트리(키+값)가 maxmemory 초과 시 저장하지 않고 OOM 에러 출력

### TTL 관리 (힙 기반)
- `EXPIRE key seconds`: key 없으면 (integer) 0, seconds 0 이하면 즉시 만료 처리 가능, 정상 설정 시 (integer) 1
- `TTL key`: key 없으면 (integer) -2, 만료 시간 없으면 (integer) -1, 있으면 남은 초 (integer) N
- 엣지 케이스: 만료된 키는 GET 시 삭제 후 (nil), LRU 갱신 안 함 / SET 덮어쓰기 시 TTL 초기화 / EXPIRE를 없는 키에 호출하면 (integer) 0 / DEL은 모든 구조에서 함께 제거 / lazy deletion 등 구현 선택

### 에러 처리 표준 + CLI
- `mini-redis>` 프롬프트, exit 또는 quit으로 종료
- `(error) ERR unknown command '<cmd>'`
- `(error) ERR wrong number of arguments for '<cmd>' command`
- `(error) ERR value is not an integer or out of range`
- `(error) OOM command not allowed when used_memory > 'maxmemory'`
- 값 파싱: "Alice" 같은 따옴표 입력 허용, 공백 없는 값 / 큰따옴표 값 중 하나는 지원

## 5. 보너스 과제 (선택)
- 동적 배열 직접 구현 (append/get/set/remove, capacity 2배 확장)
- 스택/큐/덱 개념 조사 및 STACK_QUEUE_DEQUE.md 문서화
- 이진 트리와 전위/중위/후위/레벨 순회 구현
- 이진 탐색 트리(BST) 삽입/탐색/삭제 및 중위 순회 정렬
- Pub/Sub 기능 구현 (PUBLISH, SUBSCRIBE)

## 6. 개발 환경
Python 3.8 이상

## 7. 제약 사항
- dict, set, collections 사용 금지 (내장 컬렉션으로 해시맵/캐시 대체 금지)
- 각 자료구조(해시맵/이중 연결 리스트/힙)는 독립된 모듈/파일로 분리
- 핵심 클래스/함수에 주석 또는 docstring
- 네트워크 통신, 데이터 영속성, 복잡 자료형(List/Set/Sorted Set), 멀티스레딩 구현 안 함

## 8. 결과 예시
```
mini-redis> CONFIG SET maxmemory 30
OK
mini-redis> SET user:1 "Alice"
OK
mini-redis> SET user:2 "Bob"
OK
mini-redis> SET user:3 "Charlie"
OK
# maxmemory(30) 초과로 LRU(user:1) 제거
mini-redis> GET user:1
(nil)
mini-redis> INFO memory
used_memory:22
maxmemory:30
evicted_keys:1
mini-redis> KEYS
1. "user:2"
2. "user:3"
mini-redis> EXPIRE user:2 3
(integer) 1
mini-redis> TTL user:2
(integer) 2
# (3초 경과 후)
mini-redis> GET user:2
(nil)
mini-redis> TTL user:2
(integer) -2

mini-redis> CONFIG SET maxmemory abc
(error) ERR value is not an integer or out of range
mini-redis> GET
(error) ERR wrong number of arguments for 'GET' command
mini-redis> HELLO
(error) ERR unknown command 'HELLO'
```
