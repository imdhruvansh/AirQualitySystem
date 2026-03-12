pipeline {
    agent any

    stages {

        stage('Install Python') {
            steps {
                sh '''
                apt-get update
                apt-get install -y python3 python3-pip
                '''
            }
        }

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
