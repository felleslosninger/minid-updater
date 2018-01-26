pipelineWithMavenAndDocker {
    verificationEnvironment = 'eid-verification'
    stagingEnvironment = 'eid-staging'
    stagingEnvironmentType = 'puppet'
    gitSshKey = 'ssh.git.difi.local'
    puppetModules = 'minid_updater'
    librarianModules = 'DIFI-minid_updater'
    puppetApplyList = [' eid-systest-admin01.dmz.local baseconfig,minid_updater']
}
