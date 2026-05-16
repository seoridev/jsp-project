<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dao.ProductImageDAO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ page import="com.carrot.dto.ProductImageDTO" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%!
    private long parseProductId(String value) {
        try {
            return value == null ? 0 : Long.parseLong(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String detailStatusText(String status) {
        if ("RESERVED".equalsIgnoreCase(status)) {
            return "예약중";
        }
        if ("SOLD".equalsIgnoreCase(status)) {
            return "거래완료";
        }
        if ("HIDDEN".equalsIgnoreCase(status)) {
            return "숨김";
        }
        return "판매중";
    }
%>
<%
    long productId = parseProductId(request.getParameter("id"));
    ProductDAO productDAO = new ProductDAO();
    ProductImageDAO imageDAO = new ProductImageDAO();

    if (productId > 0) {
        productDAO.increaseViewCount(productId);
    }

    ProductDTO product = productId > 0 ? productDAO.selectProductById(productId) : null;
    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/product/productList.jsp?error=noProduct");
        return;
    }

    List<ProductImageDTO> images = imageDAO.selectImagesByProductId(productId);
    DecimalFormat priceFormat = new DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= escapeHtml(product.getTitle()) %> - 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <span class="status-badge"><%= detailStatusText(product.getStatus()) %></span>
                <h2><%= escapeHtml(product.getTitle()) %></h2>
                <p><%= escapeHtml(product.getRegion()) %> · 조회 <%= product.getViewCount() %></p>
            </div>
            <div class="admin-actions">
                <a class="button" href="<%= contextPath %>/product/productList.jsp">목록</a>
                <% if (loggedIn && loginId.equals(product.getSellerId())) { %>
                    <a class="button" href="<%= contextPath %>/product/productEdit.jsp?id=<%= product.getProductId() %>">수정</a>
                    <form class="inline-form" action="<%= contextPath %>/product/productDeleteProcess.jsp" method="post" onsubmit="return confirm('이 상품을 삭제 상태로 변경할까요?');">
                        <input type="hidden" name="id" value="<%= product.getProductId() %>">
                        <button type="submit">삭제</button>
                    </form>
                <% } %>
            </div>
        </div>

        <% if (!images.isEmpty()) { %>
            <div class="detail-grid">
                <% for (ProductImageDTO image : images) { %>
                    <div>
                        <dt><%= "Y".equals(image.getIsMain()) ? "대표 이미지" : "상품 이미지" %></dt>
                        <dd>
                            <img src="<%= contextPath + image.getImagePath() + image.getSaveName() %>" alt="상품 이미지" style="max-width: 100%; border-radius: 8px;">
                        </dd>
                    </div>
                <% } %>
            </div>
        <% } %>

        <dl class="detail-grid">
            <div>
                <dt>가격</dt>
                <dd><strong><%= priceFormat.format(product.getPrice()) %>원</strong></dd>
            </div>
            <div>
                <dt>카테고리</dt>
                <dd><%= escapeHtml(product.getCategoryName()) %></dd>
            </div>
            <div>
                <dt>판매자</dt>
                <dd><%= escapeHtml(product.getSellerNickname() == null ? product.getSellerId() : product.getSellerNickname()) %></dd>
            </div>
            <div>
                <dt>상품 상태</dt>
                <dd><%= detailStatusText(product.getStatus()) %></dd>
            </div>
            <div>
                <dt>설명</dt>
                <dd><%= escapeHtml(product.getContent()).replace("\n", "<br>") %></dd>
            </div>
        </dl>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
