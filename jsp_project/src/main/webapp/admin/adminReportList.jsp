<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="DAO.ReportDAO" %>
<%@ page import="DTO.ReportDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
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
%>
<%
    List<ReportDTO> reports = new ReportDAO().getReportList();
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>신고 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-report-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>신고 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/adminLogout.jsp">로그아웃</a>
        </div>
    </div>
    <% if ("success".equals(result)) { %>
        <script>
            (() => {
                alert("신고를 처리했습니다.");
                const url = new URL(window.location.href);
                url.searchParams.delete("result");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } else if ("fail".equals(result)) { %>
        <script>
            (() => {
                alert("신고 처리에 실패했습니다.");
                const url = new URL(window.location.href);
                url.searchParams.delete("result");
                window.history.replaceState({}, "", url);
            })();
        </script>
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
                <% if (reports == null || reports.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="8">등록된 신고가 없습니다.</td></tr>
                <% } else {
                    for (ReportDTO report : reports) {
                        boolean waiting = "WAITING".equalsIgnoreCase(report.getStatus());
                %>
                    <tr>
                        <td><%= report.getReportId() %></td>
                        <td><%= escapeHtml(report.getReporterId()) %></td>
                        <td>
                            <% if ("PRODUCT".equalsIgnoreCase(report.getTargetType())) { %>
                                <a class="table-link" href="<%= contextPath %>/product/productDetail.jsp?id=<%= report.getTargetId() %>">
                                    <%= escapeHtml(report.getProductTitle() == null ? "상품 #" + report.getTargetId() : report.getProductTitle()) %>
                                </a>
                            <% } else { %>
                                <%= escapeHtml(report.getTargetType()) %> #<%= report.getTargetId() %>
                            <% } %>
                        </td>
                        <td><%= escapeHtml(report.getReason()) %></td>
                        <td><%= escapeHtml(report.getDetail()) %></td>
                        <td><span class="status-badge<%= statusClass(report.getStatus()) %>"><%= statusText(report.getStatus()) %></span></td>
                        <td><%= report.getCreatedAt() == null ? "-" : dateFormat.format(report.getCreatedAt()) %></td>
                        <td>
                            <% if (waiting) { %>
                                <form class="inline-form" action="<%= contextPath %>/admin/adminReportProcess.jsp" method="post">
                                    <input type="hidden" name="reportId" value="<%= report.getReportId() %>">
                                    <input type="hidden" name="targetId" value="<%= report.getTargetId() %>">
                                    <button type="submit" name="action" value="done">완료</button>
                                    <% if ("PRODUCT".equalsIgnoreCase(report.getTargetType())) { %>
                                        <button type="submit" name="action" value="hide">숨김+완료</button>
                                    <% } %>
                                    <button type="submit" name="action" value="reject">반려</button>
                                </form>
                            <% } else { %>
                                처리됨
                            <% } %>
                        </td>
                    </tr>
                <%  }
                } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
