import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/l10n/app_strings.dart';

String _lang(BuildContext context) => Localizations.localeOf(context).languageCode;
String _norm(String s) => s
    .trim()
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ñ', 'n');

String localizeKnownName(BuildContext context, String raw) {
  final key = _norm(raw);
  final lang = _lang(context);
  const es = {
    'barbarian': 'Bárbaro',
    'bard': 'Bardo',
    'cleric': 'Clérigo',
    'druid': 'Druida',
    'fighter': 'Guerrero',
    'monk': 'Monje',
    'paladin': 'Paladín',
    'ranger': 'Explorador',
    'rogue': 'Pícaro',
    'sorcerer': 'Hechicero',
    'warlock': 'Brujo',
    'wizard': 'Mago',
    'dragonborn': 'Dracónido',
    'dwarf': 'Enano',
    'dward': 'Enano',
    'elf': 'Elfo',
    'gnome': 'Gnomo',
    'half-elf': 'Semielfo',
    'half-orc': 'Semiorco',
    'halfling': 'Mediano',
    'human': 'Humano',
    'tiefling': 'Tiefling',
    'acolyte': 'Acólito',
    'charlatan': 'Charlatán',
    'criminal': 'Criminal',
    'entertainer': 'Artista',
    'folk hero': 'Héroe del pueblo',
    'guild artisan': 'Artesano gremial',
    'hermit': 'Ermitaño',
    'noble': 'Noble',
    'outlander': 'Forastero',
    'sage': 'Sabio',
    'sailor': 'Marinero',
    'soldier': 'Soldado',
    'urchin': 'Huérfano callejero',
    'draconic ancestry': 'Ascendencia dracónica',
    'breath weapon': 'Arma de aliento',
    'damage resistance': 'Resistencia al daño',
    'dwarven toughness': 'Dureza enana',
    'dwarven armor training': 'Entrenamiento con armadura enana',
    'tool proficiency': 'Competencia con herramientas',
    'extra language': 'Idioma adicional',
    'high elf cantrip': 'Truco de elfo de las alturas',
    'skill versatility': 'Versatilidad de habilidades',
    'smith\'s tools': 'Herramientas de herrero',
    'brewer\'s supplies': 'Suministros de cervecero',
    'mason\'s tools': 'Herramientas de albañil',
    'black': 'Negro',
    'blue': 'Azul',
    'brass': 'Latón',
    'bronze': 'Bronce',
    'copper': 'Cobre',
    'gold': 'Oro',
    'green': 'Verde',
    'red': 'Rojo',
    'silver': 'Plata',
    'white': 'Blanco',
  };
  const gl = {
    'barbarian': 'Bárbaro',
    'bard': 'Bardo',
    'cleric': 'Clérigo',
    'druid': 'Druida',
    'fighter': 'Guerreiro',
    'monk': 'Monxe',
    'paladin': 'Paladín',
    'ranger': 'Explorador',
    'rogue': 'Pícaro',
    'sorcerer': 'Feiticeiro',
    'warlock': 'Bruxo',
    'wizard': 'Mago',
    'dragonborn': 'Dracónido',
    'dwarf': 'Anano',
    'dward': 'Anano',
    'elf': 'Elfo',
    'gnome': 'Gnomo',
    'half-elf': 'Semielfo',
    'half-orc': 'Semiorco',
    'halfling': 'Mediano',
    'human': 'Humano',
    'tiefling': 'Tiefling',
    'draconic ancestry': 'Ascendencia dracónica',
    'breath weapon': 'Arma de alento',
    'damage resistance': 'Resistencia ao dano',
    'dwarven toughness': 'Dureza anana',
    'dwarven armor training': 'Adestramento con armadura anana',
    'tool proficiency': 'Competencia con ferramentas',
    'extra language': 'Idioma adicional',
    'high elf cantrip': 'Truco de elfo das alturas',
    'skill versatility': 'Versatilidade de habilidades',
    'smith\'s tools': 'Ferramentas de ferreiro',
    'brewer\'s supplies': 'Subministracións de cervexeiro',
    'mason\'s tools': 'Ferramentas de canteiro',
    'black': 'Negro',
    'blue': 'Azul',
    'brass': 'Latón',
    'bronze': 'Bronce',
    'copper': 'Cobre',
    'gold': 'Ouro',
    'green': 'Verde',
    'red': 'Vermello',
    'silver': 'Prata',
    'white': 'Branco',
  };
  if (lang == 'es') return es[key] ?? raw;
  if (lang == 'gl') return gl[key] ?? raw;
  return raw;
}

