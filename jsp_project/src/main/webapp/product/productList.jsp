<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.CategoryDAO" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dao.ProductImageDAO" %>
<%@ page import="com.carrot.dto.CategoryDTO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ page import="com.carrot.dto.ProductImageDTO" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>

<%
	String type = request.getParameter("type");
	String keyword = request.getParameter("keyword");
	String categoryIdParam = request.getParameter("categoryId");
	Integer categoryId = null;
	
	String minPriceParam = request.getParameter("minPrice");
    String maxPriceParam = request.getParameter("maxPrice");

    // categoryId 파라미터를 숫자로 안전하게 변환
	if (categoryIdParam != null && !categoryIdParam.trim().isEmpty()) {
	    try {
	        categoryId = Integer.parseInt(categoryIdParam);
	    } catch (NumberFormatException e) {
	        categoryId = null;
	    }
	}
    
	// 가격 데이터 유효성 검사 및 기본값 설정
    Integer minPrice = null;
    Integer maxPrice = null;
    try {
        if (minPriceParam != null && !minPriceParam.trim().isEmpty()) minPrice = Integer.parseInt(minPriceParam);
    } catch (NumberFormatException e) { 
    	minPrice = null; 
    }
    
    try {
        if (maxPriceParam != null && !maxPriceParam.trim().isEmpty()) maxPrice = Integer.parseInt(maxPriceParam);
    } catch (NumberFormatException e) { 
    	maxPrice = null; 
    }

    ProductDAO dao = new ProductDAO();
    CategoryDAO categoryDao = new CategoryDAO();
    ProductImageDAO imgDao = new ProductImageDAO();
    List<CategoryDTO> categoryList = categoryDao.selectAllCategories();
    String selectedCategoryName = null;

    // 존재하는 활성 카테고리일 때만 categoryId 필터 적용
    if (categoryId != null) {
        selectedCategoryName = categoryDao.selectCategoryName(categoryId);
        if (selectedCategoryName == null) {
            categoryId = null;
        }
    }

    // 카테고리와 검색어를 함께 적용해 상품 조회
    List<ProductDTO> list = dao.selectProductList(type, keyword, categoryId, minPrice, maxPrice);
    String displayType = (type == null || type.trim().isEmpty()) ? "all" : type;
    
    // 잘못된 검색 type은 화면과 링크에서 전체 검색으로 처리
    if (!"title".equals(displayType) && !"content".equals(displayType) && !"all".equals(displayType)) {
        displayType = "all";
    }
    String displayKeyword = keyword == null ? "" : keyword.trim();
    String encodedKeyword = URLEncoder.encode(displayKeyword, "UTF-8");
    
    String displayMinPrice = (minPriceParam == null || minPriceParam.trim().isEmpty()) ? "0" : minPriceParam.trim();
    String displayMaxPrice = (maxPriceParam == null || maxPriceParam.trim().isEmpty()) ? "1000000" : maxPriceParam.trim();
    
    int productCount = list == null ? 0 : list.size();
    DecimalFormat df = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>물품 목록 | 동네 마켓</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
