<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
<%
    Object leaveCafeIdValue = request.getAttribute("cafeIncludeCafeId");
    int leaveCafeId = leaveCafeIdValue instanceof Integer ? ((Integer) leaveCafeIdValue).intValue() : 0;
    String leaveLoginId = (String) session.getAttribute("loginId");
    CafeMemberDTO leaveMember = leaveCafeId > 0 && leaveLoginId != null
            ? new CafeMemberDAO().selectCafeMember(leaveCafeId, leaveLoginId)
            : null;
    boolean canLeaveCafe = leaveMember != null
            && "ACTIVE".equals(leaveMember.getStatus())
            && !"OWNER".equals(leaveMember.getRole());
%>
<% if (canLeaveCafe) { %>
    <form class="cafe-left-leave-form" action="<%= request.getContextPath() %>/community/cafe/cafeLeaveProcess.jsp" method="post" onsubmit="return confirm('카페에서 탈퇴하시겠습니까?');">
        <input type="hidden" name="cafeId" value="<%= leaveCafeId %>">
        <button class="button cafe-side-secondary" type="submit">카페 탈퇴</button>
    </form>
<% } %>
