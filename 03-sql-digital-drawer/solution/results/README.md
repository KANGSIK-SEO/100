# 쿼리 실행 결과

`python run.py` 로 만든 결과입니다. Q01~Q15 = 핵심 쿼리, B01~B09 = 보너스.

## Q01. 확인: 네덜란드 화가만 골라 태어난 순서대로 본다 (WHERE + ORDER BY)

```
Q01. 확인: 네덜란드 화가만 골라 태어난 순서대로 본다 (WHERE + ORDER BY)

sql> SELECT name, birth_year, death_year
     FROM artist
     WHERE nationality = 'Dutch'
     ORDER BY birth_year;
| name               | birth_year | death_year |
|--------------------|------------|------------|
| Rembrandt van Rijn | 1606       | 1669       |
| Johannes Vermeer   | 1632       | 1675       |
| Vincent van Gogh   | 1853       | 1890       |
(3 rows)

```

## Q02. 확인: 1880년 이후에 그려진 작품 중 최신작 5점 (WHERE + ORDER BY DESC + LIMIT)

```
Q02. 확인: 1880년 이후에 그려진 작품 중 최신작 5점 (WHERE + ORDER BY DESC + LIMIT)

sql> SELECT title, year_made, museum
     FROM artwork
     WHERE year_made >= 1880
     ORDER BY year_made DESC
     LIMIT 5;
| title                                  | year_made | museum |
|----------------------------------------|-----------|--------|
| Water Lilies (Agapanthus)              | 1915      | cma    |
| The Gulf Stream                        | 1899      | met    |
| No te aha oe riri (Why Are You Angry?) | 1896      | aic    |
| Ia Orana Maria (Hail Mary)             | 1891      | met    |
| The Card Players                       | 1890      | met    |
(5 rows)

```

## Q03. 확인: 제목에 'Portrait'(초상화)가 들어간 작품 검색 (LIKE 패턴 검색)

```
Q03. 확인: 제목에 'Portrait'(초상화)가 들어간 작품 검색 (LIKE 패턴 검색)

sql> SELECT id, title, year_made
     FROM artwork
     WHERE title LIKE '%Portrait%'
     ORDER BY year_made;
| id | title                                                            | year_made |
|----|------------------------------------------------------------------|-----------|
| 4  | Portrait of a Man, probably a Member of the Van Beresteyn Family | 1632      |
| 2  | Self-Portrait                                                    | 1660      |
| 42 | Self-Portrait with a Straw Hat (obverse: The Potato Peeler)      | 1887      |
(3 rows)

```

## Q04. 확인: 별점 5점 리뷰 중 가장 최근 것 5개 (WHERE + ORDER BY + LIMIT)

```
Q04. 확인: 별점 5점 리뷰 중 가장 최근 것 5개 (WHERE + ORDER BY + LIMIT)

sql> SELECT id, artwork_id, rating, comment, created_at
     FROM review
     WHERE rating = 5
     ORDER BY created_at DESC
     LIMIT 5;
| id | artwork_id | rating | comment                | created_at |
|----|------------|--------|------------------------|------------|
| 38 | 31         | 5      | 직접 보고 싶어요       | 2026-09-22 |
| 37 | 5          | 5      | 직접 보고 싶어요       | 2026-09-21 |
| 26 | 5          | 5      | 인생 작품이에요        | 2026-09-10 |
| 24 | 17         | 5      | 색감이 정말 아름다워요 | 2026-09-08 |
| 23 | 32         | 5      | 인생 작품이에요        | 2026-09-07 |
(5 rows)

```

## Q05. 확인: 작품 제목 옆에 화가 이름을 붙여 본다 (INNER JOIN, artwork.artist_id = artist.id)

```
Q05. 확인: 작품 제목 옆에 화가 이름을 붙여 본다 (INNER JOIN, artwork.artist_id = artist.id)

sql> SELECT a.name AS artist, w.title, w.year_made
     FROM artwork w
     INNER JOIN artist a ON w.artist_id = a.id
     WHERE a.name = 'Vincent van Gogh'
     ORDER BY w.year_made;
| artist           | title                                                       | year_made |
|------------------|-------------------------------------------------------------|-----------|
| Vincent van Gogh | Self-Portrait with a Straw Hat (obverse: The Potato Peeler) | 1887      |
| Vincent van Gogh | Wheat Field with Cypresses                                  | 1889      |
| Vincent van Gogh | The Large Plane Trees (Road Menders at Saint-Rémy)          | 1889      |
| Vincent van Gogh | Irises                                                      | 1890      |
(4 rows)

```

