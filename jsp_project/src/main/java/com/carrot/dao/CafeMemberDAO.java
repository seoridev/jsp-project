package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafeMemberDTO;

public class CafeMemberDAO extends BaseDAO {

    public boolean insertOwner(int cafeId, String ownerId) {
        return insertMember(cafeId, ownerId, "OWNER", "ACTIVE");
    }

    public String joinCafe(int cafeId, String memberId) {
        CafeMemberDTO current = selectCafeMember(cafeId, memberId);
        String status = getJoinStatus(cafeId);
        if (current != null) {
            String currentStatus = current.getStatus();
            if ("ACTIVE".equals(currentStatus)) {
                return "already";
            }
            if ("PENDING".equals(currentStatus)) {
                return "pending";
            }
            if ("BANNED".equals(currentStatus)) {
                return "banned";
            }
            if ("LEFT".equals(currentStatus) || "REJECTED".equals(currentStatus)) {
                return updateMemberStatus(cafeId, memberId, currentStatus, status) ? status.toLowerCase() : "fail";
            }
            return "fail";
        }
        return insertMember(cafeId, memberId, "MEMBER", status) ? status.toLowerCase() : "fail";
    }

    public boolean isActiveMember(int cafeId, String memberId) {
        CafeMemberDTO member = selectCafeMember(cafeId, memberId);
        return member != null && "ACTIVE".equals(member.getStatus());
    }

    public boolean isCafeManagerOrOwner(int cafeId, String memberId) {
        CafeMemberDTO member = selectCafeMember(cafeId, memberId);
        return member != null && "ACTIVE".equals(member.getStatus())
                && ("OWNER".equals(member.getRole()) || "MANAGER".equals(member.getRole()));
    }

    public CafeMemberDTO selectCafeMember(int cafeId, String memberId) {
        String sql = "SELECT cm.*, m.nickname, m.region "
                + "FROM cafe_member cm LEFT JOIN member m ON cm.member_id = m.login_id "
                + "WHERE cm.cafe_id = ? AND cm.member_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapMember(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<CafeMemberDTO> selectPendingMembers(int cafeId) {
        String sql = "SELECT cm.*, m.nickname, m.region "
                + "FROM cafe_member cm LEFT JOIN member m ON cm.member_id = m.login_id "
                + "WHERE cm.cafe_id = ? AND cm.status = 'PENDING' "
                + "ORDER BY cm.joined_at ASC";
        return selectMembersBySql(sql, cafeId);
    }

    public List<CafeMemberDTO> selectCafeMembers(int cafeId) {
        String sql = "SELECT cm.*, m.nickname, m.region "
                + "FROM cafe_member cm LEFT JOIN member m ON cm.member_id = m.login_id "
                + "WHERE cm.cafe_id = ? AND cm.status = 'ACTIVE' "
                + "ORDER BY CASE cm.role WHEN 'OWNER' THEN 1 WHEN 'MANAGER' THEN 2 ELSE 3 END, cm.joined_at ASC";
        return selectMembersBySql(sql, cafeId);
    }

    public boolean approveMember(int cafeId, String memberId) {
        String sql = "UPDATE cafe_member SET status = 'ACTIVE', updated_at = SYSTIMESTAMP "
                + "WHERE cafe_id = ? AND member_id = ? AND status = 'PENDING'";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, cafeId);
                pstmt.setString(2, memberId);
                boolean updated = pstmt.executeUpdate() > 0;
                if (!updated) {
                    conn.rollback();
                    return false;
                }
                updateMemberCount(conn, cafeId, 1);
                conn.commit();
                return true;
            }
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    public boolean rejectMember(int cafeId, String memberId) {
        String sql = "UPDATE cafe_member SET status = 'REJECTED', updated_at = SYSTIMESTAMP "
                + "WHERE cafe_id = ? AND member_id = ? AND status = 'PENDING'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, memberId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean leaveCafe(int cafeId, String memberId) {
        String sql = "UPDATE cafe_member SET status = 'LEFT', updated_at = SYSTIMESTAMP "
                + "WHERE cafe_id = ? AND member_id = ? AND status = 'ACTIVE' AND role IN ('MEMBER', 'MANAGER')";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, cafeId);
                pstmt.setString(2, memberId);
                boolean updated = pstmt.executeUpdate() > 0;
                if (!updated) {
                    conn.rollback();
                    return false;
                }
                updateMemberCount(conn, cafeId, -1);
                conn.commit();
                return true;
            }
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    private boolean insertMember(int cafeId, String memberId, String role, String status) {
        String sql = "INSERT INTO cafe_member "
                + "(cafe_member_id, cafe_id, member_id, role, status) "
                + "VALUES (seq_cafe_member.NEXTVAL, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, cafeId);
                pstmt.setString(2, memberId);
                pstmt.setString(3, role);
                pstmt.setString(4, status);
                boolean inserted = pstmt.executeUpdate() > 0;
                if (inserted && "ACTIVE".equals(status)) {
                    updateMemberCount(conn, cafeId, 1);
                }
                conn.commit();
                return inserted;
            }
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    private boolean updateMemberStatus(int cafeId, String memberId, String oldStatus, String status) {
        String sql = "UPDATE cafe_member SET status = ?, updated_at = SYSTIMESTAMP "
                + "WHERE cafe_id = ? AND member_id = ? AND status = ?";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, status);
                pstmt.setInt(2, cafeId);
                pstmt.setString(3, memberId);
                pstmt.setString(4, oldStatus);
                boolean updated = pstmt.executeUpdate() > 0;
                if (updated && !"ACTIVE".equals(oldStatus) && "ACTIVE".equals(status)) {
                    updateMemberCount(conn, cafeId, 1);
                }
                conn.commit();
                return updated;
            }
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    private String getJoinStatus(int cafeId) {
        String sql = "SELECT join_type FROM cafe WHERE cafe_id = ? AND status = 'ACTIVE'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return "APPROVAL".equals(rs.getString("join_type")) ? "PENDING" : "ACTIVE";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "PENDING";
    }

    private void updateMemberCount(Connection conn, int cafeId, int amount) throws Exception {
        String sql = "UPDATE cafe SET member_count = GREATEST(member_count + ?, 0) WHERE cafe_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, amount);
            pstmt.setInt(2, cafeId);
            pstmt.executeUpdate();
        }
    }

    private List<CafeMemberDTO> selectMembersBySql(String sql, int cafeId) {
        List<CafeMemberDTO> members = new ArrayList<>();
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
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

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (Exception ignored) {
            }
        }
    }

    private CafeMemberDTO mapMember(ResultSet rs) throws Exception {
        Timestamp joinedAt = rs.getTimestamp("joined_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        return CafeMemberDTO.builder()
                .cafeMemberId(rs.getInt("cafe_member_id"))
                .cafeId(rs.getInt("cafe_id"))
                .memberId(rs.getString("member_id"))
                .role(rs.getString("role"))
                .status(rs.getString("status"))
                .joinedAt(joinedAt == null ? null : joinedAt.toLocalDateTime())
                .updatedAt(updatedAt == null ? null : updatedAt.toLocalDateTime())
                .nickname(rs.getString("nickname"))
                .region(rs.getString("region"))
                .build();
    }
}
