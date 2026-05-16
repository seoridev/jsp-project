<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.FavoriteDAO" %>
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

    private String detailStatusClass(String status) {
        if ("RESERVED".equalsIgnoreCase(status)) {
            return "product-status-reserved";
        }
        if ("SOLD".equalsIgnoreCase(status)) {
            return "product-status-sold";
        }
        if ("HIDDEN".equalsIgnoreCase(status)) {
            return "product-status-hidden";
        }
        return "product-status-sale";
    }
%>
<%
    long productId = parseProductId(request.getParameter("id"));
    ProductDAO productDAO = new ProductDAO();
    ProductImageDAO imageDAO = new ProductImageDAO();
    FavoriteDAO favoriteDAO = new FavoriteDAO();

    if (productId > 0) {
        productDAO.increaseViewCount(productId);
    }

    ProductDTO product = productId > 0 ? productDAO.selectProductById(productId) : null;
    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/product/productList.jsp?error=noProduct");
        return;
    }

    List<ProductImageDTO> images = imageDAO.selectImagesByProductId(productId);
    String detailLoginId = (String) session.getAttribute("loginId");
    boolean detailLoggedIn = detailLoginId != null;
    boolean favorite = detailLoggedIn && !detailLoginId.equals(product.getSellerId()) && favoriteDAO.isFavorite(detailLoginId, productId);
    int favoriteCount = favoriteDAO.countFavoritesByProductId(productId);
    DecimalFormat priceFormat = new DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= escapeHtml(product.getTitle()) %> - 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/product.css?v=external-ui-1">
</head>
<body class="product-page">
<%@ include file="../common/header.jsp" %>
<main class="product-detail-container">
    <div class="product-image-section">
        <% if (images != null && !images.isEmpty()) {
            ProductImageDTO mainImage = images.get(0);
            for (ProductImageDTO image : images) {
                if ("Y".equals(image.getIsMain())) {
                    mainImage = image;
                    break;
                }
            }
            String mainImagePath = contextPath + mainImage.getImagePath() + mainImage.getSaveName();
        %>
            <img src="<%= mainImagePath %>" id="currentImg" class="product-main-img" alt="상품 이미지">
            <div class="product-thumb-container">
                <% for (ProductImageDTO image : images) {
                    String fullPath = contextPath + image.getImagePath() + image.getSaveName();
                    boolean isMain = "Y".equals(image.getIsMain());
                %>
                    <div class="product-detail-thumb-wrapper">
                        <% if (isMain) { %>
                            <span class="product-detail-main-badge">대표</span>
                        <% } %>
                        <img src="<%= fullPath %>"
                             class="product-thumb-img <%= isMain ? "active-thumb" : "" %>"
                             alt="상품 썸네일"
                             onclick="changeDetailImage(this, '<%= fullPath %>')">
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="product-no-image">등록된 이미지가 없습니다.</div>
        <% } %>
    </div>

    <div class="product-detail-header">
        <div class="product-category"><%= escapeHtml(product.getCategoryName()) %></div>
        <h1 class="product-detail-title"><%= escapeHtml(product.getTitle()) %></h1>
        <div class="product-meta-info">
            <span>판매자: <strong><%= escapeHtml(product.getSellerNickname() == null ? product.getSellerId() : product.getSellerNickname()) %></strong></span>
            <span>조회수: <%= product.getViewCount() %></span>
            <span>관심: <%= favoriteCount %></span>
        </div>
    </div>

    <div class="product-info-box">
        <div class="product-info-item">
            <span class="product-label">판매 가격</span>
            <span class="product-value product-price-value"><%= priceFormat.format(product.getPrice()) %>원</span>
        </div>
        <div class="product-info-item">
            <span class="product-label">거래 희망 지역</span>
            <span class="product-value"><%= escapeHtml(product.getRegion()) %></span>
        </div>
        <div class="product-info-item">
            <span class="product-label">판매 상태</span>
            <span class="product-value">
                <span class="product-status-badge <%= detailStatusClass(product.getStatus()) %>">
                    <%= detailStatusText(product.getStatus()) %>
                </span>
            </span>
        </div>
    </div>

    <div class="product-content-section"><%= escapeHtml(product.getContent()) %></div>

    <% if ("success".equals(request.getParameter("report"))) { %>
        <p class="message success">신고가 접수되었습니다.</p>
    <% } %>
    <% if ("insert".equals(request.getParameter("favorite"))) { %>
        <p class="message success">관심 상품에 등록했습니다.</p>
    <% } else if ("delete".equals(request.getParameter("favorite"))) { %>
        <p class="message success">관심 상품에서 해제했습니다.</p>
    <% } else if ("own".equals(request.getParameter("favorite"))) { %>
        <p class="message error">내가 등록한 상품은 관심 상품으로 등록할 수 없습니다.</p>
    <% } else if ("fail".equals(request.getParameter("favorite"))) { %>
        <p class="message error">관심 상품 처리에 실패했습니다.</p>
    <% } %>

    <div class="product-button-group">
        <a href="<%= contextPath %>/product/productList.jsp" class="product-btn product-btn-list">목록으로</a>
        <% if (loggedIn && loginId.equals(product.getSellerId())) { %>
            <a href="<%= contextPath %>/product/productEdit.jsp?id=<%= product.getProductId() %>" class="product-btn product-btn-edit">수정하기</a>
            <form action="<%= contextPath %>/product/productDeleteProcess.jsp" method="post" onsubmit="return confirm('정말로 이 게시글을 삭제하시겠습니까?');">
                <input type="hidden" name="id" value="<%= product.getProductId() %>">
                <button type="submit" class="product-btn product-btn-delete">삭제하기</button>
            </form>
        <% } else if (loggedIn) { %>
            <form action="<%= contextPath %>/favorite/favoriteProcess.jsp" method="post">
                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                <button type="submit" class="product-btn product-btn-favorite <%= favorite ? "is-active" : "" %>">
                    <%= favorite ? "관심 해제" : "관심 등록" %>
                </button>
            </form>
            <a href="<%= contextPath %>/report/report.jsp?targetType=PRODUCT&targetId=<%= product.getProductId() %>" class="product-btn product-btn-delete">신고하기</a>
        <% } else { %>
            <a href="<%= contextPath %>/member/login.jsp?error=loginRequired" class="product-btn product-btn-favorite">관심 등록</a>
        <% } %>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
<script>
function changeDetailImage(element, imgUrl) {
    document.getElementById("currentImg").src = imgUrl;
    document.querySelectorAll(".product-thumb-img").forEach((thumb) => {
        thumb.classList.remove("active-thumb");
    });
    element.classList.add("active-thumb");
}
</script>
</body>
</html>
