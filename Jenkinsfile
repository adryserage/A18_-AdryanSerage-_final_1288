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
                    sh """
                        # installer gh cli si nécessaire
                        if ! command -v gh &> /dev/null; then
                            echo "installation de gh cli..."
                            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                            chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
                            echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                            apt update
                            apt install -y gh
                        fi

                        # configurer gh avec le token
                        echo \$GH_TOKEN | gh auth login --with-token

                        # créer le tag et la release
                        TAG_NAME="${ARTIFACT_NAME}_build_${BUILD_NUMBER}"
                        RELEASE_TITLE="Release ${ARTIFACT_NAME} - Build ${BUILD_NUMBER}"
                        RELEASE_NOTES="## build jenkins #${BUILD_NUMBER}

**artifacts générés:**
- ${ARTIFACT_NAME}.java - code source java
- ${ARTIFACT_NAME}.class - bytecode compilé
- ${ARTIFACT_NAME}.Dockerfile - configuration docker
- ${ARTIFACT_NAME}_image.tar - image docker complète
- ${ARTIFACT_NAME}_report.txt - rapport de build
- ${ARTIFACT_NAME}_success.txt - marqueur de succès

**image docker:** ${DOCKER_IMAGE}
**date:** \$(date)
**commit:** \$(git rev-parse HEAD)

build réussi avec succès via jenkins."

                        # créer la release avec les artifacts
                        gh release create "\$TAG_NAME" \
                            --title "\$RELEASE_TITLE" \
                            --notes "\$RELEASE_NOTES" \
                            artifacts/${ARTIFACT_NAME}.java \
                            artifacts/${ARTIFACT_NAME}.class \
                            artifacts/${ARTIFACT_NAME}.Dockerfile \
                            artifacts/${ARTIFACT_NAME}_image.tar \
                            artifacts/${ARTIFACT_NAME}_report.txt \
                            artifacts/${ARTIFACT_NAME}_success.txt

                        echo "✅ release github créée: \$TAG_NAME"
                    """
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
