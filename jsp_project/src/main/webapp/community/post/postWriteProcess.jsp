<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ page import="com.carrot.util.CafeRoleUtil" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    // 글쓰기 요청값과 게시판 권한 검증
    request.setCharacterEncoding("UTF-8");

    int cafeId = ParamParser.parseInt(request.getParameter("cafeId"));
    int boardId = ParamParser.parseInt(request.getParameter("boardId"));
    String title = request.getParameter("title") == null ? "" : request.getParameter("title").trim();
    String content = request.getParameter("content") == null ? "" : request.getParameter("content").trim();
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeBoardDTO board = new CafeBoardDAO().selectBoardById(boardId);
    CafeMemberDAO memberDao = new CafeMemberDAO();
    CafeMemberDTO currentMember = currentLoginId == null ? null : memberDao.selectCafeMember(cafeId, currentLoginId);
    boolean activeMember = currentMember != null && "ACTIVE".equals(currentMember.getStatus());
    String currentRole = activeMember ? currentMember.getRole() : null;
    boolean manager = CafeRoleUtil.canManageCafe(currentRole);
    boolean canWrite = board != null && board.getCafeId() == cafeId
            && activeMember
            && CafeRoleUtil.canWriteBoard(board.getWritePermission(), currentRole);

    if (!canWrite) {
        response.sendRedirect(request.getContextPath() + "/community/post/postWrite.jsp?cafeId=" + cafeId + "&boardId=" + boardId + "&error=noPermission");
        return;
    }

    if (title.isEmpty() || content.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/community/post/postWrite.jsp?cafeId=" + cafeId + "&boardId=" + boardId + "&error=invalid");
        return;
    }

    int postId = new CafePostDAO().insertPost(CafePostDTO.builder()
            .cafeId(cafeId)
            .boardId(boardId)
            .writerId(currentLoginId)
            .title(title)
            .content(content)
            .isNotice(manager && "Y".equals(request.getParameter("isNotice")) ? "Y" : "N")
            .build());

    if (postId <= 0) {
        response.sendRedirect(request.getContextPath() + "/community/post/postWrite.jsp?cafeId=" + cafeId + "&boardId=" + boardId + "&error=fail");
        return;
    }
    response.sendRedirect(request.getContextPath() + "/community/post/postDetail.jsp?postId=" + postId);
%>
