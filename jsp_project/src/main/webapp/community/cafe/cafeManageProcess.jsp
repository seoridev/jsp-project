<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    int cafeId = ParamParser.parseInt(request.getParameter("cafeId"));
    String description = request.getParameter("description") == null ? "" : request.getParameter("description").trim();
    String region = request.getParameter("region") == null ? "" : request.getParameter("region").trim();
    String category = request.getParameter("category") == null ? "" : request.getParameter("category").trim();
    String visibility = "PRIVATE".equals(request.getParameter("visibility")) ? "PRIVATE" : "PUBLIC";
    String joinType = "APPROVAL".equals(request.getParameter("joinType")) ? "APPROVAL" : "DIRECT";

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeDAO cafeDao = new CafeDAO();
    CafeDTO currentCafe = cafeDao.selectCafeById(cafeId);
    if (currentCafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeList.jsp?error=noCafe");
        return;
    }

    if (!new CafeMemberDAO().isCafeManagerOrOwner(cafeId, currentLoginId)) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeManage.jsp?cafeId=" + cafeId + "&error=manageDenied");
        return;
    }

    if (description.isEmpty() || description.length() > 500
            || region.isEmpty() || region.length() > 100
            || category.isEmpty() || category.length() > 50) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeManage.jsp?cafeId=" + cafeId + "&error=invalid");
        return;
    }

    boolean updated = cafeDao.updateCafeSettings(CafeDTO.builder()
            .cafeId(cafeId)
            .description(description)
            .region(region)
            .category(category)
            .visibility(visibility)
            .joinType(joinType)
            .build());

    response.sendRedirect(request.getContextPath() + "/community/cafe/cafeManage.jsp?cafeId="
            + cafeId + (updated ? "&update=success" : "&error=fail"));
%>
