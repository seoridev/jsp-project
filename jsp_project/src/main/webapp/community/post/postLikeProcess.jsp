<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dao.CafePostLikeDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    // 활성 카페 회원만 게시글 좋아요 토글
    int postId = ParamParser.parseInt(request.getParameter("postId"));
    String currentLoginId = (String) session.getAttribute("loginId");
    CafePostDTO post = new CafePostDAO().selectPostById(postId);

    if (post == null) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=noPost");
        return;
    }

    if (!new CafeMemberDAO().isActiveMember(post.getCafeId(), currentLoginId)) {
        session.setAttribute("skipPostViewIncrementPostId", Integer.valueOf(postId));
        response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId=" + postId + "&error=likeDenied");
        return;
    }

    boolean toggled = new CafePostLikeDAO().toggleLike(postId, currentLoginId);
    session.setAttribute("skipPostViewIncrementPostId", Integer.valueOf(postId));
    response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId="
            + postId + (toggled ? "&like=success" : "&error=likeFail"));
%>
