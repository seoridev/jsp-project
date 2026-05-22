<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
    String currentLoginId = (String) session.getAttribute("loginId");
    MemberDTO member = new MemberDAO().getMemberByLoginId(currentLoginId);
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 정보 수정 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=mypage-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="auth-wrap">
    <section class="auth-panel">
        <h1>내 정보 수정</h1>
        <% if ("empty".equals(error)) { %>
            <script>
                (() => {
                    alert("닉네임과 동네는 필수 정보입니다.");
                    const url = new URL(window.location.href);
                    url.searchParams.delete("error");
                    window.history.replaceState({}, "", url);
                })();
            </script>
        <% } else if ("phoneDuplicate".equals(error)) { %>
            <script>
                (() => {
                    alert("이미 사용된 연락처입니다.");
                    const url = new URL(window.location.href);
                    url.searchParams.delete("error");
                    window.history.replaceState({}, "", url);
                })();
            </script>
        <% } else if ("fail".equals(error)) { %>
            <script>
                (() => {
                    alert("정보 수정에 실패했습니다.");
                    const url = new URL(window.location.href);
                    url.searchParams.delete("error");
                    window.history.replaceState({}, "", url);
                })();
            </script>
        <% } %>
        <form class="form-grid" action="<%= contextPath %>/mypage/profileEditProcess.jsp" method="post">
            <div class="field">
                <label for="nickname">닉네임</label>
                <input id="nickname" name="nickname" value="<%= escapeHtml(member == null ? "" : member.getNickname()) %>" required>
            </div>
            <div class="field">
                <label for="phone">연락처</label>
                <input id="phone" name="phone" value="<%= escapeHtml(member == null ? "" : member.getPhone()) %>">
            </div>
            <div class="field">
                <label for="region">동네</label>
                <input id="region" name="region" value="<%= escapeHtml(member == null ? "" : member.getRegion()) %>" required>
            </div>
            <div class="field">
                <label for="profileText">소개</label>
                <input id="profileText" name="profileText" value="<%= escapeHtml(member == null ? "" : member.getProfileText()) %>">
            </div>
            <div class="form-actions">
                <button class="primary" type="submit">저장</button>
                <a class="button" href="<%= contextPath %>/mypage/mypage.jsp">취소</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
