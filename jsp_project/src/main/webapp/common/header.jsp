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
	request.setCharacterEncoding("UTF-8");
	response.setContentType("text/html; charset=UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	String contextPath = request.getContextPath();
	String loginId = (String) session.getAttribute("loginId");
	String loginNickname = (String) session.getAttribute("loginNickname");
	String loginRegion = (String) session.getAttribute("loginRegion");
	boolean loggedIn = loginId != null;
%>
<header class="site-header">
    <a class="brand" href="<%= contextPath %>/index.jsp">
        <span class="brand-mark">D</span>
        <span>&#46041;&#45348;&#47560;&#53011;</span>
    </a>
    <nav class="top-nav" aria-label="&#51452;&#50836; &#47700;&#45684;">
        <a href="<%= contextPath %>/index.jsp">&#54856;</a>
        <% if (loggedIn) { %>
            <a href="<%= contextPath %>/member/logout.jsp">&#47196;&#44536;&#50500;&#50883;</a>
        <% } else { %>
            <a href="<%= contextPath %>/member/login.jsp">&#47196;&#44536;&#51064;</a>
            <a class="nav-primary" href="<%= contextPath %>/member/signup.jsp">&#54924;&#50896;&#44032;&#51077;</a>
        <% } %>
    </nav>
</header>
