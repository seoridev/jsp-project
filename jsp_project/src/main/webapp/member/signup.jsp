<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	//가입 결과에 맞는 안내 문구 설정
	String error = request.getParameter("error");
	String errorMessage = "";

	if ("empty".equals(error)) {
	    errorMessage = "필수 입력값을 모두 입력해 주세요.";
	} else if ("idRule".equals(error)) {
	    errorMessage = "아이디는 4~20자의 영문, 숫자만 사용할 수 있습니다.";
	} else if ("passwordRule".equals(error)) {
	    errorMessage = "비밀번호는 8~20자이며 영문과 숫자를 모두 포함해야 합니다.";
	} else if ("nicknameRule".equals(error)) {
	    errorMessage = "닉네임은 2~20자로 입력해 주세요.";
	} else if ("phoneRule".equals(error)) {
	    errorMessage = "연락처 뒷자리는 숫자 8자리로 입력해 주세요.";
	} else if ("regionRule".equals(error)) {
	    errorMessage = "동네는 2자 이상 입력해 주세요.";
	} else if ("duplicate".equals(error)) {
	    errorMessage = "이미 사용 중인 아이디입니다.";
	} else if ("password".equals(error)) {
	    errorMessage = "비밀번호와 비밀번호 확인이 일치하지 않습니다.";
	} else if ("db".equals(error)) {
	    errorMessage = "지금은 가입을 완료할 수 없습니다. 잠시 후 다시 시도해 주세요.";
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=phone-row-2">
</head>
<body>
<%@ include file="../common/header.jsp" %>
	<main class="auth-wrap">
	    <section class="auth-panel">
	        <h1>회원가입</h1>
	        <p>동네 이웃과 거래할 계정을 만들어 주세요.</p>

	        <%-- 서버 검증 메시지가 있으면 표시 --%>
	        <% if (!errorMessage.isEmpty()) { %>
	            <p class="form-error-text"><%= errorMessage %></p>
	        <% } %>
	        <p class="form-error-text" id="signupError" hidden></p>

	        <%-- 기본 입력 규칙 확인 후 처리 페이지로 전송 --%>
	        <form class="form-grid" action="<%= contextPath %>/member/signupProcess.jsp" method="post" id="signupForm" novalidate>
	            <div class="field">
	                <label for="loginId">아이디</label>
	                <input type="text" id="loginId" name="loginId" minlength="4" maxlength="20" required>
	                <small>4~20자의 영문, 숫자만 사용할 수 있습니다.</small>
	            </div>

	            <div class="field">
	                <label for="password">비밀번호</label>
	                <input type="password" id="password" name="password" minlength="8" maxlength="20" required>
	                <small>8~20자, 영문과 숫자를 모두 포함해 주세요.</small>
	            </div>

	            <div class="field">
	                <label for="passwordConfirm">비밀번호 확인</label>
	                <input type="password" id="passwordConfirm" name="passwordConfirm" minlength="8" maxlength="20" required>
	            </div>

	            <div class="field">
	                <label for="nickname">닉네임</label>
	                <input type="text" id="nickname" name="nickname" minlength="2" maxlength="20" required>
	            </div>

	            <div class="field">
	                <label for="phone">연락처</label>
	                <div class="phone-row">
	                    <select id="phonePrefix" name="phonePrefix" aria-label="연락처 앞자리">
	                        <option value="010">010</option>
	                        <option value="011">011</option>
	                        <option value="016">016</option>
	                        <option value="017">017</option>
	                        <option value="018">018</option>
	                        <option value="019">019</option>
	                    </select>
	                    <input type="text" id="phoneTail" name="phoneTail" inputmode="numeric" maxlength="9" placeholder="0000-0000">
	                </div>
	                <input type="hidden" id="phone" name="phone">
	            </div>

	            <div class="field">
	                <label for="region">동네</label>
	                <input type="text" id="region" name="region" minlength="2" maxlength="100" placeholder="예: 서울시 강남구 역삼동" required>
	            </div>

	            <div class="form-actions">
	                <button class="primary" type="submit">가입하기</button>
	            </div>
	        </form>

	        <p class="helper-link">이미 계정이 있나요? <a href="<%= contextPath %>/member/login.jsp">로그인</a></p>
	    </section>
	</main>
<%@ include file="../common/footer.jsp" %>
<script>
const signupForm = document.getElementById("signupForm");
const loginId = document.getElementById("loginId");
const password = document.getElementById("password");
const passwordConfirm = document.getElementById("passwordConfirm");
const nickname = document.getElementById("nickname");
const phonePrefix = document.getElementById("phonePrefix");
const phoneTail = document.getElementById("phoneTail");
const phone = document.getElementById("phone");
const region = document.getElementById("region");
const signupError = document.getElementById("signupError");

function showSignupError(message) {
    signupError.textContent = message;
    signupError.hidden = message === "";
}

//뒷자리 8자리를 0000-0000 형태로 맞춤
function formatPhoneTail(value) {
    const digits = value.replace(/[^0-9]/g, "").slice(0, 8);
    if (digits.length <= 4) {
        return digits;
    }
    return digits.slice(0, 4) + "-" + digits.slice(4);
}

function updatePhoneValue() {
    const digits = phoneTail.value.replace(/[^0-9]/g, "");
    phone.value = digits.length === 8 ? phonePrefix.value + "-" + phoneTail.value : "";
}

//보내기 전에 화면에서 한 번 더 확인
function validateSignup() {
    updatePhoneValue();

    if (!/^[A-Za-z0-9]{4,20}$/.test(loginId.value.trim())) {
        return "아이디는 4~20자의 영문, 숫자만 사용할 수 있습니다.";
    }

    if (!/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#$%^&*]{8,20}$/.test(password.value)) {
        return "비밀번호는 8~20자이며 영문과 숫자를 모두 포함해야 합니다.";
    }

    if (password.value !== passwordConfirm.value) {
        return "비밀번호 확인이 일치하지 않습니다.";
    }

    if (nickname.value.trim().length < 2 || nickname.value.trim().length > 20) {
        return "닉네임은 2~20자로 입력해 주세요.";
    }

    if (phoneTail.value.trim() !== "" && !/^[0-9]{4}-[0-9]{4}$/.test(phoneTail.value.trim())) {
        return "연락처 뒷자리는 숫자 8자리로 입력해 주세요.";
    }

    if (region.value.trim().length < 2) {
        return "동네는 2자 이상 입력해 주세요.";
    }

    return "";
}

phoneTail.addEventListener("input", () => {
    phoneTail.value = formatPhoneTail(phoneTail.value);
    updatePhoneValue();
});

phonePrefix.addEventListener("change", updatePhoneValue);

[loginId, password, passwordConfirm, nickname, phoneTail, region].forEach((input) => {
    input.addEventListener("input", () => showSignupError(""));
});

signupForm.addEventListener("submit", (event) => {
    const message = validateSignup();
    if (message !== "") {
        event.preventDefault();
        showSignupError(message);
    }
});
</script>
</body>
</html>
