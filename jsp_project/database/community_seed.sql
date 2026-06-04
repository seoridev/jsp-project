-- 카페 기능 화면 확인용 예시 데이터
-- Oracle 기준. sync_to_current_db.sql의 테스트 회원(user01, user02, user03, aaa123)을 사용한다.

SET DEFINE OFF;

--------------------------------------------------------
-- 1. 카페
--------------------------------------------------------

MERGE INTO cafe c
USING (
    SELECT '동네 맛집 수다방' cafe_name,
           '우리 동네 맛집, 웨이팅 정보, 혼밥하기 좋은 곳을 함께 공유해요.' description,
           '경기도 시흥시' region,
           '맛집' category,
           'PUBLIC' visibility,
           'DIRECT' join_type,
           'user01' owner_id,
           4 member_count,
           6 post_count,
           128 view_count,
           SYSTIMESTAMP - INTERVAL '1' DAY last_active_at
    FROM dual
    UNION ALL
    SELECT '중고거래 꿀팁 카페',
           '거래 전 체크리스트, 가격 책정, 사기 예방 팁을 나누는 카페입니다.',
           '서울특별시 강남구',
           '중고거래',
           'PUBLIC',
           'DIRECT',
           'user02',
           3,
           4,
           94,
           SYSTIMESTAMP - INTERVAL '2' DAY
    FROM dual
    UNION ALL
    SELECT '우리동네 러닝크루',
           '퇴근 후 가볍게 달리는 동네 러닝 모임입니다. 신규 멤버는 승인 후 함께해요.',
           '인천광역시 남동구',
           '취미',
           'PRIVATE',
           'APPROVAL',
           'user03',
           3,
           4,
           76,
           SYSTIMESTAMP - INTERVAL '3' DAY
    FROM dual
) s
ON (c.cafe_name = s.cafe_name)
WHEN MATCHED THEN UPDATE SET
    c.description = s.description,
    c.region = s.region,
    c.category = s.category,
    c.visibility = s.visibility,
    c.join_type = s.join_type,
    c.owner_id = s.owner_id,
    c.status = 'ACTIVE',
    c.member_count = s.member_count,
    c.post_count = s.post_count,
    c.view_count = s.view_count,
    c.last_active_at = s.last_active_at,
    c.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (cafe_id, cafe_name, description, image_path, region, category, visibility, join_type,
     owner_id, status, member_count, post_count, view_count, last_active_at, created_at, updated_at)
    VALUES
    (seq_cafe.NEXTVAL, s.cafe_name, s.description, NULL, s.region, s.category, s.visibility, s.join_type,
     s.owner_id, 'ACTIVE', s.member_count, s.post_count, s.view_count, s.last_active_at, SYSTIMESTAMP, SYSTIMESTAMP);

--------------------------------------------------------
-- 2. 카페 회원
--------------------------------------------------------

MERGE INTO cafe_member cm
USING (
    SELECT c.cafe_id, 'user01' member_id, 'OWNER' role, 'ACTIVE' status
    FROM cafe c WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, 'user02', 'MANAGER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, 'user03', 'MEMBER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, 'aaa123', 'MEMBER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, 'user02', 'OWNER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL
    SELECT c.cafe_id, 'user01', 'MEMBER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL
    SELECT c.cafe_id, 'aaa123', 'MEMBER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL
    SELECT c.cafe_id, 'user03', 'OWNER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '우리동네 러닝크루'
    UNION ALL
    SELECT c.cafe_id, 'user01', 'MANAGER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '우리동네 러닝크루'
    UNION ALL
    SELECT c.cafe_id, 'user02', 'MEMBER', 'ACTIVE'
    FROM cafe c WHERE c.cafe_name = '우리동네 러닝크루'
    UNION ALL
    SELECT c.cafe_id, 'aaa123', 'MEMBER', 'PENDING'
    FROM cafe c WHERE c.cafe_name = '우리동네 러닝크루'
) s
ON (cm.cafe_id = s.cafe_id AND cm.member_id = s.member_id)
WHEN MATCHED THEN UPDATE SET
    cm.role = s.role,
    cm.status = s.status,
    cm.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (cafe_member_id, cafe_id, member_id, role, status, joined_at, updated_at)
    VALUES
    (seq_cafe_member.NEXTVAL, s.cafe_id, s.member_id, s.role, s.status, SYSTIMESTAMP, SYSTIMESTAMP);

UPDATE cafe_member cm
SET cm.role = 'MEMBER',
    cm.updated_at = SYSTIMESTAMP
WHERE cm.role = 'OWNER'
  AND EXISTS (
      SELECT 1
      FROM cafe c
      WHERE c.cafe_id = cm.cafe_id
        AND c.owner_id <> cm.member_id
  );

--------------------------------------------------------
-- 3. 게시판
--------------------------------------------------------

MERGE INTO cafe_board cb
USING (
    SELECT c.cafe_id, '공지사항' board_name, '카페 소식과 운영 안내' description, 'ALL' read_permission, 'MANAGER' write_permission, 'Y' is_notice, 1 display_order
    FROM cafe c WHERE c.cafe_name IN ('동네 맛집 수다방', '중고거래 꿀팁 카페', '우리동네 러닝크루')
    UNION ALL
    SELECT c.cafe_id, '자유게시판', '자유롭게 이야기해요', 'ALL', 'MEMBER', 'N', 2
    FROM cafe c WHERE c.cafe_name IN ('동네 맛집 수다방', '중고거래 꿀팁 카페')
    UNION ALL
    SELECT c.cafe_id, '맛집 후기', '다녀온 곳 후기를 남겨요', 'ALL', 'MEMBER', 'N', 3
    FROM cafe c WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, '거래 질문', '거래 전 궁금한 점을 물어보세요', 'ALL', 'MEMBER', 'N', 3
    FROM cafe c WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL
    SELECT c.cafe_id, '러닝 공지', '정기 러닝 일정과 준비물 안내', 'MEMBER', 'MANAGER', 'Y', 2
    FROM cafe c WHERE c.cafe_name = '우리동네 러닝크루'
    UNION ALL
    SELECT c.cafe_id, '러닝 후기', '함께 달린 기록과 코스 후기를 남겨요', 'MEMBER', 'MEMBER', 'N', 3
    FROM cafe c WHERE c.cafe_name = '우리동네 러닝크루'
) s
ON (cb.cafe_id = s.cafe_id AND cb.board_name = s.board_name)
WHEN MATCHED THEN UPDATE SET
    cb.description = s.description,
    cb.read_permission = s.read_permission,
    cb.write_permission = s.write_permission,
    cb.is_notice = s.is_notice,
    cb.display_order = s.display_order,
    cb.status = 'ACTIVE',
    cb.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (board_id, cafe_id, board_name, description, read_permission, write_permission,
     is_notice, is_admin_only, display_order, status, created_at, updated_at)
    VALUES
    (seq_cafe_board.NEXTVAL, s.cafe_id, s.board_name, s.description, s.read_permission, s.write_permission,
     s.is_notice, 'N', s.display_order, 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);

--------------------------------------------------------
-- 4. 게시글
--------------------------------------------------------

