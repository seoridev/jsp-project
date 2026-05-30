package com.carrot.util;

public final class CafeRoleUtil {
    private CafeRoleUtil() {
    }

    public static String badgeText(String role) {
        if ("OWNER".equals(role)) {
            return "운영자";
        }
        if ("MANAGER".equals(role)) {
            return "스탭";
        }
        if ("MEMBER".equals(role)) {
            return "멤버";
        }
        return "";
    }

    public static String badgeClass(String role) {
        if ("OWNER".equals(role)) {
            return "is-owner";
        }
        if ("MANAGER".equals(role)) {
            return "is-manager";
        }
        if ("MEMBER".equals(role)) {
            return "is-member";
        }
        return "";
    }
}
