<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="DAO.ProductDAO" %>
<%@ page import="DTO.ProductDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>

<%
	String type = request.getParameter("type");
	String keyword = request.getParameter("keyword");

    ProductDAO dao = new ProductDAO();
    List<ProductDTO> list = dao.selectProductList(type, keyword);
    
    DecimalFormat df = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>중고거래 마켓 - 물품 목록</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
<style>
    body { font-family: sans-serif; background: #f4f4f4; padding: 20px; }
    .container { max-width: 900px; margin: auto; background: white; padding: 20px; border-radius: 8px; }
    
    .search-bar {
        margin-bottom: 20px;
        display: flex;
        justify-content: flex-start;
        gap: 10px;
        background: #f8f9fa;
        padding: 15px;
        border-radius: 5px;
    }
    .search-bar select, .search-bar input {
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
    }
    .search-bar input[type="text"] { width: 250px; }
    .btn-search {
        background: #666;
        color: white;
        border: none;
        padding: 8px 15px;
        border-radius: 4px;
        cursor: pointer;
    }
    .btn-search:hover { background: #444; }
    
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 12px; border-bottom: 1px solid #ddd; text-align: left; }
    th { background: #f8f9fa; }
    .price { font-weight: bold; color: #ff5a5f; }
    .region { color: #666; font-size: 0.9em; }
    .button-container {
    margin-top: 30px;
    display: flex;
    justify-content: flex-end; /* 오른쪽 정렬 */
	}
	
	.btn-write {
	    display: inline-block;
	    background-color: #ff5a5f; /* 강조 포인트 색상 */
	    color: white;
	    padding: 12px 24px;
	    border-radius: 30px; /* 둥근 버튼 */
	    text-decoration: none;
	    font-weight: bold;
	    font-size: 16px;
	    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
	    transition: background-color 0.3s, transform 0.2s;
	}
	
	.btn-write:hover {
	    background-color: #e0484d;
	    transform: translateY(-2px); /* 살짝 떠오르는 효과 */
	    color: white;
	}
	
	.btn-write .icon {
	    margin-right: 5px;
	    font-size: 18px;
	    vertical-align: middle;
	}
</style>
</head>
<body>
<%@ include file="../common/header.jsp" %>
	<div class="container">
		<h2>🥕 중고거래 물품 목록</h2>

		<div class="search-bar">
			<form action="productList.jsp" method="get"
				style="display: flex; gap: 10px; width: 100%;">
				<select name="type">
					<option value="title" <%= "title".equals(type) ? "selected" : "" %>>제목</option>
					<option value="content"
						<%= "content".equals(type) ? "selected" : "" %>>내용</option>
					<option value="all" <%= "all".equals(type) ? "selected" : "" %>>제목+내용</option>
				</select> <input type="text" name="keyword"
					value="<%= (keyword != null) ? keyword : "" %>">
				<button type="submit" class="btn-search">검색</button>

				<% if(keyword != null && !keyword.isEmpty()) { %>
				<a href="productList.jsp"
					style="text-decoration: none; font-size: 12px; color: #999; align-self: center;">초기화</a>
				<% } %>
			</form>
		</div>

		<table>
			<thead>
				<tr>
					<th>제목</th>
					<th>가격</th>
					<th>지역</th>
					<th>조회수</th>
				</tr>
			</thead>
			<tbody>
				<%
	                if (list == null || list.isEmpty()) {
	            %>
				<tr>
					<td colspan="5" style="text-align: center;">등록된 물품이 없습니다.</td>
				</tr>
				<%
	                } else {
	                    for (ProductDTO p : list) {
	            %>
				<tr>
					<td><a href="productDetail.jsp?id=<%= p.getProductId() %>"><%= p.getTitle() %></a>
					</td>
					<td class="price"><%= df.format(p.getPrice()) %>원</td>
					<td class="region"><%= p.getRegion() %></td>
					<td><%= p.getViewCount() %></td>
				</tr>
				<%
	                    }
	                } 
	            %>
			</tbody>
		</table>
		<div class="button-container">
			<a href="productWrite.jsp" class="btn-write"> <span class="icon">+</span>
				물품 등록하기
			</a>
		</div>
	</div>
	<%@ include file="../common/footer.jsp" %>
</body>
</html>