package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.ReportDTO;

public class ReportDAO extends BaseDAO {
    public static class ProductReportFilter {
        private String searchType;
        private String keyword;
        private String status;

        public String getSearchType() {
            return searchType;
        }

        public void setSearchType(String searchType) {
            this.searchType = searchType;
        }

        public String getKeyword() {
            return keyword;
        }

        public void setKeyword(String keyword) {
            this.keyword = keyword;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }
    }

    public static class CommunityReportFilter {
        private String searchType;
        private String keyword;
        private String status;
        private String targetType;
        private String reason;
        private String reporterId;
        private String targetWriterId;
        private String dateFrom;
        private String dateTo;

        public String getSearchType() {
            return searchType;
        }

        public void setSearchType(String searchType) {
            this.searchType = searchType;
        }

        public String getKeyword() {
            return keyword;
        }

        public void setKeyword(String keyword) {
            this.keyword = keyword;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getTargetType() {
            return targetType;
        }

        public void setTargetType(String targetType) {
            this.targetType = targetType;
        }

        public String getReason() {
            return reason;
        }

        public void setReason(String reason) {
            this.reason = reason;
        }

        public String getReporterId() {
            return reporterId;
        }

        public void setReporterId(String reporterId) {
            this.reporterId = reporterId;
        }

        public String getTargetWriterId() {
            return targetWriterId;
        }

        public void setTargetWriterId(String targetWriterId) {
            this.targetWriterId = targetWriterId;
        }

        public String getDateFrom() {
            return dateFrom;
        }

        public void setDateFrom(String dateFrom) {
            this.dateFrom = dateFrom;
        }

        public String getDateTo() {
            return dateTo;
        }

        public void setDateTo(String dateTo) {
            this.dateTo = dateTo;
        }
    }

