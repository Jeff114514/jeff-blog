package com.blog.controller;

import com.blog.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.net.URI;

/**
 * AI对话控制器（vLLM）
 */
@RestController
@RequestMapping("/api/ai")
public class AIController {

    @Value("${ai.vllm.url}")
    private String vllmUrl;

    @Value("${ai.vllm.model}")
    private String model;

    @Value("${ai.vllm.api-key}")
    private String apiKey;

    @Value("${ai.vllm.timeout}")
    private int timeout;

    @Value("${ai.vllm.max-tokens}")
    private int maxTokens;

    @Value("${ai.vllm.temperature}")
    private double temperature;

    @Value("${ai.vllm.top-p}")
    private double topP;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * AI对话接口（vLLM）
     */
    @PostMapping("/chat")
    public Result<?> chat(@RequestBody Map<String, String> request) {
        try {
            String userMessage = request.get("message");
            if (userMessage == null || userMessage.trim().isEmpty()) {
                return Result.error("消息内容不能为空");
            }

            // 构建vLLM请求体（OpenAI兼容格式）
            Map<String, Object> aiRequest = new HashMap<>();
            aiRequest.put("model", model);
            aiRequest.put("messages", new Object[] {
                Map.of("role", "user", "content", userMessage)
            });
            aiRequest.put("max_tokens", maxTokens);
            aiRequest.put("temperature", temperature);
            aiRequest.put("top_p", topP);
            aiRequest.put("stream", false);

            // 设置请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            if (apiKey != null && !apiKey.equals("your-api-key-here")) {
                headers.set("Authorization", "Bearer " + apiKey);
            }

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(aiRequest, headers);

            // 调用vLLM服务
            ResponseEntity<Map> response = restTemplate.exchange(
                vllmUrl,
                HttpMethod.POST,
                entity,
                Map.class
            );

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                Map<String, Object> result = response.getBody();

                // vLLM返回格式：{"choices": [{"message": {"content": "..."}}]}
                List<Map<String, Object>> choices = (List<Map<String, Object>>) result.get("choices");
                if (choices != null && !choices.isEmpty()) {
                    Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                    String responseText = (String) message.get("content");

                    Map<String, Object> data = new HashMap<>();
                    data.put("message", responseText);
                    data.put("model", model);
                    data.put("usage", result.get("usage"));

                    return Result.success("AI回复成功", data);
                } else {
                    return Result.error("AI服务返回格式错误");
                }
            } else {
                return Result.error("AI服务响应异常: " + response.getStatusCode());
            }
        } catch (Exception e) {
            return Result.error("AI服务调用失败: " + e.getMessage());
        }
    }

    /**
     * 检查vLLM服务状态
     */
    @GetMapping("/status")
    public Result<?> checkStatus() {
        try {
            // 检查vLLM服务健康状态（从配置的vllmUrl推导基础地址）
            String baseUrl = getVllmBaseUrl();
            ResponseEntity<String> response = restTemplate.getForEntity(baseUrl + "/health", String.class);

            if (response.getStatusCode() == HttpStatus.OK) {
                return Result.success("vLLM服务正常运行");
            } else {
                return Result.error("vLLM服务异常");
            }
        } catch (Exception e) {
            return Result.error("vLLM服务未连接: " + e.getMessage());
        }
    }

    /**
     * 获取可用模型列表
     */
    @GetMapping("/models")
    public Result<?> getModels() {
        try {
            String baseUrl = getVllmBaseUrl();
            ResponseEntity<Map> response = restTemplate.getForEntity(baseUrl + "/v1/models", Map.class);

            if (response.getStatusCode() == HttpStatus.OK) {
                Map<String, Object> result = response.getBody();
                return Result.success("获取模型列表成功", result.get("data"));
            } else {
                return Result.error("获取模型列表失败");
            }
        } catch (Exception e) {
            return Result.error("无法获取模型列表: " + e.getMessage());
        }
    }

    /**
     * 从配置的 vllmUrl 推导出基础地址（协议 + 主机 + 端口）。
     * 例如：
     *  - http://vllm:8000/v1/chat/completions -> http://vllm:8000
     *  - http://localhost:8000/v1/chat/completions -> http://localhost:8000
     */
    private String getVllmBaseUrl() {
        try {
            URI uri = URI.create(vllmUrl);
            String scheme = uri.getScheme();
            String host = uri.getHost();
            int port = uri.getPort();
            if (scheme == null || host == null) {
                // 回退：按 /v1/ 截断
                int idx = vllmUrl.indexOf("/v1/");
                return idx > 0 ? vllmUrl.substring(0, idx) : vllmUrl;
            }
            return scheme + "://" + host + (port > -1 ? ":" + port : "");
        } catch (Exception ex) {
            int idx = vllmUrl.indexOf("/v1/");
            return idx > 0 ? vllmUrl.substring(0, idx) : vllmUrl;
        }
    }
}

