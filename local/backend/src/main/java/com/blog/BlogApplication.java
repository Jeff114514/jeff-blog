package com.blog;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 博客系统主启动类
 * 
 * @author Blog System
 * @version 1.0.0
 */
@SpringBootApplication
@MapperScan("com.blog.mapper")
public class BlogApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(BlogApplication.class, args);
        System.out.println("\n==============================================");
        System.out.println("博客系统启动成功!");
        System.out.println("访问地址: http://localhost:8080");
        System.out.println("==============================================\n");
    }
}
