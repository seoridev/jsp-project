<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    // 활성 카페 회원의 댓글 등록 처리
    request.setCharacterEncoding("UTF-8");

    int postId = ParamParser.parseInt(request.getParameter("postId"));
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