MERGE INTO cafe_post cp
USING (
    SELECT c.cafe_id, b.board_id, 'user01' writer_id,
           '[공지] 맛집 수다방 이용 안내' title,
           '맛집 위치, 가격, 웨이팅 시간, 추천 메뉴를 함께 남겨주세요. 광고성 글은 숨김 처리될 수 있습니다.' content,
           41 view_count, 3 like_count, 2 comment_count, 'Y' is_notice, SYSTIMESTAMP - INTERVAL '7' DAY created_at
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항'
    WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user02',
           '시흥 은행동 칼국수집 다녀왔어요',
           '점심시간에는 조금 기다려야 하지만 국물이 진하고 김치가 맛있었어요. 혼밥도 괜찮은 분위기입니다.',
           33, 2, 2, 'N', SYSTIMESTAMP - INTERVAL '5' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '맛집 후기'
    WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'aaa123',
           '주말 브런치 갈 만한 곳 추천해주세요',
           '가족이랑 갈 예정이라 주차 가능하고 너무 시끄럽지 않은 곳이면 좋겠어요.',
           19, 1, 1, 'N', SYSTIMESTAMP - INTERVAL '3' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판'
    WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user03',
           '배곧 쪽 새로 생긴 돈가스집 후기',
           '등심이 부드럽고 소스가 자극적이지 않았어요. 저녁에는 재료 소진이 빠른 편입니다.',
           22, 1, 0, 'N', SYSTIMESTAMP - INTERVAL '1' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '맛집 후기'
    WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user01',
           '혼밥하기 좋은 국밥집 리스트 공유',
           '카운터석이 있거나 회전이 빠른 곳 위주로 정리해봤어요. 댓글로 추가 추천 부탁드려요.',
           13, 1, 0, 'N', SYSTIMESTAMP - INTERVAL '12' HOUR
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판'
    WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user02',
           '이번 주 인기 맛집 모아보기',
           '조회수가 높았던 후기와 추천 댓글을 모았습니다. 처음 방문하는 분들은 참고해 주세요.',
           0, 0, 0, 'Y', SYSTIMESTAMP - INTERVAL '2' HOUR
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항'
    WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user02',
           '[공지] 안전거래 체크리스트' title,
           '직거래 장소, 계좌 거래, 택배 거래 전 확인해야 할 내용을 정리했습니다.' content,
           38, 4, 1, 'Y', SYSTIMESTAMP - INTERVAL '8' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항'
    WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user01',
           '노트북 거래할 때 배터리 확인 어떻게 하세요?',
           '설정에서 사이클 수를 보는 방법 말고 현장에서 빠르게 확인할 팁이 있을까요?',
           24, 2, 1, 'N', SYSTIMESTAMP - INTERVAL '4' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '거래 질문'
    WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'aaa123',
           '가격 제안 받을 때 기준 잡는 법',
           '처음 올릴 때 어느 정도 여유를 두고 가격을 정하는지 궁금합니다.',
           16, 1, 1, 'N', SYSTIMESTAMP - INTERVAL '2' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판'
    WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user02',
           '거래 장소는 밝은 곳이 제일 좋더라고요',
           '최근에는 지하철역 출구 앞이나 편의점 앞에서 주로 거래하고 있어요.',
           11, 0, 0, 'N', SYSTIMESTAMP - INTERVAL '9' HOUR
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판'
    WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user03',
           '[공지] 6월 정기 러닝 일정',
           '매주 화요일과 목요일 저녁 8시에 중앙공원 입구에서 모입니다. 우천 시 취소됩니다.',
           29, 3, 2, 'Y', SYSTIMESTAMP - INTERVAL '6' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '러닝 공지'
    WHERE c.cafe_name = '우리동네 러닝크루'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user01',
           '어제 5km 완주 후기',
           '처음에는 페이스가 빨라 힘들었는데 마지막 1km는 다 같이 맞춰 뛰어서 좋았습니다.',
           21, 2, 1, 'N', SYSTIMESTAMP - INTERVAL '2' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '러닝 후기'
    WHERE c.cafe_name = '우리동네 러닝크루'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user02',
           '초보자도 참여 가능한가요?',
           '러닝을 막 시작했는데 3km 정도부터 같이 뛰어도 괜찮을까요?',
           17, 1, 1, 'N', SYSTIMESTAMP - INTERVAL '1' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '러닝 후기'
    WHERE c.cafe_name = '우리동네 러닝크루'
    UNION ALL
    SELECT c.cafe_id, b.board_id, 'user03',
           '다음 모임 준비물 안내',
           '물, 가벼운 바람막이, 야간 식별용 밴드를 챙겨오시면 좋습니다.',
           9, 0, 0, 'Y', SYSTIMESTAMP - INTERVAL '4' HOUR
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '러닝 공지'
    WHERE c.cafe_name = '우리동네 러닝크루'
) s
ON (cp.cafe_id = s.cafe_id AND cp.title = s.title)
WHEN MATCHED THEN UPDATE SET
    cp.board_id = s.board_id,
    cp.writer_id = s.writer_id,
    cp.content = s.content,
    cp.view_count = s.view_count,
    cp.like_count = s.like_count,
    cp.comment_count = s.comment_count,
    cp.is_notice = s.is_notice,
    cp.is_hidden = 'N',
    cp.is_deleted = 'N',
    cp.created_at = s.created_at,
    cp.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (post_id, cafe_id, board_id, writer_id, title, content, view_count, like_count,
     comment_count, is_notice, is_hidden, is_deleted, created_at, updated_at)
    VALUES
    (seq_cafe_post.NEXTVAL, s.cafe_id, s.board_id, s.writer_id, s.title, s.content, s.view_count, s.like_count,
     s.comment_count, s.is_notice, 'N', 'N', s.created_at, SYSTIMESTAMP);

--------------------------------------------------------
-- 5. 댓글
--------------------------------------------------------

MERGE INTO cafe_comment cc
USING (
    SELECT p.post_id, 'user02' writer_id, '공지 확인했습니다. 후기 작성할 때 양식 참고할게요.' content
    FROM cafe_post p WHERE p.title = '[공지] 맛집 수다방 이용 안내'
    UNION ALL
    SELECT p.post_id, 'aaa123', '광고성 글 기준도 명확해서 좋아요.'
    FROM cafe_post p WHERE p.title = '[공지] 맛집 수다방 이용 안내'
    UNION ALL
    SELECT p.post_id, 'user01', '저도 여기 다녀왔는데 김치가 정말 맛있었어요.'
    FROM cafe_post p WHERE p.title = '시흥 은행동 칼국수집 다녀왔어요'
    UNION ALL
    SELECT p.post_id, 'user03', '주차는 근처 공영주차장 이용하면 편했습니다.'
    FROM cafe_post p WHERE p.title = '시흥 은행동 칼국수집 다녀왔어요'
    UNION ALL
    SELECT p.post_id, 'user02', '배곧 쪽 브런치 카페 한 곳 추천드려요. 주차장도 넓습니다.'
    FROM cafe_post p WHERE p.title = '주말 브런치 갈 만한 곳 추천해주세요'
    UNION ALL
    SELECT p.post_id, 'aaa123', '배터리 사이클이랑 외관 나사 마모도 같이 보면 좋아요.'
    FROM cafe_post p WHERE p.title = '노트북 거래할 때 배터리 확인 어떻게 하세요?'
    UNION ALL
    SELECT p.post_id, 'user01', '저는 최근 거래 완료가보다 10퍼센트 정도 높게 올려요.'
    FROM cafe_post p WHERE p.title = '가격 제안 받을 때 기준 잡는 법'
    UNION ALL
    SELECT p.post_id, 'user01', '체크리스트 저장해두겠습니다. 초보 거래자에게 유용하네요.'
    FROM cafe_post p WHERE p.title = '[공지] 안전거래 체크리스트'
    UNION ALL
    SELECT p.post_id, 'user03', '다음에는 6km 코스도 천천히 도전해봐요.'
    FROM cafe_post p WHERE p.title = '어제 5km 완주 후기'
    UNION ALL
    SELECT p.post_id, 'user03', '초보자 환영입니다. 3km 조도 같이 운영할게요.'
    FROM cafe_post p WHERE p.title = '초보자도 참여 가능한가요?'
    UNION ALL
    SELECT p.post_id, 'user01', '공지 확인했습니다. 야간 밴드 챙겨갈게요.'
    FROM cafe_post p WHERE p.title = '[공지] 6월 정기 러닝 일정'
    UNION ALL
    SELECT p.post_id, 'user02', '비 오면 당일 오후에 다시 공지 부탁드려요.'
    FROM cafe_post p WHERE p.title = '[공지] 6월 정기 러닝 일정'
) s
ON (cc.post_id = s.post_id AND cc.writer_id = s.writer_id AND cc.content = s.content)
WHEN MATCHED THEN UPDATE SET
    cc.is_deleted = 'N',
    cc.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (comment_id, post_id, writer_id, content, is_deleted, created_at, updated_at)
    VALUES
    (seq_cafe_comment.NEXTVAL, s.post_id, s.writer_id, s.content, 'N', SYSTIMESTAMP, SYSTIMESTAMP);

--------------------------------------------------------
-- 6. 좋아요
--------------------------------------------------------

