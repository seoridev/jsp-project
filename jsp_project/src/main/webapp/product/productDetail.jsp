<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="DAO.ProductDAO"%>
<%@ page import="DAO.ProductImageDAO"%>
<%@ page import="DTO.ProductDTO"%>
<%@ page import="DTO.ProductImageDTO"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ include file="../common/sessionCheck.jsp" %>

<%
    String idParam = request.getParameter("id");
    
	ProductDAO productDao = new ProductDAO();
	ProductImageDAO productImageDao = new ProductImageDAO();
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
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= p.getTitle() %> - 상세 정보</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
<style>
    body { font-family: 'Malgun Gothic', sans-serif; background: #f9f9f9; padding: 40px; color: #333; line-height: 1.6; }
	.detail-container { max-width: 800px; margin: auto; background: white; padding: 40px; border-radius: 12px; }    
    
    /* 이미지 슬라이드/리스트 영역 */
    .image-section { width: 100%; margin-bottom: 30px; text-align: center; }
    .main-img { width: 100%; max-height: 500px; object-fit: cover; border-radius: 8px; margin-bottom: 10px; }
    .thumb-container { display: flex; gap: 10px; justify-content: center; overflow-x: auto; }
    .thumb-img { width: 80px; height: 80px; object-fit: cover; border-radius: 4px; cursor: pointer; border: 2px solid transparent; }
    .thumb-img:hover { border-color: #ff5a5f; }

    .content-section { white-space: pre-wrap; padding: 20px 0; border-top: 1px solid #eee; }
    
    /* 상단 영역 */
    .header { border-bottom: 2px solid #eee; padding-bottom: 20px; margin-bottom: 30px; }
    .category { color: #ff5a5f; font-weight: bold; font-size: 0.9em; }
    .title { font-size: 2em; margin: 10px 0; }
    .meta-info { color: #888; font-size: 0.85em; display: flex; gap: 15px; }

    /* 상품 정보 요약 박스 */
    .info-box { background: #fff8f8; border-radius: 8px; padding: 20px; margin-bottom: 30px; display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
    .info-item { display: flex; flex-direction: column; }
    .label { font-size: 0.8em; color: #999; margin-bottom: 5px; }
    .value { font-size: 1.1em; font-weight: 500; }
    .price-value { color: #ff5a5f; font-size: 1.5em; font-weight: bold; }

    /* 본문 내용 */
    .content-section { min-height: 200px; white-space: pre-wrap; margin-bottom: 40px; padding: 10px; border-top: 1px solid #eee; padding-top: 30px; }

    /* 버튼 영역 */
    .button-group { display: flex; gap: 10px; justify-content: center; }
    .btn { padding: 12px 25px; border-radius: 6px; border: none; cursor: pointer; font-weight: bold; text-decoration: none; }
    .btn-list { background: #eee; color: #333; }
    .btn-edit { background: #333; color: #white; }
    .btn-delete { background: #ff5a5f; color: white; }
    
    /* 상태 배지 */
    .badge { padding: 4px 10px; border-radius: 20px; font-size: 0.8em; color: white; }
    .badge-sale { background: #2ecc71; }
    .badge-reserved { background: #f1c40f; }
    .badge-sold { background: #95a5a6; }
    
    /* 기존 스타일 유지 및 대표 표시 스타일 추가 */
    .image-section { width: 100%; margin-bottom: 30px; text-align: center; }
    .main-img { width: 100%; max-height: 500px; object-fit: cover; border-radius: 8px; margin-bottom: 15px; }
    .thumb-container { display: flex; gap: 12px; justify-content: center; overflow-x: auto; padding: 5px; }
    
    /* 썸네일 감싸는 박스 */
    .detail-thumb-wrapper { position: relative; width: 80px; height: 80px; flex-shrink: 0; }
    
    .thumb-img { width: 100%; height: 100%; object-fit: cover; border-radius: 6px; cursor: pointer; border: 2px solid transparent; transition: 0.2s; }
    .thumb-img:hover { border-color: #ff5a5f; }
    
    /* 대표 이미지 썸네일에 줄 테두리 강조 */
    .thumb-img.active-thumb { border-color: #ff5a5f; }

    /* 상세페이지용 대표 배지 스타일 */
    .detail-main-badge {
        position: absolute;
        top: -5px;
        left: -5px;
        background: #ff5a5f;
        color: white;
        font-size: 11px;
        font-weight: bold;
        padding: 2px 6px;
        border-radius: 4px;
        z-index: 10;
        box-shadow: 0 2px 4px rgba(0,0,0,0.15);
    }
</style>
</head>
<body>
<%@ include file="../common/header.jsp" %>

<div class="detail-container">
	<div class="image-section">
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
            <img src="<%= mainImgPath %>" id="currentImg" class="main-img" alt="상품이미지">
            
            <div class="thumb-container">
                <% for (ProductImageDTO img : imageList) { 
                    String fullPath = request.getContextPath() + img.getImagePath() + img.getSaveName();
                    boolean isMain = "Y".equals(img.getIsMain());
                %>
                    <div class="detail-thumb-wrapper">
                        <% if (isMain) { %>
                            <span class="detail-main-badge">대표</span>
                        <% } %>
                        <img src="<%= fullPath %>" class="thumb-img <%= isMain ? "active-thumb" : "" %>" 
                             onclick="changeDetailImage(this, '<%= fullPath %>')">
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div style="width:100%; height:300px; background:#f0f0f0; display:flex; align-items:center; justify-content:center; color:#ccc;">
                등록된 이미지가 없습니다.
            </div>
        <% } %>
    </div>
    <div class="header">
        <div class="category">카테고리 번호: <%= p.getCategoryId() %></div>
        <h1 class="title"><%= p.getTitle() %></h1>
        <div class="meta-info">
            <span>판매자: <strong><%= p.getSellerId() %></strong></span>
            <span>작성일: <%= p.getCreatedAt() %></span>
            <span>조회수: <%= p.getViewCount() %></span>
        </div>
    </div>

    <div class="info-box">
        <div class="info-item">
            <span class="label">판매 가격</span>
            <span class="value price-value"><%= df.format(p.getPrice()) %>원</span>
        </div>
        <div class="info-item">
            <span class="label">거래 희망 지역</span>
            <span class="value"><%= p.getRegion() %></span>
        </div>
        <div class="info-item">
            <span class="label">판매 상태</span>
            <span class="value">
                <span class="badge badge-<%= p.getStatus().toLowerCase() %>">
                    <%= p.getStatus() %>
                </span>
            </span>
        </div>
    </div>

    <div class="content-section">
        <%= p.getContent() %>
    </div>

    <div class="button-group">
        <a href="productList.jsp" class="btn btn-list">목록으로</a>
        <%		
		    if (loginId != null && loginId.equals(p.getSellerId())) {
		%>
		    <a href="productUpdate.jsp?id=<%= p.getProductId() %>" class="btn btn-edit" style="color:white;">수정하기</a>
		    <button onclick="deleteConfirm(<%= p.getProductId() %>)" class="btn btn-delete">삭제하기</button> 
		<%
		    }
		%>
    </div>
</div>

<script>
	// 썸네일 클릭 시 이미지 변경
	function changeDetailImage(element, imgUrl) {
	    document.getElementById('currentImg').src = imgUrl;
	    
	    // 클릭할 때 테두리 변화를 주고 싶다면 아래 로직 활성화
	    const allThumbs = document.querySelectorAll('.thumb-img');
	    allThumbs.forEach(thumb => thumb.classList.remove('active-thumb'));
	    element.classList.add('active-thumb');
	}

    function deleteConfirm(id) {
        if(confirm("정말로 이 게시글을 삭제하시겠습니까?")) {
        	location.href = "productDeleteProcess.jsp?id=" + id;
        }
    }
</script>

<%@ include file="../common/footer.jsp" %>
</body>
</html>