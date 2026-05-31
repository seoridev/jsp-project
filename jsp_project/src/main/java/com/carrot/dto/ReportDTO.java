package com.carrot.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportDTO {
    private int reportId;
    private String reporterId;
    private String targetType;
    private int targetId;
    private String reason;
    private String detail;
    private String status;
    private Timestamp createdAt;
    private Timestamp processedAt;
    private String processedBy;
    private String actionType;
    private String adminMemo;

    private String reporterNickname;
    private String productTitle;
    private String targetTitle;
    private String targetContent;
    private String targetWriterId;
    private int targetPostId;
    private int targetCafeId;
    private String targetCafeName;
    private int targetWaitingReportCount;
    private int targetTotalReportCount;
    private String targetRecentReportSummary;
}
