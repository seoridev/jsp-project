<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
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
    String memberId = request.getParameter("memberId");
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();

    if (cafeId <= 0 || memberId == null || memberId.trim().isEmpty()
            || !memberDao.isCafeManagerOrOwner(cafeId, currentLoginId)) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId + "&error=manageDenied");
        return;
    }

    boolean approved = memberDao.approveMember(cafeId, memberId);
    response.sendRedirect(request.getContextPath() + "/community/member/cafeMemberManage.jsp?cafeId="
            + cafeId + (approved ? "&approve=success" : "&error=approveFail"));
%>
