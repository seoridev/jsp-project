<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dao.CafePostLikeDAO" %>
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
    boolean activeMember = false;
    boolean manager = false;
    boolean isWriter = false;
    boolean likedPost = false;
    int likeCount = 0;
    List<CafeCommentDTO> comments = java.util.Collections.emptyList();
    if (post != null) {
        cafe = new CafeDAO().selectCafeById(post.getCafeId());
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
        <section class="community-section">
            <p class="field-message is-error">게시글을 삭제할 수 없습니다.</p>
            <a class="button btn-primary" href="<%= contextPath %>/community/communityHome.jsp">커뮤니티 홈</a>
        </section>
    <% } else { %>
    <div class="post-detail-layout">
        <article class="post-main-column">
            <section class="community-section post-article">
                <% if (request.getParameter("error") != null) { %>
                    <p class="field-message is-error">요청을 처리하지 못했습니다.</p>
                <% } else if ("success".equals(request.getParameter("update"))) { %>
                    <p class="field-message is-success">게시글이 수정되었습니다.</p>
                <% } else if ("success".equals(request.getParameter("commentDelete"))) { %>
                    <p class="field-message is-success">댓글이 삭제되었습니다.</p>
                <% } else if ("success".equals(request.getParameter("report"))) { %>
                    <p class="field-message is-success">신고가 접수되었습니다.</p>
                <% } %>
                <p class="breadcrumb">
                    <a href="<%= contextPath %>/community/communityHome.jsp">커뮤니티</a>
                    <span>/</span>
                    <a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= post.getCafeId() %>"><%= escapeHtml(post.getCafeName()) %></a>
                    <span>/</span>
                    <a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= post.getCafeId() %>&boardId=<%= post.getBoardId() %>"><%= escapeHtml(post.getBoardName()) %></a>
                </p>
                <div class="post-title-row large">
                    <% if ("Y".equals(post.getIsNotice())) { %><span class="notice-badge">공지</span><% } %>
                    <h1><%= escapeHtml(post.getTitle()) %></h1>
                </div>
                <div class="author-row">
                    <div class="author-avatar"><%= escapeHtml(post.getWriterNickname()).isEmpty() ? "U" : escapeHtml(post.getWriterNickname()).substring(0, 1) %></div>
                    <div>
                        <strong><%= escapeHtml(post.getWriterNickname()) %></strong>
                        <div class="post-meta">
                            <span>조회 <%= post.getViewCount() + 1 %></span>
                            <span>댓글 <%= comments.size() %>개</span>
                            <span>좋아요 <%= likeCount %>개</span>
                        </div>
                    </div>
                </div>
                <div class="post-body"><%= escapeHtml(post.getContent()) %></div>
                <div class="post-action-bar">
                    <% if (activeMember) { %>
                        <form action="<%= contextPath %>/community/postLikeProcess.jsp" method="post">
                            <input type="hidden" name="postId" value="<%= postId %>">
                            <button class="btn-secondary" type="submit"><%= likedPost ? "좋아요 취소" : "좋아요" %></button>
                        </form>
                    <% } %>
                    <% if (loggedIn) { %>
                        <a class="button btn-ghost" href="<%= contextPath %>/community/communityReport.jsp?targetType=CAFE_POST&targetId=<%= postId %>">신고</a>
                    <% } %>
                    <% if (isWriter || manager) { %>
                        <a class="button btn-secondary" href="<%= contextPath %>/community/postUpdate.jsp?postId=<%= postId %>">수정</a>
                        <button class="btn-danger" type="button" onclick="deletePost(<%= postId %>)">삭제</button>
                    <% } %>
                </div>
            </section>

            <section class="community-section">
                <div class="section-title-row">
                    <h2>댓글 <%= comments.size() %>개</h2>
                </div>
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
                                        <a class="button btn-ghost" href="<%= contextPath %>/community/communityReport.jsp?targetType=CAFE_COMMENT&targetId=<%= comment.getCommentId() %>">신고</a>
                                    <% } %>
                                    <% if (currentLoginId != null && (currentLoginId.equals(comment.getWriterId()) || manager)) { %>
                                        <button class="btn-danger" type="button" onclick="deleteComment(<%= comment.getCommentId() %>)">삭제</button>
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
                        <textarea id="commentContent" name="content" maxlength="1000" placeholder="댓글을 입력하세요" required></textarea>
                        <button class="btn-primary" type="submit">댓글 등록</button>
                    </form>
                <% } else if (!loggedIn) { %>
                    <p class="community-meta">댓글은 로그인 후 작성할 수 있습니다.</p>
                <% } else { %>
                    <p class="community-meta">댓글은 카페 가입 후 작성할 수 있습니다.</p>
                <% } %>
            </section>
        </article>

        <aside class="post-side-column">
            <section class="cafe-action-card">
                <span class="community-badge"><%= escapeHtml(cafe.getCategory()) %></span>
                <h2><%= escapeHtml(cafe.getCafeName()) %></h2>
                <p><%= escapeHtml(cafe.getDescription()) %></p>
                <div class="community-meta-row">
                    <span>회원 <%= cafe.getMemberCount() %>명</span>
                    <span>글 <%= cafe.getPostCount() %>개</span>
                </div>
                <a class="button btn-secondary" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= post.getCafeId() %>">카페로 돌아가기</a>
                <a class="button btn-ghost" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= post.getCafeId() %>&boardId=<%= post.getBoardId() %>">게시판 목록</a>
            </section>
        </aside>
    </div>
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
