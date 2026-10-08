-- 스키마 생성 스크립트 — 주제: 명화 감상 리뷰 서랍장 (SQLite)
-- 실행 순서대로 정리: 부모 표(artist, member) → 자식 표(artwork, review)
--
-- 관계(1:N)
--   artist 1 ── N artwork   (화가 한 명이 작품 여러 점을 그린다)     artwork.artist_id → artist.id
--   member 1 ── N review    (회원 한 명이 리뷰를 여러 개 쓴다)        review.member_id  → member.id
--   artwork 1 ── N review   (작품 하나에 리뷰가 여러 개 달린다)       review.artwork_id → artwork.id

PRAGMA foreign_keys = ON;  -- SQLite 전용: FK 검사는 기본으로 꺼져 있어서 연결할 때마다 켜야 한다

DROP TABLE IF EXISTS review;   -- 다시 실행해도 되도록 지우고 만든다 (자식부터 지운다)
DROP TABLE IF EXISTS artwork;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS artist;

-- 화가
CREATE TABLE artist (
    id           INTEGER PRIMARY KEY,           -- PK: 화가 번호
    name         VARCHAR(100) NOT NULL UNIQUE,  -- 같은 화가가 두 번 들어가지 않게 UNIQUE
    nationality  VARCHAR(50)  NOT NULL,         -- 국적 (Dutch, French, American)
    birth_year   INTEGER,
    death_year   INTEGER
);

-- 작품 (화가 1 : 작품 N)
CREATE TABLE artwork (
    id         INTEGER PRIMARY KEY,
    artist_id  INTEGER      NOT NULL REFERENCES artist (id),  -- FK: 그린 화가
    title      VARCHAR(300) NOT NULL,
    year_made  INTEGER,                         -- 제작 연도
    medium     VARCHAR(100),                    -- 재료 (Oil on canvas 등)
    museum     VARCHAR(10)  NOT NULL CHECK (museum IN ('met', 'aic', 'cma')),  -- 소장 미술관
    image_url  VARCHAR(500) NOT NULL
);

-- 회원
CREATE TABLE member (
    id         INTEGER PRIMARY KEY,
    email      VARCHAR(100) NOT NULL UNIQUE,    -- 같은 이메일로 두 번 가입 불가
    nickname   VARCHAR(30)  NOT NULL,
    joined_at  DATE         NOT NULL            -- 가입일 (YYYY-MM-DD)
);

-- 리뷰 (회원 1 : 리뷰 N, 작품 1 : 리뷰 N)
CREATE TABLE review (
    id          INTEGER PRIMARY KEY,
    member_id   INTEGER NOT NULL REFERENCES member (id),   -- FK: 쓴 회원
    artwork_id  INTEGER NOT NULL REFERENCES artwork (id),  -- FK: 대상 작품
    rating      INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),  -- 별점 1~5
    comment     VARCHAR(500),
    created_at  DATE    NOT NULL,
    UNIQUE (member_id, artwork_id)              -- 한 회원은 한 작품에 리뷰 1개만
);
