pipeline {
  agent any
  environment {
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    UNIQUE_SUFFIX       = sh(script: 'date +%s | cut -c 6-10', returnStdout:true).trim()
  }
  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }
    
    stage('Terraform Init') {
      steps {
        sh 'terraform init -input=false -upgrade'
      }
    }
    
    stage('Terraform Plan/Apply') {
      steps {
        script {
          // Generate unique names
          def RG_NAME = "lab4-rg-${env.UNIQUE_SUFFIX}"
          def STORAGE_NAME = "lab4strg${env.UNIQUE_SUFFIX}"
          
          // Auto-approve for master branch
          sh """
            terraform plan -out=tfplan -input=false \
              -var="resource_group_name=${RG_NAME}" \
              -var="storage_account_name=${STORAGE_NAME}"
            
            terraform apply -auto-approve -input=false tfplan
          """
        }
      }
    }
  }
  post {
    always {
      cleanWs()
      archiveArtifacts artifacts: '**/*.tfplan', allowEmptyArchive: true
    }
    failure {
      sh 'terraform destroy -auto-approve -var="resource_group_name=lab4-rg-${UNIQUE_SUFFIX}" || true'
    }
  }
}
