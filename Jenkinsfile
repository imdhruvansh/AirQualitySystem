pipeline {
    agent {
        docker {
            image 'python:3.10'
        }
    }

    stages {

        stage('Check Python') {
            steps {
                sh 'python --version'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
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
            echo 'Air Quality System Pipeline Successful'
        }
        failure {
            echo 'Pipeline Failed'
        }
    }
}
