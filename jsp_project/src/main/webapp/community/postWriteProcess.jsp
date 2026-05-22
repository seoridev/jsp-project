<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
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

    int cafeId = parseIntParam(request.getParameter("cafeId"));
    int boardId = parseIntParam(request.getParameter("boardId"));
    String title = request.getParameter("title") == null ? "" : request.getParameter("title").trim();
    String content = request.getParameter("content") == null ? "" : request.getParameter("content").trim();
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeBoardDTO board = new CafeBoardDAO().selectBoardById(boardId);
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean manager = memberDao.isCafeManagerOrOwner(cafeId, currentLoginId);
    boolean canWrite = board != null && board.getCafeId() == cafeId
            && memberDao.isActiveMember(cafeId, currentLoginId)
            && ("MEMBER".equals(board.getWritePermission()) || manager);

    if (!canWrite || title.isEmpty() || content.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/community/postWrite.jsp?cafeId=" + cafeId + "&boardId=" + boardId + "&error=invalid");
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
        response.sendRedirect(request.getContextPath() + "/community/postWrite.jsp?cafeId=" + cafeId + "&boardId=" + boardId + "&error=fail");
        return;
    }
    response.sendRedirect(request.getContextPath() + "/community/postDetail.jsp?postId=" + postId);
%>
