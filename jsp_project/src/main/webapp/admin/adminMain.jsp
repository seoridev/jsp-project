<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%
String adminName = (String) session.getAttribute("adminName");
MemberDAO.MemberStats stats = new MemberDAO.MemberStats();
String statsError = "";

try {
    stats = new MemberDAO().getMemberStats();
} catch (Exception e) {
    statsError = "회원 통계를 불러오지 못했습니다.";
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-2">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1><%= escapeHtml(adminName == null ? "관리자" : adminName) %>님</h1>
        </div>
        <a class="button" href="<%= contextPath %>/admin/adminLogout.jsp">로그아웃</a>
    </div>

    <% if (!statsError.isEmpty()) { %>
        <p class="form-error-text"><%= statsError %></p>
    <% } %>

    <section class="admin-summary">
        <div>
            <span>전체 회원</span>
            <strong><%= stats.getTotalCount() %></strong>
        </div>
        <div>
            <span>정상 회원</span>
            <strong><%= stats.getActiveCount() %></strong>
        </div>
        <div>
            <span>이용 제한</span>
            <strong><%= stats.getStoppedCount() %></strong>
        </div>
        <div>
            <span>오늘 가입</span>
            <strong><%= stats.getTodayJoinCount() %></strong>
        </div>
    </section>

    <nav class="admin-menu" aria-label="관리 메뉴">
        <a href="<%= contextPath %>/admin/adminMemberList.jsp">
            <strong>회원 관리</strong>
            <span>회원 검색, 상세 확인, 상태 변경을 처리합니다.</span>
        </a>
        <a href="<%= contextPath %>/admin/adminMemberList.jsp?status=STOPPED">
            <strong>제한 회원</strong>
            <span>이용 제한 상태인 회원만 빠르게 확인합니다.</span>
        </a>
        <a href="<%= contextPath %>/admin/adminMemberList.jsp?status=WITHDRAWN">
            <strong>탈퇴 처리 회원</strong>
            <span>탈퇴 처리된 회원 목록을 검토합니다.</span>
        </a>
    </nav>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