MERGE INTO cafe_post_like cpl
USING (
    SELECT p.post_id, 'user01' member_id FROM cafe_post p WHERE p.title = '[공지] 맛집 수다방 이용 안내'
    UNION ALL SELECT p.post_id, 'user02' FROM cafe_post p WHERE p.title = '[공지] 맛집 수다방 이용 안내'
    UNION ALL SELECT p.post_id, 'aaa123' FROM cafe_post p WHERE p.title = '[공지] 맛집 수다방 이용 안내'
    UNION ALL SELECT p.post_id, 'user01' FROM cafe_post p WHERE p.title = '시흥 은행동 칼국수집 다녀왔어요'
    UNION ALL SELECT p.post_id, 'user03' FROM cafe_post p WHERE p.title = '시흥 은행동 칼국수집 다녀왔어요'
    UNION ALL SELECT p.post_id, 'user02' FROM cafe_post p WHERE p.title = '주말 브런치 갈 만한 곳 추천해주세요'
    UNION ALL SELECT p.post_id, 'user01' FROM cafe_post p WHERE p.title = '[공지] 안전거래 체크리스트'
    UNION ALL SELECT p.post_id, 'user02' FROM cafe_post p WHERE p.title = '[공지] 안전거래 체크리스트'
    UNION ALL SELECT p.post_id, 'user03' FROM cafe_post p WHERE p.title = '[공지] 안전거래 체크리스트'
    UNION ALL SELECT p.post_id, 'aaa123' FROM cafe_post p WHERE p.title = '[공지] 안전거래 체크리스트'
    UNION ALL SELECT p.post_id, 'user02' FROM cafe_post p WHERE p.title = '어제 5km 완주 후기'
    UNION ALL SELECT p.post_id, 'user03' FROM cafe_post p WHERE p.title = '어제 5km 완주 후기'
    UNION ALL SELECT p.post_id, 'user01' FROM cafe_post p WHERE p.title = '[공지] 6월 정기 러닝 일정'
    UNION ALL SELECT p.post_id, 'user02' FROM cafe_post p WHERE p.title = '[공지] 6월 정기 러닝 일정'
    UNION ALL SELECT p.post_id, 'user03' FROM cafe_post p WHERE p.title = '[공지] 6월 정기 러닝 일정'
) s
ON (cpl.post_id = s.post_id AND cpl.member_id = s.member_id)
WHEN NOT MATCHED THEN INSERT
    (like_id, post_id, member_id, created_at)
    VALUES
    (seq_cafe_post_like.NEXTVAL, s.post_id, s.member_id, SYSTIMESTAMP);

--------------------------------------------------------
-- 7. 즐겨찾기
--------------------------------------------------------

MERGE INTO cafe_favorite cf
USING (
    SELECT c.cafe_id, 'aaa123' member_id FROM cafe c WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL SELECT c.cafe_id, 'user02' FROM cafe c WHERE c.cafe_name = '동네 맛집 수다방'
    UNION ALL SELECT c.cafe_id, 'user01' FROM cafe c WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL SELECT c.cafe_id, 'aaa123' FROM cafe c WHERE c.cafe_name = '중고거래 꿀팁 카페'
    UNION ALL SELECT c.cafe_id, 'user01' FROM cafe c WHERE c.cafe_name = '우리동네 러닝크루'
) s
ON (cf.cafe_id = s.cafe_id AND cf.member_id = s.member_id)
WHEN NOT MATCHED THEN INSERT
    (favorite_id, cafe_id, member_id, created_at)
    VALUES
    (seq_cafe_favorite.NEXTVAL, s.cafe_id, s.member_id, SYSTIMESTAMP);

--------------------------------------------------------
-- 8. 카운트 재계산
--------------------------------------------------------

UPDATE cafe c
SET member_count = (
        SELECT COUNT(*)
        FROM cafe_member cm
        WHERE cm.cafe_id = c.cafe_id
          AND cm.status = 'ACTIVE'
    ),
    post_count = (
        SELECT COUNT(*)
        FROM cafe_post cp
        WHERE cp.cafe_id = c.cafe_id
          AND cp.is_hidden = 'N'
          AND cp.is_deleted = 'N'
    ),
    updated_at = SYSTIMESTAMP
WHERE c.cafe_name IN ('동네 맛집 수다방', '중고거래 꿀팁 카페', '우리동네 러닝크루');

UPDATE cafe_post cp
SET comment_count = (
        SELECT COUNT(*)
        FROM cafe_comment cc
        WHERE cc.post_id = cp.post_id
          AND cc.is_deleted = 'N'
    ),
    like_count = (
        SELECT COUNT(*)
        FROM cafe_post_like cpl
        WHERE cpl.post_id = cp.post_id
    ),
    updated_at = SYSTIMESTAMP
WHERE cp.cafe_id IN (
    SELECT cafe_id
    FROM cafe
    WHERE cafe_name IN ('동네 맛집 수다방', '중고거래 꿀팁 카페', '우리동네 러닝크루')
);

--------------------------------------------------------
-- 9. 실제 서비스처럼 보이는 추가 카페/글 데이터
--------------------------------------------------------

UPDATE cafe
SET cafe_name = '안양 만안 동네장터',
    description = '안양 만안구 이웃들이 중고거래, 나눔, 동네 생활 정보를 편하게 나누는 카페입니다.',
    region = '경기도 안양시 만안구 안양동',
    category = '중고거래',
    visibility = 'PUBLIC',
    join_type = 'DIRECT',
    owner_id = 'user01',
    status = 'ACTIVE',
    updated_at = SYSTIMESTAMP
WHERE cafe_name = 'fdsa'
  AND NOT EXISTS (
      SELECT 1 FROM cafe WHERE cafe_name = '안양 만안 동네장터'
  );

UPDATE cafe_post
SET title = '안양역 근처 생활용품 나눔합니다',
    content = '이사 정리하면서 나온 깨끗한 생활용품 몇 가지를 동네 이웃에게 나눔하려고 합니다. 필요한 분은 댓글 남겨주세요.',
    updated_at = SYSTIMESTAMP
WHERE (LOWER(title) LIKE '%fdsa%' OR LOWER(title) LIKE '%fasd%' OR LOWER(title) LIKE '%asdf%'
       OR REGEXP_LIKE(title, '^[?[:space:]]+$')
       OR LOWER(DBMS_LOB.SUBSTR(content, 4000, 1)) LIKE '%fdsa%'
       OR LOWER(DBMS_LOB.SUBSTR(content, 4000, 1)) LIKE '%fasd%'
       OR LOWER(DBMS_LOB.SUBSTR(content, 4000, 1)) LIKE '%asdf%'
       OR REGEXP_LIKE(DBMS_LOB.SUBSTR(content, 4000, 1), '^[?[:space:][:punct:]]+$'))
  AND cafe_id IN (
      SELECT cafe_id FROM cafe WHERE cafe_name = '안양 만안 동네장터'
  );

