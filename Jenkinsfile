pipeline {
  agent any
  environment {
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
  }
  stages {
    stage('Terraform Init') {
      steps {
        dir('~/azure-storage-lab') {
          sh 'terraform init'
        }
      }
    }
    stage('Terraform Plan') {
      steps {
        dir('~/azure-storage-lab') {
          sh 'terraform plan -out=tfplan'
        }
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
        dir('~/azure-storage-lab') {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }
  }
}
