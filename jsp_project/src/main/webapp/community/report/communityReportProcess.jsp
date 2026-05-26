<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dao.ReportDAO" %>
<%@ page import="com.carrot.dto.CafeCommentDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ page import="com.carrot.dto.ReportDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%!
    // 신고 처리 공통 검증과 리다이렉트 보조 함수
    private boolean isValidTargetType(String targetType) {
        return "CAFE".equals(targetType) || "CAFE_POST".equals(targetType) || "CAFE_COMMENT".equals(targetType);
    }

    private String appendParam(String url, String param) {
        return url + (url.indexOf('?') >= 0 ? "&" : "?") + param;
    }
%>
<%
    // 신고 대상 검증 후 중복 신고를 막고 저장
    request.setCharacterEncoding("UTF-8");
    String currentLoginId = (String) session.getAttribute("loginId");
    String targetType = request.getParameter("targetType");
    int targetId = ParamParser.parseInt(request.getParameter("targetId"));
    String reason = request.getParameter("reason");
    String detail = request.getParameter("detail");
    String redirectUrl = request.getContextPath() + "/community/communityHome.jsp";
    boolean validTarget = false;

    if ("CAFE".equals(targetType)) {
        CafeDTO cafe = new CafeDAO().selectCafeById(targetId);
        validTarget = cafe != null;
        redirectUrl = request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + targetId;
    } else if ("CAFE_POST".equals(targetType)) {
        CafePostDTO post = new CafePostDAO().selectPostById(targetId);
        validTarget = post != null;
        redirectUrl = request.getContextPath() + "/community/post/postDetail.jsp?postId=" + targetId;
    } else if ("CAFE_COMMENT".equals(targetType)) {
        CafeCommentDTO comment = new CafeCommentDAO().selectCommentById(targetId);
        CafePostDTO post = comment == null ? null : new CafePostDAO().selectPostById(comment.getPostId());
        validTarget = comment != null && !"Y".equals(comment.getIsDeleted()) && post != null;
        if (comment != null) {
            redirectUrl = request.getContextPath() + "/community/post/postDetail.jsp?postId=" + comment.getPostId();
        }
    }

    boolean valid = isValidTargetType(targetType)
            && targetId > 0
            && validTarget
            && reason != null
            && !reason.trim().isEmpty()
            && detail != null
            && !detail.trim().isEmpty();

    if (!valid) {
        response.sendRedirect(appendParam(redirectUrl, "error=reportFail"));
        return;
    }

    ReportDAO reportDao = new ReportDAO();
    if (reportDao.existsReport(currentLoginId, targetType, targetId)) {
        response.sendRedirect(appendParam(redirectUrl, "error=reportDuplicate"));
        return;
    }

    ReportDTO report = ReportDTO.builder()
            .reporterId(currentLoginId)
            .targetType(targetType)
            .targetId(targetId)
            .reason(reason.trim())
            .detail(detail.trim())
            .build();
    boolean inserted = reportDao.insertReport(report);
    response.sendRedirect(appendParam(redirectUrl, inserted ? "report=success" : "error=reportFail"));
%>
