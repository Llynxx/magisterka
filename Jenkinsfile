#!groovy
pipeline {
    agent any
    stages {
        stage('Determine tag') {
            steps {
                script {
                    VERSION = "prod"
                }
            }
        }
        stage('Build applications') {
            failFast true
            parallel {
                stage("Repository") {
                    agent {
                        dockerfile {
                            filename 'Dockerfile.builder'
                        }
                    }
                    steps {
                        sh 'mvn clean install'
                    }
                }
            }
        }
        stage('Build Docker') {
            failFast true
            parallel {
                stage("App") {
                    steps {
                        script {
                            repositoryImage = docker.build("artifacts.nvtvt.com/alfresco-content-services:$VERSION", "-f Dockerfile.repository .")
                        }
                    }
                }
            }
        }
        stage('Push Docker images') {
            parallel {
                stage("App") {
                    when { expression { params.BUILD_REPOSITORY } }
                    steps {
                        script {
                            docker.withRegistry('https://artifacts.nvtvt.com', 'artifactory_tvn') {
                                repositoryImage.push()
                            }
                            sh(script: "docker image rm artifacts.nvtvt.com/alfresco-content-services:$VERSION")
                        }
                    }
                }
            }
        }
        stage("Deploy") {
            agent {
                dockerfile {
                    filename 'Dockerfile.builder'
                }
            }
            stages {
                stage("App") {
                    steps {
                        withKubeConfig([credentialsId: KUBE, serverUrl: "https://10.0.2.2:6443"]) {
                            sh 'helm repo update'
                            sh """helm upgrade alfresco-content-services artifactory/alfresco-content-services \
                                   --install \
                                   --namespace production \
                                   --reuse-values \
                                   --atomic \
                                   --timeout 600s"""
                        }
                    }
                }
            }
        }
    }
}