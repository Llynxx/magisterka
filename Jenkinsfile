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
                            repositoryImage = docker.build("lynx99/magisterka:$VERSION", "-f Dockerfile .")
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
                            repositoryImage.push()
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