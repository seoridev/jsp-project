<%
    String adminCommunityTab = (String) request.getAttribute("adminCommunityTab");
    String adminCommunityContextPath = request.getContextPath();
%>
<nav class="admin-community-tabs" aria-label="커뮤니티 관리 탭">
    <a class="<%= "cafe".equals(adminCommunityTab) ? "is-current" : "" %>" href="<%= adminCommunityContextPath %>/admin/communityCafeManage.jsp">카페</a>
    <a class="<%= "post".equals(adminCommunityTab) ? "is-current" : "" %>" href="<%= adminCommunityContextPath %>/admin/communityPostManage.jsp">게시글</a>
    <a class="<%= "comment".equals(adminCommunityTab) ? "is-current" : "" %>" href="<%= adminCommunityContextPath %>/admin/communityCommentManage.jsp">댓글</a>
</nav>
