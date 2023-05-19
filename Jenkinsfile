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
        stage('Package Helm Chart') {
            failFast true
            parallel {
                stage('Repository') {
                    agent {
                        dockerfile {
                            filename 'Dockerfile.builder'
                        }
                    }
                    steps {
                        sh 'HELM_CHART_NAME=magisterka ./helm_package.sh'
                        stash name: 'chart', includes: "magisterka-${VERSION}.tgz"
                    }
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
                        sh './build-repository.sh'
                        stash name: 'repository-artifacts', includes: 'alfresco-custom-modules-platform/target/alfresco-custom-modules-platform-1.0-SNAPSHOT.amp,alfresco-localisation-tools/target/alfresco-pl.jar'
                    }
                }
            }
        }
        stage('Build Docker') {
            failFast true
            parallel {
                stage("Repository") {
                    steps {
                        script {
                            unstash 'repository-artifacts'
                            repositoryImage = docker.build("artifacts.nvtvt.com/alfresco-content-services:$VERSION", "-f Dockerfile.repository .")
                        }
                    }
                }
            }
        }
        stage('Push Docker images') {
            parallel {
                stage("Repository") {
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
                stage("Repository") {
                    steps {
                        withCredentials([usernamePassword(credentialsId: ARTIFACTORY_CREDENTIALS_NAME, usernameVariable: 'username', passwordVariable: 'password')]) {
                            sh "helm repo add artifactory $HELM_REPOSITORY --username $username --password $password"
                        }
                        withKubeConfig([credentialsId: KUBE_SERVICE_ACCOUNT_CREDENTIALS_NAME, serverUrl: KUBE_API]) {
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