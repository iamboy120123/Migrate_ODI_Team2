-- 01_create_tables.sql  (DRAFT generated 2026-10-29T20:57:32)
-- ⚠️ DRAFT: คอลัมน์ที่ทำเครื่องหมาย TODO ต้องกำหนดชนิด/ความยาวจริงเอง
--    ดู README.md และรัน 03_profile_source_lengths.sql ฝั่ง Blendata ก่อนสรุป

-- K16: TB_STAGING_SS_ESIM_CHECKPOINT มีอยู่แล้วใน Oracle (all_tab_columns) — DDL นี้ใช้อ้างอิง/สร้างใน env ใหม่ (Prod) ห้ามรันทับใน Dev
CREATE TABLE DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT (
    PARTITION_DATE               NUMBER(19)      ,
    CHECKPOINT_PARTITION         NUMBER(19)      ,
    PROCESS_DATE                 TIMESTAMP(6)    
);
-- Blendata partition by: PARTITION_DATE
--   ถ้าจะทำ partition ฝั่ง Oracle ด้วย แนะนำ RANGE/INTERVAL บน PARTITION_DATE
--   และจะทำให้ 080000 retention ใช้ DROP PARTITION แทน DELETE ได้

-- K16: TB_STAGING_SS_ESIM_CHECKPOINT_TEMP มีอยู่แล้วใน Oracle (all_tab_columns) — DDL นี้ใช้อ้างอิง/สร้างใน env ใหม่ (Prod) ห้ามรันทับใน Dev
CREATE TABLE DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP (
    PARTITION_DATE               NUMBER(19)      ,
    CHECKPOINT_PARTITION         NUMBER(19)      ,
    PROCESS_DATE                 TIMESTAMP(6)    
);
-- Blendata partition by: PARTITION_DATE
--   ถ้าจะทำ partition ฝั่ง Oracle ด้วย แนะนำ RANGE/INTERVAL บน PARTITION_DATE
--   และจะทำให้ 080000 retention ใช้ DROP PARTITION แทน DELETE ได้

-- K16: TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS มีอยู่แล้วใน Oracle (all_tab_columns) — DDL นี้ใช้อ้างอิง/สร้างใน env ใหม่ (Prod) ห้ามรันทับใน Dev
CREATE TABLE DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS (
    RUNNING                      VARCHAR2(5)     ,
    WORKFLOW_PROCESS_DATE        VARCHAR2(14)    ,
    SUCCESS                      VARCHAR2(5)     
);

-- K16: TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP มีอยู่แล้วใน Oracle (all_tab_columns) — DDL นี้ใช้อ้างอิง/สร้างใน env ใหม่ (Prod) ห้ามรันทับใน Dev
CREATE TABLE DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP (
    SUCCESS                      VARCHAR2(20)    
);

