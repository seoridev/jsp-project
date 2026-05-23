<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/sessionCheck.jsp" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>카페 만들기 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="auth-wrap">
    <section class="auth-panel community-write-panel">
        <p class="eyebrow">커뮤니티</p>
        <h1>카페 만들기</h1>
        <p>이웃과 주제별 이야기를 나눌 동네 공간을 만들어보세요.</p>
        <% if ("duplicate".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">이미 사용 중인 카페명입니다.</p>
        <% } else if ("fail".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">카페 생성에 실패했습니다.</p>
        <% } %>
        <form class="form-grid" action="<%= contextPath %>/community/cafeCreateProcess.jsp" method="post">
            <div class="field">
                <label for="cafeName">카페명</label>
                <input id="cafeName" name="cafeName" maxlength="100" required>
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
            <div class="form-actions horizontal">
                <button class="btn-primary" type="submit">생성하기</button>
                <a class="button btn-secondary" href="<%= contextPath %>/community/communityHome.jsp">취소</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
