"""schema.sql + data.sql 로 DB를 만들고 queries.sql(15개), bonus.sql 을 실행해 results/ 에 결과를 저장한다.

사용법: python run.py   (파이썬 표준 라이브러리만 사용)
"""
import re
import sqlite3
import unicodedata
from pathlib import Path

HERE = Path(__file__).parent
DB = HERE / "art_review.db"
RESULTS = HERE / "results"


def width(s: str) -> int:
    """한글처럼 넓은 글자는 2칸으로 센다 (표 줄맞춤용)."""
    return sum(2 if unicodedata.east_asian_width(ch) in "WF" else 1 for ch in s)


def table(cols: list[str], rows: list[tuple]) -> str:
    """조회 결과를 글자 표로 만든다."""
    cells = [["NULL" if v is None else str(v) for v in row] for row in rows]
    w = [max([width(c)] + [width(r[i]) for r in cells]) for i, c in enumerate(cols)]
    line = lambda vals: "| " + " | ".join(v + " " * (w[i] - width(v)) for i, v in enumerate(vals)) + " |"
    sep = "|-" + "-|-".join("-" * x for x in w) + "-|"
    return "\n".join([line(cols), sep] + [line(r) for r in cells] + [f"({len(rows)} rows)"])


def statements(sql: str):
    """SQL 덩어리를 문장(;) 단위로 나누고, 주석 줄은 뺀다."""
    buf = ""
    for ln in sql.splitlines(keepends=True):
        if ln.lstrip().startswith("--"):
            continue
        buf += ln
        if sqlite3.complete_statement(buf):
            yield buf.strip()
            buf = ""


def run_file(con: sqlite3.Connection, sql_file: str, marker: str) -> list[str]:
    """파일 안의 '-- Q01.' 같은 묶음마다 실행하고 결과를 results/<번호>.txt 로 저장한다."""
    text = (HERE / sql_file).read_text(encoding="utf-8")
    md = []
    for block in re.split(rf"(?m)^(?=-- {marker}\d\d\.)", text)[1:]:
        title = block.splitlines()[0][3:]
        out = [title, ""]
        for code in statements(block):
            out.append("sql> " + code.replace("\n", "\n     "))
            try:
                cur = con.execute(code)
                if cur.description:
                    out.append(table([d[0] for d in cur.description], cur.fetchall()))
                else:
                    out.append(f"(OK, {cur.rowcount} row(s) affected)" if cur.rowcount >= 0 else "(OK)")
            except sqlite3.Error as e:  # 보너스 2: 일부러 낸 에러를 그대로 기록
                out.append(f"ERROR: {e}")
            out.append("")
        con.commit()
        (RESULTS / f"{title.split('.')[0]}.txt").write_text("\n".join(out), encoding="utf-8")
        md += [f"## {title}\n", "```", *out, "```\n"]
        print("\n".join(out))
    return md


def main() -> None:
    DB.unlink(missing_ok=True)
    con = sqlite3.connect(DB)
    con.executescript((HERE / "schema.sql").read_text(encoding="utf-8"))
    con.executescript((HERE / "data.sql").read_text(encoding="utf-8"))
    con.execute("PRAGMA foreign_keys = ON")

    RESULTS.mkdir(exist_ok=True)
    md = ["# 쿼리 실행 결과\n", "`python run.py` 로 만든 결과입니다. Q01~Q15 = 핵심 쿼리, B01~B09 = 보너스.\n"]
    md += run_file(con, "queries.sql", "Q")
    md += run_file(con, "bonus.sql", "B")
    (RESULTS / "README.md").write_text("\n".join(md), encoding="utf-8")
    con.close()


if __name__ == "__main__":
    main()
