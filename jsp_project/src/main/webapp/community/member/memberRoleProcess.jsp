<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
<%@ include file="../../common/sessionCheck.jsp" %>
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
    String memberId = request.getParameter("memberId");
    String role = request.getParameter("role");
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    String redirectUrl = request.getContextPath() + "/community/member/cafeMemberManage.jsp?cafeId=" + cafeId;

    CafeMemberDTO currentMember = memberDao.selectCafeMember(cafeId, currentLoginId);
    CafeMemberDTO targetMember = memberDao.selectCafeMember(cafeId, memberId);
    boolean canChange = cafeId > 0
            && currentMember != null
            && targetMember != null
            && "ACTIVE".equals(currentMember.getStatus())
            && "OWNER".equals(currentMember.getRole())
            && !"OWNER".equals(targetMember.getRole())
            && "ACTIVE".equals(targetMember.getStatus())
            && !currentLoginId.equals(memberId)
            && ("MANAGER".equals(role) || "MEMBER".equals(role));

    if (!canChange) {
        response.sendRedirect(redirectUrl + "&error=roleFail");
        return;
    }

    boolean updated = memberDao.updateMemberRole(cafeId, memberId, role);
    response.sendRedirect(redirectUrl + (updated ? "&memberAction=role" : "&error=roleFail"));
%>
