<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%
    CafeDTO cafeHeroCafe = (CafeDTO) request.getAttribute("cafeIncludeCafe");
    Object cafeHeroCafeIdValue = request.getAttribute("cafeIncludeCafeId");
    int cafeHeroCafeId = cafeHeroCafeIdValue instanceof Integer ? ((Integer) cafeHeroCafeIdValue).intValue() : 0;
    String cafeHeroLoginId = (String) session.getAttribute("loginId");
    boolean cafeHeroFavorite = cafeHeroCafe != null && cafeHeroCafeId > 0
            && cafeHeroLoginId != null
            && new CafeFavoriteDAO().existsFavorite(cafeHeroCafeId, cafeHeroLoginId);
    String cafeHeroUri = request.getRequestURI().substring(request.getContextPath().length());
    String cafeHeroQuery = request.getQueryString();
    String cafeHeroReturn = cafeHeroUri + (cafeHeroQuery == null ? "" : "?" + cafeHeroQuery);
    String cafeHeroRedirect = java.net.URLEncoder.encode(cafeHeroReturn, "UTF-8");
%>
<% if (cafeHeroCafe != null) { %>
<section class="cafe-gate">
    <div class="cafe-cover-band">
        <span class="cafe-cover-label"><%= com.carrot.util.HtmlEscaper.escape(cafeHeroCafe.getCategory()) %></span>
    </div>
    <div class="cafe-gate-content">
        <div class="cafe-gate-copy">
            <div class="cafe-title-row">
                <h1><%= com.carrot.util.HtmlEscaper.escape(cafeHeroCafe.getCafeName()) %></h1>
                <span class="cafe-badge"><%= com.carrot.util.HtmlEscaper.escape(cafeHeroCafe.getVisibility()) %></span>
                <% if (cafeHeroLoginId != null) { %>
                    <form class="cafe-title-favorite-form" action="<%= request.getContextPath() %>/community/cafeFavoriteProcess.jsp" method="post">
                        <input type="hidden" name="cafeId" value="<%= cafeHeroCafeId %>">
                        <input type="hidden" name="redirect" value="<%= com.carrot.util.HtmlEscaper.escape(cafeHeroReturn) %>">
                        <button class="cafe-favorite-toggle <%= cafeHeroFavorite ? "is-active" : "" %>" type="submit" aria-label="<%= cafeHeroFavorite ? "즐겨찾기 해제" : "즐겨찾기" %>">
                            <%= cafeHeroFavorite ? "★" : "☆" %>
                        </button>
                    </form>
                <% } else { %>
                    <a class="cafe-favorite-toggle" href="<%= request.getContextPath() %>/member/login.jsp?error=loginRequired&amp;redirect=<%= cafeHeroRedirect %>" aria-label="로그인 후 즐겨찾기">☆</a>
                <% } %>
            </div>
            <p><%= com.carrot.util.HtmlEscaper.escape(cafeHeroCafe.getDescription()) %></p>
            <div class="cafe-meta-line">
                <span><%= com.carrot.util.HtmlEscaper.escape(cafeHeroCafe.getCategory()) %></span>
                <span><%= com.carrot.util.HtmlEscaper.escape(com.carrot.util.RegionFormatter.formatKoreanSigungu(cafeHeroCafe.getRegion())) %></span>
            </div>
        </div>
    </div>
</section>
<% } %>
