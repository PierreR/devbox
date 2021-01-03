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
        if ("${env.BRANCH_NAME}" == '21.05') {
          build job: 'cicd/docs.cicd.cirb.lan/master', wait: true
        }
      }
    }
    cleanup{
      deleteDir()
    }
  }
}
