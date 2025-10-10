package com.blog.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.blog.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

/**
 * 用户Mapper接口
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {
    
    /**
     * 根据用户名查找用户
     */
    @Select("SELECT * FROM users WHERE username = #{username} AND deleted = 0")
    User findByUsername(String username);
    
    /**
     * 根据邮箱查找用户
     */
    @Select("SELECT * FROM users WHERE email = #{email} AND deleted = 0")
    User findByEmail(String email);
}

