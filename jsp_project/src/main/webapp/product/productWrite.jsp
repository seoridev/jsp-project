<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CategoryDAO" %>
<%@ page import="com.carrot.dto.CategoryDTO" %>
<%@ page import="java.util.List" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
    CategoryDAO categoryDAO = new CategoryDAO();
    List<CategoryDTO> categories = categoryDAO.selectAllCategories();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 등록 - 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/product.css?v=external-ui-1">
</head>
<body class="product-page">
<%@ include file="../common/header.jsp" %>
<main class="product-form-container">
    <h2>물품 등록하기</h2>
    <form class="product-form" action="<%= contextPath %>/product/productWriteProcess.jsp" method="post" enctype="multipart/form-data" onsubmit="return validateProductForm()">
        <div class="product-form-group">
            <label for="sellerId">판매자 ID</label>
            <input type="text" id="sellerId" value="<%= escapeHtml(loginId) %>" readonly>
        </div>

        <div class="product-form-group">
            <label for="categoryId">카테고리</label>
            <select id="categoryId" name="categoryId" required>
                <option value="">카테고리 선택</option>
                <% for (CategoryDTO category : categories) { %>
                    <option value="<%= category.getCategoryId() %>"><%= escapeHtml(category.getCategoryName()) %></option>
                <% } %>
            </select>
        </div>

        <div class="product-form-group">
            <label for="title">상품명</label>
            <input type="text" id="title" name="title" maxlength="150" placeholder="상품 제목을 입력하세요" required>
        </div>

        <div class="product-form-group">
            <label>상품 이미지 등록 (최대 5장)</label>
            <input type="file" id="imageInput" accept="image/*" multiple hidden onchange="addFiles(this)">
            <div class="product-upload-row">
                <div class="product-upload-box" onclick="document.getElementById('imageInput').click()">
                    <span class="product-camera-icon">사진</span>
                    <span id="imageCount">0 / 5</span>
                </div>
                <div id="thumbnailContainer" class="product-thumbnail-container"></div>
            </div>
            <input type="hidden" id="mainImageIndex" name="mainImageIndex" value="0">
            <div id="hiddenInputContainer" hidden></div>
        </div>

        <div class="product-form-group">
            <label for="region">거래 지역</label>
            <input type="text" id="region" name="region" value="<%= escapeHtml(loginRegion) %>" placeholder="예: 서울 강남구, 경기 수원시" required>
        </div>

        <div class="product-form-group product-price-input">
            <label for="price">판매 가격</label>
            <input type="number" id="price" name="price" min="0" placeholder="가격을 입력하세요" required>
        </div>

        <div class="product-form-group">
            <label for="content">상품 설명</label>
            <textarea id="content" name="content" placeholder="상품의 상태, 구매 시기 등 상세한 정보를 적어주세요" required></textarea>
        </div>

        <div class="product-button-group">
            <button type="submit" class="product-btn product-btn-submit">등록 완료</button>
            <a href="<%= contextPath %>/product/productList.jsp" class="product-btn product-btn-cancel">취소</a>
        </div>
    </form>
</main>
<%@ include file="../common/footer.jsp" %>
<script>
let uploadedFiles = [];
let selectedMainIndex = 0;

function addFiles(input) {
    const files = Array.from(input.files);

    if (uploadedFiles.length + files.length > 5) {
        alert("이미지는 최대 5장까지 업로드 가능합니다.");
        input.value = "";
        return;
    }

    files.forEach((file) => uploadedFiles.push(file));
    input.value = "";
    renderThumbnails();
}

function renderThumbnails() {
    const container = document.getElementById("thumbnailContainer");
    const countSpan = document.getElementById("imageCount");
    container.innerHTML = "";

    uploadedFiles.forEach((file, index) => {
        const reader = new FileReader();
        reader.onload = function(event) {
            const wrapper = document.createElement("div");
            wrapper.className = "product-thumb-wrapper" + (index === selectedMainIndex ? " main-selected" : "");
            wrapper.setAttribute("data-index", index);
            wrapper.innerHTML =
                "<div class=\"product-remove-btn\" onclick=\"removeFile(" + index + ", event)\">x</div>"
                + "<div class=\"product-main-badge\">대표</div>"
                + "<img src=\"" + event.target.result + "\" alt=\"상품 이미지\" onclick=\"changeMainImage(" + index + ")\">";
            container.appendChild(wrapper);
        };
        reader.readAsDataURL(file);
    });

    countSpan.innerText = uploadedFiles.length + " / 5";
    updateMainIndex();
}

function removeFile(index, event) {
    event.stopPropagation();
    uploadedFiles.splice(index, 1);

    if (selectedMainIndex === index) {
        selectedMainIndex = 0;
    } else if (selectedMainIndex > index) {
        selectedMainIndex--;
    }

    renderThumbnails();
}

function changeMainImage(index) {
    selectedMainIndex = index;
    updateMainIndex();
    document.querySelectorAll(".product-thumb-wrapper").forEach((wrapper) => {
        wrapper.classList.toggle("main-selected", Number(wrapper.getAttribute("data-index")) === index);
    });
}

function updateMainIndex() {
    document.getElementById("mainImageIndex").value = selectedMainIndex;
}

function validateProductForm() {
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

        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        input.files = dataTransfer.files;
        hiddenContainer.appendChild(input);
    });

    updateMainIndex();
    return true;
}
</script>
</body>
</html>
