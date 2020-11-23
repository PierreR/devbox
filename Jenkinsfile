pipeline {
  agent {
    label 'middleware'
  }
  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }
  stages {
    stage('Validate') {
      steps {
        script {
          make = new brussels.bric.Make()
          make.make(target: 'test', useNixShell: false)
        }
      }
    }
  }
  post {
    success {
      script {
        if (env.GIT_BRANCH == '20.09') {
          build job: 'cicd/docs.cicd.cirb.lan/master', wait: true
        }
      }
    }
    cleanup{
      deleteDir()
    }
  }
}
