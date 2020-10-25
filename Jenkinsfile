pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github', url: 'https://github.com/skrameshkumartcspractice/DevOps-Demo-WebApp.git']]])
            }
        }
        stage('build') {
            steps {
                echo 'building the applicaiton...'
            }
        }        
        stage('test') {
            steps {
                echo 'testing the application...'
            }
        }        
    }
}