## Q06. 확인: 리뷰 한 줄에 "누가 / 어떤 작품에 / 몇 점" 을 사람이 읽을 수 있게 (INNER JOIN 3개 표)

```
Q06. 확인: 리뷰 한 줄에 "누가 / 어떤 작품에 / 몇 점" 을 사람이 읽을 수 있게 (INNER JOIN 3개 표)

sql> SELECT m.nickname, w.title, a.name AS artist, r.rating, r.created_at
     FROM review r
     INNER JOIN member  m ON r.member_id  = m.id
     INNER JOIN artwork w ON r.artwork_id = w.id
     INNER JOIN artist  a ON w.artist_id  = a.id
     ORDER BY r.created_at DESC
     LIMIT 10;
| nickname | title                                                       | artist                | rating | created_at |
|----------|-------------------------------------------------------------|-----------------------|--------|------------|
| 준호     | Two Sisters (On the Terrace)                                | Pierre-Auguste Renoir | 4      | 2026-09-24 |
| 민지     | Self-Portrait with a Straw Hat (obverse: The Potato Peeler) | Vincent van Gogh      | 4      | 2026-09-23 |
| 예린     | Arrival of the Normandy Train, Gare Saint-Lazare            | Claude Monet          | 5      | 2026-09-22 |
| 수아     | Study of a Young Woman                                      | Johannes Vermeer      | 5      | 2026-09-21 |
| 수아     | Irises                                                      | Vincent van Gogh      | 3      | 2026-09-20 |
| 하은     | The Herring Net                                             | Winslow Homer         | 1      | 2026-09-19 |
| 예린     | Study of a Young Woman                                      | Johannes Vermeer      | 4      | 2026-09-18 |
| 서준     | Study of a Young Woman                                      | Johannes Vermeer      | 2      | 2026-09-17 |
| 수아     | The Card Players                                            | Paul Cezanne          | 1      | 2026-09-16 |
| 현우     | Irises                                                      | Vincent van Gogh      | 3      | 2026-09-15 |
(10 rows)

```

## Q07. 확인: 미술관이 'met'(메트로폴리탄)인 작품에 달린 리뷰만 본다 (INNER JOIN + WHERE)

