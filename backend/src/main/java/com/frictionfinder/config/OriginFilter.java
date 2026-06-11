package com.frictionfinder.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 輕度來源防護：若帶了 Origin header 但不在白名單 → 403。
 * 沒帶 Origin（server-to-server，如 build-time 抓 /api/survey）→ 放行。
 * CORS 是瀏覽器端強制；這層補上伺服器端的拒絕。
 */
@Component
@Order(1)
public class OriginFilter extends OncePerRequestFilter {

    private final Set<String> allowedOrigins;

    public OriginFilter(@Value("${app.cors.allowed-origins}") String[] origins) {
        this.allowedOrigins = Arrays.stream(origins)
                .map(String::trim)
                .collect(Collectors.toUnmodifiableSet());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws ServletException, IOException {
        String origin = req.getHeader("Origin");
        if (origin != null && !allowedOrigins.contains(origin)) {
            res.setStatus(HttpServletResponse.SC_FORBIDDEN); // 403
            res.setContentType(MediaType.APPLICATION_JSON_VALUE);
            res.getWriter().write("{\"error\":\"forbiddenOrigin\"}");
            return;
        }
        chain.doFilter(req, res);
    }

    /** 只管 /api/**。 */
    @Override
    protected boolean shouldNotFilter(HttpServletRequest req) {
        return !req.getRequestURI().startsWith("/api/");
    }
}
