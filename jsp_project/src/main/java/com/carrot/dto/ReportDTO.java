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

    private String reporterNickname;
    private String productTitle;
}
