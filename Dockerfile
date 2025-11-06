# --- Build Stage ---
# Nutzt ein volles Maven & JDK Image, um die App zu bauen
FROM maven:3.9-eclipse-temurin-17 AS build

# Setzt das Arbeitsverzeichnis im Container
WORKDIR /app

# Kopiert erst die pom.xml und lädt Dependencies herunter.
# Das nutzt den Docker-Cache, solange sich die pom.xml nicht ändert.
COPY pom.xml .
RUN mvn dependency:go-offline

# Kopiert den restlichen Source Code
COPY src ./src

# Baut die Anwendung und überspringt die Tests (wurden ja schon in CI gemacht)
RUN mvn package -DskipTests

# --- Runtime Stage ---
# Nutzt ein sehr schlankes JRE Image, um die App auszuführen
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Kopiert nur die gebaute JAR-Datei aus dem Build-Stage
COPY --from=build /app/target/*.jar app.jar

# Dieser Befehl wird ausgeführt, wenn der Container startet
ENTRYPOINT ["java", "-jar", "app.jar"]