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
                sh 'docker compose build --no-cache'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'docker compose up -d'
                sh 'sleep 15'
                sh 'docker compose exec -T app php artisan test'
            }
            post {
                always {
                    sh 'docker compose down -v'
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh 'chmod +x deploy.sh'
                sh './deploy.sh'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
            sh 'docker compose down -v || true'
        }
    }
}