String localizeClassDescription(BuildContext context, String classIndexName, String fallback) {
  if (_lang(context) == 'en') return fallback;
  final key = _norm(classIndexName);
  const es = {
    'barbarian': 'Los bárbaros son guerreros primitivos de gran fortaleza. Su poder nace de una furia interior que les otorga resistencia sobrehumana en combate.',
    'bard': 'Los bardos tejen la magia a través de palabras y música. Inspiran a sus aliados y desconciertan a sus enemigos con sus proezas arcanas.',
    'cleric': 'Los clérigos son intermediarios entre el mundo mortal y los planos divinos. Empuñan el poder de su deidad para curar, proteger y destruir.',
    'druid': 'Los druidas encarnan la fuerza de la naturaleza y pueden adoptar formas animales para proteger el equilibrio natural.',
    'fighter': 'Los guerreros son maestros del combate con armas y armaduras, con técnicas marciales que los hacen letales en batalla.',
    'monk': 'Los monjes dominan el ki para superar límites físicos y enfrentar al enemigo con disciplina y precisión.',
    'paladin': 'Los paladines son guerreros sagrados que juran defender sus ideales con acero, magia divina y auras protectoras.',
    'ranger': 'Los exploradores son cazadores y rastreadores de tierras salvajes, expertos en combate y supervivencia.',
    'rogue': 'Los pícaros confían en la astucia, el sigilo y el ataque sorpresa para imponerse en las sombras.',
    'sorcerer': 'Los hechiceros poseen poder mágico innato y canalizan la magia de forma instintiva.',
    'warlock': 'Los brujos obtienen su poder de un pacto con entidades sobrenaturales.',
    'wizard': 'Los magos aprenden la magia mediante estudio riguroso y una gran versatilidad de hechizos.',
  };
  const gl = {
    'barbarian': 'Os bárbaros son guerreiros primitivos de gran fortaleza; a súa rabia convérteos en máquinas de destrución no combate.',
    'bard': 'Os bardos tecen a maxia con palabras e música, inspirando aliados e desconcertando inimigos.',
    'cleric': 'Os clérigos son intermediarios entre o mundo mortal e os planos divinos, capaces de curar, protexer e destruír.',
    'druid': 'Os druídas encarnan a forza da natureza e poden adoptar formas animais para preservar o equilibrio natural.',
    'fighter': 'Os guerreiros son mestres do combate con armas e armaduras, cun amplo repertorio de técnicas marciais.',
    'monk': 'Os monxes dominan o ki para superar límites físicos e combater con disciplina.',
    'paladin': 'Os paladinos son guerreiros sagrados que xuran defender os seus ideais con poder marcial e divino.',
    'ranger': 'Os exploradores son cazadores e rastrexadores de terras salvaxes, expertos en combate e supervivencia.',
    'rogue': 'Os pícaros confían na astucia, o sixilo e o ataque sorpresa para vencer.',
    'sorcerer': 'Os feiticeiros posúen maxia innata e canalízana de forma instintiva.',
    'warlock': 'Os bruxos obteñen o seu poder dun pacto con entidades sobrenaturais.',
    'wizard': 'Os magos aprenden a maxia mediante estudo rigoroso e gran versatilidade de feitizos.',
  };
  if (_lang(context) == 'es') return es[key] ?? fallback;
  return gl[key] ?? fallback;
}

String localizeAbilityCode(BuildContext context, String raw) {
  final s = AppStrings.of(context);
  switch (raw.trim().toLowerCase()) {
    case 'str':
    case 'strength':
      return s.str;
    case 'dex':
    case 'dexterity':
      return s.dex;
    case 'con':
    case 'constitution':
      return s.con;
    case 'int':
    case 'intelligence':
      return s.intAttr;
    case 'wis':
    case 'wisdom':
      return s.wis;
    case 'cha':
    case 'charisma':
      return s.cha;
    default:
      return raw.toUpperCase();
  }
}

String localizeAlignment(BuildContext context, String raw) {
  final key = _norm(raw);
  final lang = _lang(context);
  const es = {
    'lawful good': 'Legal bueno',
    'neutral good': 'Neutral bueno',
    'chaotic good': 'Caótico bueno',
    'lawful neutral': 'Legal neutral',
    'true neutral': 'Neutral verdadero',
    'neutral': 'Neutral',
    'chaotic neutral': 'Caótico neutral',
    'lawful evil': 'Legal malvado',
    'neutral evil': 'Neutral malvado',
    'chaotic evil': 'Caótico malvado',
    'lawful': 'Legal',
    'chaotic': 'Caótico',
    'good': 'Bueno',
    'evil': 'Malvado',
    'lg': 'LB',
    'ng': 'NB',
    'cg': 'CB',
    'ln': 'LN',
    'tn': 'NV',
    'cn': 'CN',
    'le': 'LM',
    'ne': 'NM',
    'ce': 'CM',
  };
  const gl = {
    'lawful good': 'Leal bo',
    'neutral good': 'Neutral bo',
    'chaotic good': 'Caótico bo',
    'lawful neutral': 'Leal neutral',
    'true neutral': 'Neutral verdadeiro',
    'neutral': 'Neutral',
    'chaotic neutral': 'Caótico neutral',
    'lawful evil': 'Leal malvado',
    'neutral evil': 'Neutral malvado',
    'chaotic evil': 'Caótico malvado',
    'lawful': 'Leal',
    'chaotic': 'Caótico',
    'good': 'Bo',
    'evil': 'Malvado',
    'lg': 'LB',
    'ng': 'NB',
    'cg': 'CB',
    'ln': 'LN',
    'tn': 'NV',
    'cn': 'CN',
    'le': 'LM',
    'ne': 'NM',
    'ce': 'CM',
  };
  if (lang == 'es') return es[key] ?? raw;
  if (lang == 'gl') return gl[key] ?? raw;
  return raw;
}

String localizeSpellSchool(BuildContext context, String raw) {
  final key = _norm(raw);
  final lang = _lang(context);
  const es = {
    'abjuration': 'Abjuración',
    'conjuration': 'Conjuración',
    'divination': 'Adivinación',
    'enchantment': 'Encantamiento',
    'evocation': 'Evocación',
    'illusion': 'Ilusión',
    'necromancy': 'Nigromancia',
    'transmutation': 'Transmutación',
  };
  const gl = {
    'abjuration': 'Abxuración',
    'conjuration': 'Conxuración',
    'divination': 'Adiviñación',
    'enchantment': 'Encantamento',
    'evocation': 'Evocación',
    'illusion': 'Ilusión',
    'necromancy': 'Nigromancia',
    'transmutation': 'Transmutación',
  };
  if (lang == 'es') return es[key] ?? raw;
  if (lang == 'gl') return gl[key] ?? raw;
  return raw;
}

