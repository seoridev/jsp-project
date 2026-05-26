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
    String action = request.getParameter("action");
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    String redirectUrl = request.getContextPath() + "/community/member/cafeMemberManage.jsp?cafeId=" + cafeId;

    CafeMemberDTO currentMember = memberDao.selectCafeMember(cafeId, currentLoginId);
    CafeMemberDTO targetMember = memberDao.selectCafeMember(cafeId, memberId);
    String nextStatus = null;
    if ("kick".equals(action)) {
        nextStatus = "LEFT";
    } else if ("ban".equals(action)) {
        nextStatus = "BANNED";
    } else if ("unban".equals(action)) {
        nextStatus = "ACTIVE";
    }

    boolean owner = currentMember != null && "OWNER".equals(currentMember.getRole());
    boolean manager = currentMember != null && "MANAGER".equals(currentMember.getRole());
    boolean canManage = cafeId > 0
            && currentMember != null
            && targetMember != null
            && nextStatus != null
            && "ACTIVE".equals(currentMember.getStatus())
            && !"OWNER".equals(targetMember.getRole())
            && !currentLoginId.equals(memberId)
            && (owner || (manager && "MEMBER".equals(targetMember.getRole())));

    if ("kick".equals(action)) {
        canManage = canManage && "ACTIVE".equals(targetMember.getStatus());
    } else if ("unban".equals(action)) {
        canManage = canManage && owner
                && ("BANNED".equals(targetMember.getStatus()) || "LEFT".equals(targetMember.getStatus()));
    }

    if (!canManage) {
        response.sendRedirect(redirectUrl + "&error=statusFail");
        return;
    }

    boolean updated = memberDao.setMemberStatus(cafeId, memberId, nextStatus);
    response.sendRedirect(redirectUrl + (updated ? "&memberAction=" + action : "&error=statusFail"));
%>
