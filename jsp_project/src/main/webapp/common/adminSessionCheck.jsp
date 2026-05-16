<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	//관리자 로그인 세션이 있을 때만 접근 허용
	if (session.getAttribute("adminLoginId") == null) {
	    response.sendRedirect(request.getContextPath() + "/admin/adminLogin.jsp?error=loginRequired");
	    return;
	}
%>
