pipeline {
  agent any
  environment {
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
  }
  stages {
    stage('Checkout Code') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/master']],
          extensions: [
            // This copies files directly to workspace root
            [$class: 'CleanBeforeCheckout'],
            [$class: 'RelativeTargetDirectory', relativeTargetDir: '.']
          ],
          userRemoteConfigs: [[
            url: 'https://github.com/Syed-Amjad/azure-terraform-lab.git',
            credentialsId: 'your-github-credentials' // Add in Jenkins credentials
          ]]
        ])
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          ls -la  # Verify files exist
          terraform init -input=false
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -out=tfplan -input=false'
      }
    }

    stage('Manual Approval') {
      steps {
        timeout(time: 30, unit: 'MINUTES') {
          input message: 'Apply Terraform changes?', ok: 'Yes'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        sh 'terraform apply -auto-approve -input=false tfplan'
      }
    }
  }
  post {
    always {
      cleanWs()
      sh 'terraform destroy -auto-approve' // Optional: Cleanup after testing
    }
  }
}
