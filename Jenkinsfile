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
                stage("Appp") {
                    agent {
                        dockerfile {
                            filename 'Dockerfile.builder'
                        }
                    }
                    steps {
                        sh 'mvn clean install'
                        stash name: 'artifacts', includes: 'target/magisterka-0.0.1-SNAPSHOT.jar,'
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
                            unstash 'artifacts'
                            image = docker.build("lynx99/magisterka:$VERSION", "-f Dockerfile .")
                        }
                    }
                }
            }
        }
        stage('Push Docker images') {
            parallel {
                stage("App") {
                    steps {
                        script {
                            docker.withRegistry('https://registry-1.docker.io/v1', 'hub') {
                                image.push()
                            }
                        }
                    }
                }
            }
        }
        stage("Deploy") {
            agent any
            stages {
                stage("App") {
                    steps {
                        withCredentials([file(credentialsId: 'K8s', variable: 'KUBECONFIG')]) {
                            sh """helm list -a"""
                        }
                    }
                }
            }
        }
    }
}