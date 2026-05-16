package com.carrot.dao;

import com.carrot.dto.MemberDTO;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

//회원 가입, 로그인, 관리자 회원 관리 화면에서 쓰는 DB 작업을 모아 둔 DAO
public class MemberDAO extends BaseDAO {
    //관리자 대시보드에서 필요한 회원 수 요약값
    public static class MemberStats {
        private int totalCount;
        private int activeCount;
        private int stoppedCount;
        private int withdrawnCount;
        private int todayJoinCount;

        public int getTotalCount() {
            return totalCount;
        }

        public int getActiveCount() {
            return activeCount;
        }

        public int getStoppedCount() {
            return stoppedCount;
        }

        public int getWithdrawnCount() {
            return withdrawnCount;
        }

        public int getTodayJoinCount() {
            return todayJoinCount;
        }
    }

    //회원 가입 저장. status/created_at 컬럼이 없는 예전 테이블도 한 번 더 시도
    public boolean insertMember(MemberDTO member) throws SQLException {
        String sql = "INSERT INTO member "
            + "(login_id, password, nickname, phone, region, status, created_at) "
            + "VALUES (?, ?, ?, ?, ?, 'ACTIVE', SYSDATE)";

        try {
            return executeInsert(member, sql);
        } catch (SQLException e) {
            //ORA-00904: 컬럼이 없는 실습 DB에서도 가입이 되도록 기본 컬럼만 사용
            if (e.getErrorCode() == 904) {
                String simpleSql = "INSERT INTO member "
                    + "(login_id, password, nickname, phone, region) "
                    + "VALUES (?, ?, ?, ?, ?)";
                return executeInsert(member, simpleSql);
            }
            throw e;
        }
    }

    //로그인 검증. 계정 존재, 비밀번호, 회원 상태를 순서대로 확인
    public MemberDTO login(String loginId, String password) throws SQLException {
        MemberDTO member = getMemberByLoginId(loginId);

        if (member == null) {
            return null;
        }

        String hashedPassword = sha256(password);
        String savedPassword = member.getPassword();

        //이미 저장된 평문 비밀번호가 있어도 로그인은 가능하게 유지
        if (!hashedPassword.equals(savedPassword) && !password.equals(savedPassword)) {
            return null;
        }

        //관리자가 제한하거나 탈퇴 처리한 계정은 로그인 불가
        if (member.getStatus() != null && !"ACTIVE".equalsIgnoreCase(member.getStatus())) {
            return null;
        }

        return member;
    }

    //가입 전에 같은 아이디가 있는지 확인
    public boolean isDuplicateLoginId(String loginId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM member WHERE login_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, loginId);
            rs = pstmt.executeQuery();

