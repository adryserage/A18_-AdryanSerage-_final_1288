FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY DockerDemo.java /app
RUN javac DockerDemo.java
CMD ["java", "DockerDemo"]