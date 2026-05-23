<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String statusText(String status) {
        if ("ACTIVE".equals(status)) return "활동";
        if ("PENDING".equals(status)) return "승인 대기";
        if ("REJECTED".equals(status)) return "거절";
        if ("BANNED".equals(status)) return "차단";
        if ("LEFT".equals(status)) return "탈퇴";
        return status == null ? "-" : status;
    }

    private String statusClass(String status) {
        if ("ACTIVE".equals(status)) return " is-active";
        if ("PENDING".equals(status) || "BANNED".equals(status)) return " is-stopped";
        return " is-withdrawn";
    }

    private String formatDateTime(java.time.LocalDateTime value) {
        return value == null ? "-" : value.toString().replace("T", " ");
    }
%>
<%
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    if (!memberDao.isCafeManagerOrOwner(cafeId, currentLoginId)) {
        response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + cafeId + "&error=manageDenied");
        return;
    }

    List<CafeMemberDTO> pendingMembers = memberDao.selectPendingMembers(cafeId);
    List<CafeMemberDTO> cafeMembers = memberDao.selectCafeMembers(cafeId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 관리 | <%= escapeHtml(cafe.getCafeName()) %></title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <p><a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(cafe.getCafeName()) %></a></p>
                <h1>회원 관리</h1>
                <p class="community-meta">승인 대기 <%= pendingMembers.size() %>명 · 전체 회원 <%= cafeMembers.size() %>명</p>
            </div>
        </div>
        <% if ("success".equals(request.getParameter("approve"))) { %>
            <p class="field-message is-success">가입 신청을 승인했습니다.</p>
        <% } else if ("success".equals(request.getParameter("reject"))) { %>
            <p class="field-message is-success">가입 신청을 거절했습니다.</p>
        <% } else if ("approveFail".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">승인할 수 없는 신청입니다.</p>
        <% } else if ("rejectFail".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">거절할 수 없는 신청입니다.</p>
        <% } else if ("manageDenied".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">카페 관리 권한이 없습니다.</p>
        <% } else if (request.getParameter("error") != null) { %>
            <p class="field-message is-error">회원 처리에 실패했습니다.</p>
        <% } %>
    </section>

    <section class="detail-panel">
        <h2>승인 대기</h2>
        <div class="community-list">
            <% if (pendingMembers.isEmpty()) { %>
                <p class="empty-cell">승인 대기 중인 회원이 없습니다.</p>
            <% } %>
            <% for (CafeMemberDTO member : pendingMembers) { %>
                <div class="community-row">
                    <span>
                        <strong><%= escapeHtml(member.getNickname() == null ? member.getMemberId() : member.getNickname()) %></strong>
                        <br>
                        <small class="community-meta"><%= escapeHtml(member.getMemberId()) %> · <%= escapeHtml(member.getRegion()) %></small>
                    </span>
                    <span class="form-actions">
                        <form action="<%= contextPath %>/community/memberApproveProcess.jsp" method="post">
                            <input type="hidden" name="cafeId" value="<%= cafeId %>">
                            <input type="hidden" name="memberId" value="<%= escapeHtml(member.getMemberId()) %>">
                            <button class="primary" type="submit">승인</button>
                        </form>
                        <form action="<%= contextPath %>/community/memberRejectProcess.jsp" method="post">
                            <input type="hidden" name="cafeId" value="<%= cafeId %>">
                            <input type="hidden" name="memberId" value="<%= escapeHtml(member.getMemberId()) %>">
                            <button type="submit">거절</button>
                        </form>
                    </span>
                </div>
            <% } %>
        </div>
    </section>

    <section class="detail-panel">
        <h2>전체 회원</h2>
        <div class="community-list">
            <% if (cafeMembers.isEmpty()) { %>
                <p class="empty-cell">회원이 없습니다.</p>
            <% } %>
            <% for (CafeMemberDTO member : cafeMembers) { %>
                <div class="community-row">
                    <span>
                        <strong><%= escapeHtml(member.getNickname() == null ? member.getMemberId() : member.getNickname()) %></strong>
                        <br>
                        <small class="community-meta">
                            <%= escapeHtml(member.getMemberId()) %> · <%= escapeHtml(member.getRegion()) %> · 가입일 <%= escapeHtml(formatDateTime(member.getJoinedAt())) %>
                        </small>
                    </span>
                    <span class="form-actions">
                        <span class="status-badge"><%= escapeHtml(member.getRole()) %></span>
                        <span class="status-badge<%= statusClass(member.getStatus()) %>"><%= escapeHtml(statusText(member.getStatus())) %></span>
                    </span>
                </div>
            <% } %>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
