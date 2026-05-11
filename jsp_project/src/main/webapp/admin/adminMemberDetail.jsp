<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.SimpleDateFormat" %>
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

private String encodeParam(String value) {
    try {
        return URLEncoder.encode(value == null ? "" : value, "UTF-8");
    } catch (Exception e) {
        return "";
    }
}

private String buildListQuery(String loginIdSearch, String nicknameSearch, String phoneSearch,
        String regionSearch, String status, String page) {
    return "loginIdSearch=" + encodeParam(loginIdSearch)
        + "&nicknameSearch=" + encodeParam(nicknameSearch)
        + "&phoneSearch=" + encodeParam(phoneSearch)
        + "&regionSearch=" + encodeParam(regionSearch)
        + "&status=" + encodeParam(status == null || status.isEmpty() ? "ALL" : status)
        + "&page=" + encodeParam(page == null || page.isEmpty() ? "1" : page);
}
%>
<%
request.setCharacterEncoding("UTF-8");

String loginIdParam = request.getParameter("loginId") == null ? "" : request.getParameter("loginId").trim();
String loginIdSearch = request.getParameter("loginIdSearch") == null ? "" : request.getParameter("loginIdSearch").trim();
String nicknameSearch = request.getParameter("nicknameSearch") == null ? "" : request.getParameter("nicknameSearch").trim();
String phoneSearch = request.getParameter("phoneSearch") == null ? "" : request.getParameter("phoneSearch").trim();
String regionSearch = request.getParameter("regionSearch") == null ? "" : request.getParameter("regionSearch").trim();
String statusFilter = request.getParameter("status") == null ? "ALL" : request.getParameter("status").trim().toUpperCase();
String pageNumber = request.getParameter("page") == null ? "1" : request.getParameter("page").trim();
String result = request.getParameter("result");
String detailError = "";
MemberDTO member = null;
SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");

if (loginIdParam.isEmpty()) {
    detailError = "회원을 선택해 주세요.";
} else {
    try {
        member = new MemberDAO().getMemberByLoginId(loginIdParam);
        if (member == null) {
            detailError = "회원을 찾을 수 없습니다.";
        }
    } catch (Exception e) {
        detailError = "회원 정보를 불러오지 못했습니다.";
    }
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 상세 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-2">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>회원 상세</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMemberList.jsp?<%= buildListQuery(loginIdSearch, nicknameSearch, phoneSearch, regionSearch, statusFilter, pageNumber) %>">목록</a>
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
        </div>
    </div>

    <% if ("success".equals(result)) { %>
        <p class="form-success-text">회원 상태를 변경했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="form-error-text">회원 상태를 변경하지 못했습니다.</p>
    <% } %>

    <% if (!detailError.isEmpty()) { %>
        <p class="form-error-text"><%= detailError %></p>
    <% } else { %>
        <section class="detail-panel">
            <div class="detail-header">
                <div>
                    <span class="status-badge<%= statusClass(member.getStatus()) %>"><%= statusLabel(member.getStatus()) %></span>
                    <h2><%= escapeHtml(member.getNickname()) %></h2>
                    <p><%= escapeHtml(member.getLoginId()) %></p>
                </div>
                <form class="inline-form detail-status-form" action="<%= contextPath %>/admin/adminMemberStatusProcess.jsp" method="post">
                    <input type="hidden" name="origin" value="detail">
                    <input type="hidden" name="loginId" value="<%= escapeHtml(member.getLoginId()) %>">
                    <input type="hidden" name="loginIdSearch" value="<%= escapeHtml(loginIdSearch) %>">
                    <input type="hidden" name="nicknameSearch" value="<%= escapeHtml(nicknameSearch) %>">
                    <input type="hidden" name="phoneSearch" value="<%= escapeHtml(phoneSearch) %>">
                    <input type="hidden" name="regionSearch" value="<%= escapeHtml(regionSearch) %>">
                    <input type="hidden" name="statusFilter" value="<%= escapeHtml(statusFilter) %>">
                    <input type="hidden" name="page" value="<%= escapeHtml(pageNumber) %>">
                    <select name="status" aria-label="회원 상태">
                        <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(member.getStatus()) || member.getStatus() == null ? "selected" : "" %>>정상</option>
                        <option value="STOPPED" <%= "STOPPED".equalsIgnoreCase(member.getStatus()) ? "selected" : "" %>>이용 제한</option>
                        <option value="WITHDRAWN" <%= "WITHDRAWN".equalsIgnoreCase(member.getStatus()) ? "selected" : "" %>>탈퇴 처리</option>
                    </select>
                    <button class="primary" type="submit">상태 저장</button>
                </form>
            </div>

            <dl class="detail-grid">
                <div>
                    <dt>연락처</dt>
                    <dd><%= member.getPhone() == null || member.getPhone().isEmpty() ? "-" : escapeHtml(member.getPhone()) %></dd>
                </div>
                <div>
                    <dt>동네</dt>
                    <dd><%= escapeHtml(member.getRegion()) %></dd>
                </div>
                <div>
                    <dt>매너 점수</dt>
                    <dd><%= String.format("%.1f", member.getMannerScore()) %></dd>
                </div>
                <div>
                    <dt>가입일</dt>
                    <dd><%= member.getCreatedAt() == null ? "-" : dateTimeFormat.format(member.getCreatedAt()) %></dd>
                </div>
                <div>
                    <dt>수정일</dt>
                    <dd><%= member.getUpdatedAt() == null ? "-" : dateTimeFormat.format(member.getUpdatedAt()) %></dd>
                </div>
                <div>
                    <dt>프로필</dt>
                    <dd><%= member.getProfileText() == null || member.getProfileText().isEmpty() ? "-" : escapeHtml(member.getProfileText()) %></dd>
                </div>
            </dl>
        </section>
    <% } %>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
