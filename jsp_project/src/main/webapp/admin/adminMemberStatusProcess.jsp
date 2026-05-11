<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
private boolean isAllowedStatus(String status) {
    return "ACTIVE".equals(status) || "STOPPED".equals(status) || "WITHDRAWN".equals(status);
}
%>
<%
request.setCharacterEncoding("UTF-8");

String loginId = request.getParameter("loginId");
String status = request.getParameter("status");
String contextPath = request.getContextPath();

if (loginId == null || loginId.trim().isEmpty() || !isAllowedStatus(status)) {
    response.sendRedirect(contextPath + "/admin/adminMemberList.jsp?result=fail");
    return;
}

try {
    boolean updated = new MemberDAO().updateMemberStatus(loginId.trim(), status);
    response.sendRedirect(contextPath + "/admin/adminMemberList.jsp?result=" + (updated ? "success" : "fail"));
} catch (Exception e) {
    response.sendRedirect(contextPath + "/admin/adminMemberList.jsp?result=fail");
}
%>
