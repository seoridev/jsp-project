<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dao.CafePostLikeDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String formatCafeDate(java.time.LocalDateTime value) {
        return value == null ? "" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd."));
    }

    private String formatCafeRole(String role) {
        if ("OWNER".equals(role)) {
            return "관리자";
        }
        if ("MANAGER".equals(role)) {
            return "매니저";
        }
        if ("MEMBER".equals(role)) {
            return "멤버";
        }
        return role == null ? "방문자" : role;
    }

    private String formatCount(int value, String unit) {
        return String.format("%,d%s", value, unit);
    }
%>
<%
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    String cafeDetailRedirect = java.net.URLEncoder.encode("/community/cafeDetail.jsp?cafeId=" + cafeId, "UTF-8");
    CafeDAO cafeDao = new CafeDAO();
    CafeDTO cafe = cafeDao.selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    CafeMemberDTO myMember = currentLoginId == null ? null : memberDao.selectCafeMember(cafeId, currentLoginId);
    boolean activeMember = myMember != null && "ACTIVE".equals(myMember.getStatus());
    boolean pendingMember = myMember != null && "PENDING".equals(myMember.getStatus());
    boolean ownerOrManager = activeMember && ("OWNER".equals(myMember.getRole()) || "MANAGER".equals(myMember.getRole()));
    boolean favoriteCafe = currentLoginId != null && new CafeFavoriteDAO().existsFavorite(cafeId, currentLoginId);
    boolean canRead = "PUBLIC".equals(cafe.getVisibility()) || activeMember;
    String cafeImagePath = cafe.getImagePath();
    boolean hasCafeImage = cafeImagePath != null && !cafeImagePath.trim().isEmpty();
    String cafeImageUrl = hasCafeImage
            ? request.getContextPath() + (cafeImagePath.startsWith("/") ? cafeImagePath : "/" + cafeImagePath)
            : "";
    String createdDate = formatCafeDate(cafe.getCreatedAt());
    String joinedDate = myMember == null ? "" : formatCafeDate(myMember.getJoinedAt());

    CafePostDAO postDao = new CafePostDAO();
    List<CafeBoardDTO> boards = new CafeBoardDAO().selectBoardsByCafeId(cafeId);
    List<CafePostDTO> posts = canRead ? postDao.selectRecentPostsByCafeId(cafeId, 10) : java.util.Collections.emptyList();
    int myCafePostCount = currentLoginId != null ? postDao.countPostsByWriterInCafe(cafeId, currentLoginId) : 0;
    int myCafeCommentCount = currentLoginId != null ? new CafeCommentDAO().countCommentsByWriterInCafe(cafeId, currentLoginId) : 0;
    int myCafeLikeCount = currentLoginId != null ? new CafePostLikeDAO().countLikesByMemberInCafe(cafeId, currentLoginId) : 0;
    int writeBoardId = 0;
    if (activeMember) {
        for (CafeBoardDTO board : boards) {
            if (ownerOrManager || "MEMBER".equals(board.getWritePermission())) {
                writeBoardId = board.getBoardId();
                break;
            }
        }
    }
    cafeDao.increaseViewCount(cafeId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= escapeHtml(cafe.getCafeName()) %> | 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=20260525-cafe-side-profile-2">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell community-shell">
    <% if ("success".equals(request.getParameter("created"))) { %>
        <p class="notice-toast">카페가 생성되었습니다.</p>
    <% } else if ("active".equals(request.getParameter("join"))) { %>
        <p class="notice-toast">카페에 가입되었습니다.</p>
    <% } else if ("pending".equals(request.getParameter("join"))) { %>
        <p class="field-message">가입 요청이 접수되었습니다.</p>
    <% } else if ("success".equals(request.getParameter("leave"))) { %>
        <p class="notice-toast">카페에서 탈퇴했습니다.</p>
    <% } else if (request.getParameter("error") != null) { %>
        <p class="field-message is-error">요청을 처리하지 못했습니다.</p>
    <% } %>

    <section class="cafe-gate">
        <div class="cafe-cover-band">
            <span class="cafe-cover-label"><%= escapeHtml(cafe.getCategory()) %></span>
        </div>
        <div class="cafe-gate-content">
            <div class="cafe-avatar cafe-gate-avatar"><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></div>
            <div class="cafe-gate-copy">
                <div class="cafe-title-row">
                    <h1><%= escapeHtml(cafe.getCafeName()) %></h1>
                    <span class="cafe-badge"><%= escapeHtml(cafe.getVisibility()) %></span>
                    <% if (loggedIn) { %>
                        <form class="cafe-title-favorite-form" action="<%= contextPath %>/community/cafeFavoriteProcess.jsp" method="post">
                            <input type="hidden" name="cafeId" value="<%= cafeId %>">
                            <button class="cafe-favorite-toggle <%= favoriteCafe ? "is-active" : "" %>" type="submit" aria-label="<%= favoriteCafe ? "즐겨찾기 해제" : "즐겨찾기" %>">
                                <%= favoriteCafe ? "★" : "☆" %>
                            </button>
                        </form>
                    <% } else { %>
                        <a class="cafe-favorite-toggle" href="<%= contextPath %>/member/login.jsp?error=loginRequired&amp;redirect=<%= cafeDetailRedirect %>" aria-label="로그인 후 즐겨찾기">☆</a>
                    <% } %>
                </div>
                <p><%= escapeHtml(cafe.getDescription()) %></p>
                <div class="cafe-meta-line">
                    <span><%= escapeHtml(cafe.getCategory()) %></span>
                    <span><%= escapeHtml(formatKoreanSigungu(cafe.getRegion())) %></span>
                </div>
            </div>
        </div>
    </section>

    <section class="cafe-layout cafe-detail-layout">
        <aside class="cafe-left">
            <div class="cafe-side-profile" data-cafe-side-profile>
                <div class="cafe-side-tabs" role="tablist" aria-label="카페 정보">
                    <button class="is-active" type="button" data-cafe-tab="info" role="tab" aria-selected="true">카페정보</button>
                    <button type="button" data-cafe-tab="activity" role="tab" aria-selected="false">나의활동</button>
                </div>
                <div class="cafe-side-panel is-active" data-cafe-panel="info" role="tabpanel">
                    <div class="cafe-side-head">
                        <% if (hasCafeImage) { %>
                            <img class="cafe-side-image" src="<%= escapeHtml(cafeImageUrl) %>" alt="">
                        <% } else { %>
                            <div class="cafe-side-image is-initial"><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></div>
                        <% } %>
                        <div class="cafe-side-copy">
                            <div class="cafe-side-name-row">
                                <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                                <% if (ownerOrManager) { %>
                                    <span><%= formatCafeRole(myMember.getRole()) %></span>
                                <% } %>
                            </div>
                            <% if (!createdDate.isEmpty()) { %>
                                <p><%= createdDate %> 개설</p>
                            <% } %>
                            <p><%= escapeHtml(cafe.getDescription()) %></p>
                        </div>
                    </div>
                    <div class="cafe-side-meta">
                        <div><span>지역</span><strong><%= escapeHtml(formatKoreanSigungu(cafe.getRegion())) %></strong></div>
                        <div><span>회원</span><strong><%= cafe.getMemberCount() %>명</strong></div>
                        <div><span>공개</span><strong><%= escapeHtml(cafe.getVisibility()) %></strong></div>
                    </div>
                </div>
                <div class="cafe-side-panel" data-cafe-panel="activity" role="tabpanel" hidden>
                    <% if (!loggedIn) { %>
                        <div class="cafe-side-empty">로그인 후 나의활동을 볼 수 있습니다.</div>
                    <% } else { %>
                        <div class="cafe-side-head">
                            <div class="cafe-side-image is-user"><%= escapeHtml(loginNickname == null || loginNickname.isEmpty() ? currentLoginId.substring(0, 1) : loginNickname.substring(0, 1)) %></div>
                            <div class="cafe-side-copy">
                                <strong><%= escapeHtml(loginNickname == null || loginNickname.isEmpty() ? currentLoginId : loginNickname) %></strong>
                                <% if (!joinedDate.isEmpty()) { %>
                                    <p><%= joinedDate %> 가입</p>
                                <% } else { %>
                                    <p><%= activeMember ? "가입 정보 없음" : (pendingMember ? "승인 대기" : "카페 미가입") %></p>
                                <% } %>
                            </div>
                        </div>
                        <div class="cafe-side-meta">
                            <div><span>내 등급</span><strong><%= activeMember ? formatCafeRole(myMember.getRole()) : (pendingMember ? "승인 대기" : "방문자") %></strong></div>
                            <div><span>내가 쓴 게시글</span><strong><%= formatCount(myCafePostCount, "개") %></strong></div>
                            <div><span>내가 쓴 댓글</span><strong><%= formatCount(myCafeCommentCount, "개") %></strong></div>
                            <div><span>내가 보낸 좋아요</span><strong><%= formatCount(myCafeLikeCount, "개") %></strong></div>
                        </div>
                    <% } %>
                </div>
                <div class="cafe-side-actions">
                    <% if (!loggedIn) { %>
                        <a class="button cafe-side-primary" href="<%= contextPath %>/member/login.jsp?error=loginRequired&amp;redirect=<%= cafeDetailRedirect %>">로그인 후 가입</a>
                    <% } else if (pendingMember) { %>
                        <span class="status-badge is-stopped">승인 대기</span>
                    <% } else if (!activeMember) { %>
                        <a class="button cafe-side-primary" href="<%= contextPath %>/community/cafeJoinProcess.jsp?cafeId=<%= cafeId %>">카페 가입</a>
                    <% } else if (writeBoardId > 0) { %>
                        <a class="button cafe-side-primary" href="<%= contextPath %>/community/postWrite.jsp?cafeId=<%= cafeId %>&boardId=<%= writeBoardId %>">카페 글쓰기</a>
                    <% } else { %>
                        <span class="status-badge is-stopped">글쓰기 권한 없음</span>
                    <% } %>
                    <% if (activeMember && !"OWNER".equals(myMember.getRole())) { %>
                        <form action="<%= contextPath %>/community/cafeLeaveProcess.jsp" method="post" onsubmit="return confirm('카페에서 탈퇴하시겠습니까?');">
                            <input type="hidden" name="cafeId" value="<%= cafeId %>">
                            <button class="button cafe-side-secondary" type="submit">카페 탈퇴</button>
                        </form>
                    <% } %>
                </div>
            </div>

            <div class="cafe-box">
                <div class="cafe-section-title">게시판 목록</div>
                <nav class="cafe-menu-list" aria-label="카페 메뉴">
                    <a class="cafe-menu-item active" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>">카페 홈</a>
                    <% if (!boards.isEmpty()) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boards.get(0).getBoardId() %>">전체글 보기</a>
                    <% } %>
                    <% for (CafeBoardDTO board : boards) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
                            <span><%= escapeHtml(board.getBoardName()) %></span>
                            <span><%= board.getPostCount() %></span>
                        </a>
                    <% } %>
                </nav>
            </div>
            <div class="cafe-box cafe-info-box">
                <div class="cafe-section-title">카페 통계</div>
                <div class="cafe-box-body">
                    <ul class="cafe-stat-list">
                        <li><span>회원</span><strong><%= cafe.getMemberCount() %></strong></li>
                        <li><span>게시글</span><strong><%= cafe.getPostCount() %></strong></li>
                        <li><span>조회</span><strong><%= cafe.getViewCount() + 1 %></strong></li>
                    </ul>
                </div>
            </div>
            <% if (ownerOrManager) { %>
                <div class="cafe-box">
                    <div class="cafe-section-title">관리 메뉴</div>
                    <nav class="cafe-menu-list">
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                    </nav>
                </div>
            <% } %>
        </aside>

        <section class="cafe-main cafe-box">
            <div class="cafe-section-title">
                <span>최근 글</span>
            </div>
            <% if (!canRead) { %>
                <div class="cafe-private-guide">
                    <strong>비공개 카페입니다.</strong>
                    <p>가입 후 글을 볼 수 있습니다.</p>
                </div>
            <% } else if (posts.isEmpty()) { %>
                <p class="empty-cell">아직 작성된 글이 없습니다.</p>
            <% } else { %>
                <div class="cafe-post-list">
                    <% for (CafePostDTO post : posts) { %>
                        <a class="cafe-post-item <%= "Y".equals(post.getIsNotice()) ? "is-notice" : "" %>" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>">
                            <span class="<%= "Y".equals(post.getIsNotice()) ? "notice-badge" : "board-badge is-normal" %>"><%= "Y".equals(post.getIsNotice()) ? "공지" : "일반" %></span>
                            <span class="cafe-post-board"><%= escapeHtml(post.getBoardName()) %></span>
                            <span class="cafe-post-title"><%= escapeHtml(post.getTitle()) %></span>
                            <span class="cafe-post-author"><%= escapeHtml(post.getWriterNickname()) %></span>
                            <span class="cafe-post-comments">댓글 <%= post.getCommentCount() %></span>
                        </a>
                    <% } %>
                </div>
            <% } %>
        </section>
    </section>
    <% if (loggedIn) { %>
        <div class="cafe-report-row">
            <a class="cafe-report-link" href="<%= contextPath %>/community/communityReport.jsp?targetType=CAFE&targetId=<%= cafeId %>">이 카페 신고하기</a>
        </div>
    <% } %>
</main>
<script>
document.querySelectorAll("[data-cafe-side-profile]").forEach(function (profile) {
    var tabs = profile.querySelectorAll("[data-cafe-tab]");
    var panels = profile.querySelectorAll("[data-cafe-panel]");

    tabs.forEach(function (tab) {
        tab.addEventListener("click", function () {
            var target = tab.getAttribute("data-cafe-tab");

            tabs.forEach(function (item) {
                var active = item === tab;
                item.classList.toggle("is-active", active);
                item.setAttribute("aria-selected", active ? "true" : "false");
            });

            panels.forEach(function (panel) {
                var active = panel.getAttribute("data-cafe-panel") === target;
                panel.classList.toggle("is-active", active);
                panel.hidden = !active;
            });
        });
    });
});
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
