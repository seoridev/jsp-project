<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeCategoryDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dto.CafeCategoryDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private int parsePage(String value) {
        return Math.max(parseIntParam(value), 1);
    }

    private String requestValue(String value) {
        return value == null ? "" : value.trim();
    }

    private String selectedAttr(String current, String expected) {
        return expected.equalsIgnoreCase(current) ? "selected" : "";
    }

    private String statusText(String status) {
        if ("HIDDEN".equalsIgnoreCase(status)) return "숨김";
        if ("DELETED".equalsIgnoreCase(status)) return "삭제";
        return "활성";
    }

    private String statusClass(String status) {
        if ("HIDDEN".equalsIgnoreCase(status)) return " is-stopped";
        if ("DELETED".equalsIgnoreCase(status)) return " is-withdrawn";
        return " is-active";
    }

    private String encodeParam(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    private String buildListQuery(String searchType, String keyword, String status, int categoryId, int page) {
        return "searchType=" + encodeParam(searchType)
            + "&keyword=" + encodeParam(keyword)
            + "&status=" + encodeParam(status)
            + "&categoryId=" + categoryId
            + "&page=" + page;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String searchType = requestValue(request.getParameter("searchType")).toUpperCase();
    if (!"OWNER".equals(searchType)) {
        searchType = "CAFE_NAME";
    }
    String keyword = requestValue(request.getParameter("keyword"));
    String statusFilter = requestValue(request.getParameter("status")).toUpperCase();
    if (!"ACTIVE".equals(statusFilter) && !"HIDDEN".equals(statusFilter)) {
        statusFilter = "ALL";
    }
    int categoryIdFilter = parseIntParam(request.getParameter("categoryId"));
    int pageNumber = parsePage(request.getParameter("page"));
    int pageSize = 10;
    String listQuery = buildListQuery(searchType, keyword, statusFilter, categoryIdFilter, pageNumber);

    CafeDAO cafeDao = new CafeDAO();
    String action = requestValue(request.getParameter("action"));
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    if (cafeId > 0 && ("hide".equals(action) || "restore".equals(action))) {
        String nextStatus = "hide".equals(action) ? "HIDDEN" : "ACTIVE";
        boolean success = cafeDao.updateCafeStatus(cafeId, nextStatus);
        response.sendRedirect(request.getContextPath() + "/admin/communityCafeManage.jsp?"
                + listQuery + "&result=" + (success ? action : "fail"));
        return;
    }

    CafeDAO.AdminCafeFilter filter = new CafeDAO.AdminCafeFilter();
    filter.setSearchType(searchType);
    filter.setKeyword(keyword);
    filter.setStatus(statusFilter);
    filter.setCafeCategoryId(categoryIdFilter);

    int totalCount = cafeDao.countCafesForAdmin(filter);
    int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
    if (pageNumber > totalPages) {
        pageNumber = totalPages;
        listQuery = buildListQuery(searchType, keyword, statusFilter, categoryIdFilter, pageNumber);
    }
    int pageBlockSize = 10;
    int blockStartPage = ((pageNumber - 1) / pageBlockSize) * pageBlockSize + 1;
    int blockEndPage = Math.min(totalPages, blockStartPage + pageBlockSize - 1);
    List<CafeDTO> cafes = cafeDao.selectCafesForAdmin(filter, pageNumber, pageSize);
    List<CafeCategoryDTO> categories = new CafeCategoryDAO().selectActiveCategories();
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 카페 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-community-3">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>커뮤니티 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/communityReportManage.jsp">커뮤니티 신고 관리</a>
        </div>
    </div>
    <% request.setAttribute("adminCommunityTab", "cafe"); %>
    <%@ include file="communityManageTabs.jsp" %>

    <% if ("hide".equals(result)) { %>
        <p class="notice-toast">카페를 숨김 처리했습니다.</p>
    <% } else if ("restore".equals(result)) { %>
        <p class="notice-toast">카페를 복구했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="notice-toast is-error">카페 처리에 실패했습니다.</p>
    <% } %>

    <form class="admin-filter" action="<%= contextPath %>/admin/communityCafeManage.jsp" method="get">
        <input type="hidden" name="page" value="1">
        <div class="field">
            <label for="searchType">검색 기준</label>
            <select id="searchType" name="searchType">
                <option value="CAFE_NAME" <%= selectedAttr(searchType, "CAFE_NAME") %>>카페명</option>
                <option value="OWNER" <%= selectedAttr(searchType, "OWNER") %>>운영자</option>
            </select>
        </div>
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" type="search" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="검색어">
        </div>
        <div class="field">
            <label for="categoryId">카테고리</label>
            <select id="categoryId" name="categoryId">
                <option value="0">전체</option>
                <% for (CafeCategoryDTO category : categories) { %>
                    <option value="<%= category.getCafeCategoryId() %>" <%= category.getCafeCategoryId() == categoryIdFilter ? "selected" : "" %>><%= escapeHtml(category.getCategoryName()) %></option>
                <% } %>
            </select>
        </div>
        <div class="field">
            <label for="status">상태</label>
            <select id="status" name="status">
                <option value="ALL" <%= selectedAttr(statusFilter, "ALL") %>>전체</option>
                <option value="ACTIVE" <%= selectedAttr(statusFilter, "ACTIVE") %>>활성</option>
                <option value="HIDDEN" <%= selectedAttr(statusFilter, "HIDDEN") %>>숨김</option>
            </select>
        </div>
        <div class="form-actions">
            <button class="primary" type="submit">검색</button>
            <a class="button" href="<%= contextPath %>/admin/communityCafeManage.jsp">초기화</a>
        </div>
    </form>

    <div class="admin-list-meta">
        <span>총 <strong><%= totalCount %></strong>개</span>
        <span><%= pageNumber %> / <%= totalPages %> 페이지</span>
    </div>

    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>카페명</th>
                    <th>운영자</th>
                    <th>지역</th>
                    <th>카테고리</th>
                    <th>회원</th>
                    <th>글</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <% if (cafes.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="8">조건에 맞는 카페가 없습니다.</td></tr>
                <% } %>
                <% for (CafeDTO cafe : cafes) { %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>"><%= escapeHtml(cafe.getCafeName()) %></a></td>
                        <td><%= escapeHtml(cafe.getOwnerId()) %></td>
                        <td><%= escapeHtml(cafe.getRegion()) %></td>
                        <td><%= escapeHtml(cafe.getCategory()) %></td>
                        <td><%= cafe.getMemberCount() %></td>
                        <td><%= cafe.getPostCount() %></td>
                        <td><span class="status-badge<%= statusClass(cafe.getStatus()) %>"><%= statusText(cafe.getStatus()) %></span></td>
                        <td>
                            <form class="inline-form admin-status-form" action="<%= contextPath %>/admin/communityCafeManage.jsp" method="post">
                                <input type="hidden" name="cafeId" value="<%= cafe.getCafeId() %>">
                                <input type="hidden" name="searchType" value="<%= escapeHtml(searchType) %>">
                                <input type="hidden" name="keyword" value="<%= escapeHtml(keyword) %>">
                                <input type="hidden" name="status" value="<%= escapeHtml(statusFilter) %>">
                                <input type="hidden" name="categoryId" value="<%= categoryIdFilter %>">
                                <input type="hidden" name="page" value="<%= pageNumber %>">
                                <select name="action" aria-label="카페 상태">
                                    <option value="restore" <%= "ACTIVE".equals(cafe.getStatus()) ? "selected" : "" %>>활성</option>
                                    <option value="hide" <%= "HIDDEN".equals(cafe.getStatus()) ? "selected" : "" %>>숨김</option>
                                </select>
                                <button type="submit">변경</button>
                            </form>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <% if (totalPages > 1) { %>
        <nav class="pagination" aria-label="카페 목록 페이지">
            <% if (blockStartPage > 1) { %>
                <a href="<%= contextPath %>/admin/communityCafeManage.jsp?<%= buildListQuery(searchType, keyword, statusFilter, categoryIdFilter, blockStartPage - pageBlockSize) %>">이전</a>
            <% } %>
            <% for (int i = blockStartPage; i <= blockEndPage; i++) { %>
                <a class="<%= i == pageNumber ? "is-current" : "" %>" href="<%= contextPath %>/admin/communityCafeManage.jsp?<%= buildListQuery(searchType, keyword, statusFilter, categoryIdFilter, i) %>"><%= i %></a>
            <% } %>
            <% if (blockEndPage < totalPages) { %>
                <a href="<%= contextPath %>/admin/communityCafeManage.jsp?<%= buildListQuery(searchType, keyword, statusFilter, categoryIdFilter, blockEndPage + 1) %>">다음</a>
            <% } %>
        </nav>
    <% } %>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
