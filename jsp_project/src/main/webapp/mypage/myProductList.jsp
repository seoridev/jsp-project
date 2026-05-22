<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%!
    private String statusText(String status) {
        if ("RESERVED".equalsIgnoreCase(status)) return "예약중";
        if ("SOLD".equalsIgnoreCase(status)) return "거래완료";
        if ("HIDDEN".equalsIgnoreCase(status)) return "숨김";
        return "판매중";
    }

    private String statusClass(String status) {
        if ("HIDDEN".equalsIgnoreCase(status)) return " is-withdrawn";
        if ("SOLD".equalsIgnoreCase(status)) return " is-stopped";
        return " is-active";
    }
%>
<%
    String currentLoginId = (String) session.getAttribute("loginId");
    List<ProductDTO> products = new ProductDAO().getProductsBySellerId(currentLoginId);
    DecimalFormat priceFormat = new DecimalFormat("#,###");
    String statusFilter = request.getParameter("status");
    boolean activeOnly = "active".equalsIgnoreCase(statusFilter);
    boolean soldOnly = "SOLD".equalsIgnoreCase(statusFilter);
    String listTitle = soldOnly ? "거래완료 상품" : (activeOnly ? "판매중 상품" : "내가 등록한 상품");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 상품 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=mypage-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">마이페이지</p>
            <h1><%= listTitle %></h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/mypage/mypage.jsp">마이페이지</a>
            <a class="button primary" href="<%= contextPath %>/product/productWrite.jsp">상품 등록</a>
        </div>
    </div>
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>상품명</th>
                    <th>가격</th>
                    <th>동네</th>
                    <th>카테고리</th>
                    <th>상태</th>
                    <th>조회수</th>
                </tr>
            </thead>
            <tbody>
                <% if (products == null || products.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="6">등록한 상품이 없습니다.</td></tr>
                <% } else {
                    int visibleCount = 0;
                    for (ProductDTO product : products) {
                        boolean isSold = "SOLD".equalsIgnoreCase(product.getStatus());
                        if ((activeOnly && isSold) || (soldOnly && !isSold)) {
                            continue;
                        }
                        visibleCount++;
                %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>"><%= escapeHtml(product.getTitle()) %></a></td>
                        <td><%= priceFormat.format(product.getPrice()) %>원</td>
                        <td><%= escapeHtml(product.getRegion()) %></td>
                        <td><%= escapeHtml(product.getCategoryName()) %></td>
                        <td><span class="status-badge<%= statusClass(product.getStatus()) %>"><%= statusText(product.getStatus()) %></span></td>
                        <td><%= product.getViewCount() %></td>
                    </tr>
                <%  }
                    if (visibleCount == 0) {
                %>
                    <tr><td class="empty-cell" colspan="6">해당 상품이 없습니다.</td></tr>
                <%  }
                } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
