#!/usr/bin/env groovy

if (env.BRANCH_NAME == 'master') {
  properties (
    [
      pipelineTriggers([cron('0 21 * * *')])
    ]
  )
}

generic = new brussels.bric.Generic()
make = new brussels.bric.Make()

node ('middleware') {
  stage('Checkout') {
    checkout scm
  }
  generic.time("test", {
    make.make(target: 'test')
  })
}
