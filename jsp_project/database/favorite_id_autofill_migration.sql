-- Existing favorite tables may have favorite_id as NOT NULL without IDENTITY.
-- This migration keeps existing data and fills favorite_id automatically
-- when application code inserts only member_id/product_id/created_at.

SET DEFINE OFF;

DECLARE
    v_identity_count NUMBER;
    v_sequence_count NUMBER;
    v_start_with NUMBER;
    v_next_value NUMBER;
    v_increment_by NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_identity_count
      FROM user_tab_identity_cols
     WHERE table_name = 'FAVORITE'
       AND column_name = 'FAVORITE_ID';

    IF v_identity_count = 0 THEN
        SELECT COUNT(*)
          INTO v_sequence_count
          FROM user_sequences
         WHERE sequence_name = 'SEQ_FAVORITE';

        IF v_sequence_count = 0 THEN
            SELECT NVL(MAX(favorite_id), 0) + 1
              INTO v_start_with
              FROM favorite;

            EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_favorite START WITH '
                || v_start_with || ' INCREMENT BY 1 NOCACHE NOCYCLE';
        ELSE
            SELECT NVL(MAX(favorite_id), 0) + 1
              INTO v_start_with
              FROM favorite;

            EXECUTE IMMEDIATE 'SELECT seq_favorite.NEXTVAL FROM dual'
              INTO v_next_value;

            IF v_next_value < v_start_with THEN
                v_increment_by := v_start_with - v_next_value;

                EXECUTE IMMEDIATE 'ALTER SEQUENCE seq_favorite INCREMENT BY ' || v_increment_by;
                EXECUTE IMMEDIATE 'SELECT seq_favorite.NEXTVAL FROM dual' INTO v_next_value;
                EXECUTE IMMEDIATE 'ALTER SEQUENCE seq_favorite INCREMENT BY 1';
            END IF;
        END IF;

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER trg_favorite_id
            BEFORE INSERT ON favorite
            FOR EACH ROW
            BEGIN
                IF :NEW.favorite_id IS NULL THEN
                    SELECT seq_favorite.NEXTVAL
                      INTO :NEW.favorite_id
                      FROM dual;
                END IF;
            END;
        ]';
    END IF;
END;
/

COMMIT;
