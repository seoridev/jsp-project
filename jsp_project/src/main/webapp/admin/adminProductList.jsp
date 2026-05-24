<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
    private String selected(String current, String expected) {
        return expected.equalsIgnoreCase(current) ? "selected" : "";
    }

    private String statusText(String status) {
        if ("RESERVED".equalsIgnoreCase(status)) return "예약중";
        if ("SOLD".equalsIgnoreCase(status)) return "거래완료";
        if ("HIDDEN".equalsIgnoreCase(status)) return "숨김";
        return "판매중";
    }
%>
<%
    List<ProductDTO> products = new ProductDAO().getAllProductsForAdmin();
    DecimalFormat priceFormat = new DecimalFormat("#,###");
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-product-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>상품 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/adminLogout.jsp">로그아웃</a>
        </div>
    </div>
    <% if ("success".equals(result)) { %>
        <script>
            (() => {
                alert("상품 상태를 변경했습니다.");
                const url = new URL(window.location.href);
                url.searchParams.delete("result");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } else if ("fail".equals(result)) { %>
        <script>
            (() => {
                alert("상품 상태 변경에 실패했습니다.");
                const url = new URL(window.location.href);
                url.searchParams.delete("result");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } %>
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>상품명</th>
                    <th>판매자</th>
                    <th>가격</th>
                    <th>동네</th>
                    <th>상태</th>
                    <th>삭제</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (products == null || products.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="7">등록된 상품이 없습니다.</td></tr>
                <% } else {
                    for (ProductDTO product : products) {
                %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>"><%= escapeHtml(product.getTitle()) %></a></td>
                        <td><%= escapeHtml(product.getSellerId()) %></td>
                        <td><%= priceFormat.format(product.getPrice()) %>원</td>
                        <td><%= escapeHtml(product.getRegion()) %></td>
                        <td><%= statusText(product.getStatus()) %></td>
                        <td><%= "Y".equals(product.getIsDeleted()) ? "삭제됨" : "정상" %></td>
                        <td>
                            <form class="inline-form" action="<%= contextPath %>/admin/adminProductStatusProcess.jsp" method="post">
                                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                <select name="status" aria-label="상품 상태">
                                    <option value="SALE" <%= selected(product.getStatus(), "SALE") %>>판매중</option>
                                    <option value="RESERVED" <%= selected(product.getStatus(), "RESERVED") %>>예약중</option>
                                    <option value="SOLD" <%= selected(product.getStatus(), "SOLD") %>>거래완료</option>
                                    <option value="HIDDEN" <%= selected(product.getStatus(), "HIDDEN") %>>숨김</option>
                                </select>
                                <button type="submit">변경</button>
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
