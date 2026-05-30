<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%!
    private String selectedAttr(String value, String current) {
        return value.equals(current) ? " selected" : "";
    }

    private String visibilityText(String visibility) {
        return "PRIVATE".equals(visibility) ? "비공개" : "공개";
    }
%>
<%
    int cafeId = ParamParser.parseInt(request.getParameter("cafeId"));
    CafeDAO cafeDao = new CafeDAO();
    CafeDTO cafe = cafeDao.selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeList.jsp?error=noCafe");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    if (!new CafeMemberDAO().isCafeManagerOrOwner(cafeId, currentLoginId)) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId + "&error=manageDenied");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>카페 관리 | <%= escapeHtml(cafe.getCafeName()) %></title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
<main class="page-shell manage-shell">
    <section class="manage-header">
        <div>
            <p class="breadcrumb"><a href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(cafe.getCafeName()) %></a></p>
            <h1>카페 관리</h1>
        </div>
        <a class="button btn-sub" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafeId %>">카페로 돌아가기</a>
    </section>

    <% if ("success".equals(request.getParameter("update"))) { %>
        <p class="notice-toast">카페 설정이 저장되었습니다.</p>
    <% } else if ("invalid".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">카페 정보를 다시 확인해 주세요.</p>
    <% } else if ("fail".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">카페 설정 저장에 실패했습니다.</p>
    <% } else if ("manageDenied".equals(request.getParameter("error"))) { %>
        <p class="field-message is-error">카페 관리 권한이 없습니다.</p>
    <% } %>

    <section class="manage-layout">
        <aside class="manage-sidebar">
            <div class="manage-sidebar-title">관리 메뉴</div>
            <nav class="manage-menu" aria-label="카페 관리 메뉴">
                <a class="active" href="<%= contextPath %>/community/cafe/cafeManage.jsp?cafeId=<%= cafeId %>">카페 관리</a>
                <a href="<%= contextPath %>/community/board/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                <a href="<%= contextPath %>/community/member/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                <a href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafeId %>">카페로 돌아가기</a>
            </nav>
        </aside>

        <section class="manage-content">
            <section class="manage-card">
                <div class="manage-card-head">
                    <div>
                        <h2>기본 정보</h2>
                        <p>카페 소개, 지역, 주제와 운영 방식을 관리합니다.</p>
                    </div>
                    <span class="status-badge"><%= visibilityText(cafe.getVisibility()) %></span>
                </div>

                <form class="board-setting-form cafe-setting-form" action="<%= contextPath %>/community/cafe/cafeManageProcess.jsp" method="post">
                    <input type="hidden" name="cafeId" value="<%= cafeId %>">

                    <div class="board-setting-row">
                        <span>카페명</span>
                        <div class="board-setting-stack">
                            <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                            <p class="cafe-setting-help">카페명은 중복 방지를 위해 이 화면에서 변경하지 않습니다.</p>
                        </div>
                    </div>

                    <div class="board-setting-row">
                        <label for="description">카페 소개</label>
                        <div class="board-setting-stack">
                            <textarea id="description" name="description" maxlength="500" required><%= escapeHtml(cafe.getDescription()) %></textarea>
                            <p class="cafe-setting-help">카페 홈과 검색 결과에서 카페를 설명하는 문구입니다.</p>
                        </div>
                    </div>

                    <div class="board-setting-row">
                        <label for="region">지역</label>
                        <div class="board-setting-stack">
                            <input id="region" name="region" maxlength="100" value="<%= escapeHtml(cafe.getRegion()) %>" required>
                            <p class="cafe-setting-help">카페 검색과 지역 표시 기준으로 사용됩니다.</p>
                        </div>
                    </div>

                    <div class="board-setting-row">
                        <label for="category">주제</label>
                        <div class="board-setting-stack">
                            <input id="category" name="category" maxlength="50" value="<%= escapeHtml(cafe.getCategory()) %>" required>
                            <p class="cafe-setting-help">독서, 반려동물, 동네 소식처럼 카페의 주제를 적어 주세요.</p>
                        </div>
                    </div>

                    <div class="board-setting-row">
                        <label for="visibility">공개 범위</label>
                        <div class="board-setting-stack">
                            <select id="visibility" name="visibility">
                                <option value="PUBLIC"<%= selectedAttr("PUBLIC", cafe.getVisibility()) %>>공개</option>
                                <option value="PRIVATE"<%= selectedAttr("PRIVATE", cafe.getVisibility()) %>>비공개</option>
                            </select>
                            <p class="cafe-setting-help">공개 카페는 누구나 글 목록을 볼 수 있고, 비공개 카페는 가입 회원만 글을 볼 수 있습니다.</p>
                        </div>
                    </div>

                    <div class="board-setting-row">
                        <label for="joinType">가입 방식</label>
                        <div class="board-setting-stack">
                            <select id="joinType" name="joinType">
                                <option value="DIRECT"<%= selectedAttr("DIRECT", cafe.getJoinType()) %>>바로 가입</option>
                                <option value="APPROVAL"<%= selectedAttr("APPROVAL", cafe.getJoinType()) %>>승인 가입</option>
                            </select>
                            <p class="cafe-setting-help">바로 가입은 신청 즉시 회원이 되고, 승인 가입은 스탭 승인 후 활동할 수 있습니다.</p>
                        </div>
                    </div>

                    <div class="board-setting-actions">
                        <button class="btn-main" type="submit">설정 저장</button>
                    </div>
                </form>
            </section>
        </section>
    </section>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
