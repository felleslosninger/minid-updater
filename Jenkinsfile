pipelineWithMavenAndDocker {
    verificationEnvironment = 'eid-verification2'
    stagingEnvironment = 'eid-staging'
    stagingEnvironmentType = 'puppet2'
    productionEnvironment = 'eid-production'
    gitSshKey = 'ssh.git.difi.local'
    puppetModules = 'minid_updater'
    puppetApplyList = [' eid-systest-admin01.dmz.local baseconfig,minid_updater']
}
