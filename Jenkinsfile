pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github', url: 'https://github.com/skrameshkumartcspractice/DevOps-Demo-WebApp.git']]])
            }
        }
        stage('Sonarqube') {
            environment {
                scannerHome = tool 'sonarqubescanner'
            }
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh """${scannerHome}/bin/sonar-scanner"""
                }
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }                
        stage('build') {
            steps {
                echo 'building the applicaiton...'
                sh 'mvn clean install' 
            }
        }        
        stage('Test Deploy') {
            steps {
                sshagent(['deploy_user']) {
                    sh "scp -o StrictHostKeyChecking=no target/AVNCommunication-1.0.war azureuser@52.183.96.227:/var/lib/tomcat8/"webapps
                }
            }
        }                
        stage('test') {
            steps {
                echo 'testing the application...'
                echo 'test demo the application...'
            }
        }        
    }
}
