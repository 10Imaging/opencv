node {
  // let GitHub know a build is pending
  step([$class: 'GitHubSetCommitStatusBuilder'])

  stage('Checkout') {
    checkout scm
    //sh 'git submodule update --init --recursive'
  }


  stage ('Build') {
      echo "Branch: ${env.BRANCH_NAME}"
      echo "Build#: ${env.BUILD_NUMBER}"
      echo "ID: ${env.CHANGE_ID}"
      echo "Author: ${env.CHANGE_AUTHOR}"
      sh "./build.sh clean"
  }

  //tell Jenkins to archive the apks
  stage ('Archive') {
    step([$class: 'ArtifactArchiver', artifacts: 'app/build/outputs/apk/*.apk', fingerprint: true])
  }
  /*
  stage ('Upload To Fabric') {
    sh "./gradlew crashlyticsUploadDistribution${flavor}Debug  -PBUILD_NUMBER=${env.BUILD_NUMBER}"
  } */
}
