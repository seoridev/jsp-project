<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.CategoryDAO"%>
<%@ page import="com.carrot.dto.CategoryDTO"%>
<%@ page import="java.util.List"%>
<%@ include file="../common/sessionCheck.jsp" %>
<%
	CategoryDAO categoryDao = new CategoryDAO();
	List<CategoryDTO> categoryList = categoryDao.selectAllCategories();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>중고거래 마켓 - 상품 등록</title>
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
    <h2>🥕 물품 등록하기</h2>
    <form action="productWriteProcess.jsp" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
        
        <input type="hidden" id="sellerId" name="sellerId" value=<%= loginId %>>

        <div class="form-group">
            <label for="categoryId">카테고리</label>
            <select id="categoryId" name="categoryId" required>
                <option value="">카테고리 선택</option>
                <% 
	                if (categoryList != null) {
	                	for (CategoryDTO cat : categoryList) { 
		        %>
		        			<option value="<%= cat.getCategoryId() %>"><%= cat.getCategoryName() %></option>
		        <% 
			            }
			        }
		        %>
            </select>
        </div>

        <div class="form-group">
            <label for="title">상품명</label>
            <input type="text" id="title" name="title" maxlength="150" placeholder="상품 제목을 입력하세요" required>
        </div>
        
		<div class="form-group">
		    <label>상품 이미지 등록 (최대 5장)</label>
		    <input type="file" id="imageInput" accept="image/*" multiple style="display: none;" onchange="addFiles(this)">
		    
		    <div class="upload-btn-container">
		        <div class="upload-box" onclick="document.getElementById('imageInput').click()">
		            <span class="camera-icon">📷</span>
		            <span id="imageCount">0 / 5</span>
		        </div>
		        
		        <div id="thumbnailContainer" class="thumbnail-container"></div>
		    </div>
		
		    <input type="hidden" id="mainImageIndex" name="mainImageIndex" value="0">
		    <div id="hiddenInputContainer" style="display:none;"></div>
		</div>

        <div class="form-group">
            <label for="region">거래 지역</label>
            <input type="text" id="region" name="region" placeholder="예: 서울 강남구, 경기 수원시" required>
        </div>

        <div class="form-group price-input">
            <label for="price">판매 가격</label>
            <input type="number" id="price" name="price" placeholder="가격을 입력하세요" required>
        </div>

        <div class="form-group">
            <label for="content">상품 설명</label>
            <textarea id="content" name="content" placeholder="상품의 상태, 구매 시기 등 상세한 정보를 적어주세요" required></textarea>
        </div>

        <div class="btn-group">
            <button type="submit" class="btn btn-submit">등록 완료</button>
            <a href="productList.jsp" class="btn btn-cancel">취소</a>
        </div>
    </form>
</div>

<script>
	let uploadedFiles = [];
	let selectedMainIndex = 0;
	
	// 파일 추가 함수
	function addFiles(input) {
	    const files = Array.from(input.files);
	    
	    if (uploadedFiles.length + files.length > 5) {
	        alert("이미지는 최대 5장까지 업로드 가능합니다.");
	        input.value = ""; 
	        return;
	    }
	
	    files.forEach(file => {
	        uploadedFiles.push(file);
	    });
	
	    input.value = "";
	    renderThumbnails();
	}
	
	// 썸네일 렌더링
	function renderThumbnails() {
		const container = document.getElementById("thumbnailContainer");
	    const countSpan = document.getElementById("imageCount");
	    container.innerHTML = "";

	    uploadedFiles.forEach((file, index) => {
	        const reader = new FileReader();
	        reader.onload = function(e) {
	            const wrapper = document.createElement("div");
	            // id를 부여하여 나중에 개별 접근이 가능하게 합니다.
	            wrapper.id = `thumb-\${index}`;
	            wrapper.className = `thumb-wrapper \${index === selectedMainIndex ? 'main-selected' : ''}`;
	            wrapper.setAttribute("data-index", index);

	            wrapper.innerHTML = `
	                <div class="remove-btn" onclick="removeFile(\${index}, event)">×</div>
	                <div class="main-badge">대표</div>
	                <img src="\${e.target.result}" onclick="changeMainImage(\${index})">
	            `;
	            container.appendChild(wrapper);
	        };
	        reader.readAsDataURL(file);
	    });

	    countSpan.innerText = `\${uploadedFiles.length} / 5`;
	    updateMainIndex();
	}
	
	// 파일 삭제
	function removeFile(index, event) {
	    event.stopPropagation(); 
	    
	    uploadedFiles.splice(index, 1);
	    
	    // 대표 이미지가 지워졌을 경우 처리
	    if (selectedMainIndex === index) {
	        selectedMainIndex = 0;
	    } else if (selectedMainIndex > index) {
	        selectedMainIndex--;
	    }
	    
	    renderThumbnails();
	}
	
	// 대표 이미지 변경
	function changeMainImage(index) {
		selectedMainIndex = index;
	    updateMainIndex();

	    const wrappers = document.querySelectorAll(".thumb-wrapper");
	    wrappers.forEach((wrapper, i) => {
	        if (parseInt(wrapper.getAttribute("data-index")) === index) {
	            wrapper.classList.add("main-selected");
	        } else {
	            wrapper.classList.remove("main-selected");
	        }
	    });
	}
	
	// 인덱스 업데이트
	function updateMainIndex() {
	    document.getElementById("mainImageIndex").value = selectedMainIndex;
	}
	
	// 전송 가공
	function validateForm() {
	    const hiddenContainer = document.getElementById("hiddenInputContainer");
	    hiddenContainer.innerHTML = "";
	
	    if (uploadedFiles.length === 0) {
	        alert("최소 한 장의 이미지를 등록해주세요.");
	        return false;
	    }
	
	    uploadedFiles.forEach((file, index) => {
	        const input = document.createElement("input");
	        input.type = "file";
	        input.name = "image_" + index;
	        
	        const dt = new DataTransfer();
	        dt.items.add(file);
	        input.files = dt.files;
	        
	        hiddenContainer.appendChild(input);
	    });
	    
	    updateMainIndex();
	    return true;
	}
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>