```
Q07. 확인: 미술관이 'met'(메트로폴리탄)인 작품에 달린 리뷰만 본다 (INNER JOIN + WHERE)

sql> SELECT w.museum, w.title, r.rating, r.comment
     FROM artwork w
     INNER JOIN review r ON r.artwork_id = w.id
     WHERE w.museum = 'met'
     ORDER BY r.rating DESC, w.title;
| museum | title                                                            | rating | comment                |
|--------|------------------------------------------------------------------|--------|------------------------|
| met    | A Woman Seated beside a Vase of Flowers (Madame Paul Valpinçon?) | 5      | 색감이 정말 아름다워요 |
| met    | Ia Orana Maria (Hail Mary)                                       | 5      | 직접 보고 싶어요       |
| met    | Madame Cézanne (Hortense Fiquet, 1850–1922) in a Red Dress       | 5      | 인생 작품이에요        |
| met    | Mademoiselle V. . . in the Costume of an Espada                  | 5      | 직접 보고 싶어요       |
| met    | Study of a Young Woman                                           | 5      | 인생 작품이에요        |
| met    | Study of a Young Woman                                           | 5      | 직접 보고 싶어요       |
| met    | Wheat Field with Cypresses                                       | 5      | 직접 보고 싶어요       |
| met    | A Maid Asleep                                                    | 4      | 분위기가 좋아요        |
| met    | Portrait of a Man, probably a Member of the Van Beresteyn Family | 4      | 분위기가 좋아요        |
| met    | Self-Portrait with a Straw Hat (obverse: The Potato Peeler)      | 4      | 분위기가 좋아요        |
| met    | Study of a Young Woman                                           | 4      | 오래 보게 되네요       |
| met    | The Spanish Singer                                               | 4      | 분위기가 좋아요        |
| met    | Woman with a Parrot                                              | 4      | 오래 보게 되네요       |
| met    | Irises                                                           | 3      | 무난해요               |
| met    | Irises                                                           | 3      | 설명을 더 알고 싶어요  |
| met    | Self-Portrait                                                    | 3      | 무난해요               |
| met    | Self-Portrait with a Straw Hat (obverse: The Potato Peeler)      | 3      | 설명을 더 알고 싶어요  |
| met    | Study of a Young Woman                                           | 3      | 설명을 더 알고 싶어요  |
| met    | The Dance Class                                                  | 3      | 무난해요               |
| met    | The Old Italian Woman                                            | 3      | 무난해요               |
| met    | The Veteran in a New Field                                       | 3      | 설명을 더 알고 싶어요  |
| met    | Young Ladies of the Village                                      | 3      | 설명을 더 알고 싶어요  |
| met    | A Maid Asleep                                                    | 2      | 제 취향은 아니에요     |
| met    | A Woman Seated beside a Vase of Flowers (Madame Paul Valpinçon?) | 2      | 제 취향은 아니에요     |
| met    | Study of a Young Woman                                           | 2      | 제 취향은 아니에요     |
| met    | Study of a Young Woman                                           | 2      | 제 취향은 아니에요     |
| met    | Woman with a Parrot                                              | 2      | 제 취향은 아니에요     |
| met    | Irises                                                           | 1      | 잘 모르겠어요          |
| met    | The Card Players                                                 | 1      | 잘 모르겠어요          |
| met    | The Collector of Prints                                          | 1      | 잘 모르겠어요          |
(30 rows)

```

## Q08. 확인: 리뷰가 하나도 없는 작품 찾기 (LEFT JOIN: 짝이 없으면 오른쪽이 NULL)

```
Q08. 확인: 리뷰가 하나도 없는 작품 찾기 (LEFT JOIN: 짝이 없으면 오른쪽이 NULL)

sql> SELECT w.id, w.title, r.id AS review_id
     FROM artwork w
     LEFT JOIN review r ON r.artwork_id = w.id
     WHERE r.id IS NULL
     ORDER BY w.id;
| id | title                                                                       | review_id |
|----|-----------------------------------------------------------------------------|-----------|
| 1  | Aristotle with a Bust of Homer                                              | NULL      |
| 3  | Man in a Turban                                                             | NULL      |
| 6  | Young Woman with a Water Pitcher                                            | NULL      |
| 7  | Allegory of the Catholic Faith                                              | NULL      |
| 11 | Panoramic View of the Alps, Les Dents du Midi                               | NULL      |
| 12 | Mère Grégoire                                                               | NULL      |
| 14 | Boating                                                                     | NULL      |
| 15 | Young Lady in 1866                                                          | NULL      |
| 21 | The Gulf Stream                                                             | NULL      |
| 24 | Croquet Scene                                                               | NULL      |
| 27 | Still Life with Apples and a Pot of Primroses                               | NULL      |
| 28 | Antoine Dominique Sauveur Aubert (born 1817), the Artist's Uncle, as a Monk | NULL      |
| 33 | Romaine Lacaux                                                              | NULL      |
| 35 | Acrobats at the Cirque Fernando (Francisca and Angelina Wartenberg)         | NULL      |
| 38 | Arlésiennes (Mistral)                                                       | NULL      |
| 40 | Woman in Front of a Still Life by Cezanne                                   | NULL      |
| 44 | The Large Plane Trees (Road Menders at Saint-Rémy)                          | NULL      |
| 45 | Circus Sideshow (Parade de cirque)                                          | NULL      |
| 46 | Study for "A Sunday on La Grande Jatte"                                     | NULL      |
| 47 | Oil Sketch for "A Sunday on La Grande Jatte — 1884"                         | NULL      |
| 48 | The Forest at Pontaubert                                                    | NULL      |
(21 rows)

```

## Q09. 확인: 국적별 화가 수와 작품 수 (COUNT + GROUP BY)