-- K16: TB_STAGING_SS_ESIM_RAW_TEMP มีอยู่แล้วใน Oracle (all_tab_columns) — DDL นี้ใช้อ้างอิง/สร้างใน env ใหม่ (Prod) ห้ามรันทับใน Dev
CREATE TABLE DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP (
    PARTITION_DATE               NUMBER(19)      ,
    CDR_ID                       VARCHAR2(50)    ,
    CDR_TYPE                     VARCHAR2(50)    ,
    PARTNER                      VARCHAR2(50)    ,
    OWNER                        VARCHAR2(50)    ,
    ICCID                        VARCHAR2(50)    ,
    FIRST_INSTALLED              TIMESTAMP(6)    ,
    PROFILE_TYPE                 VARCHAR2(20)    ,
    EID                          VARCHAR2(50)    ,
    SIM_TYPE                     VARCHAR2(20)    ,
    CP_ID                        VARCHAR2(20)    ,
    SERVICE_ID                   NUMBER(10)      ,
    PRICE_RATE_TYPE              VARCHAR2(20)    ,
    NETWORK_TYPE                 VARCHAR2(20)    ,
    INVOICING_CO_ID              VARCHAR2(20)    ,
    SHARE_BASIS                  VARCHAR2(20)    ,
    CDR_FILENAME                 VARCHAR2(255)   ,
    CHK_DUPLICATE                VARCHAR2(255)   ,
    SOURCE_PATH                  VARCHAR2(500)   ,
    FILTER_ERROR                 VARCHAR2(100)   ,
    FILTER_ERROR_MSG             VARCHAR2(2000)  ,
    TYPE_ERROR                   VARCHAR2(100)   ,
    TYPE_ERROR_MSG               VARCHAR2(2000)  ,
    MAPPING_ERROR                VARCHAR2(100)   ,
    MAPPING_ERROR_MSG            VARCHAR2(2000)  ,
    STATUS                       VARCHAR2(50)    ,
    FILTER_DTM                   TIMESTAMP(6)    ,
    B_NO                         VARCHAR2(50)    ,
    CREATE_BY                    VARCHAR2(50)    ,
    PROCESS_DATE                 TIMESTAMP(6)    ,
    WORKFLOW_PROCESS_DATE        VARCHAR2(14)    ,
    FILE_DATE                    TIMESTAMP(6)    
);
-- Blendata partition by: PARTITION_DATE
--   ถ้าจะทำ partition ฝั่ง Oracle ด้วย แนะนำ RANGE/INTERVAL บน PARTITION_DATE
--   และจะทำให้ 080000 retention ใช้ DROP PARTITION แทน DELETE ได้

-- K16: TB_TRANSACTION_SS_ESIM_REJECT มีอยู่แล้วใน Oracle (all_tab_columns) — DDL นี้ใช้อ้างอิง/สร้างใน env ใหม่ (Prod) ห้ามรันทับใน Dev
CREATE TABLE DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT (
    PARTITION_DATE               NUMBER(19)      ,
    CDR_ID                       VARCHAR2(50)    ,
    CDR_TYPE                     VARCHAR2(50)    ,
    PARTNER                      VARCHAR2(50)    ,
    OWNER                        VARCHAR2(50)    ,
    ICCID                        VARCHAR2(50)    ,
    FIRST_INSTALLED              TIMESTAMP(6)    ,
    PROFILE_TYPE                 VARCHAR2(20)    ,
    EID                          VARCHAR2(50)    ,
    SIM_TYPE                     VARCHAR2(20)    ,
    CDR_FILENAME                 VARCHAR2(255)   ,
    CHK_DUPLICATE                VARCHAR2(255)   ,
    CDR_SOURCE_PATH              VARCHAR2(500)   ,
    FILTER_DTM                   TIMESTAMP(6)    ,
    CREATE_BY                    VARCHAR2(50)    ,
    PROCESS_DATE                 TIMESTAMP(6)    ,
    STATUS                       VARCHAR2(50)    ,
    FILTER_ERROR                 VARCHAR2(1000)  ,
    ERR_MSG                      VARCHAR2(2000)  ,
    WORKFLOW_PROCESS_DATE        VARCHAR2(14)    
);
-- Blendata partition by: PARTITION_DATE, STATUS, WORKFLOW_PROCESS_DATE
--   ถ้าจะทำ partition ฝั่ง Oracle ด้วย แนะนำ RANGE/INTERVAL บน PARTITION_DATE
--   และจะทำให้ 080000 retention ใช้ DROP PARTITION แทน DELETE ได้

