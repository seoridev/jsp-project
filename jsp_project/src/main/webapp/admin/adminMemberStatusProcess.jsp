<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.util.AdminPageUtil" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%
	request.setCharacterEncoding("UTF-8");

	String loginId = request.getParameter("loginId");
	String status = request.getParameter("status");
	String searchType = request.getParameter("searchType");
	String keyword = request.getParameter("keyword");
	String statusFilter = request.getParameter("statusFilter");
	String pageNumber = request.getParameter("page");
	String origin = request.getParameter("origin");
	String contextPath = request.getContextPath();
	String listQuery = AdminPageUtil.memberListQuery(searchType, keyword, statusFilter, pageNumber);

	//목록/상세 중 돌아갈 위치 결정
	String redirectUrl = contextPath + "/admin/adminMemberList.jsp?" + listQuery;
	if ("detail".equals(origin) && loginId != null && !loginId.trim().isEmpty()) {
	    redirectUrl = contextPath + "/admin/adminMemberDetail.jsp?loginId="
	        + AdminPageUtil.encode(loginId.trim()) + "&" + listQuery;
	}

	//잘못된 요청이면 변경 없이 원래 화면으로 이동
	if (loginId == null || loginId.trim().isEmpty() || !AdminPageUtil.isMemberUpdateStatus(status)) {
	    response.sendRedirect(redirectUrl + "&result=fail");
	    return;
	}

	try {
	    boolean updated = new MemberDAO().updateMemberStatus(loginId.trim(), status);
	    response.sendRedirect(redirectUrl + "&result=" + (updated ? "success" : "fail"));
	} catch (Exception e) {
	    response.sendRedirect(redirectUrl + "&result=fail");
	}
%>
