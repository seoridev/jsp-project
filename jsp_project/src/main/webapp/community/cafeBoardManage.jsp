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

    CafeBoardDAO boardDao = new CafeBoardDAO();
    List<CafeBoardDTO> boards = boardDao.selectBoardsByCafeId(cafeId);
    int selectedBoardId = parseIntParam(request.getParameter("boardId"));
    CafeBoardDTO selectedBoard = null;
    int selectedIndex = -1;

    for (int i = 0; i < boards.size(); i++) {
        CafeBoardDTO board = boards.get(i);
        if (board.getBoardId() == selectedBoardId) {
            selectedBoard = board;
            selectedIndex = i;
            break;
        }
    }

    if (selectedBoard == null && !boards.isEmpty()) {
        selectedBoard = boards.get(0);
        selectedBoardId = selectedBoard.getBoardId();
        selectedIndex = 0;
    }

    boolean canMoveUp = selectedIndex > 0;
    boolean canMoveDown = selectedIndex >= 0 && selectedIndex < boards.size() - 1;
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
<main class="page-shell manage-shell">
    <section class="manage-header">
        <div>
            <p class="breadcrumb"><a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(cafe.getCafeName()) %></a></p>
            <h1>게시판 관리</h1>
        </div>
        <a class="button btn-sub" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>">카페로 돌아가기</a>
    </section>

    <% if ("success".equals(request.getParameter("update"))) { %>
        <p class="notice-toast">게시판이 수정되었습니다.</p>
    <% } else if ("success".equals(request.getParameter("hide"))) { %>
        <p class="notice-toast">게시판이 숨김 처리되었습니다.</p>
    <% } else if ("hasPosts".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">글이 있는 게시판은 숨길 수 없습니다.</p>
    <% } else if (request.getParameter("error") != null) { %>
        <p class="field-message is-error">게시판 처리에 실패했습니다.</p>
    <% } %>

    <section class="manage-layout">
        <aside class="manage-sidebar">
            <div class="manage-sidebar-title">카페 관리</div>
            <nav class="manage-menu" aria-label="카페 관리 메뉴">
                <a class="active" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                <a href="<%= contextPath %>/community/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                <a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>">카페로 돌아가기</a>
            </nav>
        </aside>

        <section class="manage-content">
            <section class="manage-summary-grid">
                <div class="manage-summary-card">
                    <span>전체 게시판</span>
                    <strong><%= boards.size() %></strong>
                </div>
                <div class="manage-summary-card">
                    <span>선택 게시판 글 수</span>
                    <strong><%= selectedBoard == null ? 0 : selectedBoard.getPostCount() %></strong>
                </div>
            </section>

            <section class="manage-card">
                <div class="manage-card-head">
                    <div>
                        <h2>게시판 설정</h2>
                        <p>왼쪽에서 게시판을 선택하고 오른쪽에서 이름, 설명, 권한을 수정합니다.</p>
                    </div>
                    <form class="inline-form" action="<%= contextPath %>/community/boardCreateProcess.jsp" method="post">
                        <input type="hidden" name="cafeId" value="<%= cafeId %>">
                        <input type="hidden" name="boardName" value="일반게시판">
                        <input type="hidden" name="description" value="">
                        <input type="hidden" name="readPermission" value="ALL">
                        <input type="hidden" name="writePermission" value="MEMBER">
                        <input type="hidden" name="isNotice" value="N">
                        <button class="btn-main btn-small" type="submit">+ 게시판</button>
                    </form>
                </div>

                <div class="board-manage-editor">
                    <aside class="board-manage-list">
                        <div class="board-manage-toolbar">
                            <button class="btn-sub btn-small" type="button" <%= canMoveUp ? "" : "disabled" %> onclick="moveSelectedBoard('UP')">↑</button>
                            <button class="btn-sub btn-small" type="button" <%= canMoveDown ? "" : "disabled" %> onclick="moveSelectedBoard('DOWN')">↓</button>
                            <span>선택한 게시판 순서 변경</span>
                        </div>
                        <nav class="board-manage-items" aria-label="게시판 목록">
                            <% if (boards.isEmpty()) { %>
                                <p class="empty-cell">활성 게시판이 없습니다.</p>
                            <% } %>
                            <% for (CafeBoardDTO board : boards) { %>
                                <a class="board-manage-item <%= board.getBoardId() == selectedBoardId ? "active" : "" %>" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
                                    <span><%= escapeHtml(board.getBoardName()) %></span>
                                    <% if ("Y".equals(board.getIsNotice())) { %>
                                        <em>공지</em>
                                    <% } %>
                                    <strong><%= board.getPostCount() %></strong>
                                </a>
                            <% } %>
                        </nav>
                    </aside>

                    <section class="board-manage-detail">
                        <% if (selectedBoard != null) { %>
                            <form class="board-setting-form" action="<%= contextPath %>/community/boardUpdateProcess.jsp" method="post">
                                <input type="hidden" name="cafeId" value="<%= cafeId %>">
                                <input type="hidden" name="boardId" value="<%= selectedBoard.getBoardId() %>">
                                <input type="hidden" name="displayOrder" value="<%= selectedBoard.getDisplayOrder() %>">

                                <div class="board-detail-title">
                                    <div>
                                        <h3><%= escapeHtml(selectedBoard.getBoardName()) %></h3>
                                        <p>표시 순서 <%= selectedBoard.getDisplayOrder() %> · 글 <%= selectedBoard.getPostCount() %>개</p>
                                    </div>
                                    <span class="status-badge"><%= "Y".equals(selectedBoard.getIsNotice()) ? "공지" : "일반" %></span>
                                </div>

                                <div class="board-setting-row">
                                    <label for="boardName<%= selectedBoard.getBoardId() %>">메뉴명</label>
                                    <input id="boardName<%= selectedBoard.getBoardId() %>" name="boardName" maxlength="100" value="<%= escapeHtml(selectedBoard.getBoardName()) %>" required>
                                </div>

                                <div class="board-setting-row">
                                    <label for="description<%= selectedBoard.getBoardId() %>">메뉴 설명</label>
                                    <input id="description<%= selectedBoard.getBoardId() %>" name="description" maxlength="500" value="<%= escapeHtml(selectedBoard.getDescription()) %>">
                                </div>

                                <div class="board-setting-row">
                                    <span>권한 설정</span>
                                    <div class="board-setting-stack">
                                        <label for="writePermission<%= selectedBoard.getBoardId() %>">
                                            글쓰기
                                            <select id="writePermission<%= selectedBoard.getBoardId() %>" name="writePermission">
                                                <option value="MEMBER" <%= "MEMBER".equals(selectedBoard.getWritePermission()) ? "selected" : "" %>>회원</option>
                                                <option value="MANAGER" <%= "MANAGER".equals(selectedBoard.getWritePermission()) ? "selected" : "" %>>매니저</option>
                                                <option value="OWNER" <%= "OWNER".equals(selectedBoard.getWritePermission()) ? "selected" : "" %>>운영자</option>
                                            </select>
                                            이상
                                        </label>
                                        <label for="readPermission<%= selectedBoard.getBoardId() %>">
                                            읽기
                                            <select id="readPermission<%= selectedBoard.getBoardId() %>" name="readPermission">
                                                <option value="ALL" <%= "ALL".equals(selectedBoard.getReadPermission()) ? "selected" : "" %>>전체</option>
                                                <option value="MEMBER" <%= "MEMBER".equals(selectedBoard.getReadPermission()) ? "selected" : "" %>>회원</option>
                                            </select>
                                            이상
                                        </label>
                                    </div>
                                </div>

                                <div class="board-setting-row">
                                    <span>게시판 설정</span>
                                    <div class="board-setting-stack">
                                        <label class="check-row board-setting-check">
                                            <input type="checkbox" name="isNotice" value="Y" <%= "Y".equals(selectedBoard.getIsNotice()) ? "checked" : "" %>>
                                            공지 게시판으로 사용
                                        </label>
                                    </div>
                                </div>

                                <div class="board-setting-actions">
                                    <button class="btn-main" type="submit">수정 저장</button>
                                    <button class="btn-danger" type="button" onclick="hideBoard(<%= selectedBoard.getBoardId() %>, <%= cafeId %>)">숨김 처리</button>
                                </div>
                            </form>
                        <% } else { %>
                            <div class="empty-cell">+ 게시판을 눌러 일반게시판을 만든 뒤 오른쪽에서 수정하세요.</div>
                        <% } %>
                    </section>
                </div>
            </section>
        </section>
    </section>
</main>
<script>
    const selectedBoardId = <%= selectedBoard == null ? "null" : String.valueOf(selectedBoard.getBoardId()) %>;

    function moveSelectedBoard(direction) {
        if (!selectedBoardId) {
            return;
        }
        location.href = "<%= request.getContextPath() %>/community/boardMoveProcess.jsp?boardId="
                + selectedBoardId + "&cafeId=<%= cafeId %>&direction=" + direction;
    }

    function hideBoard(boardId, cafeId) {
        if (confirm("게시판을 숨김 처리하시겠습니까?")) {
            location.href = "<%= request.getContextPath() %>/community/boardHideProcess.jsp?boardId=" + boardId + "&cafeId=" + cafeId;
        }
    }
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
