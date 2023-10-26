pipeline{
    agent any 
    environment{
        VERSION = "${env.BUILD_ID}"
    }
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
                timeout(time:1, unit: 'HOURS'){
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }

            }
        }
        }
        stage("docker build and docker push"){
        steps{
            script{

                withCredentials([string(credentialsId: 'nex_docker_pass', variable: 'docker_password')]) {
                 sh '''
                docker build -t 34.207.194.87:8083/473tech:${VERSION} .
                docker login -u admin -p $docker_password  34.207.194.87:8083
                docker push 34.207.194.87:8083/473tech:${VERSION}
                docker rmi 34.207.194.87:8083/473tech:${VERSION}
                '''
            }   
            }
        }
    }
    stage("Push helm chart to Nexus"){
        steps{
            script{

                withCredentials([string(credentialsId: 'nex_docker_pass', variable: 'docker_password')]) {
                 sh '''
                 helmversion=$(helm show chart myapp |grep version|sed  s/version://g|tr -d ' ')
                 tar -czvf myapp-${helmversion}.tgz myapp/
                curl -u admin:$docker_password http://34.207.194.87:8081/repository/helm-hosted/ --upload-file myapp-${helmversion}.tgz -v
                '''
                }   
            }
        }
    }

   stage('Deploy to K8s') {
      steps{
        script {
          //sh "sed -i 's,TEST_IMAGE_NAME,harshmanvar/node-web-app:$BUILD_NUMBER,' deployment.yaml"
         // sh "cat deployment.yaml"
         
         sh "helm upgrade --install --set image.repository=34.207.194.87:8083/473tech --set image.tag=${VERSION} demo myapp"
          sh "~/bin/kubectl --kubeconfig=/var/lib/jenkins/.kube/config get pods"
          sh "~/bin/kubectl --kubeconfig=/var/lib/jenkins/.kube/config apply -f k8s.yaml"
        }
      }
    }
    
    }
    post{
        always{
            emailext body: '<h1>This is to inform you that your build successfully passed" </h1>', subject: 'Build Succeeded ', to: 'gotolulope@gmail.com'
        }
        success{
           mail bcc: '', body: '<br> BUILD PASSED<br> ', cc: '', from: '', replyTo: '', subject: 'BUILD PASSED', to: 'gotolulope@gmail.com'
        }
        failure{
            mail bcc: '', body: '<br> BUILD PASSED<br> ', cc: '', from: '', replyTo: '', subject: 'BUILD PASSED', to: 'gotolulope@gmail.com'
        }
    }
    
}