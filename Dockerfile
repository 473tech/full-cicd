FROM openjdk:11 as base
WORKDIR /app
RUN apt-get update && apt-get install -y maven
COPY . .
RUN mvn package

FROM tomcat:9
WORKDIR webapps
COPY --from=base /app/target/473tech.war .
RUN rm -rf ROOT && mv 473tech.war ROOT.war

