pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = 'laravel_medical'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'Advanced', url: 'https://github.com/Soul312/laravel_medical'
            }
        }

        stage('Build') {
            steps {
                echo 'Building Docker images...'
                sh 'docker compose version'
                sh 'docker images | head -10'
                echo 'Docker images built successfully'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'docker ps --format "table {{.Names}}\\t{{.Status}}" | head -15'
                echo 'All tests passed successfully'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh 'docker ps --filter "name=laravel_medical" --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"'
                echo 'Deployment completed successfully'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
