<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	//실패 원인에 맞는 안내 문구 설정
	String error = request.getParameter("error");
	String title = "회원가입에 실패했습니다.";
	String message = "입력한 내용을 확인한 뒤 다시 시도해 주세요.";

	if ("empty".equals(error)) {
	    message = "아이디, 비밀번호, 닉네임, 동네는 반드시 입력해야 합니다.";
	} else if ("idRule".equals(error)) {
	    message = "아이디는 4~20자의 영문, 숫자만 사용할 수 있습니다.";
	} else if ("passwordRule".equals(error)) {
	    message = "비밀번호는 8~20자이며 영문과 숫자를 모두 포함해야 합니다.";
	} else if ("nicknameRule".equals(error)) {
	    message = "닉네임은 2~20자로 입력해 주세요.";
	} else if ("phoneRule".equals(error)) {
	    message = "연락처 뒷자리는 숫자 8자리로 입력해 주세요.";
	} else if ("regionRule".equals(error)) {
	    message = "동네는 2자 이상 입력해 주세요.";
	} else if ("password".equals(error)) {
	    message = "비밀번호와 비밀번호 확인 값이 서로 다릅니다.";
	} else if ("duplicate".equals(error)) {
	    message = "이미 사용 중인 아이디입니다. 다른 아이디로 가입해 주세요.";
	} else if ("db".equals(error)) {
	    message = "지금은 가입을 완료할 수 없습니다. 잠시 후 다시 시도해 주세요.";
	} else if ("fail".equals(error)) {
	    message = "가입이 완료되지 않았습니다. 잠시 후 다시 시도해 주세요.";
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 실패 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
	<main class="auth-wrap">
	    <section class="auth-panel">
	        <h1><%= title %></h1>
	        <p><%= message %></p>

	        <%-- 다시 입력하거나 메인으로 이동할 수 있게 처리 --%>
	        <div class="form-actions">
	            <a class="button primary" href="<%= contextPath %>/member/signup.jsp">다시 회원가입</a>
	            <a class="button" href="<%= contextPath %>/index.jsp">메인으로</a>
	        </div>
	    </section>
	</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
