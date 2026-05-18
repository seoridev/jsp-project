<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="DAO.ProductDAO" %>
<%@ page import="DTO.ProductDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
%>
<%
    String targetType = request.getParameter("targetType") == null ? "PRODUCT" : request.getParameter("targetType").trim().toUpperCase();
    int targetId = parseIntParam(request.getParameter("targetId"));
    ProductDTO product = null;
    if ("PRODUCT".equals(targetType) && targetId > 0) {
        product = new ProductDAO().selectProductById(targetId);
    }
    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/product/productList.jsp?error=noProduct");
        return;
    }
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>신고하기 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=report-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="auth-wrap">
    <section class="auth-panel">
        <h1>신고하기</h1>
        <p><strong><%= escapeHtml(product.getTitle()) %></strong> 상품을 신고합니다.</p>
        <% if ("empty".equals(error)) { %>
            <script>
                (() => {
                    alert("신고 사유를 선택해 주세요.");
                    const url = new URL(window.location.href);
                    url.searchParams.delete("error");
                    window.history.replaceState({}, "", url);
                })();
            </script>
        <% } else if ("fail".equals(error)) { %>
            <script>
                (() => {
                    alert("신고 등록에 실패했습니다.");
                    const url = new URL(window.location.href);
                    url.searchParams.delete("error");
                    window.history.replaceState({}, "", url);
                })();
            </script>
        <% } %>
        <form class="form-grid" action="<%= contextPath %>/report/reportProcess.jsp" method="post">
            <input type="hidden" name="targetType" value="PRODUCT">
            <input type="hidden" name="targetId" value="<%= product.getProductId() %>">
            <div class="field">
                <label for="reason">신고 사유</label>
                <select id="reason" name="reason" required>
                    <option value="">선택</option>
                    <option value="부적절한 상품">부적절한 상품</option>
                    <option value="허위 매물">허위 매물</option>
                    <option value="거래 비매너">거래 비매너</option>
                    <option value="기타">기타</option>
                </select>
            </div>
            <div class="field">
                <label for="detail">상세 내용</label>
                <input id="detail" name="detail" placeholder="관리자가 확인할 수 있게 내용을 적어주세요.">
            </div>
            <div class="form-actions">
                <button class="primary" type="submit">신고 등록</button>
                <a class="button" href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>">취소</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
