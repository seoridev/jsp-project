<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
if (session.getAttribute("loginId") == null) {
    response.sendRedirect(request.getContextPath() + "/member/login.jsp?error=loginRequired");
    return;
}
%>
