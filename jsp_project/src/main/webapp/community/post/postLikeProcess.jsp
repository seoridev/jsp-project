<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dao.CafePostLikeDAO" %>
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
    int postId = parseIntParam(request.getParameter("postId"));
    String currentLoginId = (String) session.getAttribute("loginId");
    CafePostDTO post = new CafePostDAO().selectPostById(postId);

    if (post == null) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=noPost");
        return;
    }

    if (!new CafeMemberDAO().isActiveMember(post.getCafeId(), currentLoginId)) {
        response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId=" + postId + "&error=likeDenied");
        return;
    }

    boolean toggled = new CafePostLikeDAO().toggleLike(postId, currentLoginId);
    response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId="
            + postId + (toggled ? "&like=success" : "&error=likeFail"));
%>
