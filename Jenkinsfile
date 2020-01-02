#!/usr/bin/env groovy

pipeline {

    triggers { bitbucketPush() }
    
    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
    }
    
    environment {
        DOCKER_REGISTRY     = "docker-registry.myplateform.com"
        DOCKER_IMAGE_NAME   = "sb-docker"
        DOCKER_IMAGE        = "${DOCKER_REGISTRY}/lab/${DOCKER_IMAGE_NAME}"
    }
    
    agent {
        label 'maven-3.5' 
    }
 
    stages {
    
        stage('Git Checkout') {
            steps {
                checkout scm
                script {
                    projectName = sh(returnStdout: true, script: "git config --local remote.origin.url|sed -n 's#.*/\\([^.]*\\)\\.git#\\1#p'").trim()
                    echo "Project name: ${projectName}"
                }
            }
        }
     
        stage('Initialize vars') {
            steps{
                script {
                    env.BRANCH_NAME = sh(script: "git name-rev --name-only HEAD | tr -d '\n'", returnStdout: true)
                    env.COMMIT_ID = sh(script: "git rev-parse HEAD | tr -d '\n'", returnStdout: true)
                    def pom = readMavenPom file: "./pom.xml"
                    env.project_version = pom.version
                    echo "BRANCH NAME: ${env.BRANCH_NAME}"
                    echo "Building Basket Modules : version ${env.project_version} with commitId ${env.COMMIT_ID}"
                }
            }
        }   


        stage('Compilation and Analysis') {
            failFast true
            parallel {

                stage('Compilation') {
                    steps{
                        mvn("-B -DskipTests clean install")
                    }
                }  

                stage('Static Analysis') {
                    stages {
                        stage('Checkstyle') {
                            steps {     
                                
                                mvn("checkstyle:checkstyle")                   

                                step([$class: 'CheckStylePublisher', canRunOnFailed: true, defaultEncoding: '', healthy: '100', 
                                     pattern: '**/target/checkstyle-result.xml', unHealthy: '90', useStableBuildAsReference: true])                                                                           
                            }
                            
                        }  
                    } 
                }
            }
        }

        stage('Unit Testing') {
            steps {   
                script {
                    try {
                        mvn("org.jacoco:jacoco-maven-plugin:prepare-agent@preTest surefire:test org.jacoco:jacoco-maven-plugin:report@postTest")                    
                    } finally {
                        step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*Test.xml'])
                    }           
                }                                                                           
            }
        }

       
        stage('Deploy to Nexus') {
            steps {
                mvn("-B deploy -DskipTests -Dsonar.scm.desabled=true")               
            }
            post{
                success {
                    archiveArtifacts artifacts: "**/target/*.jar", fingerprint: true
                }
            }
        }
        
        stage("Build Docker Image") {
            steps{
                sh """
                cd tracking-server
                docker build --build-arg JAR_FILE=${DOCKER_IMAGE_NAME}:${env.project_version} -t ${DOCKER_IMAGE_NAME}:${env.project_version} .
                docker image ls ${DOCKER_IMAGE_NAME}
                """
            }
        }


        stage("Push Image to Docker Registry") {
            steps{
                 withCredentials([usernamePassword(credentialsId: 'docker-rg-credentials', passwordVariable: 'registry_password', usernameVariable: 'registry_user')]) {
                    sh """
                        docker login --username ${registry_user} --password ${registry_password} ${DOCKER_REGISTRY}
                        DOCKER_IMAGE_TAG = ${DOCKER_IMAGE}:${env.project_version}
                        docker tag ${DOCKER_IMAGE_NAME}:${env.project_version} ${DOCKER_IMAGE_TAG}
                        docker push ${DOCKER_IMAGE_TAG}
                    """
                }
            }
        }

    }
  
    post {
        always {
            cleanWs()
        }
        
    }
}

def mvn(maven_command){
	withMaven(maven:'Maven 3.5', mavenSettingsConfig: 'AF_MavenSettings'){
      sh("mvn ${maven_command}")
    }
}