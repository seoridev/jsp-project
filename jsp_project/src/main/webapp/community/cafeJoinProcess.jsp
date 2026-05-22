<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
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
    if (cafeId <= 0) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    String result = new CafeMemberDAO().joinCafe(cafeId, currentLoginId);
    response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + cafeId + "&join=" + result);
%>
