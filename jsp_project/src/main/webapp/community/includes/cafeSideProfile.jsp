<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dao.CafePostLikeDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
<%
    CafeDTO cafeSideCafe = (CafeDTO) request.getAttribute("cafeIncludeCafe");
    Object cafeSideCafeIdValue = request.getAttribute("cafeIncludeCafeId");
    int cafeSideCafeId = cafeSideCafeIdValue instanceof Integer ? ((Integer) cafeSideCafeIdValue).intValue() : 0;
    Object cafeSideCurrentBoardIdValue = request.getAttribute("cafeIncludeCurrentBoardId");
    int cafeSideCurrentBoardId = cafeSideCurrentBoardIdValue instanceof Integer ? ((Integer) cafeSideCurrentBoardIdValue).intValue() : 0;
    String cafeSideLoginId = (String) session.getAttribute("loginId");
    String cafeSideLoginNickname = (String) session.getAttribute("loginNickname");
    String cafeSideRedirectPath = request.getRequestURI().substring(request.getContextPath().length());
    String cafeSideQuery = request.getQueryString();
    String cafeSideRedirect = java.net.URLEncoder.encode(cafeSideRedirectPath + (cafeSideQuery == null ? "" : "?" + cafeSideQuery), "UTF-8");

    CafeMemberDTO cafeSideMember = null;
    boolean cafeSideLoggedIn = cafeSideLoginId != null;
    boolean cafeSideActive = false;
    boolean cafeSidePending = false;
    boolean cafeSideManager = false;
    List<CafeBoardDTO> cafeSideBoards = java.util.Collections.emptyList();
    int cafeSideWriteBoardId = 0;
    int cafeSidePostCount = 0;
    int cafeSideCommentCount = 0;
    int cafeSideLikeCount = 0;

    if (cafeSideCafe != null && cafeSideCafeId > 0) {
        CafeMemberDAO cafeSideMemberDao = new CafeMemberDAO();
        cafeSideMember = cafeSideLoginId == null ? null : cafeSideMemberDao.selectCafeMember(cafeSideCafeId, cafeSideLoginId);
        cafeSideActive = cafeSideMember != null && "ACTIVE".equals(cafeSideMember.getStatus());
        cafeSidePending = cafeSideMember != null && "PENDING".equals(cafeSideMember.getStatus());
        cafeSideManager = cafeSideActive && ("OWNER".equals(cafeSideMember.getRole()) || "MANAGER".equals(cafeSideMember.getRole()));
        cafeSideBoards = new CafeBoardDAO().selectBoardsByCafeId(cafeSideCafeId);
        if (cafeSideActive) {
            boolean cafeSideFoundCurrentBoard = false;
            if (cafeSideCurrentBoardId > 0) {
                for (CafeBoardDTO cafeSideBoard : cafeSideBoards) {
                    if (cafeSideBoard.getBoardId() == cafeSideCurrentBoardId) {
                        cafeSideFoundCurrentBoard = true;
                        if (cafeSideManager || "MEMBER".equals(cafeSideBoard.getWritePermission())) {
                            cafeSideWriteBoardId = cafeSideBoard.getBoardId();
                        }
                        break;
                    }
                }
            }
            if (cafeSideWriteBoardId <= 0 && !cafeSideFoundCurrentBoard) {
                for (CafeBoardDTO cafeSideBoard : cafeSideBoards) {
                    if (cafeSideManager || "MEMBER".equals(cafeSideBoard.getWritePermission())) {
                        cafeSideWriteBoardId = cafeSideBoard.getBoardId();
                        break;
                    }
                }
            }
        }
        CafePostDAO cafeSidePostDao = new CafePostDAO();
        cafeSidePostCount = cafeSideLoginId != null ? cafeSidePostDao.countPostsByWriterInCafe(cafeSideCafeId, cafeSideLoginId) : 0;
        cafeSideCommentCount = cafeSideLoginId != null ? new CafeCommentDAO().countCommentsByWriterInCafe(cafeSideCafeId, cafeSideLoginId) : 0;
        cafeSideLikeCount = cafeSideLoginId != null ? new CafePostLikeDAO().countLikesByMemberInCafe(cafeSideCafeId, cafeSideLoginId) : 0;
    }

    String cafeSideOwnerName = cafeSideCafe == null ? "" : cafeSideCafe.getOwnerNickname();
    if (cafeSideOwnerName == null || cafeSideOwnerName.trim().isEmpty()) {
        cafeSideOwnerName = cafeSideCafe == null || cafeSideCafe.getOwnerId() == null ? "스탭" : cafeSideCafe.getOwnerId();
    }
    String cafeSideImagePath = cafeSideCafe == null ? null : cafeSideCafe.getImagePath();
    boolean cafeSideHasImage = cafeSideImagePath != null && !cafeSideImagePath.trim().isEmpty();
    String cafeSideImageUrl = cafeSideHasImage
            ? request.getContextPath() + (cafeSideImagePath.startsWith("/") ? cafeSideImagePath : "/" + cafeSideImagePath)
            : "";
    String cafeSideCreatedDate = cafeSideCafe == null || cafeSideCafe.getCreatedAt() == null ? "" : cafeSideCafe.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("yyyy.MM.dd."));
    String cafeSideJoinedDate = cafeSideMember == null || cafeSideMember.getJoinedAt() == null ? "" : cafeSideMember.getJoinedAt().format(java.time.format.DateTimeFormatter.ofPattern("yyyy.MM.dd."));
    String cafeSideRoleText = "방문자";
    if (cafeSideActive) {
        if ("OWNER".equals(cafeSideMember.getRole())) {
            cafeSideRoleText = "스탭";
        } else if ("MANAGER".equals(cafeSideMember.getRole())) {
            cafeSideRoleText = "스탭";
        } else {
            cafeSideRoleText = "멤버";
        }
    } else if (cafeSidePending) {
        cafeSideRoleText = "승인 대기";
    }
    String cafeSideUserName = cafeSideLoginNickname == null || cafeSideLoginNickname.isEmpty() ? cafeSideLoginId : cafeSideLoginNickname;
