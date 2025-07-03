#!/bin/bash

# Azure Infrastructure Deployment Script for Product Management App
# This script creates the Azure infrastructure for the full-stack application

set -e

# Configuration
RESOURCE_GROUP_NAME="product-management-rg"
LOCATION="West US"
DEPLOYMENT_NAME="product-management-deployment"
TEMPLATE_FILE="azure-templates/main.json"
PARAMETERS_FILE="azure-templates/parameters.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Azure CLI is installed
check_azure_cli() {
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        print_status "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    print_success "Azure CLI is installed"
}

# Function to check if user is logged in to Azure
check_azure_login() {
    if ! az account show &> /dev/null; then
        print_error "You are not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    print_success "Azure login verified"
}

# Function to create resource group
create_resource_group() {
    print_status "Creating resource group: $RESOURCE_GROUP_NAME"
    
    if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_warning "Resource group $RESOURCE_GROUP_NAME already exists"
    else
        az group create \
            --name "$RESOURCE_GROUP_NAME" \
            --location "$LOCATION" \
            --output table
        print_success "Resource group created successfully"
    fi
}

# Function to validate ARM template
validate_template() {
    print_status "Validating ARM template..."
    
    az deployment group validate \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --template-file "$TEMPLATE_FILE" \
        --parameters @"$PARAMETERS_FILE" \
        --output table
    
    print_success "Template validation successful"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure..."
    
    az deployment group create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --template-file "$TEMPLATE_FILE" \
        --parameters @"$PARAMETERS_FILE" \
        --output table
    
    print_success "Infrastructure deployment completed"
}

# Function to get deployment outputs
get_deployment_outputs() {
    print_status "Retrieving deployment outputs..."
    
    SQL_SERVER_NAME=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query 'properties.outputs.sqlServerName.value' \
        --output tsv)
    
    SQL_DATABASE_NAME=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query 'properties.outputs.sqlDatabaseName.value' \
        --output tsv)
    
    WEB_APP_NAME=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query 'properties.outputs.webAppName.value' \
        --output tsv)
    
    WEB_APP_URL=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query 'properties.outputs.webAppUrl.value' \
        --output tsv)
    
    STATIC_WEB_APP_NAME=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query 'properties.outputs.staticWebAppName.value' \
        --output tsv)
    
    CONNECTION_STRING=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query 'properties.outputs.connectionString.value' \
        --output tsv)
    
    print_success "Deployment outputs retrieved"
}

# Function to configure database
configure_database() {
    print_status "Configuring database..."
    
    # Create database tables (this would typically be done via Flask migrations)
    print_status "Database configuration will be handled by the Flask application during deployment"
}

# Function to display deployment summary
display_summary() {
    echo ""
    echo "=========================================="
    echo "    INFRASTRUCTURE DEPLOYMENT COMPLETED"
    echo "=========================================="
    echo ""
    echo "Resource Group: $RESOURCE_GROUP_NAME"
    echo "Location: $LOCATION"
    echo ""
    echo "📊 SQL Database:"
    echo "  Server: $SQL_SERVER_NAME"
    echo "  Database: $SQL_DATABASE_NAME"
    echo ""
    echo "🚀 App Service:"
    echo "  Name: $WEB_APP_NAME"
    echo "  URL: $WEB_APP_URL"
    echo ""
    echo "🌐 Static Web App:"
    echo "  Name: $STATIC_WEB_APP_NAME"
    echo ""
    echo "🔗 Connection String:"
    echo "  $CONNECTION_STRING"
    echo ""
    echo "Next Steps:"
    echo "1. Configure GitHub repository for Static Web App"
    echo "2. Set up GitHub Actions workflows"
    echo "3. Deploy backend application to App Service"
    echo "4. Deploy frontend application to Static Web App"
    echo ""
    echo "GitHub Secrets to configure:"
    echo "  - AZURE_CREDENTIALS"
    echo "  - AZURE_WEBAPP_NAME: $WEB_APP_NAME"
    echo "  - AZURE_WEBAPP_PUBLISH_PROFILE"
    echo "  - DATABASE_URL"
    echo ""
}

# Function to save outputs to file
save_outputs() {
    print_status "Saving deployment outputs to file..."
    
    cat > deployment-outputs.json << EOF
{
  "resourceGroup": "$RESOURCE_GROUP_NAME",
  "location": "$LOCATION",
  "sqlServerName": "$SQL_SERVER_NAME",
  "sqlDatabaseName": "$SQL_DATABASE_NAME",
  "webAppName": "$WEB_APP_NAME",
  "webAppUrl": "$WEB_APP_URL",
  "staticWebAppName": "$STATIC_WEB_APP_NAME",
  "connectionString": "$CONNECTION_STRING"
}
EOF
    
    print_success "Deployment outputs saved to deployment-outputs.json"
}

# Main execution
main() {
    echo "=========================================="
    echo "  Product Management App Infrastructure"
    echo "=========================================="
    echo ""
    
    check_azure_cli
    check_azure_login
    create_resource_group
    validate_template
    deploy_infrastructure
    get_deployment_outputs
    configure_database
    save_outputs
    display_summary
}

# Run main function
main "$@"

