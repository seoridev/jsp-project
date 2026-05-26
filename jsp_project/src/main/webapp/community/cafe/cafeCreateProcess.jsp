<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String currentLoginId = (String) session.getAttribute("loginId");
    String cafeName = request.getParameter("cafeName") == null ? "" : request.getParameter("cafeName").trim();
    String description = request.getParameter("description") == null ? "" : request.getParameter("description").trim();
    String region = request.getParameter("region") == null ? "" : request.getParameter("region").trim();
    String category = request.getParameter("category") == null ? "" : request.getParameter("category").trim();
    String visibility = "PRIVATE".equals(request.getParameter("visibility")) ? "PRIVATE" : "PUBLIC";
    String joinType = "APPROVAL".equals(request.getParameter("joinType")) ? "APPROVAL" : "DIRECT";

    if (cafeName.isEmpty() || region.isEmpty() || category.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeCreate.jsp?error=empty");
        return;
    }

    CafeDAO cafeDao = new CafeDAO();
    if (cafeDao.isDuplicateCafeName(cafeName)) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeCreate.jsp?error=duplicate");
        return;
    }

    int cafeId = cafeDao.createCafeWithOwnerAndDefaultBoards(CafeDTO.builder()
            .cafeName(cafeName)
            .description(description)
            .region(region)
            .category(category)
            .visibility(visibility)
            .joinType(joinType)
            .ownerId(currentLoginId)
            .build());

    if (cafeId <= 0) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeCreate.jsp?error=fail");
        return;
    }

    response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId + "&created=success");
%>
