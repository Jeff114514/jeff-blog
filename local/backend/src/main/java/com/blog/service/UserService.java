package com.blog.service;

import com.blog.common.Result;
import com.blog.dto.LoginRequest;
import com.blog.dto.RegisterRequest;
import com.blog.entity.User;

/**
 * 用户服务接口
 */
public interface UserService {
    
    /**
     * 用户注册
     */
    Result<?> register(RegisterRequest request);
    
    /**
     * 用户登录
     */
    Result<?> login(LoginRequest request);
    
    /**
     * 获取用户信息
     */
    Result<?> getUserProfile(Long userId);
    
    /**
     * 根据ID查找用户
     */
    User findById(Long id);
    
    /**
     * 根据用户名查找用户
     */
    User findByUsername(String username);
}

