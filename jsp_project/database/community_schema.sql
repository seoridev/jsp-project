-- 동네마켓 커뮤니티 스키마
-- Oracle 기준. 기존 MEMBER 테이블의 LOGIN_ID를 회원 FK로 사용한다.

CREATE TABLE cafe (
    cafe_id NUMBER,
    cafe_name VARCHAR2(100 BYTE) NOT NULL,
    description CLOB,
    image_path VARCHAR2(500 BYTE),
    region VARCHAR2(100 BYTE) NOT NULL,
    category VARCHAR2(50 BYTE) NOT NULL,
    visibility VARCHAR2(20 BYTE) DEFAULT 'PUBLIC' NOT NULL,
    join_type VARCHAR2(20 BYTE) DEFAULT 'DIRECT' NOT NULL,
    owner_id VARCHAR2(50 BYTE) NOT NULL,
    status VARCHAR2(20 BYTE) DEFAULT 'ACTIVE' NOT NULL,
    member_count NUMBER DEFAULT 0 NOT NULL,
    post_count NUMBER DEFAULT 0 NOT NULL,
    view_count NUMBER DEFAULT 0 NOT NULL,
    last_active_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe ADD CONSTRAINT cafe_pk PRIMARY KEY (cafe_id);
ALTER TABLE cafe ADD CONSTRAINT uq_cafe_name UNIQUE (cafe_name);
ALTER TABLE cafe ADD CONSTRAINT fk_cafe_owner FOREIGN KEY (owner_id) REFERENCES member(login_id);
ALTER TABLE cafe ADD CONSTRAINT chk_cafe_visibility CHECK (visibility IN ('PUBLIC', 'PRIVATE'));
ALTER TABLE cafe ADD CONSTRAINT chk_cafe_join_type CHECK (join_type IN ('DIRECT', 'APPROVAL'));
ALTER TABLE cafe ADD CONSTRAINT chk_cafe_status CHECK (status IN ('ACTIVE', 'HIDDEN', 'DELETED'));

CREATE SEQUENCE seq_cafe START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE INDEX idx_cafe_region ON cafe(region);
CREATE INDEX idx_cafe_category ON cafe(category);
CREATE INDEX idx_cafe_status ON cafe(status);

CREATE TABLE cafe_member (
    cafe_member_id NUMBER,
    cafe_id NUMBER NOT NULL,
    member_id VARCHAR2(50 BYTE) NOT NULL,
    role VARCHAR2(20 BYTE) DEFAULT 'MEMBER' NOT NULL,
    status VARCHAR2(20 BYTE) DEFAULT 'ACTIVE' NOT NULL,
    joined_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe_member ADD CONSTRAINT cafe_member_pk PRIMARY KEY (cafe_member_id);
ALTER TABLE cafe_member ADD CONSTRAINT uq_cafe_member UNIQUE (cafe_id, member_id);
ALTER TABLE cafe_member ADD CONSTRAINT fk_cafe_member_cafe FOREIGN KEY (cafe_id) REFERENCES cafe(cafe_id) ON DELETE CASCADE;
ALTER TABLE cafe_member ADD CONSTRAINT fk_cafe_member_member FOREIGN KEY (member_id) REFERENCES member(login_id);
ALTER TABLE cafe_member ADD CONSTRAINT chk_cafe_member_role CHECK (role IN ('OWNER', 'MANAGER', 'MEMBER'));
ALTER TABLE cafe_member ADD CONSTRAINT chk_cafe_member_status CHECK (status IN ('PENDING', 'ACTIVE', 'REJECTED', 'BANNED', 'LEFT'));

CREATE SEQUENCE seq_cafe_member START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE INDEX idx_cafe_member_member ON cafe_member(member_id);
CREATE INDEX idx_cafe_member_status ON cafe_member(status);

CREATE TABLE cafe_board (
    board_id NUMBER,
    cafe_id NUMBER NOT NULL,
    board_name VARCHAR2(100 BYTE) NOT NULL,
    description VARCHAR2(500 BYTE),
    read_permission VARCHAR2(20 BYTE) DEFAULT 'ALL' NOT NULL,
    write_permission VARCHAR2(20 BYTE) DEFAULT 'MEMBER' NOT NULL,
    is_notice CHAR(1 BYTE) DEFAULT 'N' NOT NULL,
    is_admin_only CHAR(1 BYTE) DEFAULT 'N' NOT NULL,
    display_order NUMBER DEFAULT 1 NOT NULL,
    status VARCHAR2(20 BYTE) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe_board ADD CONSTRAINT cafe_board_pk PRIMARY KEY (board_id);
ALTER TABLE cafe_board ADD CONSTRAINT fk_cafe_board_cafe FOREIGN KEY (cafe_id) REFERENCES cafe(cafe_id) ON DELETE CASCADE;
ALTER TABLE cafe_board ADD CONSTRAINT chk_cafe_board_read CHECK (read_permission IN ('ALL', 'MEMBER'));
ALTER TABLE cafe_board ADD CONSTRAINT chk_cafe_board_write CHECK (write_permission IN ('MEMBER', 'MANAGER', 'OWNER'));
ALTER TABLE cafe_board ADD CONSTRAINT chk_cafe_board_notice CHECK (is_notice IN ('Y', 'N'));
ALTER TABLE cafe_board ADD CONSTRAINT chk_cafe_board_admin_only CHECK (is_admin_only IN ('Y', 'N'));
ALTER TABLE cafe_board ADD CONSTRAINT chk_cafe_board_status CHECK (status IN ('ACTIVE', 'HIDDEN', 'DELETED'));

CREATE SEQUENCE seq_cafe_board START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE INDEX idx_cafe_board_cafe ON cafe_board(cafe_id);

CREATE TABLE cafe_post (
    post_id NUMBER,
    cafe_id NUMBER NOT NULL,
    board_id NUMBER NOT NULL,
    writer_id VARCHAR2(50 BYTE) NOT NULL,
    title VARCHAR2(200 BYTE) NOT NULL,
    content CLOB NOT NULL,
    view_count NUMBER DEFAULT 0 NOT NULL,
    like_count NUMBER DEFAULT 0 NOT NULL,
    comment_count NUMBER DEFAULT 0 NOT NULL,
    is_notice CHAR(1 BYTE) DEFAULT 'N' NOT NULL,
    is_hidden CHAR(1 BYTE) DEFAULT 'N' NOT NULL,
    is_deleted CHAR(1 BYTE) DEFAULT 'N' NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe_post ADD CONSTRAINT cafe_post_pk PRIMARY KEY (post_id);
ALTER TABLE cafe_post ADD CONSTRAINT fk_cafe_post_cafe FOREIGN KEY (cafe_id) REFERENCES cafe(cafe_id) ON DELETE CASCADE;
ALTER TABLE cafe_post ADD CONSTRAINT fk_cafe_post_board FOREIGN KEY (board_id) REFERENCES cafe_board(board_id) ON DELETE CASCADE;
ALTER TABLE cafe_post ADD CONSTRAINT fk_cafe_post_writer FOREIGN KEY (writer_id) REFERENCES member(login_id);
ALTER TABLE cafe_post ADD CONSTRAINT chk_cafe_post_notice CHECK (is_notice IN ('Y', 'N'));
ALTER TABLE cafe_post ADD CONSTRAINT chk_cafe_post_hidden CHECK (is_hidden IN ('Y', 'N'));
ALTER TABLE cafe_post ADD CONSTRAINT chk_cafe_post_deleted CHECK (is_deleted IN ('Y', 'N'));

CREATE SEQUENCE seq_cafe_post START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE INDEX idx_cafe_post_cafe_board ON cafe_post(cafe_id, board_id);
CREATE INDEX idx_cafe_post_writer ON cafe_post(writer_id);
CREATE INDEX idx_cafe_post_created ON cafe_post(created_at);

CREATE TABLE cafe_comment (
    comment_id NUMBER,
    post_id NUMBER NOT NULL,
    writer_id VARCHAR2(50 BYTE) NOT NULL,
    content VARCHAR2(1000 BYTE) NOT NULL,
    is_deleted CHAR(1 BYTE) DEFAULT 'N' NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe_comment ADD CONSTRAINT cafe_comment_pk PRIMARY KEY (comment_id);
ALTER TABLE cafe_comment ADD CONSTRAINT fk_cafe_comment_post FOREIGN KEY (post_id) REFERENCES cafe_post(post_id) ON DELETE CASCADE;
ALTER TABLE cafe_comment ADD CONSTRAINT fk_cafe_comment_writer FOREIGN KEY (writer_id) REFERENCES member(login_id);
ALTER TABLE cafe_comment ADD CONSTRAINT chk_cafe_comment_deleted CHECK (is_deleted IN ('Y', 'N'));

CREATE SEQUENCE seq_cafe_comment START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE INDEX idx_cafe_comment_post ON cafe_comment(post_id);
CREATE INDEX idx_cafe_comment_writer ON cafe_comment(writer_id);

CREATE TABLE cafe_post_image (
    image_id NUMBER,
    post_id NUMBER NOT NULL,
    origin_name VARCHAR2(255 BYTE),
    save_name VARCHAR2(255 BYTE) NOT NULL,
    image_path VARCHAR2(500 BYTE) NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe_post_image ADD CONSTRAINT cafe_post_image_pk PRIMARY KEY (image_id);
ALTER TABLE cafe_post_image ADD CONSTRAINT fk_cafe_post_image_post FOREIGN KEY (post_id) REFERENCES cafe_post(post_id) ON DELETE CASCADE;

CREATE SEQUENCE seq_cafe_post_image START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE INDEX idx_cafe_post_image_post ON cafe_post_image(post_id);

CREATE TABLE cafe_post_like (
    like_id NUMBER,
    post_id NUMBER NOT NULL,
    member_id VARCHAR2(50 BYTE) NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe_post_like ADD CONSTRAINT cafe_post_like_pk PRIMARY KEY (like_id);
ALTER TABLE cafe_post_like ADD CONSTRAINT uq_cafe_post_like UNIQUE (post_id, member_id);
ALTER TABLE cafe_post_like ADD CONSTRAINT fk_cafe_post_like_post FOREIGN KEY (post_id) REFERENCES cafe_post(post_id) ON DELETE CASCADE;
ALTER TABLE cafe_post_like ADD CONSTRAINT fk_cafe_post_like_member FOREIGN KEY (member_id) REFERENCES member(login_id);

CREATE SEQUENCE seq_cafe_post_like START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE cafe_favorite (
    favorite_id NUMBER,
    cafe_id NUMBER NOT NULL,
    member_id VARCHAR2(50 BYTE) NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe_favorite ADD CONSTRAINT cafe_favorite_pk PRIMARY KEY (favorite_id);
ALTER TABLE cafe_favorite ADD CONSTRAINT uq_cafe_favorite UNIQUE (cafe_id, member_id);
ALTER TABLE cafe_favorite ADD CONSTRAINT fk_cafe_favorite_cafe FOREIGN KEY (cafe_id) REFERENCES cafe(cafe_id) ON DELETE CASCADE;
ALTER TABLE cafe_favorite ADD CONSTRAINT fk_cafe_favorite_member FOREIGN KEY (member_id) REFERENCES member(login_id);

CREATE SEQUENCE seq_cafe_favorite START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE cafe_activity_log (
    log_id NUMBER,
    cafe_id NUMBER NOT NULL,
    actor_id VARCHAR2(50 BYTE),
    action_type VARCHAR2(50 BYTE) NOT NULL,
    target_type VARCHAR2(50 BYTE),
    target_id NUMBER,
    message VARCHAR2(1000 BYTE),
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP
);

ALTER TABLE cafe_activity_log ADD CONSTRAINT cafe_activity_log_pk PRIMARY KEY (log_id);
ALTER TABLE cafe_activity_log ADD CONSTRAINT fk_cafe_activity_log_cafe FOREIGN KEY (cafe_id) REFERENCES cafe(cafe_id) ON DELETE CASCADE;
ALTER TABLE cafe_activity_log ADD CONSTRAINT fk_cafe_activity_log_actor FOREIGN KEY (actor_id) REFERENCES member(login_id);

CREATE SEQUENCE seq_cafe_activity_log START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE INDEX idx_cafe_activity_log_cafe ON cafe_activity_log(cafe_id);
