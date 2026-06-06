<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
    private String selected(String current, String expected) {
        return expected.equalsIgnoreCase(current) ? "selected" : "";
    }

    private boolean isAllowedSearchType(String searchType) {
        return "title".equals(searchType) || "seller".equals(searchType);
    }

    private boolean isAllowedStatus(String status) {
        return "ALL".equals(status) || "SALE".equals(status) || "RESERVED".equals(status)
            || "SOLD".equals(status) || "HIDDEN".equals(status);
    }

    private String encodeParam(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    private String buildListQuery(String searchType, String keyword, String status) {
        return "searchType=" + encodeParam(searchType)
            + "&keyword=" + encodeParam(keyword)
            + "&status=" + encodeParam(status);
    }

    private String statusText(String status) {
        if ("ALL".equalsIgnoreCase(status)) return "전체";
        if ("RESERVED".equalsIgnoreCase(status)) return "예약중";
        if ("SOLD".equalsIgnoreCase(status)) return "판매완료";
        if ("HIDDEN".equalsIgnoreCase(status)) return "숨김";
        return "판매중";
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String searchType = request.getParameter("searchType") == null ? "title" : request.getParameter("searchType").trim();
    if (!isAllowedSearchType(searchType)) {
        searchType = "title";
    }
    String keyword = request.getParameter("keyword") == null ? "" : request.getParameter("keyword").trim();
    String statusFilter = request.getParameter("status") == null ? "ALL" : request.getParameter("status").trim().toUpperCase();
    if (!isAllowedStatus(statusFilter)) {
        statusFilter = "ALL";
    }

    ProductDAO.AdminProductFilter filter = new ProductDAO.AdminProductFilter();
    filter.setSearchType(searchType);
    filter.setKeyword(keyword);
    filter.setStatus(statusFilter);

    ProductDAO productDao = new ProductDAO();
    List<ProductDTO> products = productDao.selectProductsForAdmin(filter);
    int totalCount = productDao.countProductsForAdmin(filter);
    DecimalFormat priceFormat = new DecimalFormat("#,###");
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-product-2">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>상품 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/adminLogout.jsp">로그아웃</a>
        </div>
    </div>
    <% if ("success".equals(result)) { %>
        <p class="notice-toast">상품 상태를 변경했습니다.</p>
        <script>
            (() => {
                const url = new URL(window.location.href);
                url.searchParams.delete("result");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } else if ("fail".equals(result)) { %>
        <p class="notice-toast is-error">상품 상태 변경에 실패했습니다.</p>
        <script>
            (() => {
                const url = new URL(window.location.href);
                url.searchParams.delete("result");
                window.history.replaceState({}, "", url);
            })();
        </script>
    <% } %>
    <form class="admin-filter" action="<%= contextPath %>/admin/adminProductList.jsp" method="get">
        <div class="field">
            <label for="searchType">검색 기준</label>
            <select id="searchType" name="searchType">
                <option value="title" <%= selected(searchType, "title") %>>상품명</option>
                <option value="seller" <%= selected(searchType, "seller") %>>판매자</option>
            </select>
        </div>
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" type="search" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="검색어를 입력하세요">
        </div>
        <div class="field">
            <label for="status">상태</label>
            <select id="status" name="status">
                <option value="ALL" <%= selected(statusFilter, "ALL") %>>전체</option>
                <option value="SALE" <%= selected(statusFilter, "SALE") %>>판매중</option>
                <option value="RESERVED" <%= selected(statusFilter, "RESERVED") %>>예약중</option>
                <option value="SOLD" <%= selected(statusFilter, "SOLD") %>>판매완료</option>
                <option value="HIDDEN" <%= selected(statusFilter, "HIDDEN") %>>숨김</option>
            </select>
        </div>
        <button class="primary" type="submit">검색</button>
        <a class="button" href="<%= contextPath %>/admin/adminProductList.jsp">초기화</a>
    </form>
    <div class="admin-list-meta">
        <span>총 <strong><%= totalCount %></strong>개</span>
        <span><%= statusText(statusFilter) %></span>
    </div>
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>상품명</th>
                    <th>판매자</th>
                    <th>가격</th>
                    <th>동네</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (products == null || products.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="6">조건에 맞는 상품이 없습니다.</td></tr>
                <% } else {
                    for (ProductDTO product : products) {
                %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>"><%= escapeHtml(product.getTitle()) %></a></td>
                        <td><%= escapeHtml(product.getSellerId()) %></td>
                        <td><%= priceFormat.format(product.getPrice()) %>원</td>
                        <td><%= escapeHtml(product.getRegion()) %></td>
                        <td><%= statusText(product.getStatus()) %></td>
                        <td>
                            <form class="inline-form" action="<%= contextPath %>/admin/adminProductStatusProcess.jsp" method="post">
                                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                <input type="hidden" name="searchType" value="<%= escapeHtml(searchType) %>">
                                <input type="hidden" name="keyword" value="<%= escapeHtml(keyword) %>">
                                <input type="hidden" name="statusFilter" value="<%= escapeHtml(statusFilter) %>">
                                <select name="status" aria-label="상품 상태">
                                    <option value="SALE" <%= selected(product.getStatus(), "SALE") %>>판매중</option>
                                    <option value="RESERVED" <%= selected(product.getStatus(), "RESERVED") %>>예약중</option>
                                    <option value="SOLD" <%= selected(product.getStatus(), "SOLD") %>>거래완료</option>
                                    <option value="HIDDEN" <%= selected(product.getStatus(), "HIDDEN") %>>숨김</option>
                                </select>
                                <button type="submit">변경</button>
                            </form>
                        </td>
                    </tr>
                <%  }
                } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
