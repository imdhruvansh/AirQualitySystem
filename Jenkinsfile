pipeline {
    agent any

    stages {

        stage('Check Python') {
            steps {
                sh 'python3 --version'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip3 install -r requirements.txt'
            }
        }

        stage('Run Application') {
            steps {
                sh 'python3 app.py'
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
