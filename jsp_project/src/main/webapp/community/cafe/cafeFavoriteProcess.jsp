<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    // 즐겨찾기 요청 후 원래 커뮤니티 경로로 복귀
    int cafeId = ParamParser.parseInt(request.getParameter("cafeId"));
    String redirect = request.getParameter("redirect");
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);

    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeList.jsp?error=noCafe");
        return;
    }

    boolean toggled = new CafeFavoriteDAO().toggleFavorite(cafeId, currentLoginId);
    if (redirect == null || !redirect.startsWith("/community/") || redirect.contains("\r") || redirect.contains("\n")) {
        redirect = "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId;
    }
    response.sendRedirect(request.getContextPath() + redirect
            + (redirect.indexOf('?') >= 0 ? "&" : "?")
            + (toggled ? "favorite=success" : "error=favoriteFail"));
%>