MERGE INTO cafe c
USING (
    SELECT '안양 만안 동네장터' cafe_name,
           '안양 만안구 이웃들이 중고거래, 나눔, 동네 생활 정보를 편하게 나누는 카페입니다.' description,
           '경기도 안양시 만안구 안양동' region,
           '중고거래' category,
           'PUBLIC' visibility,
           'DIRECT' join_type,
           'user01' owner_id,
           4 member_count,
           5 post_count,
           156 view_count,
           SYSTIMESTAMP - INTERVAL '1' HOUR last_active_at
    FROM dual
    UNION ALL
    SELECT '평촌 육아 정보방',
           '평촌과 범계 주변 부모들이 어린이집, 병원, 문화센터 정보를 나누는 공간입니다.',
           '경기도 안양시 동안구 평촌동',
           '육아',
           'PUBLIC',
           'APPROVAL',
           'user02',
           4,
           4,
           121,
           SYSTIMESTAMP - INTERVAL '4' HOUR
    FROM dual
    UNION ALL
    SELECT '관악산 산책모임',
           '관악산 둘레길, 주말 산책 코스, 가벼운 등산 약속을 함께 잡는 카페입니다.',
           '서울특별시 관악구 신림동',
           '취미',
           'PUBLIC',
           'DIRECT',
           'user03',
           4,
           4,
           88,
           SYSTIMESTAMP - INTERVAL '6' HOUR
    FROM dual
    UNION ALL
    SELECT '범계 자취살림 나눔방',
           '범계역 주변 자취생들이 생활용품 나눔, 방 꾸미기, 장보기 팁을 공유합니다.',
           '경기도 안양시 동안구 호계동',
           '나눔',
           'PUBLIC',
           'DIRECT',
           'aaa123',
           4,
           4,
           104,
           SYSTIMESTAMP - INTERVAL '8' HOUR
    FROM dual
    UNION ALL
    SELECT '수원 영통 반려생활',
           '영통 반려인들이 산책 코스, 동물병원, 펫용품 정보를 나누는 카페입니다.',
           '경기도 수원시 영통구 영통동',
           '반려동물',
           'PUBLIC',
           'APPROVAL',
           'user01',
           4,
           4,
           97,
           SYSTIMESTAMP - INTERVAL '10' HOUR
    FROM dual
    UNION ALL
    SELECT '분당 판교 개발자 수다',
           '판교와 분당 개발자들이 커리어, 스터디, 점심 맛집 이야기를 나누는 카페입니다.',
           '경기도 성남시 분당구 삼평동',
           '스터디',
           'PUBLIC',
           'DIRECT',
           'user02',
           4,
           4,
           143,
           SYSTIMESTAMP - INTERVAL '14' HOUR
    FROM dual
) s
ON (c.cafe_name = s.cafe_name)
WHEN MATCHED THEN UPDATE SET
    c.description = s.description,
    c.region = s.region,
    c.category = s.category,
    c.visibility = s.visibility,
    c.join_type = s.join_type,
    c.owner_id = s.owner_id,
    c.status = 'ACTIVE',
    c.member_count = s.member_count,
    c.post_count = s.post_count,
    c.view_count = s.view_count,
    c.last_active_at = s.last_active_at,
    c.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (cafe_id, cafe_name, description, image_path, region, category, visibility, join_type,
     owner_id, status, member_count, post_count, view_count, last_active_at, created_at, updated_at)
    VALUES
    (seq_cafe.NEXTVAL, s.cafe_name, s.description, NULL, s.region, s.category, s.visibility, s.join_type,
     s.owner_id, 'ACTIVE', s.member_count, s.post_count, s.view_count, s.last_active_at, SYSTIMESTAMP, SYSTIMESTAMP);

MERGE INTO cafe_member cm
USING (
    SELECT c.cafe_id, 'user01' member_id, 'OWNER' role, 'ACTIVE' status FROM cafe c WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, 'user02', 'MANAGER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, 'user03', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, 'aaa123', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, 'user02', 'OWNER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '평촌 육아 정보방'
    UNION ALL SELECT c.cafe_id, 'user01', 'MANAGER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '평촌 육아 정보방'
    UNION ALL SELECT c.cafe_id, 'user03', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '평촌 육아 정보방'
    UNION ALL SELECT c.cafe_id, 'aaa123', 'MEMBER', 'PENDING' FROM cafe c WHERE c.cafe_name = '평촌 육아 정보방'
    UNION ALL SELECT c.cafe_id, 'user03', 'OWNER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '관악산 산책모임'
    UNION ALL SELECT c.cafe_id, 'user01', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '관악산 산책모임'
    UNION ALL SELECT c.cafe_id, 'user02', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '관악산 산책모임'
    UNION ALL SELECT c.cafe_id, 'aaa123', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '관악산 산책모임'
    UNION ALL SELECT c.cafe_id, 'aaa123', 'OWNER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '범계 자취살림 나눔방'
    UNION ALL SELECT c.cafe_id, 'user01', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '범계 자취살림 나눔방'
    UNION ALL SELECT c.cafe_id, 'user02', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '범계 자취살림 나눔방'
    UNION ALL SELECT c.cafe_id, 'user03', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '범계 자취살림 나눔방'
    UNION ALL SELECT c.cafe_id, 'user01', 'OWNER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '수원 영통 반려생활'
    UNION ALL SELECT c.cafe_id, 'user02', 'MANAGER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '수원 영통 반려생활'
    UNION ALL SELECT c.cafe_id, 'user03', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '수원 영통 반려생활'
    UNION ALL SELECT c.cafe_id, 'aaa123', 'MEMBER', 'PENDING' FROM cafe c WHERE c.cafe_name = '수원 영통 반려생활'
    UNION ALL SELECT c.cafe_id, 'user02', 'OWNER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '분당 판교 개발자 수다'
    UNION ALL SELECT c.cafe_id, 'user01', 'MANAGER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '분당 판교 개발자 수다'
    UNION ALL SELECT c.cafe_id, 'user03', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '분당 판교 개발자 수다'
    UNION ALL SELECT c.cafe_id, 'aaa123', 'MEMBER', 'ACTIVE' FROM cafe c WHERE c.cafe_name = '분당 판교 개발자 수다'
) s
ON (cm.cafe_id = s.cafe_id AND cm.member_id = s.member_id)
WHEN MATCHED THEN UPDATE SET
    cm.role = s.role,
    cm.status = s.status,
    cm.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (cafe_member_id, cafe_id, member_id, role, status, joined_at, updated_at)
    VALUES
    (seq_cafe_member.NEXTVAL, s.cafe_id, s.member_id, s.role, s.status, SYSTIMESTAMP, SYSTIMESTAMP);

UPDATE cafe_member cm
SET cm.role = 'MEMBER',
    cm.updated_at = SYSTIMESTAMP
WHERE cm.role = 'OWNER'
  AND EXISTS (
      SELECT 1
      FROM cafe c
      WHERE c.cafe_id = cm.cafe_id
        AND c.owner_id <> cm.member_id
  );

MERGE INTO cafe_board cb
USING (
    SELECT c.cafe_id, '공지사항' board_name, '카페 운영 안내와 필독 공지' description, 'ALL' read_permission, 'MANAGER' write_permission, 'Y' is_notice, 1 display_order
    FROM cafe c WHERE c.cafe_name IN ('안양 만안 동네장터', '평촌 육아 정보방', '관악산 산책모임', '범계 자취살림 나눔방', '수원 영통 반려생활', '분당 판교 개발자 수다')
    UNION ALL SELECT c.cafe_id, '자유게시판', '이웃과 자유롭게 이야기해요', 'ALL', 'MEMBER', 'N', 2
    FROM cafe c WHERE c.cafe_name IN ('안양 만안 동네장터', '평촌 육아 정보방', '관악산 산책모임', '범계 자취살림 나눔방', '수원 영통 반려생활', '분당 판교 개발자 수다')
    UNION ALL SELECT c.cafe_id, '거래후기', '직거래와 나눔 후기를 남겨요', 'ALL', 'MEMBER', 'N', 3 FROM cafe c WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, '육아정보', '육아 시설과 생활 정보를 공유해요', 'ALL', 'MEMBER', 'N', 3 FROM cafe c WHERE c.cafe_name = '평촌 육아 정보방'
    UNION ALL SELECT c.cafe_id, '산책후기', '산책 코스와 모임 후기를 남겨요', 'ALL', 'MEMBER', 'N', 3 FROM cafe c WHERE c.cafe_name = '관악산 산책모임'
    UNION ALL SELECT c.cafe_id, '나눔장터', '자취용품 나눔과 거래를 올려요', 'ALL', 'MEMBER', 'N', 3 FROM cafe c WHERE c.cafe_name = '범계 자취살림 나눔방'
    UNION ALL SELECT c.cafe_id, '반려동물 Q&A', '반려생활 궁금증을 묻고 답해요', 'ALL', 'MEMBER', 'N', 3 FROM cafe c WHERE c.cafe_name = '수원 영통 반려생활'
    UNION ALL SELECT c.cafe_id, '개발 이야기', '개발 공부와 커리어 이야기를 나눠요', 'ALL', 'MEMBER', 'N', 3 FROM cafe c WHERE c.cafe_name = '분당 판교 개발자 수다'
) s
ON (cb.cafe_id = s.cafe_id AND cb.board_name = s.board_name)
WHEN MATCHED THEN UPDATE SET
    cb.description = s.description,
    cb.read_permission = s.read_permission,
    cb.write_permission = s.write_permission,
    cb.is_notice = s.is_notice,
    cb.display_order = s.display_order,
    cb.status = 'ACTIVE',
    cb.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (board_id, cafe_id, board_name, description, read_permission, write_permission,
     is_notice, is_admin_only, display_order, status, created_at, updated_at)
    VALUES
    (seq_cafe_board.NEXTVAL, s.cafe_id, s.board_name, s.description, s.read_permission, s.write_permission,
     s.is_notice, 'N', s.display_order, 'ACTIVE', SYSTIMESTAMP, SYSTIMESTAMP);

