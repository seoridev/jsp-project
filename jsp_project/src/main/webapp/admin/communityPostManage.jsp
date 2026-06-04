<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.AdminCommunityActionLogDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private int parsePage(String value) {
        return Math.max(parseIntParam(value), 1);
    }

    private String requestValue(String value) {
        return value == null ? "" : value.trim();
    }

    private String selectedAttr(String current, String expected) {
        return expected.equalsIgnoreCase(current) ? "selected" : "";
    }

    private String encodeParam(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    private String buildListQuery(String searchType, String keyword, String status, int page) {
        return "searchType=" + encodeParam(searchType)
            + "&keyword=" + encodeParam(keyword)
            + "&status=" + encodeParam(status)
            + "&page=" + page;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String searchType = requestValue(request.getParameter("searchType")).toUpperCase();
    if (!"CONTENT".equals(searchType) && !"WRITER".equals(searchType) && !"CAFE".equals(searchType)) {
        searchType = "TITLE";
    }
    String keyword = requestValue(request.getParameter("keyword"));
    String statusFilter = requestValue(request.getParameter("status")).toUpperCase();
    if (!"VISIBLE".equals(statusFilter) && !"HIDDEN".equals(statusFilter)) {
        statusFilter = "ALL";
    }
    int pageNumber = parsePage(request.getParameter("page"));
    int pageSize = 10;
    String listQuery = buildListQuery(searchType, keyword, statusFilter, pageNumber);

    CafePostDAO postDao = new CafePostDAO();
    boolean logReady = new AdminCommunityActionLogDAO().hasLogTable();
    String action = requestValue(request.getParameter("action"));
    int postId = parseIntParam(request.getParameter("postId"));
    if (postId > 0 && ("hide".equals(action) || "restore".equals(action))) {
        String adminMemo = request.getParameter("adminMemo");
        String adminId = (String) session.getAttribute("adminLoginId");
        boolean success = logReady && adminMemo != null && !adminMemo.trim().isEmpty()
                && postDao.updatePostHiddenByAdmin(postId, "hide".equals(action), adminId, adminMemo);
        response.sendRedirect(request.getContextPath() + "/admin/communityPostManage.jsp?"
                + listQuery + "&result=" + (success ? action : "fail"));
        return;
    }

    CafePostDAO.AdminPostFilter filter = new CafePostDAO.AdminPostFilter();
    filter.setSearchType(searchType);
    filter.setKeyword(keyword);
    filter.setStatus(statusFilter);

    int totalCount = postDao.countPostsForAdmin(filter);
    int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
    if (pageNumber > totalPages) {
        pageNumber = totalPages;
        listQuery = buildListQuery(searchType, keyword, statusFilter, pageNumber);
    }
    int pageBlockSize = 10;
    int blockStartPage = ((pageNumber - 1) / pageBlockSize) * pageBlockSize + 1;
    int blockEndPage = Math.min(totalPages, blockStartPage + pageBlockSize - 1);
    List<CafePostDTO> posts = postDao.selectPostsForAdmin(filter, pageNumber, pageSize);
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 게시글 관리 | 동네마켓</title>
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
    <% request.setAttribute("adminCommunityTab", "post"); %>
    <%@ include file="communityManageTabs.jsp" %>

    <% if (!logReady) { %>
        <p class="field-message is-error">관리 이력 테이블이 없습니다. database/admin_community_action_log_migration.sql을 실행해야 직접 숨김/복구 처리가 가능합니다.</p>
    <% } %>
    <% if ("hide".equals(result)) { %>
        <p class="field-message is-success">게시글을 숨김 처리했습니다.</p>
    <% } else if ("restore".equals(result)) { %>
        <p class="field-message is-success">게시글을 복구했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="field-message is-error">게시글 처리에 실패했습니다. 처리 사유를 입력했는지 확인하세요.</p>
    <% } %>

    <form class="admin-filter" action="<%= contextPath %>/admin/communityPostManage.jsp" method="get">
        <input type="hidden" name="page" value="1">
        <div class="field">
            <label for="searchType">검색 기준</label>
            <select id="searchType" name="searchType">
                <option value="TITLE" <%= selectedAttr(searchType, "TITLE") %>>제목</option>
                <option value="CONTENT" <%= selectedAttr(searchType, "CONTENT") %>>내용</option>
                <option value="WRITER" <%= selectedAttr(searchType, "WRITER") %>>작성자</option>
                <option value="CAFE" <%= selectedAttr(searchType, "CAFE") %>>카페명</option>
            </select>
        </div>
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" type="search" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="검색어">
        </div>
        <div class="field">
            <label for="status">상태</label>
            <select id="status" name="status">
                <option value="ALL" <%= selectedAttr(statusFilter, "ALL") %>>전체</option>
                <option value="VISIBLE" <%= selectedAttr(statusFilter, "VISIBLE") %>>노출</option>
                <option value="HIDDEN" <%= selectedAttr(statusFilter, "HIDDEN") %>>숨김</option>
            </select>
        </div>
        <div class="form-actions">
            <button class="primary" type="submit">검색</button>
            <a class="button" href="<%= contextPath %>/admin/communityPostManage.jsp">초기화</a>
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
                    <th>글 제목</th>
                    <th>카페</th>
                    <th>게시판</th>
                    <th>작성자</th>
                    <th>조회</th>
                    <th>댓글</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (posts.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="8">조건에 맞는 게시글이 없습니다.</td></tr>
                <% } %>
                <% for (CafePostDTO post : posts) {
                    boolean hidden = "Y".equals(post.getIsHidden());
                %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>"><%= escapeHtml(post.getTitle()) %></a></td>
                        <td><a class="table-link" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= post.getCafeId() %>"><%= escapeHtml(post.getCafeName()) %></a></td>
                        <td><%= escapeHtml(post.getBoardName()) %></td>
                        <td><%= escapeHtml(post.getWriterId()) %></td>
                        <td><%= post.getViewCount() %></td>
                        <td><%= post.getCommentCount() %></td>
                        <td><span class="status-badge<%= hidden ? " is-stopped" : " is-active" %>"><%= hidden ? "숨김" : "노출" %></span></td>
                        <td>
                            <form class="inline-form admin-memo-form" action="<%= contextPath %>/admin/communityPostManage.jsp" method="post" data-current-action="<%= hidden ? "hide" : "restore" %>" data-action-label-prefix="게시글" onsubmit="return fillAdminMemo(this);">
                                <input type="hidden" name="postId" value="<%= post.getPostId() %>">
                                <input type="hidden" name="adminMemo" value="">
                                <input type="hidden" name="searchType" value="<%= escapeHtml(searchType) %>">
                                <input type="hidden" name="keyword" value="<%= escapeHtml(keyword) %>">
                                <input type="hidden" name="status" value="<%= escapeHtml(statusFilter) %>">
                                <input type="hidden" name="page" value="<%= pageNumber %>">
                                <select name="action" aria-label="게시글 상태">
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
        <nav class="pagination" aria-label="게시글 목록 페이지">
            <% if (blockStartPage > 1) { %>
                <a href="<%= contextPath %>/admin/communityPostManage.jsp?<%= buildListQuery(searchType, keyword, statusFilter, blockStartPage - pageBlockSize) %>">이전</a>
            <% } %>
            <% for (int i = blockStartPage; i <= blockEndPage; i++) { %>
                <a class="<%= i == pageNumber ? "is-current" : "" %>" href="<%= contextPath %>/admin/communityPostManage.jsp?<%= buildListQuery(searchType, keyword, statusFilter, i) %>"><%= i %></a>
            <% } %>
            <% if (blockEndPage < totalPages) { %>
                <a href="<%= contextPath %>/admin/communityPostManage.jsp?<%= buildListQuery(searchType, keyword, statusFilter, blockEndPage + 1) %>">다음</a>
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
