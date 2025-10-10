package com.blog.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 评论实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("comments")
public class Comment implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    
    /**
     * 文章ID
     */
    private Long articleId;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 评论内容
     */
    @TableField(value = "`content`")
    private String content;
    
    /**
     * 父评论ID（用于回复评论）
     */
    private Long parentId;
    
    /**
     * 评论状态: 0-待审核, 1-已审核, 2-已拒绝
     */
    private Integer status;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    
    /**
     * 逻辑删除
     */
    @TableLogic
    private Integer deleted;
}

