<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.FavoriteDAO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%!
    private String statusText(String status) {
        if ("RESERVED".equalsIgnoreCase(status)) return "예약중";
        if ("SOLD".equalsIgnoreCase(status)) return "거래완료";
        return "판매중";
    }

    private String statusClass(String status) {
        if ("SOLD".equalsIgnoreCase(status)) return " is-stopped";
        return " is-active";
    }
%>
<%
    String currentLoginId = (String) session.getAttribute("loginId");
    List<ProductDTO> products = new FavoriteDAO().getFavoriteProductsByMemberId(currentLoginId);
    DecimalFormat priceFormat = new DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관심 상품 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=favorite-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">마이페이지</p>
            <h1>관심 상품</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/mypage/mypage.jsp">마이페이지</a>
            <a class="button primary" href="<%= contextPath %>/product/productList.jsp">상품 둘러보기</a>
        </div>
    </div>

    <% if ("delete".equals(request.getParameter("favorite"))) { %>
        <script>
            (() => {
                alert("관심 상품에서 해제했습니다.");
                const url = new URL(window.location.href);
                url.searchParams.delete("favorite");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } else if ("fail".equals(request.getParameter("favorite"))) { %>
        <script>
            (() => {
                alert("관심 상품 처리에 실패했습니다.");
                const url = new URL(window.location.href);
                url.searchParams.delete("favorite");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } %>

    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>상품명</th>
                    <th>가격</th>
                    <th>지역</th>
                    <th>카테고리</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (products == null || products.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="6">관심 상품이 없습니다.</td></tr>
                <% } else {
                    for (ProductDTO product : products) {
                %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>"><%= escapeHtml(product.getTitle()) %></a></td>
                        <td><%= priceFormat.format(product.getPrice()) %>원</td>
                        <td><%= escapeHtml(product.getRegion()) %></td>
                        <td><%= escapeHtml(product.getCategoryName()) %></td>
                        <td><span class="status-badge<%= statusClass(product.getStatus()) %>"><%= statusText(product.getStatus()) %></span></td>
                        <td>
                            <form class="inline-form" action="<%= contextPath %>/favorite/favoriteProcess.jsp" method="post">
                                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                <input type="hidden" name="source" value="list">
                                <button type="submit">해제</button>
                            </form>
                        </td>
                    </tr>
                <%  }
                } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
