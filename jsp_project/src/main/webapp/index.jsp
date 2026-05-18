<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=home-category-1">
</head>
<body>
<%@ include file="common/header.jsp" %>
<main class="home-search-page">
    <section class="home-search-shell" aria-labelledby="home-title">
        <h1 id="home-title">우리 동네 중고거래를 더 편하게 만나보세요</h1>

        <form class="home-main-search" action="<%= contextPath %>/product/productList.jsp" method="get">
            <label class="visually-hidden" for="home-search-type">검색 종류</label>
            <select id="home-search-type" name="type" aria-label="검색 종류">
                <option value="all">중고거래</option>
                <option value="title">제목</option>
                <option value="content">내용</option>
            </select>

            <span class="home-search-divider" aria-hidden="true"></span>

            <label class="visually-hidden" for="home-keyword">검색어</label>
            <input id="home-keyword" type="text" name="keyword" placeholder="검색어를 입력해주세요">

            <button type="submit" aria-label="검색">→</button>
        </form>

        <div class="home-keyword-row" aria-label="인기 검색어">
            <strong>인기 검색어</strong>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=에어컨">에어컨</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=노트북">노트북</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=원룸">원룸</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=자전거">자전거</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=책상">책상</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=의자">의자</a>
        </div>

        <nav class="home-category-select" aria-label="카테고리 선택">
            <a href="<%= contextPath %>/product/productList.jsp">
                <span class="category-mark mark-orange">중</span>
                <strong>중고거래</strong>
            </a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=디지털">
                <span class="category-mark mark-red">디</span>
                <strong>디지털기기</strong>
            </a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=가전">
                <span class="category-mark mark-yellow">가</span>
                <strong>생활가전</strong>
            </a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=가구">
                <span class="category-mark mark-brown">가</span>
                <strong>가구/인테리어</strong>
            </a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=의류">
                <span class="category-mark mark-blue">의</span>
                <strong>의류/잡화</strong>
            </a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=도서">
                <span class="category-mark mark-green">도</span>
                <strong>도서/음반</strong>
            </a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=스포츠">
                <span class="category-mark mark-orange">스</span>
                <strong>스포츠/레저</strong>
            </a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=생활">
                <span class="category-mark mark-yellow">생</span>
                <strong>생활/주방</strong>
            </a>
        </nav>
    </section>
</main>
<%@ include file="common/footer.jsp" %>
</body>
</html>
