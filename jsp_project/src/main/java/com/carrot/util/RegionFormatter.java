package com.carrot.util;

public final class RegionFormatter {

    private RegionFormatter() {
    }

    public static String formatKoreanSigungu(String region) {
        if (region == null) {
            return "";
        }
        String normalized = region.trim().replaceAll("\\s+", " ");
        if (normalized.isEmpty()) {
            return "";
        }

        String[] parts = normalized.split(" ");
        if (parts.length == 1) {
            return parts[0];
        }

        String first = parts[0];
        if (hasRegionSuffix(first, "특별자치시") || "세종".equals(first)) {
            return first;
        }

        boolean provinceLevel = hasRegionSuffix(first, "도") || isProvinceRegionAlias(first);
        boolean metroLevel = hasRegionSuffix(first, "특별시") || hasRegionSuffix(first, "광역시") || isMetroRegionAlias(first);

        if (provinceLevel || metroLevel) {
            StringBuilder result = new StringBuilder(first).append(" ").append(parts[1]);
            if (hasRegionSuffix(parts[1], "시") && parts.length > 2 && hasRegionSuffix(parts[2], "구")) {
                result.append(" ").append(parts[2]);
            }
            return result.toString();
        }

        if (hasRegionSuffix(first, "시") && parts.length > 1 && hasRegionSuffix(parts[1], "구")) {
            return first + " " + parts[1];
        }
        if (hasRegionSuffix(first, "시") || hasRegionSuffix(first, "군") || hasRegionSuffix(first, "구")) {
            return first;
        }

        return normalized;
    }

    private static boolean hasRegionSuffix(String value, String suffix) {
        return value != null && value.endsWith(suffix);
    }

    private static boolean isMetroRegionAlias(String value) {
        return "서울".equals(value) || "부산".equals(value) || "대구".equals(value)
                || "인천".equals(value) || "광주".equals(value) || "대전".equals(value)
                || "울산".equals(value);
    }

    private static boolean isProvinceRegionAlias(String value) {
        return "경기".equals(value) || "강원".equals(value) || "충북".equals(value)
                || "충남".equals(value) || "전북".equals(value) || "전남".equals(value)
                || "경북".equals(value) || "경남".equals(value) || "제주".equals(value);
    }
}
