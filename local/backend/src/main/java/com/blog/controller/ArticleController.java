package com.blog.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.blog.common.Result;
import com.blog.dto.ArticleRequest;
import com.blog.entity.Article;
import com.blog.service.ArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

/**
 * 文章控制器
 */
@RestController
@RequestMapping("/api/articles")
public class ArticleController {
    
    @Autowired
    private ArticleService articleService;
    
    /**
     * 创建文章
     */
    @PostMapping
    public Result<?> createArticle(@Valid @RequestBody ArticleRequest request,
                                  @RequestParam Long userId) {
        return articleService.createArticle(request, userId);
    }
    
    /**
     * 更新文章
     */
    @PutMapping("/{id}")
    public Result<?> updateArticle(@PathVariable Long id,
                                  @Valid @RequestBody ArticleRequest request,
                                  @RequestParam Long userId) {
        return articleService.updateArticle(id, request, userId);
    }
    
    /**
     * 删除文章
     */
    @DeleteMapping("/{id}")
    public Result<?> deleteArticle(@PathVariable Long id,
                                  @RequestParam Long userId) {
        return articleService.deleteArticle(id, userId);
    }
    
    /**
     * 获取文章详情
     */
    @GetMapping("/{id}")
    public Result<?> getArticle(@PathVariable Long id) {
        return articleService.getArticleById(id);
    }
    
    /**
     * 分页查询文章列表
     */
    @GetMapping
    public Result<?> getArticles(@RequestParam(defaultValue = "1") Integer page,
                                @RequestParam(defaultValue = "10") Integer size,
                                @RequestParam(required = false) String category,
                                @RequestParam(required = false) String keyword) {
        Page<Article> pageParam = new Page<>(page, size);
        return articleService.getArticles(pageParam, category, keyword);
    }
    
    /**
     * 获取所有文章列表
     */
    @GetMapping("/list")
    public Result<?> getArticleList() {
        return articleService.getArticleList();
    }
}

