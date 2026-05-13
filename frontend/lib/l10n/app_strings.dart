import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ── Abstract interface ────────────────────────────────────────────────────────

abstract class AppStrings {
  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  // Common
  String get cancel;
  String get confirm;
  String get save;
  String get edit;
  String get remove;
  String get close;
  String get back;
  String get next;
  String get loading;
  String get error;
  String get retry;
  String get use;
  String get restore;
  String get resetLabel;
  String get apply;

  // App
  String get appTitle;
  String get appSubtitle;

  // Auth
  String get username;
  String get password;
  String get loginButton;
  String get usernameRequired;
  String get passwordRequired;
  String get changePassword;
  String get currentPassword;
  String get newPassword;
  String get confirmPassword;
  String get onlyDmCanAddPlayers;

  // Dashboard
  String get myCharacters;
  String get newCharacter;
  String get noCharacters;
  String get noCharactersHint;
  String get logoutTitle;
  String get logoutConfirm;
  String get logout;
  String get userManagement;
  String get errorLoadingCharacters;
  String get tryAgain;

  // Sheet Tabs
  String get tabAbilities;
  String get tabSkills;
  String get tabCombat;
  String get tabSpells;
  String get tabFeatures;
  String get tabInventory;
  String get tabInfo;

  // Sheet Header
  String get hp;
  String get ac;
  String get initiative;
  String get speed;
  String get proficiency;
  String get manageHp;

  // Combat
  String get actions;
  String get bonusActions;
  String get reactions;
  String get deathSavingThrows;
  String get successes;
  String get failures;
  String get hitDiceAndSpeed;
  String get hitDice;
  String get howManyUse;
  String get available;

  // Spells
  String get manageSpells;
  String get mySpells;
  String get learnNew;
  String get prepared;
  String get saveDC;
  String get attack;
  String get learnSpellTitle;
  String get learnButton;
  String get removeSpellTitle;
  String get removeButton;
  String get castButton;
  String get learnNewSpell;

  // Settings
  String get settings;
  String get editCharacter;
  String get levelUp;
  String get language;
  String get levelUpButton;

  // Long / Short rest
  String get longRest;
  String get shortRest;
  String get longRestTitle;
  String get shortRestTitle;
  String get rest;
  String get rollDice;

  // HP Management
  String get characterSheet;
  String get damage;
  String get heal;
  String get tempHp;

  // Language names (always in their own language)
  String get langEnglish;
  String get langSpanish;
  String get langGalician;

  // Ability attributes
  String get abilityScores;
  String get savingThrows;
  String get str;
  String get dex;
  String get con;
  String get intAttr;
  String get wis;
  String get cha;
  String get level;
  String get standardActions;

  // Dynamic / parametrised
  String levelUpContent(String name, int nextLevel);
  String removeSpellContent(String spellName);
  String spellLearned(String spellName);
  String availableCount(int count);
  String newCharacterCount(int count, int max);
}

// ── English ───────────────────────────────────────────────────────────────────

class _EnStrings extends AppStrings {
  @override String get cancel => 'Cancel';
  @override String get confirm => 'Confirm';
  @override String get save => 'Save';
  @override String get edit => 'Edit';
  @override String get remove => 'Remove';
  @override String get close => 'Close';
  @override String get back => 'Back';
  @override String get next => 'Next';
  @override String get loading => 'Loading…';
  @override String get error => 'Error';
  @override String get retry => 'Retry';
  @override String get use => 'Use';
  @override String get restore => 'Restore';
  @override String get resetLabel => 'RESET';
  @override String get apply => 'Apply';

  @override String get appTitle => 'DungeonScroll';
  @override String get appSubtitle => 'D&D Character Manager';

  @override String get username => 'Username';
  @override String get password => 'Password';
  @override String get loginButton => 'Sign In';
  @override String get usernameRequired => 'Please enter your username';
  @override String get passwordRequired => 'Please enter your password';
  @override String get changePassword => 'Change Password';
  @override String get currentPassword => 'Current password';
  @override String get newPassword => 'New password';
  @override String get confirmPassword => 'Confirm password';
  @override String get onlyDmCanAddPlayers => 'Only the Dungeon Master can add new players';

