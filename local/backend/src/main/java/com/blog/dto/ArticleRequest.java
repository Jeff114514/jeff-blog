package com.blog.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import java.io.Serializable;

/**
 * 文章请求DTO
 */
@Data
public class ArticleRequest implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @NotBlank(message = "标题不能为空")
    private String title;
    
    @NotBlank(message = "内容不能为空")
    private String content;
    
    private String summary;
    
    private String category;
    
    private String tags;
    
    private Integer status;
}

