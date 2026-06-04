<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ page import="com.carrot.util.AdminPageUtil" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String searchType = AdminPageUtil.requestValue(request.getParameter("searchType")).toUpperCase();
    if (!"CONTENT".equals(searchType) && !"WRITER".equals(searchType) && !"CAFE".equals(searchType)) {
        searchType = "TITLE";
    }
    String keyword = AdminPageUtil.requestValue(request.getParameter("keyword"));
    String statusFilter = AdminPageUtil.requestValue(request.getParameter("status")).toUpperCase();
    if (!"VISIBLE".equals(statusFilter) && !"HIDDEN".equals(statusFilter)) {
        statusFilter = "ALL";
    }
    int pageNumber = AdminPageUtil.parsePage(request.getParameter("page"));
    int pageSize = 10;
    String listQuery = AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, pageNumber);

    CafePostDAO postDao = new CafePostDAO();
    String action = AdminPageUtil.requestValue(request.getParameter("action"));
    int postId = AdminPageUtil.parseInt(request.getParameter("postId"));
    if (postId > 0 && ("hide".equals(action) || "restore".equals(action))) {
        boolean success = postDao.updatePostHiddenByAdmin(postId, "hide".equals(action));
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
        listQuery = AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, pageNumber);
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

    <% if ("hide".equals(result)) { %>
        <p class="notice-toast">게시글을 숨김 처리했습니다.</p>
    <% } else if ("restore".equals(result)) { %>
        <p class="notice-toast">게시글을 복구했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="notice-toast is-error">게시글 처리에 실패했습니다.</p>
    <% } %>

    <form class="admin-filter" action="<%= contextPath %>/admin/communityPostManage.jsp" method="get">
        <input type="hidden" name="page" value="1">
        <div class="field">
            <label for="searchType">검색 기준</label>
            <select id="searchType" name="searchType">
                <option value="TITLE" <%= AdminPageUtil.selected(searchType, "TITLE") %>>제목</option>
                <option value="CONTENT" <%= AdminPageUtil.selected(searchType, "CONTENT") %>>내용</option>
                <option value="WRITER" <%= AdminPageUtil.selected(searchType, "WRITER") %>>작성자</option>
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
                            <form class="inline-form admin-status-form" action="<%= contextPath %>/admin/communityPostManage.jsp" method="post">
                                <input type="hidden" name="postId" value="<%= post.getPostId() %>">
                                <input type="hidden" name="searchType" value="<%= escapeHtml(searchType) %>">
                                <input type="hidden" name="keyword" value="<%= escapeHtml(keyword) %>">
                                <input type="hidden" name="status" value="<%= escapeHtml(statusFilter) %>">
                                <input type="hidden" name="page" value="<%= pageNumber %>">
                                <select name="action" aria-label="게시글 상태">
                                    <option value="restore" <%= hidden ? "" : "selected" %>>노출</option>
                                    <option value="hide" <%= hidden ? "selected" : "" %>>숨김</option>
                                </select>
                                <button type="submit">변경</button>
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
                <a href="<%= contextPath %>/admin/communityPostManage.jsp?<%= AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, blockStartPage - pageBlockSize) %>">이전</a>
            <% } %>
            <% for (int i = blockStartPage; i <= blockEndPage; i++) { %>
                <a class="<%= i == pageNumber ? "is-current" : "" %>" href="<%= contextPath %>/admin/communityPostManage.jsp?<%= AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, i) %>"><%= i %></a>
            <% } %>
            <% if (blockEndPage < totalPages) { %>
                <a href="<%= contextPath %>/admin/communityPostManage.jsp?<%= AdminPageUtil.communityListQuery(searchType, keyword, statusFilter, blockEndPage + 1) %>">다음</a>
            <% } %>
        </nav>
    <% } %>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