<style>    
    /* 카테고리 필터 칩 */
    .category-filter {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 24px;
    }
    .category-filter a {
        display: inline-flex;
        align-items: center;
        min-height: 34px;
        padding: 0 14px;
        border: 1px solid #ded6ca;
        border-radius: 999px;
        background: #fffaf3;
        color: #5f574f;
        font-size: 13px;
        font-weight: 700;
        transition: all 0.2s;
    }
    .category-filter a:hover { border-color: #ffb27a; color: #d95c00; }
    .category-filter a.active { border-color: #ff6f0f; background: #ff6f0f; color: #fff; }
    
    /* 검색바 */
    .product-search-wrapper { margin-bottom: 32px; }
    .product-search-wrapper .inline-form { width: 100%; max-width: 600px; display: flex; gap: 6px; }
    .product-search-wrapper select { min-width: 110px; padding: 0 10px; border: 1px solid #d7d0c5; border-radius: 8px; background: #fffdf9; }
    .product-search-wrapper input[type="text"] { flex: 1; min-height: 42px; border: 1px solid #d7d0c5; border-radius: 8px; padding: 0 12px; background: #fffdf9; font-size: 14px; }
    .product-search-wrapper input[type="text"]:focus { outline: 3px solid rgba(255, 111, 15, 0.18); border-color: #ff6f0f; }
    .search-reset-link { font-size: 13px; color: #756b61; font-weight: 700; margin-left: 8px; align-self: center; }
    .search-reset-link:hover { color: #202124; text-decoration: underline; }
    
    /* 당근마켓풍 카드형 그리드 레이아웃 */
    .product-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
        gap: 28px 18px;
        margin-bottom: 40px;
    }
    
    .product-card {
        display: flex;
        flex-direction: column;
        text-decoration: none;
        color: inherit;
        background: #fff;
        border-radius: 12px;
        overflow: hidden;
        border: 1px solid #eae5dd;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    
    .product-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.06);
    }
    
    /* 1:1 비율 이미지 박스 */
    .card-photo-box {
        position: relative;
        width: 100%;
        padding-top: 100%; 
        background-color: #f7f4ee;
        overflow: hidden;
    }
    
    .card-photo-box img {
        position: absolute;
        top: 0; left: 0;
        width: 100%; height: 100%;
        object-fit: cover;
    }
    
    .no-image-placeholder {
        position: absolute;
        top: 0; left: 0;
        width: 100%; height: 100%;
        display: flex; flex-direction: column;
        align-items: center; justify-content: center;
        color: #a89f91; font-size: 13px; font-weight: bold;
    }
    
    /* 카드 텍스트 레이아웃 */
    .card-details {
        padding: 12px;
        display: flex;
        flex-direction: column;
        flex-grow: 1;
    }
    
    .card-title {
        font-size: 14px;
        font-weight: 700;
        color: #202124;
        line-height: 1.4;
        margin: 0 0 4px 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    
    .card-meta {
        font-size: 12px;
        color: #756b61;
        margin-bottom: 8px;
    }
    
    .card-price-row {
        margin-top: auto;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    
    .card-price {
        font-size: 15px;
        font-weight: 800;
        color: #ff6f0f;
    }
    
    .card-views {
        font-size: 11px;
        background: #f4eee3;
        color: #6d645b;
        padding: 2px 6px;
        border-radius: 4px;
        font-weight: 700;
    }

    .grid-empty-message {
        grid-column: 1 / -1;
        text-align: center;
        padding: 60px 0;
        color: #756b61;
        font-size: 14px;
        font-weight: 700;
        background: #fffdf9;
        border: 1px dashed #d7d0c5;
        border-radius: 12px;
    }
    
    .admin-actions.list-actions {
        margin-top: 32px;
        display: flex;
        justify-content: flex-end;
    }
    
	.admin-list-meta {
	    display: flex; align-items: center; justify-content: flex-start; gap: 8px;
	    margin: 8px 0 16px; color: #6d645b; font-size: 14px; font-weight: 700;
	    letter-spacing: -0.03em !important; 
	}
	.admin-list-meta strong { color: #202124; font-weight: 800; letter-spacing: -0.04em !important; }
	.admin-list-meta span { font-weight: normal; color: #756b61; margin-left: 4px; letter-spacing: -0.02em !important; }
	
	/* 레인지 슬라이더 전체 컨테이너 */
	.price-slider-container {
	    display: flex;
	    flex-direction: column;
	    gap: 8px;
	    width: 260px; /* 슬라이더 바의 전체 너비 */
	    padding: 0 10px;
	    position: relative;
	}
	
	/* 슬라이더 바가 배치되는 껍데기 */
	.slider-track-wrapper {
	    position: relative;
	    width: 100%;
	    height: 6px;
	    margin-top: 10px;
	}
	
	/* 실제 선택된 영역을 표시할 투명/유색 트랙 */
	.slider-track {
	    position: absolute;
	    width: 100%;
	    height: 100%;
	    background: #eae5dd; /* 비선택 영역 색상 */
	    border-radius: 5px;
	}
	
	/* 겹쳐진 두 개의 range 인풋 */
	.price-slider-container input[type="range"] {
	    position: absolute;
	    width: 100%;
	    height: 6px;
	    top: 0;
	    left: 0;
	    background: none;
	    pointer-events: none; /* 트랙 클릭 방해 금지 */
	    -webkit-appearance: none;
	    appearance: none;
	}
	
	/* 크롬/사파리/엣지 브라우저의 슬라이더 동그라미(핸들) 스타일 */
	.price-slider-container input[type="range"]::-webkit-slider-thumb {
	    height: 18px;
	    width: 18px;
	    border-radius: 50%;
	    background: #ff6f0f; /* 당근마켓 주황색 */
	    border: 2px solid #fff;
	    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
	    cursor: pointer;
	    pointer-events: auto; /* 핸들은 클릭/드래그 가능하도록 */
	    -webkit-appearance: none;
	}
	
	/* 파이어폭스 브라우저의 슬라이더 동그라미 스타일 */
	.price-slider-container input[type="range"]::-moz-range-thumb {
	    height: 18px;
	    width: 18px;
	    border-radius: 50%;
	    background: #ff6f0f;
	    border: 2px solid #fff;
	    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
	    cursor: pointer;
	    pointer-events: auto;
	}
	
	/* 아래쪽에 현재 설정된 가격을 텍스트로 보여줄 영역 */
	.slider-values {
	    display: flex;
	    justify-content: space-between;
	    font-size: 12px;
	    color: #756b61;
	    font-weight: bold;
	}
</style>
</head>
<body>
<%@ include file="../common/header.jsp" %>

    <div class="admin-shell">
        
        <div class="admin-heading">
            <div>
                <h1 style="font-weight: 900; color: #202124;">🥕 중고거래 물품 목록</h1>
                <p class="admin-list-meta" style="margin-top: 8px; margin-bottom: 0;">
                    현재 카테고리: <strong><%= selectedCategoryName != null ? selectedCategoryName : "전체" %></strong>
                    (총 <strong><%= productCount %></strong>개 관련 상품)
                    <% if (!displayKeyword.isEmpty()) { %>
                        <span style="font-weight: normal; color: #756b61; margin-left: 6px;">/ 검색어: "<%= displayKeyword %>"</span>
                    <% } %>
                </p>
            </div>
        </div>

        <div class="category-filter">
			<%
			    String priceQuery = "";
			
			    if(minPrice != null && minPrice != 0) {
			        priceQuery += "&minPrice=" + minPrice;
			    }
			
			    if(maxPrice != null && maxPrice != 0) {
			        priceQuery += "&maxPrice=" + maxPrice;
			    }
			%>
            <a class="<%= categoryId == null ? "active" : "" %>"
               href="productList.jsp?<%= !displayKeyword.isEmpty() ? "type=" + displayType + "&keyword=" + encodedKeyword : "" %><%= priceQuery %>">전체</a>
            <% for (CategoryDTO category : categoryList) {
                String categoryUrl = "productList.jsp?categoryId=" + category.getCategoryId();
                if (!displayKeyword.isEmpty()) {
                    categoryUrl += "&type=" + displayType + "&keyword=" + encodedKeyword;
                }
                categoryUrl += priceQuery; // 가격 조건 유지
            %>
                <a class="<%= categoryId != null && categoryId == category.getCategoryId() ? "active" : "" %>"
                   href="<%= categoryUrl %>"><%= category.getCategoryName() %></a>
            <% } %>
        </div>

		<div class="product-search-wrapper">
		    <form action="productList.jsp" method="get" class="inline-form" style="max-width: 950px; align-items: center;">
		        <% if (categoryId != null) { %>
		        <input type="hidden" name="categoryId" value="<%= categoryId %>">
		        <% } %>
		        
		        <select name="type">
		            <option value="all" <%= "all".equals(displayType) ? "selected" : "" %>>제목+내용</option>
		            <option value="title" <%= "title".equals(displayType) ? "selected" : "" %>>제목</option>
		            <option value="content" <%= "content".equals(displayType) ? "selected" : "" %>>내용</option>
		        </select> 
		        
		        <input type="text" name="keyword" value="<%= displayKeyword %>" placeholder="필요한 물품을 검색해보세요.">
		        
		        <div class="price-slider-container">
		            <div class="slider-track-wrapper">
		                <div class="slider-track" id="sliderTrack"></div>
		                <input type="range" id="minPriceInput" name="minPrice" 
		                       min="0" max="1000000" step="10000" value="<%= displayMinPrice %>" oninput="slideMin()">
		                <input type="range" id="maxPriceInput" name="maxPrice" 
		                       min="0" max="1000000" step="10000" value="<%= displayMaxPrice %>" oninput="slideMax()">
		            </div>
		            <div class="slider-values">
		                <span id="minPriceText">0원</span>
		                <span id="maxPriceText">100만 원</span>
		            </div>
		        </div>
		
		        <button type="submit" class="primary">검색</button>
		
		        <% if(!displayKeyword.isEmpty() || categoryId != null || minPriceParam != null || maxPriceParam != null) { %>
		        	<a href="productList.jsp" class="search-reset-link">초기화</a>
		        <% } %>
		    </form>
		</div>

        <div class="product-grid">
		    <% if (list == null || list.isEmpty()) { %>
		        <div class="grid-empty-message">등록된 물품이 없습니다. 첫 물품의 주인공이 되어보세요!</div>
		    <% } else {
		        for (ProductDTO p : list) {
		
		            // [수정 핵심] 각 상품 루프가 돌 때마다 이미지 테이블에서 첫 번째(메인) 이미지를 조회
		            List<ProductImageDTO> images = imgDao.selectImagesByProductId(p.getProductId());
		            String mainImageName = null;
		            if(images != null && !images.isEmpty()) {
		                mainImageName = images.get(0).getSaveName(); // index 0번이 메인 이미지
		            }
		    %>
		        <a href="productDetail.jsp?id=<%= p.getProductId() %>" class="product-card">
		            <div class="card-photo-box">
		                <% if (mainImageName != null && !mainImageName.trim().isEmpty()) { %>
		                    <img src="<%= request.getContextPath() %>/upload/product/<%= mainImageName %>" alt="<%= p.getTitle() %>">
		                <% } else { %>
		                    <div class="no-image-placeholder"><span>📷 이미지 준비중</span></div>
		                <% } %>
		            </div>
		
		            <div class="card-details">
		                <h2 class="card-title"><%= p.getTitle() %></h2>
		                <div class="card-meta">
		                    <span class="card-region"><%= p.getRegion() %></span>
		                </div>
		                <div class="card-price-row">
		                    <span class="card-price"><%= df.format(p.getPrice()) %>원</span>
		                    <span class="card-views">👁️ <%= p.getViewCount() %></span>
		                </div>
		            </div>
		        </a>
		    <% 
		        }
		    } 
		    %>
		</div>
        
        <div class="admin-actions list-actions">
            <a href="productWrite.jsp" class="button primary" style="min-height: 46px; padding: 0 24px; border-radius: 999px; font-size: 15px;">
                <span style="margin-right: 6px; font-size: 18px; font-weight: 900;">+</span> 물품 등록하기
            </a>
        </div>
        
    </div>

<%@ include file="../common/footer.jsp" %>

<script>
    const minInput = document.getElementById("minPriceInput");
    const maxInput = document.getElementById("maxPriceInput");
    const minText = document.getElementById("minPriceText");
    const maxText = document.getElementById("maxPriceText");
    const track = document.getElementById("sliderTrack");
    
    // 최소 가격 스케일 간격 제한 
    const priceGap = 50000; 

    function formatPrice(value) {
        if(value == 0) return "0원";
        if(value >= 1000000) return "100만 원+";
        return Number(value).toLocaleString() + "원";
    }

    function updateTrackColor() {
        const minPercent = (minInput.value / minInput.max) * 100;
        const maxPercent = (maxInput.value / maxInput.max) * 100;
        // CSS  속성 제어
        track.style.background = `linear-gradient(to right, #eae5dd ${minPercent}% , #ff6f0f ${minPercent}% , #ff6f0f ${maxPercent}%, #eae5dd ${maxPercent}%)`;
    }

    function slideMin() {
        if (parseInt(maxInput.value) - parseInt(minInput.value) <= priceGap) {
            minInput.value = parseInt(maxInput.value) - priceGap;
        }
        minText.textContent = formatPrice(minInput.value);
        updateTrackColor();
    }

    function slideMax() {
        if (parseInt(maxInput.value) - parseInt(minInput.value) <= priceGap) {
            maxInput.value = parseInt(minInput.value) + priceGap;
        }
        maxText.textContent = formatPrice(maxInput.value);
        updateTrackColor();
    }

    // 페이지가 처음 로드되었을 때 초기 슬라이더 상태 렌더링
    window.addEventListener("DOMContentLoaded", () => {
        minText.textContent = formatPrice(minInput.value);
        maxText.textContent = formatPrice(maxInput.value);
        updateTrackColor();
    });
</script>
</body>
</html>