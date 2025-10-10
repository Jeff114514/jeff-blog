package com.blog.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.blog.common.Result;
import com.blog.dto.LoginRequest;
import com.blog.dto.RegisterRequest;
import com.blog.entity.User;
import com.blog.mapper.UserMapper;
import com.blog.service.UserService;
import com.blog.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 用户服务实现类
 */
@Service
public class UserServiceImpl implements UserService {
    
    @Autowired
    private UserMapper userMapper;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Override
    @Transactional
    public Result<?> register(RegisterRequest request) {
        // 检查用户名是否已存在
        QueryWrapper<User> usernameWrapper = new QueryWrapper<>();
        usernameWrapper.eq("username", request.getUsername()).eq("deleted", 0);
        if (userMapper.selectCount(usernameWrapper) > 0) {
            return Result.error("用户名已存在");
        }
        
        // 检查邮箱是否已存在
        QueryWrapper<User> emailWrapper = new QueryWrapper<>();
        emailWrapper.eq("email", request.getEmail()).eq("deleted", 0);
        if (userMapper.selectCount(emailWrapper) > 0) {
            return Result.error("邮箱已被注册");
        }
        
        // 创建用户
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setStatus(1);
        user.setRole("user");
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        user.setDeleted(0);
        
        userMapper.insert(user);
        
        return Result.success("注册成功");
    }
    
    @Override
    public Result<?> login(LoginRequest request) {
        // 查找用户
        User user = userMapper.findByUsername(request.getUsername());
        
        if (user == null) {
            return Result.error("用户不存在");
        }
        
        if (user.getStatus() == 0) {
            return Result.error("账号已被禁用");
        }
        
        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return Result.error("密码错误");
        }
        
        // 生成Token
        String token = jwtUtil.generateToken(user.getId().toString());
        
        // 返回用户信息和Token
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("userId", user.getId());
        data.put("username", user.getUsername());
        data.put("email", user.getEmail());
        data.put("avatar", user.getAvatar());
        data.put("role", user.getRole());
        
        return Result.success("登录成功", data);
    }
    
    @Override
    public Result<?> getUserProfile(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null || user.getDeleted() == 1) {
            return Result.error("用户不存在");
        }
        
        // 移除密码字段
        user.setPassword(null);
        return Result.success(user);
    }
    
    @Override
    public User findById(Long id) {
        return userMapper.selectById(id);
    }
    
    @Override
    public User findByUsername(String username) {
        return userMapper.findByUsername(username);
    }
}

