<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
	private String escapeHtml(String value) {
	    if (value == null) {
	        return "";
	    }
	    return value
	        .replace("&", "&amp;")
	        .replace("<", "&lt;")
	        .replace(">", "&gt;")
	        .replace("\"", "&quot;")
	        .replace("'", "&#39;");
	}
%>
<%
	//공통 헤더에서 쓸 세션 값 준비
	request.setCharacterEncoding("UTF-8");
	response.setContentType("text/html; charset=UTF-8");
	response.setCharacterEncoding("UTF-8");

	String contextPath = request.getContextPath();
	String loginId = (String) session.getAttribute("loginId");
	String loginNickname = (String) session.getAttribute("loginNickname");
	String loginRegion = (String) session.getAttribute("loginRegion");
	boolean loggedIn = loginId != null;
%>
<%-- 로그인 여부에 따라 상단 메뉴 변경 --%>
<header class="site-header">
    <a class="brand" href="<%= contextPath %>/index.jsp">
        <span class="brand-mark">D</span>
        <span>동네마켓</span>
    </a>
    <nav class="top-nav" aria-label="주요 메뉴">
        <a href="<%= contextPath %>/index.jsp">홈</a>
        <a href="<%= contextPath %>/product/productList.jsp">상품 목록</a>
        <% if (loggedIn) { %>
            <a href="<%= contextPath %>/mypage/mypage.jsp">마이페이지</a>
            <a href="<%= contextPath %>/member/logout.jsp">로그아웃</a>
        <% } else { %>
            <a href="<%= contextPath %>/member/login.jsp">로그인</a>
            <a class="nav-primary" href="<%= contextPath %>/member/signup.jsp">회원가입</a>
        <% } %>
    </nav>
</header>
