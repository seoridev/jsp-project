<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dao.FavoriteDAO" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
    String currentLoginId = (String) session.getAttribute("loginId");
    MemberDTO member = new MemberDAO().getMemberByLoginId(currentLoginId);
    List<ProductDTO> products = new ProductDAO().getProductsBySellerId(currentLoginId);
    int favoriteCount = new FavoriteDAO().countFavoritesByMemberId(currentLoginId);
    int saleCount = 0;
    int soldCount = 0;
    for (ProductDTO product : products) {
        if ("SOLD".equalsIgnoreCase(product.getStatus())) {
            soldCount++;
        } else {
            saleCount++;
        }
    }
    DecimalFormat scoreFormat = new DecimalFormat("0.0");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>마이페이지 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=mypage-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">마이페이지</p>
            <h1><%= escapeHtml(member == null ? currentLoginId : member.getNickname()) %>님</h1>
        </div>
        <div class="admin-actions">
            <a class="button primary" href="<%= contextPath %>/mypage/profileEdit.jsp">내 정보 수정</a>
        </div>
    </div>

    <section class="admin-summary">
        <a href="<%= contextPath %>/mypage/myProductList.jsp?status=active">
            <span>판매중 상품</span><strong><%= saleCount %></strong>
        </a>
        <a href="<%= contextPath %>/mypage/myProductList.jsp?status=SOLD">
            <span>거래완료</span><strong><%= soldCount %></strong>
        </a>
        <a href="<%= contextPath %>/favorite/favoriteList.jsp">
            <span>관심 상품</span><strong><%= favoriteCount %></strong>
        </a>
        <div>
            <span>매너 점수</span><strong><%= member == null ? "36.5" : scoreFormat.format(member.getMannerScore()) %></strong>
        </div>
    </section>

    <% if ("updated".equals(request.getParameter("result"))) { %>
        <script>
            (() => {
                alert("내 정보가 수정되었습니다.");
                const url = new URL(window.location.href);
                url.searchParams.delete("result");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } %>

    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <p>내 정보</p>
                <h2><%= escapeHtml(currentLoginId) %></h2>
            </div>
        </div>
        <dl class="detail-grid">
            <div><dt>닉네임</dt><dd><%= escapeHtml(member == null ? "" : member.getNickname()) %></dd></div>
            <div><dt>연락처</dt><dd><%= escapeHtml(member == null ? "" : member.getPhone()) %></dd></div>
            <div><dt>동네</dt><dd><%= escapeHtml(member == null ? "" : member.getRegion()) %></dd></div>
            <div><dt>상태</dt><dd><%= escapeHtml(member == null ? "" : member.getStatus()) %></dd></div>
            <div><dt>소개</dt><dd><%= escapeHtml(member == null ? "" : member.getProfileText()) %></dd></div>
        </dl>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
