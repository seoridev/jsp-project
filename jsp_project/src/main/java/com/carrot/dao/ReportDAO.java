package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.ReportDTO;

public class ReportDAO extends BaseDAO {

    public boolean insertReport(ReportDTO report) {
        String sql = "INSERT INTO report "
            + "(reporter_id, target_type, target_id, reason, detail, status, created_at) "
            + "VALUES (?, ?, ?, ?, ?, 'WAITING', SYSTIMESTAMP)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, report.getReporterId());
            pstmt.setString(2, report.getTargetType());
            pstmt.setInt(3, report.getTargetId());
            pstmt.setString(4, report.getReason());
            pstmt.setString(5, report.getDetail());
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<ReportDTO> getReportList() {
        List<ReportDTO> reports = new ArrayList<>();
        String sql = "SELECT r.report_id, r.reporter_id, r.target_type, r.target_id, "
            + "r.reason, r.detail, r.status, r.created_at, r.processed_at, "
            + "m.nickname AS reporter_nickname, p.title AS product_title "
            + "FROM report r "
            + "LEFT JOIN member m ON r.reporter_id = m.login_id "
            + "LEFT JOIN product p ON r.target_type = 'PRODUCT' AND r.target_id = p.product_id "
            + "ORDER BY CASE WHEN r.status = 'WAITING' THEN 0 ELSE 1 END, r.created_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                reports.add(mapReport(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return reports;
    }

    public List<ReportDTO> getCommunityReportList() {
        List<ReportDTO> reports = new ArrayList<>();
        String sql = "SELECT r.report_id, r.reporter_id, r.target_type, r.target_id, "
            + "r.reason, r.detail, r.status, r.created_at, r.processed_at, "
            + "m.nickname AS reporter_nickname, CAST(NULL AS VARCHAR2(200)) AS product_title "
            + "FROM report r "
            + "LEFT JOIN member m ON r.reporter_id = m.login_id "
            + "WHERE r.target_type IN ('CAFE', 'CAFE_POST', 'CAFE_COMMENT') "
            + "ORDER BY CASE WHEN r.status = 'WAITING' THEN 0 ELSE 1 END, r.created_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                reports.add(mapReport(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return reports;
    }

    public boolean processReport(int reportId, String status) {
        String sql = "UPDATE report SET status = ?, processed_at = SYSTIMESTAMP WHERE report_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, reportId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean processReportAndHideProduct(int reportId, int productId) {
        String hideSql = "UPDATE product SET status = 'HIDDEN', updated_at = SYSTIMESTAMP WHERE product_id = ?";
        String reportSql = "UPDATE report SET status = 'DONE', processed_at = SYSTIMESTAMP WHERE report_id = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement hideStmt = conn.prepareStatement(hideSql);
                 PreparedStatement reportStmt = conn.prepareStatement(reportSql)) {
                hideStmt.setInt(1, productId);
                int hidden = hideStmt.executeUpdate();

                reportStmt.setInt(1, reportId);
                int processed = reportStmt.executeUpdate();

                if (hidden > 0 && processed > 0) {
                    conn.commit();
                    return true;
                }
                conn.rollback();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public int countWaitingReports() {
        String sql = "SELECT COUNT(*) FROM report WHERE status = 'WAITING'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    private ReportDTO mapReport(ResultSet rs) throws Exception {
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp processedAt = rs.getTimestamp("processed_at");

        return ReportDTO.builder()
            .reportId(rs.getInt("report_id"))
            .reporterId(rs.getString("reporter_id"))
            .targetType(rs.getString("target_type"))
            .targetId(rs.getInt("target_id"))
            .reason(rs.getString("reason"))
            .detail(rs.getString("detail"))
            .status(rs.getString("status"))
            .createdAt(createdAt)
            .processedAt(processedAt)
            .reporterNickname(rs.getString("reporter_nickname"))
            .productTitle(rs.getString("product_title"))
            .build();
    }
}
