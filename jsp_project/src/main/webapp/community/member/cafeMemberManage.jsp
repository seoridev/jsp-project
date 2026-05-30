<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ page import="com.carrot.util.RegionFormatter" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%!
    // 회원 관리 화면 표시용 상태/등급 문구 변환
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

    private String roleText(String role) {
        if ("OWNER".equals(role)) return "운영자";
        if ("MANAGER".equals(role)) return "스탭";
        if ("MEMBER".equals(role)) return "회원";
        return role == null ? "-" : role;
    }

    private String selectedAttr(String value, String current) {
        return value.equals(current) ? " selected" : "";
    }

    private String formatDateTime(java.time.LocalDateTime value) {
        return value == null ? "-" : value.withNano(0).toString().replace("T", " ");
    }
%>
<%
    // 카페 관리자 권한 확인 후 회원 목록 조회
    int cafeId = ParamParser.parseInt(request.getParameter("cafeId"));
    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeList.jsp?error=noCafe");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    CafeMemberDTO currentMember = memberDao.selectCafeMember(cafeId, currentLoginId);
    if (currentMember == null || !"ACTIVE".equals(currentMember.getStatus())
            || (!"OWNER".equals(currentMember.getRole()) && !"MANAGER".equals(currentMember.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId + "&error=manageDenied");
        return;
    }

    String keyword = request.getParameter("keyword") == null ? "" : request.getParameter("keyword").trim();
    String roleFilter = request.getParameter("role") == null ? "ALL" : request.getParameter("role").trim().toUpperCase();
    String statusFilter = request.getParameter("status") == null ? "ALL" : request.getParameter("status").trim().toUpperCase();
    boolean cafeOwner = "OWNER".equals(currentMember.getRole());
    List<CafeMemberDTO> pendingMembers = memberDao.selectPendingMembers(cafeId);
    List<CafeMemberDTO> allCafeMembers = memberDao.selectCafeMembers(cafeId);
    List<CafeMemberDTO> cafeMembers = memberDao.selectCafeMembers(cafeId, keyword, roleFilter, statusFilter);
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
<%@ include file="../../common/header.jsp" %>
<main class="page-shell manage-shell">
    <section class="manage-header">
        <div>
            <p class="breadcrumb"><a href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(cafe.getCafeName()) %></a></p>
            <h1>회원 관리</h1>
        </div>
        <a class="button btn-sub" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafeId %>">카페로 돌아가기</a>
    </section>

    <% if ("success".equals(request.getParameter("approve"))) { %>
        <p class="notice-toast">가입 신청을 승인했습니다.</p>
    <% } else if ("success".equals(request.getParameter("reject"))) { %>
        <p class="notice-toast">가입 신청을 거절했습니다.</p>
    <% } else if ("role".equals(request.getParameter("memberAction"))) { %>
        <p class="notice-toast">회원 등급을 변경했습니다.</p>
    <% } else if ("kick".equals(request.getParameter("memberAction"))) { %>
        <p class="notice-toast">회원을 강퇴했습니다.</p>
    <% } else if ("ban".equals(request.getParameter("memberAction"))) { %>
        <p class="notice-toast">회원을 차단했습니다.</p>
    <% } else if ("unban".equals(request.getParameter("memberAction"))) { %>
        <p class="notice-toast">차단을 해제했습니다.</p>
    <% } else if ("approveFail".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">승인할 수 없는 신청입니다.</p>
    <% } else if ("rejectFail".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">거절할 수 없는 신청입니다.</p>
    <% } else if ("roleFail".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">등급을 변경할 수 없습니다.</p>
    <% } else if ("statusFail".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">회원 상태를 변경할 수 없습니다.</p>
    <% } else if ("manageDenied".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">카페 관리 권한이 없습니다.</p>
    <% } else if (request.getParameter("error") != null) { %>
        <p class="field-message is-error">회원 처리에 실패했습니다.</p>
    <% } %>

    <section class="manage-layout">
        <aside class="manage-sidebar">
            <div class="manage-sidebar-title">관리 메뉴</div>
            <nav class="manage-menu" aria-label="카페 관리 메뉴">
                <a href="<%= contextPath %>/community/cafe/cafeManage.jsp?cafeId=<%= cafeId %>">카페 관리</a>
                <a href="<%= contextPath %>/community/board/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                <a class="active" href="<%= contextPath %>/community/member/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                <a href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafeId %>">카페로 돌아가기</a>
            </nav>
        </aside>

        <section class="manage-content">
            <section class="manage-summary-grid member-summary-grid">
                <div class="manage-summary-card">
                    <span>승인 대기</span>
                    <strong><%= pendingMembers.size() %></strong>
                </div>
                <div class="manage-summary-card">
                    <span>전체 회원</span>
                    <strong><%= allCafeMembers.size() %></strong>
                </div>
                <div class="manage-summary-card">
                    <span>검색 결과</span>
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
                                    <td><%= escapeHtml(RegionFormatter.formatKoreanSigungu(member.getRegion())) %></td>
                                    <td><%= escapeHtml(formatDateTime(member.getJoinedAt())) %></td>
                                    <td><span class="status-badge is-pending">승인 필요</span></td>
                                    <td>
                                        <div class="manage-actions">
                                            <form action="<%= contextPath %>/community/member/memberApproveProcess.jsp" method="post">
                                                <input type="hidden" name="cafeId" value="<%= cafeId %>">
                                                <input type="hidden" name="memberId" value="<%= escapeHtml(member.getMemberId()) %>">
                                                <button class="btn-main btn-small" type="submit">승인</button>
                                            </form>
                                            <form action="<%= contextPath %>/community/member/memberRejectProcess.jsp" method="post">
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
                        <p>닉네임, 아이디, 등급, 상태로 회원을 찾고 관리합니다.</p>
                    </div>
                    <span class="status-badge">검색 결과 <%= cafeMembers.size() %>명</span>
                </div>
                <form class="member-filter-form" action="<%= contextPath %>/community/member/cafeMemberManage.jsp" method="get">
                    <input type="hidden" name="cafeId" value="<%= cafeId %>">
                    <label>
                        <span>검색</span>
                        <input name="keyword" placeholder="닉네임 또는 아이디" value="<%= escapeHtml(keyword) %>">
                    </label>
                    <label>
                        <span>등급</span>
                        <select name="role">
                            <option value="ALL"<%= selectedAttr("ALL", roleFilter) %>>전체</option>
                            <option value="OWNER"<%= selectedAttr("OWNER", roleFilter) %>>운영자</option>
                            <option value="MANAGER"<%= selectedAttr("MANAGER", roleFilter) %>>스탭</option>
                            <option value="MEMBER"<%= selectedAttr("MEMBER", roleFilter) %>>회원</option>
                        </select>
                    </label>
                    <label>
                        <span>상태</span>
                        <select name="status">
                            <option value="ALL"<%= selectedAttr("ALL", statusFilter) %>>전체</option>
                            <option value="ACTIVE"<%= selectedAttr("ACTIVE", statusFilter) %>>활동</option>
                            <option value="PENDING"<%= selectedAttr("PENDING", statusFilter) %>>승인 대기</option>
                            <option value="REJECTED"<%= selectedAttr("REJECTED", statusFilter) %>>거절</option>
                            <option value="BANNED"<%= selectedAttr("BANNED", statusFilter) %>>차단</option>
                            <option value="LEFT"<%= selectedAttr("LEFT", statusFilter) %>>탈퇴</option>
                        </select>
                    </label>
                    <button class="btn-main btn-small" type="submit">검색</button>
                    <a class="button btn-sub btn-small" href="<%= contextPath %>/community/member/cafeMemberManage.jsp?cafeId=<%= cafeId %>">초기화</a>
                </form>
                <div class="manage-table-wrap">
                    <table class="manage-table member-manage-table member-directory-table">
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
                                    <td class="empty-cell" colspan="6">조건에 맞는 회원이 없습니다.</td>
                                </tr>
                            <% } %>
                            <% for (CafeMemberDTO member : cafeMembers) { %>
                                <%
                                    boolean targetSelf = member.getMemberId().equals(currentLoginId);
                                    boolean targetOwner = "OWNER".equals(member.getRole());
                                    boolean targetActive = "ACTIVE".equals(member.getStatus());
                                    boolean canChangeRole = cafeOwner && !targetSelf && !targetOwner && targetActive;
                                    boolean canManageStatus = !targetSelf && !targetOwner
                                            && (cafeOwner || ("MANAGER".equals(currentMember.getRole()) && "MEMBER".equals(member.getRole())));
                                %>
                                <tr class="member-manage-row"
                                    data-member-id="<%= escapeHtml(member.getMemberId()) %>"
                                    data-can-kick="<%= canManageStatus && targetActive %>"
                                    data-can-ban="<%= canManageStatus && targetActive %>"
                                    data-can-restore-kick="<%= cafeOwner && canManageStatus && "LEFT".equals(member.getStatus()) %>"
                                    data-can-restore-ban="<%= cafeOwner && canManageStatus && "BANNED".equals(member.getStatus()) %>">
                                    <td><strong><%= escapeHtml(member.getNickname() == null ? member.getMemberId() : member.getNickname()) %></strong></td>
                                    <td><%= escapeHtml(member.getMemberId()) %></td>
                                    <td><%= escapeHtml(RegionFormatter.formatKoreanSigungu(member.getRegion())) %></td>
                                    <td><%= escapeHtml(formatDateTime(member.getJoinedAt())) %></td>
                                    <td>
                                        <% if (canChangeRole) { %>
                                            <form class="member-inline-form" action="<%= contextPath %>/community/member/memberRoleProcess.jsp" method="post">
                                                <input type="hidden" name="cafeId" value="<%= cafeId %>">
                                                <input type="hidden" name="memberId" value="<%= escapeHtml(member.getMemberId()) %>">
                                                <select name="role" aria-label="회원 등급">
                                                    <option value="MANAGER"<%= selectedAttr("MANAGER", member.getRole()) %>>스탭</option>
                                                    <option value="MEMBER"<%= selectedAttr("MEMBER", member.getRole()) %>>회원</option>
                                                </select>
                                                <button class="btn-sub btn-small" type="submit">변경</button>
                                            </form>
                                        <% } else { %>
                                            <span class="status-badge"><%= escapeHtml(roleText(member.getRole())) %></span>
                                        <% } %>
                                    </td>
                                    <td><span class="status-badge<%= statusClass(member.getStatus()) %>"><%= escapeHtml(statusText(member.getStatus())) %></span></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </section>
    </section>
    <div class="member-context-menu" id="memberContextMenu" hidden>
        <button type="button" data-member-action="kick">강퇴</button>
        <button type="button" data-member-action="ban" class="is-danger">차단</button>
        <button type="button" data-member-action="unban" data-menu-type="restore-kick">강퇴 해제</button>
        <button type="button" data-member-action="unban" data-menu-type="restore-ban">차단 해제</button>
    </div>
    <form id="memberContextForm" action="<%= contextPath %>/community/member/memberStatusProcess.jsp" method="post" hidden>
        <input type="hidden" name="cafeId" value="<%= cafeId %>">
        <input type="hidden" name="memberId" value="">
        <input type="hidden" name="action" value="">
    </form>
</main>
<script>
(function () {
    var menu = document.getElementById('memberContextMenu');
    var form = document.getElementById('memberContextForm');
    if (!menu || !form) {
        return;
    }

    var memberInput = form.querySelector('input[name="memberId"]');
    var actionInput = form.querySelector('input[name="action"]');
    var activeMemberId = '';

    function hideMenu() {
        menu.hidden = true;
        activeMemberId = '';
    }

    function setButton(action, enabled) {
        menu.querySelectorAll('[data-member-action="' + action + '"]').forEach(function (button) {
            button.hidden = !enabled;
        });
    }

    document.querySelectorAll('.member-manage-row').forEach(function (row) {
        row.addEventListener('contextmenu', function (event) {
            var canKick = row.dataset.canKick === 'true';
            var canBan = row.dataset.canBan === 'true';
            var canRestoreKick = row.dataset.canRestoreKick === 'true';
            var canRestoreBan = row.dataset.canRestoreBan === 'true';
            if (!canKick && !canBan && !canRestoreKick && !canRestoreBan) {
                return;
            }

            event.preventDefault();
            activeMemberId = row.dataset.memberId || '';
            setButton('kick', canKick);
            setButton('ban', canBan);
            setButton('unban', false);
            var restoreKickButton = menu.querySelector('[data-menu-type="restore-kick"]');
            var restoreBanButton = menu.querySelector('[data-menu-type="restore-ban"]');
            if (restoreKickButton) {
                restoreKickButton.hidden = !canRestoreKick;
            }
            if (restoreBanButton) {
                restoreBanButton.hidden = !canRestoreBan;
            }
            menu.hidden = false;

            var menuWidth = menu.offsetWidth;
            var menuHeight = menu.offsetHeight;
            var left = Math.min(event.pageX, window.scrollX + window.innerWidth - menuWidth - 12);
            var top = Math.min(event.pageY, window.scrollY + window.innerHeight - menuHeight - 12);
            menu.style.left = Math.max(window.scrollX + 8, left) + 'px';
            menu.style.top = Math.max(window.scrollY + 8, top) + 'px';
        });
    });

    menu.addEventListener('click', function (event) {
        var button = event.target.closest('button[data-member-action]');
        if (!button || !activeMemberId) {
            return;
        }
        memberInput.value = activeMemberId;
        actionInput.value = button.dataset.memberAction;
        form.submit();
    });

    document.addEventListener('click', function (event) {
        if (!menu.contains(event.target)) {
            hideMenu();
        }
    });
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            hideMenu();
        }
    });
    window.addEventListener('scroll', hideMenu, true);
    window.addEventListener('resize', hideMenu);
}());
</script>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
