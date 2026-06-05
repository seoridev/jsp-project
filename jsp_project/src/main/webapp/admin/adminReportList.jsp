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
    <title>상품 신고 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-report-3">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>상품 신고 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/adminLogout.jsp">로그아웃</a>
        </div>
    </div>
    <% if ("success".equals(result)) { %>
        <p class="notice-toast">신고를 처리했습니다. 같은 상품의 대기 신고가 함께 처리되었습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="notice-toast is-error">신고 처리에 실패했습니다.</p>
    <% } %>

    <form class="admin-filter admin-report-filter" action="<%= contextPath %>/admin/adminReportList.jsp" method="get">
        <div class="field">
            <label for="searchType">검색 기준</label>
            <select id="searchType" name="searchType">
                <option value="product" <%= AdminPageUtil.selected(searchType, "product") %>>상품명</option>
                <option value="reporter" <%= AdminPageUtil.selected(searchType, "reporter") %>>신고자</option>
            </select>
        </div>
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" type="search" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="검색어">
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
        <div class="form-actions">
            <button class="primary" type="submit">검색</button>
            <a class="button" href="<%= contextPath %>/admin/adminReportList.jsp">초기화</a>
        </div>
    </form>

    <div class="admin-list-meta">
        <span>총 <strong><%= totalCount %></strong>개 상품</span>
        <span><%= AdminPageUtil.reportStatusText(statusFilter) %></span>
    </div>
    <div class="admin-table-wrap">
        <table class="admin-table report-group-table">
            <thead>
                <tr>
                    <th>상품</th>
                    <th>신고 요약</th>
                    <th>최근 신고일</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (reports == null || reports.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="5">조건에 맞는 상품 신고가 없습니다.</td></tr>
                <% } else {
                    for (ReportDTO report : reports) {
                        boolean waiting = "WAITING".equalsIgnoreCase(report.getStatus());
                        int waitingCount = Math.max(report.getTargetWaitingReportCount(), waiting ? 1 : 0);
                        List<ReportDTO> detailReports = reportDao.getProductReportsByTarget(report.getTargetType(), report.getTargetId());
                %>
                    <tr>
                        <td class="report-target-cell">
                            <strong>
                                <a class="table-link" href="<%= contextPath %>/product/productDetail.jsp?id=<%= report.getTargetId() %>">
                                    <%= escapeHtml(report.getProductTitle() == null ? "상품 #" + report.getTargetId() : report.getProductTitle()) %>
                                </a>
                            </strong>
                            <p class="community-meta">판매자: <%= escapeHtml(report.getTargetWriterId() == null ? "-" : report.getTargetWriterId()) %></p>
                        </td>
                        <td class="report-summary-cell">
                            <p><strong>대기 <%= waitingCount %>건 / 누적 <%= report.getTargetTotalReportCount() %>건</strong></p>
                            <p><span class="status-badge is-stopped"><%= escapeHtml(report.getReason()) %></span></p>
                            <details class="report-detail-panel">
                                <summary>상세 보기</summary>
                                <p class="community-meta">상품 내용: <%= escapeHtml(report.getTargetContent() == null ? "-" : report.getTargetContent()) %></p>
                                <table class="admin-table report-detail-table">
                                    <thead>
                                        <tr>
                                            <th>신고자</th>
                                            <th>사유</th>
                                            <th>내용</th>
                                            <th>신고일</th>
                                            <th>상태</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (ReportDTO detail : detailReports) { %>
                                            <tr>
                                                <td><%= escapeHtml(detail.getReporterNickname() == null ? detail.getReporterId() : detail.getReporterNickname()) %></td>
                                                <td><%= escapeHtml(detail.getReason()) %></td>
                                                <td><%= escapeHtml(detail.getDetail()) %></td>
                                                <td><%= detail.getCreatedAt() == null ? "-" : dateFormat.format(detail.getCreatedAt()) %></td>
                                                <td><span class="status-badge<%= AdminPageUtil.reportStatusClass(detail.getStatus()) %>"><%= AdminPageUtil.reportStatusText(detail.getStatus()) %></span></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </details>
                        </td>
                        <td><%= report.getCreatedAt() == null ? "-" : dateFormat.format(report.getCreatedAt()) %></td>
                        <td><span class="status-badge<%= AdminPageUtil.reportStatusClass(report.getStatus()) %>"><%= AdminPageUtil.reportStatusText(report.getStatus()) %></span></td>
                        <td>
                            <% if (waiting) { %>
                                <form class="inline-form admin-status-form report-action-form" action="<%= contextPath %>/admin/adminReportProcess.jsp" method="post" data-waiting-count="<%= waitingCount %>" onsubmit="return confirmReportAction(this);">
                                    <input type="hidden" name="reportId" value="<%= report.getReportId() %>">
                                    <input type="hidden" name="searchType" value="<%= escapeHtml(searchType) %>">
                                    <input type="hidden" name="keyword" value="<%= escapeHtml(keyword) %>">
                                    <input type="hidden" name="statusFilter" value="<%= escapeHtml(statusFilter) %>">
                                    <select name="action" aria-label="신고 처리">
                                        <option value="hide">숨김</option>
                                        <option value="reject">반려</option>
                                    </select>
                                    <button type="submit">처리</button>
                                </form>
                            <% } else { %>
                                <span class="muted-text">처리됨</span>
                            <% } %>
                        </td>
                    </tr>
                <%  }
                } %>
            </tbody>
        </table>
    </div>
</main>
<script>
    function confirmReportAction(form) {
        var actionSelect = form.querySelector("select[name='action']");
        var actionName = actionSelect ? actionSelect.options[actionSelect.selectedIndex].text : "처리";
        var waitingCount = form.getAttribute("data-waiting-count") || "1";
        return confirm(actionName + " 처리할까요?\n같은 상품의 대기 신고 " + waitingCount + "건이 함께 처리됩니다.");
    }
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
