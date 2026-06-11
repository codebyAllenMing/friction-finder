# ---- build stage：Maven 編譯出可執行 jar ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
# 先只 copy pom 抓相依，能吃 layer cache（src 改動不會重抓）
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q clean package -DskipTests

# ---- runtime stage：只留 JRE + jar，體積小 ----
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# 非 root 跑，較安全
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /app/target/*.jar app.jar
USER app
EXPOSE 8080
# 正式環境可用 JAVA_TOOL_OPTIONS 注入 heap 限制（見 plan/risks.md §2.2）
ENTRYPOINT ["java","-jar","app.jar"]
