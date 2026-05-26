<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.carrot.util.RegionFormatter" %>
<%
    // 커뮤니티 홈 탭과 검색 조건에 맞는 목록 데이터 조회
    DateTimeFormatter postDateFormat = DateTimeFormatter.ofPattern("yyyy.MM.dd");
    String currentLoginId = (String) session.getAttribute("loginId");
    String currentNickname = (String) session.getAttribute("loginNickname");
    boolean communityLoggedIn = currentLoginId != null;

    String tab = request.getParameter("tab");
    if (!"latest".equals(tab) && !"myPosts".equals(tab) && !"popular".equals(tab) && !"cafes".equals(tab)) {
        tab = "home";
    }
    String searchKeyword = request.getParameter("keyword");
    searchKeyword = searchKeyword == null ? "" : searchKeyword.trim();
    boolean cafeSearchMode = !searchKeyword.isEmpty();
    String searchType = request.getParameter("searchType");
    if (!"cafes".equals(searchType)) {
        searchType = "posts";
    }
    String homeView = request.getParameter("view");
    boolean favoriteOnly = "favorite".equals(homeView);
    boolean manageOnly = "manage".equals(homeView);

    CafeDAO cafeDao = new CafeDAO();
    CafePostDAO postDao = new CafePostDAO();
    CafeFavoriteDAO favoriteDao = new CafeFavoriteDAO();

    List<CafeDTO> recentCafes = Collections.emptyList();
    List<CafeDTO> allCafes = Collections.emptyList();
    List<CafeDTO> searchedCafes = Collections.emptyList();
    List<CafePostDTO> searchedPosts = Collections.emptyList();
    List<CafePostDTO> popularPosts = Collections.emptyList();
    List<CafePostDTO> recentPosts = Collections.emptyList();
    List<CafePostDTO> myPosts = Collections.emptyList();
    List<CafeDTO> ownedCafes = Collections.emptyList();
    List<CafeDTO> joinedCafes = Collections.emptyList();
    List<CafeDTO> favoriteCafes = Collections.emptyList();
    List<CafeDTO> myCafes = new ArrayList<>();
    Set<Integer> myCafeIds = new HashSet<>();

    if (cafeSearchMode) {
        if ("cafes".equals(searchType)) {
            searchedCafes = cafeDao.selectCafeList(searchKeyword, null, null, "recent", 100);
        } else {
            searchedPosts = postDao.selectSearchPosts(searchKeyword, 100);
        }
    } else if ("popular".equals(tab)) {
        popularPosts = postDao.selectPopularPosts(8);
    } else if ("cafes".equals(tab)) {
        allCafes = cafeDao.selectCafeList(null, null, null, "recent", 100);
    } else if ("latest".equals(tab)) {
        recentPosts = postDao.selectRecentPosts(12);
    } else if ("myPosts".equals(tab)) {
        myPosts = communityLoggedIn ? postDao.selectPostsByWriter(currentLoginId) : Collections.emptyList();
    } else if (communityLoggedIn) {
        favoriteCafes = favoriteDao.selectFavoriteCafes(currentLoginId);
        if (manageOnly || !favoriteOnly) {
            ownedCafes = cafeDao.selectOwnedCafes(currentLoginId);
        }
        if (!manageOnly && !favoriteOnly) {
            joinedCafes = cafeDao.selectJoinedCafes(currentLoginId);
            for (CafeDTO cafe : ownedCafes) {
                if (myCafeIds.add(cafe.getCafeId())) {
                    myCafes.add(cafe);
                }
            }
            for (CafeDTO cafe : joinedCafes) {
                if (myCafeIds.add(cafe.getCafeId())) {
                    myCafes.add(cafe);
                }
            }
        }
    } else {
        popularPosts = postDao.selectPopularPosts(8);
        recentCafes = cafeDao.selectCafeList(null, null, null, "recent", 6);
    }

    Set<Integer> favoriteCafeIds = new HashSet<>();
    for (CafeDTO cafe : favoriteCafes) {
        favoriteCafeIds.add(cafe.getCafeId());
    }
    List<CafeDTO> visibleMyCafes = manageOnly ? ownedCafes : (favoriteOnly ? favoriteCafes : myCafes);

    String communityHomeReturn = request.getRequestURI().substring(request.getContextPath().length());
    String communityHomeQuery = request.getQueryString();
    if (communityHomeQuery != null) {
        communityHomeReturn += "?" + communityHomeQuery;
    }
    String encodedSearchKeyword = URLEncoder.encode(searchKeyword, "UTF-8");
    String displayNickname = currentNickname == null || currentNickname.trim().isEmpty() ? currentLoginId : currentNickname;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>카페홈 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=community-home-tabs-2">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="community-cafe-page">
    <aside class="community-cafe-left">
        <nav class="community-cafe-menu" aria-label="카페 메뉴">
            <a class="<%= "home".equals(tab) ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=home"><span></span>카페홈</a>
            <a class="<%= "cafes".equals(tab) ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=cafes"><span></span>카페 목록</a>
            <a class="<%= "popular".equals(tab) ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=popular"><span></span>인기글</a>
            <a class="<%= "latest".equals(tab) ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=latest"><span></span>최신글</a>
            <a class="<%= "myPosts".equals(tab) ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=myPosts"><span></span>내가 쓴 글</a>
        </nav>
    </aside>

    <div class="community-cafe-center">
        <form class="community-cafe-search" action="<%= contextPath %>/community/communityHome.jsp" method="get">
            <input type="hidden" name="tab" value="home">
            <input type="hidden" name="searchType" value="<%= escapeHtml(searchType) %>">
            <input name="keyword" value="<%= escapeHtml(searchKeyword) %>" placeholder="원하는 카페, 글을 찾아보세요">
            <button type="submit">검색</button>
            <% if (cafeSearchMode) { %>
                <a href="<%= contextPath %>/community/communityHome.jsp?tab=home">초기화</a>
            <% } %>
        </form>

    <section class="community-cafe-main">
        <h1 class="community-cafe-title"><%= cafeSearchMode ? "검색결과" : ("popular".equals(tab) ? "인기글" : ("cafes".equals(tab) ? "카페 목록" : ("latest".equals(tab) ? "최신글" : ("myPosts".equals(tab) ? "내가 쓴 글" : "카페홈")))) %></h1>

        <% if (cafeSearchMode) { %>
            <section class="community-search-results">
                <div class="community-section-heading">
                    <h2>'<%= escapeHtml(searchKeyword) %>' 검색결과</h2>
                </div>

                <div class="community-search-tabs">
                    <a class="<%= "posts".equals(searchType) ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=home&amp;keyword=<%= encodedSearchKeyword %>&amp;searchType=posts">전체글</a>
                    <a class="<%= "cafes".equals(searchType) ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=home&amp;keyword=<%= encodedSearchKeyword %>&amp;searchType=cafes">카페명</a>
                </div>

                <% if ("posts".equals(searchType)) { %>
                    <div class="community-search-list">
                        <% if (searchedPosts.isEmpty()) { %>
                            <div class="community-empty-cafe">
                                <strong>검색된 글이 없습니다.</strong>
                                <span>다른 키워드로 다시 검색해 보세요.</span>
                            </div>
                        <% } %>
                        <% for (CafePostDTO post : searchedPosts) { %>
                            <% String preview = post.getContent() == null ? "" : post.getContent().replaceAll("<[^>]*>", " ").replaceAll("\\s+", " ").trim(); %>
                            <% if (preview.length() > 120) { preview = preview.substring(0, 120) + "..."; } %>
                            <a class="community-search-row" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>">
                                <strong><%= escapeHtml(post.getTitle()) %></strong>
                                <span><%= escapeHtml(preview) %></span>
                                <small class="community-post-footer"><span><%= escapeHtml(post.getCafeName()) %></span><time><%= post.getCreatedAt() == null ? "" : post.getCreatedAt().format(postDateFormat) %></time></small>
                            </a>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="community-search-list">
                        <% if (searchedCafes.isEmpty()) { %>
                            <div class="community-empty-cafe">
                                <strong>검색된 카페가 없습니다.</strong>
                                <span>다른 카페명이나 소개글로 다시 검색해 보세요.</span>
                            </div>
                        <% } %>
                        <% for (CafeDTO cafe : searchedCafes) { %>
                            <a class="community-search-row" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                                <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                                <span><%= escapeHtml(cafe.getDescription()) %></span>
                                <small>멤버수 <%= cafe.getMemberCount() %></small>
                            </a>
                        <% } %>
                    </div>
                <% } %>
            </section>
        <% } else if ("popular".equals(tab)) { %>
            <section class="community-search-results">
                <div class="community-search-list">
                    <% if (popularPosts.isEmpty()) { %>
                        <div class="community-empty-cafe">
                            <strong>인기글이 없습니다.</strong>
                            <span>조회, 좋아요, 댓글이 쌓이면 여기에 표시됩니다.</span>
                        </div>
                    <% } %>
                    <% for (CafePostDTO post : popularPosts) { %>
                        <a class="community-search-row" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>">
                            <strong><%= escapeHtml(post.getTitle()) %></strong>
                            <span>조회 <%= post.getViewCount() %> · 좋아요 <%= post.getLikeCount() %> · 댓글 <%= post.getCommentCount() %></span>
                            <small class="community-post-footer"><span><%= escapeHtml(post.getCafeName()) %></span><time><%= post.getCreatedAt() == null ? "" : post.getCreatedAt().format(postDateFormat) %></time></small>
                        </a>
                    <% } %>
                </div>
            </section>
        <% } else if ("cafes".equals(tab)) { %>
            <section class="community-search-results">
                <div class="community-search-list">
                    <% if (allCafes.isEmpty()) { %>
                        <div class="community-empty-cafe">
                            <strong>등록된 카페가 없습니다.</strong>
                            <span>첫 카페를 만들어 보세요.</span>
                        </div>
                    <% } %>
                    <% for (CafeDTO cafe : allCafes) { %>
                        <a class="community-search-row" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                            <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                            <span><%= escapeHtml(cafe.getDescription()) %></span>
                            <small>멤버수 <%= cafe.getMemberCount() %></small>
                        </a>
                    <% } %>
                </div>
            </section>
        <% } else if ("home".equals(tab)) { %>
            <% if (communityLoggedIn) { %>
                <div class="community-cafe-tabs">
                    <a class="<%= !favoriteOnly && !manageOnly ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=home">가입한 카페</a>
                    <a class="<%= favoriteOnly ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=home&amp;view=favorite">즐겨찾는 카페</a>
                    <a class="community-cafe-manage <%= manageOnly ? "is-active" : "" %>" href="<%= contextPath %>/community/communityHome.jsp?tab=home&amp;view=manage">내 카페</a>
                </div>
                <div class="community-my-cafe-list">
                    <% if (visibleMyCafes.isEmpty()) { %>
                        <div class="community-empty-cafe">
                            <strong><%= manageOnly ? "관리 중인 카페가 없습니다." : (favoriteOnly ? "즐겨찾는 카페가 없습니다." : "가입한 카페가 없습니다.") %></strong>
                            <span><%= manageOnly ? "새 카페를 만들면 여기에서 관리할 수 있습니다." : (favoriteOnly ? "자주 보는 카페의 별을 눌러 즐겨찾기에 추가해 보세요." : "관심 있는 동네 카페를 찾아 가입해 보세요.") %></span>
                            <a class="button btn-main btn-small" href="<%= contextPath %>/community/communityHome.jsp?tab=cafes">카페 둘러보기</a>
                        </div>
                    <% } %>
                    <% for (CafeDTO cafe : visibleMyCafes) { %>
                        <article class="community-my-cafe-card">
                            <a class="community-my-cafe-head" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                                <% String imagePath = cafe.getImagePath(); %>
                                <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
                                    <img src="<%= contextPath %><%= imagePath.startsWith("/") ? imagePath : "/" + imagePath %>" alt="">
                                <% } else { %>
                                    <span class="community-cafe-avatar"><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></span>
                                <% } %>
                                <span>
                                    <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                                    <small>새 글 <%= cafe.getPostCount() %></small>
                                </span>
                            </a>
                            <div class="community-my-cafe-posts">
                                <% List<CafePostDTO> cafePosts = postDao.selectRecentPostsByCafeId(cafe.getCafeId(), 3); %>
                                <% if (cafePosts.isEmpty()) { %>
                                    <p>아직 새 글이 없습니다.</p>
                                <% } %>
                                <% for (CafePostDTO post : cafePosts) { %>
                                    <a href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>">
                                        <span><%= escapeHtml(post.getTitle()) %></span>
                                        <small><%= escapeHtml(post.getWriterNickname()) %></small>
                                    </a>
                                <% } %>
                            </div>
                            <% boolean favoriteCafe = favoriteCafeIds.contains(cafe.getCafeId()); %>
                            <form class="community-cafe-star-form" action="<%= contextPath %>/community/cafe/cafeFavoriteProcess.jsp" method="post">
                                <input type="hidden" name="cafeId" value="<%= cafe.getCafeId() %>">
                                <input type="hidden" name="redirect" value="<%= escapeHtml(communityHomeReturn) %>">
                                <button class="community-cafe-star <%= favoriteCafe ? "is-active" : "" %>" type="submit" aria-label="<%= favoriteCafe ? "즐겨찾기 해제" : "즐겨찾기" %>"><%= favoriteCafe ? "★" : "☆" %></button>
                            </form>
                        </article>
                    <% } %>
                </div>
            <% } else { %>
                <section class="community-popular-section">
                    <div class="community-section-heading">
                        <h2>인기글</h2>
                    </div>
                    <div class="community-popular-cards">
                        <% for (int i = 0; i < Math.min(3, popularPosts.size()); i++) { %>
                            <% CafePostDTO post = popularPosts.get(i); %>
                            <a class="community-popular-card" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>">
                                <strong><%= escapeHtml(post.getTitle()) %></strong>
                                <small>조회 <%= post.getViewCount() %> · 좋아요 <%= post.getLikeCount() %> · 댓글 <%= post.getCommentCount() %></small>
                                <small class="community-post-footer"><span><%= escapeHtml(post.getCafeName()) %></span><time><%= post.getCreatedAt() == null ? "" : post.getCreatedAt().format(postDateFormat) %></time></small>
                            </a>
                        <% } %>
                    </div>
                    <div class="community-popular-list">
                        <% for (int i = 3; i < Math.min(8, popularPosts.size()); i++) { %>
                            <% CafePostDTO post = popularPosts.get(i); %>
                            <a class="community-popular-row community-post-row" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>">
                                <strong><%= escapeHtml(post.getTitle()) %></strong>
                                <span class="community-post-stats">조회 <%= post.getViewCount() %> · 좋아요 <%= post.getLikeCount() %> · 댓글 <%= post.getCommentCount() %></span>
                                <span class="community-post-cafe community-post-footer"><span><%= escapeHtml(post.getCafeName()) %></span><time><%= post.getCreatedAt() == null ? "" : post.getCreatedAt().format(postDateFormat) %></time></span>
                            </a>
                        <% } %>
                    </div>
                </section>

                <section class="community-local-section">
                    <div class="community-section-heading">
                        <h2>새 카페</h2>
                    </div>
                    <% for (CafeDTO cafe : recentCafes) { %>
                        <a class="community-local-row" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                            <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                            <span><%= escapeHtml(cafe.getDescription()) %></span>
                            <small><%= escapeHtml(RegionFormatter.formatKoreanSigungu(cafe.getRegion())) %> · 회원 <%= cafe.getMemberCount() %></small>
                        </a>
                    <% } %>
                </section>
            <% } %>
        <% } else if ("latest".equals(tab)) { %>
            <section class="community-popular-section">
                <div class="community-popular-list">
                    <% if (recentPosts.isEmpty()) { %>
                        <div class="community-empty-cafe">
                            <strong>아직 게시글이 없습니다.</strong>
                            <span>첫 카페 글을 작성해 보세요.</span>
                        </div>
                    <% } %>
                    <% for (CafePostDTO post : recentPosts) { %>
                        <a class="community-popular-row community-post-row" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>">
                            <strong><%= escapeHtml(post.getTitle()) %></strong>
                            <span class="community-post-stats">조회 <%= post.getViewCount() %> · 좋아요 <%= post.getLikeCount() %> · 댓글 <%= post.getCommentCount() %></span>
                            <span class="community-post-cafe community-post-footer"><span><%= escapeHtml(post.getCafeName()) %></span><time><%= post.getCreatedAt() == null ? "" : post.getCreatedAt().format(postDateFormat) %></time></span>
                        </a>
                    <% } %>
                </div>
            </section>
        <% } else { %>
            <% if (!communityLoggedIn) { %>
                <div class="community-empty-cafe">
                    <strong>로그인이 필요합니다.</strong>
                    <span>내가 쓴 글은 로그인 후 확인할 수 있습니다.</span>
                    <a class="button btn-main btn-small" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인</a>
                </div>
            <% } else { %>
                <section class="community-popular-section">
                    <div class="community-popular-list">
                        <% if (myPosts.isEmpty()) { %>
                            <div class="community-empty-cafe">
                                <strong>작성한 글이 없습니다.</strong>
                                <span>가입한 카페에서 첫 글을 작성해 보세요.</span>
                            </div>
                        <% } %>
                        <% for (CafePostDTO post : myPosts) { %>
                            <a class="community-popular-row community-post-row" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>">
                                <strong><%= escapeHtml(post.getTitle()) %></strong>
                                <span class="community-post-stats">조회 <%= post.getViewCount() %> · 좋아요 <%= post.getLikeCount() %> · 댓글 <%= post.getCommentCount() %></span>
                                <span class="community-post-cafe community-post-footer"><span><%= escapeHtml(post.getCafeName()) %></span><time><%= post.getCreatedAt() == null ? "" : post.getCreatedAt().format(postDateFormat) %></time></span>
                            </a>
                        <% } %>
                    </div>
                </section>
            <% } %>
        <% } %>
    </section>
    </div>

    <aside class="community-cafe-right">
        <% if (communityLoggedIn) { %>
            <section class="community-side-card community-profile-card">
                <div class="community-profile-row">
                    <span class="community-profile-avatar"></span>
                    <div>
                        <strong><%= escapeHtml(displayNickname) %>님</strong>
                        <p>보관함 · 쪽지 0</p>
                    </div>
                    <a class="community-logout" href="<%= contextPath %>/member/logout.jsp">로그아웃</a>
                </div>
                <a class="community-create-cafe" href="<%= contextPath %>/community/cafe/cafeCreate.jsp">+ 카페 만들기</a>
            </section>
        <% } else { %>
            <section class="community-side-card community-login-card">
                <a class="community-login-button" href="<%= contextPath %>/member/login.jsp">로그인</a>
            </section>
        <% } %>
    </aside>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