MERGE INTO cafe_post cp
USING (
    SELECT c.cafe_id, b.board_id, 'user01' writer_id, '[공지] 동네장터 이용 안내' title,
           '직거래 약속은 밝은 장소에서 잡고, 거래 완료 후에는 간단한 후기를 남겨주세요.' content,
           52 view_count, 3 like_count, 2 comment_count, 'Y' is_notice, SYSTIMESTAMP - INTERVAL '9' DAY created_at
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항' WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user02', '안양역 근처 유아책 나눔합니다',
           '상태 좋은 보드북 12권입니다. 이번 주 평일 저녁 안양역 근처에서 드릴 수 있어요.',
           38, 2, 2, 'N', SYSTIMESTAMP - INTERVAL '5' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판' WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, b.board_id, 'aaa123', '접이식 캠핑의자 거래 후기',
           '사진 그대로 깨끗했고 약속 시간도 잘 맞춰주셔서 편하게 거래했습니다.',
           24, 2, 1, 'N', SYSTIMESTAMP - INTERVAL '3' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '거래후기' WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user03', '만안구 이사박스 구할 곳 있을까요?',
           '주말에 이사 준비 중인데 튼튼한 박스 구할 만한 곳 아시는 분 계실까요?',
           21, 1, 1, 'N', SYSTIMESTAMP - INTERVAL '18' HOUR
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판' WHERE c.cafe_name = '안양 만안 동네장터'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user02', '[공지] 육아정보방 글 작성 안내',
           '어린이 개인정보가 드러나는 사진과 실명은 올리지 않도록 주의해주세요.',
           44, 3, 1, 'Y', SYSTIMESTAMP - INTERVAL '8' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항' WHERE c.cafe_name = '평촌 육아 정보방'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user01', '평촌 도서관 유아 프로그램 신청했어요',
           '다음 달 그림책 수업 신청했는데 처음 가보는 분들 참고하시라고 링크 남깁니다.',
           31, 2, 2, 'N', SYSTIMESTAMP - INTERVAL '4' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '육아정보' WHERE c.cafe_name = '평촌 육아 정보방'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user03', '범계 소아과 대기 적은 시간대 공유',
           '오전 첫 타임이나 점심 직후가 비교적 덜 붐비는 편이었어요.',
           27, 2, 1, 'N', SYSTIMESTAMP - INTERVAL '2' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판' WHERE c.cafe_name = '평촌 육아 정보방'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user03', '[공지] 산책모임 안전 수칙',
           '야간 산책은 단체 이동을 원칙으로 하고, 개인 물과 편한 신발을 챙겨주세요.',
           36, 3, 1, 'Y', SYSTIMESTAMP - INTERVAL '7' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항' WHERE c.cafe_name = '관악산 산책모임'
    UNION ALL SELECT c.cafe_id, b.board_id, 'aaa123', '토요일 낙성대 코스 같이 걸으실 분',
           '오전 9시에 낙성대공원 입구에서 출발해서 1시간 정도 걷는 일정입니다.',
           29, 2, 2, 'N', SYSTIMESTAMP - INTERVAL '3' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판' WHERE c.cafe_name = '관악산 산책모임'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user01', '지난주 둘레길 산책 후기',
           '비 온 뒤라 길이 조금 미끄러웠지만 나무 향이 좋아서 만족스러웠어요.',
           22, 1, 1, 'N', SYSTIMESTAMP - INTERVAL '1' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '산책후기' WHERE c.cafe_name = '관악산 산책모임'
    UNION ALL SELECT c.cafe_id, b.board_id, 'aaa123', '[공지] 나눔 물품 예약 규칙',
           '무료 나눔은 댓글 순서보다 실제 약속 가능 시간을 우선합니다.',
           40, 2, 1, 'Y', SYSTIMESTAMP - INTERVAL '6' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항' WHERE c.cafe_name = '범계 자취살림 나눔방'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user02', '전자레인지 받침대 나눔합니다',
           '작은 원룸에서 쓰기 좋은 크기입니다. 범계역 3번 출구 근처에서 전달 가능해요.',
           25, 2, 2, 'N', SYSTIMESTAMP - INTERVAL '2' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '나눔장터' WHERE c.cafe_name = '범계 자취살림 나눔방'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user03', '자취방 습기 잡는 팁 공유해요',
           '옷장 안에는 제습제보다 작은 순환팬을 같이 쓰는 게 훨씬 효과 있었습니다.',
           18, 1, 1, 'N', SYSTIMESTAMP - INTERVAL '12' HOUR
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판' WHERE c.cafe_name = '범계 자취살림 나눔방'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user01', '[공지] 반려생활 매너 안내',
           '산책 모임 사진에는 보호자 동의 없이 얼굴이 나오지 않도록 조심해주세요.',
           33, 2, 1, 'Y', SYSTIMESTAMP - INTERVAL '7' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항' WHERE c.cafe_name = '수원 영통 반려생활'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user02', '영통 중앙공원 산책 시간 추천',
           '오후 5시 이후가 그늘도 많고 강아지 산책하는 분들이 많아서 좋았어요.',
           28, 2, 2, 'N', SYSTIMESTAMP - INTERVAL '3' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판' WHERE c.cafe_name = '수원 영통 반려생활'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user03', '고양이 이동장 적응 어떻게 시키나요?',
           '병원 갈 때마다 너무 힘들어해서 평소에 적응시키는 방법이 궁금합니다.',
           23, 1, 1, 'N', SYSTIMESTAMP - INTERVAL '1' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '반려동물 Q&A' WHERE c.cafe_name = '수원 영통 반려생활'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user02', '[공지] 개발자 수다방 이용 안내',
           '회사 내부 정보나 채용 과정의 민감한 내용은 공유하지 않도록 주의해주세요.',
           47, 3, 1, 'Y', SYSTIMESTAMP - INTERVAL '9' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '공지사항' WHERE c.cafe_name = '분당 판교 개발자 수다'
    UNION ALL SELECT c.cafe_id, b.board_id, 'user01', '점심시간에 보기 좋은 기술 세미나 추천',
           '짧게 볼 수 있는 프론트엔드 성능 개선 발표를 모아봤습니다.',
           34, 2, 2, 'N', SYSTIMESTAMP - INTERVAL '4' DAY
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '개발 이야기' WHERE c.cafe_name = '분당 판교 개발자 수다'
    UNION ALL SELECT c.cafe_id, b.board_id, 'aaa123', '판교역 근처 조용한 코딩 카페 있나요?',
           '노트북 펴고 2시간 정도 집중할 수 있는 곳 찾고 있습니다.',
           30, 2, 1, 'N', SYSTIMESTAMP - INTERVAL '20' HOUR
    FROM cafe c JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = '자유게시판' WHERE c.cafe_name = '분당 판교 개발자 수다'
) s
ON (cp.cafe_id = s.cafe_id AND cp.title = s.title)
WHEN MATCHED THEN UPDATE SET
    cp.board_id = s.board_id,
    cp.writer_id = s.writer_id,
    cp.content = s.content,
    cp.view_count = s.view_count,
    cp.like_count = s.like_count,
    cp.comment_count = s.comment_count,
    cp.is_notice = s.is_notice,
    cp.is_hidden = 'N',
    cp.is_deleted = 'N',
    cp.created_at = s.created_at,
    cp.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (post_id, cafe_id, board_id, writer_id, title, content, view_count, like_count,
     comment_count, is_notice, is_hidden, is_deleted, created_at, updated_at)
    VALUES
    (seq_cafe_post.NEXTVAL, s.cafe_id, s.board_id, s.writer_id, s.title, s.content, s.view_count, s.like_count,
     s.comment_count, s.is_notice, 'N', 'N', s.created_at, SYSTIMESTAMP);

