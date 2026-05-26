<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ include file="../../common/adminSessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    CafePostDAO postDao = new CafePostDAO();
    String action = request.getParameter("action") == null ? "" : request.getParameter("action").trim();
    int postId = parseIntParam(request.getParameter("postId"));
    if ("hide".equals(action) && postId > 0) {
        boolean success = postDao.hidePostByAdmin(postId);
        response.sendRedirect(request.getContextPath() + "/admin/communityPostManage.jsp?result=" + (success ? "success" : "fail"));
        return;
    }

    List<CafePostDTO> posts = postDao.selectAllPostsForAdmin();
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 게시글 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-community-1">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>커뮤니티 게시글 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/communityCafeManage.jsp">카페 관리</a>
            <a class="button" href="<%= contextPath %>/admin/communityReportManage.jsp">신고 관리</a>
        </div>
    </div>
    <% if ("success".equals(result)) { %>
        <p class="field-message is-success">게시글을 숨김 처리했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="field-message is-error">게시글 처리에 실패했습니다.</p>
    <% } %>
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
                    <tr><td class="empty-cell" colspan="8">게시글이 없습니다.</td></tr>
                <% } %>
                <% for (CafePostDTO post : posts) { %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>"><%= escapeHtml(post.getTitle()) %></a></td>
                        <td><a class="table-link" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= post.getCafeId() %>"><%= escapeHtml(post.getCafeName()) %></a></td>
                        <td><%= escapeHtml(post.getBoardName()) %></td>
                        <td><%= escapeHtml(post.getWriterId()) %></td>
                        <td><%= post.getViewCount() %></td>
                        <td><%= post.getCommentCount() %></td>
                        <td><%= "Y".equals(post.getIsHidden()) ? "숨김" : "노출" %></td>
                        <td>
                            <% if (!"Y".equals(post.getIsHidden())) { %>
                                <form class="inline-form" action="<%= contextPath %>/admin/communityPostManage.jsp" method="post">
                                    <input type="hidden" name="postId" value="<%= post.getPostId() %>">
                                    <button type="submit" name="action" value="hide">숨김</button>
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
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
