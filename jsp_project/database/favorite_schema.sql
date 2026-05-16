-- 관심 상품 기능 DB 스키마
-- product_schema.sql 실행 후 적용합니다.

CREATE TABLE favorite (
    favorite_id NUMBER NOT NULL,
    member_id VARCHAR2(20 BYTE) NOT NULL,
    product_id NUMBER NOT NULL,
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    CONSTRAINT favorite_pk PRIMARY KEY (favorite_id),
    CONSTRAINT uq_favorite_member_product UNIQUE (member_id, product_id),
    CONSTRAINT fk_favorite_member FOREIGN KEY (member_id)
        REFERENCES member (login_id) ON DELETE CASCADE,
    CONSTRAINT fk_favorite_product FOREIGN KEY (product_id)
        REFERENCES product (product_id) ON DELETE CASCADE
);

CREATE SEQUENCE seq_favorite START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

COMMIT;
