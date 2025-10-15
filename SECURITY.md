# Sécurité du Projet - Forum Anonyme

## 🔒 Outils de Sécurité Intégrés

Ce projet intègre plusieurs outils de sécurité dans le pipeline CI/CD pour garantir la qualité et la sécurité du code.

### 1. Détection de Secrets - Gitleaks

**Outil:** [Gitleaks](https://github.com/gitleaks/gitleaks)  
**Workflow:** `.github/workflows/ci-cd.yml` (job `secret-scan`)  
**Configuration:** `.gitleaks.toml`

**Fonctionnalités:**
- Scan de tout l'historique Git pour détecter les secrets exposés
- Détection des clés API, tokens, mots de passe, clés privées
- Règles personnalisées pour AWS, GitHub, et autres services
- Exécution automatique à chaque push et pull request

**Types de secrets détectés:**
- Clés d'accès AWS (Access Key & Secret Key)
- Tokens GitHub (Personal Access Tokens, OAuth)
- Clés privées SSH/RSA
- Clés API génériques

### 2. Analyse SAST - CodeQL

**Outil:** [GitHub CodeQL](https://codeql.github.com/)  
**Workflow:** `.github/workflows/ci-cd.yml` (job `sast-analysis`)

**Fonctionnalités:**
- Analyse statique du code JavaScript/Node.js
- Détection des vulnérabilités de sécurité
- Vérification de la qualité du code
- Requêtes de sécurité et de qualité avancées
- Intégration avec GitHub Security

**Vulnérabilités détectées:**
- Injections SQL
- Cross-Site Scripting (XSS)
- Vulnérabilités de désérialisation
- Problèmes de gestion des erreurs
- Mauvaises pratiques de sécurité

### 3. Gestion des Dépendances - Dependabot

**Outil:** [GitHub Dependabot](https://docs.github.com/en/code-security/dependabot)  
**Configuration:** `.github/dependabot.yml`

**Fonctionnalités:**
- Surveillance hebdomadaire des dépendances npm
- Surveillance des GitHub Actions
- Surveillance des images Docker de base
- Création automatique de Pull Requests pour les mises à jour
- Alertes de sécurité pour les vulnérabilités connues

**Écosystèmes surveillés:**
- **npm:** Dépendances JavaScript (root, api, thread, sender)
- **GitHub Actions:** Versions des actions utilisées
- **Docker:** Images de base dans les Dockerfiles

**Planification:**
- Vérification tous les lundis à 9h00
- Maximum 10 PR pour le root, 5 par service
- Labels automatiques: `dependencies`, `security`
- Messages de commit conventionnels (prefix: `chore`)

## 🔄 Pipeline de Sécurité

Le pipeline CI/CD exécute les contrôles de sécurité dans l'ordre suivant:

```
1. secret-scan (Gitleaks)
   ↓
2. sast-analysis (CodeQL)
   ↓
3. validate (Lint & Format)
   ↓
4. test (Tests unitaires)
   ↓
5. build-and-push-images (Docker)
   ↓
6. deploy (AWS - uniquement sur main/master)
```

**Important:** Si un secret est détecté ou une vulnérabilité critique est trouvée, le pipeline s'arrête et le déploiement est bloqué.

## 📊 Résultats et Rapports

### GitHub Security Tab
- Les résultats CodeQL sont disponibles dans l'onglet "Security" > "Code scanning alerts"
- Les alertes Dependabot sont dans "Security" > "Dependabot alerts"

### Actions Workflow
- Les logs détaillés de Gitleaks sont dans les runs GitHub Actions
- Les rapports SAST sont générés automatiquement par CodeQL

## 🛠️ Configuration Locale

### Tester Gitleaks localement
```bash
# Installer Gitleaks
brew install gitleaks

# Scanner le dépôt
gitleaks detect --source . --verbose

# Scanner avec la config personnalisée
gitleaks detect --source . --config .gitleaks.toml
```

### Tester CodeQL localement
```bash
# Installer CodeQL CLI
# https://github.com/github/codeql-cli-binaries

# Créer une base de données
codeql database create codeql-db --language=javascript

# Analyser
codeql database analyze codeql-db --format=sarif-latest --output=results.sarif
```

## 🚨 En cas de Détection

### Secret détecté
1. **NE PAS** supprimer simplement le commit
2. Révoquer immédiatement le secret exposé
3. Générer de nouvelles credentials
4. Utiliser GitHub Secrets pour stocker les secrets
5. Réécrire l'historique Git si nécessaire (`git filter-branch` ou `BFG Repo-Cleaner`)

### Vulnérabilité détectée
1. Examiner le rapport CodeQL
2. Corriger la vulnérabilité selon les recommandations
3. Ajouter des tests pour éviter les régressions
4. Documenter le fix dans le commit

### Dépendance vulnérable
1. Examiner la PR Dependabot
2. Vérifier la compatibilité de la mise à jour
3. Tester localement si nécessaire
4. Merger la PR ou mettre à jour manuellement

## 📝 Bonnes Pratiques

1. **Jamais de secrets en dur dans le code**
   - Utiliser des variables d'environnement
   - Utiliser GitHub Secrets pour la CI/CD
   - Utiliser AWS Secrets Manager en production

2. **Révision régulière des dépendances**
   - Accepter les PRs Dependabot rapidement
   - Maintenir les dépendances à jour
   - Supprimer les dépendances inutilisées

3. **Analyse continue**
   - Ne pas ignorer les alertes de sécurité
   - Traiter les vulnérabilités par ordre de priorité
   - Documenter les exceptions justifiées

4. **Formation de l'équipe**
   - Comprendre les vulnérabilités courantes (OWASP Top 10)
   - Suivre les bonnes pratiques de développement sécurisé
   - Participer aux revues de code avec un focus sécurité

## 🔗 Ressources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [CodeQL Documentation](https://codeql.github.com/docs/)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
