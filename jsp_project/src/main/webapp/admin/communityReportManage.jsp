<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
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

    private String requestValue(String value) {
        return value == null ? "" : value.trim();
    }

    private String selectedAttr(String value, String current) {
        return value.equals(current) ? "selected" : "";
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

    private String reasonText(String reason) {
        if ("SPAM".equals(reason)) return "스팸/홍보";
        if ("ABUSE".equals(reason)) return "욕설/비방";
        if ("FRAUD".equals(reason)) return "사기/허위 정보";
        if ("SEXUAL".equals(reason)) return "음란/부적절";
        if ("PRIVACY".equals(reason)) return "개인정보 노출";
        if ("ETC".equals(reason)) return "기타";
        return reason;
    }

    private String actionText(String actionType) {
        if ("HIDE_CAFE".equals(actionType)) return "카페 숨김";
        if ("HIDE_POST".equals(actionType)) return "게시글 숨김";
        if ("HIDE_COMMENT".equals(actionType)) return "댓글 숨김";
        if ("DONE".equals(actionType)) return "신고만 완료";
        if ("REJECT".equals(actionType)) return "반려";
        return actionType == null || actionType.isEmpty() ? "-" : actionType;
    }

    private String targetUrl(String contextPath, ReportDTO report) {
        if ("CAFE".equals(report.getTargetType())) {
            return contextPath + "/community/cafe/cafeDetail.jsp?cafeId=" + report.getTargetId();
        }
        if ("CAFE_POST".equals(report.getTargetType())) {
            return contextPath + "/community/post/postDetail.jsp?postId=" + report.getTargetId();
        }
        if ("CAFE_COMMENT".equals(report.getTargetType()) && report.getTargetPostId() > 0) {
            return contextPath + "/community/post/postDetail.jsp?postId=" + report.getTargetPostId();
        }
        return contextPath + "/community/communityHome.jsp";
    }

    private String addQuery(String query, String name, String value) throws Exception {
        if (value == null || value.trim().isEmpty()) {
            return query;
        }
        return query + (query.isEmpty() ? "" : "&") + name + "=" + URLEncoder.encode(value.trim(), "UTF-8");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    ReportDAO reportDao = new ReportDAO();
    boolean moderationColumnsReady = reportDao.hasReportModerationColumns();
    String action = request.getParameter("action") == null ? "" : request.getParameter("action").trim();
    int reportId = parseIntParam(request.getParameter("reportId"));
    if (reportId > 0 && ("done".equals(action) || "reject".equals(action)
            || "hideCafe".equals(action) || "hidePost".equals(action) || "hideComment".equals(action))) {
        String actionType = "done".equals(action) ? "DONE"
                : ("reject".equals(action) ? "REJECT"
                : ("hideCafe".equals(action) ? "HIDE_CAFE"
                : ("hidePost".equals(action) ? "HIDE_POST" : "HIDE_COMMENT")));
        String adminId = (String) session.getAttribute("adminLoginId");
        String adminMemo = request.getParameter("adminMemo");
        boolean success = moderationColumnsReady
                && adminMemo != null
                && !adminMemo.trim().isEmpty()
                && reportDao.processCommunityReport(reportId, actionType, adminId, adminMemo);
        response.sendRedirect(request.getContextPath() + "/admin/communityReportManage.jsp?result=" + (success ? "success" : "fail"));
        return;
    }

    String statusFilter = requestValue(request.getParameter("status"));
    String targetTypeFilter = requestValue(request.getParameter("targetType"));
    String reasonFilter = requestValue(request.getParameter("reason"));
    String reporterFilter = requestValue(request.getParameter("reporterId"));
    String targetWriterFilter = requestValue(request.getParameter("targetWriterId"));
    String dateFromFilter = requestValue(request.getParameter("dateFrom"));
    String dateToFilter = requestValue(request.getParameter("dateTo"));

    ReportDAO.CommunityReportFilter filter = new ReportDAO.CommunityReportFilter();
    filter.setStatus(statusFilter);
    filter.setTargetType(targetTypeFilter);
    filter.setReason(reasonFilter);
    filter.setReporterId(reporterFilter);
    filter.setTargetWriterId(targetWriterFilter);
    filter.setDateFrom(dateFromFilter);
    filter.setDateTo(dateToFilter);

    int pageNo = parseIntParam(request.getParameter("page"));
    if (pageNo <= 0) {
        pageNo = 1;
    }
    int pageSize = 10;
    int totalCount = reportDao.countCommunityReports(filter);
    int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
    if (pageNo > totalPages) {
        pageNo = totalPages;
    }
    List<ReportDTO> reports = reportDao.getCommunityReportList(filter, pageNo, pageSize);
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String result = request.getParameter("result");

    String filterQuery = "";
    filterQuery = addQuery(filterQuery, "status", statusFilter);
    filterQuery = addQuery(filterQuery, "targetType", targetTypeFilter);
    filterQuery = addQuery(filterQuery, "reason", reasonFilter);
    filterQuery = addQuery(filterQuery, "reporterId", reporterFilter);
    filterQuery = addQuery(filterQuery, "targetWriterId", targetWriterFilter);
    filterQuery = addQuery(filterQuery, "dateFrom", dateFromFilter);
    filterQuery = addQuery(filterQuery, "dateTo", dateToFilter);
    String pageQueryPrefix = filterQuery.isEmpty() ? "?" : "?" + filterQuery + "&";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 신고 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-community-report-3">
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
    <% if (!moderationColumnsReady) { %>
        <p class="field-message is-error">신고 처리 이력 컬럼이 없습니다. 먼저 database/report_moderation_migration.sql을 실행해야 처리 메모와 일괄 처리가 저장됩니다.</p>
    <% } %>
    <% if ("success".equals(result)) { %>
        <p class="field-message is-success">신고를 처리했습니다. 같은 대상의 대기 신고도 함께 처리되었습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="field-message is-error">신고 처리에 실패했습니다.</p>
    <% } %>

    <form class="form-grid" action="<%= contextPath %>/admin/communityReportManage.jsp" method="get">
        <input type="hidden" name="page" value="1">
        <div class="field">
            <label for="status">상태</label>
            <select id="status" name="status">
                <option value="">전체</option>
                <option value="WAITING" <%= selectedAttr("WAITING", statusFilter) %>>대기</option>
                <option value="DONE" <%= selectedAttr("DONE", statusFilter) %>>처리완료</option>
                <option value="REJECTED" <%= selectedAttr("REJECTED", statusFilter) %>>반려</option>
            </select>
        </div>
        <div class="field">
            <label for="targetType">대상</label>
            <select id="targetType" name="targetType">
                <option value="">전체</option>
                <option value="CAFE" <%= selectedAttr("CAFE", targetTypeFilter) %>>카페</option>
                <option value="CAFE_POST" <%= selectedAttr("CAFE_POST", targetTypeFilter) %>>게시글</option>
                <option value="CAFE_COMMENT" <%= selectedAttr("CAFE_COMMENT", targetTypeFilter) %>>댓글</option>
            </select>
        </div>
        <div class="field">
            <label for="reason">사유</label>
            <select id="reason" name="reason">
                <option value="">전체</option>
                <option value="SPAM" <%= selectedAttr("SPAM", reasonFilter) %>>스팸/홍보</option>
                <option value="ABUSE" <%= selectedAttr("ABUSE", reasonFilter) %>>욕설/비방</option>
                <option value="FRAUD" <%= selectedAttr("FRAUD", reasonFilter) %>>사기/허위 정보</option>
                <option value="SEXUAL" <%= selectedAttr("SEXUAL", reasonFilter) %>>음란/부적절</option>
                <option value="PRIVACY" <%= selectedAttr("PRIVACY", reasonFilter) %>>개인정보 노출</option>
                <option value="ETC" <%= selectedAttr("ETC", reasonFilter) %>>기타</option>
            </select>
        </div>
        <div class="field">
            <label for="reporterId">신고자</label>
            <input id="reporterId" name="reporterId" value="<%= escapeHtml(reporterFilter) %>">
        </div>
        <div class="field">
            <label for="targetWriterId">대상 작성자</label>
            <input id="targetWriterId" name="targetWriterId" value="<%= escapeHtml(targetWriterFilter) %>">
        </div>
        <div class="field">
            <label for="dateFrom">시작일</label>
            <input id="dateFrom" name="dateFrom" type="date" value="<%= escapeHtml(dateFromFilter) %>">
        </div>
        <div class="field">
            <label for="dateTo">종료일</label>
            <input id="dateTo" name="dateTo" type="date" value="<%= escapeHtml(dateToFilter) %>">
        </div>
        <div class="form-actions">
            <button class="primary" type="submit">검색</button>
            <a class="button" href="<%= contextPath %>/admin/communityReportManage.jsp">초기화</a>
        </div>
    </form>

    <p class="community-meta">총 <%= totalCount %>개 대상 / <%= pageNo %>페이지</p>
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>대표 신고</th>
                    <th>최근 신고자</th>
                    <th>대상</th>
                    <th>누적</th>
                    <th>사유</th>
                    <th>상세</th>
                    <th>상태</th>
                    <th>신고일</th>
                    <th>처리</th>
                </tr>
            </thead>
            <tbody>
                <% if (reports.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="9">커뮤니티 신고가 없습니다.</td></tr>
                <% } %>
                <% for (ReportDTO report : reports) {
                    boolean waiting = "WAITING".equalsIgnoreCase(report.getStatus());
                    String targetTitle = report.getTargetTitle() == null || report.getTargetTitle().trim().isEmpty()
                            ? targetText(report.getTargetType()) + " #" + report.getTargetId()
                            : report.getTargetTitle();
                    int waitingCount = Math.max(report.getTargetWaitingReportCount(), waiting ? 1 : 0);
                %>
                    <tr>
                        <td><%= report.getReportId() %></td>
                        <td>
                            <strong><%= escapeHtml(report.getReporterNickname() == null ? report.getReporterId() : report.getReporterNickname()) %></strong>
                            <p class="community-meta"><%= escapeHtml(report.getReporterId()) %></p>
                        </td>
                        <td>
                            <strong><%= escapeHtml(targetText(report.getTargetType())) %></strong>
                            <p><a class="table-link" href="<%= targetUrl(contextPath, report) %>"><%= escapeHtml(targetTitle) %></a></p>
                            <p class="community-meta">
                                카페: <%= escapeHtml(report.getTargetCafeName() == null ? "-" : report.getTargetCafeName()) %>
                                / 작성자: <%= escapeHtml(report.getTargetWriterId() == null ? "-" : report.getTargetWriterId()) %>
                            </p>
                        </td>
                        <td>
                            <strong>대기 <%= waitingCount %>건</strong>
                            <p class="community-meta">누적 <%= report.getTargetTotalReportCount() %>건</p>
                            <% if (report.getTargetRecentReportSummary() != null && !report.getTargetRecentReportSummary().trim().isEmpty()) { %>
                                <p class="community-meta"><%= escapeHtml(report.getTargetRecentReportSummary()) %></p>
                            <% } %>
                        </td>
                        <td><%= escapeHtml(reasonText(report.getReason())) %></td>
                        <td>
                            <p><%= escapeHtml(report.getDetail()) %></p>
                            <% if (report.getTargetContent() != null && !report.getTargetContent().trim().isEmpty()) { %>
                                <p class="community-meta">대상 내용: <%= escapeHtml(report.getTargetContent()) %></p>
                            <% } %>
                        </td>
                        <td>
                            <span class="status-badge<%= statusClass(report.getStatus()) %>"><%= statusText(report.getStatus()) %></span>
                            <% if (!waiting) { %>
                                <p class="community-meta"><%= escapeHtml(actionText(report.getActionType())) %></p>
                                <p class="community-meta">처리자: <%= escapeHtml(report.getProcessedBy() == null ? "-" : report.getProcessedBy()) %></p>
                                <p class="community-meta">처리일: <%= report.getProcessedAt() == null ? "-" : dateFormat.format(report.getProcessedAt()) %></p>
                                <% if (report.getAdminMemo() != null && !report.getAdminMemo().trim().isEmpty()) { %>
                                    <p class="community-meta">메모: <%= escapeHtml(report.getAdminMemo()) %></p>
                                <% } %>
                            <% } %>
                        </td>
                        <td><%= report.getCreatedAt() == null ? "-" : dateFormat.format(report.getCreatedAt()) %></td>
                        <td>
                            <% if (waiting) { %>
                                <form class="inline-form" action="<%= contextPath %>/admin/communityReportManage.jsp" method="post" data-waiting-count="<%= waitingCount %>" onsubmit="return confirmReportAction(this, event);">
                                    <input type="hidden" name="reportId" value="<%= report.getReportId() %>">
                                    <textarea name="adminMemo" rows="2" maxlength="1000" placeholder="처리 메모" required <%= moderationColumnsReady ? "" : "disabled" %>></textarea>
                                    <button class="btn-sub" type="submit" name="action" value="done" <%= moderationColumnsReady ? "" : "disabled" %>>신고만 완료</button>
                                    <% if ("CAFE".equals(report.getTargetType())) { %>
                                        <button class="btn-danger" type="submit" name="action" value="hideCafe" <%= moderationColumnsReady ? "" : "disabled" %>>카페 숨김</button>
                                    <% } else if ("CAFE_POST".equals(report.getTargetType())) { %>
                                        <button class="btn-danger" type="submit" name="action" value="hidePost" <%= moderationColumnsReady ? "" : "disabled" %>>게시글 숨김</button>
                                    <% } else if ("CAFE_COMMENT".equals(report.getTargetType())) { %>
                                        <button class="btn-danger" type="submit" name="action" value="hideComment" <%= moderationColumnsReady ? "" : "disabled" %>>댓글 숨김</button>
                                    <% } %>
                                    <button class="btn-sub" type="submit" name="action" value="reject" <%= moderationColumnsReady ? "" : "disabled" %>>반려</button>
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
    <div class="pagination">
        <% if (pageNo > 1) { %>
            <a href="<%= contextPath %>/admin/communityReportManage.jsp<%= pageQueryPrefix %>page=<%= pageNo - 1 %>">이전</a>
        <% } else { %>
            <span class="is-disabled">이전</span>
        <% } %>
        <% for (int pageIndex = Math.max(1, pageNo - 2); pageIndex <= Math.min(totalPages, pageNo + 2); pageIndex++) { %>
            <a class="<%= pageIndex == pageNo ? "is-current" : "" %>" href="<%= contextPath %>/admin/communityReportManage.jsp<%= pageQueryPrefix %>page=<%= pageIndex %>"><%= pageIndex %></a>
        <% } %>
        <% if (pageNo < totalPages) { %>
            <a href="<%= contextPath %>/admin/communityReportManage.jsp<%= pageQueryPrefix %>page=<%= pageNo + 1 %>">다음</a>
        <% } else { %>
            <span class="is-disabled">다음</span>
        <% } %>
    </div>
</main>
<script>
    function confirmReportAction(form, event) {
        var memo = form.querySelector("textarea[name='adminMemo']");
        if (!memo || memo.value.trim().length === 0) {
            alert("처리 메모를 입력해 주세요.");
            if (memo) {
                memo.focus();
            }
            return false;
        }
        var button = event && event.submitter ? event.submitter : null;
        var actionName = button ? button.textContent.trim() : "처리";
        var waitingCount = form.getAttribute("data-waiting-count") || "1";
        return confirm(actionName + " 처리할까요?\n같은 대상의 대기 신고 " + waitingCount + "건이 함께 처리됩니다.");
    }
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
