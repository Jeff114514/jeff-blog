package com.blog.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.Serializable;

/**
 * 评论请求DTO
 */
@Data
public class CommentRequest implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @NotNull(message = "文章ID不能为空")
    private Long articleId;
    
    @NotBlank(message = "评论内容不能为空")
    private String content;
    
    private Long parentId;
}

