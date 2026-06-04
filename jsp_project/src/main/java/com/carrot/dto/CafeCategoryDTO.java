package com.carrot.dto;

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
public class CafeCategoryDTO {
    private int cafeCategoryId;
    private String categoryName;
    private int sortOrder;
    private String isActive;
}
