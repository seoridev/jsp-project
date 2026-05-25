<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private String escapeScript(String value) {
        if (value == null) {
            return "";
        }
        return value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\r", "\\r")
            .replace("\n", "\\n");
    }

    private boolean hasRegionSuffix(String value, String suffix) {
        return value != null && value.endsWith(suffix);
    }

    private boolean isMetroRegionAlias(String value) {
        return "서울".equals(value) || "부산".equals(value) || "대구".equals(value)
            || "인천".equals(value) || "광주".equals(value) || "대전".equals(value)
            || "울산".equals(value);
    }

    private boolean isProvinceRegionAlias(String value) {
        return "경기".equals(value) || "강원".equals(value) || "충북".equals(value)
            || "충남".equals(value) || "전북".equals(value) || "전남".equals(value)
            || "경북".equals(value) || "경남".equals(value) || "제주".equals(value);
    }

    private String formatKoreanSigungu(String region) {
        if (region == null) {
            return "";
        }
        String normalized = region.trim().replaceAll("\\s+", " ");
        if (normalized.isEmpty()) {
            return "";
        }

        String[] parts = normalized.split(" ");
        if (parts.length == 1) {
            return parts[0];
        }

        StringBuilder result = new StringBuilder(parts[0]);
        String first = parts[0];

        if (hasRegionSuffix(first, "특별자치시") || "세종".equals(first)) {
            return result.toString();
        }

        boolean provinceLevel = hasRegionSuffix(first, "도") || isProvinceRegionAlias(first);
        boolean metroLevel = hasRegionSuffix(first, "특별시") || hasRegionSuffix(first, "광역시") || isMetroRegionAlias(first);

        if (provinceLevel || metroLevel) {
            result.append(" ").append(parts[1]);
            if (hasRegionSuffix(parts[1], "시") && parts.length > 2 && hasRegionSuffix(parts[2], "구")) {
                result.append(" ").append(parts[2]);
            }
            return result.toString();
        }

        if (hasRegionSuffix(first, "시") && parts.length > 1 && hasRegionSuffix(parts[1], "구")) {
            return first + " " + parts[1];
        }
        if (hasRegionSuffix(first, "시") || hasRegionSuffix(first, "군") || hasRegionSuffix(first, "구")) {
            return first;
        }

        return normalized;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    String contextPath = request.getContextPath();
    String loginId = (String) session.getAttribute("loginId");
    String loginNickname = (String) session.getAttribute("loginNickname");
    String loginRegion = (String) session.getAttribute("loginRegion");
    boolean loggedIn = loginId != null;
%>
<header class="site-header">
    <a class="brand" href="<%= contextPath %>/index.jsp">
        <span class="brand-mark">D</span>
        <span>동네마켓</span>
    </a>
    <nav class="top-nav" aria-label="주요 메뉴">
        <a href="<%= contextPath %>/index.jsp">홈</a>
        <a href="<%= contextPath %>/product/productList.jsp">상품 목록</a>
        <a href="<%= contextPath %>/community/communityHome.jsp">커뮤니티</a>
        <% if (loggedIn) { %>
            <a href="<%= contextPath %>/favorite/favoriteList.jsp">관심 상품</a>
            <a href="<%= contextPath %>/chat/chatRoomList.jsp">채팅</a>
            <a href="<%= contextPath %>/mypage/mypage.jsp">마이페이지</a>
            <a href="<%= contextPath %>/member/logout.jsp">로그아웃</a>
        <% } else { %>
            <a href="<%= contextPath %>/member/login.jsp">로그인</a>
            <a class="nav-primary" href="<%= contextPath %>/member/signup.jsp">회원가입</a>
        <% } %>
    </nav>
</header>
