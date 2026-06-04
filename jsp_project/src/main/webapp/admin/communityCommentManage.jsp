<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.AdminCommunityActionLogDAO" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dto.CafeCommentDTO" %>
<%@ page import="com.carrot.util.AdminPageUtil" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String searchType = AdminPageUtil.requestValue(request.getParameter("searchType")).toUpperCase();
    if (!"WRITER".equals(searchType) && !"POST".equals(searchType) && !"CAFE".equals(searchType)) {
        searchType = "CONTENT";
    }
    String keyword = AdminPageUtil.requestValue(request.getParameter("keyword"));
    String statusFilter = AdminPageUtil.requestValue(request.getParameter("status")).toUpperCase();
    if (!"VISIBLE".equals(statusFilter) && !"HIDDEN".equals(statusFilter)) {
        statusFilter = "ALL";
    }
    int pageNumber = AdminPageUtil.parsePage(request.getParameter("page"));
    int pageSize = 10;
    String listQuery = AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, pageNumber);

    CafeCommentDAO commentDao = new CafeCommentDAO();
    boolean logReady = new AdminCommunityActionLogDAO().hasLogTable();
    String action = AdminPageUtil.requestValue(request.getParameter("action"));
    int commentId = AdminPageUtil.parseInt(request.getParameter("commentId"));
    if (commentId > 0 && ("hide".equals(action) || "restore".equals(action))) {
        String adminMemo = request.getParameter("adminMemo");
        String adminId = (String) session.getAttribute("adminLoginId");
        boolean success = logReady && adminMemo != null && !adminMemo.trim().isEmpty()
                && commentDao.updateCommentDeletedByAdmin(commentId, "hide".equals(action), adminId, adminMemo);
        response.sendRedirect(request.getContextPath() + "/admin/communityCommentManage.jsp?"
                + listQuery + "&result=" + (success ? action : "fail"));
        return;
    }

    CafeCommentDAO.AdminCommentFilter filter = new CafeCommentDAO.AdminCommentFilter();
    filter.setSearchType(searchType);
    filter.setKeyword(keyword);
    filter.setStatus(statusFilter);

    int totalCount = commentDao.countCommentsForAdmin(filter);
    int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
    if (pageNumber > totalPages) {
        pageNumber = totalPages;
        listQuery = AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, pageNumber);
    }
    int pageBlockSize = 10;
    int blockStartPage = ((pageNumber - 1) / pageBlockSize) * pageBlockSize + 1;
    int blockEndPage = Math.min(totalPages, blockStartPage + pageBlockSize - 1);
    List<CafeCommentDTO> comments = commentDao.selectCommentsForAdmin(filter, pageNumber, pageSize);
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 댓글 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-community-3">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>커뮤니티 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/communityReportManage.jsp">커뮤니티 신고 관리</a>
        </div>
    </div>
    <% request.setAttribute("adminCommunityTab", "comment"); %>
    <%@ include file="communityManageTabs.jsp" %>

    <% if (!logReady) { %>
        <p class="field-message is-error">관리 이력 테이블이 없습니다. database/admin_community_action_log_migration.sql을 실행해야 직접 숨김/복구 처리가 가능합니다.</p>
    <% } %>
    <% if ("hide".equals(result)) { %>
        <p class="field-message is-success">댓글을 숨김 처리했습니다.</p>
    <% } else if ("restore".equals(result)) { %>
        <p class="field-message is-success">댓글을 복구했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="field-message is-error">댓글 처리에 실패했습니다. 처리 사유를 입력했는지 확인하세요.</p>
    <% } %>

    <form class="admin-filter" action="<%= contextPath %>/admin/communityCommentManage.jsp" method="get">
        <input type="hidden" name="page" value="1">
        <div class="field">
            <label for="searchType">검색 기준</label>
            <select id="searchType" name="searchType">
                <option value="CONTENT" <%= AdminPageUtil.selected(searchType, "CONTENT") %>>댓글 내용</option>
                <option value="WRITER" <%= AdminPageUtil.selected(searchType, "WRITER") %>>작성자</option>
                <option value="POST" <%= AdminPageUtil.selected(searchType, "POST") %>>게시글 제목</option>
                <option value="CAFE" <%= AdminPageUtil.selected(searchType, "CAFE") %>>카페명</option>
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
                <option value="VISIBLE" <%= AdminPageUtil.selected(statusFilter, "VISIBLE") %>>노출</option>
                <option value="HIDDEN" <%= AdminPageUtil.selected(statusFilter, "HIDDEN") %>>숨김</option>
            </select>
        </div>
        <div class="form-actions">
            <button class="primary" type="submit">검색</button>
            <a class="button" href="<%= contextPath %>/admin/communityCommentManage.jsp">초기화</a>
        </div>
    </form>

    <div class="admin-list-meta">
        <span>총 <strong><%= totalCount %></strong>개</span>
        <span><%= pageNumber %> / <%= totalPages %> 페이지</span>
    </div>

    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>댓글</th>
                    <th>게시글</th>
                    <th>카페</th>
                    <th>작성자</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (comments.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="6">조건에 맞는 댓글이 없습니다.</td></tr>
                <% } %>
                <% for (CafeCommentDTO comment : comments) {
                    boolean hidden = "Y".equals(comment.getIsDeleted());
                %>
                    <tr>
                        <td><%= escapeHtml(comment.getContent()) %></td>
                        <td><a class="table-link" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= comment.getPostId() %>"><%= escapeHtml(comment.getPostTitle()) %></a></td>
                        <td><a class="table-link" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= comment.getCafeId() %>"><%= escapeHtml(comment.getCafeName()) %></a></td>
                        <td><%= escapeHtml(comment.getWriterId()) %></td>
                        <td><span class="status-badge<%= hidden ? " is-stopped" : " is-active" %>"><%= hidden ? "숨김" : "노출" %></span></td>
                        <td>
                            <form class="inline-form admin-memo-form" action="<%= contextPath %>/admin/communityCommentManage.jsp" method="post" data-current-action="<%= hidden ? "hide" : "restore" %>" data-action-label-prefix="댓글" onsubmit="return fillAdminMemo(this);">
                                <input type="hidden" name="commentId" value="<%= comment.getCommentId() %>">
                                <input type="hidden" name="adminMemo" value="">
                                <input type="hidden" name="searchType" value="<%= escapeHtml(searchType) %>">
                                <input type="hidden" name="keyword" value="<%= escapeHtml(keyword) %>">
                                <input type="hidden" name="status" value="<%= escapeHtml(statusFilter) %>">
                                <input type="hidden" name="page" value="<%= pageNumber %>">
                                <select name="action" aria-label="댓글 상태">
                                    <option value="restore" <%= hidden ? "" : "selected" %>>노출</option>
                                    <option value="hide" <%= hidden ? "selected" : "" %>>숨김</option>
                                </select>
                                <button type="submit" <%= logReady ? "" : "disabled" %>>변경</button>
                            </form>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <% if (totalPages > 1) { %>
        <nav class="pagination" aria-label="댓글 목록 페이지">
            <% if (blockStartPage > 1) { %>
                <a href="<%= contextPath %>/admin/communityCommentManage.jsp?<%= AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, blockStartPage - pageBlockSize) %>">이전</a>
            <% } %>
            <% for (int i = blockStartPage; i <= blockEndPage; i++) { %>
                <a class="<%= i == pageNumber ? "is-current" : "" %>" href="<%= contextPath %>/admin/communityCommentManage.jsp?<%= AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, i) %>"><%= i %></a>
            <% } %>
            <% if (blockEndPage < totalPages) { %>
                <a href="<%= contextPath %>/admin/communityCommentManage.jsp?<%= AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, blockEndPage + 1) %>">다음</a>
            <% } %>
        </nav>
    <% } %>
</main>
<script>
function fillAdminMemo(form) {
    var select = form.querySelector("select[name='action']");
    if (select && select.value === form.getAttribute("data-current-action")) {
        alert("변경할 상태를 선택하세요.");
        return false;
    }
    var prefix = form.getAttribute("data-action-label-prefix") || "";
    var actionName = (prefix ? prefix + " " : "") + (select ? select.options[select.selectedIndex].text : "상태 변경");
    var memo = prompt(actionName + " 처리 사유를 입력하세요.");
    if (!memo || memo.trim().length === 0) {
        alert("처리 사유가 필요합니다.");
        return false;
    }
    form.querySelector("input[name='adminMemo']").value = memo.trim();
    return confirm(actionName + " 처리할까요?");
}
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
