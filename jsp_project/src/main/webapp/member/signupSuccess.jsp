<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>가입 완료 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
	<main class="auth-wrap">
	    <section class="auth-panel">
	        <h1>가입이 완료되었습니다.</h1>
	        <p>이제 동네 이웃과 거래를 시작할 수 있습니다.</p>

	        <%-- 가입 후 바로 로그인할 수 있게 처리 --%>
	        <div class="form-actions">
	            <a class="button primary" href="<%= contextPath %>/member/login.jsp">로그인하러 가기</a>
	            <a class="button" href="<%= contextPath %>/index.jsp">메인으로</a>
	        </div>
	    </section>
	</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
