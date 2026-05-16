<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dao.ReportDAO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%
    String adminName = (String) session.getAttribute("adminName");
    MemberDAO.MemberStats stats = new MemberDAO.MemberStats();
    int waitingReports = 0;
    String statsError = "";

    try {
        stats = new MemberDAO().getMemberStats();
        waitingReports = new ReportDAO().countWaitingReports();
    } catch (Exception e) {
        statsError = "관리자 통계를 불러오지 못했습니다.";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-4">
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
        <div><span>전체 회원</span><strong><%= stats.getTotalCount() %></strong></div>
        <div><span>정상 회원</span><strong><%= stats.getActiveCount() %></strong></div>
        <div><span>대기 신고</span><strong><%= waitingReports %></strong></div>
    </section>

    <nav class="admin-menu" aria-label="관리 메뉴">
        <a href="<%= contextPath %>/admin/adminMemberList.jsp">
            <strong>회원 관리</strong>
            <span>회원 검색, 상세 확인, 상태 변경을 처리합니다.</span>
        </a>
        <a href="<%= contextPath %>/admin/adminProductList.jsp">
            <strong>상품 관리</strong>
            <span>전체 상품을 확인하고 판매 상태나 숨김 상태를 변경합니다.</span>
        </a>
        <a href="<%= contextPath %>/admin/adminReportList.jsp">
            <strong>신고 관리</strong>
            <span>신고 내용을 확인하고 완료, 반려, 상품 숨김 처리를 합니다.</span>
        </a>
    </nav>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
