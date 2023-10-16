pipeline{
    agent any 
    tools{
        maven 'maven'
    }
    stages{
        stage("Sonarqube quality check"){
        steps{
            script
            {
                withSonarQubeEnv(credentialsId: 'sonar-token') {
                    sh "mvn sonar:sonar"
                }

            }
        }
        }
    }
}