MERGE INTO cafe_comment cc
USING (
    SELECT p.post_id, 'user02' writer_id, '안내 확인했습니다. 거래 후기 남길 때 참고할게요.' content FROM cafe_post p WHERE p.title = '[공지] 동네장터 이용 안내'
    UNION ALL SELECT p.post_id, 'user03', '책 상태 괜찮으면 제가 받고 싶어요. 오늘 저녁 가능할까요?' FROM cafe_post p WHERE p.title = '안양역 근처 유아책 나눔합니다'
    UNION ALL SELECT p.post_id, 'user01', '거래 후기 감사합니다. 사진도 그대로라 믿음 가네요.' FROM cafe_post p WHERE p.title = '접이식 캠핑의자 거래 후기'
    UNION ALL SELECT p.post_id, 'aaa123', '마트 뒤쪽 문구점에서 박스 얻은 적 있어요.' FROM cafe_post p WHERE p.title = '만안구 이사박스 구할 곳 있을까요?'
    UNION ALL SELECT p.post_id, 'user03', '개인정보 주의 문구 좋아요. 공지 확인했습니다.' FROM cafe_post p WHERE p.title = '[공지] 육아정보방 글 작성 안내'
    UNION ALL SELECT p.post_id, 'user02', '저도 신청했어요. 주차는 도서관 지하가 편했습니다.' FROM cafe_post p WHERE p.title = '평촌 도서관 유아 프로그램 신청했어요'
    UNION ALL SELECT p.post_id, 'aaa123', '점심 직후 정보 감사합니다. 다음 진료 때 참고할게요.' FROM cafe_post p WHERE p.title = '범계 소아과 대기 적은 시간대 공유'
    UNION ALL SELECT p.post_id, 'user01', '낙성대 코스 참여하고 싶어요. 운동화만 챙기면 될까요?' FROM cafe_post p WHERE p.title = '토요일 낙성대 코스 같이 걸으실 분'
    UNION ALL SELECT p.post_id, 'user02', '지난주 코스 좋았어요. 다음엔 조금 일찍 출발해도 좋겠습니다.' FROM cafe_post p WHERE p.title = '지난주 둘레길 산책 후기'
    UNION ALL SELECT p.post_id, 'user01', '받침대 크기 알려주시면 확인하고 싶어요.' FROM cafe_post p WHERE p.title = '전자레인지 받침대 나눔합니다'
    UNION ALL SELECT p.post_id, 'user02', '순환팬 팁 좋네요. 창문 없는 방에도 도움 될 것 같아요.' FROM cafe_post p WHERE p.title = '자취방 습기 잡는 팁 공유해요'
    UNION ALL SELECT p.post_id, 'user03', '중앙공원 저녁 산책 괜찮더라고요. 배변봉투함도 있어요.' FROM cafe_post p WHERE p.title = '영통 중앙공원 산책 시간 추천'
    UNION ALL SELECT p.post_id, 'aaa123', '이동장을 평소에 열어두고 간식 넣어두면 조금 나아졌어요.' FROM cafe_post p WHERE p.title = '고양이 이동장 적응 어떻게 시키나요?'
    UNION ALL SELECT p.post_id, 'user03', '세미나 추천 감사합니다. 점심시간에 보기 딱 좋네요.' FROM cafe_post p WHERE p.title = '점심시간에 보기 좋은 기술 세미나 추천'
    UNION ALL SELECT p.post_id, 'user02', '판교역 북쪽보다 백현동 쪽이 조용한 곳이 많았어요.' FROM cafe_post p WHERE p.title = '판교역 근처 조용한 코딩 카페 있나요?'
) s
ON (cc.post_id = s.post_id AND cc.writer_id = s.writer_id AND cc.content = s.content)
WHEN MATCHED THEN UPDATE SET
    cc.is_deleted = 'N',
    cc.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (comment_id, post_id, writer_id, content, is_deleted, created_at, updated_at)
    VALUES
    (seq_cafe_comment.NEXTVAL, s.post_id, s.writer_id, s.content, 'N', SYSTIMESTAMP, SYSTIMESTAMP);

MERGE INTO cafe_post_like cpl
USING (
    SELECT p.post_id, 'user01' member_id FROM cafe_post p WHERE p.title IN ('[공지] 동네장터 이용 안내', '안양역 근처 유아책 나눔합니다', '평촌 도서관 유아 프로그램 신청했어요', '토요일 낙성대 코스 같이 걸으실 분', '영통 중앙공원 산책 시간 추천', '점심시간에 보기 좋은 기술 세미나 추천')
    UNION ALL SELECT p.post_id, 'user02' FROM cafe_post p WHERE p.title IN ('[공지] 동네장터 이용 안내', '접이식 캠핑의자 거래 후기', '[공지] 육아정보방 글 작성 안내', '지난주 둘레길 산책 후기', '전자레인지 받침대 나눔합니다', '판교역 근처 조용한 코딩 카페 있나요?')
    UNION ALL SELECT p.post_id, 'user03' FROM cafe_post p WHERE p.title IN ('안양역 근처 유아책 나눔합니다', '만안구 이사박스 구할 곳 있을까요?', '범계 소아과 대기 적은 시간대 공유', '[공지] 산책모임 안전 수칙', '자취방 습기 잡는 팁 공유해요', '고양이 이동장 적응 어떻게 시키나요?')
    UNION ALL SELECT p.post_id, 'aaa123' FROM cafe_post p WHERE p.title IN ('접이식 캠핑의자 거래 후기', '평촌 도서관 유아 프로그램 신청했어요', '토요일 낙성대 코스 같이 걸으실 분', '[공지] 나눔 물품 예약 규칙', '[공지] 반려생활 매너 안내', '[공지] 개발자 수다방 이용 안내')
) s
ON (cpl.post_id = s.post_id AND cpl.member_id = s.member_id)
WHEN NOT MATCHED THEN INSERT
    (like_id, post_id, member_id, created_at)
    VALUES
    (seq_cafe_post_like.NEXTVAL, s.post_id, s.member_id, SYSTIMESTAMP);

MERGE INTO cafe_favorite cf
USING (
    SELECT c.cafe_id, 'aaa123' member_id FROM cafe c WHERE c.cafe_name IN ('안양 만안 동네장터', '관악산 산책모임', '분당 판교 개발자 수다')
    UNION ALL SELECT c.cafe_id, 'user01' FROM cafe c WHERE c.cafe_name IN ('평촌 육아 정보방', '범계 자취살림 나눔방')
    UNION ALL SELECT c.cafe_id, 'user02' FROM cafe c WHERE c.cafe_name IN ('안양 만안 동네장터', '수원 영통 반려생활')
    UNION ALL SELECT c.cafe_id, 'user03' FROM cafe c WHERE c.cafe_name IN ('범계 자취살림 나눔방', '분당 판교 개발자 수다')
) s
ON (cf.cafe_id = s.cafe_id AND cf.member_id = s.member_id)
WHEN NOT MATCHED THEN INSERT
    (favorite_id, cafe_id, member_id, created_at)
    VALUES
    (seq_cafe_favorite.NEXTVAL, s.cafe_id, s.member_id, SYSTIMESTAMP);

--------------------------------------------------------
-- 10. 안양 맛집 공유 카페 전용 예시 데이터
--------------------------------------------------------

MERGE INTO cafe c
USING (
    SELECT '안양 맛집 공유 카페' cafe_name,
           '안양 동네 맛집, 방문 후기, 메뉴 추천을 이웃들과 편하게 나누는 카페입니다.' description,
           '경기도 안양시 만안구 안양동' region,
           '맛집' category,
           'PUBLIC' visibility,
           'DIRECT' join_type,
           'user01' owner_id,
           SYSTIMESTAMP - INTERVAL '2' HOUR last_active_at
    FROM dual
) s
ON (c.cafe_name = s.cafe_name)
WHEN MATCHED THEN UPDATE SET
    c.description = s.description,
    c.region = s.region,
    c.category = s.category,
    c.visibility = s.visibility,
    c.join_type = s.join_type,
    c.owner_id = NVL(c.owner_id, s.owner_id),
    c.status = 'ACTIVE',
    c.last_active_at = s.last_active_at,
    c.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (cafe_id, cafe_name, description, image_path, region, category, visibility, join_type,
     owner_id, status, member_count, post_count, view_count, last_active_at, created_at, updated_at)
    VALUES
    (seq_cafe.NEXTVAL, s.cafe_name, s.description, NULL, s.region, s.category, s.visibility, s.join_type,
     s.owner_id, 'ACTIVE', 0, 0, 240, s.last_active_at, SYSTIMESTAMP - INTERVAL '20' DAY, SYSTIMESTAMP);

