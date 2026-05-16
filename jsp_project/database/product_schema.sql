-- 상품 기능 DB 스키마
-- 앱 접속 계정(C##userjsp)에서 실행하는 기준입니다.

CREATE TABLE category (
    category_id NUMBER NOT NULL,
    category_name VARCHAR2(50 BYTE) NOT NULL,
    is_active CHAR(1 BYTE) DEFAULT 'Y',
    CONSTRAINT category_pk PRIMARY KEY (category_id),
    CONSTRAINT chk_category_active CHECK (is_active IN ('Y', 'N'))
);

CREATE TABLE product (
    product_id NUMBER NOT NULL,
    seller_id VARCHAR2(20 BYTE),
    category_id NUMBER NOT NULL,
    title VARCHAR2(150 BYTE) NOT NULL,
    content CLOB NOT NULL,
    price NUMBER NOT NULL,
    region VARCHAR2(100 BYTE) NOT NULL,
    status VARCHAR2(20 BYTE) DEFAULT 'SALE',
    view_count NUMBER DEFAULT 0,
    is_deleted CHAR(1 BYTE) DEFAULT 'N',
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    CONSTRAINT product_pk PRIMARY KEY (product_id),
    CONSTRAINT chk_product_status CHECK (status IN ('SALE', 'RESERVED', 'SOLD', 'HIDDEN')),
    CONSTRAINT chk_product_deleted CHECK (is_deleted IN ('Y', 'N'))
);

CREATE TABLE product_image (
    image_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    origin_name VARCHAR2(255 BYTE),
    save_name VARCHAR2(255 BYTE),
    image_path VARCHAR2(500 BYTE),
    is_main CHAR(1 BYTE) DEFAULT 'N',
    created_at TIMESTAMP(6) DEFAULT SYSTIMESTAMP,
    CONSTRAINT product_image_pk PRIMARY KEY (image_id),
    CONSTRAINT chk_product_image_main CHECK (is_main IN ('Y', 'N')),
    CONSTRAINT fk_product_image_product FOREIGN KEY (product_id)
        REFERENCES product (product_id) ON DELETE CASCADE
);

CREATE SEQUENCE seq_product START WITH 51 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_image START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

INSERT INTO category (category_id, category_name, is_active) VALUES (10, '디지털기기', 'Y');
INSERT INTO category (category_id, category_name, is_active) VALUES (20, '생활가전', 'Y');
INSERT INTO category (category_id, category_name, is_active) VALUES (30, '가구/인테리어', 'Y');
INSERT INTO category (category_id, category_name, is_active) VALUES (40, '생활/주방', 'Y');
INSERT INTO category (category_id, category_name, is_active) VALUES (50, '의류/잡화', 'Y');
INSERT INTO category (category_id, category_name, is_active) VALUES (60, '취미/게임', 'Y');
INSERT INTO category (category_id, category_name, is_active) VALUES (70, '도서/티켓', 'Y');
INSERT INTO category (category_id, category_name, is_active) VALUES (80, '기타 중고물품', 'Y');

INSERT INTO product
    (product_id, seller_id, category_id, title, content, price, region, status, view_count, is_deleted, created_at, updated_at)
VALUES
    (48, 'user02', 30, '원목 데스크 정리함', '샘플 상품 설명입니다.', 15000, '서울특별시 강남구', 'RESERVED', 5, 'N',
     TO_TIMESTAMP('26/05/12 19:58:44.364000000', 'RR/MM/DD HH24:MI:SSXFF'),
     TO_TIMESTAMP('26/05/12 19:58:44.364000000', 'RR/MM/DD HH24:MI:SSXFF'));

INSERT INTO product
    (product_id, seller_id, category_id, title, content, price, region, status, view_count, is_deleted, created_at, updated_at)
VALUES
    (49, 'user03', 60, '닌텐도 스위치 OLED', '샘플 상품 설명입니다.', 380000, '인천광역시 남동구', 'SOLD', 24, 'N',
     TO_TIMESTAMP('26/05/12 19:58:44.374000000', 'RR/MM/DD HH24:MI:SSXFF'),
     TO_TIMESTAMP('26/05/12 19:58:44.374000000', 'RR/MM/DD HH24:MI:SSXFF'));

INSERT INTO product
    (product_id, seller_id, category_id, title, content, price, region, status, view_count, is_deleted, created_at, updated_at)
VALUES
    (47, 'user01', 10, '아이폰 15 프로 256GB', '샘플 상품 설명입니다.', 1100000, '경기도 시흥시', 'SALE', 0, 'N',
     TO_TIMESTAMP('26/05/12 19:58:44.356000000', 'RR/MM/DD HH24:MI:SSXFF'),
     TO_TIMESTAMP('26/05/12 19:58:44.356000000', 'RR/MM/DD HH24:MI:SSXFF'));

INSERT INTO product
    (product_id, seller_id, category_id, title, content, price, region, status, view_count, is_deleted, created_at, updated_at)
VALUES
    (50, 'user01', 50, '나이키 에어포스', '샘플 상품 설명입니다.', 85000, '경기도 안산시', 'HIDDEN', 12, 'N',
     TO_TIMESTAMP('26/05/12 19:58:44.380000000', 'RR/MM/DD HH24:MI:SSXFF'),
     TO_TIMESTAMP('26/05/12 19:58:44.380000000', 'RR/MM/DD HH24:MI:SSXFF'));

COMMIT;
