<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.ProductDAO"%>
<%@ page import="com.carrot.dao.ProductImageDAO"%>
<%@ page import="com.carrot.dto.ProductDTO"%>
<%@ page import="com.carrot.dto.ProductImageDTO"%>
<%@ page import="com.carrot.dao.CategoryDAO"%>
<%@ page import="com.carrot.dto.CategoryDTO"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.List" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
	int productId = Integer.parseInt(request.getParameter("id"));
	ProductDAO productDao = new ProductDAO();
	ProductImageDAO productImageDao = new ProductImageDAO();
	CategoryDAO categoryDao = new CategoryDAO();

	ProductDTO p = productDao.selectProductById(productId);
	List<ProductImageDTO> imageList = productImageDao.selectImagesByProductId(productId);
	List<CategoryDTO> categoryList = categoryDao.selectAllCategories();
	
	long currentCategoryId = (p != null) ? p.getCategoryId() : 0;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>상품 수정 | 동네마켓</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
<style>
    .upload-btn-container { 
        display: flex; 
        gap: 12px; 
        align-items: center; 
        margin-top: 4px; 
        overflow-x: auto; 
        padding: 4px 4px 10px 4px; 
    }
    
    .upload-box { 
        width: 82px; 
        height: 82px; 
        border: 1px dashed #d7d0c5; 
        border-radius: 8px; 
        display: flex; 
        flex-direction: column; 
        align-items: center; 
        justify-content: center; 
        cursor: pointer; 
        background: #fffdf9; 
        color: #756b61; 
        font-size: 12px; 
        font-weight: 700;
        flex-shrink: 0;
        transition: all 0.2s;
    }
    .upload-box:hover { 
        border-color: #ff6f0f; 
        background: #fffaf3;
        color: #ff6f0f; 
    }
    .camera-icon { 
        font-size: 20px; 
        margin-bottom: 2px; 
    }
    #imageCount {
        letter-spacing: -0.02em;
    }

    .thumbnail-container { 
        display: flex; 
        gap: 12px; 
    }
    .thumb-wrapper { 
        position: relative; 
        width: 82px; 
        height: 82px; 
        border-radius: 8px; 
        border: 1px solid #d7d0c5; 
        overflow: hidden; 
        cursor: pointer; 
        flex-shrink: 0;
        background: #fff;
        transition: all 0.2s;
    }
    .thumb-wrapper img { 
        width: 100%; 
        height: 100%; 
        object-fit: cover; 
    }
    
    .thumb-wrapper.main-selected { 
        border-color: #ff6f0f; 
        outline: 2px solid #ff6f0f;
    }
    
    .main-badge { 
        position: absolute; 
        bottom: 0; 
        left: 0; 
        width: 100%; 
        background: #ff6f0f; 
        color: white; 
        font-size: 11px; 
        text-align: center; 
        padding: 2px 0; 
        font-weight: 800;
        letter-spacing: -0.03em;
        display: none;
    }
    .thumb-wrapper.main-selected .main-badge { 
        display: block; 
    }
    
    .remove-btn {
        position: absolute; 
        top: 2px; 
        right: 2px; 
        width: 20px; 
        height: 20px;
        background: rgba(32, 33, 36, 0.6); 
        color: white; 
        border-radius: 50%;
        text-align: center; 
        line-height: 18px; 
        cursor: pointer; 
        font-size: 14px; 
        font-weight: 700;
        z-index: 15;
        transition: background-color 0.15s;
    }
    .remove-btn:hover { 
        background: #d93025;
    }

    input::-webkit-outer-spin-button,
	input::-webkit-inner-spin-button { 
        -webkit-appearance: none; 
        margin: 0; 
    }
    
    .price-field-group {
        position: relative;
    }
    .price-field-group input {
        padding-right: 36px !important;
    }
    .price-unit-tag {
        position: absolute;
        right: 14px;
        bottom: 12px;
        color: #756b61;
        font-size: 15px;
        font-weight: 700;
        pointer-events: none;
    }
    
    .field textarea {
        width: 100%;
        height: 160px;
        border: 1px solid #d7d0c5;
        border-radius: 8px;
        padding: 12px 14px;
        font-size: 15px;
        font-family: inherit;
        background: #fffdf9;
        resize: none;
    }
    .field textarea:focus {
        outline: 3px solid rgba(255, 111, 15, 0.18);
        border-color: #ff6f0f;
    }
