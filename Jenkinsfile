import java.time.ZoneId
import java.time.format.DateTimeFormatter
import org.jenkinsci.plugins.workflow.steps.FlowInterruptedException

import static java.time.ZonedDateTime.now

def buildHostUser = 'jenkins'
def buildHostName = 'eid-jenkins03.dmz.local'
def deployStackName = UUID.randomUUID()
def deployHostName = 'eid-test01.dmz.local'
def deployHostUser = 'jenkins'

pipeline {
    agent none
    options {
        timeout(time: 5, unit: 'DAYS')
        disableConcurrentBuilds()
        ansiColor('xterm')
        timestamps()
    }
    stages {
        stage('Check build') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) } }
            agent {
                docker {
                    image 'maven:3.5.0-jdk-8'
                    args '--network pipeline_pipeline -v /var/jenkins_home/.ssh/known_hosts:/root/.ssh/known_hosts -u root:root'
                }
            }
            steps {
                transitionIssue env.ISSUE_STATUS_OPEN, env.ISSUE_TRANSITION_START
                ensureIssueStatusIs env.ISSUE_STATUS_IN_PROGRESS
                script {
                    currentBuild.description = "Building from commit " + readCommitId()
                    env.MAVEN_OPTS = readProperties(file: 'Jenkinsfile.properties').MAVEN_OPTS
                    env.skipDeploy = readProperties(file: 'Jenkinsfile.properties').skipDeploy
                    env.skipDocker = readProperties(file: 'Jenkinsfile.properties').skipDocker
                    if (readCommitMessage() == "ready!") {
                        env.verification = 'true'
                    }
                }
                sh "mvn clean test -B"
            }
        }
        stage('Wait for verification to start') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' } }
            steps {
                transitionIssue env.ISSUE_TRANSITION_READY_FOR_CODE_REVIEW
                waitUntilIssueStatusIs env.ISSUE_STATUS_CODE_REVIEW
            }
        }
        stage('Wait for verification slot') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' } }
            agent any
            steps {
                failIfJobIsAborted()
                sshagent(['ssh.git.difi.local']) {
                    retry(count: 1000000) {
                        sleep 10
                        sh 'pipeline/git/available-verification-slot'
                    }
                }
            }
            post {
                failure { transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK }
                aborted { transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK }
            }
        }
        stage('Prepare verification') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' } }
            environment {
                crucible = credentials('crucible')
            }
            agent any
            steps {
                script {
                    env.version = DateTimeFormatter.ofPattern('yyyy-MM-dd-HHmm').format(now(ZoneId.of('UTC'))) + "-" + readCommitId()
                    commitMessage = "${env.version}|" + issueId() + ": " + issueSummary()
                    sshagent(['ssh.git.difi.local']) {
                        verifyRevision = sh returnStdout: true, script: "pipeline/git/create-verification-revision \"${commitMessage}\""
                    }
                    sh "pipeline/create-review ${verifyRevision} ${env.crucible_USR} ${env.crucible_PSW}"
                }
            }
            post {
                failure {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
                aborted {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
            }
        }
        stage('Build Java artifacts') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' } }
            environment {
                nexus = credentials('nexus')
            }
            agent {
                docker {
                    image 'maven:3.5.0-jdk-8'
                    args '--network pipeline_pipeline -v /var/jenkins_home/.ssh/known_hosts:/root/.ssh/known_hosts -u root:root'
                }
            }
            steps {
                script {
                    checkoutVerificationBranch()
                    currentBuild.description = "Building ${env.version} from commit " + readCommitId()
                    sh "mvn versions:set -B -DnewVersion=${env.version}"
                    sh "mvn deploy -B -s settings.xml -Dmaven.stage.username=${env.nexus_USR} -Dmaven.stage.password=${env.nexus_PSW} -DaltDeploymentRepository=stage::default::http://nexus:8081/repository/maven-releases"
                }
            }
            post {
                failure {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
                aborted {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
            }
        }
        stage('Build Docker images') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' && env.skipDocker != 'true'} }
            environment {
                nexus = credentials('nexus')
            }
            agent {
                dockerfile {
                    dir 'docker'
                    args '-v /var/jenkins_home/.ssh/known_hosts:/root/.ssh/known_hosts -u root:root'
                }
            }
            steps {
                script {
                    checkoutVerificationBranch()
                    DOCKER_HOST = sh(returnStdout: true, script: 'pipeline/docker/define-docker-host-for-ssh-tunnel')
                    sshagent(['ssh.git.difi.local']) {
                        sh "DOCKER_HOST=${DOCKER_HOST} pipeline/docker/create-ssh-tunnel-for-docker-host ${buildHostUser}@${buildHostName}"
                    }
                    sh "DOCKER_TLS_VERIFY= DOCKER_HOST=${DOCKER_HOST} docker/build ${env.version} ${env.nexus_USR} ${env.nexus_PSW}"
                }
            }
            post {
                failure {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
                aborted {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
            }
        }
        stage('Deploy for verification') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' && env.skipDocker != 'true'} }
            agent {
                dockerfile {
                    dir 'docker'
                    args '-v /var/jenkins_home/.ssh/known_hosts:/root/.ssh/known_hosts -u root:root'
                }
            }
            steps {
                script {
                    checkoutVerificationBranch()
                    DOCKER_HOST = sh(returnStdout: true, script: 'pipeline/docker/define-docker-host-for-ssh-tunnel')
                    sshagent(['ssh.git.difi.local']) {
                        sh "DOCKER_HOST=${DOCKER_HOST} pipeline/docker/create-ssh-tunnel-for-docker-host ${deployHostUser}@${deployHostName}"
                    }
                    sh "DOCKER_TLS_VERIFY= DOCKER_HOST=${DOCKER_HOST} docker/run ${deployStackName} ${env.version}"
                    env.adminPort = port DOCKER_HOST, deployStackName, 'eid-atest-admin'
                    env.idpPort = port DOCKER_HOST, deployStackName, 'eid-atest-idp-app'
                    env.seleniumPort = port DOCKER_HOST, deployStackName, 'selenium'
                    env.dbPort = port DOCKER_HOST, deployStackName, 'eid-atest-db'
                }
            }
            post {
                always {
                    sh "pipeline/docker/cleanup-ssh-tunnel-for-docker-host"
                }
                failure {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                    sshagent(['ssh.git.difi.local']) { sh "pipeline/docker/remove-stack ${deployStackName} ${deployHostName} ${deployHostUser}" }
                }
                aborted {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                    sshagent(['ssh.git.difi.local']) { sh "pipeline/docker/remove-stack ${deployStackName} ${deployHostName} ${deployHostUser}" }
                }
            }
        }
        stage('Verify behaviour') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' && env.skipDocker != 'true'} }
            agent {
                docker {
                    image 'maven:3.5.0-jdk-8'
                    args "--network pipeline_pipeline -v /var/jenkins_home/.ssh/known_hosts:/root/.ssh/known_hosts -u root:root"
                }
            }
            steps {
                script {
                    checkoutVerificationBranch()
                    sh """
                        mvn verify -pl system-tests -PsystemTests -B\
                        -DadminDirectBaseURL=http://${deployHostName}:${env.adminPort}/idporten-admin/\
                        -DminIDOnTheFlyUrl=http://${deployHostName}:${env.idpPort}/minid_filegateway/\
                        -DseleniumUrl=http://${deployHostName}:${env.seleniumPort}/wd/hub\
                        -DdatabaseUrl=${deployHostName}:${env.dbPort}
                    """
                }
            }
            post {
                always {
                    cucumber 'system-tests/target/cucumber-report.json'
                    jiraAddComment(
                            idOrKey: issueId(),
                            comment: "Verifikasjonstester utført: [Rapport|${env.BUILD_URL}cucumber-html-reports/overview-features.html] og [byggstatus|${env.BUILD_URL}]",
                            auditLog: false
                    )
                    sshagent(['ssh.git.difi.local']) { sh "pipeline/docker/remove-stack ${deployStackName} ${deployHostName} ${deployHostUser}" }
                }
                failure {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
                aborted {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
            }
        }
        stage('Wait for code review to finish') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' } }
            steps {
                waitUntilIssueStatusIsNot env.ISSUE_STATUS_CODE_REVIEW
                script {
                    env.codeApproved = "false"
                    if (issueStatusIs(env.ISSUE_STATUS_CODE_APPROVED))
                        env.codeApproved = "true"
                }
            }
        }
        stage('Publish Java artifacts') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' } }
            agent {
                docker {
                    image 'maven:3.5.0-jdk-8'
                    args '--network pipeline_pipeline -v /var/jenkins_home/.ssh/known_hosts:/root/.ssh/known_hosts -u root:root'
                }
            }
            environment {
                artifactory = credentials('artifactory-publish')
            }
            steps {
                failIfJobIsAborted()
                script {
                    if (env.codeApproved == "false") {
                        error("Code was not approved")
                    }
                    checkoutVerificationBranch()
                    commitId = readCommitId()
                    currentBuild.description = "Publish version ${env.version} from commit ${commitId}"
                    sh "mvn versions:set -B -DnewVersion=${env.version}"
                    sh "mvn deploy -B -s settings.xml -Dmaven.release.username=${env.artifactory_USR} -Dmaven.release.password=${env.artifactory_PSW} -DskipTests=true"
                }
            }
            post {
                failure {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
                aborted {
                    deleteVerificationBranch()
                    transitionIssue env.ISSUE_STATUS_CODE_REVIEW, env.ISSUE_TRANSITION_RESUME_WORK
                }
            }
        }
        stage('Integrate code') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' } }
            agent {
                docker {
                    image 'maven:3.5.0-jdk-8'
                    args '-v /var/jenkins_home/.ssh/known_hosts:/root/.ssh/known_hosts -u root:root'
                }
            }
            steps {
                checkoutVerificationBranch()
                sshagent(['ssh.git.difi.local']) {
                    sh 'git push origin HEAD:master'
                }
            }
            post {
                always {
                    deleteVerificationBranch()
                }
                failure {
                    deleteArtifacts(env.version)
                }
                aborted {
                    deleteArtifacts(env.version)
                }
                success {
                    deleteWorkBranch()
                }
            }
        }
        stage('Wait for manual verification to start') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' && env.skipDeploy != 'true' } }
            steps {
                waitUntilIssueStatusIs env.ISSUE_STATUS_MANUAL_VERIFICATION
            }
        }
        stage('Deploy for manual verification') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' && env.skipDeploy != 'true' } }
            agent any
            steps {
                failIfJobIsAborted()
                script {
                    currentBuild.description = "Deploying ${env.version}"
                    sshagent(['ssh.git.difi.local']) {
                        properties = readProperties(file: 'Jenkinsfile.properties')
                        tagPuppetModules(env.version)
                        updateHiera('systest', env.version, properties.puppetModules)
                        updateControl('systest', env.version, properties.librarianModules)
                        def applyParametersList = []
                        for (int i = 1; i < 10; i++) {
                            String property = "puppetApply.systest.$i"
                            String applyParameters = properties.get(property)
                            if (applyParameters != null)
                                applyParametersList.add(applyParameters)
                            else break
                        }
                        deployToSystest(properties.librarianModules, applyParametersList)
                    }
                }
            }
            post {
                failure { deleteArtifacts(env.version) }
                aborted { deleteArtifacts(env.version) }
            }
        }
        stage('Wait for manual verification to finish') {
            when { expression { env.BRANCH_NAME.matches(/(work|feature|bugfix)\/(\w+-\w+)/) && env.verification == 'true' && env.skipDeploy != 'true' } }
            steps {
                waitUntilIssueStatusIsNot env.ISSUE_STATUS_MANUAL_VERIFICATION
                failIfJobIsAborted()
                ensureIssueStatusIs env.ISSUE_STATUS_MANUAL_VERIFICATION_OK
            }
            post {
                failure { deleteArtifacts(env.version) }
                aborted { deleteArtifacts(env.version) }
            }
        }
    }
    post {
        success {
            echo "Success"
            notifySuccess()
        }
        unstable {
            echo "Unstable"
            notifyUnstable()
        }
        failure {
            echo "Failure"
            notifyFailed()
        }
        aborted {
            echo "Aborted"
            notifyFailed()
        }
        always {
            echo "Build finished"
        }
    }
}

