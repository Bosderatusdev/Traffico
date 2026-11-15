import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Traffico'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In fr, this message translates to:
  /// **'Réservez votre trajet en toute simplicité, où que vous soyez'**
  String get welcomeTagline;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccountYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccountYet;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Content de te revoir !'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tape ton téléphone ou ton email, la connexion s\'adapte automatiquement'**
  String get loginSubtitle;

  /// No description provided for @phoneOrEmail.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone ou email'**
  String get phoneOrEmail;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @registerInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment vous appelez-vous ?'**
  String get registerInfoTitle;

  /// No description provided for @registerInfoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations apparaîtront sur vos billets'**
  String get registerInfoSubtitle;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButton;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @registerPhoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment peut-on vous joindre ?'**
  String get registerPhoneTitle;

  /// No description provided for @registerPhoneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone est obligatoire, l\'email est optionnel'**
  String get registerPhoneSubtitle;

  /// No description provided for @emailOptional.
  ///
  /// In fr, this message translates to:
  /// **'Email (optionnel)'**
  String get emailOptional;

  /// No description provided for @registerPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre mot de passe'**
  String get registerPasswordTitle;

  /// No description provided for @registerPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caractères'**
  String get registerPasswordSubtitle;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDontMatch;

  /// No description provided for @verifyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code reçu'**
  String get verifyTitle;

  /// No description provided for @resendCode.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get resendCode;

  /// No description provided for @verifyButton.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get verifyButton;

  /// No description provided for @accountCreatedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé !'**
  String get accountCreatedTitle;

  /// No description provided for @accountCreatedSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ton compte a bien été vérifié.\nTu peux maintenant te connecter.'**
  String get accountCreatedSubtitle;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navReservations.
  ///
  /// In fr, this message translates to:
  /// **'Réservations'**
  String get navReservations;

  /// No description provided for @navMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @searchDeparture.
  ///
  /// In fr, this message translates to:
  /// **'Ville de départ'**
  String get searchDeparture;

  /// No description provided for @searchArrival.
  ///
  /// In fr, this message translates to:
  /// **'Ville d\'arrivée'**
  String get searchArrival;

  /// No description provided for @searchDate.
  ///
  /// In fr, this message translates to:
  /// **'Date (optionnel)'**
  String get searchDate;

  /// No description provided for @searchAllDates.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les dates'**
  String get searchAllDates;

  /// No description provided for @searchButton.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get searchButton;

  /// No description provided for @noTripFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun trajet trouvé'**
  String get noTripFound;

  /// No description provided for @tryOtherCity.
  ///
  /// In fr, this message translates to:
  /// **'Essaie une autre ville ou une autre date'**
  String get tryOtherCity;

  /// No description provided for @findYourTrip.
  ///
  /// In fr, this message translates to:
  /// **'Trouve ton prochain trajet'**
  String get findYourTrip;

  /// No description provided for @enterDestination.
  ///
  /// In fr, this message translates to:
  /// **'Indique ta destination pour voir les trajets disponibles'**
  String get enterDestination;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoon;

  /// No description provided for @noReservationYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation pour le moment'**
  String get noReservationYet;

  /// No description provided for @ticketsWillAppear.
  ///
  /// In fr, this message translates to:
  /// **'Ton historique de billets apparaîtra ici'**
  String get ticketsWillAppear;

  /// No description provided for @confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get confirmed;

  /// No description provided for @pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @noNotificationYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de notification'**
  String get noNotificationYet;

  /// No description provided for @alertsWillAppear.
  ///
  /// In fr, this message translates to:
  /// **'Confirmations et alertes apparaîtront ici'**
  String get alertsWillAppear;

  /// No description provided for @myAccount.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get myAccount;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Tu devras te reconnecter pour accéder à ton compte.'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @personalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInfo;

  /// No description provided for @security.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get security;

  /// No description provided for @paymentMethods.
  ///
  /// In fr, this message translates to:
  /// **'Moyens de paiement'**
  String get paymentMethods;

  /// No description provided for @myReviews.
  ///
  /// In fr, this message translates to:
  /// **'Mes avis'**
  String get myReviews;

  /// No description provided for @favorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @notificationPrefs.
  ///
  /// In fr, this message translates to:
  /// **'Préférences de notifications'**
  String get notificationPrefs;

  /// No description provided for @helpSupport.
  ///
  /// In fr, this message translates to:
  /// **'Aide & support'**
  String get helpSupport;

  /// No description provided for @termsOfUse.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccount;

  /// No description provided for @greeting.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get greeting;

  /// No description provided for @noCharge.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de Charger'**
  String get noCharge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
