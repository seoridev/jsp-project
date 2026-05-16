-- 기존 상품 DB에 회원/카테고리 참조 무결성을 추가합니다.
-- 앱 접속 계정(C##userjsp)에서 실행하는 기준입니다.

MERGE INTO member m
USING (
    SELECT 'user01' AS login_id,
           '19513fdc9da4fb72a4a05eb66917548d3c90ff94d5419e1f2363eea89dfee1dd' AS password,
           '시흥거래러' AS nickname,
           '010-1111-0001' AS phone,
           '경기도 시흥시' AS region
    FROM dual
) s
ON (m.login_id = s.login_id)
WHEN NOT MATCHED THEN
    INSERT (login_id, password, nickname, phone, region, status, created_at)
    VALUES (s.login_id, s.password, s.nickname, s.phone, s.region, 'ACTIVE', SYSTIMESTAMP);

MERGE INTO member m
USING (
    SELECT 'user02' AS login_id,
           '19513fdc9da4fb72a4a05eb66917548d3c90ff94d5419e1f2363eea89dfee1dd' AS password,
           '강남정리왕' AS nickname,
           '010-1111-0002' AS phone,
           '서울특별시 강남구' AS region
    FROM dual
) s
ON (m.login_id = s.login_id)
WHEN NOT MATCHED THEN
    INSERT (login_id, password, nickname, phone, region, status, created_at)
    VALUES (s.login_id, s.password, s.nickname, s.phone, s.region, 'ACTIVE', SYSTIMESTAMP);

MERGE INTO member m
USING (
    SELECT 'user03' AS login_id,
           '19513fdc9da4fb72a4a05eb66917548d3c90ff94d5419e1f2363eea89dfee1dd' AS password,
           '남동게임상점' AS nickname,
           '010-1111-0003' AS phone,
           '인천광역시 남동구' AS region
    FROM dual
) s
ON (m.login_id = s.login_id)
WHEN NOT MATCHED THEN
    INSERT (login_id, password, nickname, phone, region, status, created_at)
    VALUES (s.login_id, s.password, s.nickname, s.phone, s.region, 'ACTIVE', SYSTIMESTAMP);

ALTER TABLE product MODIFY (seller_id NOT NULL);

ALTER TABLE product ADD CONSTRAINT fk_product_seller
    FOREIGN KEY (seller_id) REFERENCES member (login_id);

ALTER TABLE product ADD CONSTRAINT fk_product_category
    FOREIGN KEY (category_id) REFERENCES category (category_id);

COMMIT;
