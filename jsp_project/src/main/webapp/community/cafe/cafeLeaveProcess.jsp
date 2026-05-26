<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
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
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    CafeMemberDTO member = memberDao.selectCafeMember(cafeId, currentLoginId);

    if (cafeId <= 0 || member == null || !"ACTIVE".equals(member.getStatus())) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId + "&error=leaveFail");
        return;
    }

    if ("OWNER".equals(member.getRole())) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId + "&error=ownerLeaveDenied");
        return;
    }

    boolean left = memberDao.leaveCafe(cafeId, currentLoginId);
    response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId="
            + cafeId + (left ? "&leave=success" : "&error=leaveFail"));
%>
