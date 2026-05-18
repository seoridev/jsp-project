<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="DAO.AdminDAO" %>
<%@ page import="DTO.AdminDTO" %>
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

	//빈 값이면 DB 조회 전에 로그인 화면으로 이동
	if (isBlank(loginId) || isBlank(password)) {
	    response.sendRedirect(contextPath + "/admin/adminLogin.jsp?error=empty");
	    return;
	}

	try {
	    AdminDAO adminDAO = new AdminDAO();
	    AdminDTO admin = adminDAO.login(loginId.trim(), password);

	    //관리자 계정이 없거나 비밀번호가 다르면 실패 처리
	    if (admin == null) {
	        response.sendRedirect(contextPath + "/admin/adminLogin.jsp?error=fail");
	        return;
	    }

	    //관리자 화면에서 쓸 정보만 세션에 저장
	    session.setAttribute("adminLoginId", admin.getLoginId());
	    session.setAttribute("adminName", admin.getName());
	    session.setMaxInactiveInterval(60 * 30);

	    response.sendRedirect(contextPath + "/admin/adminMain.jsp");
	} catch (Exception e) {
	    response.sendRedirect(contextPath + "/admin/adminLogin.jsp?error=db");
	}
%>