  @override String get myCharacters => 'My Characters';
  @override String get newCharacter => 'New Character';
  @override String get noCharacters => 'No adventurers yet';
  @override String get noCharactersHint => 'Create your first character\nto start the adventure.';
  @override String get logoutTitle => 'Log out?';
  @override String get logoutConfirm => 'Are you sure you want to log out?';
  @override String get logout => 'Log out';
  @override String get userManagement => 'User Management';
  @override String get errorLoadingCharacters => 'Error loading characters';
  @override String get tryAgain => 'Try again';

  @override String get tabAbilities => 'Abilities';
  @override String get tabSkills => 'Skills';
  @override String get tabCombat => 'Combat';
  @override String get tabSpells => 'Spells';
  @override String get tabFeatures => 'Features';
  @override String get tabInventory => 'Inventory';
  @override String get tabInfo => 'Info';

  @override String get hp => 'HP';
  @override String get ac => 'AC';
  @override String get initiative => 'Initiative';
  @override String get speed => 'Speed';
  @override String get proficiency => 'Proficiency';
  @override String get manageHp => 'Manage HP';

  @override String get actions => 'Actions';
  @override String get bonusActions => 'Bonus Actions';
  @override String get reactions => 'Reactions';
  @override String get deathSavingThrows => 'Death Saving Throws';
  @override String get successes => 'Successes';
  @override String get failures => 'Failures';
  @override String get hitDiceAndSpeed => 'Hit Dice & Speed';
  @override String get hitDice => 'Hit Dice';
  @override String get howManyUse => 'How many will you use?';
  @override String get available => 'available';

  @override String get manageSpells => 'Manage Spells';
  @override String get mySpells => 'My Spells';
  @override String get learnNew => 'Learn New';
  @override String get prepared => 'PREPARED';
  @override String get saveDC => 'SAVE DC';
  @override String get attack => 'ATTACK';
  @override String get learnSpellTitle => 'Learn spell?';
  @override String get learnButton => 'Learn';
  @override String get removeSpellTitle => 'Remove spell?';
  @override String get removeButton => 'Remove';
  @override String get castButton => 'CAST';
  @override String get learnNewSpell => 'Learn New Spell';

  @override String get settings => 'Settings';
  @override String get editCharacter => 'Edit Character';
  @override String get levelUp => 'Level Up';
  @override String get language => 'Language';
  @override String get levelUpButton => 'Level Up!';

  @override String get longRest => 'Long';
  @override String get shortRest => 'Short';
  @override String get longRestTitle => 'Long Rest';
  @override String get shortRestTitle => 'Short Rest';
  @override String get rest => 'Rest';
  @override String get rollDice => 'Roll dice';
  @override String get characterSheet => 'Character Sheet';
  @override String get damage => 'Damage';
  @override String get heal => 'Heal';
  @override String get tempHp => 'Temp HP';

  @override String get langEnglish => 'English';
  @override String get langSpanish => 'Castellano';
  @override String get langGalician => 'Galego';

  @override String get abilityScores => 'Ability Scores';
  @override String get savingThrows => 'Saving Throws';
  @override String get str => 'STR';
  @override String get dex => 'DEX';
  @override String get con => 'CON';
  @override String get intAttr => 'INT';
  @override String get wis => 'WIS';
  @override String get cha => 'CHA';
  @override String get level => 'Level';
  @override String get standardActions => 'Standard Actions';

  @override String levelUpContent(String name, int nextLevel) =>
      'Level up $name to level $nextLevel?';
  @override String removeSpellContent(String spellName) =>
      'Remove "$spellName" from your spellbook?';
  @override String spellLearned(String spellName) => 'Spell learned: "$spellName"';
  @override String availableCount(int count) => '$count available';
  @override String newCharacterCount(int count, int max) =>
      'New Character ($count / $max)';
}

