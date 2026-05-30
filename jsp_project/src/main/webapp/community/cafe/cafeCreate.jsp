<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>카페 만들기 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
<main class="cafe-write-wrap">
    <section class="cafe-write-panel">
        <%-- 카페 생성 입력 화면 --%>
        <div class="cafe-write-head">
            <p class="breadcrumb">
                <a href="<%= contextPath %>/community/communityHome.jsp">커뮤니티</a>
                <span>&gt;</span>
                <span>카페 만들기</span>
            </p>
            <h1>카페 만들기</h1>
            <p class="community-meta">지역과 주제가 드러나는 카페 정보를 입력하세요.</p>
        </div>
        <% if ("duplicate".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">이미 사용 중인 카페명입니다.</p>
        <% } else if ("fail".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">카페 생성에 실패했습니다.</p>
        <% } %>
        <form class="cafe-write-form" action="<%= contextPath %>/community/cafe/cafeCreateProcess.jsp" method="post" id="cafeCreateForm">
            <div class="field" id="cafeNameField">
                <label for="cafeName">카페명</label>
                <div class="inline-check">
                    <input id="cafeName" class="write-title-input" name="cafeName" maxlength="100" required>
                    <button type="button" id="checkCafeNameButton">중복 확인</button>
                </div>
                <p class="field-message" id="cafeNameMessage" aria-live="polite"></p>
            </div>
            <div class="field">
                <label for="description">소개</label>
                <input id="description" name="description" maxlength="500" required>
            </div>
            <div class="field">
                <label for="region">지역</label>
                <input id="region" name="region" maxlength="100" value="<%= escapeHtml(loginRegion) %>" required>
            </div>
            <div class="field">
                <label for="category">주제</label>
                <input id="category" name="category" maxlength="50" placeholder="독서, 반려동물, 동네 소식" required>
            </div>
            <div class="field">
                <label for="visibility">공개 범위</label>
                <select id="visibility" name="visibility">
                    <option value="PUBLIC">공개</option>
                    <option value="PRIVATE">비공개</option>
                </select>
            </div>
            <div class="field">
                <label for="joinType">가입 방식</label>
                <select id="joinType" name="joinType">
                    <option value="DIRECT">바로 가입</option>
                    <option value="APPROVAL">승인 가입</option>
                </select>
            </div>
            <div class="write-actions">
                <a class="button btn-sub" href="<%= contextPath %>/community/communityHome.jsp">취소</a>
                <button class="btn-main" type="submit">생성하기</button>
            </div>
        </form>
    </section>
</main>
<%@ include file="../../common/footer.jsp" %>
<script>
const cafeCreateForm = document.getElementById("cafeCreateForm");
const cafeName = document.getElementById("cafeName");
const cafeNameField = document.getElementById("cafeNameField");
const cafeNameMessage = document.getElementById("cafeNameMessage");
const checkCafeNameButton = document.getElementById("checkCafeNameButton");
const contextPath = "<%= request.getContextPath() %>";
let cafeNameCheckState = {
    value: "",
    checked: false,
    available: false
};

function setCafeNameState(message, type) {
    const isError = type === "error" && message !== "";

    cafeNameMessage.textContent = message;
    cafeNameMessage.className = "field-message";
    if (message !== "") {
        cafeNameMessage.classList.add(type === "success" ? "is-success" : "is-error");
    }

    cafeNameField.classList.toggle("is-invalid", isError);
}

function resetCafeNameCheck() {
    cafeNameCheckState = {
        value: "",
        checked: false,
        available: false
    };
}

function validateCafeNameRule() {
    const value = cafeName.value.trim();

    if (value === "") {
        return "카페명을 입력해 주세요.";
    }

    if (value.length > 100) {
        return "카페명은 100자 이하로 입력해 주세요.";
    }

    return "";
}

async function checkCafeNameDuplicate() {
    const ruleMessage = validateCafeNameRule();
    const value = cafeName.value.trim();

    if (ruleMessage !== "") {
        resetCafeNameCheck();
        setCafeNameState(ruleMessage, "error");
        return false;
    }

    if (cafeNameCheckState.checked && cafeNameCheckState.value === value) {
        return cafeNameCheckState.available;
    }

    checkCafeNameButton.disabled = true;
    setCafeNameState("중복 확인 중입니다.", "success");

    try {
        const response = await fetch(contextPath + "/community/cafe/checkCafeName.jsp?cafeName="
            + encodeURIComponent(value), {
            headers: { "Accept": "application/json" }
        });
        const result = await response.json();

        if (cafeName.value.trim() !== value) {
            resetCafeNameCheck();
            setCafeNameState("", "error");
            return false;
        }

        const available = result.valid === true && result.duplicate === false;
        cafeNameCheckState = { value, checked: true, available };
        setCafeNameState(result.message || "", available ? "success" : "error");
        return available;
    } catch (error) {
        resetCafeNameCheck();
        setCafeNameState("중복 확인 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.", "error");
        return false;
    } finally {
        checkCafeNameButton.disabled = false;
    }
}

cafeName.addEventListener("input", () => {
    resetCafeNameCheck();
    setCafeNameState("", "error");
});

cafeName.addEventListener("blur", () => {
    if (cafeName.value.trim() !== "") {
        checkCafeNameDuplicate();
    }
});

checkCafeNameButton.addEventListener("click", () => checkCafeNameDuplicate());

cafeCreateForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    if (!await checkCafeNameDuplicate()) {
        cafeName.focus();
        return;
    }

    cafeCreateForm.submit();
});
</script>
</body>
</html>
