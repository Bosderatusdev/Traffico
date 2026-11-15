# 📊 État du projet — Traffico (Transport Burundi & international)

Dernière mise à jour : 13 septembre 2026

## 🛠️ Stack technique
- Backend : Spring Boot 3.5.14, Java 21 (LTS, fixé volontairement)
- Base de données : PostgreSQL 18, base `transport_burundi`
- Sécurité backend : Spring Security + JWT (jjwt 0.12.6) + Bucket4j 8.19.0 (rate limiting) + BCrypt (PasswordEncoder)
- Frontend : Flutter 3.44.8 / Dart, org `com.transport`
- HTTP client : Dio 5.x (interceptor JWT automatique)
- Stockage sécurisé : flutter_secure_storage
- Préférences simples : shared_preferences (langue)
- Téléphone international : intl_phone_field
- PDF & impression : pdf + printing
- QR code (affichage écran) : qr_flutter
- Internationalisation : flutter_localizations + intl + ARB (fr, en — infrastructure prête)
- Typographie : Google Fonts (Poppins)
- Environnement : Kali Linux, VSCode, DBeaver, Postman, Android Studio (émulateur Pixel 8 API 36)

## 📦 APIs backend (10, Favoris ajoutée)
Agences, Users, Chauffeurs, Bus, Trajets, Reservations, Paiements, Avis, Notifications, **Favoris**
→ Chacune suit le pattern : Model → Repository → Service → Controller, avec protection IDOR systématique

## 🔐 Authentification & compte backend
- Inscription : nom + prénom + téléphone obligatoire (international, avec `+`), email optionnel
- Vérification par code à 6 chiffres : email réel (Gmail SMTP), téléphone simulé (logs serveur)
- Connexion : `identifiant` (téléphone OU email) + `motDePasse`
- Token JWT (24h), avec `tokenVersion` pour invalidation après changement sensible (email/téléphone/mot de passe)
- Mot de passe oublié : `forgot-password` (envoi code) + `reset-password` (vérif + changement) — réutilisé aussi pour le changement de mot de passe depuis l'app (sécurité par code)
- **Changement d'email** : `POST /api/users/{id}/change-email/request` (envoie code au NOUVEL email) + `/change-email/confirm` (code) — email non modifié tant que non confirmé
- **Changement de téléphone** : même principe, `/change-telephone/request` + `/change-telephone/confirm`
- **Suppression de compte** : `POST /api/users/{id}/delete-self` (body: motDePasse) — anonymisation (soft delete) plutôt que suppression physique, pour préserver l'intégrité des réservations/paiements historiques. Le `POST` a été choisi plutôt que `DELETE` car certains clients HTTP (dont Dio/Android) n'envoient pas fiablement de body sur les requêtes `DELETE`.
- ⚠️ Le backend ne bloque pas la connexion d'un compte non vérifié — c'est le frontend qui force la vérification du canal utilisé

## 🏗️ Architecture des rôles — 3 apps, 4 rôles
| Version | Rôles couverts | Plateforme | Statut |
|---|---|---|---|
| **App Client** | Client | Flutter Mobile | ✅ Quasi terminée |
| App Agence | Admin Agence + Chauffeur (rôle limité) | Flutter Mobile (même code, interface selon `role`) | 🔜 Prochaine étape |
| Dashboard Super Admin | Super Admin | Web | 📋 Plus tard |

## 💳 Paiement
- Structure prête : Lumicash (défaut), EcoCash, Smart Pesa, BurundiPay
- Backend fonctionnel et testé : `POST /api/paiements` (body: `groupeId`, `montant`, `methode`) → statut `en_attente`, puis `PUT /api/paiements/{id}/confirmer` → statut `reussi`, décrémente `placesDisponibles`, génère notifications (billet + QR par place + notification générale "Paiement confirmé")
- **Frontend NON branché** — en attente de l'obtention de l'accès API réel Lumicash (comptes marchands pas encore obtenus). L'écran `reservation_confirmee_screen.dart` affiche le récapitulatif mais le bouton "Procéder au paiement" est un placeholder.

## 🔒 Sécurité — points traités récemment
- Faille corrigée : `UserController.updateUser()` permettait l'élévation de privilège via `role` envoyé par le client → restreint à `nom`/`prenom` uniquement
- Bean `PasswordEncoder` manquant dans `SecurityConfig` → ajouté (bloquait la suppression de compte)
- Nom d'agence rendu unique en base (`UNIQUE` constraint) pour garantir qu'un client sait toujours précisément quelle agence reçoit son paiement

---

