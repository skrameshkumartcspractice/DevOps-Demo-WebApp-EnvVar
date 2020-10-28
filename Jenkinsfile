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
                    sh "scp -o StrictHostKeyChecking=no target/AVNCommunication-1.0.war azureuser@52.183.96.227:/var/lib/tomcat8/webapps/QAWebapp.war"
                    sh "scp -o StrictHostKeyChecking=no -r target/AVNCommunication-1.0 azureuser@52.183.96.227:/var/lib/tomcat8/webapps/QAWebapp"                     
                }
            }
        }                
        stage('Artifactory') {
            steps {
                script{
                    // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
                    def server = Artifactory.server "artifactory"
                    // Create an Artifactory Maven instance.
                    def rtMaven = Artifactory.newMavenBuild()
                    def buildInfo = Artifactory.newBuildInfo()
                
                        // Tool name from Jenkins configuration
                        rtMaven.tool = "maven"
                        // Set Artifactory repositories for dependencies resolution and artifacts deployment.
                        rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
                        rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
                        rtMaven.deployer.deployArtifacts = false
                    
                
                        buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean install -e -Dmaven.repo.local=.m2', buildInfo: buildInfo
                
                        server.publishBuildInfo buildInfo
                }
            }
        }   
        stage('selenium test') {
            steps {
                echo 'running selenium test the applicaiton...'
                sh 'mvn -f functionaltest/pom.xml test'
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\functionaltest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: ''])
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
