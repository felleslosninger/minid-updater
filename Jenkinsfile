#!groovy
import java.time.ZoneId
import java.time.format.DateTimeFormatter

import static java.time.ZonedDateTime.now

pipeline {
    agent any
    stages {
        stage('Branch build') {
            steps {
                script {
                    env.version = DateTimeFormatter.ofPattern('yyyy-MM-dd-HHmm').format(now(ZoneId.of('UTC')))
                    env.commitId = readCommitId()
                    env.commitMessage = readCommitMessage()
                    if (isQuickBuild()) {
                        currentBuild.description = "Building: ${env.commitId}"
                        sh 'mvn clean verify'
                    }
                }
            }
        }
        stage('Release build') {
            steps {
                script {
                    if (isDeployBuild()) {
                        currentBuild.description = "Release: ${env.version}"
                        sh "mvn versions:set -DnewVersion=${env.version}"
                        sh 'mvn clean deploy'
                        step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*.xml'])
                        step([$class: 'ArtifactArchiver', artifacts: '**/target/*.jar', fingerprint: true])
                    }
                    else {
                        echo 'Build is not for deploy'
                    }
                }
            }
        }
    }
    post {
        changed {
            notifySuccess()
        }
        unstable {
            notifyUnstable()
        }
        failure {
            notifyFailed()
        }
        always {
            echo "Finish building ${env.commitMessage}"
        }
    }
}

def notifyFailed() {
    emailext (
            subject: "FAILED: '${env.JOB_NAME}'",
            body: """<p>FAILED: Bygg '${env.JOB_NAME} [${env.BUILD_NUMBER}]' feilet.</p>
            <p><b>Konsoll output:</b><br/>
            <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
            recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']]
    )
}

def notifyUnstable() {
    emailext (
            subject: "UNSTABLE: '${env.JOB_NAME}'",
            body: """<p>UNSTABLE: Bygg '${env.JOB_NAME} [${env.BUILD_NUMBER}]' er ustabilt.</p>
            <p><b>Konsoll output:</b><br/>
            <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
            recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']]
    )
}

def notifySuccess() {
    if (isPreviousBuildFailOrUnstable()) {
        emailext (
                subject: "SUCCESS: '${env.JOB_NAME}'",
                body: """<p>SUCCESS: Bygg '${env.JOB_NAME} [${env.BUILD_NUMBER}]' er oppe og snurrer igjen.</p>""",
                recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']]
        )
    }
}

boolean isPreviousBuildFailOrUnstable() {
    if(!hudson.model.Result.SUCCESS.equals(currentBuild.rawBuild.getPreviousBuild()?.getResult())) {
        return true
    }
    return false
}

boolean isDeployBuild() {
    return env.BRANCH_NAME.matches('master')
}

boolean isQuickBuild() {
    return env.BRANCH_NAME.matches(/(feature|bugfix)\/(\w+-\w+)/)
}

String readCommitId() {
    return sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
}

String readCommitMessage() {
    return sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
}