pipeline {
    agent any

    stages {

        stage('Clone Repository') {
            steps {
                git 'https://github.com/imdhruvansh/AirQualitySystem.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'echo Running basic tests'
            }
        }

        stage('Run Application') {
            steps {
                sh 'python app.py'
            }
        }

    }

    post {
        success {
            echo 'Air Quality System Build Successful'
        }
        failure {
            echo 'Build Failed'
        }
    }
}
