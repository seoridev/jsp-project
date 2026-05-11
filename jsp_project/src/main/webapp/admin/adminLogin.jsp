<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = request.getParameter("error");
String errorMessage = "";

if ("empty".equals(error)) {
    errorMessage = "아이디와 비밀번호를 입력해 주세요.";
} else if ("fail".equals(error)) {
    errorMessage = "아이디 또는 비밀번호가 맞지 않습니다.";
} else if ("loginRequired".equals(error)) {
    errorMessage = "관리자 로그인 후 이용할 수 있습니다.";
} else if ("db".equals(error)) {
    errorMessage = "지금은 로그인할 수 없습니다. 잠시 후 다시 시도해 주세요.";
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 로그인 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="auth-wrap">
    <section class="auth-panel">
        <h1>관리자 로그인</h1>
        <p>관리 메뉴를 이용하려면 로그인해 주세요.</p>

        <% if (!errorMessage.isEmpty()) { %>
            <p class="form-error-text"><%= errorMessage %></p>
        <% } %>

        <form class="form-grid" action="<%= contextPath %>/admin/adminLoginProcess.jsp" method="post">
            <div class="field">
                <label for="loginId">아이디</label>
                <input type="text" id="loginId" name="loginId" maxlength="50" required>
            </div>

            <div class="field">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" maxlength="100" required>
            </div>

            <div class="form-actions">
                <button class="primary" type="submit">로그인</button>
                <a class="button" href="<%= contextPath %>/index.jsp">메인으로</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
