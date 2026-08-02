pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'

        // ECR registry belongs to your AWS account and region
        ECR_REGISTRY = '673611060385.dkr.ecr.us-east-1.amazonaws.com'

        // Full ECR repository URIs
        FRONTEND_REPO = "${ECR_REGISTRY}/devops-challenge-frontend"
        BACKEND_REPO  = "${ECR_REGISTRY}/devops-challenge-backend"

        // ECS resources created by Terraform
        ECS_CLUSTER      = 'devops-challenge-cluster'
        FRONTEND_SERVICE = 'devops-challenge-frontend-service'
        BACKEND_SERVICE  = 'devops-challenge-backend-service'
    }

    stages {
        stage('Checkout code') {
            steps {
                checkout scm
            }
        }

        stage('Verify required tools') {
            steps {
                sh '''
                    docker --version
                    aws --version
                '''
            }
        }

        stage('Build Docker images') {
            steps {
                sh '''
                    docker build -t frontend:latest ./frontend
                    docker build -t backend:latest ./backend
                '''
            }
        }

        stage('Authenticate to ECR') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: '05ad4dd2-3de8-4086-bdf7-b8a95faad281'
                    ]
                ]) {
                    sh '''
                        aws ecr get-login-password \
                          --region "$AWS_REGION" |
                        docker login \
                          --username AWS \
                          --password-stdin "$ECR_REGISTRY"
                    '''
                }
            }
        }

        stage('Tag and push images to ECR') {
            steps {
                sh '''
                    docker tag frontend:latest "$FRONTEND_REPO:latest"
                    docker tag backend:latest "$BACKEND_REPO:latest"

                    docker push "$FRONTEND_REPO:latest"
                    docker push "$BACKEND_REPO:latest"
                '''
            }
        }

        stage('Update ECS services') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: '05ad4dd2-3de8-4086-bdf7-b8a95faad281'
                    ]
                ]) {
                    sh '''
                        aws ecs update-service \
                          --cluster "$ECS_CLUSTER" \
                          --service "$FRONTEND_SERVICE" \
                          --force-new-deployment \
                          --region "$AWS_REGION"

                        aws ecs update-service \
                          --cluster "$ECS_CLUSTER" \
                          --service "$BACKEND_SERVICE" \
                          --force-new-deployment \
                          --region "$AWS_REGION"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Frontend and backend images were pushed, and ECS deployments were started.'
        }

        failure {
            echo 'The pipeline failed. Check the console output for the failed stage.'
        }

        always {
            cleanWs()
        }
    }
}