    public boolean insertReport(ReportDTO report) {
        try (Connection conn = getConnection()) {
            boolean useSequence = hasSequence(conn, "SEQ_REPORT");
            String sql = useSequence
                ? "INSERT INTO report "
                    + "(report_id, reporter_id, target_type, target_id, reason, detail, status, created_at) "
                    + "VALUES (seq_report.NEXTVAL, ?, ?, ?, ?, ?, 'WAITING', SYSTIMESTAMP)"
                : "INSERT INTO report "
                    + "(reporter_id, target_type, target_id, reason, detail, status, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, 'WAITING', SYSTIMESTAMP)";

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, report.getReporterId());
                pstmt.setString(2, report.getTargetType());
                pstmt.setInt(3, report.getTargetId());
                pstmt.setString(4, report.getReason());
                pstmt.setString(5, report.getDetail());
                return pstmt.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean existsReport(String reporterId, String targetType, int targetId) {
        String sql = "SELECT 1 FROM report "
            + "WHERE reporter_id = ? AND target_type = ? AND target_id = ? AND status = 'WAITING'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, reporterId);
            pstmt.setString(2, targetType);
            pstmt.setInt(3, targetId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private boolean hasSequence(Connection conn, String sequenceName) throws Exception {
        String sql = "SELECT COUNT(*) FROM user_sequences WHERE sequence_name = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sequenceName);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public List<ReportDTO> getReportList() {
        return getReportList(new ProductReportFilter());
    }

    public List<ReportDTO> getReportList(ProductReportFilter filter) {
        List<ReportDTO> reports = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT r.report_id, r.reporter_id, r.target_type, r.target_id, "
            + "r.reason, r.detail, r.status, r.created_at, r.processed_at, "
            + "m.nickname AS reporter_nickname, p.title AS product_title "
            + "FROM report r "
            + "LEFT JOIN member m ON r.reporter_id = m.login_id "
            + "LEFT JOIN product p ON r.target_type = 'PRODUCT' AND r.target_id = p.product_id "
            + "WHERE r.target_type NOT IN ('CAFE', 'CAFE_POST', 'CAFE_COMMENT') ");
        appendProductReportWhere(sql, params, filter);
        sql.append("ORDER BY CASE WHEN r.status = 'WAITING' THEN 0 ELSE 1 END, r.created_at DESC");

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            bindParams(pstmt, params);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reports.add(mapReport(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return reports;
    }

    public int countProductReports(ProductReportFilter filter) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM report r "
            + "LEFT JOIN product p ON r.target_type = 'PRODUCT' AND r.target_id = p.product_id "
            + "WHERE r.target_type NOT IN ('CAFE', 'CAFE_POST', 'CAFE_COMMENT') ");
        appendProductReportWhere(sql, params, filter);

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            bindParams(pstmt, params);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void appendProductReportWhere(StringBuilder sql, List<Object> params, ProductReportFilter filter) {
        String keyword = clean(filter == null ? null : filter.getKeyword());
        String searchType = clean(filter == null ? null : filter.getSearchType());
        if (keyword != null) {
            String value = "%" + keyword.toLowerCase() + "%";
            if ("REPORTER".equals(searchType)) {
                sql.append("AND LOWER(r.reporter_id) LIKE ? ");
                params.add(value);
            } else {
                sql.append("AND LOWER(p.title) LIKE ? ");
                params.add(value);
            }
        }

        String status = clean(filter == null ? null : filter.getStatus());
        if (isReportStatus(status)) {
            sql.append("AND r.status = ? ");
            params.add(status);
        }
    }

    public List<ReportDTO> getCommunityReportList() {
        return getCommunityReportList(new CommunityReportFilter(), 1, 10);
    }

    public List<ReportDTO> getCommunityReportList(CommunityReportFilter filter, int page, int pageSize) {
        List<ReportDTO> reports = new ArrayList<>();
        try (Connection conn = getConnection()) {
            List<Object> params = new ArrayList<>();
            String sql = "SELECT * FROM ("
                    + buildCommunityReportSelectSql(conn, filter, params)
                    + ") WHERE target_row_num = 1 "
                    + "ORDER BY CASE WHEN status = 'WAITING' THEN 0 ELSE 1 END, "
                    + "target_waiting_report_count DESC, created_at DESC "
                    + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                bindParams(pstmt, params);
                int safePage = Math.max(1, page);
                int safePageSize = Math.max(1, pageSize);
                pstmt.setInt(params.size() + 1, (safePage - 1) * safePageSize);
                pstmt.setInt(params.size() + 2, safePageSize);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        reports.add(mapReport(rs));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return reports;
    }

    public int countCommunityReports(CommunityReportFilter filter) {
        try (Connection conn = getConnection()) {
            List<Object> params = new ArrayList<>();
            String sql = "SELECT COUNT(*) FROM (SELECT r.target_type, r.target_id "
                    + communityReportFromWhereSql(filter, params)
                    + "GROUP BY r.target_type, r.target_id) grouped_reports";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                bindParams(pstmt, params);
                try (ResultSet rs = pstmt.executeQuery()) {
                    return rs.next() ? rs.getInt(1) : 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private String buildCommunityReportSelectSql(Connection conn, CommunityReportFilter filter, List<Object> params)
            throws Exception {
        boolean hasProcessColumns = hasReportModerationColumns(conn);
        String processColumns = hasProcessColumns
                ? "r.processed_by, r.action_type, r.admin_memo, "
                : "CAST(NULL AS VARCHAR2(50)) AS processed_by, CAST(NULL AS VARCHAR2(50)) AS action_type, CAST(NULL AS VARCHAR2(1000)) AS admin_memo, ";

        return "SELECT r.report_id, r.reporter_id, r.target_type, r.target_id, "
            + "r.reason, r.detail, r.status, r.created_at, r.processed_at, "
            + processColumns
            + "m.nickname AS reporter_nickname, CAST(NULL AS VARCHAR2(200)) AS product_title, "
            + "CASE "
            + "WHEN r.target_type = 'CAFE' THEN rc.cafe_name "
            + "WHEN r.target_type = 'CAFE_POST' THEN rp.title "
            + "WHEN r.target_type = 'CAFE_COMMENT' THEN SUBSTR(rcc.content, 1, 200) "
            + "END AS target_title, "
            + "CASE "
            + "WHEN r.target_type = 'CAFE' THEN DBMS_LOB.SUBSTR(rc.description, 300, 1) "
            + "WHEN r.target_type = 'CAFE_POST' THEN DBMS_LOB.SUBSTR(rp.content, 300, 1) "
            + "WHEN r.target_type = 'CAFE_COMMENT' THEN rcc.content "
            + "END AS target_content, "
            + "CASE "
            + "WHEN r.target_type = 'CAFE' THEN rc.owner_id "
            + "WHEN r.target_type = 'CAFE_POST' THEN rp.writer_id "
            + "WHEN r.target_type = 'CAFE_COMMENT' THEN rcc.writer_id "
            + "END AS target_writer_id, "
            + "CASE "
            + "WHEN r.target_type = 'CAFE' THEN rc.cafe_id "
            + "WHEN r.target_type = 'CAFE_POST' THEN rp.cafe_id "
            + "WHEN r.target_type = 'CAFE_COMMENT' THEN comment_post.cafe_id "
            + "ELSE 0 END AS target_cafe_id, "
            + "CASE "
            + "WHEN r.target_type = 'CAFE_POST' THEN rp.post_id "
            + "WHEN r.target_type = 'CAFE_COMMENT' THEN comment_post.post_id "
            + "ELSE 0 END AS target_post_id, "
            + "CASE "
            + "WHEN r.target_type = 'CAFE' THEN rc.cafe_name "
            + "WHEN r.target_type = 'CAFE_POST' THEN post_cafe.cafe_name "
            + "WHEN r.target_type = 'CAFE_COMMENT' THEN comment_cafe.cafe_name "
            + "END AS target_cafe_name, "
            + "(SELECT COUNT(*) FROM report rr WHERE rr.target_type = r.target_type "
            + "AND rr.target_id = r.target_id AND rr.status = 'WAITING') AS target_waiting_report_count, "
            + "(SELECT COUNT(*) FROM report rr WHERE rr.target_type = r.target_type "
            + "AND rr.target_id = r.target_id) AS target_total_report_count, "
            + "(SELECT LISTAGG(rr.reason || '/' || rr.reporter_id, ', ') WITHIN GROUP (ORDER BY rr.created_at DESC) "
            + "FROM report rr WHERE rr.target_type = r.target_type AND rr.target_id = r.target_id) AS target_recent_report_summary, "
            + "ROW_NUMBER() OVER (PARTITION BY r.target_type, r.target_id "
            + "ORDER BY CASE WHEN r.status = 'WAITING' THEN 0 ELSE 1 END, r.created_at DESC) AS target_row_num "
            + communityReportFromWhereSql(filter, params);
    }

    private String communityReportFromWhereSql(CommunityReportFilter filter, List<Object> params) {
        StringBuilder sql = new StringBuilder()
            .append("FROM report r ")
            .append("LEFT JOIN member m ON r.reporter_id = m.login_id ")
            .append("LEFT JOIN cafe rc ON r.target_type = 'CAFE' AND r.target_id = rc.cafe_id ")
            .append("LEFT JOIN cafe_post rp ON r.target_type = 'CAFE_POST' AND r.target_id = rp.post_id ")
            .append("LEFT JOIN cafe post_cafe ON rp.cafe_id = post_cafe.cafe_id ")
            .append("LEFT JOIN cafe_comment rcc ON r.target_type = 'CAFE_COMMENT' AND r.target_id = rcc.comment_id ")
            .append("LEFT JOIN cafe_post comment_post ON rcc.post_id = comment_post.post_id ")
            .append("LEFT JOIN cafe comment_cafe ON comment_post.cafe_id = comment_cafe.cafe_id ")
            .append("WHERE r.target_type IN ('CAFE', 'CAFE_POST', 'CAFE_COMMENT') ");

        String status = clean(filter == null ? null : filter.getStatus());
        if (isReportStatus(status)) {
            sql.append("AND r.status = ? ");
            params.add(status);
        }

        String targetType = clean(filter == null ? null : filter.getTargetType());
        if (isCommunityTarget(targetType)) {
            sql.append("AND r.target_type = ? ");
            params.add(targetType);
        }

        String keyword = clean(filter == null ? null : filter.getKeyword());
        if (keyword != null) {
            String searchType = clean(filter == null ? null : filter.getSearchType());
            String like = "%" + keyword.toLowerCase() + "%";
            if ("TARGET_WRITER".equals(searchType)) {
                sql.append("AND (")
                    .append("(r.target_type = 'CAFE' AND LOWER(rc.owner_id) LIKE ?) OR ")
                    .append("(r.target_type = 'CAFE_POST' AND LOWER(rp.writer_id) LIKE ?) OR ")
                    .append("(r.target_type = 'CAFE_COMMENT' AND LOWER(rcc.writer_id) LIKE ?)")
                    .append(") ");
                params.add(like);
                params.add(like);
                params.add(like);
            } else if ("TARGET_TITLE".equals(searchType)) {
                sql.append("AND (")
                    .append("(r.target_type = 'CAFE' AND LOWER(rc.cafe_name) LIKE ?) OR ")
                    .append("(r.target_type = 'CAFE_POST' AND LOWER(rp.title) LIKE ?) OR ")
                    .append("(r.target_type = 'CAFE_COMMENT' AND LOWER(rcc.content) LIKE ?)")
                    .append(") ");
                params.add(like);
                params.add(like);
                params.add(like);
            } else {
                sql.append("AND LOWER(r.reporter_id) LIKE ? ");
                params.add(like);
            }
        }

        String reason = clean(filter == null ? null : filter.getReason());
        if (isReportReason(reason)) {
            sql.append("AND r.reason = ? ");
            params.add(reason);
        }

        String reporterId = clean(filter == null ? null : filter.getReporterId());
        if (reporterId != null) {
            sql.append("AND LOWER(r.reporter_id) LIKE ? ");
            params.add("%" + reporterId.toLowerCase() + "%");
        }

        String targetWriterId = clean(filter == null ? null : filter.getTargetWriterId());
        if (targetWriterId != null) {
            sql.append("AND (")
                .append("(r.target_type = 'CAFE' AND LOWER(rc.owner_id) LIKE ?) OR ")
                .append("(r.target_type = 'CAFE_POST' AND LOWER(rp.writer_id) LIKE ?) OR ")
                .append("(r.target_type = 'CAFE_COMMENT' AND LOWER(rcc.writer_id) LIKE ?)")
                .append(") ");
            String like = "%" + targetWriterId.toLowerCase() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        String dateFrom = clean(filter == null ? null : filter.getDateFrom());
        if (dateFrom != null) {
            sql.append("AND r.created_at >= TO_TIMESTAMP(?, 'YYYY-MM-DD') ");
            params.add(dateFrom);
        }

        String dateTo = clean(filter == null ? null : filter.getDateTo());
        if (dateTo != null) {
            sql.append("AND r.created_at < TO_TIMESTAMP(?, 'YYYY-MM-DD') + INTERVAL '1' DAY ");
            params.add(dateTo);
        }

        return sql.toString();
    }

    public int countCommunityWaitingReports() {
        String sql = "SELECT COUNT(*) FROM report "
            + "WHERE status = 'WAITING' AND target_type IN ('CAFE', 'CAFE_POST', 'CAFE_COMMENT')";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public boolean processCommunityReport(int reportId, String actionType, String adminId, String adminMemo) {
        if (!"DONE".equals(actionType) && !"REJECT".equals(actionType)
                && !"HIDE_CAFE".equals(actionType) && !"HIDE_POST".equals(actionType)
                && !"HIDE_COMMENT".equals(actionType)) {
            return false;
        }

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            if (!hasReportModerationColumns(conn)) {
                conn.rollback();
                return false;
            }

            ReportTarget target = selectWaitingReportTarget(conn, reportId);
            if (target == null || !isCommunityTarget(target.targetType)) {
                conn.rollback();
                return false;
            }

            String status = "REJECT".equals(actionType) ? "REJECTED" : "DONE";
            boolean actionSuccess = true;
            if ("HIDE_CAFE".equals(actionType)) {
                actionSuccess = "CAFE".equals(target.targetType) && hideCafe(conn, target.targetId);
            } else if ("HIDE_POST".equals(actionType)) {
                actionSuccess = "CAFE_POST".equals(target.targetType) && hidePost(conn, target.targetId);
            } else if ("HIDE_COMMENT".equals(actionType)) {
                actionSuccess = "CAFE_COMMENT".equals(target.targetType) && hideComment(conn, target.targetId);
            }

            if (!actionSuccess || !updateRelatedReportProcess(conn, target, status, actionType, adminId, adminMemo)) {
                conn.rollback();
                return false;
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }

        return false;
    }

    public boolean processReport(int reportId, String status) {
        if (!"DONE".equals(status) && !"REJECTED".equals(status)) {
            return false;
        }
        String sql = "UPDATE report SET status = ?, processed_at = SYSTIMESTAMP "
            + "WHERE report_id = ? AND status = 'WAITING'";

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
        String reportSql = "UPDATE report SET status = 'DONE', processed_at = SYSTIMESTAMP "
            + "WHERE report_id = ? AND target_type = 'PRODUCT' AND target_id = ? AND status = 'WAITING'";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement hideStmt = conn.prepareStatement(hideSql);
                 PreparedStatement reportStmt = conn.prepareStatement(reportSql)) {
                hideStmt.setInt(1, productId);
                int hidden = hideStmt.executeUpdate();

                reportStmt.setInt(1, reportId);
                reportStmt.setInt(2, productId);
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
        String sql = "SELECT COUNT(*) FROM report "
            + "WHERE status = 'WAITING' AND target_type NOT IN ('CAFE', 'CAFE_POST', 'CAFE_COMMENT')";

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

    public boolean hasReportModerationColumns() {
        try (Connection conn = getConnection()) {
            return hasReportModerationColumns(conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean hasReportModerationColumns(Connection conn) throws Exception {
        return hasColumn(conn, "REPORT", "PROCESSED_BY")
                && hasColumn(conn, "REPORT", "ACTION_TYPE")
                && hasColumn(conn, "REPORT", "ADMIN_MEMO");
    }

    private void bindParams(PreparedStatement pstmt, List<?> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            pstmt.setObject(i + 1, params.get(i));
        }
    }

    private String clean(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() || "ALL".equalsIgnoreCase(trimmed) ? null : trimmed.toUpperCase();
    }

    private boolean isReportStatus(String status) {
        return "WAITING".equals(status) || "DONE".equals(status) || "REJECTED".equals(status);
    }

    private boolean isReportReason(String reason) {
        return "SPAM".equals(reason) || "ABUSE".equals(reason) || "FRAUD".equals(reason)
                || "SEXUAL".equals(reason) || "PRIVACY".equals(reason) || "ETC".equals(reason);
    }

    private ReportTarget selectWaitingReportTarget(Connection conn, int reportId) throws Exception {
        String sql = "SELECT target_type, target_id FROM report WHERE report_id = ? AND status = 'WAITING'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, reportId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new ReportTarget(rs.getString("target_type"), rs.getInt("target_id"));
                }
            }
        }
        return null;
    }

    private boolean isCommunityTarget(String targetType) {
        return "CAFE".equals(targetType) || "CAFE_POST".equals(targetType) || "CAFE_COMMENT".equals(targetType);
    }

    private boolean hideCafe(Connection conn, int cafeId) throws Exception {
        String sql = "UPDATE cafe SET status = 'HIDDEN', updated_at = SYSTIMESTAMP "
                + "WHERE cafe_id = ? AND status <> 'DELETED'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            return pstmt.executeUpdate() > 0;
        }
    }

    private boolean hidePost(Connection conn, int postId) throws Exception {
        Integer cafeId = null;
        String selectSql = "SELECT cafe_id, is_hidden, is_deleted FROM cafe_post WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(selectSql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next() || "Y".equals(rs.getString("is_deleted"))) {
                    return false;
                }
                cafeId = rs.getInt("cafe_id");
                if ("Y".equals(rs.getString("is_hidden"))) {
                    return true;
                }
            }
        }

        String updateSql = "UPDATE cafe_post SET is_hidden = 'Y', updated_at = SYSTIMESTAMP WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
            pstmt.setInt(1, postId);
            if (pstmt.executeUpdate() <= 0) {
                return false;
            }
        }

        String countSql = "UPDATE cafe SET post_count = GREATEST(post_count - 1, 0), last_active_at = SYSTIMESTAMP WHERE cafe_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(countSql)) {
            pstmt.setInt(1, cafeId);
            pstmt.executeUpdate();
        }
        return true;
    }

    private boolean hideComment(Connection conn, int commentId) throws Exception {
        Integer postId = null;
        String selectSql = "SELECT post_id, is_deleted FROM cafe_comment WHERE comment_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(selectSql)) {
            pstmt.setInt(1, commentId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                postId = rs.getInt("post_id");
                if ("Y".equals(rs.getString("is_deleted"))) {
                    return true;
                }
            }
        }

        String updateSql = "UPDATE cafe_comment SET is_deleted = 'Y', updated_at = SYSTIMESTAMP WHERE comment_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
            pstmt.setInt(1, commentId);
            if (pstmt.executeUpdate() <= 0) {
                return false;
            }
        }

        String countSql = "UPDATE cafe_post SET comment_count = GREATEST(comment_count - 1, 0) WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(countSql)) {
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();
        }
        return true;
    }