// ── Castellano ────────────────────────────────────────────────────────────────

class _EsStrings extends AppStrings {
  @override String get cancel => 'Cancelar';
  @override String get confirm => 'Confirmar';
  @override String get save => 'Guardar';
  @override String get edit => 'Editar';
  @override String get remove => 'Eliminar';
  @override String get close => 'Cerrar';
  @override String get back => 'Atrás';
  @override String get next => 'Siguiente';
  @override String get loading => 'Cargando…';
  @override String get error => 'Error';
  @override String get retry => 'Reintentar';
  @override String get use => 'Usar';
  @override String get restore => 'Restaurar';
  @override String get resetLabel => 'REINICIAR';
  @override String get apply => 'Aplicar';

  @override String get appTitle => 'DungeonScroll';
  @override String get appSubtitle => 'Gestor de Personajes D&D';

  @override String get username => 'Usuario';
  @override String get password => 'Contraseña';
  @override String get loginButton => 'Entrar';
  @override String get usernameRequired => 'Por favor introduce tu usuario';
  @override String get passwordRequired => 'Por favor introduce tu contraseña';
  @override String get changePassword => 'Cambiar contraseña';
  @override String get currentPassword => 'Contraseña actual';
  @override String get newPassword => 'Nueva contraseña';
  @override String get confirmPassword => 'Confirmar contraseña';
  @override String get onlyDmCanAddPlayers => 'Solo el Dungeon Master puede añadir nuevos jugadores';

  @override String get myCharacters => 'Mis Personajes';
  @override String get newCharacter => 'Nuevo Personaje';
  @override String get noCharacters => 'Aún no hay aventureros';
  @override String get noCharactersHint => 'Crea tu primer personaje\npara empezar la aventura.';
  @override String get logoutTitle => '¿Cerrar sesión?';
  @override String get logoutConfirm => '¿Seguro que quieres cerrar sesión?';
  @override String get logout => 'Cerrar sesión';
  @override String get userManagement => 'Gestión de usuarios';
  @override String get errorLoadingCharacters => 'Error al cargar personajes';
  @override String get tryAgain => 'Reintentar';

  @override String get tabAbilities => 'Atributos';
  @override String get tabSkills => 'Destrezas';
  @override String get tabCombat => 'Combate';
  @override String get tabSpells => 'Hechizos';
  @override String get tabFeatures => 'Habilidades';
  @override String get tabInventory => 'Inventario';
  @override String get tabInfo => 'Info';

  @override String get hp => 'PV';
  @override String get ac => 'CA';
  @override String get initiative => 'Iniciativa';
  @override String get speed => 'Velocidad';
  @override String get proficiency => 'Competencia';
  @override String get manageHp => 'Gestionar PV';

  @override String get actions => 'Acciones';
  @override String get bonusActions => 'Acciones adicionales';
  @override String get reactions => 'Reacciones';
  @override String get deathSavingThrows => 'Tiradas de Muerte';
  @override String get successes => 'Éxitos';
  @override String get failures => 'Fallos';
  @override String get hitDiceAndSpeed => 'Dados de Golpe y Velocidad';
  @override String get hitDice => 'Dados de Golpe';
  @override String get howManyUse => '¿Cuántos vas a usar?';
  @override String get available => 'disponibles';

  @override String get manageSpells => 'Gestionar Hechizos';
  @override String get mySpells => 'Mis Hechizos';
  @override String get learnNew => 'Aprender';
  @override String get prepared => 'PREPARADO';
  @override String get saveDC => 'CD SALVACIÓN';
  @override String get attack => 'ATAQUE';
  @override String get learnSpellTitle => '¿Aprender hechizo?';
  @override String get learnButton => 'Aprender';
  @override String get removeSpellTitle => '¿Eliminar hechizo?';
  @override String get removeButton => 'Eliminar';
  @override String get castButton => 'LANZAR';
  @override String get learnNewSpell => 'Aprender Nuevo Hechizo';