String localizeDamageType(BuildContext context, String raw) {
  final key = _norm(raw);
  final lang = _lang(context);
  const es = {
    'acid': 'Ácido',
    'bludgeoning': 'Contundente',
    'cold': 'Frío',
    'fire': 'Fuego',
    'force': 'Fuerza',
    'lightning': 'Relámpago',
    'necrotic': 'Necrótico',
    'piercing': 'Perforante',
    'poison': 'Veneno',
    'psychic': 'Psíquico',
    'radiant': 'Radiante',
    'slashing': 'Cortante',
    'thunder': 'Trueno',
  };
  const gl = {
    'acid': 'Ácido',
    'bludgeoning': 'Contundente',
    'cold': 'Frío',
    'fire': 'Lume',
    'force': 'Forza',
    'lightning': 'Lampo',
    'necrotic': 'Necrótico',
    'piercing': 'Perforante',
    'poison': 'Veleno',
    'psychic': 'Psíquico',
    'radiant': 'Radiante',
    'slashing': 'Cortante',
    'thunder': 'Trono',
  };
  if (lang == 'es') return es[key] ?? raw;
  if (lang == 'gl') return gl[key] ?? raw;
  return raw;
}

String localizeWeaponProperty(BuildContext context, String raw) {
  final key = _norm(raw).replaceAll('_', '-');
  final lang = _lang(context);
  const es = {
    'ammunition': 'Munición',
    'finesse': 'Sutileza',
    'heavy': 'Pesada',
    'light': 'Ligera',
    'loading': 'Recarga',
    'range': 'Alcance',
    'reach': 'Alcance largo',
    'special': 'Especial',
    'thrown': 'Arrojadiza',
    'two-handed': 'A dos manos',
    'versatile': 'Versátil',
  };
  const gl = {
    'ammunition': 'Munición',
    'finesse': 'Sutileza',
    'heavy': 'Pesada',
    'light': 'Lixeira',
    'loading': 'Recarga',
    'range': 'Alcance',
    'reach': 'Alcance longo',
    'special': 'Especial',
    'thrown': 'Arroxadiza',
    'two-handed': 'A dúas mans',
    'versatile': 'Versátil',
  };
  if (lang == 'es') return es[key] ?? raw;
  if (lang == 'gl') return gl[key] ?? raw;
  return raw;
}

String localizeSkillOrProficiency(BuildContext context, String raw) {
  final key = raw
      .trim()
      .toLowerCase()
      .replaceAll('_', '-')
      .replaceAll(' ', '-')
      .replaceFirst(RegExp(r'^(skill|tool)-'), '');
  final lang = _lang(context);
  const es = {
    'acrobatics': 'Acrobacias',
    'animal-handling': 'Trato con animales',
    'arcana': 'Arcano',
    'athletics': 'Atletismo',
    'deception': 'Engaño',
    'history': 'Historia',
    'insight': 'Perspicacia',
    'intimidation': 'Intimidación',
    'investigation': 'Investigación',
    'medicine': 'Medicina',
    'nature': 'Naturaleza',
    'perception': 'Percepción',
    'performance': 'Interpretación',
    'persuasion': 'Persuasión',
    'religion': 'Religión',
    'sleight-of-hand': 'Juego de manos',
    'stealth': 'Sigilo',
    'survival': 'Supervivencia',
    'smith\'s-tools': 'Herramientas de herrero',
    'brewer\'s-supplies': 'Suministros de cervecero',
    'mason\'s-tools': 'Herramientas de albañil',
  };
  const gl = {
    'acrobatics': 'Acrobacias',
    'animal-handling': 'Trato con animais',
    'arcana': 'Arcano',
    'athletics': 'Atletismo',
    'deception': 'Engaño',
    'history': 'Historia',
    'insight': 'Perspicacia',
    'intimidation': 'Intimidación',
    'investigation': 'Investigación',
    'medicine': 'Medicina',
    'nature': 'Natureza',
    'perception': 'Percepción',
    'performance': 'Interpretación',
    'persuasion': 'Persuasión',
    'religion': 'Relixión',
    'sleight-of-hand': 'Xogo de mans',
    'stealth': 'Sixilo',
    'survival': 'Supervivencia',
    'smith\'s-tools': 'Ferramentas de ferreiro',
    'brewer\'s-supplies': 'Subministracións de cervexeiro',
    'mason\'s-tools': 'Ferramentas de canteiro',
  };
  if (lang == 'es') return es[key] ?? _titleCase(raw);
  if (lang == 'gl') return gl[key] ?? _titleCase(raw);
  return _titleCase(raw);
}

