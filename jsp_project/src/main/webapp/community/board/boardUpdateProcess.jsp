<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%!
    // 게시판 수정 입력값 허용 범위 확인
    private boolean isReadPermission(String value) {
        return "ALL".equals(value) || "MEMBER".equals(value);
    }

    private boolean isWritePermission(String value) {
        return "MEMBER".equals(value) || "MANAGER".equals(value) || "OWNER".equals(value);
    }

    private boolean isYn(String value) {
        return "Y".equals(value) || "N".equals(value);
    }
%>
<%
    // 게시판 수정 권한과 입력값 검증
    request.setCharacterEncoding("UTF-8");

    int cafeId = ParamParser.parseInt(request.getParameter("cafeId"), 0);
    int boardId = ParamParser.parseInt(request.getParameter("boardId"), 0);
    String boardName = request.getParameter("boardName") == null ? "" : request.getParameter("boardName").trim();
    String description = request.getParameter("description") == null ? "" : request.getParameter("description").trim();
    String readPermission = request.getParameter("readPermission");
    String writePermission = request.getParameter("writePermission");
    String isNotice = request.getParameter("isNotice") == null ? "N" : request.getParameter("isNotice");
    int displayOrder = Math.max(1, ParamParser.parseInt(request.getParameter("displayOrder"), 1));
    String currentLoginId = (String) session.getAttribute("loginId");

    CafeBoardDAO boardDao = new CafeBoardDAO();
    CafeBoardDTO currentBoard = boardDao.selectBoardById(boardId);
    boolean valid = cafeId > 0
            && currentBoard != null
            && currentBoard.getCafeId() == cafeId
            && new CafeMemberDAO().isCafeManagerOrOwner(cafeId, currentLoginId)
            && !boardName.isEmpty()
            && boardName.length() <= 100
            && description.length() <= 500
            && isReadPermission(readPermission)
            && isWritePermission(writePermission)
            && isYn(isNotice);
    if (!valid) {
        response.sendRedirect(request.getContextPath() + "/community/board/cafeBoardManage.jsp?cafeId=" + cafeId + "&error=updateFail");
        return;
    }

    boolean updated = boardDao.updateBoard(CafeBoardDTO.builder()
            .boardId(boardId)
            .cafeId(cafeId)
            .boardName(boardName)
            .description(description)
            .readPermission(readPermission)
            .writePermission(writePermission)
            .isNotice(isNotice)
            .displayOrder(displayOrder)
            .build());
    response.sendRedirect(request.getContextPath() + "/community/board/cafeBoardManage.jsp?cafeId="
            + cafeId + "&boardId=" + boardId + (updated ? "&update=success" : "&error=updateFail"));
%>
