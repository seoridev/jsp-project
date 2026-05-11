<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
private String statusLabel(String status) {
    if ("STOPPED".equalsIgnoreCase(status)) {
        return "제한";
    }
    if ("WITHDRAWN".equalsIgnoreCase(status)) {
        return "탈퇴";
    }
    return "정상";
}
%>
<%
List<MemberDTO> members = null;
String listError = "";
String result = request.getParameter("result");
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

try {
    members = new MemberDAO().getAllMembers();
} catch (Exception e) {
    listError = "회원 목록을 불러오지 못했습니다.";
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>회원 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">관리자 홈</a>
            <a class="button" href="<%= contextPath %>/admin/adminLogout.jsp">로그아웃</a>
        </div>
    </div>

    <% if ("success".equals(result)) { %>
        <p class="form-success-text">회원 상태를 변경했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="form-error-text">회원 상태를 변경하지 못했습니다.</p>
    <% } %>

    <% if (!listError.isEmpty()) { %>
        <p class="form-error-text"><%= listError %></p>
    <% } else { %>
        <div class="admin-table-wrap">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>아이디</th>
                        <th>닉네임</th>
                        <th>연락처</th>
                        <th>동네</th>
                        <th>상태</th>
                        <th>가입일</th>
                        <th>변경</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (MemberDTO member : members) { %>
                        <tr>
                            <td><%= escapeHtml(member.getLoginId()) %></td>
                            <td><%= escapeHtml(member.getNickname()) %></td>
                            <td><%= escapeHtml(member.getPhone()) %></td>
                            <td><%= escapeHtml(member.getRegion()) %></td>
                            <td><span class="status-badge"><%= statusLabel(member.getStatus()) %></span></td>
                            <td><%= member.getCreatedAt() == null ? "-" : dateFormat.format(member.getCreatedAt()) %></td>
                            <td>
                                <form class="inline-form" action="<%= contextPath %>/admin/adminMemberStatusProcess.jsp" method="post">
                                    <input type="hidden" name="loginId" value="<%= escapeHtml(member.getLoginId()) %>">
                                    <select name="status" aria-label="회원 상태">
                                        <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(member.getStatus()) || member.getStatus() == null ? "selected" : "" %>>정상</option>
                                        <option value="STOPPED" <%= "STOPPED".equalsIgnoreCase(member.getStatus()) ? "selected" : "" %>>제한</option>
                                        <option value="WITHDRAWN" <%= "WITHDRAWN".equalsIgnoreCase(member.getStatus()) ? "selected" : "" %>>탈퇴</option>
                                    </select>
                                    <button type="submit">저장</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
