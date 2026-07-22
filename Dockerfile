# 첫 번째 스테이지: 빌드 스테이지
FROM gradle:jdk25 AS builder

WORKDIR /app

# Gradle 설정 파일 복사
COPY build.gradle.kts .
COPY settings.gradle.kts .

# 종속성 다운로드
RUN gradle dependencies --no-daemon

# 소스 코드 및 환경 변수 파일 복사
COPY .env .
COPY src src

# 애플리케이션 빌드
RUN gradle build --no-daemon


# 두 번째 스테이지: 실행 스테이지
FROM container-registry.oracle.com/graalvm/jdk:25

WORKDIR /app

# 실행 가능한 JAR만 복사
COPY --from=builder /app/build/libs/*.jar app.jar
COPY --from=builder /app/.env .env

ENTRYPOINT ["java", "-Dspring.profiles.active=prod", "-jar", "app.jar"]