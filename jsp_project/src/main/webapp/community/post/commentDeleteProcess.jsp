<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeCommentDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    // 작성자 또는 관리자만 댓글 삭제 처리
    int commentId = ParamParser.parseInt(request.getParameter("commentId"));
    CafeCommentDAO commentDao = new CafeCommentDAO();
    CafeCommentDTO comment = commentDao.selectCommentById(commentId);
    if (comment == null) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=noComment");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    boolean manager = new CafeMemberDAO().isCafeManagerOrOwner(comment.getCafeId(), currentLoginId);
    boolean deleted = commentDao.deleteComment(commentId, currentLoginId, manager);
    if (deleted) {
        response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId="
                + comment.getPostId() + "&commentDelete=success");
        return;
    }
    response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId="
            + comment.getPostId() + "&error=commentDeleteFail");
%>
