<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	//회원 로그인 세션이 없으면 로그인 화면으로 이동
	if (session.getAttribute("loginId") == null) {
	    response.sendRedirect(request.getContextPath() + "/member/login.jsp?error=loginRequired");
	    return;
	}
%>