</style>
</head>
<body>
<%@ include file="../common/header.jsp" %>

<div class="auth-wrap" style="width: min(640px, calc(100% - 32px));">
    <div class="auth-panel">
        <h1 style="font-weight: 900; color: #202124; margin-bottom: 8px;"><b>📝 물품 수정하기</b></h1>
        <p style="margin: 0 0 24px; font-size: 14px; letter-spacing: -0.02em;">변경할 내용을 정확하게 수정해 주세요.</p>
        
        <form action="productUpdateProcess.jsp" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
            <input type="hidden" name="productId" value="<%= p.getProductId() %>">

            <div class="form-grid">
                
                <!-- 카테고리 -->
                <div class="field">
                    <label for="categoryId">카테고리</label>
                    <select id="categoryId" name="categoryId" required>
                        <option value="">카테고리 선택</option>
                        <% 
                            if (categoryList != null) {
                                for (CategoryDTO cat : categoryList) { 
                                    String selected = (cat.getCategoryId() == currentCategoryId) ? "selected" : "";
                        %>
                                    <option value="<%= cat.getCategoryId() %>" <%= selected %>><%= cat.getCategoryName() %></option>
                        <% 
                                }
                            }
                        %>
                    </select>
                </div>

                <!-- 상품명 -->
                <div class="field">
                    <label for="title">상품명</label>
                    <input type="text" id="title" name="title" value="<%= p.getTitle() %>" maxlength="150" placeholder="글 제목을 입력해 주세요." required>
                </div>
                
                <!-- 이미지 업로드 -->
                <div class="field">
                    <label>상품 이미지 수정 <small style="font-weight: normal; margin-left: 4px;">(최대 5장)</small></label>
                    <input type="file" id="imageInput" accept="image/*" multiple style="display: none;" onchange="addFiles(this)">
                    
                    <div class="upload-btn-container">
                        <div class="upload-box" onclick="document.getElementById('imageInput').click()">
                            <span class="camera-icon">📷</span>
                            <span id="imageCount"><%= imageList != null ? imageList.size() : 0 %> / 5</span>
                        </div>
                        
                        <div id="thumbnailContainer" class="thumbnail-container">
                            <!-- 초기 정적 데이터는 스크립트 onload에서 동적으로 바인딩하여 무결성 유지 -->
                        </div>
                    </div>
                
                    <input type="hidden" id="mainImageIndex" name="mainImageIndex" value="0">
                    <div id="hiddenInputContainer" style="display:none;"></div>
                </div>

                <!-- 거래 지역 -->
                <div class="field">
                    <label for="region">거래 지역</label>
                    <input type="text" id="region" name="region" value="<%= p.getRegion() %>" placeholder="예: 서울 강남구, 경기 수원시 인계동" required>
                </div>

                <!-- 판매 가격 -->
                <div class="field">
                    <label for="price">판매 가격</label>
                    <div class="price-field-group">
                        <input type="number" id="price" name="price" value="<%= p.getPrice() %>" placeholder="가격을 입력해 주세요." required>
                        <span class="price-unit-tag">원</span>
                    </div>
                </div>

                <!-- 상품 설명 -->
                <div class="field">
                    <label for="content">상품 설명</label>
                    <textarea id="content" name="content" placeholder="구매 시기, 브랜드, 사용감, 하자 유무 등 내용을 구체적으로 작성해 주세요." required><%= p.getContent() %></textarea>
                </div>

                <!-- 하단 액션 버튼 그룹 -->
                <div class="form-actions" style="grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 16px;">
                    <button type="submit" class="primary" style="min-height: 48px; font-size: 15px;">수정 완료</button>
                    <a href="productDetail.jsp?id=<%= productId %>" class="button" style="min-height: 48px; font-size: 15px; border-color: #ded6ca;">취소</a>
                </div>
                
            </div>
        </form>
    </div>
