-- 관리자 신고 처리 기록 기능 제거용 정리 스크립트.
-- 이미 적용된 DB에 남아 있는 기록 테이블/컬럼을 제거할 때 실행하세요.

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_constraints
    WHERE constraint_name = 'FK_REPORT_PROCESSED_BY';

    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE report DROP CONSTRAINT fk_report_processed_by';
    END IF;
END;
/

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_tab_columns
    WHERE table_name = 'REPORT' AND column_name = 'PROCESSED_BY';

    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE report DROP COLUMN processed_by';
    END IF;
END;
/

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_tab_columns
    WHERE table_name = 'REPORT' AND column_name = 'ACTION_TYPE';

    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE report DROP COLUMN action_type';
    END IF;
END;
/

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_tab_columns
    WHERE table_name = 'REPORT' AND column_name = 'ADMIN_MEMO';

    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE report DROP COLUMN admin_memo';
    END IF;
END;
/

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_tables
    WHERE table_name = 'ADMIN_COMMUNITY_ACTION_LOG';

    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE admin_community_action_log CASCADE CONSTRAINTS';
    END IF;
END;
/

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_sequences
    WHERE sequence_name = 'SEQ_ADMIN_COMMUNITY_ACTION_LOG';

    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_admin_community_action_log';
    END IF;
END;
/

COMMIT;
