<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dao.CafePostLikeDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeCommentDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
%>
<%
    int postId = parseIntParam(request.getParameter("postId"));
    String postDetailRedirect = java.net.URLEncoder.encode("/community/postDetail.jsp?postId=" + postId, "UTF-8");
    CafePostDAO postDao = new CafePostDAO();
    CafePostDTO post = postDao.selectPostById(postId);
    boolean deletedPostFail = post == null && "deleteFail".equals(request.getParameter("error"));
    if (post == null && !deletedPostFail) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=noPost");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    CafeDTO cafe = null;
    List<CafeBoardDTO> boards = java.util.Collections.emptyList();
    boolean activeMember = false;
    boolean manager = false;
    boolean isWriter = false;
    boolean likedPost = false;
    int likeCount = 0;
    List<CafeCommentDTO> comments = java.util.Collections.emptyList();
    if (post != null) {
        cafe = new CafeDAO().selectCafeById(post.getCafeId());
        boards = new CafeBoardDAO().selectBoardsByCafeId(post.getCafeId());
        activeMember = currentLoginId != null && memberDao.isActiveMember(post.getCafeId(), currentLoginId);
        manager = currentLoginId != null && memberDao.isCafeManagerOrOwner(post.getCafeId(), currentLoginId);
        isWriter = currentLoginId != null && currentLoginId.equals(post.getWriterId());
        boolean canRead = cafe != null && ("PUBLIC".equals(cafe.getVisibility()) || activeMember);
        if (!canRead) {
            response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + post.getCafeId() + "&error=private");
            return;
        }

        postDao.increaseViewCount(postId);
        CafePostLikeDAO likeDao = new CafePostLikeDAO();
        likedPost = currentLoginId != null && likeDao.existsLike(postId, currentLoginId);
        likeCount = likeDao.countLike(postId);
        comments = new CafeCommentDAO().selectCommentsByPostId(postId);
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= deletedPostFail ? "게시글 삭제 실패" : escapeHtml(post.getTitle()) %> | 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell community-shell">
    <% if (deletedPostFail) { %>
        <section class="cafe-box">
            <div class="cafe-box-body">
                <p class="field-message is-error">게시글을 삭제할 수 없습니다.</p>
                <a class="button btn-main" href="<%= contextPath %>/community/communityHome.jsp">커뮤니티 홈</a>
            </div>
        </section>
    <% } else { %>
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
            <div class="cafe-box">
                <div class="cafe-section-title">카페 활동</div>
                <div class="cafe-box-body cafe-action-stack">
                    <% if (!loggedIn) { %>
                        <a class="button btn-main" href="<%= contextPath %>/member/login.jsp?error=loginRequired&amp;redirect=<%= postDetailRedirect %>">로그인 후 가입</a>
                    <% } else if (activeMember) { %>
                        <a class="button btn-main" href="<%= contextPath %>/community/postWrite.jsp?cafeId=<%= post.getCafeId() %>&boardId=<%= post.getBoardId() %>">글쓰기</a>
                    <% } else { %>
                        <a class="button btn-main" href="<%= contextPath %>/community/cafeJoinProcess.jsp?cafeId=<%= post.getCafeId() %>">카페 가입</a>
                    <% } %>
                </div>
            </div>

            <div class="cafe-box cafe-info-box">
                <div class="cafe-section-title">내 카페 정보</div>
                <div class="cafe-box-body">
                    <ul class="cafe-stat-list">
                        <li><span>내 등급</span><strong><%= manager ? "관리자" : (activeMember ? "가입중" : "방문자") %></strong></li>
                        <li><span>지역</span><strong><%= escapeHtml(formatKoreanSigungu(cafe.getRegion())) %></strong></li>
                        <li><span>공개</span><strong><%= escapeHtml(cafe.getVisibility()) %></strong></li>
                    </ul>
                </div>
            </div>

            <div class="cafe-box">
                <div class="cafe-section-title">게시판 목록</div>
                <nav class="cafe-menu-list" aria-label="카페 메뉴">
                    <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= post.getCafeId() %>">카페 홈</a>
                    <% if (!boards.isEmpty()) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= post.getCafeId() %>&boardId=<%= boards.get(0).getBoardId() %>">전체글 보기</a>
                    <% } %>
                    <% for (CafeBoardDTO board : boards) { %>
                        <a class="cafe-menu-item <%= board.getBoardId() == post.getBoardId() ? "active" : "" %>" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= post.getCafeId() %>&boardId=<%= board.getBoardId() %>">
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
                        <li><span>조회</span><strong><%= cafe.getViewCount() %></strong></li>
                    </ul>
                </div>
            </div>
            <% if (manager) { %>
                <div class="cafe-box">
                    <div class="cafe-section-title">관리 메뉴</div>
                    <nav class="cafe-menu-list">
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= post.getCafeId() %>">게시판 관리</a>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeMemberManage.jsp?cafeId=<%= post.getCafeId() %>">회원 관리</a>
                    </nav>
                </div>
            <% } %>
        </aside>

        <article class="cafe-main">
            <section class="cafe-box post-read-panel">
                <% if (request.getParameter("error") != null) { %>
                    <p class="field-message is-error">요청을 처리하지 못했습니다.</p>
                <% } else if ("success".equals(request.getParameter("update"))) { %>
                    <p class="notice-toast">게시글이 수정되었습니다.</p>
                <% } else if ("success".equals(request.getParameter("commentDelete"))) { %>
                    <p class="notice-toast">댓글이 삭제되었습니다.</p>
                <% } else if ("success".equals(request.getParameter("report"))) { %>
                    <p class="notice-toast">신고가 접수되었습니다.</p>
                <% } %>
                <div class="post-read-header">
                    <p class="breadcrumb">
                        <a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= post.getCafeId() %>"><%= escapeHtml(post.getCafeName()) %></a>
                        <span>&gt;</span>
                        <a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= post.getCafeId() %>&boardId=<%= post.getBoardId() %>"><%= escapeHtml(post.getBoardName()) %></a>
                    </p>
                    <% if ("Y".equals(post.getIsNotice())) { %><span class="notice-badge">공지</span><% } %>
                    <h1><%= escapeHtml(post.getTitle()) %></h1>
                    <div class="post-meta-line">
                        <span><%= escapeHtml(post.getWriterNickname()) %></span>
                        <span>조회 <%= post.getViewCount() + 1 %></span>
                        <span>댓글 <%= comments.size() %></span>
                        <span>좋아요 <%= likeCount %></span>
                    </div>
                    <% if (isWriter || manager) { %>
                        <div class="post-action-bar">
                            <a class="button btn-sub btn-small" href="<%= contextPath %>/community/postUpdate.jsp?postId=<%= postId %>">수정</a>
                            <button class="btn-danger btn-small" type="button" onclick="deletePost(<%= postId %>)">삭제</button>
                        </div>
                    <% } %>
                </div>
                <div class="post-body"><%= escapeHtml(post.getContent()) %></div>
                <div class="post-action-bar">
                    <% if (activeMember) { %>
                        <form action="<%= contextPath %>/community/postLikeProcess.jsp" method="post">
                            <input type="hidden" name="postId" value="<%= postId %>">
                            <button class="btn-sub btn-small" type="submit"><%= likedPost ? "좋아요 취소" : "좋아요" %></button>
                        </form>
                    <% } %>
                    <% if (loggedIn) { %>
                        <a class="button btn-text" href="<%= contextPath %>/community/communityReport.jsp?targetType=CAFE_POST&targetId=<%= postId %>">신고</a>
                    <% } %>
                </div>
            </section>

            <section class="cafe-box">
                <div class="cafe-section-title">댓글 <%= comments.size() %>개</div>
                <div class="cafe-box-body">
                    <div class="comment-list">
                        <% if (comments.isEmpty()) { %>
                            <p class="empty-cell">아직 댓글이 없습니다.</p>
                        <% } %>
                        <% for (CafeCommentDTO comment : comments) { %>
                            <div class="comment-item">
                                <div class="comment-avatar"><%= escapeHtml(comment.getWriterNickname()).isEmpty() ? "U" : escapeHtml(comment.getWriterNickname()).substring(0, 1) %></div>
                                <div class="comment-body">
                                    <div class="comment-meta">
                                        <strong><%= escapeHtml(comment.getWriterNickname()) %></strong>
                                        <span><%= comment.getCreatedAt() %></span>
                                    </div>
                                    <p><%= escapeHtml(comment.getContent()) %></p>
                                    <div class="comment-actions">
                                        <% if (loggedIn) { %>
                                            <a class="button btn-text" href="<%= contextPath %>/community/communityReport.jsp?targetType=CAFE_COMMENT&targetId=<%= comment.getCommentId() %>">신고</a>
                                        <% } %>
                                        <% if (currentLoginId != null && (currentLoginId.equals(comment.getWriterId()) || manager)) { %>
                                            <button class="btn-danger btn-small" type="button" onclick="deleteComment(<%= comment.getCommentId() %>)">삭제</button>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    <% if (activeMember) { %>
                        <form class="comment-form" action="<%= contextPath %>/community/commentWriteProcess.jsp" method="post">
                            <input type="hidden" name="postId" value="<%= postId %>">
                            <label class="visually-hidden" for="commentContent">댓글 작성</label>
                            <textarea id="commentContent" name="content" maxlength="1000" placeholder="댓글을 입력하세요." required></textarea>
                            <button class="btn-main btn-small" type="submit">등록</button>
                        </form>
                    <% } else if (!loggedIn) { %>
                        <p class="community-meta">댓글은 로그인 후 작성할 수 있습니다.</p>
                    <% } else { %>
                        <p class="community-meta">댓글은 카페 가입 후 작성할 수 있습니다.</p>
                    <% } %>
                </div>
            </section>
        </article>
    </section>
    <% } %>
</main>
<script>
    function deletePost(postId) {
        if (confirm("게시글을 삭제하시겠습니까?")) {
            location.href = "<%= request.getContextPath() %>/community/postDeleteProcess.jsp?postId=" + postId;
        }
    }

    function deleteComment(commentId) {
        if (confirm("댓글을 삭제하시겠습니까?")) {
            location.href = "<%= request.getContextPath() %>/community/commentDeleteProcess.jsp?commentId=" + commentId;
        }
    }
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
