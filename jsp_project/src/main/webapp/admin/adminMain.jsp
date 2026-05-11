<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%
String adminName = (String) session.getAttribute("adminName");
int memberCount = 0;
int stoppedCount = 0;

try {
    List<MemberDTO> members = new MemberDAO().getAllMembers();
    memberCount = members.size();
    for (MemberDTO member : members) {
        if ("STOPPED".equalsIgnoreCase(member.getStatus())) {
            stoppedCount++;
        }
    }
} catch (Exception ignored) {
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-1">
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

    <section class="admin-summary">
        <div>
            <span>전체 회원</span>
            <strong><%= memberCount %></strong>
        </div>
        <div>
            <span>이용 제한</span>
            <strong><%= stoppedCount %></strong>
        </div>
    </section>

    <nav class="admin-menu" aria-label="관리 메뉴">
        <a href="<%= contextPath %>/admin/adminMemberList.jsp">
            <strong>회원 관리</strong>
            <span>회원 상태를 확인하고 변경합니다.</span>
        </a>
        <a href="<%= contextPath %>/admin/adminMain.jsp">
            <strong>상품 관리</strong>
            <span>상품의 상태를 확인하고 변경합니다.</span>
        </a>
        <a href="<%= contextPath %>/admin/adminMain.jsp">
            <strong>신고 관리</strong>
            <span>신고 상태를 확인하고 변경합니다.</span>
        </a>
    </nav>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
