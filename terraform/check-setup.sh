#!/bin/bash

# Script de vérification avant déploiement
# Vérifie que tous les prérequis sont en place

set -e

echo "🔍 Vérification de l'environnement de déploiement..."
echo ""

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Fonction pour afficher les résultats
check_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

check_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

check_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# 1. Vérifier Terraform
echo "1. Vérification de Terraform..."
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    check_ok "Terraform installé (version $TERRAFORM_VERSION)"
else
    check_error "Terraform n'est pas installé. Installez-le depuis https://www.terraform.io/downloads"
fi
echo ""

# 2. Vérifier AWS CLI
echo "2. Vérification d'AWS CLI..."
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1 | cut -d'/' -f2)
    check_ok "AWS CLI installé (version $AWS_VERSION)"
else
    check_warning "AWS CLI n'est pas installé (optionnel pour déploiement via Terraform)"
fi
echo ""

# 3. Vérifier les credentials AWS
echo "3. Vérification des credentials AWS..."
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    check_ok "Variables d'environnement AWS configurées"
    
    # Tester les credentials si AWS CLI est disponible
    if command -v aws &> /dev/null; then
        if aws sts get-caller-identity &> /dev/null; then
            check_ok "Credentials AWS valides"
        else
            check_error "Credentials AWS invalides ou expirés"
        fi
    fi
elif [ -f ~/.aws/credentials ]; then
    check_ok "Fichier ~/.aws/credentials trouvé"
else
    check_warning "Credentials AWS non configurés (nécessaires pour déploiement local)"
fi
echo ""

# 4. Vérifier les fichiers Terraform
echo "4. Vérification des fichiers Terraform..."
REQUIRED_FILES=("main.tf" "variables.tf" "outputs.tf" "terraform.tfvars")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        check_ok "Fichier $file présent"
    else
        check_error "Fichier $file manquant"
    fi
done
echo ""

# 5. Vérifier le script user_data
echo "5. Vérification du script de déploiement..."
if [ -f "scripts/user_data.sh" ]; then
    check_ok "Script user_data.sh présent"
    if [ -x "scripts/user_data.sh" ]; then
        check_ok "Script user_data.sh exécutable"
    else
        check_warning "Script user_data.sh n'est pas exécutable (pas critique)"
    fi
else
    check_error "Script scripts/user_data.sh manquant"
fi
echo ""

# 6. Vérifier terraform.tfvars
echo "6. Vérification de la configuration..."
if [ -f "terraform.tfvars" ]; then
    # Vérifier instance_type
    if grep -q "instance_type.*=.*\"t[23]\.\(nano\|micro\)\"" terraform.tfvars; then
        check_ok "Instance type conforme (t2/t3 nano ou micro)"
    else
        check_error "Instance type non conforme. Utilisez t2.micro, t2.nano, t3.micro ou t3.nano"
    fi
    
    # Vérifier github_repository
    if grep -q "github_repository" terraform.tfvars; then
        REPO=$(grep "github_repository" terraform.tfvars | cut -d'"' -f2)
        check_ok "Repository GitHub configuré: $REPO"
    else
        check_error "Repository GitHub non configuré dans terraform.tfvars"
    fi
    
    # Vérifier db_password
    if grep -q "db_password" terraform.tfvars; then
        check_ok "Mot de passe base de données configuré"
    else
        check_warning "Mot de passe base de données non configuré (utilisera la valeur par défaut)"
    fi
fi
echo ""

# 7. Vérifier l'état Terraform
echo "7. Vérification de l'état Terraform..."
if [ -d ".terraform" ]; then
    check_ok "Terraform initialisé (.terraform/ existe)"
else
    check_warning "Terraform non initialisé. Exécutez 'terraform init'"
fi

if [ -f "terraform.tfstate" ]; then
    check_warning "État Terraform existant détecté. Une infrastructure est peut-être déjà déployée"
fi
echo ""

# 8. Vérifier Docker (pour tests locaux)
echo "8. Vérification de Docker (optionnel)..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    check_ok "Docker installé (version $DOCKER_VERSION)"
    
    if docker ps &> /dev/null; then
        check_ok "Docker daemon en cours d'exécution"
    else
        check_warning "Docker daemon non accessible"
    fi
else
    check_warning "Docker non installé (nécessaire uniquement pour tests locaux)"
fi
echo ""

# Résumé
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RÉSUMÉ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Tout est prêt pour le déploiement !${NC}"
    echo ""
    echo "Prochaines étapes :"
    echo "  1. terraform init    (si pas encore fait)"
    echo "  2. terraform plan    (vérifier le plan)"
    echo "  3. terraform apply   (déployer)"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS avertissement(s) détecté(s)${NC}"
    echo "Vous pouvez continuer mais vérifiez les avertissements ci-dessus."
    exit 0
else
    echo -e "${RED}✗ $ERRORS erreur(s) détectée(s)${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS avertissement(s) détecté(s)${NC}"
    fi
    echo ""
    echo "Corrigez les erreurs avant de déployer."
    exit 1
fi
