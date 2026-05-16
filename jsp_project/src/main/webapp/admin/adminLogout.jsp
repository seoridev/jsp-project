<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	//관리자 세션 값만 지우고 관리자 로그인 화면으로 돌아감
	session.removeAttribute("adminLoginId");
	session.removeAttribute("adminName");
	response.sendRedirect(request.getContextPath() + "/admin/adminLogin.jsp");
%>
