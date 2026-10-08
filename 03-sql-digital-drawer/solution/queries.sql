-- 핵심 쿼리 15개 (SQLite)
-- 각 쿼리 위의 "확인:" 줄이 무엇을 확인하는 쿼리인지 설명한다.
-- 실행 결과는 results/ 폴더에 있다 (python run.py 로 다시 만들 수 있다).

PRAGMA foreign_keys = ON;  -- SQLite 전용

-- ============================================================
-- [기본 조회] WHERE / ORDER BY / LIMIT
-- ============================================================

-- Q01. 확인: 네덜란드 화가만 골라 태어난 순서대로 본다 (WHERE + ORDER BY)
SELECT name, birth_year, death_year
FROM artist
WHERE nationality = 'Dutch'
ORDER BY birth_year;

-- Q02. 확인: 1880년 이후에 그려진 작품 중 최신작 5점 (WHERE + ORDER BY DESC + LIMIT)
SELECT title, year_made, museum
FROM artwork
WHERE year_made >= 1880
ORDER BY year_made DESC
LIMIT 5;

-- Q03. 확인: 제목에 'Portrait'(초상화)가 들어간 작품 검색 (LIKE 패턴 검색)
SELECT id, title, year_made
FROM artwork
WHERE title LIKE '%Portrait%'
ORDER BY year_made;

-- Q04. 확인: 별점 5점 리뷰 중 가장 최근 것 5개 (WHERE + ORDER BY + LIMIT)
SELECT id, artwork_id, rating, comment, created_at
FROM review
WHERE rating = 5
ORDER BY created_at DESC
LIMIT 5;

-- ============================================================
-- [조인] INNER JOIN 3개, LEFT JOIN 1개
-- ============================================================

-- Q05. 확인: 작품 제목 옆에 화가 이름을 붙여 본다 (INNER JOIN, artwork.artist_id = artist.id)
SELECT a.name AS artist, w.title, w.year_made
FROM artwork w
INNER JOIN artist a ON w.artist_id = a.id
WHERE a.name = 'Vincent van Gogh'
ORDER BY w.year_made;

-- Q06. 확인: 리뷰 한 줄에 "누가 / 어떤 작품에 / 몇 점" 을 사람이 읽을 수 있게 (INNER JOIN 3개 표)
SELECT m.nickname, w.title, a.name AS artist, r.rating, r.created_at
FROM review r
INNER JOIN member  m ON r.member_id  = m.id
INNER JOIN artwork w ON r.artwork_id = w.id
INNER JOIN artist  a ON w.artist_id  = a.id
ORDER BY r.created_at DESC
LIMIT 10;

-- Q07. 확인: 미술관이 'met'(메트로폴리탄)인 작품에 달린 리뷰만 본다 (INNER JOIN + WHERE)
SELECT w.museum, w.title, r.rating, r.comment
FROM artwork w
INNER JOIN review r ON r.artwork_id = w.id
WHERE w.museum = 'met'
ORDER BY r.rating DESC, w.title;

-- Q08. 확인: 리뷰가 하나도 없는 작품 찾기 (LEFT JOIN: 짝이 없으면 오른쪽이 NULL)
SELECT w.id, w.title, r.id AS review_id
FROM artwork w
LEFT JOIN review r ON r.artwork_id = w.id
WHERE r.id IS NULL
ORDER BY w.id;

-- ============================================================
-- [집계] COUNT / SUM / AVG + GROUP BY
-- ============================================================

-- Q09. 확인: 국적별 화가 수와 작품 수 (COUNT + GROUP BY)
SELECT a.nationality,
       COUNT(DISTINCT a.id) AS artist_count,
       COUNT(w.id)          AS artwork_count
FROM artist a
INNER JOIN artwork w ON w.artist_id = a.id
GROUP BY a.nationality
ORDER BY artwork_count DESC;

-- Q10. 확인: 화가별 평균 별점 랭킹 — 리뷰 3개 이상인 화가만 (AVG + COUNT + GROUP BY + HAVING)
SELECT a.name,
       COUNT(r.id)            AS review_count,
       ROUND(AVG(r.rating), 2) AS avg_rating
FROM artist a
INNER JOIN artwork w ON w.artist_id  = a.id
INNER JOIN review  r ON r.artwork_id = w.id
GROUP BY a.id, a.name
HAVING COUNT(r.id) >= 3
ORDER BY avg_rating DESC, review_count DESC;

-- Q11. 확인: 회원별 리뷰 수와 준 별점 합계 — 활동 많은 회원 순 (COUNT + SUM + GROUP BY)
SELECT m.nickname,
       COUNT(r.id)   AS review_count,
       SUM(r.rating) AS rating_sum
FROM member m
INNER JOIN review r ON r.member_id = m.id
GROUP BY m.id, m.nickname
ORDER BY review_count DESC, rating_sum DESC;

-- ============================================================
-- [서브쿼리]
-- ============================================================

-- Q12. 확인: 리뷰를 한 번도 쓰지 않은 회원 찾기 (NOT IN 서브쿼리)
SELECT id, nickname, email
FROM member
WHERE id NOT IN (SELECT member_id FROM review);

-- ============================================================
-- [수정 / 삭제]
-- ============================================================

-- Q13. 확인: 회원이 리뷰 별점을 고친다 — 7번 리뷰를 2점 → 4점으로 (UPDATE, 수정 전/후 비교)
SELECT id, rating, comment FROM review WHERE id = 7;   -- 수정 전
UPDATE review
SET rating = 4, comment = '다시 보니 좋아요'
WHERE id = 7;
SELECT id, rating, comment FROM review WHERE id = 7;   -- 수정 후

-- Q14. 확인: 14번 리뷰를 삭제한다 (DELETE, 삭제 전/후 개수 비교)
SELECT COUNT(*) AS review_count_before FROM review;
DELETE FROM review
WHERE id = 14;
SELECT COUNT(*) AS review_count_after FROM review;

-- ============================================================
-- [인덱스]
-- ============================================================

-- Q15. 확인: review.artwork_id 에 인덱스를 만들고, 검색 방식이 바뀌는지 본다
-- 적용 이유: "작품별 리뷰" 조회와 artwork-review 조인이 가장 자주 일어나는데, 인덱스가 없으면 리뷰 표 전체를 처음부터 끝까지 훑는다.
EXPLAIN QUERY PLAN SELECT * FROM review WHERE artwork_id = 9;   -- 만들기 전: SCAN (전체 훑기)
CREATE INDEX idx_review_artwork_id ON review (artwork_id);
EXPLAIN QUERY PLAN SELECT * FROM review WHERE artwork_id = 9;   -- 만든 후: SEARCH ... USING INDEX (바로 찾기)
