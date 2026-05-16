package com.carrot.dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.MemberDTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// 회원 가입, 로그인, 관리자 회원 관리 DAO
public class MemberDAO extends BaseDAO {
    // 관리자 회원 통계 DTO
    @Builder
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MemberStats {
        private int totalCount;
        private int activeCount;
        private int stoppedCount;
        private int withdrawnCount;
        private int todayJoinCount;
    }

    // ===== 회원 화면 기능 =====

    // 회원 가입
    public boolean insertMember(MemberDTO member) throws SQLException {
        String sql = "INSERT INTO member "
            + "(login_id, password, nickname, phone, region, status, created_at) "
            + "VALUES (?, ?, ?, ?, ?, 'ACTIVE', SYSDATE)";

        try {
            return executeInsert(member, sql);
        } catch (SQLException e) {
            if (e.getErrorCode() == 904) {
                return insertMemberWithBaseColumns(member);
            }
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 회원 로그인
    public MemberDTO login(String loginId, String password) throws SQLException {
        MemberDTO member = getMemberByLoginId(loginId);

        if (member == null) {
            return null;
        }

        String hashedPassword = sha256(password);
        String savedPassword = member.getPassword();

        if (!hashedPassword.equals(savedPassword) && !password.equals(savedPassword)) {
            return null;
        }

        if (member.getStatus() != null && !"ACTIVE".equalsIgnoreCase(member.getStatus())) {
            return null;
        }

        return member;
    }

    // 아이디 중복 확인
    public boolean isDuplicateLoginId(String loginId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM member WHERE login_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, loginId);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 회원 아이디로 조회
    public MemberDTO getMemberByLoginId(String loginId) {
        String sql = "SELECT login_id, password, nickname, phone, region, "
            + "profile_text, manner_score, status, created_at, updated_at "
            + "FROM member WHERE login_id = ?";

        try {
            return selectOne(sql, loginId);
        } catch (SQLException e) {
            if (e.getErrorCode() == 904) {
                return getMemberByLoginIdWithBaseColumns(loginId);
            }
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 회원 정보 수정
    public boolean updateMember(MemberDTO member) {
        String sql = "UPDATE member SET nickname = ?, phone = ?, region = ?, "
            + "profile_text = ?, updated_at = SYSDATE WHERE login_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, member.getNickname());
            setNullableString(pstmt, 2, member.getPhone());
            pstmt.setString(3, member.getRegion());
            setNullableString(pstmt, 4, member.getProfileText());
            pstmt.setString(5, member.getLoginId());
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ===== 관리자 화면 기능 =====

    // 회원 상태 변경
    public boolean updateMemberStatus(String loginId, String status) {
        String sql = "UPDATE member SET status = ?, updated_at = SYSDATE WHERE login_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setString(2, loginId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 전체 회원 목록 조회
    public List<MemberDTO> getAllMembers() {
        List<MemberDTO> members = new ArrayList<>();
        String sql = "SELECT login_id, password, nickname, phone, region, "
            + "profile_text, manner_score, status, created_at, updated_at "
            + "FROM member ORDER BY created_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                members.add(mapMember(rs));
            }
            return members;
        } catch (SQLException e) {
            if (e.getErrorCode() != 904) {
                e.printStackTrace();
                return members;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return members;
        }

        return getAllMembersWithBaseColumns();
    }

    // 회원 통계 조회
    public MemberStats getMemberStats() {
        String sql = "SELECT COUNT(*) AS total_count, "
            + "SUM(CASE WHEN status = 'ACTIVE' OR status IS NULL THEN 1 ELSE 0 END) AS active_count, "
            + "SUM(CASE WHEN status = 'STOPPED' THEN 1 ELSE 0 END) AS stopped_count, "
            + "SUM(CASE WHEN status = 'WITHDRAWN' THEN 1 ELSE 0 END) AS withdrawn_count, "
            + "SUM(CASE WHEN created_at >= TRUNC(SYSDATE) THEN 1 ELSE 0 END) AS today_join_count "
            + "FROM member";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return MemberStats.builder()
                    .totalCount(rs.getInt("total_count"))
                    .activeCount(rs.getInt("active_count"))
                    .stoppedCount(rs.getInt("stopped_count"))
                    .withdrawnCount(rs.getInt("withdrawn_count"))
                    .todayJoinCount(rs.getInt("today_join_count"))
                    .build();
            }
            return MemberStats.builder().build();
        } catch (SQLException e) {
            if (e.getErrorCode() != 904) {
                e.printStackTrace();
                return MemberStats.builder().build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return MemberStats.builder().build();
        }

        return calculateMemberStatsInJava();
    }

    // 회원 수 조회
    public int countMembers(String loginId, String nickname, String phone, String region, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM member");
        List<String> params = new ArrayList<>();
        appendMemberFilters(sql, params, loginId, nickname, phone, region, status);

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            bindStringParams(pstmt, params);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    // 회원 검색 목록 조회
    public List<MemberDTO> searchMembers(String loginId, String nickname, String phone, String region,
            String status, int page, int pageSize) {
        List<MemberDTO> members = new ArrayList<>();
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

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            int paramIndex = bindStringParams(pstmt, params);
            pstmt.setInt(paramIndex++, offset);
            pstmt.setInt(paramIndex, safePageSize);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    members.add(mapMember(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return members;
    }

    // ===== 호환 처리 =====

    // 기본 컬럼만 있는 회원 테이블에 저장
    private boolean insertMemberWithBaseColumns(MemberDTO member) throws SQLException {
        String sql = "INSERT INTO member "
            + "(login_id, password, nickname, phone, region) "
            + "VALUES (?, ?, ?, ?, ?)";

        try {
            return executeInsert(member, sql);
        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 기본 컬럼만 있는 회원 테이블에서 조회
    private MemberDTO getMemberByLoginIdWithBaseColumns(String loginId) {
        String sql = "SELECT login_id, password, nickname, phone, region "
            + "FROM member WHERE login_id = ?";

        try {
            return selectOne(sql, loginId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 기본 컬럼만 있는 회원 테이블 목록 조회
    private List<MemberDTO> getAllMembersWithBaseColumns() {
        List<MemberDTO> members = new ArrayList<>();
        String sql = "SELECT login_id, password, nickname, phone, region FROM member ORDER BY login_id";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                members.add(mapMember(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return members;
    }

    // 목록 데이터로 회원 통계 계산
    private MemberStats calculateMemberStatsInJava() {
        MemberStats stats = MemberStats.builder().build();
        List<MemberDTO> members = getAllMembers();
        stats.setTotalCount(members.size());

        for (MemberDTO member : members) {
            String status = member.getStatus();
            if ("STOPPED".equalsIgnoreCase(status)) {
                stats.setStoppedCount(stats.getStoppedCount() + 1);
            } else if ("WITHDRAWN".equalsIgnoreCase(status)) {
                stats.setWithdrawnCount(stats.getWithdrawnCount() + 1);
            } else {
                stats.setActiveCount(stats.getActiveCount() + 1);
            }
        }

        return stats;
    }

    // ===== 공통 조회/매핑 =====

    // 회원 저장 공통 처리
    private boolean executeInsert(MemberDTO member, String sql) throws Exception {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, member.getLoginId());
            pstmt.setString(2, sha256(member.getPassword()));
            pstmt.setString(3, member.getNickname());
            setNullableString(pstmt, 4, member.getPhone());
            pstmt.setString(5, member.getRegion());
            return pstmt.executeUpdate() > 0;
        }
    }

    // 회원 단건 조회 공통 처리
    private MemberDTO selectOne(String sql, String loginId) throws Exception {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, loginId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                return mapMember(rs);
            }
        }
    }

    // 회원 DTO 변환
    private MemberDTO mapMember(ResultSet rs) throws SQLException {
        return MemberDTO.builder()
            .loginId(rs.getString("login_id"))
            .password(rs.getString("password"))
            .nickname(rs.getString("nickname"))
            .phone(getOptionalString(rs, "phone"))
            .region(rs.getString("region"))
            .profileText(getOptionalString(rs, "profile_text"))
            .mannerScore(getOptionalDouble(rs, "manner_score"))
            .status(getOptionalString(rs, "status"))
            .createdAt(getOptionalTimestamp(rs, "created_at"))
            .updatedAt(getOptionalTimestamp(rs, "updated_at"))
            .build();
    }

    // 회원 검색 조건 추가
    private void appendMemberFilters(StringBuilder sql, List<String> params, String loginId,
            String nickname, String phone, String region, String status) {
        List<String> conditions = new ArrayList<>();

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

    // LIKE 검색 조건 추가
    private void appendLikeFilter(List<String> conditions, List<String> params, String columnName, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        conditions.add("LOWER(" + columnName + ") LIKE ?");
        params.add("%" + value.trim().toLowerCase() + "%");
    }

    // 문자열 파라미터 바인딩
    private int bindStringParams(PreparedStatement pstmt, List<String> params) throws SQLException {
        int index = 1;
        for (String param : params) {
            pstmt.setString(index++, param);
        }
        return index;
    }

    // ===== 공통 유틸 =====

    // 비밀번호 해시 처리
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

    // 빈 문자열 NULL 처리
    private void setNullableString(PreparedStatement pstmt, int index, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) {
            pstmt.setNull(index, java.sql.Types.VARCHAR);
        } else {
            pstmt.setString(index, value.trim());
        }
    }

    // 선택 문자열 컬럼 조회
    private String getOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException e) {
            return null;
        }
    }

    // 선택 숫자 컬럼 조회
    private double getOptionalDouble(ResultSet rs, String columnName) {
        try {
            return rs.getDouble(columnName);
        } catch (SQLException e) {
            return 0;
        }
    }

    // 선택 날짜 컬럼 조회
    private Timestamp getOptionalTimestamp(ResultSet rs, String columnName) {
        try {
            return rs.getTimestamp(columnName);
        } catch (SQLException e) {
            return null;
        }
    }
}
