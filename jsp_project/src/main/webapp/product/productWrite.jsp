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
<title>상품 등록 | 동네마켓</title>
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
        <h1 style="font-weight: 900; color: #202124; margin-bottom: 8px;"><b>물품 등록하기</b></h1>
        <p style="margin: 0 0 24px; font-size: 14px; letter-spacing: -0.02em;">상태를 잘 알 수 있도록 꼼꼼하게 정보를 기록해 주세요.</p>
        
        <form action="productWriteProcess.jsp" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
            <input type="hidden" id="sellerId" name="sellerId" value="<%= loginId %>">

            <div class="form-grid">
                
                <!-- 카테고리 -->
                <div class="field">
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

                <!-- 상품명 -->
                <div class="field">
                    <label for="title">상품명</label>
                    <input type="text" id="title" name="title" maxlength="150" placeholder="글 제목을 입력해 주세요." required>
                </div>
                
                <!-- 이미지 업로드 -->
                <div class="field">
                    <label>상품 이미지 등록 <small style="font-weight: normal; margin-left: 4px;">(최대 5장)</small></label>
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

                <!-- 거래 지역 -->
                <div class="field">
                    <label for="region">거래 지역</label>
                    <input type="text" id="region" name="region" placeholder="예: 서울 강남구, 경기 수원시 인계동" required>
                </div>

                <!-- 판매 가격 -->
                <div class="field">
                    <label for="price">판매 가격</label>
                    <div class="price-field-group">
                        <input type="number" id="price" name="price" placeholder="가격을 입력해 주세요." required>
                        <span class="price-unit-tag">원</span>
                    </div>
                </div>

                <!-- 상품 설명 -->
                <div class="field">
                    <label for="content">상품 설명</label>
                    <textarea id="content" name="content" placeholder="구매 시기, 브랜드, 사용감, 하자 유무 등 설명이 구체적일수록 빠르게 판매될 확률이 높아져요!" required></textarea>
                </div>

                <!-- 하단 액션 버튼 그룹 -->
                <div class="form-actions" style="grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 16px;">
                    <button type="submit" class="primary" style="min-height: 48px; font-size: 15px;">등록 완료</button>
                    <a href="productList.jsp" class="button" style="min-height: 48px; font-size: 15px; border-color: #ded6ca;">취소</a>
                </div>
                
            </div>
        </form>
    </div>
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