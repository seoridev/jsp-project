<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
private String statusLabel(String status) {
    if ("STOPPED".equalsIgnoreCase(status)) {
        return "이용 제한";
    }
    if ("WITHDRAWN".equalsIgnoreCase(status)) {
        return "탈퇴 처리";
    }
    return "정상";
}

private String statusClass(String status) {
    if ("STOPPED".equalsIgnoreCase(status)) {
        return " is-stopped";
    }
    if ("WITHDRAWN".equalsIgnoreCase(status)) {
        return " is-withdrawn";
    }
    return " is-active";
}

private String selected(String current, String expected) {
    return expected.equalsIgnoreCase(current) ? "selected" : "";
}

private int parsePage(String value) {
    try {
        return Math.max(Integer.parseInt(value), 1);
    } catch (Exception e) {
        return 1;
    }
}

private String encodeParam(String value) {
    try {
        return URLEncoder.encode(value == null ? "" : value, "UTF-8");
    } catch (Exception e) {
        return "";
    }
}

private String buildListQuery(String keyword, String status, int page) {
    return "keyword=" + encodeParam(keyword)
        + "&status=" + encodeParam(status)
        + "&page=" + page;
}
%>
<%
request.setCharacterEncoding("UTF-8");

String keyword = request.getParameter("keyword") == null ? "" : request.getParameter("keyword").trim();
String statusFilter = request.getParameter("status") == null ? "ALL" : request.getParameter("status").trim().toUpperCase();
if (!"ALL".equals(statusFilter) && !"ACTIVE".equals(statusFilter)
        && !"STOPPED".equals(statusFilter) && !"WITHDRAWN".equals(statusFilter)) {
    statusFilter = "ALL";
}

int pageNumber = parsePage(request.getParameter("page"));
int pageSize = 10;
int totalCount = 0;
int totalPages = 1;
List<MemberDTO> members = null;
String listError = "";
String result = request.getParameter("result");
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
MemberDAO memberDAO = new MemberDAO();

try {
    totalCount = memberDAO.countMembers(keyword, statusFilter);
    totalPages = Math.max((int) Math.ceil(totalCount / (double) pageSize), 1);
    if (pageNumber > totalPages) {
        pageNumber = totalPages;
    }
    members = memberDAO.searchMembers(keyword, statusFilter, pageNumber, pageSize);
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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-2">
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
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/adminLogout.jsp">로그아웃</a>
        </div>
    </div>

    <% if ("success".equals(result)) { %>
        <p class="form-success-text">회원 상태를 변경했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="form-error-text">회원 상태를 변경하지 못했습니다.</p>
    <% } %>

    <form class="admin-filter" action="<%= contextPath %>/admin/adminMemberList.jsp" method="get">
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" type="search" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="아이디, 닉네임, 연락처, 동네">
        </div>
        <div class="field">
            <label for="status">상태</label>
            <select id="status" name="status">
                <option value="ALL" <%= selected(statusFilter, "ALL") %>>전체</option>
                <option value="ACTIVE" <%= selected(statusFilter, "ACTIVE") %>>정상</option>
                <option value="STOPPED" <%= selected(statusFilter, "STOPPED") %>>이용 제한</option>
                <option value="WITHDRAWN" <%= selected(statusFilter, "WITHDRAWN") %>>탈퇴 처리</option>
            </select>
        </div>
        <button class="primary" type="submit">검색</button>
        <a class="button" href="<%= contextPath %>/admin/adminMemberList.jsp">초기화</a>
    </form>

    <% if (!listError.isEmpty()) { %>
        <p class="form-error-text"><%= listError %></p>
    <% } else { %>
        <div class="admin-list-meta">
            <span>총 <strong><%= totalCount %></strong>명</span>
            <span><%= pageNumber %> / <%= totalPages %> 페이지</span>
        </div>

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
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (members == null || members.isEmpty()) { %>
                        <tr>
                            <td class="empty-cell" colspan="7">조건에 맞는 회원이 없습니다.</td>
                        </tr>
                    <% } else { %>
                        <% for (MemberDTO member : members) { %>
                            <tr>
                                <td>
                                    <a class="table-link" href="<%= contextPath %>/admin/adminMemberDetail.jsp?loginId=<%= encodeParam(member.getLoginId()) %>&<%= buildListQuery(keyword, statusFilter, pageNumber) %>">
                                        <%= escapeHtml(member.getLoginId()) %>
                                    </a>
                                </td>
                                <td><%= escapeHtml(member.getNickname()) %></td>
                                <td><%= escapeHtml(member.getPhone()) %></td>
                                <td><%= escapeHtml(member.getRegion()) %></td>
                                <td><span class="status-badge<%= statusClass(member.getStatus()) %>"><%= statusLabel(member.getStatus()) %></span></td>
                                <td><%= member.getCreatedAt() == null ? "-" : dateFormat.format(member.getCreatedAt()) %></td>
                                <td>
                                    <form class="inline-form" action="<%= contextPath %>/admin/adminMemberStatusProcess.jsp" method="post">
                                        <input type="hidden" name="loginId" value="<%= escapeHtml(member.getLoginId()) %>">
                                        <input type="hidden" name="keyword" value="<%= escapeHtml(keyword) %>">
                                        <input type="hidden" name="statusFilter" value="<%= escapeHtml(statusFilter) %>">
                                        <input type="hidden" name="page" value="<%= pageNumber %>">
                                        <select name="status" aria-label="회원 상태">
                                            <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(member.getStatus()) || member.getStatus() == null ? "selected" : "" %>>정상</option>
                                            <option value="STOPPED" <%= "STOPPED".equalsIgnoreCase(member.getStatus()) ? "selected" : "" %>>이용 제한</option>
                                            <option value="WITHDRAWN" <%= "WITHDRAWN".equalsIgnoreCase(member.getStatus()) ? "selected" : "" %>>탈퇴 처리</option>
                                        </select>
                                        <button type="submit">저장</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>

        <% if (totalPages > 1) { %>
            <nav class="pagination" aria-label="회원 목록 페이지">
                <% if (pageNumber > 1) { %>
                    <a href="<%= contextPath %>/admin/adminMemberList.jsp?<%= buildListQuery(keyword, statusFilter, pageNumber - 1) %>">이전</a>
                <% } %>
                <% for (int i = 1; i <= totalPages; i++) { %>
                    <a class="<%= i == pageNumber ? "is-current" : "" %>" href="<%= contextPath %>/admin/adminMemberList.jsp?<%= buildListQuery(keyword, statusFilter, i) %>"><%= i %></a>
                <% } %>
                <% if (pageNumber < totalPages) { %>
                    <a href="<%= contextPath %>/admin/adminMemberList.jsp?<%= buildListQuery(keyword, statusFilter, pageNumber + 1) %>">다음</a>
                <% } %>
            </nav>
        <% } %>
    <% } %>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
