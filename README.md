# Forum Anonyme

Une application de forum anonyme avec une architecture microservices, déployée avec Docker et intégrée dans un pipeline CI/CD.

## Architecture

Le projet est composé de 4 services principaux :

1. **API** : Gestion de la création et de la récupération des messages du forum. Située dans un réseau interne, isolée d'Internet.
2. **DB** : Base de données PostgreSQL utilisée par l'API pour stocker les messages du forum, également située dans le réseau interne.
3. **Thread** : Service frontend chargé d'afficher les messages des utilisateurs via le port 80, consommant les services de l'API.
4. **Sender** : Service frontend chargé d'écrire les messages des utilisateurs via le port 8080, consommant également l'API.

## Technologies utilisées

- **Backend** : Node.js avec Express
- **Frontend** : Vue.js
- **Base de données** : PostgreSQL
- **Conteneurisation** : Docker
- **CI/CD** : GitHub Actions
- **Tests** : Jest
- **Linting/Formatting** : ESLint, Prettier
- **Gestion des commits** : Commitizen (Conventional Commits)

## Fonctionnalités

- Création de messages anonymes
- Affichage des messages dans un fil de discussion
- Isolation des services dans des réseaux Docker
- Persistance des données via des volumes Docker

## Mise en place du projet

### Prérequis

- Docker et Docker Compose
- Node.js et pnpm
- Git

### Installation

```bash
# Cloner le dépôt
git clone https://github.com/itsmelouis/forum-anonyme.git
cd forum-anonyme

# Installer les dépendances
pnpm install

# Lancer les tests
pnpm test

# Démarrer l'application avec Docker Compose
docker compose up -d
```

## Accès aux services

- **Thread** (affichage des messages) : http://localhost:80
- **Sender** (envoi de messages) : http://localhost:8080
- **API** (interne) : http://localhost:3000

## Pipeline CI/CD

Le projet est configuré avec un pipeline CI/CD GitHub Actions qui exécute les étapes suivantes :

1. **Validation** : Vérification du code (linting, formatting)
2. **Tests** : Exécution des tests unitaires et d'intégration
3. **Construction** : Génération des images Docker pour chaque service avec le tag correspondant au hash court du commit
4. **Déploiement** : Push des images Docker générées sur GitHub Container Registry

## Structure du projet

```
forum-anonyme/
├── .github/
│   └── workflows/
│       └── ci-cd.yml      # Configuration du pipeline CI/CD
├── apps/
│   ├── api/              # Service API
│   │   ├── src/
│   │   ├── tests/
│   │   └── Dockerfile
│   ├── sender/           # Service d'envoi de messages
│   │   ├── src/
│   │   └── Dockerfile
│   └── thread/           # Service d'affichage des messages
│       ├── src/
│       └── Dockerfile
├── db/
│   └── init.sql         # Script d'initialisation de la base de données
├── docker-compose.yml   # Configuration Docker Compose
└── README.md            # Documentation du projet
```

## Conformité aux exigences

- ✅ **Conventional Commits** : Utilisation de Commitizen pour formater les commits
- ✅ **Docker** : Chaque service possède son propre Dockerfile
- ✅ **Docker Compose** : Configuration pour l'environnement de développement
- ✅ **CI/CD** : Pipeline GitHub Actions pour la validation, les tests, la construction et le déploiement
- ✅ **Registry** : Utilisation de GitHub Container Registry pour stocker les images Docker
- ✅ **Networks et Volumes** : Configuration dans docker-compose.yml pour la persistance et la sécurité
- ✅ **Tests** : Tests unitaires pour l'API
- ✅ **Validation** : Linting et formatting du code

## Licence

MIT