```
Q09. 확인: 국적별 화가 수와 작품 수 (COUNT + GROUP BY)

sql> SELECT a.nationality,
            COUNT(DISTINCT a.id) AS artist_count,
            COUNT(w.id)          AS artwork_count
     FROM artist a
     INNER JOIN artwork w ON w.artist_id = a.id
     GROUP BY a.nationality
     ORDER BY artwork_count DESC;
| nationality | artist_count | artwork_count |
|-------------|--------------|---------------|
| French      | 8            | 32            |
| Dutch       | 3            | 12            |
| American    | 1            | 4             |
(3 rows)

```

## Q10. 확인: 화가별 평균 별점 랭킹 — 리뷰 3개 이상인 화가만 (AVG + COUNT + GROUP BY + HAVING)

```
Q10. 확인: 화가별 평균 별점 랭킹 — 리뷰 3개 이상인 화가만 (AVG + COUNT + GROUP BY + HAVING)

sql> SELECT a.name,
            COUNT(r.id)            AS review_count,
            ROUND(AVG(r.rating), 2) AS avg_rating
     FROM artist a
     INNER JOIN artwork w ON w.artist_id  = a.id
     INNER JOIN review  r ON r.artwork_id = w.id
     GROUP BY a.id, a.name
     HAVING COUNT(r.id) >= 3
     ORDER BY avg_rating DESC, review_count DESC;
| name             | review_count | avg_rating |
|------------------|--------------|------------|
| Claude Monet     | 5            | 4.2        |
| Johannes Vermeer | 8            | 3.38       |
| Vincent van Gogh | 6            | 3.17       |
| Winslow Homer    | 3            | 3.0        |
| Gustave Courbet  | 3            | 3.0        |
| Edgar Degas      | 5            | 2.8        |
(6 rows)

```

## Q11. 확인: 회원별 리뷰 수와 준 별점 합계 — 활동 많은 회원 순 (COUNT + SUM + GROUP BY)

```
Q11. 확인: 회원별 리뷰 수와 준 별점 합계 — 활동 많은 회원 순 (COUNT + SUM + GROUP BY)

sql> SELECT m.nickname,
            COUNT(r.id)   AS review_count,
            SUM(r.rating) AS rating_sum
     FROM member m
     INNER JOIN review r ON r.member_id = m.id
     GROUP BY m.id, m.nickname
     ORDER BY review_count DESC, rating_sum DESC;
| nickname | review_count | rating_sum |
|----------|--------------|------------|
| 준호     | 6            | 23         |
| 수아     | 6            | 21         |
| 도윤     | 5            | 20         |
| 예린     | 5            | 20         |
| 민지     | 4            | 11         |
| 지우     | 3            | 11         |
| 서준     | 3            | 9          |
| 채원     | 3            | 8          |
| 현우     | 2            | 8          |
| 하은     | 2            | 4          |
| 태양     | 1            | 1          |
(11 rows)

```

## Q12. 확인: 리뷰를 한 번도 쓰지 않은 회원 찾기 (NOT IN 서브쿼리)

```
Q12. 확인: 리뷰를 한 번도 쓰지 않은 회원 찾기 (NOT IN 서브쿼리)

sql> SELECT id, nickname, email
     FROM member
     WHERE id NOT IN (SELECT member_id FROM review);
| id | nickname | email            |
|----|----------|------------------|
| 12 | 나리     | nari@example.com |
(1 rows)

```

## Q13. 확인: 회원이 리뷰 별점을 고친다 — 7번 리뷰를 2점 → 4점으로 (UPDATE, 수정 전/후 비교)

```
Q13. 확인: 회원이 리뷰 별점을 고친다 — 7번 리뷰를 2점 → 4점으로 (UPDATE, 수정 전/후 비교)

sql> SELECT id, rating, comment FROM review WHERE id = 7;   -- 수정 전
| id | rating | comment            |
|----|--------|--------------------|
| 7  | 2      | 제 취향은 아니에요 |
(1 rows)

sql> UPDATE review
     SET rating = 4, comment = '다시 보니 좋아요'
     WHERE id = 7;
(OK, 1 row(s) affected)

sql> SELECT id, rating, comment FROM review WHERE id = 7;   -- 수정 후
| id | rating | comment          |
|----|--------|------------------|
| 7  | 4      | 다시 보니 좋아요 |
(1 rows)

```

