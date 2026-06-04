<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    // 작성자 또는 관리자만 게시글 삭제 처리
    int postId = ParamParser.parseInt(request.getParameter("postId"));
    CafePostDAO postDao = new CafePostDAO();
    CafePostDTO post = postDao.selectPostForDelete(postId);
    if (post == null) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=noPost");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    boolean manager = new CafeMemberDAO().isCafeManagerOrOwner(post.getCafeId(), currentLoginId);
    boolean deleted = postDao.deletePost(postId, currentLoginId, manager);
    if (deleted) {
        response.sendRedirect(request.getContextPath() + "/community/post/postList.jsp?cafeId="
                + post.getCafeId() + "&boardId=" + post.getBoardId() + "&delete=success");
        return;
    }
    response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId=" + postId + "&error=deleteFail");
%>
