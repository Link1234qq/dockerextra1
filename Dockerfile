ARG JAVA_VERSION=21
FROM eclipse-temurin:${JAVA_VERSION}-jdk-jammy AS builder

WORKDIR /opt

COPY . .

RUN chmod +x ./gradlew && ./gradlew bootJar

ARG JAVA_VERSION=21
FROM eclipse-temurin:${JAVA_VERSION}-jre-jammy AS runner

WORKDIR /opt

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/build/libs/spring-petclinic-4.0.0-SNAPSHOT.jar /opt/app.jar

COPY --chmod=744 /opt/app.jar

USER 10001
ENV SPRING_PROFILES_ACTIVE=default

EXPOSE 8080

ENTRYPOINT ["java"]

CMD ["-jar", "/opt/app.jar"]