## Q14. 확인: 14번 리뷰를 삭제한다 (DELETE, 삭제 전/후 개수 비교)

```
Q14. 확인: 14번 리뷰를 삭제한다 (DELETE, 삭제 전/후 개수 비교)

sql> SELECT COUNT(*) AS review_count_before FROM review;
| review_count_before |
|---------------------|
| 40                  |
(1 rows)

sql> DELETE FROM review
     WHERE id = 14;
(OK, 1 row(s) affected)

sql> SELECT COUNT(*) AS review_count_after FROM review;
| review_count_after |
|--------------------|
| 39                 |
(1 rows)

```

## Q15. 확인: review.artwork_id 에 인덱스를 만들고, 검색 방식이 바뀌는지 본다

```
Q15. 확인: review.artwork_id 에 인덱스를 만들고, 검색 방식이 바뀌는지 본다

sql> EXPLAIN QUERY PLAN SELECT * FROM review WHERE artwork_id = 9;   -- 만들기 전: SCAN (전체 훑기)
| id | parent | notused | detail      |
|----|--------|---------|-------------|
| 2  | 0      | 0       | SCAN review |
(1 rows)

sql> CREATE INDEX idx_review_artwork_id ON review (artwork_id);
(OK)

sql> EXPLAIN QUERY PLAN SELECT * FROM review WHERE artwork_id = 9;   -- 만든 후: SEARCH ... USING INDEX (바로 찾기)
| id | parent | notused | detail                                                         |
|----|--------|---------|----------------------------------------------------------------|
| 3  | 0      | 0       | SEARCH review USING INDEX idx_review_artwork_id (artwork_id=?) |
(1 rows)

```

## B01. 확인: JOIN 방식 — 두 표를 옆으로 붙인 뒤 조건으로 거른다. 작품 제목도 같이 볼 수 있다.

```
B01. 확인: JOIN 방식 — 두 표를 옆으로 붙인 뒤 조건으로 거른다. 작품 제목도 같이 볼 수 있다.

sql> SELECT r.id, w.title, r.rating
     FROM review r
     INNER JOIN artwork w ON r.artwork_id = w.id
     INNER JOIN artist  a ON w.artist_id  = a.id
     WHERE a.name = 'Claude Monet'
     ORDER BY r.id;
| id | title                                            | rating |
|----|--------------------------------------------------|--------|
| 3  | The Red Kerchief                                 | 3      |
| 11 | Water Lilies (Agapanthus)                        | 4      |
| 23 | The Beach at Sainte-Adresse                      | 5      |
| 25 | The Red Kerchief                                 | 4      |
| 38 | Arrival of the Normandy Train, Gare Saint-Lazare | 5      |
(5 rows)

```

## B02. 확인: 서브쿼리 방식 — 안쪽 쿼리로 "모네 작품 번호 목록"을 먼저 구하고, 바깥에서 그 번호의 리뷰만 고른다.

```
B02. 확인: 서브쿼리 방식 — 안쪽 쿼리로 "모네 작품 번호 목록"을 먼저 구하고, 바깥에서 그 번호의 리뷰만 고른다.

sql> SELECT r.id, r.artwork_id, r.rating
     FROM review r
     WHERE r.artwork_id IN (
         SELECT id FROM artwork
         WHERE artist_id = (SELECT id FROM artist WHERE name = 'Claude Monet')
     )
     ORDER BY r.id;
| id | artwork_id | rating |
|----|------------|--------|
| 3  | 29         | 3      |
| 11 | 30         | 4      |
| 23 | 32         | 5      |
| 25 | 29         | 4      |
| 38 | 31         | 5      |
(5 rows)

```

## B03. 확인: 없는 화가(999번)의 작품을 넣으면 FK가 막는다 → FOREIGN KEY constraint failed

```
B03. 확인: 없는 화가(999번)의 작품을 넣으면 FK가 막는다 → FOREIGN KEY constraint failed

sql> INSERT INTO artwork (id, artist_id, title, year_made, medium, museum, image_url)
     VALUES (100, 999, 'Fake Painting', 2026, 'Oil on canvas', 'met', 'https://example.com/fake.jpg');
ERROR: FOREIGN KEY constraint failed

```

