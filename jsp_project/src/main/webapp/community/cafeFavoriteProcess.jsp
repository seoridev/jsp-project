<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
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
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);

    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }

    boolean toggled = new CafeFavoriteDAO().toggleFavorite(cafeId, currentLoginId);
    response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId="
            + cafeId + (toggled ? "&favorite=success" : "&error=favoriteFail"));
%>
