# Forum Anonyme - Infrastructure Terraform

Infrastructure as Code pour déployer le forum anonyme sur AWS EC2 selon les principes DevSecOps.

## Architecture

- **EC2 Instance**: t2.micro avec Amazon Linux 2
- **PostgreSQL**: Container Docker sur l'instance EC2
- **Security Groups**: Accès restreint selon le principe du moindre privilège
- **Elastic IP**: IP publique stable pour l'accès aux services
- **Docker Compose**: Orchestration des containers

## Services déployés

Tous les services sont déployés en containers Docker sur une seule instance EC2 :

- **Thread** (Port 80): Interface d'affichage des messages (Vue.js)
- **Sender** (Port 8080): Interface d'envoi de messages (Vue.js)
- **API** (Port 3000): Backend REST pour la gestion des messages (Node.js/Express)
- **PostgreSQL** (Port 5432 interne): Base de données en container

## Prérequis

1. **AWS CLI** configuré avec vos credentials
2. **Terraform** >= 1.0 installé
3. **Accès AWS** avec les permissions nécessaires

## Configuration des credentials AWS

**⚠️ IMPORTANT**: Ne jamais commiter vos credentials AWS dans Git !

```bash
# Méthode 1: Variables d'environnement (recommandée)
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="eu-west-3"

# Méthode 2: AWS CLI configure
aws configure
```

Pour GitHub Actions, ajoutez les secrets suivants dans votre repository :
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Déploiement

### 1. Initialisation

```bash
cd terraform
terraform init
```

### 2. Planification

```bash
terraform plan
```

### 3. Déploiement

```bash
terraform apply
```

### 4. Accès aux services

Après le déploiement, les URLs seront affichées :

```bash
# Récupérer les outputs
terraform output

# Exemples d'URLs générées :
# Thread: http://IP_PUBLIQUE
# Sender: http://IP_PUBLIQUE:8080  
# API: http://IP_PUBLIQUE:3000
```

### 5. Connexion SSH

```bash
# La clé SSH est générée automatiquement
ssh -i keys/forum-anonyme-key.pem ec2-user@IP_PUBLIQUE
```

## Sécurité implémentée

### Security by Design
- Chiffrement des volumes EBS
- RDS en réseau privé uniquement
- IAM roles avec permissions minimales
- Security Groups restrictifs

### Security by Default
- Fail2ban activé
- Mises à jour automatiques
- Logs centralisés CloudWatch
- Monitoring des services
- Firewall iptables configuré

### Twelve Factor App
- Configuration via variables d'environnement
- Logs en tant que flux d'événements
- Processus stateless
- Séparation build/run/config

## Monitoring et Logs

- **CloudWatch Logs**: `/aws/ec2/forum-anonyme`
- **Health Checks**: Vérification toutes les 5 minutes
- **Service Status**: `systemctl status forum-anonyme`

## Commandes utiles

```bash
# Vérifier l'état des services
terraform output ssh_connection
ssh -i keys/forum-anonyme-key.pem ec2-user@IP_PUBLIQUE
sudo systemctl status forum-anonyme
sudo docker-compose ps

# Voir les logs
sudo journalctl -u forum-anonyme -f
sudo tail -f /var/log/forum-anonyme-health.log

# Redémarrer les services
sudo systemctl restart forum-anonyme
```

## Destruction de l'infrastructure

```bash
terraform destroy
```

## Personnalisation

Modifiez le fichier `terraform.tfvars` pour adapter :

- **instance_type**: Type d'instance EC2 (t3.nano par défaut)
- **allowed_ssh_cidr**: Restriction d'accès SSH à votre IP
- **db_password**: Mot de passe de la base de données
- **docker_image_tag**: Version des images Docker à déployer

## Coûts estimés

- **EC2 t2.micro**: ~$8.50/mois (ou gratuit avec Free Tier)
- **EBS 20GB gp3**: ~$1.60/mois
- **Elastic IP**: Gratuit si attachée à une instance en cours d'exécution
- **Total**: ~$10.10/mois (ou ~$1.60/mois avec Free Tier)

**Note**: Avec AWS Free Tier (12 premiers mois), l'instance t2.micro est gratuite (750h/mois).

## CI/CD Pipeline

La pipeline GitHub Actions effectue automatiquement :

1. **Validation**: Lint et format du code
2. **Tests**: Tests unitaires et E2E
3. **Build**: Construction des images Docker avec tag = hash du commit
4. **Push**: Publication sur GitHub Container Registry (ghcr.io)
5. **Deploy**: Déploiement sur AWS EC2 via Terraform (branche main uniquement)

### Destruction de l'infrastructure

Pour détruire l'infrastructure depuis GitHub Actions :
1. Allez dans l'onglet "Actions"
2. Sélectionnez le workflow "Destroy Infrastructure"
3. Cliquez sur "Run workflow"
4. Tapez "destroy" pour confirmer

## Troubleshooting

### Services ne démarrent pas
```bash
# Se connecter à l'instance
ssh -i keys/forum-anonyme-key.pem ec2-user@<IP_PUBLIQUE>

# Vérifier le statut du service
sudo systemctl status forum-anonyme

# Voir les logs de déploiement
sudo cat /var/log/user-data.log

# Voir les logs des containers
sudo docker-compose -f /opt/forum-anonyme/docker-compose.yml logs
```

### Problème de connexion base de données
```bash
# Vérifier que PostgreSQL est en cours d'exécution
sudo docker ps | grep postgres

# Voir les logs de l'API
sudo docker-compose -f /opt/forum-anonyme/docker-compose.yml logs api
```

### Redémarrer les services
```bash
sudo systemctl restart forum-anonyme
# ou
sudo docker-compose -f /opt/forum-anonyme/docker-compose.yml restart
```

### Accès réseau
```bash
# Vérifier les Security Groups
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=forum-anonyme"
```