## B04. 확인: 리뷰가 달린 작품(9번)을 지우면 리뷰가 "주인 없는 리뷰"가 되므로 FK가 막는다

```
B04. 확인: 리뷰가 달린 작품(9번)을 지우면 리뷰가 "주인 없는 리뷰"가 되므로 FK가 막는다

sql> DELETE FROM artwork WHERE id = 9;
ERROR: FOREIGN KEY constraint failed

```

## B05. 확인: 이미 있는 이메일로 가입하면 UNIQUE 가 막는다

```
B05. 확인: 이미 있는 이메일로 가입하면 UNIQUE 가 막는다

sql> INSERT INTO member (id, email, nickname, joined_at)
     VALUES (100, 'minji@example.com', '가짜민지', '2026-10-08');
ERROR: UNIQUE constraint failed: member.email

```

## B06. 확인: 별점 7점은 CHECK (1~5) 가 막는다

```
B06. 확인: 별점 7점은 CHECK (1~5) 가 막는다

sql> INSERT INTO review (id, member_id, artwork_id, rating, comment, created_at)
     VALUES (100, 12, 1, 7, '최고!', '2026-10-08');
ERROR: CHECK constraint failed: rating BETWEEN 1 AND 5

```

## B07. 지표 1 — 월별 리뷰 수 추이: 서비스가 점점 활발해지는지 본다

```
B07. 지표 1 — 월별 리뷰 수 추이: 서비스가 점점 활발해지는지 본다

sql> SELECT substr(created_at, 1, 7) AS month,  -- SQLite: 'YYYY-MM-DD' 에서 앞 7글자 = 'YYYY-MM'
            COUNT(*)                 AS review_count
     FROM review
     GROUP BY month
     ORDER BY month;
| month   | review_count |
|---------|--------------|
| 2026-08 | 15           |
| 2026-09 | 24           |
(2 rows)

```

## B08. 지표 2 — 인기 작품 TOP 5: 리뷰가 많은 순, 같으면 평균 별점이 높은 순

```
B08. 지표 2 — 인기 작품 TOP 5: 리뷰가 많은 순, 같으면 평균 별점이 높은 순

sql> SELECT w.title, a.name AS artist,
            COUNT(r.id)             AS review_count,
            ROUND(AVG(r.rating), 2) AS avg_rating
     FROM artwork w
     INNER JOIN artist a ON w.artist_id  = a.id
     INNER JOIN review r ON r.artwork_id = w.id
     GROUP BY w.id, w.title, a.name
     ORDER BY review_count DESC, avg_rating DESC
     LIMIT 5;
| title                                                            | artist           | review_count | avg_rating |
|------------------------------------------------------------------|------------------|--------------|------------|
| Study of a Young Woman                                           | Johannes Vermeer | 6            | 3.5        |
| Irises                                                           | Vincent van Gogh | 3            | 2.33       |
| A Woman Seated beside a Vase of Flowers (Madame Paul Valpinçon?) | Edgar Degas      | 2            | 4.5        |
| The Red Kerchief                                                 | Claude Monet     | 2            | 3.5        |
| Self-Portrait with a Straw Hat (obverse: The Potato Peeler)      | Vincent van Gogh | 2            | 3.5        |
(5 rows)

```

## B09. 지표 3 — 미술관별 리뷰 만족도: 어느 미술관 소장품이 반응이 좋은지 본다

```
B09. 지표 3 — 미술관별 리뷰 만족도: 어느 미술관 소장품이 반응이 좋은지 본다

sql> SELECT w.museum,
            COUNT(DISTINCT w.id)    AS reviewed_artworks,
            COUNT(r.id)             AS review_count,
            ROUND(AVG(r.rating), 2) AS avg_rating
     FROM artwork w
     INNER JOIN review r ON r.artwork_id = w.id
     GROUP BY w.museum
     ORDER BY avg_rating DESC;
| museum | reviewed_artworks | review_count | avg_rating |
|--------|-------------------|--------------|------------|
| aic    | 6                 | 7            | 3.71       |
| cma    | 2                 | 3            | 3.67       |
| met    | 19                | 29           | 3.41       |
(3 rows)

```
