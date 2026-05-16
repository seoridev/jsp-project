<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	//회원 로그아웃은 세션 전체 비움
	session.invalidate();
	response.sendRedirect(request.getContextPath() + "/index.jsp");
%>
