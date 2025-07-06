```markdown
# Azure Terraform CI/CD Pipeline

Automate Azure storage deployments using Jenkins and Terraform with GitHub webhooks.

## 🛠️ Prerequisites
- Azure account
- Jenkins server (v2.3+)
- Terraform (v1.5+)
- GitHub repo

## 🚀 Quick Start
1. Clone the repo:
   ```bash
   git clone https://github.com/Syed-Amjad/azure-terraform-lab.git
   ```

2. Configure Jenkins:
   - Install plugins: `Terraform`, `GitHub`, `Azure Credentials`
   - Add your Azure credentials as secrets

3. Set up GitHub webhook:
   ```
   URL: http://<your-jenkins-ip>:8080/github-webhook/
   Content-Type: application/json
   ```

4. Push changes to trigger pipeline:
   ```bash
   git push origin main
   ```

## 🌟 Features
- **Auto-provisioned resources**:
  - Azure Storage Account
  - Blob Containers
  - File Shares
- **Troubleshooting-ready** design
- **Parameterized** deployments

## 🔍 Troubleshooting Guide
| Error | Solution |
|-------|----------|
| Webhook timeout | Verify `/github-webhook/` endpoint |
| Terraform state lock | Add `-lock-timeout=5m` |
| Azure permissions | Assign `Contributor` role to SPN |

## 📂 Repository Structure
```
├── main.tf             # Terraform config
├── Jenkinsfile         # CI/CD pipeline
├── README.md           # This guide
└── scripts/            # Helper scripts
```

## 🤝 Contributing
PRs welcome! Follow these steps:
1. Fork the repo
2. Create a branch (`git checkout -b feature`)
3. Commit changes (`git commit -m 'Add feature'`)
4. Push to branch (`git push origin feature`)
5. Open a PR

## 📄 License
MIT
```

---

