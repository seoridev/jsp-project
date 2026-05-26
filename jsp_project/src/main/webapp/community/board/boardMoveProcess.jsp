<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
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

    int cafeId = parseIntParam(request.getParameter("cafeId"));
    int boardId = parseIntParam(request.getParameter("boardId"));
    String direction = request.getParameter("direction");
    String currentLoginId = (String) session.getAttribute("loginId");

    CafeBoardDAO boardDao = new CafeBoardDAO();
    CafeBoardDTO board = boardDao.selectBoardById(boardId);
    boolean valid = cafeId > 0
            && board != null
            && board.getCafeId() == cafeId
            && new CafeMemberDAO().isCafeManagerOrOwner(cafeId, currentLoginId)
            && ("UP".equals(direction) || "DOWN".equals(direction));

    if (!valid) {
        response.sendRedirect(request.getContextPath() + "/community/board/cafeBoardManage.jsp?cafeId="
                + cafeId + "&boardId=" + boardId + "&error=orderFail");
        return;
    }

    boolean moved = boardDao.moveBoard(cafeId, boardId, direction);
    response.sendRedirect(request.getContextPath() + "/community/board/cafeBoardManage.jsp?cafeId="
            + cafeId + "&boardId=" + boardId + (moved ? "&update=success" : "&error=orderFail"));
%>
