-- Cafe category master migration.
-- Keeps cafe.category for backward compatibility and adds cafe.cafe_category_id.

SET DEFINE OFF;

BEGIN
    EXECUTE IMMEDIATE q'[
        CREATE TABLE cafe_category (
            cafe_category_id NUMBER,
            category_name VARCHAR2(50 BYTE) NOT NULL,
            sort_order NUMBER DEFAULT 0 NOT NULL,
            is_active CHAR(1 BYTE) DEFAULT 'Y' NOT NULL,
            CONSTRAINT cafe_category_pk PRIMARY KEY (cafe_category_id),
            CONSTRAINT uq_cafe_category_name UNIQUE (category_name),
            CONSTRAINT chk_cafe_category_active CHECK (is_active IN ('Y', 'N'))
        )
    ]';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

MERGE INTO cafe_category cc
USING (
    SELECT 10 cafe_category_id, UNISTR('\B9DB\C9D1') category_name, 10 sort_order, 'Y' is_active FROM dual UNION ALL
    SELECT 20, UNISTR('\C911\ACE0\AC70\B798'), 20, 'Y' FROM dual UNION ALL
    SELECT 30, UNISTR('\CDE8\BBF8'), 30, 'Y' FROM dual UNION ALL
    SELECT 40, UNISTR('\C721\C544'), 40, 'Y' FROM dual UNION ALL
    SELECT 50, UNISTR('\B098\B214'), 50, 'Y' FROM dual UNION ALL
    SELECT 60, UNISTR('\BC18\B824\B3D9\BB3C'), 60, 'Y' FROM dual UNION ALL
    SELECT 70, UNISTR('\C2A4\D130\B514'), 70, 'Y' FROM dual UNION ALL
    SELECT 90, UNISTR('\D63C\D569'), 90, 'Y' FROM dual
) s
ON (cc.cafe_category_id = s.cafe_category_id)
WHEN MATCHED THEN UPDATE SET
    cc.category_name = s.category_name,
    cc.sort_order = s.sort_order,
    cc.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT
    (cafe_category_id, category_name, sort_order, is_active)
    VALUES
    (s.cafe_category_id, s.category_name, s.sort_order, s.is_active);

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cafe ADD cafe_category_id NUMBER';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1430 THEN RAISE; END IF;
END;
/

UPDATE cafe c
SET cafe_category_id = (
    SELECT cc.cafe_category_id
    FROM cafe_category cc
    WHERE cc.category_name = c.category
);

UPDATE cafe
SET cafe_category_id = 90
WHERE cafe_category_id IS NULL;

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE cafe MODIFY cafe_category_id NOT NULL';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1442 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE q'[
        ALTER TABLE cafe ADD CONSTRAINT fk_cafe_category
        FOREIGN KEY (cafe_category_id)
        REFERENCES cafe_category(cafe_category_id)
    ]';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2275 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_cafe_category_id ON cafe(cafe_category_id)';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

COMMIT;