MERGE INTO cafe_member cm
USING (
    SELECT cafe_id,
           member_id,
           CASE MIN(role_rank)
               WHEN 1 THEN 'OWNER'
               WHEN 2 THEN 'MANAGER'
               ELSE 'MEMBER'
           END role,
           'ACTIVE' status
    FROM (
        SELECT c.cafe_id, c.owner_id member_id, 1 role_rank
        FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
        UNION ALL SELECT c.cafe_id, 'user02', 2 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
        UNION ALL SELECT c.cafe_id, 'user03', 3 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
        UNION ALL SELECT c.cafe_id, 'aaa123', 3 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
        UNION ALL SELECT c.cafe_id, 'qwe123123', 3 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
        UNION ALL SELECT c.cafe_id, 'test0101', 3 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
        UNION ALL SELECT c.cafe_id, 'aaa1231', 3 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    )
    WHERE member_id IS NOT NULL
    GROUP BY cafe_id, member_id
) s
ON (cm.cafe_id = s.cafe_id AND cm.member_id = s.member_id)
WHEN MATCHED THEN UPDATE SET
    cm.role = s.role,
    cm.status = s.status,
    cm.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (cafe_member_id, cafe_id, member_id, role, status, joined_at, updated_at)
    VALUES
    (seq_cafe_member.NEXTVAL, s.cafe_id, s.member_id, s.role, s.status, SYSTIMESTAMP - INTERVAL '18' DAY, SYSTIMESTAMP);

UPDATE cafe_member cm
SET cm.role = 'MEMBER',
    cm.updated_at = SYSTIMESTAMP
WHERE cm.role = 'OWNER'
  AND EXISTS (
      SELECT 1
      FROM cafe c
      WHERE c.cafe_id = cm.cafe_id
        AND c.owner_id <> cm.member_id
  );

MERGE INTO cafe_board cb
USING (
    SELECT c.cafe_id, '공지사항' board_name, '카페 운영 안내와 공지를 확인해요' description, 'ALL' read_permission, 'MANAGER' write_permission, 'Y' is_notice, 1 display_order
    FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    UNION ALL SELECT c.cafe_id, '맛집추천', '안양 동네 맛집을 추천해요', 'ALL', 'MEMBER', 'N', 2 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    UNION ALL SELECT c.cafe_id, '방문후기', '직접 다녀온 후기를 남겨요', 'ALL', 'MEMBER', 'N', 3 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    UNION ALL SELECT c.cafe_id, '동네질문', '맛집과 메뉴를 물어봐요', 'ALL', 'MEMBER', 'N', 4 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    UNION ALL SELECT c.cafe_id, '메뉴추천', '오늘 먹기 좋은 메뉴를 추천해요', 'ALL', 'MEMBER', 'N', 5 FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
) s
ON (cb.cafe_id = s.cafe_id AND cb.board_name = s.board_name)
WHEN MATCHED THEN UPDATE SET
    cb.description = s.description,
    cb.read_permission = s.read_permission,
    cb.write_permission = s.write_permission,
    cb.is_notice = s.is_notice,
    cb.display_order = s.display_order,
    cb.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (board_id, cafe_id, board_name, description, read_permission, write_permission, is_notice,
     display_order, created_at, updated_at)
    VALUES
    (seq_cafe_board.NEXTVAL, s.cafe_id, s.board_name, s.description, s.read_permission, s.write_permission,
     s.is_notice, s.display_order, SYSTIMESTAMP, SYSTIMESTAMP);

MERGE INTO cafe_post cp
USING (
    WITH nums AS (
        SELECT LEVEL rn FROM dual CONNECT BY LEVEL <= 150
    ),
    base_seed AS (
        SELECT rn,
               CASE
                   WHEN rn = 1 THEN '안양'
                   WHEN MOD(rn - 2, 12) = 0 THEN '안양역'
                   WHEN MOD(rn - 2, 12) = 1 THEN '범계역'
                   WHEN MOD(rn - 2, 12) = 2 THEN '평촌역'
                   WHEN MOD(rn - 2, 12) = 3 THEN '명학역'
                   WHEN MOD(rn - 2, 12) = 4 THEN '관양동'
                   WHEN MOD(rn - 2, 12) = 5 THEN '비산동'
                   WHEN MOD(rn - 2, 12) = 6 THEN '호계동'
                   WHEN MOD(rn - 2, 12) = 7 THEN '석수동'
                   WHEN MOD(rn - 2, 12) = 8 THEN '박달동'
                   WHEN MOD(rn - 2, 12) = 9 THEN '안양중앙시장'
                   WHEN MOD(rn - 2, 12) = 10 THEN '인덕원'
                   ELSE '동편마을'
               END area_name,
               CASE
                   WHEN rn = 1 THEN 0
                   ELSE FLOOR((rn - 2) / 12)
               END theme_group
        FROM nums
    ),
    post_seed AS (
        SELECT rn,
               CASE
                   WHEN rn = 1 THEN '공지사항'
                   WHEN theme_group = 1 THEN '방문후기'
                   WHEN theme_group = 2 THEN '동네질문'
                   WHEN theme_group = 3 THEN '메뉴추천'
                   WHEN theme_group = 5 THEN '방문후기'
                   WHEN theme_group = 6 THEN '동네질문'
                   WHEN theme_group = 7 THEN '메뉴추천'
                   WHEN theme_group = 8 THEN '방문후기'
                   WHEN theme_group = 9 THEN '동네질문'
                   WHEN theme_group = 10 THEN '메뉴추천'
                   WHEN theme_group = 12 THEN '방문후기'
                   ELSE '맛집추천'
               END board_name,
               CASE MOD(rn, 7)
                   WHEN 0 THEN 'user01'
                   WHEN 1 THEN 'user02'
                   WHEN 2 THEN 'user03'
                   WHEN 3 THEN 'aaa123'
                   WHEN 4 THEN 'qwe123123'
                   WHEN 5 THEN 'test0101'
                   ELSE 'aaa1231'
               END writer_id,
               CASE
                   WHEN rn = 1 THEN '[공지] 안양 맛집 공유 카페 이용 안내'
                   WHEN theme_group = 0 THEN area_name || ' 혼밥하기 좋은 점심 맛집 추천'
                   WHEN theme_group = 1 THEN area_name || ' 주말 가족 외식 후기'
                   WHEN theme_group = 2 THEN area_name || ' 웨이팅 적은 저녁 식당 찾습니다'
                   WHEN theme_group = 3 THEN area_name || ' 포장해서 먹기 좋은 메뉴 추천'
                   WHEN theme_group = 4 THEN area_name || ' 비 오는 날 생각나는 따뜻한 한 끼'
                   WHEN theme_group = 5 THEN area_name || ' 점심특선 먹어본 후기'
                   WHEN theme_group = 6 THEN area_name || ' 단체 모임 가능한 식당 있을까요'
                   WHEN theme_group = 7 THEN area_name || ' 매콤한 메뉴 추천 모음'
                   WHEN theme_group = 8 THEN area_name || ' 오래 앉기 좋은 카페와 디저트'
                   WHEN theme_group = 9 THEN area_name || ' 아이랑 가기 좋은 식당 추천 부탁'
                   WHEN theme_group = 10 THEN area_name || ' 해장하기 좋은 든든한 메뉴 추천'
                   WHEN theme_group = 11 THEN area_name || ' 시장 근처 포장 맛집 정리'
                   ELSE area_name || ' 늦은 시간 문 여는 식당 후기'
               END title,
               CASE
                   WHEN rn = 1 THEN '가게 상호, 가격, 위치, 웨이팅, 주차 정보를 함께 적어주시면 이웃들이 더 편하게 참고할 수 있습니다.'
                   WHEN theme_group = 0 THEN area_name || ' 근처에서 혼자 먹기 부담 없는 점심집을 찾는 분들에게 도움이 되면 좋겠습니다. 가격대와 대기 시간을 같이 적어봤어요.'
                   WHEN theme_group = 1 THEN area_name || '에서 가족이랑 다녀온 곳입니다. 좌석 간격, 아이 동반, 주차 편의까지 기억나는 대로 남깁니다.'
                   WHEN theme_group = 2 THEN area_name || ' 주변에서 저녁에 오래 기다리지 않고 먹을 수 있는 곳을 찾고 있어요. 최근 다녀온 곳 있으면 추천 부탁드립니다.'
                   WHEN theme_group = 3 THEN area_name || '에서 포장해도 맛이 괜찮았던 메뉴를 공유합니다. 집에서 먹기 편한 구성인지도 같이 적었습니다.'
                   WHEN theme_group = 4 THEN area_name || ' 근처에서 비 오는 날 먹기 좋았던 따뜻한 메뉴를 모아봤습니다. 국물, 면, 찌개류 위주로 이야기 나눠요.'
                   WHEN theme_group = 5 THEN area_name || ' 점심특선을 먹어보고 가격, 양, 회전 속도 기준으로 정리했습니다. 직장인 점심으로 괜찮은지도 같이 남깁니다.'
                   WHEN theme_group = 6 THEN area_name || '에서 단체 모임하기 좋은 식당을 찾고 있습니다. 룸 여부, 예약 가능 여부, 주차 정보 아시는 분들 추천 부탁드려요.'
                   WHEN theme_group = 7 THEN area_name || ' 주변에서 매콤하게 먹기 좋은 메뉴를 모아봤습니다. 맵기 단계와 같이 먹으면 좋은 사이드도 적어주세요.'
                   WHEN theme_group = 8 THEN area_name || ' 근처에서 오래 앉기 편했던 카페와 디저트 가게를 공유합니다. 콘센트, 좌석 간격, 소음 정도도 함께 적었습니다.'
                   WHEN theme_group = 9 THEN area_name || '에서 아이와 함께 가기 좋은 식당을 찾고 있습니다. 유아 의자, 메뉴 구성, 대기 공간 정보가 있으면 알려주세요.'
                   WHEN theme_group = 10 THEN area_name || ' 주변에서 해장하기 좋거나 든든하게 먹기 좋은 메뉴를 추천합니다. 국물 맛과 양 기준으로 적어봤어요.'
                   WHEN theme_group = 11 THEN area_name || ' 시장 근처에서 포장해 오기 좋은 가게를 정리했습니다. 이동 시간 지나도 맛이 유지되는 메뉴 위주입니다.'
                   ELSE area_name || '에서 늦은 시간에도 문을 열어 편하게 들렀던 식당 후기입니다. 마감 시간과 주문 가능 메뉴를 같이 남깁니다.'
               END content,
               18 + rn * 4 view_count,
               CASE WHEN rn = 1 THEN 'Y' ELSE 'N' END is_notice,
               SYSTIMESTAMP - NUMTODSINTERVAL(61 - rn, 'HOUR') created_at
        FROM base_seed
    )
    SELECT c.cafe_id, b.board_id, ps.writer_id, ps.title, ps.content, ps.view_count, ps.is_notice, ps.created_at
    FROM post_seed ps
    JOIN cafe c ON c.cafe_name = '안양 맛집 공유 카페'
    JOIN cafe_board b ON b.cafe_id = c.cafe_id AND b.board_name = ps.board_name
) s
ON (cp.cafe_id = s.cafe_id AND cp.title = s.title)
WHEN MATCHED THEN UPDATE SET
    cp.board_id = s.board_id,
    cp.writer_id = s.writer_id,
    cp.content = s.content,
    cp.view_count = s.view_count,
    cp.is_notice = s.is_notice,
    cp.is_hidden = 'N',
    cp.is_deleted = 'N',
    cp.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (post_id, cafe_id, board_id, writer_id, title, content, view_count, like_count,
     comment_count, is_notice, is_hidden, is_deleted, created_at, updated_at)
    VALUES
    (seq_cafe_post.NEXTVAL, s.cafe_id, s.board_id, s.writer_id, s.title, s.content, s.view_count, 0,
     0, s.is_notice, 'N', 'N', s.created_at, SYSTIMESTAMP);