def checkoutVerificationBranch() {
    sh "git checkout verify/\${BRANCH_NAME}"
    sh "git reset --hard origin/verify/\${BRANCH_NAME}"
}

def deleteVerificationBranch() {
    sshagent(['ssh.git.difi.local']) { sh "git push origin --delete verify/\${BRANCH_NAME}" }
}

def deleteWorkBranch() {
    sshagent(['ssh.git.difi.local']) { sh "git push origin --delete \${BRANCH_NAME}" }
}

def failIfJobIsAborted() {
    if (env.jobAborted == 'true')
        error('Job was aborted')
}

boolean issueStatusIs(def targetStatus) {
    return issueStatus() == targetStatus
}

def waitUntilIssueStatusIs(def targetStatus) {
    env.jobAborted = 'false'
    try {
        retry(count: 1000000) {
            if (!issueStatusIs(targetStatus)) {
                sleep 10
                error "Waiting until issue status is ${targetStatus}..."
            }
        }
    } catch (FlowInterruptedException e) {
        env.jobAborted = "true"
    }
}

def waitUntilIssueStatusIsNot(def targetStatus) {
    env.jobAborted = 'false'
    try {
        retry(count: 1000000) {
            if (issueStatusIs(targetStatus)) {
                sleep 10
                error "Waiting until issue status is not ${targetStatus}..."
            }
        }
    } catch (FlowInterruptedException e) {
        env.jobAborted = "true"
    }
}

