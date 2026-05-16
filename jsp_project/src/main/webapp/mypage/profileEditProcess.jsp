<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    String currentLoginId = (String) session.getAttribute("loginId");
    String nickname = request.getParameter("nickname") == null ? "" : request.getParameter("nickname").trim();
    String phone = request.getParameter("phone") == null ? "" : request.getParameter("phone").trim();
    String region = request.getParameter("region") == null ? "" : request.getParameter("region").trim();
    String profileText = request.getParameter("profileText") == null ? "" : request.getParameter("profileText").trim();

    if (nickname.isEmpty() || region.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/mypage/profileEdit.jsp?error=empty");
        return;
    }

    MemberDAO memberDAO = new MemberDAO();
    MemberDTO current = memberDAO.getMemberByLoginId(currentLoginId);
    if (current == null) {
        response.sendRedirect(request.getContextPath() + "/member/login.jsp?error=loginRequired");
        return;
    }

    if (!phone.isEmpty() && !phone.equals(current.getPhone())) {
        try {
            if (memberDAO.isDuplicatePhone(phone)) {
                response.sendRedirect(request.getContextPath() + "/mypage/profileEdit.jsp?error=phoneDuplicate");
                return;
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/mypage/profileEdit.jsp?error=fail");
            return;
        }
    }

    current.setNickname(nickname);
    current.setPhone(phone);
    current.setRegion(region);
    current.setProfileText(profileText);

    if (memberDAO.updateMember(current)) {
        session.setAttribute("loginNickname", nickname);
        session.setAttribute("loginRegion", region);
        response.sendRedirect(request.getContextPath() + "/mypage/mypage.jsp?result=updated");
    } else {
        response.sendRedirect(request.getContextPath() + "/mypage/profileEdit.jsp?error=fail");
    }
%>
