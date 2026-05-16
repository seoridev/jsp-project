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
	} else if ("duplicate".equals(error) || "duplicateId".equals(error)) {
	    errorMessage = "이미 사용 중인 아이디입니다.";
	} else if ("duplicateNickname".equals(error)) {
	    errorMessage = "이미 사용 중인 닉네임입니다.";
	} else if ("duplicatePhone".equals(error)) {
	    errorMessage = "이미 사용 중인 연락처입니다.";
	} else if ("duplicateUnique".equals(error)) {
	    errorMessage = "이미 사용 중인 아이디, 닉네임 또는 연락처입니다.";
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
	            <div class="field" id="loginIdField">
	                <label for="loginId">아이디</label>
	                <div class="inline-check">
	                    <input type="text" id="loginId" name="loginId" minlength="4" maxlength="20" autocomplete="username" required>
	                    <button type="button" id="checkLoginIdButton">중복 확인</button>
	                </div>
	                <small>4~20자의 영문, 숫자만 사용할 수 있습니다.</small>
	                <p class="field-message" id="loginIdMessage" aria-live="polite"></p>
	            </div>

	            <div class="field" id="passwordField">
	                <label for="password">비밀번호</label>
	                <input type="password" id="password" name="password" minlength="8" maxlength="20" autocomplete="new-password" required>
	                <small>8~20자, 영문과 숫자를 모두 포함해 주세요.</small>
	                <p class="field-message" id="passwordMessage" aria-live="polite"></p>
	            </div>

	            <div class="field" id="passwordConfirmField">
	                <label for="passwordConfirm">비밀번호 확인</label>
	                <input type="password" id="passwordConfirm" name="passwordConfirm" minlength="8" maxlength="20" autocomplete="new-password" required>
	                <p class="field-message" id="passwordConfirmMessage" aria-live="polite"></p>
	            </div>

	            <div class="field" id="nicknameField">
	                <label for="nickname">닉네임</label>
	                <div class="inline-check">
	                    <input type="text" id="nickname" name="nickname" minlength="2" maxlength="20" required>
	                    <button type="button" id="checkNicknameButton">중복 확인</button>
	                </div>
	                <p class="field-message" id="nicknameMessage" aria-live="polite"></p>
	            </div>

	            <div class="field" id="phoneField">
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
	                    <input type="text" id="phoneTail" name="phoneTail" inputmode="numeric" maxlength="9" placeholder="0000-0000" required>
	                </div>
	                <input type="hidden" id="phone" name="phone">
	                <p class="field-message" id="phoneMessage" aria-live="polite"></p>
	            </div>

	            <div class="field" id="regionField">
	                <label for="region">동네</label>
	                <input type="text" id="region" name="region" minlength="2" maxlength="100" placeholder="예: 서울시 강남구 역삼동" required>
	                <p class="field-message" id="regionMessage" aria-live="polite"></p>
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
const loginIdField = document.getElementById("loginIdField");
const passwordField = document.getElementById("passwordField");
const passwordConfirmField = document.getElementById("passwordConfirmField");
const nicknameField = document.getElementById("nicknameField");
const phoneField = document.getElementById("phoneField");
const regionField = document.getElementById("regionField");
const checkLoginIdButton = document.getElementById("checkLoginIdButton");
const checkNicknameButton = document.getElementById("checkNicknameButton");
const phonePrefix = document.getElementById("phonePrefix");
const phoneTail = document.getElementById("phoneTail");
const phone = document.getElementById("phone");
const region = document.getElementById("region");
const signupError = document.getElementById("signupError");
const loginIdMessage = document.getElementById("loginIdMessage");
const passwordMessage = document.getElementById("passwordMessage");
const passwordConfirmMessage = document.getElementById("passwordConfirmMessage");
const nicknameMessage = document.getElementById("nicknameMessage");
const phoneMessage = document.getElementById("phoneMessage");
const regionMessage = document.getElementById("regionMessage");
const contextPath = "<%= request.getContextPath() %>";
const duplicateState = {
    loginId: { value: "", checked: false, available: false },
    nickname: { value: "", checked: false, available: false },
    phone: { value: "", checked: false, available: true }
};

function showSignupError(message) {
    signupError.textContent = message;
    signupError.hidden = message === "";
}

function setFieldState(fieldElement, messageElement, message, type) {
    const isError = type === "error" && message !== "";

    messageElement.textContent = message;
    messageElement.className = "field-message";
    if (message !== "") {
        messageElement.classList.add(type === "success" ? "is-success" : "is-error");
    }

    fieldElement.classList.toggle("is-invalid", isError);
}

function clearFieldState(fieldElement, messageElement) {
    setFieldState(fieldElement, messageElement, "", "error");
}

function hasValue(input) {
    return input.value.trim() !== "";
}

function requiredMessage(input) {
    return hasValue(input) ? "" : "필수 정보입니다.";
}

function focusFirstInvalidField() {
    const invalidInput = signupForm.querySelector(".field.is-invalid input, .field.is-invalid select");
    if (invalidInput !== null) {
        invalidInput.focus();
    }
}

function validateLoginIdRule() {
    const required = requiredMessage(loginId);
    if (required !== "") {
        return required;
    }

    if (!/^[A-Za-z0-9]{4,20}$/.test(loginId.value.trim())) {
        return "4~20자의 영문, 숫자만 사용할 수 있습니다.";
    }

    return "";
}

function validatePasswordRule() {
    const required = requiredMessage(password);
    if (required !== "") {
        return required;
    }

    if (!/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#$%^&*]{8,20}$/.test(password.value)) {
        return "8~20자, 영문과 숫자를 모두 포함해 주세요.";
    }

    return "";
}

function validatePasswordConfirmRule() {
    const required = requiredMessage(passwordConfirm);
    if (required !== "") {
        return required;
    }

    if (password.value !== passwordConfirm.value) {
        return "비밀번호가 일치하지 않습니다.";
    }

    return "";
}

function validateNicknameRule() {
    const required = requiredMessage(nickname);
    if (required !== "") {
        return required;
    }

    const trimmedNickname = nickname.value.trim();
    if (trimmedNickname.length < 2 || trimmedNickname.length > 20) {
        return "닉네임은 2~20자로 입력해 주세요.";
    }

    return "";
}

function validatePhoneRule() {
    updatePhoneValue();

    const required = requiredMessage(phoneTail);
    if (required !== "") {
        return required;
    }

    if (phoneTail.value.trim() !== "" && !/^[0-9]{4}-[0-9]{4}$/.test(phoneTail.value.trim())) {
        return "연락처 뒷자리는 숫자 8자리로 입력해 주세요.";
    }

    return "";
}

function validateRegionRule() {
    const required = requiredMessage(region);
    if (required !== "") {
        return required;
    }

    if (region.value.trim().length < 2) {
        return "동네는 2자 이상 입력해 주세요.";
    }

    return "";
}

function resetDuplicateState(type) {
    duplicateState[type] = {
        value: "",
        checked: false,
        available: type === "phone"
    };
}

async function checkDuplicate(type) {
    const duplicateFields = {
        loginId: {
            fieldElement: loginIdField,
            messageElement: loginIdMessage,
            button: checkLoginIdButton,
            validate: validateLoginIdRule,
            getValue: () => loginId.value.trim()
        },
        nickname: {
            fieldElement: nicknameField,
            messageElement: nicknameMessage,
            button: checkNicknameButton,
            validate: validateNicknameRule,
            getValue: () => nickname.value.trim()
        },
        phone: {
            fieldElement: phoneField,
            messageElement: phoneMessage,
            button: null,
            validate: validatePhoneRule,
            getValue: () => phone.value.trim()
        }
    };
    const field = duplicateFields[type];
    const ruleMessage = field.validate();
    const value = field.getValue();

    if (ruleMessage !== "") {
        setFieldState(field.fieldElement, field.messageElement, ruleMessage, "error");
        resetDuplicateState(type);
        return false;
    }

    if (duplicateState[type].checked && duplicateState[type].value === value) {
        return duplicateState[type].available;
    }

    if (field.button !== null) {
        field.button.disabled = true;
    }
    setFieldState(field.fieldElement, field.messageElement, "중복 확인 중입니다.", "success");

    try {
        const response = await fetch(contextPath + "/member/checkDuplicate.jsp?type="
            + encodeURIComponent(type) + "&value=" + encodeURIComponent(value), {
            headers: { "Accept": "application/json" }
        });
        const result = await response.json();

        if (field.getValue() !== value) {
            resetDuplicateState(type);
            clearFieldState(field.fieldElement, field.messageElement);
            return false;
        }

        const available = result.valid === true && result.duplicate === false;
        const resultMessage = type === "phone" && result.duplicate === true
            ? "이미 사용된 연락처입니다."
            : (result.message || "");
        duplicateState[type] = { value, checked: true, available };
        setFieldState(field.fieldElement, field.messageElement, resultMessage, available ? "success" : "error");
        return available;
    } catch (error) {
        resetDuplicateState(type);
        setFieldState(field.fieldElement, field.messageElement, "중복 확인 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.", "error");
        return false;
    } finally {
        if (field.button !== null) {
            field.button.disabled = false;
        }
    }
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
    let isValid = true;

    let message = validateLoginIdRule();
    if (message !== "") {
        setFieldState(loginIdField, loginIdMessage, message, "error");
        isValid = false;
    } else if (!duplicateState.loginId.available) {
        clearFieldState(loginIdField, loginIdMessage);
    }

    message = validatePasswordRule();
    if (message !== "") {
        setFieldState(passwordField, passwordMessage, message, "error");
        isValid = false;
    } else {
        clearFieldState(passwordField, passwordMessage);
    }

    message = validatePasswordConfirmRule();
    if (message !== "") {
        setFieldState(passwordConfirmField, passwordConfirmMessage, message, "error");
        isValid = false;
    } else {
        clearFieldState(passwordConfirmField, passwordConfirmMessage);
    }

    message = validateNicknameRule();
    if (message !== "") {
        setFieldState(nicknameField, nicknameMessage, message, "error");
        isValid = false;
    } else if (!duplicateState.nickname.available) {
        clearFieldState(nicknameField, nicknameMessage);
    }

    message = validatePhoneRule();
    if (message !== "") {
        setFieldState(phoneField, phoneMessage, message, "error");
        isValid = false;
    } else if (duplicateState.phone.available) {
        clearFieldState(phoneField, phoneMessage);
    }

    message = validateRegionRule();
    if (message !== "") {
        setFieldState(regionField, regionMessage, message, "error");
        isValid = false;
    } else {
        clearFieldState(regionField, regionMessage);
    }

    return isValid;
}

phoneTail.addEventListener("input", () => {
    phoneTail.value = formatPhoneTail(phoneTail.value);
    updatePhoneValue();
    resetDuplicateState("phone");
    clearFieldState(phoneField, phoneMessage);
});

phonePrefix.addEventListener("change", () => {
    updatePhoneValue();
    resetDuplicateState("phone");
    clearFieldState(phoneField, phoneMessage);
});

loginId.addEventListener("input", () => {
    showSignupError("");
    resetDuplicateState("loginId");
    clearFieldState(loginIdField, loginIdMessage);
});

nickname.addEventListener("input", () => {
    showSignupError("");
    resetDuplicateState("nickname");
    clearFieldState(nicknameField, nicknameMessage);
});

password.addEventListener("input", () => {
    showSignupError("");
    clearFieldState(passwordField, passwordMessage);
    clearFieldState(passwordConfirmField, passwordConfirmMessage);
});

passwordConfirm.addEventListener("input", () => {
    showSignupError("");
    clearFieldState(passwordConfirmField, passwordConfirmMessage);
});

phoneTail.addEventListener("input", () => showSignupError(""));
region.addEventListener("input", () => {
    showSignupError("");
    clearFieldState(regionField, regionMessage);
});

loginId.addEventListener("blur", () => {
    checkDuplicate("loginId");
});

password.addEventListener("blur", () => {
    const message = validatePasswordRule();
    setFieldState(passwordField, passwordMessage, message, message === "" ? "success" : "error");

    if (passwordConfirm.value !== "") {
        const confirmMessage = validatePasswordConfirmRule();
        setFieldState(passwordConfirmField, passwordConfirmMessage, confirmMessage, confirmMessage === "" ? "success" : "error");
    }
});

passwordConfirm.addEventListener("blur", () => {
    const message = validatePasswordConfirmRule();
    setFieldState(passwordConfirmField, passwordConfirmMessage, message, message === "" ? "success" : "error");
});

nickname.addEventListener("blur", () => {
    checkDuplicate("nickname");
});

phoneTail.addEventListener("blur", () => {
    if (phoneTail.value.trim() !== "") {
        checkDuplicate("phone");
    }
});

region.addEventListener("blur", () => {
    const message = validateRegionRule();
    setFieldState(regionField, regionMessage, message, message === "" ? "success" : "error");
});

checkLoginIdButton.addEventListener("click", () => checkDuplicate("loginId"));
checkNicknameButton.addEventListener("click", () => checkDuplicate("nickname"));

signupForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    showSignupError("");

    if (!validateSignup()) {
        focusFirstInvalidField();
        return;
    }

    if (!await checkDuplicate("loginId")) {
        showSignupError("아이디 중복 확인을 완료해 주세요.");
        loginId.focus();
        return;
    }

    if (!await checkDuplicate("nickname")) {
        showSignupError("닉네임 중복 확인을 완료해 주세요.");
        nickname.focus();
        return;
    }

    if (!await checkDuplicate("phone")) {
        showSignupError("연락처를 다시 확인해 주세요.");
        phoneTail.focus();
        return;
    }

    signupForm.submit();
});
</script>
</body>
</html>
