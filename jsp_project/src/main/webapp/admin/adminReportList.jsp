<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.ReportDAO" %>
<%@ page import="com.carrot.dto.ReportDTO" %>
<%@ page import="com.carrot.util.AdminPageUtil" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String searchType = request.getParameter("searchType") == null ? "product" : request.getParameter("searchType").trim();
    if (!AdminPageUtil.isProductReportSearchType(searchType)) {
        searchType = "product";
    }
    String keyword = request.getParameter("keyword") == null ? "" : request.getParameter("keyword").trim();
    String statusFilter = request.getParameter("status") == null ? "ALL" : request.getParameter("status").trim().toUpperCase();
    if (!AdminPageUtil.isProductReportStatus(statusFilter)) {
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
        <p class="notice-toast">신고를 처리했습니다.</p>
        <script>
            (() => {
                const url = new URL(window.location.href);
                url.searchParams.delete("result");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } else if ("fail".equals(result)) { %>
        <p class="notice-toast is-error">신고 처리에 실패했습니다.</p>
        <script>
            (() => {
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
                <option value="product" <%= AdminPageUtil.selected(searchType, "product") %>>상품명</option>
                <option value="reporter" <%= AdminPageUtil.selected(searchType, "reporter") %>>신고자</option>
            </select>
        </div>
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" type="search" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="검색어를 입력하세요">
        </div>
        <div class="field">
            <label for="status">상태</label>
            <select id="status" name="status">
                <option value="ALL" <%= AdminPageUtil.selected(statusFilter, "ALL") %>>전체</option>
                <option value="WAITING" <%= AdminPageUtil.selected(statusFilter, "WAITING") %>>대기</option>
                <option value="DONE" <%= AdminPageUtil.selected(statusFilter, "DONE") %>>처리완료</option>
                <option value="REJECTED" <%= AdminPageUtil.selected(statusFilter, "REJECTED") %>>반려</option>
            </select>
        </div>
        <button class="primary" type="submit">검색</button>
        <a class="button" href="<%= contextPath %>/admin/adminReportList.jsp">초기화</a>
    </form>
    <div class="admin-list-meta">
        <span>총 <strong><%= totalCount %></strong>건</span>
        <span><%= AdminPageUtil.reportStatusText(statusFilter) %></span>
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
                        <td><span class="status-badge<%= AdminPageUtil.reportStatusClass(report.getStatus()) %>"><%= AdminPageUtil.reportStatusText(report.getStatus()) %></span></td>
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
