<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
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
%>
<%
    request.setCharacterEncoding("UTF-8");

    int postId = parseIntParam(request.getParameter("postId"));
    String title = request.getParameter("title") == null ? "" : request.getParameter("title").trim();
    String content = request.getParameter("content") == null ? "" : request.getParameter("content").trim();
    if (postId <= 0 || title.isEmpty() || title.length() > 200 || content.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/community/postUpdate.jsp?postId=" + postId + "&error=fail");
        return;
    }

    CafePostDAO postDao = new CafePostDAO();
    CafePostDTO current = postDao.selectPostById(postId);
    if (current == null) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=noPost");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    boolean manager = new CafeMemberDAO().isCafeManagerOrOwner(current.getCafeId(), currentLoginId);
    boolean updated = postDao.updatePost(CafePostDTO.builder()
            .postId(postId)
            .title(title)
            .content(content)
            .isNotice("Y".equals(request.getParameter("isNotice")) ? "Y" : "N")
            .build(), currentLoginId, manager);

    if (!updated) {
        response.sendRedirect(request.getContextPath() + "/community/postUpdate.jsp?postId=" + postId + "&error=fail");
        return;
    }
    response.sendRedirect(request.getContextPath() + "/community/postDetail.jsp?postId=" + postId + "&update=success");
%>
