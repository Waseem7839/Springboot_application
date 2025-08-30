# ---------- Build stage ----------
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Copy wrapper + pom first for better caching
COPY mvnw pom.xml ./
COPY .mvn .mvn

# Pre-fetch dependencies (faster incremental builds)
RUN ./mvnw -q -B -DskipTests dependency:go-offline || \
    (apt-get update && apt-get install -y maven && mvn -q -B -DskipTests dependency:go-offline)

# Now copy sources and build
COPY src src
RUN ./mvnw -q -B -DskipTests package || mvn -q -B -DskipTests package

# ---------- Runtime stage ----------
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built jar (whatever its exact name is)
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
