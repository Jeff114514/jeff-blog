package com.blog.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.blog.common.Result;
import com.blog.dto.ArticleRequest;
import com.blog.entity.Article;

/**
 * 文章服务接口
 */
public interface ArticleService {
    
    /**
     * 创建文章
     */
    Result<?> createArticle(ArticleRequest request, Long userId);
    
    /**
     * 更新文章
     */
    Result<?> updateArticle(Long id, ArticleRequest request, Long userId);
    
    /**
     * 删除文章
     */
    Result<?> deleteArticle(Long id, Long userId);
    
    /**
     * 获取文章详情
     */
    Result<?> getArticleById(Long id);
    
    /**
     * 分页查询文章列表
     */
    Result<?> getArticles(Page<Article> page, String category, String keyword);
    
    /**
     * 获取所有文章列表
     */
    Result<?> getArticleList();
}

