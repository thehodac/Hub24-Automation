// Cloudbees / Jenkins declarative pipeline for HUB24 Playwright automation.
//
// Runs the regression suite inside the official Playwright Docker image
// (browsers pre-installed, so no `playwright install` download needed) and
// publishes JUnit results + the HTML report.
//
// One-time setup in Cloudbees:
//   - Add a "Username with password" credential, id: hub24-login
//   - (optional) Add a "Secret text" credential, id: chromatic-project-token
//   - Point BASE_URL at the HUB24 environment via the build parameter below.

pipeline {
  agent {
    docker {
      // Keep this version in sync with @playwright/test in package.json.
      image 'mcr.microsoft.com/playwright:v1.49.0-jammy'
      args '-u root:root --ipc=host'
    }
  }

  parameters {
    string(name: 'BASE_URL', defaultValue: 'https://uat.hub24.example',
           description: 'HUB24 environment under test')
    choice(name: 'TEST_COMMAND',
           choices: ['npm run test:e2e', 'npm test', 'npm run test:a11y', 'npm run bdd'],
           description: 'Which suite to run')
  }

  options {
    timeout(time: 30, unit: 'MINUTES')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  environment {
    CI = 'true'
    BASE_URL = "${params.BASE_URL}"
    // "Username with password" credential -> HUB24_LOGIN_USR / HUB24_LOGIN_PSW
    HUB24_LOGIN = credentials('hub24-login')
    // Expose under the names the tests expect:
    TEST_USER = "${HUB24_LOGIN_USR}"
    TEST_PASSWORD = "${HUB24_LOGIN_PSW}"
  }

  stages {
    stage('Install') {
      steps {
        sh 'npm ci'
      }
    }

    stage('Test') {
      steps {
        sh "${params.TEST_COMMAND}"
      }
    }
  }

  post {
    always {
      // Test results for the Cloudbees "Tests" tab + trend graph.
      junit testResults: 'results/junit.xml', allowEmptyResults: true
      // Keep the rich HTML report + traces/screenshots as build artifacts.
      archiveArtifacts artifacts: 'playwright-report/**, test-results/**',
                       allowEmptyArchive: true, fingerprint: false
    }
    cleanup {
      cleanWs()
    }
  }
}
