-- S3a smoke test (Blendata): ยืนยันว่ารองรับ stack() แบบ 2 ชั้นที่ profile ใช้ (ผลต้องได้ 2 แถว)
SELECT 'smoke' AS tbl, col, max_len, null_cnt, row_cnt FROM (
  SELECT row_cnt, stack(2, 'a', ml_0, nc_0, 'b', ml_1, nc_1) AS (col, max_len, null_cnt)
  FROM (SELECT 1 AS row_cnt, 3 AS ml_0, CAST(0 AS BIGINT) AS nc_0, 5 AS ml_1, CAST(1 AS BIGINT) AS nc_1) a
) t
