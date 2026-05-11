<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.AdminDAO" %>
<%@ page import="com.carrot.dto.AdminDTO" %>
<%!
private boolean isBlank(String value) {
    return value == null || value.trim().isEmpty();
}
%>
<%
request.setCharacterEncoding("UTF-8");

String loginId = request.getParameter("loginId");
String password = request.getParameter("password");
String contextPath = request.getContextPath();

if (isBlank(loginId) || isBlank(password)) {
    response.sendRedirect(contextPath + "/admin/adminLogin.jsp?error=empty");
    return;
}

try {
    AdminDAO adminDAO = new AdminDAO();
    AdminDTO admin = adminDAO.login(loginId.trim(), password);

    if (admin == null) {
        response.sendRedirect(contextPath + "/admin/adminLogin.jsp?error=fail");
        return;
    }

    session.setAttribute("adminLoginId", admin.getLoginId());
    session.setAttribute("adminName", admin.getName());
    session.setMaxInactiveInterval(60 * 30);

    response.sendRedirect(contextPath + "/admin/adminMain.jsp");
} catch (Exception e) {
    response.sendRedirect(contextPath + "/admin/adminLogin.jsp?error=db");
}
%>
