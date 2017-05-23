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
                        sh 'mvn clean deploy -B'
                        step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*.xml'])
                        step([$class: 'ArtifactArchiver', artifacts: '**/target/*.jar, **/target/*.war, **/target/*.zip', fingerprint: true])
                    }
                    else {
                        echo 'Build is not for deploy'
                    }
                }
            }
        }
        stage('Deploy to atest') {
            steps {
                script {
                    if (isDeployBuild()) {
                        apikey = sh(returnStdout: true, script: 'cat /run/secrets/minidonthefly-shenzi').trim()
                        sh(returnStdout: false, script:
                            "curl -X POST http://eid-jenkins01.dmz.local:8080/job/Tag_puppet/build --user jenkins-02:${apikey} --data-urlencode json='{\"parameter\": [{\"name\":\"NEW_VERSION\", \"value\":${env.version}}]}'")
                        updateHiera('atest', "${env.version}", "${apikey}")
                        updateControl('atest', "${env.version}")
                        publishTo('atest', "${env.version}", "${apikey}")
                    }
                }
            }
        }
        stage('Deploy to systest') {
            steps {
                script {
                    if (isDeployBuild()) {
                        apikey = sh(returnStdout: true, script: 'cat /run/secrets/minidonthefly-shenzi').trim()
                        sh(returnStdout: false, script:
                            "curl -X POST http://eid-jenkins01.dmz.local:8080/job/Tag_puppet/build --user jenkins-02:${apikey} --data-urlencode json='{\"parameter\": [{\"name\":\"NEW_VERSION\", \"value\":${env.version}}]}'")
                        timeout(time: 5, unit: 'DAYS') {
                            input "Do you approve deployment of version ${version} to systest?"
                            updateHiera('systest', "${env.version}", "${apikey}")
                            updateControl('systest', "${env.version}")
                            publishTo('systest', "${env.version}", "${apikey}")
                        }
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

def updateHiera(releaseTo, version, apikey) {
    println "Updating puppet-hiera ${releaseTo} to use version ${version} for minid-updater"
    build job: '/puppet-hiera/development', parameters: [
        [$class: 'StringParameterValue', name: 'deployTo', value: releaseTo],
        [$class: 'StringParameterValue', name: 'version', value: version],
        [$class: 'StringParameterValue', name: 'modules', value: "minid_updater"]
    ]
    println "Hiera set up with version ${version}"
}

def updateControl(releaseTo, version) {
    println "Updating puppet-control ${releaseTo} to use version ${version} for minid-updater module"
    build job: "/puppet-control/${releaseTo}", parameters: [
        [$class: 'StringParameterValue', name: 'deployTo', value: releaseTo],
        [$class: 'StringParameterValue', name: 'version', value: version],
        [$class: 'StringParameterValue', name: 'modules', value: "DIFI-minid_updater"]
    ]
    println "Control set up with version ${version}"
}

def publishTo(publishTo, version, apikey) {
    sh(returnStdout: false, script:
        "curl -X POST http://eid-jenkins01.dmz.local:8080/job/Deploy/build --user jenkins-02:${apikey} --data-urlencode json='{\"parameter\": [{\"name\":\"ENVIRONMENT\", \"value\":\"${publishTo}\"}]}'"
    )
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