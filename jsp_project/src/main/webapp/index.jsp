<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="common/header.jsp" %>
	<main class="page-shell">
	    <section class="home-layout">
	        <div class="hero-panel">
	            <p class="eyebrow">우리 동네 중고거래</p>
	            <h1>우리 동네에서 사고파는 중고거래</h1>
	            <p>
	                가까운 이웃과 필요한 물건을 나누고, 편하게 대화를 시작해 보세요.
	            </p>
	        </div>

	        <%-- 로그인 상태에 따라 메인 메뉴 변경 --%>
	        <aside class="status-panel">
	            <% if (loggedIn) { %>
	                <h2><%= escapeHtml(loginNickname) %>님, 반갑습니다.</h2>
	                <p>오늘도 좋은 거래를 만나보세요.</p>
	                <ul class="status-list">
	                    <li><span>아이디</span><strong><%= escapeHtml(loginId) %></strong></li>
	                    <li><span>활동 동네</span><strong><%= escapeHtml(loginRegion) %></strong></li>
	                </ul>
	                <a class="button primary" href="<%= contextPath %>/member/logout.jsp">로그아웃</a>
	            <% } else { %>
	                <h2>로그인이 필요합니다.</h2>
	                <p>동네 이웃과 거래하려면 먼저 계정에 로그인해 주세요.</p>
	                <div class="hero-actions">
	                    <a class="button primary" href="<%= contextPath %>/member/login.jsp">로그인</a>
	                    <a class="button" href="<%= contextPath %>/member/signup.jsp">회원가입</a>
	                </div>
	            <% } %>
	        </aside>
	    </section>
	</main>
<%@ include file="common/footer.jsp" %>
</body>
</html>
