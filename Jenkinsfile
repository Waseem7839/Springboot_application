pipeline {
    agent any

    tools { 
        maven 'maven' 
    }

    environment {
        // Docker / K8s
        DOCKER_IMAGE       = "waseem951/springboot_app"
        DOCKER_CREDENTIALS = "veera-docker"    // <-- set to your Jenkins creds ID for Docker Hub
        KUBE_NAMESPACE     = "team4-waseem-namespace"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Waseem7839/Springboot_application.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                  docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDENTIALS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                      echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                      docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                      docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                  # set your context or export KUBECONFIG before this step
                  # Example (replace placeholders):
                  # aws eks update-kubeconfig --region <region> --name <cluster-name>
                  # or: kubectl config use-context arn:aws:eks:<region>:<account-id>:cluster/<cluster-name>

                  kubectl apply -n ${KUBE_NAMESPACE} -f k8s/deployment.yaml
                  kubectl apply -n ${KUBE_NAMESPACE} -f k8s/service.yaml
                """
            }
        }
    }
}

