pipeline {
  agent any
  environment {
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    TF_VAR_rg_suffix    = sh(script: 'echo $RANDOM', returnStdout: true).trim()
  }
  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }
    
    stage('Terraform Init') {
      steps {
        sh 'terraform init -input=false'
      }
    }
    
    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -out=tfplan -input=false'
      }
    }
    
    stage('Manual Approval') {
      when { 
        not { branch 'main' } 
      }
      steps {
        timeout(time: 30, unit: 'MINUTES') {
          input message: 'Apply Terraform changes?', ok: 'Yes'
        }
      }
    }
    
    stage('Terraform Apply') {
      steps {
        script {
          // Cleanup any previous failed state
          sh 'terraform destroy -auto-approve -target=azurerm_resource_group.lab4_rg || true'
          // Apply changes
          sh 'terraform apply -auto-approve -input=false tfplan'
        }
      }
    }
  }
  post {
    always {
      cleanWs()
    }
    failure {
      sh 'terraform destroy -auto-approve || true'
    }
  }
}
