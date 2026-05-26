<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%!
    private int parseIntParam(String value, int defaultValue) {
        try {
            return value == null ? defaultValue : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

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
    request.setCharacterEncoding("UTF-8");

    int cafeId = parseIntParam(request.getParameter("cafeId"), 0);
    String boardName = request.getParameter("boardName") == null ? "" : request.getParameter("boardName").trim();
    String description = request.getParameter("description") == null ? "" : request.getParameter("description").trim();
    String readPermission = request.getParameter("readPermission");
    String writePermission = request.getParameter("writePermission");
    String isNotice = request.getParameter("isNotice") == null ? "N" : request.getParameter("isNotice");
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeBoardDAO boardDao = new CafeBoardDAO();

    boolean valid = cafeId > 0
            && new CafeMemberDAO().isCafeManagerOrOwner(cafeId, currentLoginId)
            && !boardName.isEmpty()
            && boardName.length() <= 100
            && description.length() <= 500
            && isReadPermission(readPermission)
            && isWritePermission(writePermission)
            && isYn(isNotice);
    if (!valid) {
        response.sendRedirect(request.getContextPath() + "/community/board/cafeBoardManage.jsp?cafeId=" + cafeId + "&error=createFail");
        return;
    }

    int displayOrder = boardDao.nextDisplayOrder(cafeId);

    int createdBoardId = boardDao.insertBoardAndReturnId(cafeId, boardName, description, readPermission,
            writePermission, isNotice, displayOrder);
    response.sendRedirect(request.getContextPath() + "/community/board/cafeBoardManage.jsp?cafeId="
            + cafeId + (createdBoardId > 0 ? "&boardId=" + createdBoardId + "&create=success" : "&error=createFail"));
%>
