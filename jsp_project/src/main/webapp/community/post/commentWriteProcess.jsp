<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ include file="../../common/sessionCheck.jsp" %>
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

    int postId = parseIntParam(request.getParameter("postId"));
    String content = request.getParameter("content") == null ? "" : request.getParameter("content").trim();
    CafePostDTO post = new CafePostDAO().selectPostById(postId);
    String currentLoginId = (String) session.getAttribute("loginId");

    if (post == null || content.isEmpty() || !new CafeMemberDAO().isActiveMember(post.getCafeId(), currentLoginId)) {
        response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId=" + postId + "&error=comment");
        return;
    }

    new CafeCommentDAO().insertComment(postId, currentLoginId, content);
    response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId=" + postId);
%>
