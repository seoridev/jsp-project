-- 어드민 커뮤니티 직접 조치 이력 테이블 추가
-- 카페/게시글/댓글 숨김·복구 처리 사유를 저장합니다.

SET DEFINE OFF;

BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE admin_community_action_log (
            log_id NUMBER,
            admin_id VARCHAR2(50 BYTE) NOT NULL,
            target_type VARCHAR2(30 BYTE) NOT NULL,
            target_id NUMBER NOT NULL,
            action_type VARCHAR2(30 BYTE) NOT NULL,
            admin_memo VARCHAR2(1000 BYTE) NOT NULL,
            created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
            CONSTRAINT admin_community_action_log_pk PRIMARY KEY (log_id),
            CONSTRAINT fk_admin_comm_log_admin FOREIGN KEY (admin_id) REFERENCES admin(login_id),
            CONSTRAINT chk_admin_comm_log_target CHECK (target_type IN ('CAFE', 'CAFE_POST', 'CAFE_COMMENT')),
            CONSTRAINT chk_admin_comm_log_action CHECK (action_type IN (
                'HIDE_CAFE', 'RESTORE_CAFE',
                'HIDE_POST', 'RESTORE_POST',
                'HIDE_COMMENT', 'RESTORE_COMMENT'
            ))
        )
    ]';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_admin_community_action_log START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_admin_comm_log_target ON admin_community_action_log(target_type, target_id)';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_admin_comm_log_admin ON admin_community_action_log(admin_id)';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

COMMIT;
