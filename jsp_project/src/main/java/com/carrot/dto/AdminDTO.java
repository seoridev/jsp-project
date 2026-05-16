package com.carrot.dto;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminDTO {
    private String loginId;
    private String password;
    private String name;
    private Timestamp createdAt;
}
