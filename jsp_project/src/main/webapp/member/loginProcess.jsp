<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%!
	private boolean isBlank(String value) {
	    return value == null || value.trim().isEmpty();
	}

	private boolean isSafeRedirect(String value) {
	    return value != null
	            && value.startsWith("/")
	            && !value.startsWith("//")
	            && !value.contains("://")
	            && !value.contains("\\")
	            && !value.contains("\r")
	            && !value.contains("\n");
	}

	private String encodeParam(String value) {
	    try {
	        return java.net.URLEncoder.encode(value, "UTF-8");
	    } catch (Exception e) {
	        return "";
	    }
	}

	private String loginRedirect(String contextPath, String error, String redirect) {
	    String target = contextPath + "/member/login.jsp?error=" + error;
	    if (isSafeRedirect(redirect)) {
	        target += "&redirect=" + encodeParam(redirect);
	    }
	    return target;
	}
%>
<%
	request.setCharacterEncoding("UTF-8");

	String loginId = request.getParameter("loginId");
	String password = request.getParameter("password");
	String redirect = request.getParameter("redirect");
	String contextPath = request.getContextPath();

	//빈 값이면 DB 조회 전에 로그인 화면으로 이동
	if (isBlank(loginId) || isBlank(password)) {
	    response.sendRedirect(loginRedirect(contextPath, "empty", redirect));
	    return;
	}

	MemberDAO memberDAO = new MemberDAO();

	try {
	    MemberDTO savedMember = memberDAO.getMemberByLoginId(loginId.trim());

	    //계정 상태에 따라 다른 안내 문구 사용
	    if (savedMember == null) {
	        response.sendRedirect(loginRedirect(contextPath, "noMember", redirect));
	        return;
	    }

	    if (savedMember.getStatus() != null && !"ACTIVE".equalsIgnoreCase(savedMember.getStatus())) {
	        response.sendRedirect(loginRedirect(contextPath, "stopped", redirect));
	        return;
	    }

	    MemberDTO loginMember = memberDAO.login(loginId.trim(), password);
	    if (loginMember == null) {
	        response.sendRedirect(loginRedirect(contextPath, "password", redirect));
	        return;
	    }

	    //메인과 헤더에서 쓸 회원 정보만 세션에 저장
	    session.setAttribute("loginId", loginMember.getLoginId());
	    session.setAttribute("loginNickname", loginMember.getNickname());
	    session.setAttribute("loginRegion", loginMember.getRegion());
	    session.setMaxInactiveInterval(60 * 30);

	    response.sendRedirect(isSafeRedirect(redirect) ? contextPath + redirect : contextPath + "/index.jsp");
	} catch (Exception e) {
	    response.sendRedirect(loginRedirect(contextPath, "db", redirect));
	}
%>
