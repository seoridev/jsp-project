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
        return "멤버";
    }

    public static String badgeClass(String role) {
        if ("OWNER".equals(role)) {
            return "is-owner";
        }
        if ("MANAGER".equals(role)) {
            return "is-manager";
        }
        return "is-member";
    }

    public static boolean canReadBoard(String readPermission, boolean activeMember) {
        if ("ALL".equals(readPermission)) {
            return true;
        }
        return "MEMBER".equals(readPermission) && activeMember;
    }

    public static boolean canWriteBoard(String writePermission, String role) {
        return roleLevel(role) >= roleLevel(writePermission) && roleLevel(writePermission) > 0;
    }

    public static boolean canManageCafe(String role) {
        return "OWNER".equals(role) || "MANAGER".equals(role);
    }

    private static int roleLevel(String role) {
        if ("OWNER".equals(role)) {
            return 3;
        }
        if ("MANAGER".equals(role)) {
            return 2;
        }
        if ("MEMBER".equals(role)) {
            return 1;
        }
        return 0;
    }
}
