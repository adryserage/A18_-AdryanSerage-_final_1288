pipeline {
    agent any

    environment {
        ARTIFACT_NAME = 'A18_AdryanSerage_final_1288'
        DOCKER_IMAGE_NAME = 'a18_adryanserrage_final_1288'
        DOCKER_IMAGE = "${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
        DOCKER_IMAGE_LATEST = "${DOCKER_IMAGE_NAME}:latest"
    }

    stages {
        stage('récupération code') {
            steps {
                echo 'récupération du code source...'
                checkout scm
            }
        }

        stage('compilation java') {
            steps {
                echo 'compilation de l\'application java...'
                sh 'javac DockerDemo.java'
                sh 'java DockerDemo'
            }
        }

        stage('construction image docker') {
            steps {
                echo 'construction de l\'image docker...'
                script {
                    docker.build("${DOCKER_IMAGE}")
                    docker.build("${DOCKER_IMAGE_LATEST}")
                }
            }
        }

        stage('test image docker') {
            steps {
                echo 'test de l\'image docker...'
                sh "docker run --rm ${DOCKER_IMAGE}"
            }
        }

        stage('archivage artifacts') {
            steps {
                echo 'archivage des artifacts...'
                sh 'mkdir -p artifacts'
                sh "cp DockerDemo.java artifacts/${ARTIFACT_NAME}.java"
                sh "cp DockerDemo.class artifacts/${ARTIFACT_NAME}.class"
                sh "cp Dockerfile artifacts/${ARTIFACT_NAME}.Dockerfile"

                // sauvegarde image docker en tar
                sh "docker save ${DOCKER_IMAGE} -o artifacts/${ARTIFACT_NAME}_image.tar"

                archiveArtifacts artifacts: 'artifacts/**/*', fingerprint: true
            }
        }

        stage('génération rapports') {
            steps {
                echo 'génération du rapport de build...'
                sh """
                    echo "=== rapport de build ===" > artifacts/${ARTIFACT_NAME}_report.txt
                    echo "numéro de build: ${BUILD_NUMBER}" >> artifacts/${ARTIFACT_NAME}_report.txt
                    echo "date de build: \$(date)" >> artifacts/${ARTIFACT_NAME}_report.txt
                    echo "image docker: ${DOCKER_IMAGE}" >> artifacts/${ARTIFACT_NAME}_report.txt
                    echo "commit git: \$(git rev-parse HEAD)" >> artifacts/${ARTIFACT_NAME}_report.txt
                    echo "branche git: \$(git rev-parse --abbrev-ref HEAD)" >> artifacts/${ARTIFACT_NAME}_report.txt
                """
                archiveArtifacts artifacts: "artifacts/${ARTIFACT_NAME}_report.txt"
            }
        }

        stage('création release github') {
            steps {
                echo 'création de la release github...'
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GH_USER', passwordVariable: 'GH_TOKEN')]) {
                    sh '''
                        export GH_TOKEN="${GH_TOKEN}"

                        TAG_NAME="A18_AdryanSerage_final_1288_build_${BUILD_NUMBER}"
                        RELEASE_TITLE="release A18_AdryanSerage_final_1288 - build ${BUILD_NUMBER}"

                        echo "création du tag et de la release: ${TAG_NAME}"

                        gh release create "${TAG_NAME}" \
                            --repo adryserage/A18_-AdryanSerage-_final_1288 \
                            --title "${RELEASE_TITLE}" \
                            --notes "## build jenkins #${BUILD_NUMBER}

**artifacts générés:**
- A18_AdryanSerage_final_1288.java - code source java
- A18_AdryanSerage_final_1288.class - bytecode compilé
- A18_AdryanSerage_final_1288.Dockerfile - configuration docker
- A18_AdryanSerage_final_1288_image.tar - image docker complète
- A18_AdryanSerage_final_1288_report.txt - rapport de build

**image docker:** a18_adryanserrage_final_1288:${BUILD_NUMBER}
**commit:** $(git rev-parse HEAD)

build réussi avec succès via jenkins." \
                            artifacts/A18_AdryanSerage_final_1288.java \
                            artifacts/A18_AdryanSerage_final_1288.class \
                            artifacts/A18_AdryanSerage_final_1288.Dockerfile \
                            artifacts/A18_AdryanSerage_final_1288_image.tar \
                            artifacts/A18_AdryanSerage_final_1288_report.txt

                        echo "release github créée avec succès: ${TAG_NAME}"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'pipeline terminé avec succès!'
            sh "mkdir -p artifacts"
            sh "echo 'build ${BUILD_NUMBER} réussi' > artifacts/${ARTIFACT_NAME}_success.txt"
            archiveArtifacts artifacts: "artifacts/${ARTIFACT_NAME}_success.txt"
        }
        failure {
            echo 'échec du pipeline!'
            sh "mkdir -p artifacts"
            sh "echo 'build ${BUILD_NUMBER} échoué' > artifacts/${ARTIFACT_NAME}_failure.txt"
            archiveArtifacts artifacts: "artifacts/${ARTIFACT_NAME}_failure.txt"
        }
        always {
            echo 'nettoyage...'
            cleanWs()
        }
    }
}