## 📱 FRONTEND — App Client (`transport_client`) — état détaillé

### ✅ Thème (`lib/theme/app_theme.dart`)
- `AppColors` (palette de marque fixe), `AppTheme.light()` / `.dark()` avec bascule auto `ThemeMode.system`
- `textTheme` entièrement centralisé — règle du projet : toujours `theme.textTheme.xxx`, jamais de style codé en dur
- `AppSemanticColors` (ThemeExtension) : `success`, `warning`, `surfaceVariant`, `border`, `textSecondary`
- Composants pré-stylés : boutons, champs, cartes, bottom nav, snackbar, dialog

### ✅ Authentification complète
- Inscription 4 étapes (indicateur de progression) : Nom/Prénom → Téléphone international (`IntlPhoneField`, tout pays) + Email optionnel → Mot de passe → Vérification OTP (téléphone puis email si fourni, avec renvoi de code et cooldown)
- Login avec **détection automatique du mode** : premier caractère chiffre → bascule en champ téléphone international ; lettre → reste en champ email
- Vérification forcée du canal utilisé à la connexion (redirection vers OTP si non vérifié) — décision produit pour éviter les comptes fantômes
- Mot de passe oublié : demande de code (téléphone ou email au choix) → réinitialisation
- JWT + userId + role + nom stockés via `flutter_secure_storage`, injectés automatiquement dans chaque requête via interceptor Dio

### ✅ Navigation principale (4 onglets, `IndexedStack`)
Accueil, Réservations, Messages, Profil (Mon compte + Paramètres)

### ✅ Recherche de trajets (Accueil)
- Autocomplete de villes maison (debounce, suggestions filtrées, pas de dépendance tierce fragile)
- Recherche insensible à la casse (`IgnoreCase` côté backend)
- `CancelToken` pour annuler une recherche obsolète si l'utilisateur retape vite
- Filtrage par date : date choisie → uniquement ce jour (hors passé) ; pas de date → 7 prochains jours, triés du plus proche au plus lointain
- Section "Bientôt disponible" (taxi à la demande, colis, assistance) en placeholder visuel sous les résultats

### ✅ Réservation multi-places
- Sélecteur de nombre de places (pas de sièges numérotés — usage réel des bus burundais)
- `POST /api/reservations` avec `trajetId` + `nombrePlaces` → backend crée N réservations liées par un `groupeId` UUID commun
- Écran de confirmation récapitulant le groupe, en attente de paiement

### ✅ Billets & QR codes
- Écran `ticket_detail_screen.dart` : design carte avec bandeau coloré haut/bas, infos passager/trajet/agence/place/prix/statut
- QR code = **texte lisible complet** encodé directement (pas juste un UUID) — scannable par n'importe quelle app de scan standard, pas besoin d'app dédiée pour l'instant
- **Expiration à 24h après le départ** : QR visuellement grisé + marqué "expiré" passé ce délai, sur l'écran ET dans le PDF généré
- Suppression du billet possible uniquement après cette même fenêtre de 24h (bouton toujours visible, message explicite avec compte à rebours si trop tôt)
- Génération PDF (`pdf` + `printing`) : design carte personnalisé (pas de format A4/A5/A6 standard), bandeaux colorés reproduits fidèlement, couleur du statut (vert/orange) conservée à l'impression
- Écran Réservations : regroupement par `groupeId`, une carte par achat, liste des tickets individuels cliquables

