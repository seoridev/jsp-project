<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeCommentDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private boolean isValidTargetType(String targetType) {
        return "CAFE".equals(targetType) || "CAFE_POST".equals(targetType) || "CAFE_COMMENT".equals(targetType);
    }
%>
<%
    String targetType = request.getParameter("targetType");
    int targetId = parseIntParam(request.getParameter("targetId"));
    String targetTitle = "";
    String backUrl = request.getContextPath() + "/community/communityHome.jsp";

    if (!isValidTargetType(targetType) || targetId <= 0) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=reportTarget");
        return;
    }

    if ("CAFE".equals(targetType)) {
        CafeDTO cafe = new CafeDAO().selectCafeById(targetId);
        if (cafe == null) {
            response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=reportTarget");
            return;
        }
        targetTitle = cafe.getCafeName();
        backUrl = request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + cafe.getCafeId();
    } else if ("CAFE_POST".equals(targetType)) {
        CafePostDTO post = new CafePostDAO().selectPostById(targetId);
        if (post == null) {
            response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=reportTarget");
            return;
        }
        targetTitle = post.getTitle();
        backUrl = request.getContextPath() + "/community/postDetail.jsp?postId=" + post.getPostId();
    } else {
        CafeCommentDTO comment = new CafeCommentDAO().selectCommentById(targetId);
        if (comment == null || "Y".equals(comment.getIsDeleted())) {
            response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=reportTarget");
            return;
        }
        targetTitle = comment.getContent();
        backUrl = request.getContextPath() + "/community/postDetail.jsp?postId=" + comment.getPostId();
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 신고 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=community-report-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <p class="eyebrow">커뮤니티 신고</p>
                <h1><%= escapeHtml(targetTitle) %></h1>
                <p class="community-meta"><%= escapeHtml(targetType) %> #<%= targetId %></p>
            </div>
            <a class="button" href="<%= backUrl %>">돌아가기</a>
        </div>
        <% if ("reportFail".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">신고 접수에 실패했습니다.</p>
        <% } %>
        <form class="form-grid" action="<%= contextPath %>/community/communityReportProcess.jsp" method="post">
            <input type="hidden" name="targetType" value="<%= escapeHtml(targetType) %>">
            <input type="hidden" name="targetId" value="<%= targetId %>">
            <div class="field">
                <label for="reason">신고 사유</label>
                <select id="reason" name="reason" required>
                    <option value="SPAM">스팸/홍보</option>
                    <option value="ABUSE">욕설/비방</option>
                    <option value="FRAUD">사기/허위 정보</option>
                    <option value="ETC">기타</option>
                </select>
            </div>
            <div class="field">
                <label for="detail">상세 내용</label>
                <textarea id="detail" name="detail" rows="6" maxlength="1000" required></textarea>
            </div>
            <div class="form-actions">
                <button class="primary" type="submit">신고 접수</button>
                <a class="button" href="<%= backUrl %>">취소</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
