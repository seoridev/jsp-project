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
    String action = request.getParameter("action") == null ? "" : request.getParameter("action").trim();
    int reportId = parseIntParam(request.getParameter("reportId"));
    if (reportId > 0 && ("reject".equals(action) || "hideCafe".equals(action) || "hidePost".equals(action) || "hideComment".equals(action))) {
        String actionType = "reject".equals(action) ? "REJECT"
                : ("hideCafe".equals(action) ? "HIDE_CAFE"
                : ("hidePost".equals(action) ? "HIDE_POST" : "HIDE_COMMENT"));
        boolean success = reportDao.processCommunityReport(reportId, actionType);
        response.sendRedirect(request.getContextPath() + "/admin/communityReportManage.jsp?result=" + (success ? "success" : "fail"));
        return;
    }

    String searchType = requestValue(request.getParameter("searchType")).toUpperCase();
    if (!"TARGET_WRITER".equals(searchType) && !"TARGET_TITLE".equals(searchType)) {
        searchType = "REPORTER";
    }
    String keyword = requestValue(request.getParameter("keyword"));
    String statusFilter = requestValue(request.getParameter("status"));
    String targetTypeFilter = requestValue(request.getParameter("targetType"));
    String reasonFilter = requestValue(request.getParameter("reason"));

    ReportDAO.CommunityReportFilter filter = new ReportDAO.CommunityReportFilter();
    filter.setSearchType(searchType);
    filter.setKeyword(keyword);
    filter.setStatus(statusFilter);
    filter.setTargetType(targetTypeFilter);
    filter.setReason(reasonFilter);

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
    int pageBlockSize = 10;
    int blockStartPage = ((pageNo - 1) / pageBlockSize) * pageBlockSize + 1;
    int blockEndPage = Math.min(totalPages, blockStartPage + pageBlockSize - 1);
    List<ReportDTO> reports = reportDao.getCommunityReportList(filter, pageNo, pageSize);
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String result = request.getParameter("result");

    String filterQuery = "";
    filterQuery = addQuery(filterQuery, "searchType", searchType);
    filterQuery = addQuery(filterQuery, "keyword", keyword);
    filterQuery = addQuery(filterQuery, "status", statusFilter);
    filterQuery = addQuery(filterQuery, "targetType", targetTypeFilter);
    filterQuery = addQuery(filterQuery, "reason", reasonFilter);
    String pageQueryPrefix = filterQuery.isEmpty() ? "?" : "?" + filterQuery + "&";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 신고 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-community-report-9">
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
            <a class="button" href="<%= contextPath %>/admin/communityCafeManage.jsp">커뮤니티 관리</a>
        </div>
    </div>
    <% if ("success".equals(result)) { %>
        <p class="notice-toast">신고를 처리했습니다. 같은 대상의 대기 신고가 함께 처리되었습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="notice-toast is-error">신고 처리에 실패했습니다.</p>
    <% } %>

    <form class="admin-filter admin-report-filter" action="<%= contextPath %>/admin/communityReportManage.jsp" method="get">
        <input type="hidden" name="page" value="1">
        <div class="field">
            <label for="searchType">검색 기준</label>
            <select id="searchType" name="searchType">
                <option value="REPORTER" <%= selectedAttr("REPORTER", searchType) %>>신고자</option>
                <option value="TARGET_WRITER" <%= selectedAttr("TARGET_WRITER", searchType) %>>대상 작성자</option>
                <option value="TARGET_TITLE" <%= selectedAttr("TARGET_TITLE", searchType) %>>대상 제목</option>
            </select>
        </div>
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" type="search" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="검색어">
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
            <label for="status">상태</label>
            <select id="status" name="status">
                <option value="">전체</option>
                <option value="WAITING" <%= selectedAttr("WAITING", statusFilter) %>>대기</option>
                <option value="DONE" <%= selectedAttr("DONE", statusFilter) %>>처리완료</option>
                <option value="REJECTED" <%= selectedAttr("REJECTED", statusFilter) %>>반려</option>
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
        <div class="form-actions">
            <button class="primary" type="submit">검색</button>
            <a class="button" href="<%= contextPath %>/admin/communityReportManage.jsp">초기화</a>
        </div>
    </form>

    <div class="admin-list-meta">
        <span>총 <strong><%= totalCount %></strong>개 대상</span>
        <span><%= pageNo %> / <%= totalPages %> 페이지</span>
    </div>
    <div class="admin-table-wrap">
        <table class="admin-table report-group-table">
            <thead>
                <tr>
                    <th>대상</th>
                    <th>신고 요약</th>
                    <th>최근 신고일</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (reports.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="5">커뮤니티 신고가 없습니다.</td></tr>
                <% } %>
                <% for (ReportDTO report : reports) {
                    boolean waiting = "WAITING".equalsIgnoreCase(report.getStatus());
                    String targetTitle = report.getTargetTitle() == null || report.getTargetTitle().trim().isEmpty()
                            ? targetText(report.getTargetType()) + " #" + report.getTargetId()
                            : report.getTargetTitle();
                    int waitingCount = Math.max(report.getTargetWaitingReportCount(), waiting ? 1 : 0);
                    List<ReportDTO> detailReports = reportDao.getCommunityReportsByTarget(report.getTargetType(), report.getTargetId());
                    String dialogId = "community-report-dialog-" + report.getReportId();
                %>
                    <tr>
                        <td class="report-target-cell">
                            <strong><%= escapeHtml(targetText(report.getTargetType())) %></strong>
                            <p><a class="table-link" href="<%= targetUrl(contextPath, report) %>"><%= escapeHtml(targetTitle) %></a></p>
                            <p class="community-meta">
                                카페: <%= escapeHtml(report.getTargetCafeName() == null ? "-" : report.getTargetCafeName()) %>
                                / 작성자: <%= escapeHtml(report.getTargetWriterId() == null ? "-" : report.getTargetWriterId()) %>
                            </p>
                        </td>
                        <td class="report-summary-cell">
                            <p><strong>대기 <%= waitingCount %>건 / 누적 <%= report.getTargetTotalReportCount() %>건</strong></p>
                            <p><span class="status-badge is-stopped"><%= escapeHtml(reasonText(report.getReason())) %></span></p>
                        </td>
                        <td><%= report.getCreatedAt() == null ? "-" : dateFormat.format(report.getCreatedAt()) %></td>
                        <td><span class="status-badge<%= statusClass(report.getStatus()) %>"><%= statusText(report.getStatus()) %></span></td>
                        <td class="report-process-cell">
                            <button type="button" data-open-report-dialog="<%= dialogId %>">상세 보기</button>
                            <dialog class="report-modal" id="<%= dialogId %>">
                                <div class="report-modal-header">
                                    <div>
                                        <p class="eyebrow">커뮤니티 신고 상세</p>
                                        <h2><%= escapeHtml(targetTitle) %></h2>
                                        <p class="community-meta">
                                            <%= escapeHtml(targetText(report.getTargetType())) %>
                                            / 카페: <%= escapeHtml(report.getTargetCafeName() == null ? "-" : report.getTargetCafeName()) %>
                                            / 작성자: <%= escapeHtml(report.getTargetWriterId() == null ? "-" : report.getTargetWriterId()) %>
                                        </p>
                                    </div>
                                    <button type="button" class="report-modal-close" data-close-report-dialog>닫기</button>
                                </div>
                                <div class="report-modal-body">
                                    <% if (report.getTargetContent() != null && !report.getTargetContent().trim().isEmpty()) { %>
                                        <p class="community-meta">대상 내용: <%= escapeHtml(report.getTargetContent()) %></p>
                                    <% } %>
                                    <div class="report-modal-scroll">
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
                                                        <td>
                                                            <%= escapeHtml(detail.getReporterNickname() == null ? detail.getReporterId() : detail.getReporterNickname()) %>
                                                            <p class="community-meta"><%= escapeHtml(detail.getReporterId()) %></p>
                                                        </td>
                                                        <td><%= escapeHtml(reasonText(detail.getReason())) %></td>
                                                        <td><%= escapeHtml(detail.getDetail()) %></td>
                                                        <td><%= detail.getCreatedAt() == null ? "-" : dateFormat.format(detail.getCreatedAt()) %></td>
                                                        <td><span class="status-badge<%= statusClass(detail.getStatus()) %>"><%= statusText(detail.getStatus()) %></span></td>
                                                    </tr>
                                                <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <div class="report-modal-actions">
                                    <% if (waiting) { %>
                                        <form class="inline-form admin-status-form report-action-form" action="<%= contextPath %>/admin/communityReportManage.jsp" method="post" data-waiting-count="<%= waitingCount %>"
                                              onsubmit="return confirmReportAction(this);">
                                            <input type="hidden" name="reportId" value="<%= report.getReportId() %>">
                                            <select name="action" aria-label="신고 처리">
                                                <% if ("CAFE".equals(report.getTargetType())) { %>
                                                    <option value="hideCafe">숨김</option>
                                                <% } else if ("CAFE_POST".equals(report.getTargetType())) { %>
                                                    <option value="hidePost">숨김</option>
                                                <% } else if ("CAFE_COMMENT".equals(report.getTargetType())) { %>
                                                    <option value="hideComment">숨김</option>
                                                <% } %>
                                                <option value="reject">반려</option>
                                            </select>
                                            <button type="submit">처리</button>
                                        </form>
                                    <% } else { %>
                                        <span class="muted-text">처리됨</span>
                                    <% } %>
                                </div>
                            </dialog>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>
    <div class="pagination">
        <% if (blockStartPage > 1) { %>
            <a href="<%= contextPath %>/admin/communityReportManage.jsp<%= pageQueryPrefix %>page=<%= blockStartPage - pageBlockSize %>">이전</a>
        <% } else { %>
            <span class="is-disabled">이전</span>
        <% } %>
        <% for (int pageIndex = blockStartPage; pageIndex <= blockEndPage; pageIndex++) { %>
            <a class="<%= pageIndex == pageNo ? "is-current" : "" %>" href="<%= contextPath %>/admin/communityReportManage.jsp<%= pageQueryPrefix %>page=<%= pageIndex %>"><%= pageIndex %></a>
        <% } %>
        <% if (blockEndPage < totalPages) { %>
            <a href="<%= contextPath %>/admin/communityReportManage.jsp<%= pageQueryPrefix %>page=<%= blockEndPage + 1 %>">다음</a>
        <% } else { %>
            <span class="is-disabled">다음</span>
        <% } %>
    </div>
</main>
<script>
    function confirmReportAction(form) {
        var actionSelect = form.querySelector("select[name='action']");
        var actionName = actionSelect ? actionSelect.options[actionSelect.selectedIndex].text : "처리";
        var waitingCount = form.getAttribute("data-waiting-count") || "1";
        return confirm(actionName + " 처리할까요?\n같은 대상의 대기 신고 " + waitingCount + "건이 함께 처리됩니다.");
    }

    document.querySelectorAll("[data-open-report-dialog]").forEach(function(button) {
        button.addEventListener("click", function() {
            var dialog = document.getElementById(button.getAttribute("data-open-report-dialog"));
            if (dialog && typeof dialog.showModal === "function") {
                dialog.showModal();
            }
        });
    });

    document.querySelectorAll("[data-close-report-dialog]").forEach(function(button) {
        button.addEventListener("click", function() {
            var dialog = button.closest("dialog");
            if (dialog) {
                dialog.close();
            }
        });
    });
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
