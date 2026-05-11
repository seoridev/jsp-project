<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
if (session.getAttribute("adminLoginId") == null) {
    response.sendRedirect(request.getContextPath() + "/admin/adminLogin.jsp?error=loginRequired");
    return;
}
%>