    private boolean updateRelatedReportProcess(Connection conn, ReportTarget target, String status, String actionType,
            String adminId, String adminMemo) throws Exception {
        String memo = adminMemo == null ? "" : adminMemo.trim();
        if (memo.length() > 1000) {
            memo = memo.substring(0, 1000);
        }

        String sql = "UPDATE report SET status = ?, processed_at = SYSTIMESTAMP, "
                + "processed_by = ?, action_type = ?, admin_memo = ? "
                + "WHERE target_type = ? AND target_id = ? AND status = 'WAITING'";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setString(2, adminId);
            pstmt.setString(3, actionType);
            pstmt.setString(4, memo);
            pstmt.setString(5, target.targetType);
            pstmt.setInt(6, target.targetId);
            return pstmt.executeUpdate() > 0;
        }
    }

    private boolean hasColumn(Connection conn, String tableName, String columnName) throws Exception {
        String sql = "SELECT COUNT(*) FROM user_tab_columns WHERE table_name = ? AND column_name = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, tableName);
            pstmt.setString(2, columnName);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
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
            .processedBy(getOptionalString(rs, "processed_by"))
            .actionType(getOptionalString(rs, "action_type"))
            .adminMemo(getOptionalString(rs, "admin_memo"))
            .reporterNickname(rs.getString("reporter_nickname"))
            .productTitle(getOptionalString(rs, "product_title"))
            .targetTitle(getOptionalString(rs, "target_title"))
            .targetContent(getOptionalString(rs, "target_content"))
            .targetWriterId(getOptionalString(rs, "target_writer_id"))
            .targetPostId(getOptionalInt(rs, "target_post_id"))
            .targetCafeId(getOptionalInt(rs, "target_cafe_id"))
            .targetCafeName(getOptionalString(rs, "target_cafe_name"))
            .targetWaitingReportCount(getOptionalInt(rs, "target_waiting_report_count"))
            .targetTotalReportCount(getOptionalInt(rs, "target_total_report_count"))
            .targetRecentReportSummary(getOptionalString(rs, "target_recent_report_summary"))
            .build();
    }

    private String getOptionalString(ResultSet rs, String columnName) throws SQLException {
        try {
            return rs.getString(columnName);
        } catch (SQLException e) {
            return null;
        }
    }

    private int getOptionalInt(ResultSet rs, String columnName) throws SQLException {
        try {
            return rs.getInt(columnName);
        } catch (SQLException e) {
            return 0;
        }
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

    private static class ReportTarget {
        private final String targetType;
        private final int targetId;

        private ReportTarget(String targetType, int targetId) {
            this.targetType = targetType;
            this.targetId = targetId;
        }
    }
}
