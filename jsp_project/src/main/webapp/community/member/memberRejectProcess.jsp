<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    // 관리자 권한 확인 후 가입 대기 회원 거절
    int cafeId = ParamParser.parseInt(request.getParameter("cafeId"));
    String memberId = request.getParameter("memberId");
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();

    if (cafeId <= 0 || memberId == null || memberId.trim().isEmpty()
            || !memberDao.isCafeManagerOrOwner(cafeId, currentLoginId)) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId + "&error=manageDenied");
        return;
    }

    boolean rejected = memberDao.rejectMember(cafeId, memberId);
    response.sendRedirect(request.getContextPath() + "/community/member/cafeMemberManage.jsp?cafeId="
            + cafeId + (rejected ? "&reject=success" : "&error=rejectFail"));
%>
