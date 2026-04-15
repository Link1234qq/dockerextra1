ARG JAVA_VERSION=21
ARG BUILD_JAVA_VERSION=17
FROM eclipse-temurin:${BUILD_JAVA_VERSION}-jdk-jammy AS builder

WORKDIR /opt

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

ARG PETCLINIC_REPO=https://github.com/spring-projects/spring-petclinic.git
ARG PETCLINIC_BRANCH=main

RUN git clone --depth 1 -b "${PETCLINIC_BRANCH}" "${PETCLINIC_REPO}" /opt/app-src \
    && chmod +x /opt/app-src/gradlew \
    && (cd /opt/app-src && ./gradlew bootJar --no-daemon)

FROM eclipse-temurin:${JAVA_VERSION}-jre-jammy AS runner

WORKDIR /opt

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 10001 appuser && useradd -u 10001 -g appuser appuser

COPY --chmod=744 --from=builder /opt/app-src/build/libs/spring-petclinic-4.0.0-SNAPSHOT.jar /opt/app.jar

USER appuser
ENV SPRING_PROFILES_ACTIVE=default

EXPOSE 8080

ENTRYPOINT ["java"]

CMD ["-jar", "/opt/app.jar"]
