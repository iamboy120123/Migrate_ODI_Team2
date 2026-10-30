# S4 — ODI checklist (ติ๊ก [x] เมื่อทำแล้ว, ใส่หมายเหตุหลัง —)

- [ ] Topology: logical schema `DSS_ODI_LOG` ใน context `DEV` ผูกกับ physical schema `DSSDEV` (ไม่ใช่ schema log/work ของ ODI)
- [ ] Data server ใช้ user `DSSDEV` —
- [ ] Package `PKG_SS_ESIM_L2D`: `v_max_partition` → `v_lag_minutes` → 010000 → 020000 → 030000 → 040000 → 050100 → 050200 → 050300 → 070000 → 080000 → 090000 → 999999 (13 step)
- [ ] Retry ทุก step ตามที่ SA กำหนด (Blendata เดิม: retry=false) —
- [ ] Generate scenario ของ `PKG_SS_ESIM_L2D` แล้ว — ชื่อ/เวอร์ชัน scenario:
- [ ] Schedule `30 * * * *` (เท่ากับ Blendata) — **ยังไม่ต้องเปิดใช้** จนกว่า Dev run ผ่าน
- [ ] ไม่มี project ซ้ำ (`Copy of ...`) จากการ import ผิดโหมด
