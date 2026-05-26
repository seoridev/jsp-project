<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ include file="../../common/adminSessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String statusText(String status) {
        if ("HIDDEN".equalsIgnoreCase(status)) return "숨김";
        if ("DELETED".equalsIgnoreCase(status)) return "삭제";
        return "활성";
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    CafeDAO cafeDao = new CafeDAO();
    String action = request.getParameter("action") == null ? "" : request.getParameter("action").trim();
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    if ("hide".equals(action) && cafeId > 0) {
        boolean success = cafeDao.updateCafeStatus(cafeId, "HIDDEN");
        response.sendRedirect(request.getContextPath() + "/admin/communityCafeManage.jsp?result=" + (success ? "success" : "fail"));
        return;
    }

    List<CafeDTO> cafes = cafeDao.selectAllCafesForAdmin();
    String result = request.getParameter("result");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 카페 관리 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=admin-community-1">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">관리자</p>
            <h1>커뮤니티 카페 관리</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/admin/adminMain.jsp">대시보드</a>
            <a class="button" href="<%= contextPath %>/admin/communityPostManage.jsp">게시글 관리</a>
            <a class="button" href="<%= contextPath %>/admin/communityReportManage.jsp">신고 관리</a>
        </div>
    </div>
    <% if ("success".equals(result)) { %>
        <p class="field-message is-success">카페를 숨김 처리했습니다.</p>
    <% } else if ("fail".equals(result)) { %>
        <p class="field-message is-error">카페 처리에 실패했습니다.</p>
    <% } %>
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
                    <tr><td class="empty-cell" colspan="8">카페가 없습니다.</td></tr>
                <% } %>
                <% for (CafeDTO cafe : cafes) { %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>"><%= escapeHtml(cafe.getCafeName()) %></a></td>
                        <td><%= escapeHtml(cafe.getOwnerId()) %></td>
                        <td><%= escapeHtml(cafe.getRegion()) %></td>
                        <td><%= escapeHtml(cafe.getCategory()) %></td>
                        <td><%= cafe.getMemberCount() %></td>
                        <td><%= cafe.getPostCount() %></td>
                        <td><%= statusText(cafe.getStatus()) %></td>
                        <td>
                            <% if ("ACTIVE".equals(cafe.getStatus())) { %>
                                <form class="inline-form" action="<%= contextPath %>/admin/communityCafeManage.jsp" method="post">
                                    <input type="hidden" name="cafeId" value="<%= cafe.getCafeId() %>">
                                    <button type="submit" name="action" value="hide">숨김</button>
                                </form>
                            <% } else { %>
                                처리됨
                            <% } %>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