String _titleCase(String raw) {
  return raw
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

// ── Language names ────────────────────────────────────────────────────────────

String localizeLanguageName(BuildContext context, String raw) {
  final key = _norm(raw);
  final lang = _lang(context);
  const es = {
    'abyssal': 'Abisal',
    'celestial': 'Celestial',
    'deep speech': 'Habla profunda',
    'draconic': 'Dracónico',
    'dwarvish': 'Enano',
    'elvish': 'Élfico',
    'giant': 'Gigante',
    'gnomish': 'Gnomo',
    'goblin': 'Goblin',
    'halfling': 'Mediano',
    'infernal': 'Infernal',
    'orc': 'Orco',
    'primordial': 'Primordial',
    'sylvan': 'Silvano',
    'undercommon': 'Infracomún',
  };
  const gl = {
    'abyssal': 'Abismal',
    'celestial': 'Celestial',
    'deep speech': 'Fala profunda',
    'draconic': 'Dracónico',
    'dwarvish': 'Anano',
    'elvish': 'Élfico',
    'giant': 'Xigante',
    'gnomish': 'Gnomo',
    'goblin': 'Goblin',
    'halfling': 'Mediano',
    'infernal': 'Infernal',
    'orc': 'Orco',
    'primordial': 'Primordial',
    'sylvan': 'Silvano',
    'undercommon': 'Infracomún',
  };
  if (lang == 'es') return es[key] ?? raw;
  if (lang == 'gl') return gl[key] ?? raw;
  return raw;
}

String localizeLanguageDescription(BuildContext context, String raw) {
  final key = _norm(raw);
  final lang = _lang(context);
  const es = {
    'abyssal': 'Hablado por demonios; escritura: Infernal.',
    'celestial': 'Hablado por celestiales; escritura: Celestial.',
    'deep speech': 'Hablado por aboleths; sin escritura estándar.',
    'draconic': 'Hablado por dragones y dracónidos; escritura: Dracónico.',
    'dwarvish': 'Hablado por enanos; escritura: Enano.',
    'elvish': 'Hablado por elfos; escritura: Élfico.',
    'giant': 'Hablado por ogros y gigantes; escritura: Enano.',
    'gnomish': 'Hablado por gnomos; escritura: Enano.',
    'goblin': 'Hablado por goblins; escritura: Enano.',
    'halfling': 'Hablado por medianos; escritura: Común.',
    'infernal': 'Hablado por diablos; escritura: Infernal.',
    'orc': 'Hablado por orcos; escritura: Enano.',
    'primordial': 'Hablado por elementales; escritura: Enano.',
    'sylvan': 'Hablado por criaturas feéricas; escritura: Élfico.',
    'undercommon': 'Lengua comercial del Inframundo; escritura: Élfico.',
  };
  const gl = {
    'abyssal': 'Falado por demos; escritura: Infernal.',
    'celestial': 'Falado por celestiais; escritura: Celestial.',
    'deep speech': 'Falado por aboleths; sen escritura estándar.',
    'draconic': 'Falado por dragóns e dracónidos; escritura: Dracónico.',
    'dwarvish': 'Falado por ananos; escritura: Anano.',
    'elvish': 'Falado por elfos; escritura: Élfico.',
    'giant': 'Falado por ogros e xigantes; escritura: Anano.',
    'gnomish': 'Falado por gnomos; escritura: Anano.',
    'goblin': 'Falado por goblins; escritura: Anano.',
    'halfling': 'Falado por medianos; escritura: Común.',
    'infernal': 'Falado por diabos; escritura: Infernal.',
    'orc': 'Falado por orcos; escritura: Anano.',
    'primordial': 'Falado por elementais; escritura: Anano.',
    'sylvan': 'Falado por criaturas féericas; escritura: Élfico.',
    'undercommon': 'Lingua comercial do Inframundo; escritura: Élfico.',
  };
  if (lang == 'es') return es[key] ?? raw;
  if (lang == 'gl') return gl[key] ?? raw;
  return raw;
}

// ── Skill descriptions ────────────────────────────────────────────────────────

String localizeSkillDescription(BuildContext context, String skillName) {
  final key = _norm(skillName).replaceAll(' ', '-').replaceAll('\'', '');
  final lang = _lang(context);
  const es = {
    'acrobatics': 'DES — volteretas, equilibrio.',
    'animal-handling': 'SAB — calmar, controlar animales.',
    'arcana': 'INT — conocimiento mágico, hechizos, planos.',
    'athletics': 'FUE — escalar, saltar, nadar.',
    'deception': 'CAR — mentir, disfrazarse, desviar.',
    'history': 'INT — eventos, personajes, leyendas.',
    'insight': 'SAB — leer personas, detectar mentiras.',
    'intimidation': 'CAR — amenazas, coaccionar.',
    'investigation': 'INT — buscar, deducir pistas.',
    'medicine': 'SAB — estabilizar, diagnosticar.',
    'nature': 'INT — terreno, plantas, clima, criaturas.',
    'perception': 'SAB — notar cosas con los sentidos.',
    'performance': 'CAR — actuar, cantar, tocar instrumentos.',
    'persuasion': 'CAR — diplomacia, negociar.',
    'religion': 'INT — deidades, cultos, rituales.',
    'sleight-of-hand': 'DES — hurtar, ocultar.',
    'stealth': 'DES — esconderse, moverse en silencio.',
    'survival': 'SAB — rastrear, forrajear, navegar.',
  };
  const gl = {
    'acrobatics': 'DES — volteretas, equilibrio.',
    'animal-handling': 'SAB — calmar, controlar animais.',
    'arcana': 'INT — coñecemento máxico, feitizos, planos.',
    'athletics': 'FOR — escalar, saltar, nadar.',
    'deception': 'CAR — mentir, disfrazarse, desviar.',
    'history': 'INT — eventos, personaxes, lendas.',
    'insight': 'SAB — ler persoas, detectar mentiras.',
    'intimidation': 'CAR — ameazas, coaccionar.',
    'investigation': 'INT — buscar, deducir pistas.',
    'medicine': 'SAB — estabilizar, diagnosticar.',
    'nature': 'INT — terreo, plantas, clima, criaturas.',
    'perception': 'SAB — notar cousas cos sentidos.',
    'performance': 'CAR — actuar, cantar, tocar instrumentos.',
    'persuasion': 'CAR — diplomacia, negociar.',
    'religion': 'INT — deidades, cultos, rituais.',
    'sleight-of-hand': 'DES — furtar, ocultar.',
    'stealth': 'DES — esconderse, moverse en silencio.',
    'survival': 'SAB — rastrexar, forxear, navegar.',
  };
  if (lang == 'es') return es[key] ?? '';
  if (lang == 'gl') return gl[key] ?? '';
  return '';
}

// ── Option names/descriptions (fighting styles, enemies, terrains, etc.) ─────

String localizeOptionName(BuildContext context, String raw) {
  final key = _norm(raw);
  final lang = _lang(context);
  const es = {
    // Fighting styles
    'archery': 'Tiro con arco',
    'defense': 'Defensa',
    'dueling': 'Duelo',
    'great weapon fighting': 'Combate con arma grande',
    'protection': 'Protección',
    'two-weapon fighting': 'Combate con dos armas',
    'blind fighting': 'Combate a ciegas',
    'interception': 'Interceptación',
    'superior technique': 'Técnica superior',
    'thrown weapon fighting': 'Combate con armas arrojadizas',
    'unarmed fighting': 'Combate desarmado',
    // Favored enemies
    'aberrations': 'Aberraciones',
    'beasts': 'Bestias',
    'celestials': 'Celestiales',
    'constructs': 'Constructos',
    'dragons': 'Dragones',
    'elementals': 'Elementales',
    'fey': 'Hadas',
    'fiends': 'Diablos',
    'giants': 'Gigantes',
    'monstrosities': 'Monstruosidades',
    'oozes': 'Cienos',
    'plants': 'Plantas',
    'undead': 'No muertos',
    'two humanoid types': 'Dos tipos humanoides',
    // Favored terrains
    'arctic': 'Ártico',
    'coast': 'Costa',
    'desert': 'Desierto',
    'forest': 'Bosque',
    'grassland': 'Pradera',
    'mountain': 'Montaña',
    'swamp': 'Pantano',
    'underdark': 'Inframundo',
    // Totem animals
    'bear': 'Oso',
    'eagle': 'Águila',
    'wolf': 'Lobo',
    // Hunter
    'colossus slayer': 'Cazador de colosos',
    'giant killer': 'Matagigantas',
    'horde breaker': 'Rompe hordas',
    'escape the horde': 'Escapar de la horda',
    'multiattack defense': 'Defensa multicombate',
    'steel will': 'Voluntad de acero',
    'volley': 'Descarga',
    'whirlwind attack': 'Ataque en torbellino',
    'evasion': 'Evasión',
    'stand against the tide': 'Resistir la marea',
    'uncanny dodge': 'Esquiva prodigiosa',
    // Metamagic
    'careful spell': 'Hechizo cuidadoso',
    'distant spell': 'Hechizo distante',
    'empowered spell': 'Hechizo potenciado',
    'extended spell': 'Hechizo extendido',
    'heightened spell': 'Hechizo intensificado',
    'quickened spell': 'Hechizo acelerado',
    'subtle spell': 'Hechizo sutil',
    'twinned spell': 'Hechizo gemelo',
    // Abilities
    'strength': 'Fuerza',
    'dexterity': 'Destreza',
    'constitution': 'Constitución',
    'intelligence': 'Inteligencia',
    'wisdom': 'Sabiduría',
    'charisma': 'Carisma',
  };
  const gl = {
    // Fighting styles
    'archery': 'Tiro con arco',
    'defense': 'Defensa',
    'dueling': 'Duelo',
    'great weapon fighting': 'Combate con arma grande',
    'protection': 'Protección',
    'two-weapon fighting': 'Combate con dúas armas',
    'blind fighting': 'Combate ás cegas',
    'interception': 'Interceptación',
    'superior technique': 'Técnica superior',
    'thrown weapon fighting': 'Combate con armas arroxadizas',
    'unarmed fighting': 'Combate desarmado',
    // Favored enemies
    'aberrations': 'Aberracións',
    'beasts': 'Bestas',
    'celestials': 'Celestiais',
    'constructs': 'Constructos',
    'dragons': 'Dragóns',
    'elementals': 'Elementais',
    'fey': 'Fadas',
    'fiends': 'Diabos',
    'giants': 'Xigantes',
    'monstrosities': 'Monstruosidades',
    'oozes': 'Limos',
    'plants': 'Plantas',
    'undead': 'Non mortos',
    'two humanoid types': 'Dous tipos humanoides',
    // Favored terrains
    'arctic': 'Ártico',
    'coast': 'Costa',
    'desert': 'Deserto',
    'forest': 'Bosque',
    'grassland': 'Pradería',
    'mountain': 'Montaña',
    'swamp': 'Pantano',
    'underdark': 'Inframundo',
    // Totem animals
    'bear': 'Oso',
    'eagle': 'Aguia',
    'wolf': 'Lobo',
    // Hunter
    'colossus slayer': 'Cazador de colosos',
    'giant killer': 'Mataxigantes',
    'horde breaker': 'Rompe hordas',
    'escape the horde': 'Escapar da horda',
    'multiattack defense': 'Defensa multicombate',
    'steel will': 'Vontade de aceiro',
    'volley': 'Descarga',
    'whirlwind attack': 'Ataque en torbellino',
    'evasion': 'Evasión',
    'stand against the tide': 'Resistir a marea',
    'uncanny dodge': 'Esquiva prodixiosa',
    // Metamagic
    'careful spell': 'Feitizo coidadoso',
    'distant spell': 'Feitizo distante',
    'empowered spell': 'Feitizo potenciado',
    'extended spell': 'Feitizo estendido',
    'heightened spell': 'Feitizo intensificado',
    'quickened spell': 'Feitizo acelerado',
    'subtle spell': 'Feitizo sutil',
    'twinned spell': 'Feitizo xemelgo',
    // Abilities
    'strength': 'Forza',
    'dexterity': 'Destreza',
    'constitution': 'Constitución',
    'intelligence': 'Intelixencia',
    'wisdom': 'Sabedoría',
    'charisma': 'Carisma',
  };
  if (lang == 'es') return es[key] ?? raw;
  if (lang == 'gl') return gl[key] ?? raw;
  return raw;
}

String localizeOptionDescription(BuildContext context, String optionName) {
  final key = _norm(optionName);
  final lang = _lang(context);
  const es = {
    // Fighting styles
    'archery': '+2 de bonificación a las tiradas de ataque con armas a distancia.',
    'defense': '+1 a la CA mientras lleves armadura.',
    'dueling': '+2 al daño cuando empuñas un arma cuerpo a cuerpo en una mano y ninguna otra arma.',
    'great weapon fighting': 'Vuelve a tirar los 1s y 2s en dados de daño con armas de dos manos.',
    'protection': 'Imponer desventaja en ataques contra aliados a 1,5 m (requiere escudo).',
    'two-weapon fighting': 'Añade el modificador de habilidad al daño de tu ataque con la mano secundaria.',
    'blind fighting': 'Tienes visión ciega hasta 3 m.',
    'interception': 'Reduce el daño a una criatura a 1,5 m en 1d10 + bonificador de competencia (reacción).',
    'superior technique': 'Aprende una maniobra y obtén un dado de superioridad (d6).',
    'thrown weapon fighting': '+2 al daño con armas arrojadizas; puedes sacarlas como parte del ataque.',
    'unarmed fighting': 'Los golpes desarmados hacen 1d6 (1d8 con manos libres). Las criaturas aferradas reciben 1d4 de daño al inicio de tu turno.',
    // Favored enemies
    'aberrations': 'Aberraciones: aboleth, beholder y otros horrores alienígenas.',
    'beasts': 'Bestias: animales y otras criaturas naturales.',
    'celestials': 'Celestiales: ángeles, unicornios y otras criaturas divinas.',
    'constructs': 'Constructos: gólems, objetos animados y similares.',
    'dragons': 'Dragones: dragones verdaderos y criaturas relacionadas.',
    'elementals': 'Elementales: criaturas de los planos elementales.',
    'fey': 'Hadas: sprites, dríadas y otras criaturas feéricas.',
    'fiends': 'Diablos: demonios, diablos y similares.',
    'giants': 'Gigantes: gigantes de colina, gigantes de tormenta y parientes.',
    'monstrosities': 'Monstruosidades: monstruos de origen desconocido.',
    'oozes': 'Cienos: cubos gelatinosos, pudines negros, etc.',
    'plants': 'Plantas: montículos deambulantes, treants y similares.',
    'undead': 'No muertos: zombis, vampiros, fantasmas y similares.',
    'two humanoid types': 'Elige dos razas humanoides (p.ej. orcos y gnolls).',
    // Favored terrains
    'arctic': 'Tundra y tierras heladas.',
    'coast': 'Costas, playas y zonas de marea.',
    'desert': 'Entornos desérticos fríos o calientes.',
    'forest': 'Densos bosques y junglas.',
    'grassland': 'Praderas, sabanas y llanuras.',
    'mountain': 'Terreno rocoso de alta altitud.',
    'swamp': 'Humedales, marismas y ciénagas.',
    'underdark': 'Túneles subterráneos y cavernas.',
    // Totem Spirit
    'bear': 'Resistencia a todo el daño excepto psíquico mientras estás en furia.',
    'eagle': 'Correr como acción adicional mientras estás en furia; desventaja en ataques de oportunidad contra ti.',
    'wolf': 'Los aliados tienen ventaja en ataques cuerpo a cuerpo contra criaturas adyacentes a ti mientras estás en furia.',
    // Metamagic
    'careful spell': 'Hasta CHA criaturas superan automáticamente las salvaciones contra tu hechizo. (1 PM)',
    'distant spell': 'Duplica el alcance de un hechizo; los de toque pasan a 9 m. (1 PM)',
    'empowered spell': 'Vuelve a tirar hasta CHA dados de daño (mantén los nuevos). Combinable. (1 PM)',
    'extended spell': 'Duplica la duración de un hechizo (máx. 24 h). (1 PM)',
    'heightened spell': 'Un objetivo falla automáticamente su primera salvación contra tu hechizo. (3 PM)',
    'quickened spell': 'Cambia el tiempo de lanzamiento de 1 acción a 1 acción adicional. (2 PM)',
    'subtle spell': 'Lanza sin componentes verbales ni somáticos. (1 PM)',
    'twinned spell': 'Afecta a una segunda criatura con un hechizo de un solo objetivo. (PM = nivel, mín. 1)',
    // Hunter subclass
    'colossus slayer': 'Una vez por turno, inflige 1d8 de daño extra a una criatura por debajo de sus PG máximos.',
    'giant killer': 'Reacción: realiza un ataque contra una criatura Grande o mayor que te falle a distancia de alcance.',
    'horde breaker': 'Una vez por turno, ataca a una segunda criatura adyacente al primer objetivo (misma acción).',
    'escape the horde': 'Los ataques de oportunidad contra ti se realizan con desventaja.',
    'multiattack defense': 'Tras ser golpeado por una criatura, obtén +4 CA contra sus ataques posteriores este turno.',
    'steel will': 'Ventaja en las salvaciones contra el miedo.',
    'volley': 'Usa tu acción para atacar a distancia a todas las criaturas a 3 m de un punto elegido.',
    'whirlwind attack': 'Usa tu acción para realizar un ataque cuerpo a cuerpo contra todas las criaturas a 1,5 m de ti.',
    'evasion': 'Medio daño en salvaciones de DES fallidas; sin daño en éxito.',
    'stand against the tide': 'Reacción cuando una criatura te falla: fuerza a que repita el ataque contra otra criatura.',
    'uncanny dodge': 'Reacción: reduce a la mitad el daño de un ataque que ves.',
    // Ability scores
    'strength': 'FUE',
    'dexterity': 'DES',
    'constitution': 'CON',
    'intelligence': 'INT',
    'wisdom': 'SAB',
    'charisma': 'CAR',
  };
  const gl = {
    // Fighting styles
    'archery': '+2 de bonificación ás tiradas de ataque con armas a distancia.',
    'defense': '+1 á CA mentres levas armadura.',
    'dueling': '+2 ao dano cando empuñas unha arma corpo a corpo nunha man e ningunha outra arma.',
    'great weapon fighting': 'Volve tirar os 1s e 2s en dados de dano con armas de dúas mans.',
    'protection': 'Impor desvantaxe en ataques contra aliados a 1,5 m (require escudo).',
    'two-weapon fighting': 'Engade o modificador de habilidade ao dano do teu ataque coa man secundaria.',
    'blind fighting': 'Tes visión cega ata 3 m.',
    'interception': 'Reduce o dano a unha criatura a 1,5 m en 1d10 + bonificador de competencia (reacción).',
    'superior technique': 'Aprende unha manobra e obtén un dado de superioridade (d6).',
    'thrown weapon fighting': '+2 ao dano con armas arroxadizas; podes sacalas como parte do ataque.',
    'unarmed fighting': 'Os golpes desarmados fan 1d6 (1d8 con mans libres). As criaturas aferradas reciben 1d4 ao inicio do teu turno.',
    // Favored enemies
    'aberrations': 'Aberracións: aboleth, beholder e outros horrores alieníxenas.',
    'beasts': 'Bestas: animais e outras criaturas naturais.',
    'celestials': 'Celestiais: anxos, unicornios e outras criaturas divinas.',
    'constructs': 'Constructos: gólems, obxectos animados e similares.',
    'dragons': 'Dragóns: dragóns verdadeiros e criaturas relacionadas.',
    'elementals': 'Elementais: criaturas dos planos elementais.',
    'fey': 'Fadas: sprites, dríadas e outras criaturas féericas.',
    'fiends': 'Diabos: demos, diabos e similares.',
    'giants': 'Xigantes: xigantes de outeiro, xigantes de tormenta e parentes.',
    'monstrosities': 'Monstruosidades: monstros de orixe descoñecida.',
    'oozes': 'Limos: cubos xelatinosos, pudíns negros, etc.',
    'plants': 'Plantas: montículos deambulantes, treants e similares.',
    'undead': 'Non mortos: zombis, vampiros, pantasmas e similares.',
    'two humanoid types': 'Escolle dúas razas humanoides (ex.: orcos e gnolls).',
    // Favored terrains
    'arctic': 'Tundra e terras xeadas.',
    'coast': 'Costas, praias e zonas de marea.',
    'desert': 'Entornos desérticos fríos ou quentes.',
    'forest': 'Densos bosques e xunglas.',
    'grassland': 'Praderías, sabanas e chairas.',
    'mountain': 'Terreo rochoso de alta altitude.',
    'swamp': 'Humedais, marismas e lameiros.',
    'underdark': 'Túneles subterráneos e cavernas.',
    // Totem Spirit
    'bear': 'Resistencia a todo o dano agás psíquico mentres estás en furia.',
    'eagle': 'Correr como acción adicional mentres estás en furia; desvantaxe en ataques de oportunidade contra ti.',
    'wolf': 'Os aliados teñen vantaxe en ataques corpo a corpo contra criaturas adxacentes a ti mentres estás en furia.',
    // Metamagic
    'careful spell': 'Ata CAR criaturas superan automaticamente as salvacións contra o teu feitizo. (1 PM)',
    'distant spell': 'Duplica o alcance dun feitizo; os de toque pasan a 9 m. (1 PM)',
    'empowered spell': 'Volve tirar ata CAR dados de dano (mantén os novos). Combinable. (1 PM)',
    'extended spell': 'Duplica a duración dun feitizo (máx. 24 h). (1 PM)',
    'heightened spell': 'Un obxectivo falla automaticamente a súa primeira salvación contra o teu feitizo. (3 PM)',
    'quickened spell': 'Cambia o tempo de lanzamento de 1 acción a 1 acción adicional. (2 PM)',
    'subtle spell': 'Lanza sen compoñentes verbais nin somáticos. (1 PM)',
    'twinned spell': 'Afecta a unha segunda criatura cun feitizo de un só obxectivo. (PM = nivel, mín. 1)',
    // Hunter subclass
    'colossus slayer': 'Unha vez por turno, infle 1d8 de dano extra a unha criatura por baixo dos seus PG máximos.',
    'giant killer': 'Reacción: realiza un ataque contra unha criatura Grande ou maior que che falle a distancia de alcance.',
    'horde breaker': 'Unha vez por turno, ataca a unha segunda criatura adxacente ao primeiro obxectivo (mesma acción).',
    'escape the horde': 'Os ataques de oportunidade contra ti realízanse con desvantaxe.',
    'multiattack defense': 'Tras ser golpeado por unha criatura, obtén +4 CA contra os seus ataques posteriores este turno.',
    'steel will': 'Vantaxe nas salvacións contra o medo.',
    'volley': 'Usa a túa acción para atacar a distancia a todas as criaturas a 3 m dun punto escollido.',
    'whirlwind attack': 'Usa a túa acción para realizar un ataque corpo a corpo contra todas as criaturas a 1,5 m de ti.',
    'evasion': 'Medio dano en salvacións de DES fallidas; sen dano en éxito.',
    'stand against the tide': 'Reacción cando unha criatura che falla: forza a que repita o ataque contra outra criatura.',
    'uncanny dodge': 'Reacción: reduce á metade o dano dun ataque que ves.',
    // Ability scores
    'strength': 'FOR',
    'dexterity': 'DES',
    'constitution': 'CON',
    'intelligence': 'INT',
    'wisdom': 'SAB',
    'charisma': 'CAR',
  };
  if (lang == 'es') return es[key] ?? '';
  if (lang == 'gl') return gl[key] ?? '';
  return '';
}

// ── WizardChoiceConfig label localization ─────────────────────────────────────

String localizeWizardChoiceLabel(BuildContext context, String label) {
  final lang = _lang(context);
  // Strip trailing " (lv N)" or " (lv NN)" pattern for matching, re-add suffix.
  final lvMatch = RegExp(r'^(.*?)\s*\(lv\s*(\d+)\)$').firstMatch(label);
  final base = lvMatch != null ? lvMatch.group(1)!.trim() : label.trim();
  final lvSuffix = lvMatch != null
      ? ' (${lang == 'en' ? 'lv' : 'nv'} ${lvMatch.group(2)})'
      : '';

  // Match on numbered labels like "Maneuver 1", "Discipline 3", etc.
  final numMatch = RegExp(r'^(.*?)\s+(\d+)$').firstMatch(base);
  final baseCore = numMatch != null ? numMatch.group(1)!.trim().toLowerCase() : base.toLowerCase();
  final numSuffix = numMatch != null ? ' ${numMatch.group(2)}' : '';

  final String translated;
  if (lang == 'es') {
    translated = switch (baseCore) {
      'fighting style' => 'Estilo de combate',
      'favored enemy' => 'Enemigo favorito',
      'natural explorer terrain' => 'Terreno de explorador',
      'draconic ancestry' => 'Ascendencia dracónica',
      'ability score improvement' => 'Mejora de puntuación de habilidad',
      'expertise' => 'Pericia',
      'metamagic' => 'Metamagia',
      'eldritch invocations' => 'Invocaciones sobrenaturales',
      'extra language' => 'Idioma adicional',
      'skill versatility — first skill' => 'Versatilidad — primera habilidad',
      'skill versatility — second skill' => 'Versatilidad — segunda habilidad',
      'skill versatility' => 'Versatilidad de habilidades',
      'tool proficiency' => 'Competencia con herramientas',
      'high elf cantrip (wizard cantrip)' => 'Truco de elfo de las alturas',
      'high elf cantrip' => 'Truco de elfo de las alturas',
      "hunter's prey" => 'Presa del cazador',
      'defensive tactics' => 'Tácticas defensivas',
      'multiattack' => 'Multicombate',
      "superior hunter's defense" => 'Defensa superior del cazador',
      'totem spirit' => 'Espíritu totémico',
      'aspect of the beast' => 'Aspecto de la bestia',
      'totemic attunement' => 'Sintonía totémica',
      'maneuver' => 'Maniobra',
      'discipline' => 'Disciplina',
      'bonus proficiencies (3 skills)' => 'Competencias adicionales (3 habilidades)',
      _ => base,
    };
  } else if (lang == 'gl') {
    translated = switch (baseCore) {
      'fighting style' => 'Estilo de combate',
      'favored enemy' => 'Inimigo favorito',
      'natural explorer terrain' => 'Terreo de explorador',
      'draconic ancestry' => 'Ascendencia dracónica',
      'ability score improvement' => 'Mellora de puntuación de habilidade',
      'expertise' => 'Pericia',
      'metamagic' => 'Metamaxia',
      'eldritch invocations' => 'Invocacións sobrenaturais',
      'extra language' => 'Idioma adicional',
      'skill versatility — first skill' => 'Versatilidade — primeira habilidade',
      'skill versatility — second skill' => 'Versatilidade — segunda habilidade',
      'skill versatility' => 'Versatilidade de habilidades',
      'tool proficiency' => 'Competencia con ferramentas',
      'high elf cantrip (wizard cantrip)' => 'Truco de elfo das alturas',
      'high elf cantrip' => 'Truco de elfo das alturas',
      "hunter's prey" => 'Presa do cazador',
      'defensive tactics' => 'Tácticas defensivas',
      'multiattack' => 'Multicombate',
      "superior hunter's defense" => 'Defensa superior do cazador',
      'totem spirit' => 'Espírito totémico',
      'aspect of the beast' => 'Aspecto da besta',
      'totemic attunement' => 'Sintonía totémica',
      'maneuver' => 'Manobra',
      'discipline' => 'Disciplina',
      'bonus proficiencies (3 skills)' => 'Competencias adicionais (3 habilidades)',
      _ => base,
    };
  } else {
    translated = base;
  }

  return '$translated$numSuffix$lvSuffix';
}