  @override String get settings => 'Ajustes';
  @override String get editCharacter => 'Editar Personaje';
  @override String get levelUp => 'Subir Nivel';
  @override String get language => 'Idioma';
  @override String get levelUpButton => '¡Subir Nivel!';

  @override String get longRest => 'Largo';
  @override String get shortRest => 'Corto';
  @override String get longRestTitle => 'Descanso Largo';
  @override String get shortRestTitle => 'Descanso Corto';
  @override String get rest => 'Descansar';
  @override String get rollDice => 'Tirar dados';
  @override String get characterSheet => 'Hoja de Personaje';
  @override String get damage => 'Daño';
  @override String get heal => 'Curar';
  @override String get tempHp => 'PV Temp';

  @override String get langEnglish => 'English';
  @override String get langSpanish => 'Castellano';
  @override String get langGalician => 'Galego';

  @override String get abilityScores => 'Puntuaciones de Atributos';
  @override String get savingThrows => 'Tiradas de Salvación';
  @override String get str => 'FUE';
  @override String get dex => 'DES';
  @override String get con => 'CON';
  @override String get intAttr => 'INT';
  @override String get wis => 'SAB';
  @override String get cha => 'CAR';
  @override String get level => 'Nivel';
  @override String get standardActions => 'Acciones estándar';

  @override String levelUpContent(String name, int nextLevel) =>
      '¿Subir de nivel a $name hasta el nivel $nextLevel?';
  @override String removeSpellContent(String spellName) =>
      '¿Eliminar "$spellName" de tu libro de hechizos?';
  @override String spellLearned(String spellName) => 'Hechizo aprendido: "$spellName"';
  @override String availableCount(int count) => '$count disponibles';
  @override String newCharacterCount(int count, int max) =>
      'Nuevo Personaje ($count / $max)';
}

// ── Galego ────────────────────────────────────────────────────────────────────

class _GlStrings extends AppStrings {
  @override String get cancel => 'Cancelar';
  @override String get confirm => 'Confirmar';
  @override String get save => 'Gardar';
  @override String get edit => 'Editar';
  @override String get remove => 'Eliminar';
  @override String get close => 'Pechar';
  @override String get back => 'Atrás';
  @override String get next => 'Seguinte';
  @override String get loading => 'Cargando…';
  @override String get error => 'Erro';
  @override String get retry => 'Tentar de novo';
  @override String get use => 'Usar';
  @override String get restore => 'Restaurar';
  @override String get resetLabel => 'REINICIAR';
  @override String get apply => 'Aplicar';

  @override String get appTitle => 'DungeonScroll';
  @override String get appSubtitle => 'Xestor de Personaxes D&D';

  @override String get username => 'Usuario';
  @override String get password => 'Contrasinal';
  @override String get loginButton => 'Entrar';
  @override String get usernameRequired => 'Por favor introduce o teu usuario';
  @override String get passwordRequired => 'Por favor introduce o teu contrasinal';
  @override String get changePassword => 'Cambiar contrasinal';
  @override String get currentPassword => 'Contrasinal actual';
  @override String get newPassword => 'Novo contrasinal';
  @override String get confirmPassword => 'Confirmar contrasinal';
  @override String get onlyDmCanAddPlayers => 'Só o Dungeon Master pode engadir novos xogadores';

  @override String get myCharacters => 'Os Meus Personaxes';
  @override String get newCharacter => 'Novo Personaxe';
  @override String get noCharacters => 'Aínda non hai aventureiros';
  @override String get noCharactersHint => 'Crea o teu primeiro personaxe\npara comezar a aventura.';
  @override String get logoutTitle => 'Pechar sesión?';
  @override String get logoutConfirm => 'Tes a certeza de que queres pechar sesión?';
  @override String get logout => 'Pechar sesión';
  @override String get userManagement => 'Xestión de usuarios';
  @override String get errorLoadingCharacters => 'Erro ao cargar personaxes';
  @override String get tryAgain => 'Tentar de novo';

