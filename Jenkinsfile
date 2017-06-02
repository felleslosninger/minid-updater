#!groovy
import java.time.ZoneId
import java.time.format.DateTimeFormatter

import static java.time.ZonedDateTime.now

pipeline {
    agent none
    options {
        timeout(time: 5, unit: 'DAYS')
    }
    stages {
        stage('Branch build') {
            agent any
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
            agent any
            when { branch 'master' }
            steps {
                script {
                    currentBuild.description = "Release: ${env.version}"
                    sh "mvn versions:set -DnewVersion=${env.version}"
                    sh 'mvn clean deploy -B'
                    junit '**/target/surefire-reports/TEST-*.xml'
                    tagPuppetModules("${env.version}")
                }
            }
        }
        stage('Deploy to atest') {
            agent any
            when { branch 'master' }
            steps {
                script {
                    updateHiera('atest', "${env.version}")
                    updateControl('atest', "${env.version}")
                    deployToAtest()
                }
            }
        }
        stage('Test system on atest') {
            agent any
            when { branch 'master' }
            steps {
                script {
                    testSystem('atest')
                }
            }
        }
        stage('Confirm release') {
            when { branch 'master' }
            steps {
                input message: "Confirm release of version ${env.version} to systest"
            }
        }
        stage('Deploy to systest') {
            agent any
            when { branch 'master' }
            steps {
                script {
                    updateHiera('systest', "${env.version}")
                    updateControl('systest', "${env.version}")
                    deployToSystest()
                }
            }
        }
        stage('Test system on systest01') {
            agent any
            when { branch 'master' }
            steps {
                script {
                    testSystem('systest')
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

def testSystem(String profile) {
    git(url: 'git@git.difi.local:eid', branch: 'develop')
    sh("cd cucumber/cucumber-test-multienv && mvn verify -P ${profile}")
}

def tagPuppetModules(String tagName) {
    sh("""
       #!/usr/bin/env bash
       local workDirectory=\$(mktemp -d /tmp/XXXXXXXXXXXX)
       git clone --bare git@eid-gitlab.dmz.local:puppet/puppet_modules.git \${workDirectory}
       cd \${workDirectory}
       git tag ${tagName}
       git push --tag
       cd -
       rm -rf \${workDirectory}
       """)
}

def deployToAtest() {
    sh("pipeline/puppet-kick-atest.sh")
}

def deployToSystest() {
    sh("pipeline/puppet-kick-systest.sh")
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

def updateHiera(environment, version) {
    modules='minid_updater'
    println "Updating version of modules ${modules} to ${version} for environment ${environment}"
    sh("""
        #!/usr/bin/env bash
        local workDirectory=\$(mktemp -d /tmp/XXXXXXXXXXXX)
        local platformFile=nodes/${environment}/platform.yaml
        git clone git@eid-gitlab.dmz.local:puppet/puppet_hiera.git \${workDirectory}
        cd \${workDirectory}
        for module in ${modules}; do
            sed -i "s/\\(\${module}::component_version:\\s\\).*/\\1\\"${version}\\"/i" \${platformFile}
        done
        git add \${platformFile}
        git config --local user.name 'Jenkins'
        git config --local user.email 'jenkins@difi.no'
        git commit -m "[${env.JOB_NAME} #${env.BUILD_NUMBER}]: Updated version of modules ${modules} to ${version} for environment ${environment}" \${platformFile}       
        git push
        cd -
        rm -rf \${workDirectory}
    """)
}

def updateControl(environment, version) {
    modules='DIFI-minid_updater'
    println "Updating version of modules ${modules} to ${version} for environment ${environment}"
    sh("""
        #!/usr/bin/env bash
        local workDirectory=\$(mktemp -d /tmp/XXXXXXXXXXXX)
        local puppetFile=Puppetfile
        git clone -b ${environment} --single-branch git@eid-gitlab.dmz.local:puppet/puppet_control.git \${workDirectory}
        cd \${workDirectory}
        for module in ${modules}; do
            sed -ie \"/\${module}/ s/:ref => '[^']*'/:ref => '${version}'/\" \${puppetFile}
        done
        git add \${puppetFile}
        git config --local user.name 'Jenkins'
        git config --local user.email 'jenkins@difi.no'
        git commit -m "[${env.JOB_NAME} #${env.BUILD_NUMBER}]: Updated version of modules ${modules} to ${version} for environment ${environment}" \${puppetFile}       
        git push
        cd -
        rm -rf \${workDirectory}
    """)
}

boolean isPreviousBuildFailOrUnstable() {
    if(!hudson.model.Result.SUCCESS.equals(currentBuild.rawBuild.getPreviousBuild()?.getResult())) {
        return true
    }
    return false
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