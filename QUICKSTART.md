# Quick Setup Guide - Product Management App

## Prerequisites (5 minutes)

1. **Azure Subscription** - Active Azure subscription with Contributor permissions
2. **GitHub Account** - GitHub account for repository hosting and CI/CD
3. **Local Tools**:
   - Azure CLI (latest version)
   - Git
   - Node.js 18+ (for frontend)
   - Python 3.11+ (for backend)
   - VS Code (recommended)

## Quick Start (6 Steps - 30 minutes)

### Step 1: Clone and Setup Repository
```bash
# Clone this repository
git clone <your-repo-url>
cd product-management-app

# Login to Azure
az login
```

### Step 2: Deploy Azure Infrastructure
```bash
# Run the automated infrastructure deployment
./scripts/deploy-infrastructure.sh
```

This script will:
- Create Azure resource group
- Deploy Azure SQL Database
- Deploy Azure App Service
- Deploy Azure Static Web Apps
- Configure all necessary settings

**Important**: Save the output values (Web App name, connection strings, etc.)

### Step 3: Configure GitHub Secrets
In your GitHub repository, go to Settings > Secrets and variables > Actions, and add:

**Required Secrets:**
- **`AZURE_CREDENTIALS`**: Service principal JSON (see below)
- **`SQL_ADMIN_PASSWORD`**: Your SQL Server admin password
- **`AZURE_WEBAPP_NAME`**: App Service name from Step 2
- **`AZURE_STATIC_WEB_APPS_API_TOKEN`**: Static Web App deployment token

**Create Service Principal:**
```bash
az ad sp create-for-rbac --name "product-management-deploy" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/product-management-rg \
  --sdk-auth
```

### Step 4: Test Local Development
```bash
# Start backend (Terminal 1)
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python src/main.py

# Start frontend (Terminal 2)
cd frontend
npm install
npm run dev
```

Visit `http://localhost:5173` to test the application locally.

### Step 5: Deploy to Azure
```bash
# Push to main branch to trigger deployments
git add .
git commit -m "Initial deployment"
git push origin main
```

This will automatically trigger:
- Backend deployment to Azure App Service
- Frontend deployment to Azure Static Web Apps

### Step 6: Verify Deployment
1. Check GitHub Actions tab for deployment status
2. Visit your Azure Static Web Apps URL
3. Test the application functionality

## Manual Infrastructure Setup (Alternative)

If you prefer to use GitHub Actions for infrastructure:

1. Set up GitHub Secrets first (Step 3 above)
2. Go to Actions tab in your repository
3. Run "Provision Azure Infrastructure" workflow manually
4. Follow the prompts and wait for completion
5. Update additional secrets with output values

## Environment Configuration

### Local Development
- Backend runs on `http://localhost:5000`
- Frontend runs on `http://localhost:5173`
- Uses SQLite database for local development

### Production
- Backend: `https://{your-app-name}.azurewebsites.net`
- Frontend: `https://{your-static-app}.azurestaticapps.net`
- Uses Azure SQL Database

## Common Commands

### Backend Development
```bash
cd backend
source venv/bin/activate
python src/main.py                    # Start development server
pip install <package>                 # Install new package
pip freeze > requirements.txt         # Update requirements
```

### Frontend Development
```bash
cd frontend
npm run dev                          # Start development server
npm run build                       # Build for production
npm install <package>               # Install new package
```

### Azure Management
```bash
az group list                       # List resource groups
az webapp list                      # List web apps
az sql db list --server <server>    # List databases
az staticwebapp list                # List static web apps
```

## Troubleshooting Quick Fixes

### Backend Issues
```bash
# Check if backend is running
curl http://localhost:5000/api/health

# Check Azure App Service logs
az webapp log tail --name <app-name> --resource-group product-management-rg
```

### Frontend Issues
```bash
# Clear npm cache
npm cache clean --force

# Rebuild node_modules
rm -rf node_modules package-lock.json
npm install
```

### Database Issues
```bash
# Test database connection
az sql db show --name productmgmt-db --server <server-name> --resource-group product-management-rg

# Check firewall rules
az sql server firewall-rule list --server <server-name> --resource-group product-management-rg
```

### GitHub Actions Issues
- Check GitHub Secrets are correctly set
- Verify Azure credentials have proper permissions
- Review workflow logs for specific error messages

## Resource Cleanup

To delete all Azure resources when done:
```bash
az group delete --name product-management-rg --yes --no-wait
```

## Next Steps

1. **Customize the Application**:
   - Add new product fields
   - Implement user authentication
   - Add product categories

2. **Enhance CI/CD**:
   - Add automated testing
   - Implement staging environments
   - Add deployment approvals

3. **Scale and Optimize**:
   - Configure auto-scaling
   - Add caching layers
   - Implement monitoring

4. **Security Enhancements**:
   - Add Azure AD authentication
   - Implement API rate limiting
   - Configure network security

## Support

- Check the full README.md for detailed documentation
- Review troubleshooting section for common issues
- Use GitHub Issues for questions and bug reports