  @override String get tabAbilities => 'Atributos';
  @override String get tabSkills => 'Destrezas';
  @override String get tabCombat => 'Combate';
  @override String get tabSpells => 'Feitizos';
  @override String get tabFeatures => 'Habilidades';
  @override String get tabInventory => 'Inventario';
  @override String get tabInfo => 'Info';

  @override String get hp => 'PV';
  @override String get ac => 'CA';
  @override String get initiative => 'Iniciativa';
  @override String get speed => 'Velocidade';
  @override String get proficiency => 'Competencia';
  @override String get manageHp => 'Xestionar PV';

  @override String get actions => 'Accións';
  @override String get bonusActions => 'Accións adicionais';
  @override String get reactions => 'Reaccións';
  @override String get deathSavingThrows => 'Tiradas de Morte';
  @override String get successes => 'Éxitos';
  @override String get failures => 'Fallos';
  @override String get hitDiceAndSpeed => 'Dados de Golpe e Velocidade';
  @override String get hitDice => 'Dados de Golpe';
  @override String get howManyUse => 'Cantos vas a usar?';
  @override String get available => 'dispoñibles';

  @override String get manageSpells => 'Xestionar Feitizos';
  @override String get mySpells => 'Os Meus Feitizos';
  @override String get learnNew => 'Aprender';
  @override String get prepared => 'PREPARADO';
  @override String get saveDC => 'CD SALVACIÓN';
  @override String get attack => 'ATAQUE';
  @override String get learnSpellTitle => 'Aprender feitizo?';
  @override String get learnButton => 'Aprender';
  @override String get removeSpellTitle => 'Eliminar feitizo?';
  @override String get removeButton => 'Eliminar';
  @override String get castButton => 'LANZAR';
  @override String get learnNewSpell => 'Aprender Novo Feitizo';

  @override String get settings => 'Axustes';
  @override String get editCharacter => 'Editar Personaxe';
  @override String get levelUp => 'Subir Nivel';
  @override String get language => 'Idioma';
  @override String get levelUpButton => 'Subir Nivel!';

  @override String get longRest => 'Longo';
  @override String get shortRest => 'Curto';
  @override String get longRestTitle => 'Descanso Longo';
  @override String get shortRestTitle => 'Descanso Curto';
  @override String get rest => 'Descansar';
  @override String get rollDice => 'Tirar dados';
  @override String get characterSheet => 'Folla de Personaxe';
  @override String get damage => 'Dano';
  @override String get heal => 'Curar';
  @override String get tempHp => 'PV Temp';

  @override String get langEnglish => 'English';
  @override String get langSpanish => 'Castellano';
  @override String get langGalician => 'Galego';

  @override String get abilityScores => 'Puntuacións de Atributos';
  @override String get savingThrows => 'Tiradas de Salvación';
  @override String get str => 'FUE';
  @override String get dex => 'DES';
  @override String get con => 'CON';
  @override String get intAttr => 'INT';
  @override String get wis => 'SAB';
  @override String get cha => 'CAR';
  @override String get level => 'Nivel';
  @override String get standardActions => 'Accións estándar';

  @override String levelUpContent(String name, int nextLevel) =>
      'Subir de nivel a $name ata o nivel $nextLevel?';
  @override String removeSpellContent(String spellName) =>
      'Eliminar "$spellName" do teu libro de feitizos?';
  @override String spellLearned(String spellName) => 'Feitizo aprendido: "$spellName"';
  @override String availableCount(int count) => '$count dispoñibles';
  @override String newCharacterCount(int count, int max) =>
      'Novo Personaxe ($count / $max)';
}

// ── Delegate ──────────────────────────────────────────────────────────────────

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'gl'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) => SynchronousFuture(
        switch (locale.languageCode) {
          'es' => _EsStrings(),
          'gl' => _GlStrings(),
          _ => _EnStrings(),
        },
      );

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}
