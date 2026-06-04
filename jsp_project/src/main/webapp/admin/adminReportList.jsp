<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.ReportDAO" %>
<%@ page import="com.carrot.dto.ReportDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
    private String statusText(String status) {
        if ("ALL".equalsIgnoreCase(status)) return "전체";
        if ("DONE".equalsIgnoreCase(status)) return "처리완료";
        if ("REJECTED".equalsIgnoreCase(status)) return "반려";
        return "대기";
    }

    private String statusClass(String status) {
        if ("DONE".equalsIgnoreCase(status)) return " is-active";
        if ("REJECTED".equalsIgnoreCase(status)) return " is-withdrawn";
        return " is-stopped";
    }

    private String selected(String current, String expected) {
        return expected.equalsIgnoreCase(current) ? "selected" : "";
    }

    private boolean isAllowedSearchType(String searchType) {
        return "product".equals(searchType) || "reporter".equals(searchType);
    }

    private boolean isAllowedStatus(String status) {
        return "ALL".equals(status) || "WAITING".equals(status) || "DONE".equals(status) || "REJECTED".equals(status);
    }

    private String encodeParam(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    private String buildListQuery(String searchType, String keyword, String status) {
        return "searchType=" + encodeParam(searchType)
            + "&keyword=" + encodeParam(keyword)
            + "&status=" + encodeParam(status);
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String searchType = request.getParameter("searchType") == null ? "product" : request.getParameter("searchType").trim();
    if (!isAllowedSearchType(searchType)) {
        searchType = "product";
    }
    String keyword = request.getParameter("keyword") == null ? "" : request.getParameter("keyword").trim();
    String statusFilter = request.getParameter("status") == null ? "ALL" : request.getParameter("status").trim().toUpperCase();
    if (!isAllowedStatus(statusFilter)) {
        statusFilter = "ALL";
    }

    ReportDAO.ProductReportFilter filter = new ReportDAO.ProductReportFilter();
    filter.setSearchType(searchType);
    filter.setKeyword(keyword);
    filter.setStatus(statusFilter);

    ReportDAO reportDao = new ReportDAO();
    List<ReportDTO> reports = reportDao.getReportList(filter);
    int totalCount = reportDao.countProductReports(filter);
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>신고 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-report-2">
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
    <form class="admin-filter" action="<%= contextPath %>/admin/adminReportList.jsp" method="get">
        <div class="field">
            <label for="searchType">검색 기준</label>
            <select id="searchType" name="searchType">
                <option value="product" <%= selected(searchType, "product") %>>상품명</option>
                <option value="reporter" <%= selected(searchType, "reporter") %>>신고자</option>
            </select>
        </div>
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" type="search" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="검색어를 입력하세요">
        </div>
        <div class="field">
            <label for="status">상태</label>
            <select id="status" name="status">
                <option value="ALL" <%= selected(statusFilter, "ALL") %>>전체</option>
                <option value="WAITING" <%= selected(statusFilter, "WAITING") %>>대기</option>
                <option value="DONE" <%= selected(statusFilter, "DONE") %>>처리완료</option>
                <option value="REJECTED" <%= selected(statusFilter, "REJECTED") %>>반려</option>
            </select>
        </div>
        <button class="primary" type="submit">검색</button>
        <a class="button" href="<%= contextPath %>/admin/adminReportList.jsp">초기화</a>
    </form>
    <div class="admin-list-meta">
        <span>총 <strong><%= totalCount %></strong>건</span>
        <span><%= statusText(statusFilter) %></span>
    </div>
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
                    <tr><td class="empty-cell" colspan="8">조건에 맞는 신고가 없습니다.</td></tr>
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
                                    <input type="hidden" name="searchType" value="<%= escapeHtml(searchType) %>">
                                    <input type="hidden" name="keyword" value="<%= escapeHtml(keyword) %>">
                                    <input type="hidden" name="statusFilter" value="<%= escapeHtml(statusFilter) %>">
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
