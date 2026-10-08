-- 보너스 과제 (SQLite) — queries.sql 실행이 끝난 DB에 이어서 실행한다

PRAGMA foreign_keys = ON;  -- SQLite 전용

-- ============================================================
-- 보너스 1. 같은 질문을 JOIN 과 서브쿼리 두 방식으로 풀기
-- 질문: "Claude Monet 작품에 달린 리뷰"
-- ============================================================

-- B01. 확인: JOIN 방식 — 두 표를 옆으로 붙인 뒤 조건으로 거른다. 작품 제목도 같이 볼 수 있다.
SELECT r.id, w.title, r.rating
FROM review r
INNER JOIN artwork w ON r.artwork_id = w.id
INNER JOIN artist  a ON w.artist_id  = a.id
WHERE a.name = 'Claude Monet'
ORDER BY r.id;

-- B02. 확인: 서브쿼리 방식 — 안쪽 쿼리로 "모네 작품 번호 목록"을 먼저 구하고, 바깥에서 그 번호의 리뷰만 고른다.
-- 비교: 결과 리뷰는 B01 과 같다. 하지만 서브쿼리 방식은 review 표의 칸만 볼 수 있다 (작품 제목을 못 붙임).
--       "다른 표의 정보도 함께 보여줘야 하면 JOIN, 단순히 걸러내기만 하면 서브쿼리가 읽기 쉽다."
SELECT r.id, r.artwork_id, r.rating
FROM review r
WHERE r.artwork_id IN (
    SELECT id FROM artwork
    WHERE artist_id = (SELECT id FROM artist WHERE name = 'Claude Monet')
)
ORDER BY r.id;

-- ============================================================
-- 보너스 2. 데이터 정합성 일부러 깨뜨려 보기 (모두 에러가 나야 정상)
-- ============================================================

-- B03. 확인: 없는 화가(999번)의 작품을 넣으면 FK가 막는다 → FOREIGN KEY constraint failed
INSERT INTO artwork (id, artist_id, title, year_made, medium, museum, image_url)
VALUES (100, 999, 'Fake Painting', 2026, 'Oil on canvas', 'met', 'https://example.com/fake.jpg');

-- B04. 확인: 리뷰가 달린 작품(9번)을 지우면 리뷰가 "주인 없는 리뷰"가 되므로 FK가 막는다
DELETE FROM artwork WHERE id = 9;

-- B05. 확인: 이미 있는 이메일로 가입하면 UNIQUE 가 막는다
INSERT INTO member (id, email, nickname, joined_at)
VALUES (100, 'minji@example.com', '가짜민지', '2026-10-08');

-- B06. 확인: 별점 7점은 CHECK (1~5) 가 막는다
INSERT INTO review (id, member_id, artwork_id, rating, comment, created_at)
VALUES (100, 12, 1, 7, '최고!', '2026-10-08');

-- ============================================================
-- 보너스 3. 미니 리포트 — 이 DB로 뽑을 수 있는 핵심 지표 3개
-- ============================================================

-- B07. 지표 1 — 월별 리뷰 수 추이: 서비스가 점점 활발해지는지 본다
SELECT substr(created_at, 1, 7) AS month,  -- SQLite: 'YYYY-MM-DD' 에서 앞 7글자 = 'YYYY-MM'
       COUNT(*)                 AS review_count
FROM review
GROUP BY month
ORDER BY month;

-- B08. 지표 2 — 인기 작품 TOP 5: 리뷰가 많은 순, 같으면 평균 별점이 높은 순
SELECT w.title, a.name AS artist,
       COUNT(r.id)             AS review_count,
       ROUND(AVG(r.rating), 2) AS avg_rating
FROM artwork w
INNER JOIN artist a ON w.artist_id  = a.id
INNER JOIN review r ON r.artwork_id = w.id
GROUP BY w.id, w.title, a.name
ORDER BY review_count DESC, avg_rating DESC
LIMIT 5;

-- B09. 지표 3 — 미술관별 리뷰 만족도: 어느 미술관 소장품이 반응이 좋은지 본다
SELECT w.museum,
       COUNT(DISTINCT w.id)    AS reviewed_artworks,
       COUNT(r.id)             AS review_count,
       ROUND(AVG(r.rating), 2) AS avg_rating
FROM artwork w
INNER JOIN review r ON r.artwork_id = w.id
GROUP BY w.museum
ORDER BY avg_rating DESC;
