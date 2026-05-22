<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
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
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    if (!new CafeMemberDAO().isCafeManagerOrOwner(cafeId, currentLoginId)) {
        response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + cafeId + "&error=manageDenied");
        return;
    }

    List<CafeBoardDTO> boards = new CafeBoardDAO().selectBoardsByCafeId(cafeId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시판 관리 | <%= escapeHtml(cafe.getCafeName()) %></title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <p><a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(cafe.getCafeName()) %></a></p>
                <h1>게시판 관리</h1>
            </div>
        </div>
        <% if ("success".equals(request.getParameter("create"))) { %>
            <p class="field-message is-success">게시판이 생성되었습니다.</p>
        <% } else if ("success".equals(request.getParameter("update"))) { %>
            <p class="field-message is-success">게시판이 수정되었습니다.</p>
        <% } else if ("success".equals(request.getParameter("hide"))) { %>
            <p class="field-message is-success">게시판이 숨김 처리되었습니다.</p>
        <% } else if ("hasPosts".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">글이 있는 게시판은 숨길 수 없습니다.</p>
        <% } else if (request.getParameter("error") != null) { %>
            <p class="field-message is-error">게시판 처리에 실패했습니다.</p>
        <% } %>
    </section>

    <section class="detail-panel">
        <h2>게시판 생성</h2>
        <form class="form-grid" action="<%= contextPath %>/community/boardCreateProcess.jsp" method="post">
            <input type="hidden" name="cafeId" value="<%= cafeId %>">
            <div class="field">
                <label for="boardName">게시판 이름</label>
                <input id="boardName" name="boardName" maxlength="100" required>
            </div>
            <div class="field">
                <label for="description">설명</label>
                <input id="description" name="description" maxlength="500">
            </div>
            <div class="field">
                <label for="readPermission">읽기 권한</label>
                <select id="readPermission" name="readPermission">
                    <option value="ALL">전체</option>
                    <option value="MEMBER">회원</option>
                </select>
            </div>
            <div class="field">
                <label for="writePermission">쓰기 권한</label>
                <select id="writePermission" name="writePermission">
                    <option value="MEMBER">회원</option>
                    <option value="MANAGER">매니저</option>
                    <option value="OWNER">운영자</option>
                </select>
            </div>
            <label><input type="checkbox" name="isNotice" value="Y"> 공지 게시판</label>
            <div class="field">
                <label for="displayOrder">표시 순서</label>
                <input id="displayOrder" name="displayOrder" type="number" min="1" value="<%= boards.size() + 1 %>">
            </div>
            <div class="form-actions">
                <button class="primary" type="submit">생성</button>
            </div>
        </form>
    </section>

    <section class="detail-panel">
        <h2>게시판 목록</h2>
        <div class="community-list">
            <% if (boards.isEmpty()) { %>
                <p class="empty-cell">활성 게시판이 없습니다.</p>
            <% } %>
            <% for (CafeBoardDTO board : boards) { %>
                <div class="community-card">
                    <form class="form-grid" action="<%= contextPath %>/community/boardUpdateProcess.jsp" method="post">
                        <input type="hidden" name="cafeId" value="<%= cafeId %>">
                        <input type="hidden" name="boardId" value="<%= board.getBoardId() %>">
                        <div class="field">
                            <label for="boardName<%= board.getBoardId() %>">게시판 이름</label>
                            <input id="boardName<%= board.getBoardId() %>" name="boardName" maxlength="100" value="<%= escapeHtml(board.getBoardName()) %>" required>
                        </div>
                        <div class="field">
                            <label for="description<%= board.getBoardId() %>">설명</label>
                            <input id="description<%= board.getBoardId() %>" name="description" maxlength="500" value="<%= escapeHtml(board.getDescription()) %>">
                        </div>
                        <div class="field">
                            <label for="readPermission<%= board.getBoardId() %>">읽기 권한</label>
                            <select id="readPermission<%= board.getBoardId() %>" name="readPermission">
                                <option value="ALL" <%= "ALL".equals(board.getReadPermission()) ? "selected" : "" %>>전체</option>
                                <option value="MEMBER" <%= "MEMBER".equals(board.getReadPermission()) ? "selected" : "" %>>회원</option>
                            </select>
                        </div>
                        <div class="field">
                            <label for="writePermission<%= board.getBoardId() %>">쓰기 권한</label>
                            <select id="writePermission<%= board.getBoardId() %>" name="writePermission">
                                <option value="MEMBER" <%= "MEMBER".equals(board.getWritePermission()) ? "selected" : "" %>>회원</option>
                                <option value="MANAGER" <%= "MANAGER".equals(board.getWritePermission()) ? "selected" : "" %>>매니저</option>
                                <option value="OWNER" <%= "OWNER".equals(board.getWritePermission()) ? "selected" : "" %>>운영자</option>
                            </select>
                        </div>
                        <label><input type="checkbox" name="isNotice" value="Y" <%= "Y".equals(board.getIsNotice()) ? "checked" : "" %>> 공지 게시판</label>
                        <div class="field">
                            <label for="displayOrder<%= board.getBoardId() %>">표시 순서</label>
                            <input id="displayOrder<%= board.getBoardId() %>" name="displayOrder" type="number" min="1" value="<%= board.getDisplayOrder() %>">
                        </div>
                        <p class="community-meta">글 <%= board.getPostCount() %></p>
                        <div class="form-actions">
                            <button class="primary" type="submit">수정</button>
                            <button type="button" onclick="hideBoard(<%= board.getBoardId() %>, <%= cafeId %>)" style="border-color:#d93025;color:#d93025;">숨김</button>
                        </div>
                    </form>
                </div>
            <% } %>
        </div>
    </section>
</main>
<script>
    function hideBoard(boardId, cafeId) {
        if (confirm("게시판을 숨김 처리하시겠습니까?")) {
            location.href = "<%= request.getContextPath() %>/community/boardHideProcess.jsp?boardId=" + boardId + "&cafeId=" + cafeId;
        }
    }
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
