<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.ReportDAO" %>
<%@ page import="com.carrot.dto.ReportDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String statusText(String status) {
        if ("DONE".equalsIgnoreCase(status)) return "처리완료";
        if ("REJECTED".equalsIgnoreCase(status)) return "반려";
        return "대기";
    }

    private String statusClass(String status) {
        if ("DONE".equalsIgnoreCase(status)) return " is-active";
        if ("REJECTED".equalsIgnoreCase(status)) return " is-withdrawn";
        return " is-stopped";
    }

    private String targetText(String targetType) {
        if ("CAFE".equals(targetType)) return "카페";
        if ("CAFE_POST".equals(targetType)) return "게시글";
        if ("CAFE_COMMENT".equals(targetType)) return "댓글";
        return targetType;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    ReportDAO reportDao = new ReportDAO();
    String action = request.getParameter("action") == null ? "" : request.getParameter("action").trim();
    int reportId = parseIntParam(request.getParameter("reportId"));
    if (reportId > 0 && ("done".equals(action) || "reject".equals(action))) {
        boolean success = reportDao.processReport(reportId, "done".equals(action) ? "DONE" : "REJECTED");
        response.sendRedirect(request.getContextPath() + "/admin/communityReportManage.jsp?result=" + (success ? "success" : "fail"));
        return;
    }

    List<ReportDTO> reports = reportDao.getCommunityReportList();
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 신고 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-community-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>커뮤니티 신고 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/communityCafeManage.jsp">카페 관리</a>
            <a class="button" href="<%= contextPath %>/admin/communityPostManage.jsp">게시글 관리</a>
        </div>
    </div>
    <% if ("success".equals(result)) { %>
        <p class="field-message is-success">신고를 처리했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="field-message is-error">신고 처리에 실패했습니다.</p>
    <% } %>
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>번호</th>
                    <th>신고자</th>
                    <th>대상</th>
                    <th>사유</th>
                    <th>상세</th>
                    <th>상태</th>
                    <th>신고일</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (reports.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="8">커뮤니티 신고가 없습니다.</td></tr>
                <% } %>
                <% for (ReportDTO report : reports) {
                    boolean waiting = "WAITING".equalsIgnoreCase(report.getStatus());
                %>
                    <tr>
                        <td><%= report.getReportId() %></td>
                        <td><%= escapeHtml(report.getReporterId()) %></td>
                        <td><%= escapeHtml(targetText(report.getTargetType())) %> #<%= report.getTargetId() %></td>
                        <td><%= escapeHtml(report.getReason()) %></td>
                        <td><%= escapeHtml(report.getDetail()) %></td>
                        <td><span class="status-badge<%= statusClass(report.getStatus()) %>"><%= statusText(report.getStatus()) %></span></td>
                        <td><%= report.getCreatedAt() == null ? "-" : dateFormat.format(report.getCreatedAt()) %></td>
                        <td>
                            <% if (waiting) { %>
                                <form class="inline-form" action="<%= contextPath %>/admin/communityReportManage.jsp" method="post">
                                    <input type="hidden" name="reportId" value="<%= report.getReportId() %>">
                                    <button type="submit" name="action" value="done">완료</button>
                                    <button type="submit" name="action" value="reject">반려</button>
                                </form>
                            <% } else { %>
                                처리됨
                            <% } %>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
