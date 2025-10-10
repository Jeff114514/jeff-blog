package com.blog.controller;

import com.blog.common.Result;
import com.blog.dto.LoginRequest;
import com.blog.dto.RegisterRequest;
import com.blog.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

/**
 * 认证控制器
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @Autowired
    private UserService userService;
    
    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<?> register(@Valid @RequestBody RegisterRequest request) {
        return userService.register(request);
    }
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<?> login(@Valid @RequestBody LoginRequest request) {
        return userService.login(request);
    }
    
    /**
     * 获取用户信息
     */
    @GetMapping("/profile/{userId}")
    public Result<?> getProfile(@PathVariable Long userId) {
        return userService.getUserProfile(userId);
    }
}