</div>

<script>
	let uploadedFiles = [];
	let selectedMainIndex = 0;
	
	// 페이지 로드 시 기존 DB 이미지들로 배열 초기화
    window.onload = function() {
        <% if (imageList != null) { 
            for (int i = 0; i < imageList.size(); i++) {
                ProductImageDTO img = imageList.get(i);
                String fullPath = request.getContextPath() + img.getImagePath() + img.getSaveName();
        %>
            uploadedFiles.push({
                file: null,
                preview: "<%= fullPath %>",
                isExisting: true,
                saveName: "<%= img.getSaveName() %>" 
            });
            <% if ("Y".equals(img.getIsMain())) { %>
                selectedMainIndex = <%= i %>;
            <% } %>
        <% } } %>
        renderThumbnails();
    };
    
    function addFiles(input) {
        const files = Array.from(input.files);
        if (uploadedFiles.length + files.length > 5) {
            alert("최대 5장까지 가능합니다.");
            return;
        }

        files.forEach(file => {
            const reader = new FileReader();
            reader.onload = function(e) {
                uploadedFiles.push({
                    file: file,
                    preview: e.target.result,
                    isExisting: false
                });
                renderThumbnails();
            };
            reader.readAsDataURL(file);
        });
        input.value = "";
    }
    
    function renderThumbnails() {
        const container = document.getElementById("thumbnailContainer");
        container.innerHTML = "";

        uploadedFiles.forEach((item, index) => {
            const wrapper = document.createElement("div");
            wrapper.className = `thumb-wrapper \${index === selectedMainIndex ? 'main-selected' : ''}`;
            wrapper.innerHTML = `
                <div class="remove-btn" onclick="removeFile(\${index}, event)">×</div>
                <div class="main-badge">대표</div>
                <img src="\${item.preview}" onclick="changeMainImage(\${index})">
            `;
            container.appendChild(wrapper);
        });
        document.getElementById("imageCount").innerText = `\${uploadedFiles.length} / 5`;
        document.getElementById("mainImageIndex").value = selectedMainIndex;
    }

    function removeFile(index, event) {
        event.stopPropagation();
        uploadedFiles.splice(index, 1);
        if (selectedMainIndex === index) selectedMainIndex = 0;
        else if (selectedMainIndex > index) selectedMainIndex--;
        renderThumbnails();
    }

    function changeMainImage(index) {
        selectedMainIndex = index;
        renderThumbnails();
    }
	
 	// 유효성 검사, 전송 가공
	function validateForm() {
	    const price = document.getElementById("price").value;
	    if (price < 0) {
	        alert("가격은 0원 이상이어야 합니다.");
	        return false;
	    }
	
	    const hiddenContainer = document.getElementById("hiddenInputContainer");
        hiddenContainer.innerHTML = "";
	
        let newFileCount = 0;
        uploadedFiles.forEach((item, index) => {
            if (!item.isExisting) {
                const input = document.createElement("input");
                input.type = "file";
                input.name = "image_" + index; 
                const dt = new DataTransfer();
                dt.items.add(item.file);
                input.files = dt.files;
                hiddenContainer.appendChild(input);
            } else {
                // 기존 파일이 유지되는 경우 이름만 넘김
                const input = document.createElement("input");
                input.type = "hidden";
                input.name = "existing_image_" + index;
                input.value = item.saveName;
                hiddenContainer.appendChild(input);
            }
        });
        return true;
    }
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>