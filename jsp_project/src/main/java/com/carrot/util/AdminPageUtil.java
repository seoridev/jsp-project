package com.carrot.util;

import java.net.URLEncoder;

public final class AdminPageUtil {
    private AdminPageUtil() {
    }

    public static String selected(String current, String expected) {
        return expected != null && expected.equalsIgnoreCase(current) ? "selected" : "";
    }

    public static String requestValue(String value) {
        return value == null ? "" : value.trim();
    }

    public static int parseInt(String value) {
        return ParamParser.parseInt(value);
    }

    public static int parsePage(String value) {
        return Math.max(ParamParser.parseInt(value, 1), 1);
    }

    public static String encode(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    public static String memberStatusLabel(String status) {
        if ("STOPPED".equalsIgnoreCase(status)) {
            return "이용 제한";
        }
        if ("WITHDRAWN".equalsIgnoreCase(status)) {
            return "탈퇴";
        }
        return "정상";
    }

    public static String memberStatusClass(String status) {
        if ("STOPPED".equalsIgnoreCase(status)) {
            return " is-stopped";
        }
        if ("WITHDRAWN".equalsIgnoreCase(status)) {
            return " is-withdrawn";
        }
        return " is-active";
    }

    public static boolean isMemberSearchType(String searchType) {
        return "loginId".equals(searchType) || "nickname".equals(searchType)
            || "phone".equals(searchType) || "region".equals(searchType);
    }

    public static boolean isMemberUpdateStatus(String status) {
        return "ACTIVE".equals(status) || "STOPPED".equals(status);
    }

    public static String memberListQuery(String searchType, String keyword, String status, int page) {
        return memberListQuery(searchType, keyword, status, String.valueOf(page));
    }

    public static String memberListQuery(String searchType, String keyword, String status, String page) {
        String safeSearchType = isMemberSearchType(searchType) ? searchType : "loginId";
        String safeStatus = status == null || status.isEmpty() ? "ALL" : status;
        String safePage = page == null || page.isEmpty() ? "1" : page;
        return "searchType=" + encode(safeSearchType)
            + "&keyword=" + encode(keyword)
            + "&status=" + encode(safeStatus)
            + "&page=" + encode(safePage);
    }

    public static String reportStatusText(String status) {
        if ("ALL".equalsIgnoreCase(status)) {
            return "전체";
        }
        if ("DONE".equalsIgnoreCase(status)) {
            return "처리완료";
        }
        if ("REJECTED".equalsIgnoreCase(status)) {
            return "반려";
        }
        return "대기";
    }

    public static String reportStatusClass(String status) {
        if ("DONE".equalsIgnoreCase(status)) {
            return " is-active";
        }
        if ("REJECTED".equalsIgnoreCase(status)) {
            return " is-withdrawn";
        }
        return " is-stopped";
    }

    public static boolean isProductReportSearchType(String searchType) {
        return "product".equals(searchType) || "reporter".equals(searchType);
    }

    public static boolean isProductReportStatus(String status) {
        return "ALL".equals(status) || "WAITING".equals(status)
            || "DONE".equals(status) || "REJECTED".equals(status);
    }

    public static String productReportListQuery(String searchType, String keyword, String status) {
        String safeSearchType = isProductReportSearchType(searchType) ? searchType : "product";
        String safeStatus = status == null || status.trim().isEmpty() ? "ALL" : status.trim().toUpperCase();
        return "searchType=" + encode(safeSearchType)
            + "&keyword=" + encode(keyword)
            + "&status=" + encode(safeStatus);
    }

    public static String communityListQuery(String searchType, String keyword, String status, int page) {
        return "searchType=" + encode(searchType)
            + "&keyword=" + encode(keyword)
            + "&status=" + encode(status)
            + "&page=" + page;
    }
}
