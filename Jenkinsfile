pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mayanknayak99/certifyhub-frontend"
        APP_SERVER   = "13.49.69.21"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build frontend') {
            steps {
                sh 'npm ci --legacy-peer-deps'
                sh 'npm run build'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                      docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                      docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to app-server') {
            steps {
                sshagent (credentials: ['app-server-ssh']) {
                    sh """
                      ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER} '
                        docker pull ${DOCKER_IMAGE}:latest &&
                        docker stop certifyhub || true &&
                        docker rm certifyhub || true &&
                        docker run -d --name certifyhub -p 80:80 ${DOCKER_IMAGE}:latest
                      '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}