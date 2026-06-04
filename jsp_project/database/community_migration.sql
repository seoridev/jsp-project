-- 기존 DB에 커뮤니티 신고 target_type을 추가하는 마이그레이션
-- community_schema.sql 또는 sync_to_current_db.sql을 새로 실행하는 경우 별도 실행하지 않아도 됩니다.

SET DEFINE OFF;

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE report DROP CONSTRAINT chk_report_target_type';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2443 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE q'[
        ALTER TABLE report ADD CONSTRAINT chk_report_target_type
        CHECK (target_type IN ('PRODUCT', 'MEMBER', 'CHAT', 'CAFE', 'CAFE_POST', 'CAFE_COMMENT'))
    ]';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2264 THEN RAISE; END IF;
END;
/

COMMIT;