%>
<% if (cafeSideCafe != null) { %>
<div class="cafe-side-profile" data-cafe-side-profile>
    <div class="cafe-side-tabs" role="tablist" aria-label="카페 정보">
        <button class="is-active" type="button" data-cafe-tab="info" role="tab" aria-selected="true">카페정보</button>
        <button type="button" data-cafe-tab="activity" role="tab" aria-selected="false">나의활동</button>
    </div>
    <div class="cafe-side-panel is-active" data-cafe-panel="info" role="tabpanel">
        <div class="cafe-side-head">
            <% if (cafeSideHasImage) { %>
                <img class="cafe-side-image" src="<%= com.carrot.util.HtmlEscaper.escape(cafeSideImageUrl) %>" alt="">
            <% } else { %>
                <div class="cafe-side-image is-initial"><%= com.carrot.util.HtmlEscaper.escape(cafeSideCafe.getCafeName()).isEmpty() ? "C" : com.carrot.util.HtmlEscaper.escape(cafeSideCafe.getCafeName()).substring(0, 1) %></div>
            <% } %>
            <div class="cafe-side-copy">
                <div class="cafe-side-name-row">
                    <strong><%= com.carrot.util.HtmlEscaper.escape(cafeSideOwnerName) %></strong>
                    <span>스탭</span>
                </div>
                <% if (!cafeSideCreatedDate.isEmpty()) { %>
                    <p><%= cafeSideCreatedDate %> 개설</p>
                <% } %>
            </div>
        </div>
        <div class="cafe-side-meta">
            <div><span>지역</span><strong><%= com.carrot.util.HtmlEscaper.escape(com.carrot.util.RegionFormatter.formatKoreanSigungu(cafeSideCafe.getRegion())) %></strong></div>
            <div><span>회원</span><strong><%= cafeSideCafe.getMemberCount() %>명</strong></div>
            <div><span>공개</span><strong><%= com.carrot.util.HtmlEscaper.escape(cafeSideCafe.getVisibility()) %></strong></div>
        </div>
    </div>
    <div class="cafe-side-panel" data-cafe-panel="activity" role="tabpanel" hidden>
        <% if (!cafeSideLoggedIn) { %>
            <div class="cafe-side-empty">로그인 후 나의활동을 볼 수 있습니다.</div>
        <% } else { %>
            <div class="cafe-side-head">
                <div class="cafe-side-image is-user"><%= com.carrot.util.HtmlEscaper.escape(cafeSideUserName == null || cafeSideUserName.isEmpty() ? cafeSideLoginId.substring(0, 1) : cafeSideUserName.substring(0, 1)) %></div>
                <div class="cafe-side-copy">
                    <strong><%= com.carrot.util.HtmlEscaper.escape(cafeSideUserName) %></strong>
                    <% if (!cafeSideJoinedDate.isEmpty()) { %>
                        <p><%= cafeSideJoinedDate %> 가입</p>
                    <% } else { %>
                        <p><%= cafeSideActive ? "가입 정보 없음" : (cafeSidePending ? "승인 대기" : "카페 미가입") %></p>
                    <% } %>
                </div>
            </div>
            <div class="cafe-side-meta">
                <div><span>내 등급</span><strong><%= cafeSideRoleText %></strong></div>
                <div><span>내가 쓴 게시글</span><strong><%= String.format("%,d개", cafeSidePostCount) %></strong></div>
                <div><span>내가 쓴 댓글</span><strong><%= String.format("%,d개", cafeSideCommentCount) %></strong></div>
                <div><span>내가 보낸 좋아요</span><strong><%= String.format("%,d개", cafeSideLikeCount) %></strong></div>
            </div>
        <% } %>
    </div>
    <div class="cafe-side-actions">
        <% if (!cafeSideLoggedIn) { %>
            <a class="button cafe-side-primary" href="<%= request.getContextPath() %>/member/login.jsp?error=loginRequired&amp;redirect=<%= cafeSideRedirect %>">로그인 후 가입</a>
        <% } else if (cafeSidePending) { %>
            <span class="status-badge is-stopped">승인 대기</span>
        <% } else if (!cafeSideActive) { %>
            <a class="button cafe-side-primary" href="<%= request.getContextPath() %>/community/cafeJoinProcess.jsp?cafeId=<%= cafeSideCafeId %>">카페 가입</a>
        <% } else if (cafeSideWriteBoardId > 0) { %>
            <a class="button cafe-side-primary" href="<%= request.getContextPath() %>/community/postWrite.jsp?cafeId=<%= cafeSideCafeId %>&boardId=<%= cafeSideWriteBoardId %>">카페 글쓰기</a>
        <% } else { %>
            <span class="status-badge is-stopped">글쓰기 권한 없음</span>
        <% } %>
        <% if (cafeSideActive && !"OWNER".equals(cafeSideMember.getRole())) { %>
            <form action="<%= request.getContextPath() %>/community/cafeLeaveProcess.jsp" method="post" onsubmit="return confirm('카페에서 탈퇴하시겠습니까?');">
                <input type="hidden" name="cafeId" value="<%= cafeSideCafeId %>">
                <button class="button cafe-side-secondary" type="submit">카페 탈퇴</button>
            </form>
        <% } %>
    </div>
</div>
<script>
document.querySelectorAll("[data-cafe-side-profile]").forEach(function (profile) {
    if (profile.dataset.cafeSideReady === "true") {
        return;
    }
    profile.dataset.cafeSideReady = "true";
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
<% } %>
