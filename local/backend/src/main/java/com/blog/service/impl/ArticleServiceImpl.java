package com.blog.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.blog.common.Result;
import com.blog.dto.ArticleRequest;
import com.blog.entity.Article;
import com.blog.mapper.ArticleMapper;
import com.blog.service.ArticleService;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 文章服务实现类
 */
@Service
public class ArticleServiceImpl implements ArticleService {
    
    @Autowired
    private ArticleMapper articleMapper;
    
    @Override
    @Transactional
    public Result<?> createArticle(ArticleRequest request, Long userId) {
        Article article = new Article();
        BeanUtils.copyProperties(request, article);
        article.setAuthorId(userId);
        article.setViewCount(0);
        article.setStatus(request.getStatus() != null ? request.getStatus() : 1);
        article.setCreatedAt(LocalDateTime.now());
        article.setUpdatedAt(LocalDateTime.now());
        article.setDeleted(0);
        
        articleMapper.insert(article);
        
        return Result.success("文章创建成功", article);
    }
    
    @Override
    @Transactional
    public Result<?> updateArticle(Long id, ArticleRequest request, Long userId) {
        Article existing = articleMapper.selectById(id);
        if (existing == null || existing.getDeleted() == 1) {
            return Result.error("文章不存在");
        }
        
        if (!existing.getAuthorId().equals(userId)) {
            return Result.error("无权限修改此文章");
        }
        
        BeanUtils.copyProperties(request, existing);
        existing.setUpdatedAt(LocalDateTime.now());
        
        articleMapper.updateById(existing);
        
        return Result.success("文章更新成功", existing);
    }
    
    @Override
    @Transactional
    public Result<?> deleteArticle(Long id, Long userId) {
        Article existing = articleMapper.selectById(id);
        if (existing == null || existing.getDeleted() == 1) {
            return Result.error("文章不存在");
        }
        
        if (!existing.getAuthorId().equals(userId)) {
            return Result.error("无权限删除此文章");
        }
        
        // 逻辑删除
        existing.setDeleted(1);
        existing.setUpdatedAt(LocalDateTime.now());
        articleMapper.updateById(existing);
        
        return Result.success("文章删除成功");
    }
    
    @Override
    public Result<?> getArticleById(Long id) {
        Article article = articleMapper.selectById(id);
        if (article == null || article.getDeleted() == 1) {
            return Result.error("文章不存在");
        }
        
        // 增加浏览量
        article.setViewCount(article.getViewCount() + 1);
        articleMapper.updateById(article);
        
        return Result.success(article);
    }
    
    @Override
    public Result<?> getArticles(Page<Article> page, String category, String keyword) {
        QueryWrapper<Article> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        wrapper.eq("status", 1);  // 只查询已发布的文章
        
        if (category != null && !category.isEmpty()) {
            wrapper.eq("category", category);
        }
        
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like("title", keyword).or().like("content", keyword));
        }
        
        wrapper.orderByDesc("created_at");
        
        Page<Article> resultPage = articleMapper.selectPage(page, wrapper);
        
        return Result.success(resultPage);
    }
    
    @Override
    public Result<?> getArticleList() {
        QueryWrapper<Article> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0)
               .eq("status", 1)
               .orderByDesc("created_at");
        
        return Result.success(articleMapper.selectList(wrapper));
    }
}

