# TRACEABILITY — ss_esim_landing_to_discovery

Generated: 2026-11-03 12:20:22 · `python scripts/checks/verify_all.py --level V8`

✅ ครบ · ⬜ ยังไม่มี · 📝 spec ยังไม่เติม · n/a ไม่เกี่ยว

| Task | Kind | Converted | Review log | DML | XML | Spec | Test (assert) |
|---|---|---|---|---|---|---|---|
| 010000_check_success_ss_esim_landing_to_discovery_workflow_status | sql | ✅ | n/a | ✅ | ✅ | 📝 | ✅ |
| 020000_overwrite_ss_esim_checkpoint_temp | sql | ✅ | ✅ | ✅ | ✅ | 📝 | ✅ |
| 030000_running_ss_esim_landing_to_discovery_workflow_status | sql | ✅ | ✅ | ✅ | ✅ | 📝 | ⬜ |
| 040000_overwrite_ss_esim_raw_temp | sql | ✅ | ✅ | ✅ | ✅ | 📝 | ✅ |
| 050100_append_ss_esim_valid | sql | ✅ | n/a | ✅ | ✅ | 📝 | ✅ |
| 050200_append_ss_esim_reject | sql | ✅ | n/a | ✅ | ✅ | 📝 | ✅ |
| 050300_append_ss_esim_temp | sql | ✅ | n/a | ✅ | ✅ | 📝 | ✅ |
| 090000_success_ss_esim_landing_to_discovery_workflow_status | sql | ✅ | ✅ | ✅ | ✅ | 📝 | ✅ |
| 070000_overwrite_ss_esim_checkpoint | sql | ✅ | n/a | ✅ | ✅ | 📝 | ✅ |
| 080000_cleanup_ss_esim_raw_temp | non-sql | n/a | n/a | ✅ | ✅ | 📝 | ✅ |
| 000000_recover_landing_ss_esim | variable | n/a | n/a | n/a | ✅ | n/a | n/a |
| 999999_export_data_to_mssql | sql | ✅ | n/a | ✅ | ✅ | 📝 | ⬜ |
