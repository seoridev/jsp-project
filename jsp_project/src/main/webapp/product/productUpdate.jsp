<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="DAO.ProductDAO"%>
<%@ page import="DAO.ProductImageDAO"%>
<%@ page import="DTO.ProductDTO"%>
<%@ page import="DTO.ProductImageDTO"%>
<%@ page import="DAO.CategoryDAO"%>
<%@ page import="DTO.CategoryDTO"%>
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
<title>상품 수정</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
<style>
    body { font-family: 'Malgun Gothic', sans-serif; background: #f4f4f4; padding: 40px; }
    .form-container { max-width: 600px; margin: auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    h2 { color: #333; border-bottom: 2px solid #ff5a5f; padding-bottom: 10px; margin-bottom: 20px; }
    
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; }
    .form-group input, .form-group textarea, .form-group select { 
        width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; 
    }
    .form-group textarea { height: 150px; resize: none; }
    
    .btn-group { text-align: center; margin-top: 20px; }
    .btn { padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; font-size: 1em; }
    .btn-submit { background: #ff5a5f; color: white; margin-right: 10px; }
    .btn-cancel { background: #eee; color: #333; text-decoration: none; display: inline-block; }
    
    .price-input { position: relative; }
    .price-input::after { content: "원"; position: absolute; right: 10px; top: 38px; color: #888; }
	input::-webkit-outer-spin-button,
	input::-webkit-inner-spin-button  { -webkit-appearance: none; margin: 0; }

    /* 이미지 업로드 영역 스타일 */
    .upload-btn-container { display: flex; gap: 15px; align-items: center; margin-top: 10px; overflow-x: auto; padding-bottom: 10px; }
    
    .upload-box { 
        width: 80px; height: 80px; border: 2px dashed #ddd; border-radius: 8px; 
        display: flex; flex-direction: column; align-items: center; justify-content: center; 
        cursor: pointer; background: #fafafa; color: #888; font-size: 0.85em; flex-shrink: 0;
    }
    .upload-box:hover { border-color: #ff5a5f; color: #ff5a5f; }
    .camera-icon { font-size: 1.5em; margin-bottom: 2px; }

    .thumbnail-container { display: flex; gap: 15px; }
    
    .thumb-wrapper { 
        position: relative; width: 80px; height: 80px; border-radius: 8px; 
        border: 2px solid #eee; overflow: hidden; cursor: pointer; flex-shrink: 0;
    }
    .thumb-wrapper img { width: 100%; height: 100%; object-fit: cover; }
    
    /* 대표 이미지로 선택되었을 때의 테두리 스타일 */
    .thumb-wrapper.main-selected { border-color: #ff5a5f; box-shadow: 0 0 5px rgba(255, 90, 95, 0.5); }
    
    /* 대표 이미지 배지 */
    .main-badge { 
        position: absolute; top: 0; left: 0; width: 100%; background: #ff5a5f; 
        color: white; font-size: 10px; text-align: center; padding: 2px 0; font-weight: bold;
        display: none;
    }
    .thumb-wrapper.main-selected .main-badge { display: block; }
    
    /* X 버튼 스타일 */
    .thumb-wrapper { position: relative; width: 80px; height: 80px; border: 2px solid #eee; border-radius: 8px; }
    .remove-btn {
        position: absolute; top: -5px; right: -5px; width: 20px; height: 20px;
        background: rgba(0,0,0,0.6); color: white; border-radius: 50%;
        text-align: center; line-height: 18px; cursor: pointer; font-size: 14px; z-index: 15;
    }
    .remove-btn:hover { background: #ff5a5f; }
    .thumb-wrapper img { width: 100%; height: 100%; object-fit: cover; cursor: pointer; }
</style>
</head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="form-container">
    <h2>📝 물품 수정하기</h2>
    <form action="productUpdateProcess.jsp" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
        
        <div class="form-group">
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
        
        <div class="form-group">
            <label>상품명</label>
            <input type="text" name="title" value="<%= p.getTitle() %>" required>
        </div>

        <div class="form-group">
            <label>상품 이미지 수정 (최대 5장)</label>
            <input type="file" id="imageInput" accept="image/*" multiple style="display: none;" onchange="addFiles(this)">
            
            <div class="upload-btn-container">
                <div class="upload-box" onclick="document.getElementById('imageInput').click()">
                    <span class="camera-icon">📷</span>
                    <span id="imageCount"><%= imageList.size() %> / 5</span>
                </div>
                
                <div id="thumbnailContainer" class="thumbnail-container">
                    <% for(int i=0; i<imageList.size(); i++) { 
                        ProductImageDTO img = imageList.get(i);
                        String activeClass = "Y".equals(img.getIsMain()) ? "main-selected" : "";
                    %>
                        <div class="thumb-wrapper <%= activeClass %>" data-index="<%= i %>">
                            <div class="main-badge">대표</div>
                            <img src="<%= request.getContextPath() + img.getImagePath() + img.getSaveName() %>">
                        </div>
                    <% } %>
                </div>
            </div>
            <input type="hidden" id="mainImageIndex" name="mainImageIndex" value="0">
            <div id="hiddenInputContainer" style="display:none;"></div>
        </div>

        <div class="form-group">
            <label for="region">거래 지역</label>
            <input type="text" id="region" name="region" value="<%= p.getRegion() %>" required>
        </div>

        <div class="form-group">
            <label>판매 가격</label>
            <input type="number" id="price" name="price" value="<%= p.getPrice() %>" required>
        </div>

        <div class="form-group">
            <label>상품 설명</label>
            <textarea name="content" required><%= p.getContent() %></textarea>
        </div>

        <div class="btn-group">
            <button type="submit" class="btn btn-submit">수정 완료</button>
            <a href="productDetail.jsp?id=<%= productId %>" class="btn btn-cancel">취소</a>
        </div>
    </form>
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