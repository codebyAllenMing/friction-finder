package com.frictionfinder.config;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 每來源 IP 限流（token bucket，純記憶體）。
 * 只套用在寫入端 POST /api/responses；讀取端 GET /api/survey 不擋。
 * 注意：記憶體桶為「每 instance 各一份」，單 replica 下夠用。
 */
@Component
@Order(2)
public class RateLimitFilter extends OncePerRequestFilter {

    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    @Value("${app.ratelimit.capacity:3}")
    private int capacity;

    @Value("${app.ratelimit.refill-per-minute:3}")
    private int refillPerMinute;

    private Bucket newBucket() {
        Bandwidth limit = Bandwidth.builder()
                .capacity(capacity)
                .refillGreedy(refillPerMinute, Duration.ofMinutes(1))
                .build();
        return Bucket.builder().addLimit(limit).build();
    }

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws ServletException, IOException {
        Bucket bucket = buckets.computeIfAbsent(clientIp(req), k -> newBucket());
        if (bucket.tryConsume(1)) {
            chain.doFilter(req, res);
        } else {
            res.setStatus(HttpStatus.TOO_MANY_REQUESTS.value()); // 429
            res.setContentType(MediaType.APPLICATION_JSON_VALUE);
            res.getWriter().write("{\"error\":\"rateLimit\"}");
        }
    }

    /** 只攔 POST /api/responses。 */
    @Override
    protected boolean shouldNotFilter(HttpServletRequest req) {
        return !("POST".equalsIgnoreCase(req.getMethod())
                && req.getRequestURI().startsWith("/api/responses"));
    }

    /** 取真實來源 IP：經 Cloudflare / ACA 反向代理時 remoteAddr 是代理，優先看 X-Forwarded-For。 */
    private String clientIp(HttpServletRequest req) {
        String xff = req.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isBlank()) {
            return xff.split(",")[0].trim();
        }
        return req.getRemoteAddr();
    }
}
