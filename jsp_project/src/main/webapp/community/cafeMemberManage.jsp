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
<main class="page-shell manage-shell">
    <section class="manage-header">
        <div>
            <p class="breadcrumb"><a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(cafe.getCafeName()) %></a></p>
            <h1>회원 관리</h1>
        </div>
        <a class="button btn-sub" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>">카페로 돌아가기</a>
    </section>

    <% if ("success".equals(request.getParameter("approve"))) { %>
        <p class="notice-toast">가입 신청을 승인했습니다.</p>
    <% } else if ("success".equals(request.getParameter("reject"))) { %>
        <p class="notice-toast">가입 신청을 거절했습니다.</p>
    <% } else if ("approveFail".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">승인할 수 없는 신청입니다.</p>
    <% } else if ("rejectFail".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">거절할 수 없는 신청입니다.</p>
    <% } else if ("manageDenied".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">카페 관리 권한이 없습니다.</p>
    <% } else if (request.getParameter("error") != null) { %>
        <p class="field-message is-error">회원 처리에 실패했습니다.</p>
    <% } %>

    <section class="manage-layout">
        <aside class="manage-sidebar">
            <div class="manage-sidebar-title">카페 관리</div>
            <nav class="manage-menu" aria-label="카페 관리 메뉴">
                <a href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                <a class="active" href="<%= contextPath %>/community/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                <a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>">카페로 돌아가기</a>
            </nav>
        </aside>

        <section class="manage-content">
            <section class="manage-summary-grid">
                <div class="manage-summary-card">
                    <span>승인 대기</span>
                    <strong><%= pendingMembers.size() %></strong>
                </div>
                <div class="manage-summary-card">
                    <span>전체 회원</span>
                    <strong><%= cafeMembers.size() %></strong>
                </div>
            </section>

            <section class="manage-card">
                <div class="manage-card-head">
                    <div>
                        <h2>승인 대기 회원</h2>
                        <p>가입 신청을 확인하고 승인 또는 거절할 수 있습니다.</p>
                    </div>
                    <span class="status-badge is-pending">승인 필요 <%= pendingMembers.size() %>명</span>
                </div>
                <div class="manage-table-wrap">
                    <table class="manage-table member-manage-table">
                        <thead>
                            <tr>
                                <th>닉네임</th>
                                <th>아이디</th>
                                <th>지역</th>
                                <th>가입일</th>
                                <th>상태</th>
                                <th>관리</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (pendingMembers.isEmpty()) { %>
                                <tr>
                                    <td class="empty-cell" colspan="6">승인 대기 중인 회원이 없습니다.</td>
                                </tr>
                            <% } %>
                            <% for (CafeMemberDTO member : pendingMembers) { %>
                                <tr>
                                    <td><strong><%= escapeHtml(member.getNickname() == null ? member.getMemberId() : member.getNickname()) %></strong></td>
                                    <td><%= escapeHtml(member.getMemberId()) %></td>
                                    <td><%= escapeHtml(formatKoreanSigungu(member.getRegion())) %></td>
                                    <td><%= escapeHtml(formatDateTime(member.getJoinedAt())) %></td>
                                    <td><span class="status-badge is-pending">승인 필요</span></td>
                                    <td>
                                        <div class="manage-actions">
                                            <form action="<%= contextPath %>/community/memberApproveProcess.jsp" method="post">
                                                <input type="hidden" name="cafeId" value="<%= cafeId %>">
                                                <input type="hidden" name="memberId" value="<%= escapeHtml(member.getMemberId()) %>">
                                                <button class="btn-main btn-small" type="submit">승인</button>
                                            </form>
                                            <form action="<%= contextPath %>/community/memberRejectProcess.jsp" method="post">
                                                <input type="hidden" name="cafeId" value="<%= cafeId %>">
                                                <input type="hidden" name="memberId" value="<%= escapeHtml(member.getMemberId()) %>">
                                                <button class="btn-danger btn-small" type="submit">거절</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>

            <section class="manage-card">
                <div class="manage-card-head">
                    <div>
                        <h2>전체 회원</h2>
                        <p>카페에 등록된 회원의 역할과 상태를 확인합니다.</p>
                    </div>
                    <span class="status-badge">총 <%= cafeMembers.size() %>명</span>
                </div>
                <div class="manage-table-wrap">
                    <table class="manage-table member-manage-table">
                        <thead>
                            <tr>
                                <th>닉네임</th>
                                <th>아이디</th>
                                <th>지역</th>
                                <th>가입일</th>
                                <th>역할</th>
                                <th>상태</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (cafeMembers.isEmpty()) { %>
                                <tr>
                                    <td class="empty-cell" colspan="6">회원이 없습니다.</td>
                                </tr>
                            <% } %>
                            <% for (CafeMemberDTO member : cafeMembers) { %>
                                <tr>
                                    <td><strong><%= escapeHtml(member.getNickname() == null ? member.getMemberId() : member.getNickname()) %></strong></td>
                                    <td><%= escapeHtml(member.getMemberId()) %></td>
                                    <td><%= escapeHtml(formatKoreanSigungu(member.getRegion())) %></td>
                                    <td><%= escapeHtml(formatDateTime(member.getJoinedAt())) %></td>
                                    <td><span class="status-badge"><%= escapeHtml(member.getRole()) %></span></td>
                                    <td><span class="status-badge<%= statusClass(member.getStatus()) %>"><%= escapeHtml(statusText(member.getStatus())) %></span></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </section>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