            return rs.next() && rs.getInt(1) > 0;
        } finally {
            close(rs, pstmt, conn);
        }
    }

    //회원 상세와 로그인 검증에서 공통으로 쓰는 단건 조회
    public MemberDTO getMemberByLoginId(String loginId) throws SQLException {
        String sql = "SELECT login_id, password, nickname, phone, region, "
            + "profile_text, manner_score, status, created_at, updated_at "
            + "FROM member WHERE login_id = ?";

        try {
            return selectOne(sql, loginId);
        } catch (SQLException e) {
            //추가 프로필 컬럼이 없는 테이블이면 기본 회원 정보만 읽음
            if (e.getErrorCode() == 904) {
                String simpleSql = "SELECT login_id, password, nickname, phone, region "
                    + "FROM member WHERE login_id = ?";
                return selectOne(simpleSql, loginId);
            }
            throw e;
        }
    }

    //회원이 직접 수정하는 기본 프로필 정보 저장
    public boolean updateMember(MemberDTO member) throws SQLException {
        String sql = "UPDATE member SET nickname = ?, phone = ?, region = ?, "
            + "profile_text = ?, updated_at = SYSDATE WHERE login_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, member.getNickname());
            setNullableString(pstmt, 2, member.getPhone());
            pstmt.setString(3, member.getRegion());
            setNullableString(pstmt, 4, member.getProfileText());
            pstmt.setString(5, member.getLoginId());
            return pstmt.executeUpdate() > 0;
        } finally {
            close(pstmt, conn);
        }
    }

    //관리자 화면에서 회원 상태만 바꿀 때 사용
    public boolean updateMemberStatus(String loginId, String status) throws SQLException {
        String sql = "UPDATE member SET status = ?, updated_at = SYSDATE WHERE login_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setString(2, loginId);
            return pstmt.executeUpdate() > 0;
        } finally {
            close(pstmt, conn);
        }
    }

    //관리자용 전체 회원 목록. 새 컬럼이 없으면 기본 컬럼만 읽어서 목록을 유지
    public List<MemberDTO> getAllMembers() throws SQLException {
        String sql = "SELECT login_id, password, nickname, phone, region, "
            + "profile_text, manner_score, status, created_at, updated_at "
            + "FROM member ORDER BY created_at DESC";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<MemberDTO> members = new ArrayList<>();

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                members.add(mapMember(rs));
            }

            return members;
        } catch (SQLException e) {
            if (e.getErrorCode() != 904) {
                throw e;
            }

            //위 쿼리에서 실패한 리소스를 닫고, 단순 쿼리로 다시 조회
            close(rs, pstmt, conn);
            conn = null;
            pstmt = null;
            rs = null;

            String simpleSql = "SELECT login_id, password, nickname, phone, region FROM member ORDER BY login_id";
            conn = getConnection();
            pstmt = conn.prepareStatement(simpleSql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                members.add(mapMember(rs));
            }

            return members;
        } finally {
            close(rs, pstmt, conn);
        }
    }

    //관리자 메인 대시보드에 보여줄 회원 통계 계산
    public MemberStats getMemberStats() throws SQLException {
        String sql = "SELECT COUNT(*) AS total_count, "
            + "SUM(CASE WHEN status = 'ACTIVE' OR status IS NULL THEN 1 ELSE 0 END) AS active_count, "
            + "SUM(CASE WHEN status = 'STOPPED' THEN 1 ELSE 0 END) AS stopped_count, "
            + "SUM(CASE WHEN status = 'WITHDRAWN' THEN 1 ELSE 0 END) AS withdrawn_count, "
            + "SUM(CASE WHEN created_at >= TRUNC(SYSDATE) THEN 1 ELSE 0 END) AS today_join_count "
            + "FROM member";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            MemberStats stats = new MemberStats();
            if (rs.next()) {
                stats.totalCount = rs.getInt("total_count");
                stats.activeCount = rs.getInt("active_count");
                stats.stoppedCount = rs.getInt("stopped_count");
                stats.withdrawnCount = rs.getInt("withdrawn_count");
                stats.todayJoinCount = rs.getInt("today_join_count");
            }
            return stats;
        } catch (SQLException e) {
            if (e.getErrorCode() != 904) {
                throw e;
            }

            MemberStats stats = new MemberStats();
            List<MemberDTO> members = getAllMembers();
            stats.totalCount = members.size();
            //통계 컬럼을 못 쓰는 환경에서는 목록을 읽어 자바에서 직접 계산
            for (MemberDTO member : members) {
                String status = member.getStatus();
                if ("STOPPED".equalsIgnoreCase(status)) {
                    stats.stoppedCount++;
                } else if ("WITHDRAWN".equalsIgnoreCase(status)) {
                    stats.withdrawnCount++;
                } else {
                    stats.activeCount++;
                }
            }
            return stats;
        } finally {
            close(rs, pstmt, conn);
        }
    }

    //검색 조건에 맞는 전체 회원 수. 페이징 총 페이지 계산에 사용
    public int countMembers(String loginId, String nickname, String phone, String region, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM member");
        List<String> params = new ArrayList<>();
        appendMemberFilters(sql, params, loginId, nickname, phone, region, status);

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            bindStringParams(pstmt, params);
            rs = pstmt.executeQuery();

            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            close(rs, pstmt, conn);
        }
    }

    //회원 관리 목록 조회. 검색 조건과 페이징을 같은 쿼리에 묶어서 처리
    public List<MemberDTO> searchMembers(String loginId, String nickname, String phone, String region,
            String status, int page, int pageSize) throws SQLException {
        //화면에서 잘못된 page 값이 넘어와도 최소 1페이지로 보정
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        int offset = (safePage - 1) * safePageSize;

        StringBuilder sql = new StringBuilder(
            "SELECT login_id, password, nickname, phone, region, "
                + "profile_text, manner_score, status, created_at, updated_at FROM member"
        );
        List<String> params = new ArrayList<>();
        appendMemberFilters(sql, params, loginId, nickname, phone, region, status);
        sql.append(" ORDER BY created_at DESC NULLS LAST, login_id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<MemberDTO> members = new ArrayList<>();

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            int paramIndex = bindStringParams(pstmt, params);
            pstmt.setInt(paramIndex++, offset);
            pstmt.setInt(paramIndex, safePageSize);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                members.add(mapMember(rs));
            }

            return members;
        } finally {
            close(rs, pstmt, conn);
        }
    }

    //회원 저장 공통 처리. 비밀번호는 저장 직전에 해시로 변환
    private boolean executeInsert(MemberDTO member, String sql) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, member.getLoginId());
            pstmt.setString(2, sha256(member.getPassword()));
            pstmt.setString(3, member.getNickname());
            setNullableString(pstmt, 4, member.getPhone());
            pstmt.setString(5, member.getRegion());
            return pstmt.executeUpdate() > 0;
        } finally {
            close(pstmt, conn);
        }
    }

    //쿼리만 바꿔서 재사용할 수 있는 회원 단건 조회 헬퍼
    private MemberDTO selectOne(String sql, String loginId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, loginId);
            rs = pstmt.executeQuery();

            if (!rs.next()) {
                return null;
            }

            return mapMember(rs);
        } finally {
            close(rs, pstmt, conn);
        }
    }

    //ResultSet 한 줄을 화면/처리 로직에서 쓰는 DTO로 변환
    private MemberDTO mapMember(ResultSet rs) throws SQLException {
        MemberDTO member = new MemberDTO();
        member.setLoginId(rs.getString("login_id"));
        member.setPassword(rs.getString("password"));
        member.setNickname(rs.getString("nickname"));
        member.setPhone(getOptionalString(rs, "phone"));
        member.setRegion(rs.getString("region"));
        member.setProfileText(getOptionalString(rs, "profile_text"));
        member.setMannerScore(getOptionalDouble(rs, "manner_score"));
        member.setStatus(getOptionalString(rs, "status"));
        member.setCreatedAt(getOptionalTimestamp(rs, "created_at"));
        member.setUpdatedAt(getOptionalTimestamp(rs, "updated_at"));
        return member;
    }

    //검색 화면에서 넘어온 값만 WHERE 조건으로 붙임
    private void appendMemberFilters(StringBuilder sql, List<String> params, String loginId,
            String nickname, String phone, String region, String status) {
        List<String> conditions = new ArrayList<>();

        //ACTIVE는 예전 데이터처럼 status가 비어 있는 회원도 정상으로 본다
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            if ("ACTIVE".equalsIgnoreCase(status)) {
                conditions.add("(status = ? OR status IS NULL)");
            } else {
                conditions.add("status = ?");
            }
            params.add(status.trim().toUpperCase());
        }

        appendLikeFilter(conditions, params, "login_id", loginId);
        appendLikeFilter(conditions, params, "nickname", nickname);
        appendLikeFilter(conditions, params, "phone", phone);
        appendLikeFilter(conditions, params, "region", region);

        if (!conditions.isEmpty()) {
            sql.append(" WHERE ");
            for (int i = 0; i < conditions.size(); i++) {
                if (i > 0) {
                    sql.append(" AND ");
                }
                sql.append(conditions.get(i));
            }
        }
    }

    //부분 검색은 대소문자 차이를 줄이기 위해 LOWER + LIKE로 통일
    private void appendLikeFilter(List<String> conditions, List<String> params, String columnName, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        conditions.add("LOWER(" + columnName + ") LIKE ?");
        params.add("%" + value.trim().toLowerCase() + "%");
    }

    //문자열 검색 조건을 순서대로 바인딩하고 다음 인덱스를 돌려줌
    private int bindStringParams(PreparedStatement pstmt, List<String> params) throws SQLException {
        int index = 1;
        for (String param : params) {
            pstmt.setString(index++, param);
        }
        return index;
    }

    //회원 비밀번호 저장/비교에 쓰는 SHA-256 해시
    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (Exception e) {
            throw new IllegalStateException("비밀번호 암호화 중 문제가 발생했습니다.", e);
        }
    }

    //빈 문자열은 DB에 null로 넣어 검색/표시 처리를 단순하게 유지
    private void setNullableString(PreparedStatement pstmt, int index, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) {
            pstmt.setNull(index, java.sql.Types.VARCHAR);
        } else {
            pstmt.setString(index, value.trim());
        }
    }

    //환경마다 없는 컬럼이 있을 수 있어 선택 컬럼은 조용히 기본값 처리
    private String getOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException e) {
            return null;
        }
    }

    //선택 숫자 컬럼이 없으면 화면에서는 0으로 보여줌
    private double getOptionalDouble(ResultSet rs, String columnName) {
        try {
            return rs.getDouble(columnName);
        } catch (SQLException e) {
            return 0;
        }
    }

    //가입일/수정일 컬럼이 없는 테이블도 목록 조회가 깨지지 않게 처리
    private java.sql.Timestamp getOptionalTimestamp(ResultSet rs, String columnName) {
        try {
            return rs.getTimestamp(columnName);
        } catch (SQLException e) {
            return null;
        }
    }
}