def port(dockerHost, deployStackName, serviceName) {
    try {
        return sh(returnStdout: true, script: "DOCKER_TLS_VERIFY= DOCKER_HOST=${dockerHost} pipeline/docker/get-port ${deployStackName} ${serviceName}").trim()
    } catch (Exception ignored) {
        echo "No port found for service ${serviceName}: " + ignored.toString()
        return "not_found"
    }
}

def deployToSystest(librarianModules, applyParametersList) {
    sh("pipeline/puppet-update-master systest ${librarianModules}")
    applyParametersList.each {
        sh("pipeline/puppet-apply ${it}")
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

def tagPuppetModules(version) {
    println "Tagging Puppet modules with ${version}"
    sh "pipeline/puppet-tag-modules ${version}"
}

def updateHiera(environment, version, modules) {
    println "Updating version of modules ${modules} to ${version} for environment ${environment}"
    sh("pipeline/puppet-update-hiera ${environment} ${version} ${env.JOB_NAME} ${env.BUILD_NUMBER} ${modules} ")
}

def updateControl(environment, version, modules) {
    println "Updating version of modules ${modules} to ${version} for environment ${environment}"
    sh("pipeline/puppet-update-control ${environment} ${version} ${env.JOB_NAME} ${env.BUILD_NUMBER} ${modules} ")
}

boolean isPreviousBuildFailOrUnstable() {
    if(!hudson.model.Result.SUCCESS.equals(currentBuild.rawBuild.getPreviousBuild()?.getResult())) {
        return true
    }
    return false
}

def issueId() {
    return env.BRANCH_NAME.tokenize('/')[-1]
}

def transitionIssue(def transitionId) {
    jiraTransitionIssue idOrKey: issueId(), input: [transition: [id: transitionId]]
}

def transitionIssue(def sourceStatus, def transitionId) {
    if (issueStatusIs(sourceStatus))
        transitionIssue transitionId
}

def ensureIssueStatusIs(def issueStatus) {
    if (!issueStatusIs(issueStatus))
        error "Issue status is not ${issueStatus}"
}

String issueStatus() {
    return jiraGetIssue(idOrKey: issueId()).data.fields['status']['id']
}

String issueSummary() {
    return jiraGetIssue(idOrKey: issueId()).data.fields['summary']
}

def readCommitId() {
    return sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)
}

def readCommitMessage() {
    return sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
}


def deleteArtifacts(def version) {
    try {
        echo "Deleting artifacts for rejected version ${version}"
        url = "http://eid-artifactory.dmz.local:8080/artifactory/api/search/gavc?v=${version}&repos=libs-release-local"
        httpresponse = httpRequest url
        response = new groovy.json.JsonSlurperClassic().parseText(httpresponse.content)
        Set<String> toDel = new HashSet<String>()
        response['results'].each{ item ->
            toDel.add(item['uri'].minus('api/storage/').minus(item['uri'].tokenize("/").last()))
        }
        withCredentials([string(credentialsId: 'artifactory', variable: 'artifactory')]) {
            toDel.each{ item ->
                try {
                    httpRequest customHeaders: [[name: 'X-JFrog-Art-Api', value: artifactory, maskValue: true]], httpMode: 'DELETE', url: item
                }
                catch (Exception e){
                    echo e.toString()
                }
            }
        }
    } catch (Exception e) {
        echo e.toString()
    }
}