MERGE INTO cafe_comment cc
USING (
    SELECT p.post_id,
           CASE n.rn
               WHEN 1 THEN 'user02'
               ELSE 'qwe123123'
           END writer_id,
           CASE n.rn
               WHEN 1 THEN '정보 감사합니다. 위치랑 웨이팅까지 같이 있어서 참고하기 좋아요.'
               ELSE '저도 저장해둘게요. 다음에 다녀오면 후기 남겨보겠습니다.'
           END content
    FROM cafe_post p
    JOIN cafe c ON c.cafe_id = p.cafe_id AND c.cafe_name = '안양 맛집 공유 카페'
    CROSS JOIN (SELECT LEVEL rn FROM dual CONNECT BY LEVEL <= 2) n
    WHERE p.is_deleted = 'N'
) s
ON (cc.post_id = s.post_id AND cc.writer_id = s.writer_id AND cc.content = s.content)
WHEN MATCHED THEN UPDATE SET
    cc.is_deleted = 'N',
    cc.updated_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (comment_id, post_id, writer_id, content, is_deleted, created_at, updated_at)
    VALUES
    (seq_cafe_comment.NEXTVAL, s.post_id, s.writer_id, s.content, 'N', SYSTIMESTAMP, SYSTIMESTAMP);

MERGE INTO cafe_post_like cpl
USING (
    SELECT p.post_id, m.member_id
    FROM cafe_post p
    JOIN cafe c ON c.cafe_id = p.cafe_id AND c.cafe_name = '안양 맛집 공유 카페'
    JOIN (
        SELECT 'user01' member_id, 1 sort_order FROM dual
        UNION ALL SELECT 'user02', 2 FROM dual
        UNION ALL SELECT 'user03', 3 FROM dual
        UNION ALL SELECT 'aaa123', 4 FROM dual
        UNION ALL SELECT 'qwe123123', 5 FROM dual
    ) m ON MOD(p.post_id + m.sort_order, 3) <> 0
    WHERE p.is_deleted = 'N'
) s
ON (cpl.post_id = s.post_id AND cpl.member_id = s.member_id)
WHEN NOT MATCHED THEN INSERT
    (like_id, post_id, member_id, created_at)
    VALUES
    (seq_cafe_post_like.NEXTVAL, s.post_id, s.member_id, SYSTIMESTAMP);

MERGE INTO cafe_favorite cf
USING (
    SELECT c.cafe_id, 'user02' member_id FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    UNION ALL SELECT c.cafe_id, 'user03' FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    UNION ALL SELECT c.cafe_id, 'aaa123' FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    UNION ALL SELECT c.cafe_id, 'qwe123123' FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
    UNION ALL SELECT c.cafe_id, 'test0101' FROM cafe c WHERE c.cafe_name = '안양 맛집 공유 카페'
) s
ON (cf.cafe_id = s.cafe_id AND cf.member_id = s.member_id)
WHEN NOT MATCHED THEN INSERT
    (favorite_id, cafe_id, member_id, created_at)
    VALUES
    (seq_cafe_favorite.NEXTVAL, s.cafe_id, s.member_id, SYSTIMESTAMP);

UPDATE cafe c
SET member_count = (
        SELECT COUNT(*)
        FROM cafe_member cm
        WHERE cm.cafe_id = c.cafe_id
          AND cm.status = 'ACTIVE'
    ),
    post_count = (
        SELECT COUNT(*)
        FROM cafe_post cp
        WHERE cp.cafe_id = c.cafe_id
          AND cp.is_hidden = 'N'
          AND cp.is_deleted = 'N'
    ),
    updated_at = SYSTIMESTAMP
WHERE c.status = 'ACTIVE';

UPDATE cafe_post cp
SET comment_count = (
        SELECT COUNT(*)
        FROM cafe_comment cc
        WHERE cc.post_id = cp.post_id
          AND cc.is_deleted = 'N'
    ),
    like_count = (
        SELECT COUNT(*)
        FROM cafe_post_like cpl
        WHERE cpl.post_id = cp.post_id
    ),
    updated_at = SYSTIMESTAMP
WHERE cp.is_deleted = 'N';

COMMIT;