### ✅ Messages (notifications)
- `GET /api/notifications/user/{userId}` (pas l'endpoint admin `/api/notifications`)
- Filtre côté client : exclut les notifications "Billet"/"QR Code" (qui vivent désormais dans Réservations), garde uniquement les alertes générales
- Marquage lu/non lu fonctionnel, bottom sheet de détail
- Backend : purge automatique programmée après 30 jours (`@Scheduled`), endpoint broadcast admin (`POST /api/notifications/broadcast`) pour notifications générales à tous/ciblés

### ✅ Profil → Mon compte
- **Informations personnelles** : affichage lecture seule + bouton "Modifier" ouvrant un sheet — nom/prénom modifiables directement, email/téléphone nécessitent le flow de vérification par code (nouveaux endpoints backend dédiés)
- **Sécurité** : changement de mot de passe via code envoyé (réutilise forgot-password/reset-password), statuts de vérification email/téléphone affichés
- **Mes avis** : `GET /api/avis/user/{id}` fonctionnel
- **Favoris** : agences ET trajets (paire de villes, indépendant de la date) — ajout, liste, suppression fonctionnels ; bouton étoile sur les cartes de résultats de recherche (ajout direct ; suppression via l'écran dédié pour l'instant)
- **Moyens de paiement** : placeholder, en attente du paiement réel

### ✅ Profil → Paramètres
- **Langue** : infrastructure i18n complète (ARB fr/en), Français et English **fonctionnels et traduits en temps réel sans redémarrage** sur Welcome, Login, Register étape 1 — reste des écrans à traduire progressivement. Kirundi/Swahili proposés dans le sélecteur mais marqués "Bientôt disponible" (nécessitent un vrai traducteur humain)
- Sélecteur de langue accessible **avant connexion** (bouton 🌐 sur Welcome/Login/Register) ET dans Paramètres — même mécanisme central (`TrafficoApp.changerLangue()`)
- Préférences de notifications : placeholder visuel (switches non persistés)
- Aide & support : appel/email direct via `url_launcher`
- Conditions/Confidentialité/À propos : placeholders, textes légaux à rédiger
- **Supprimer mon compte** : fonctionnel de bout en bout, protégé par re-saisie du mot de passe, testé et vérifié en base

### 🔜 En attente / prochaines étapes Client
- Brancher le paiement réel dès obtention de l'accès API Lumicash
- Continuer la traduction FR/EN écran par écran (register étapes 2-4, Accueil, Réservations, Messages, Profil, Paramètres)
- Traductions Kirundi/Swahili (nécessite traducteur humain)
- Persistance réelle des préférences de notifications
- Rédaction des textes légaux (conditions, confidentialité)
- Synchronisation visuelle de l'état favori sur les cartes de recherche (actuellement ajout seul, pas de désactivation directe)

---

## 🔜 PROCHAINE ÉTAPE MAJEURE — App Agence (`transport_agence` ou nom à définir)

- Une seule app Flutter, interface différente selon `role` (`admin_agence` vs `chauffeur`)
- **Admin Agence** : gestion des trajets/bus/chauffeurs de son agence, consultation des réservations/paiements de son agence, envoi de notifications ciblées à ses clients (endpoint broadcast déjà prêt côté backend)
- **Chauffeur** : fonctions limitées — voir son trajet du jour, scanner les billets/QR codes des passagers
- Backend déjà prêt pour le scan : `GET /api/reservations/qr/{qrCode}` (à créer si pas encore fait — vérifier), avec protection IDOR (propriétaire du billet OU staff agence/chauffeur/super_admin)
- Réutilisation probable du package Dart partagé prévu à l'origine (thème, modèles, services API) — pas encore mis en place, actuellement dupliqué dans `transport_client` seul

---

## 🔑 Décisions clés à retenir

- **Numéro de téléphone toujours stocké avec l'indicatif pays et le `+`** (ex: `+25765555555`) — validé par `@Pattern` backend (`^\+?[0-9]{8,15}$`) et cohérent avec les données réelles en base
- **userId envoyé en string** dans les endpoints verify/resend (`"4"`, pas `4`)
- Toujours utiliser `theme.textTheme`, `Theme.of(context).colorScheme` et `AppSemanticColors` — jamais de couleur/style codé en dur
- `ApiConfig.baseUrl` = `http://10.0.2.2:8081` pour l'émulateur Android (config `network_security_config.xml` nécessaire pour autoriser le cleartext HTTP sur Android 9+)
- **Un favori "trajet" = paire de villes**, jamais un `trajet_id` précis (qui devient obsolète après sa date de départ)
- **Anonymisation plutôt que suppression physique** pour tout ce qui touche à l'intégrité référentielle (comptes utilisateurs liés à des réservations/paiements historiques)
- Préférer `POST` à `DELETE` quand une action sensible nécessite l'envoi fiable d'un body (mot de passe de confirmation) depuis Flutter/Dio
- QR code des billets = texte lisible complet (pas juste un UUID) — décision produit pour rester scannable par n'importe quelle app grand public en attendant l'app de contrôle dédiée
- Après chaque ajout de package Flutter avec code natif (dio, printing, shared_preferences, etc.) : toujours `flutter clean` + arrêt complet + relance, jamais de simple hot reload/restart
- Émulateur Android : penser à surveiller/augmenter le stockage interne de l'AVD (`Wipe Data` ou augmentation via Device Manager) si erreur `INSUFFICIENT_STORAGE` à l'installation

## 📅 Planning global (rappel)
10 mois, développeur solo. Backend + sécurité (mois 1-2) largement en avance. App Client quasi complète en mois 2-3 (auth, navigation, réservations, billets, favoris, paramètres, i18n en cours) — toujours en avance sur le planning initial. Paiement réel et App Agence à venir.
