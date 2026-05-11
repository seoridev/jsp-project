<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
session.removeAttribute("adminLoginId");
session.removeAttribute("adminName");
response.sendRedirect(request.getContextPath() + "/admin/adminLogin.jsp");
%>
