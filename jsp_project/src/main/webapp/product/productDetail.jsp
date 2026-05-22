<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.ProductDAO"%>
<%@ page import="com.carrot.dao.ProductImageDAO"%>
<%@ page import="com.carrot.dto.ProductDTO"%>
<%@ page import="com.carrot.dto.ProductImageDTO"%>
<%@ page import="com.carrot.dao.CategoryDAO"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ include file="../common/sessionCheck.jsp" %>

<%
    String idParam = request.getParameter("id");
    
    ProductDAO productDao = new ProductDAO();
    ProductImageDAO productImageDao = new ProductImageDAO();
	CategoryDAO categoryDao = new CategoryDAO();
    ProductDTO p = null;
    List<ProductImageDTO> imageList = null;
    
    if (idParam != null) {
        int productId = Integer.parseInt(idParam);
        p = productDao.selectProductById(productId); // 상품 정보 조회
        imageList = productImageDao.selectImagesByProductId(productId); // 이미지 리스트 조회
    }

    DecimalFormat df = new DecimalFormat("#,###");

    if (p == null) {
        out.println("<script>alert('존재하지 않는 상품입니다.'); history.back();</script>");
        return;
    }

    boolean isSeller = (session.getAttribute("loginId").equals(p.getSellerId()));
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= p.getTitle() %> - 당근마켓</title>
    <!-- 공통 app.css 연결 -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
    
    <!-- 이미지 슬라이더 및 본문 전용 스타일 보완 -->
    <style>
        .product-image-box {
            position: relative;
            width: 100%;
            background: #fff;
            border: 1px solid #e5ded3;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 24px;
            text-align: center;
        }
        .product-main-img {
            width: 100%;
            max-height: 480px;
            object-fit: cover;
            border-radius: 6px;
            margin-bottom: 12px;
        }
        .product-thumb-container {
            display: flex;
            gap: 10px;
            justify-content: center;
            overflow-x: auto;
            padding: 4px 0;
        }
        .product-thumb-wrapper {
            position: relative;
            width: 70px;
            height: 70px;
            flex-shrink: 0;
        }
        .product-thumb-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 6px;
            cursor: pointer;
            border: 2px solid transparent;
            transition: border-color 0.2s ease;
        }
        .product-thumb-wrapper img.active-thumb {
            border-color: #ff6f0f;
        }
        .product-main-badge {
            position: absolute;
            top: -4px;
            left: -4px;
            background: #ff6f0f;
            color: white;
            font-size: 10px;
            font-weight: 800;
            padding: 1px 4px;
            border-radius: 4px;
            z-index: 5;
        }
        .product-content {
            min-height: 160px;
            padding: 20px 0;
            font-size: 16px;
            line-height: 1.8;
            white-space: pre-wrap;
            word-break: break-all;
        }
    </style>
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <div class="home-layout">
        
        <!-- 좌측: 상품 이미지 및 상세 정보 영역 -->
        <section>
            <!-- 이미지 섹션 -->
            <div class="product-image-box">
                <% if (imageList != null && !imageList.isEmpty()) { 
                    ProductImageDTO mainImgDto = imageList.get(0);
                    for (ProductImageDTO img : imageList) {
                        if ("Y".equals(img.getIsMain())) {
                            mainImgDto = img;
                            break;
                        }
                    }
                    String mainImgPath = request.getContextPath() + mainImgDto.getImagePath() + mainImgDto.getSaveName();
                %>
                    <img src="<%= mainImgPath %>" id="currentImg" class="product-main-img" alt="상품 이미지">
                    
                    <div class="product-thumb-container">
                        <% for (ProductImageDTO img : imageList) { 
                            String fullPath = request.getContextPath() + img.getImagePath() + img.getSaveName();
                            boolean isMain = "Y".equals(img.getIsMain());
                        %>
                            <div class="product-thumb-wrapper">
                                <% if (isMain) { %>
                                    <span class="product-main-badge">대표</span>
                                <% } %>
                                <img src="<%= fullPath %>" class="<%= isMain ? "active-thumb" : "" %>" 
                                     onclick="changeDetailImage(this, '<%= fullPath %>')" alt="썸네일">
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-cell" style="display: flex; align-items: center; justify-content: center;">
                        등록된 이미지가 없습니다.
                    </div>
                <% } %>
            </div>

            <!-- 상품 상세 정보 내용 -->
            <div class="detail-panel">
                <div class="detail-header">
                    <div>
                        <span class="status-badge">카테고리 <%= categoryDao.selectCategorieName(p.getCategoryId()) %></span>
                        <h2><%= p.getTitle() %></h2>
                        <p>조회수 <%= p.getViewCount() %> · <%= p.getCreatedAt() %></p>
                    </div>
                    <div>
                        <%
                            String status = p.getStatus().toUpperCase();
                            if("SALE".equals(status)) { out.print("<span class='status-badge is-active'>판매중</span>"); }
                            else if("RESERVED".equals(status)) { out.print("<span class='status-badge is-stopped'>예약중</span>"); }
                            else { out.print("<span class='status-badge is-withdrawn'>판매완료</span>"); }
                        %>
                    </div>
                </div>

                <!-- 본문 텍스트 -->
                <div class="product-content">
                    <%= p.getContent() %>
                </div>

                <!-- 하단 버튼 및 액션 컨트롤 선언 -->
                <div class="form-actions" style="grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));">
                    <a href="productList.jsp" class="button">목록으로</a>
                    
                    <% if (isSeller) { %>
                        <!-- 내가 올린 상품일 때-->
                        <a href="productUpdate.jsp?id=<%= p.getProductId() %>" class="button primary">수정하기</a>
                        <button type="button" onclick="deleteConfirm(<%= p.getProductId() %>)" style="border-color: #d93025; background: #fffafa; color: #d93025;">삭제하기</button>
                    <% } else { %>
                        <!-- 내가 올린 상품이 아닐 때 -->
                        <form action="<%= request.getContextPath() %>/chat/chatCreateProcess.jsp" method="POST" style="display: contents;">
                            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                            <input type="hidden" name="sellerId" value="<%= p.getSellerId() %>">
                            <button type="submit" class="button primary">판매자와 채팅하기</button>
                        </form>
                    <% } %>
                </div>
            </div>
        </section>

        <!-- 우측: 판매자 정보 및 가격 요약 패널 -->
        <aside>
            <div class="status-panel">
                <h2>거래 정보</h2>
                <ul class="status-list">
                    <li>
                        <span>판매가격</span>
                        <strong style="font-size: 20px; color: #ff6f0f;"><%= df.format(p.getPrice()) %> 원</strong>
                    </li>
                    <li>
                        <span>거래지역</span>
                        <strong><%= p.getRegion() %></strong>
                    </li>
                    <li>
                        <span>판매자</span>
                        <strong><%= p.getSellerId() %> <% if(isSeller) { %><small style="color:#ff6f0f;">(나)</small><% } %></strong>
                    </li>
                </ul>
                
                <% if (!isSeller) { %>
                    <blockquote>
                        <small style="color: #6d645b; line-height: 1.4; display: block;">
                            * 안심하고 거래하세요! 거래 전 주소 및 상품 상태를 채팅으로 교환하는 것이 좋습니다.
                        </small>
                    </blockquote>
                <% } %>
            </div>
        </aside>

    </div>
</main>

<%@ include file="../common/footer.jsp" %>

<script>
    // 썸네일 클릭 시 메인 이미지 교체 및 테두리 활성화
    function changeDetailImage(element, imgUrl) {
        document.getElementById('currentImg').src = imgUrl;
        
        const allThumbs = document.querySelectorAll('.product-thumb-container img');
        allThumbs.forEach(thumb => thumb.classList.remove('active-thumb'));
        element.classList.add('active-thumb');
    }

    // 게시글 삭제 컨펌
    function deleteConfirm(id) {
        if(confirm("정말로 이 게시글을 삭제하시겠습니까?")) {
            location.href = "productDeleteProcess.jsp?id=" + id;
        }
    }
</script>
</body>
</html>