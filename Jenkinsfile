pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                slackSend channel: 'tcsdevops-casestudy', message: 'my-pipeline triggered'
                slackSend channel: 'tcsdevops-casestudy', message: 'Checking out project from git'
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github', url: 'https://github.com/skrameshkumartcspractice/DevOps-Demo-WebApp.git']]])
                slackSend channel: 'tcsdevops-casestudy', message: 'Checkout complete'
            }
        }
        stage('Sonarqube') {
            environment {
                scannerHome = tool 'sonarqubescanner'
            }
            steps {
                slackSend channel: 'tcsdevops-casestudy', message: 'Static code analysis is starting..'
                withSonarQubeEnv('sonarqube') {
                    sh """${scannerHome}/bin/sonar-scanner"""
                }
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
                slackSend channel: 'tcsdevops-casestudy', message: 'Static code analysis complete..'
            }
        }                
        stage('build') {
            steps {
                slackSend channel: 'tcsdevops-casestudy', message: 'Building the application..'
                sh 'mvn clean install' 
            }
            post{
                always{
                    jiraSendBuildInfo branch: 'DEV-3', site: 'tcsdevopscs.atlassian.net'
                }                
            }
        }        
        stage('Test Deploy') {
            steps {
                slackSend channel: 'tcsdevops-casestudy', message: 'Deploying the app to test..'
                sshagent(['deploy_user']) {
                    sh "scp -o StrictHostKeyChecking=no target/AVNCommunication-1.0.war azureuser@52.183.96.227:/var/lib/tomcat8/webapps/QAWebapp.war"
                    sh "scp -o StrictHostKeyChecking=no -r target/AVNCommunication-1.0 azureuser@52.183.96.227:/var/lib/tomcat8/webapps/QAWebapp"                     
                }
            }
            post{
                always{
                    jiraAddComment comment: "Deploy to Test was successful ${env.JOB_NAME} ${BUILD_NUMBER}", idOrKey: 'DEV-3', site: 'jira'
                    jiraSendDeploymentInfo environmentId: 'us-prod-1', environmentName: 'us-prod-1', environmentType: 'testing', serviceIds: [''], site: 'tcsdevopscs.atlassian.net', state: 'successful'
                }
            }            
        }                
        stage('Artifactory') {
            steps {
                slackSend channel: 'tcsdevops-casestudy', message: 'Archiving the artifacts..'
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
                slackSend channel: 'tcsdevops-casestudy', message: 'Running UI test on Test machine..'
                sh 'mvn -f functionaltest/pom.xml test'
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\functionaltest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'UI Test Report', reportTitles: ''])
            }
        }           
        // stage('Performance Test'){
        //     steps{
        //         slackSend channel: 'tcsdevops-casestudy', message: 'Running performance testing on Test Machine..'        
        //         blazeMeterTest credentialsId: 'Blazemeter', testId: '8488353.taurus', workspaceId: '646652'
        //     }
        // }                
        stage('Prod Deploy') {
            steps {
                slackSend channel: 'tcsdevops-casestudy', message: 'Deploying the app to Prod..'
                sshagent(['deploy_user_prod']) {
                    sh "scp -o StrictHostKeyChecking=no target/AVNCommunication-1.0.war azureuser@168.62.164.231:/var/lib/tomcat8/webapps/ProdWebapp.war"
                    sh "scp -o StrictHostKeyChecking=no -r target/AVNCommunication-1.0 azureuser@168.62.164.231:/var/lib/tomcat8/webapps/ProdWebapp"                     
                }
            }
            post{
                always{
                    jiraAddComment comment: "Deploy to Prod was successful ${JOB_NAME} ${BUILD_NUMBER}", idOrKey: 'DEV-3', site: 'jira'
                    jiraSendDeploymentInfo environmentId: 'us-prod-1', environmentName: 'us-prod-1', environmentType: 'production', serviceIds: [''], site: 'tcsdevopscs.atlassian.net', state: 'successful'
                }
            }            
        }                                          
        stage('Sanity test') {
            steps {
                slackSend channel: 'tcsdevops-casestudy', message: 'performing Sanity test in Prod..'
                sh 'mvn -f Acceptancetest/pom.xml test'
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '\\Acceptancetest\\target\\surefire-reports', reportFiles: 'index.html', reportName: 'Sanity Test Report', reportTitles: ''])
            }
        }        
    }
    post{
        success {
            slackSend channel: 'tcsdevops-casestudy', message: 'Successfull tests and deployment in Test and Prod servers'
        }
    }
}
