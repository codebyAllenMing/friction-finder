package com.frictionfinder.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.web.context.WebServerApplicationContext;
import org.springframework.context.ApplicationContext;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * 啟動完成時印一個明顯橫幅，列出可連網址（含區網 IP），方便確認服務已就緒。
 */
@Component
public class StartupInfoLogger {

    private static final Logger log = LoggerFactory.getLogger(StartupInfoLogger.class);

    @EventListener(ApplicationReadyEvent.class)
    public void onReady(ApplicationReadyEvent event) {
        ApplicationContext ctx = event.getApplicationContext();
        Environment env = ctx.getEnvironment();

        int port = 8080;
        if (ctx instanceof WebServerApplicationContext webCtx && webCtx.getWebServer() != null) {
            port = webCtx.getWebServer().getPort();
        }

        String localIp;
        try {
            localIp = InetAddress.getLocalHost().getHostAddress();
        } catch (UnknownHostException e) {
            localIp = "localhost";
        }

        String app = env.getProperty("spring.application.name", "app");
        String[] profiles = env.getActiveProfiles();
        String profile = profiles.length == 0 ? "default" : String.join(",", profiles);
        boolean swagger = env.getProperty("springdoc.swagger-ui.enabled", Boolean.class, true);

        StringBuilder sb = new StringBuilder();
        sb.append("\n");
        sb.append("------------------------------------------------------------\n");
        sb.append("  ✅ ").append(app).append(" 已啟動（profile: ").append(profile).append("）\n");
        sb.append("  Local:    http://localhost:").append(port).append("\n");
        sb.append("  Network:  http://").append(localIp).append(":").append(port).append("\n");
        sb.append("  Health:   http://localhost:").append(port).append("/actuator/health\n");
        if (swagger) {
            sb.append("  Swagger:  http://localhost:").append(port).append("/swagger-ui.html\n");
        }
        sb.append("------------------------------------------------------------");

        log.info(sb.toString());
    }
}
