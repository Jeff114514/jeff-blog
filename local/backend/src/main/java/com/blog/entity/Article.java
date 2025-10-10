package com.blog.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 文章实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("articles")
public class Article implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    
    /**
     * 文章标题
     */
    private String title;
    
    /**
     * 文章内容（支持Markdown）
     */
    @TableField(value = "`content`")
    private String content;
    
    /**
     * 文章摘要
     */
    private String summary;
    
    /**
     * 作者ID
     */
    private Long authorId;
    
    /**
     * 文章分类
     */
    private String category;
    
    /**
     * 标签（逗号分隔）
     */
    private String tags;
    
    /**
     * 文章状态: 0-草稿, 1-已发布, 2-下线
     */
    private Integer status;
    
    /**
     * 浏览次数
     */
    private Integer viewCount;
    
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