-- K16: TB_TRANSACTION_SS_ESIM_TEMP มีอยู่แล้วใน Oracle (all_tab_columns) — DDL นี้ใช้อ้างอิง/สร้างใน env ใหม่ (Prod) ห้ามรันทับใน Dev
CREATE TABLE DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP (
    PARTITION_DATE               NUMBER(19)      ,
    CDR_ID                       VARCHAR2(50)    ,
    CDR_TYPE                     VARCHAR2(50)    ,
    PARTNER                      VARCHAR2(50)    ,
    OWNER                        VARCHAR2(50)    ,
    ICCID                        VARCHAR2(50)    ,
    FIRST_INSTALLED              TIMESTAMP(6)    ,
    PROFILE_TYPE                 VARCHAR2(20)    ,
    EID                          VARCHAR2(50)    ,
    SIM_TYPE                     VARCHAR2(20)    ,
    CDR_FILENAME                 VARCHAR2(255)   ,
    CHK_DUPLICATE                VARCHAR2(255)   ,
    CDR_SOURCE_PATH              VARCHAR2(500)   ,
    FILTER_DTM                   TIMESTAMP(6)    ,
    CREATE_BY                    VARCHAR2(50)    ,
    PROCESS_DATE                 TIMESTAMP(6)    ,
    STATUS                       VARCHAR2(50)    ,
    B_NO                         VARCHAR2(50)    ,
    MAPPING_ERROR                VARCHAR2(1000)  ,
    ERR_MSG                      VARCHAR2(2000)  ,
    WORKFLOW_PROCESS_DATE        VARCHAR2(14)    ,
    FILE_DATE                    TIMESTAMP(6)    
);
-- Blendata partition by: PARTITION_DATE, STATUS, B_NO, WORKFLOW_PROCESS_DATE
--   ถ้าจะทำ partition ฝั่ง Oracle ด้วย แนะนำ RANGE/INTERVAL บน PARTITION_DATE
--   และจะทำให้ 080000 retention ใช้ DROP PARTITION แทน DELETE ได้

-- K16: TB_TRANSACTION_SS_ESIM_VALID มีอยู่แล้วใน Oracle (all_tab_columns) — DDL นี้ใช้อ้างอิง/สร้างใน env ใหม่ (Prod) ห้ามรันทับใน Dev
CREATE TABLE DSSDEV.TB_TRANSACTION_SS_ESIM_VALID (
    PARTITION_DATE               NUMBER(19)      ,
    CDR_ID                       VARCHAR2(50)    ,
    CDR_TYPE                     VARCHAR2(50)    ,
    PARTNER                      VARCHAR2(50)    ,
    OWNER                        VARCHAR2(50)    ,
    ICCID                        VARCHAR2(50)    ,
    FIRST_INSTALLED              TIMESTAMP(6)    ,
    PROFILE_TYPE                 VARCHAR2(20)    ,
    EID                          VARCHAR2(50)    ,
    SIM_TYPE                     VARCHAR2(20)    ,
    CP_ID                        VARCHAR2(20)    ,
    SERVICE_ID                   NUMBER(10)      ,
    BEFORE_SHARING               NUMBER(18,6)    ,
    PRICE_RATE_TYPE              VARCHAR2(20)    ,
    NETWORK_TYPE                 VARCHAR2(20)    ,
    INVOICING_CO_ID              VARCHAR2(20)    ,
    SHARE_BASIS                  VARCHAR2(20)    ,
    CDR_FILENAME                 VARCHAR2(255)   ,
    CHK_DUPLICATE                VARCHAR2(255)   ,
    FILTER_DTM                   TIMESTAMP(6)    ,
    CREATE_BY                    VARCHAR2(50)    ,
    REMAP_DTM                    TIMESTAMP(6)    ,
    REMAP_BY                     VARCHAR2(50)    ,
    PROCESS_DATE                 TIMESTAMP(6)    ,
    TRANSACTION_UNITS            VARCHAR2(20)    ,
    STATUS                       VARCHAR2(50)    ,
    WORKFLOW_PROCESS_DATE        VARCHAR2(14)    ,
    FILE_DATE                    TIMESTAMP(6)    
);
-- Blendata partition by: PARTITION_DATE, STATUS, WORKFLOW_PROCESS_DATE
--   ถ้าจะทำ partition ฝั่ง Oracle ด้วย แนะนำ RANGE/INTERVAL บน PARTITION_DATE
--   และจะทำให้ 080000 retention ใช้ DROP PARTITION แทน DELETE ได้
