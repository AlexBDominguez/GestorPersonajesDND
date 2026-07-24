import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/admin/content_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';

/// #9 (panel de admin): creación manual de contenido de personaje -- clase, subclase, raza,
/// subraza e item -- sin depender de sync externo ni scripts SQL. Un selector de "tipo de
/// contenido" en la parte de arriba adapta los campos del formulario, mismo patrón que
/// CreateSubclassFeatureScreen usa para el tipo de mecánica.
///
/// Alcance deliberado de v1: campos básicos que los servicios de creación ya existentes
/// (DndClassService/SubclassService/SubraceService, más los nuevos RaceService/ItemController
/// de esta misma pieza) realmente persisten -- no se exponen campos que esos servicios
/// ignorarían en silencio (ej. DndClassService.create() no usa spellcastingAbility/
/// skillChoiceCount todavía pese a que DndClassDto los tiene, así que este formulario tampoco
/// los pide).
class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

const _contentTypes = <String, String>{
  'CLASS': 'Class',
  'SUBCLASS': 'Subclass',
  'RACE': 'Race',
  'SUBRACE': 'Subrace',
  'ITEM': 'Item',
  'BACKGROUND': 'Background',
  'FEAT': 'Feat',
};

const _effectModifierTypes = <String>[
  'AC', 'ATTACK_ROLL', 'DAMAGE', 'SAVING_THROW', 'ABILITY_CHECK', 'SKILL_CHECK',
  'INITIATIVE', 'SPEED', 'HP_MAX', 'ADVANTAGE', 'DISADVANTAGE', 'RESISTANCE',
  'VULNERABILITY', 'IMMUNITY',
];

const _abilityKeys = <String, String>{
  'str': 'Strength',
  'dex': 'Dexterity',
  'con': 'Constitution',
  'int': 'Intelligence',
  'wis': 'Wisdom',
  'cha': 'Charisma',
};

class _CreateContentScreenState extends State<CreateContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ContentAdminService();

  String _contentType = 'CLASS';
  bool _loadingRefs = true;
  String? _loadError;
  List<ClassAdminOption> _classes = [];
  List<RaceAdminOption> _races = [];

  // Common
  final _indexNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Class
  final _hitDieCtrl = TextEditingController();
  final _proficienciesCtrl = TextEditingController();

  // Subclass
  ClassAdminOption? _selectedClass;
  final _subclassFlavorCtrl = TextEditingController();
  String? _spellcastingAbility;

  // Race / Subrace
  RaceAdminOption? _selectedRace;
  final _sizeCtrl = ValueNotifier<String>('Medium');
  final _speedCtrl = TextEditingController(text: '30');
  final Map<String, TextEditingController> _abilityCtrls = {
    for (final k in _abilityKeys.keys) k: TextEditingController(text: '0'),
  };

  // Item
  final _itemTypeCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(text: '0');
  final _costCtrl = TextEditingController(text: '0');
  final _damageDiceCtrl = TextEditingController();
  final _damageTypeCtrl = TextEditingController();
  String _weaponRange = 'Melee';
  final _weaponPropertiesCtrl = TextEditingController();
  final _armorClassCtrl = TextEditingController();
  final _armorTypeCtrl = TextEditingController();
  final _rarityCtrl = TextEditingController();
  bool _requiresAttunement = false;
  final _bonusAcCtrl = TextEditingController(text: '0');
  final _bonusToHitCtrl = TextEditingController(text: '0');
  final _bonusDamageCtrl = TextEditingController(text: '0');
  final _bonusSavingThrowsCtrl = TextEditingController(text: '0');
  final Map<String, TextEditingController> _setToCtrls = {
    for (final k in _abilityKeys.keys) k: TextEditingController(),
  };

  // Background
  final _skillProficienciesCtrl = TextEditingController();
  final _toolProficienciesCtrl = TextEditingController();
  final _languagesCtrl = TextEditingController();
  final _languageOptionsCtrl = TextEditingController(text: '0');
  final _featureCtrl = TextEditingController();
  final _featureDescCtrl = TextEditingController();
  final _personalityTraitsCtrl = TextEditingController();
  final _idealsCtrl = TextEditingController();
  final _bondsCtrl = TextEditingController();
  final _flawsCtrl = TextEditingController();

  // Feat
  final _prerequisitesCtrl = TextEditingController();
  String? _effectModifierType;
  final _effectModifierValueCtrl = TextEditingController();
  final _choiceProficiencyCountCtrl = TextEditingController();
  final List<SpellSearchOption> _grantedSpells = [];

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRefs();
  }

  Future<void> _loadRefs() async {
    try {
      final classes = await _service.getAllClasses();
      final races = await _service.getAllRacesForAdmin();
      classes.sort((a, b) => a.name.compareTo(b.name));
      races.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) {
        setState(() { _classes = classes; _races = races; _loadingRefs = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString().replaceFirst('Exception: ', '');
          _loadingRefs = false;
        });
      }
    }
  }

  InputDecoration _decoration(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.textSecondary, size: 18) : null,
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      );

  Widget _text(TextEditingController ctrl, String label,
      {IconData? icon, TextInputType? keyboardType, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
      decoration: _decoration(label, icon: icon),
      validator: validator,
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  List<String>? _splitCommas(TextEditingController c) {
    final items = c.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return items.isEmpty ? null : items;
  }

  List<String>? _splitLines(TextEditingController c) {
    final items = c.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return items.isEmpty ? null : items;
  }

  Widget _sectionTitle(String label) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label,
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      );

  Widget _abilityBonusRow(Map<String, TextEditingController> ctrls, {String hint = '0'}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _abilityKeys.entries.map((e) {
        return SizedBox(
          width: 100,
          child: TextFormField(
            controller: ctrls[e.key],
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            decoration: _decoration(e.key.toUpperCase()),
          ),
        );
      }).toList(),
    );
  }

  Map<String, int> _abilityMap(Map<String, TextEditingController> ctrls) {
    final map = <String, int>{};
    for (final e in ctrls.entries) {
      final v = int.tryParse(e.value.text.trim()) ?? 0;
      if (v != 0) map[e.key] = v;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: const BackButton(color: AppTheme.textPrimary),
        title: Text('Create Content',
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loadingRefs
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _loadError != null
              ? Center(child: Text(_loadError!, style: GoogleFonts.lato(color: AppTheme.accent)))
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      DropdownButtonFormField<String>(
                        initialValue: _contentType,
                        decoration: _decoration('Content type', icon: Icons.category_outlined),
                        dropdownColor: AppTheme.surface,
                        style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
                        isExpanded: true,
                        items: _contentTypes.entries
                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) => setState(() { _contentType = v!; _error = null; }),
                      ),
                      const SizedBox(height: 20),
                      ..._buildFields(),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_error!,
                              style: GoogleFonts.lato(color: AppTheme.accent, fontSize: 14)),
                        ),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.background,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Create ${_contentTypes[_contentType]}',
                                  style: GoogleFonts.libreBaskerville(
                                      fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
                  ),
                ),
    );
  }

  List<Widget> _buildFields() {
    switch (_contentType) {
      case 'CLASS':
        return [
          _text(_indexNameCtrl, 'Index name (e.g. my-new-class)', icon: Icons.tag, validator: _required),
          const SizedBox(height: 16),
          _text(_nameCtrl, 'Name', icon: Icons.badge_outlined, validator: _required),
          const SizedBox(height: 16),
          _text(_hitDieCtrl, 'Hit die (e.g. 8 for d8)', icon: Icons.casino_outlined,
              keyboardType: TextInputType.number,
              validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a number' : null),
          const SizedBox(height: 16),
          _text(_proficienciesCtrl, 'Proficiencies (comma-separated)', icon: Icons.checklist),
          const SizedBox(height: 16),
          _text(_descCtrl, 'Description', icon: Icons.description_outlined, maxLines: 4, validator: _required),
        ];
      case 'SUBCLASS':
        return [
          DropdownButtonFormField<ClassAdminOption>(
            initialValue: _selectedClass,
            decoration: _decoration('Class', icon: Icons.school_outlined),
            dropdownColor: AppTheme.surface,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            isExpanded: true,
            items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => _selectedClass = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          _text(_indexNameCtrl, 'Index name (e.g. my-new-subclass)', icon: Icons.tag, validator: _required),
          const SizedBox(height: 16),
          _text(_nameCtrl, 'Name', icon: Icons.badge_outlined, validator: _required),
          const SizedBox(height: 16),
          _text(_subclassFlavorCtrl, 'Flavor tagline (optional)', icon: Icons.auto_awesome_outlined),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: _spellcastingAbility,
            decoration: _decoration('Spellcasting ability (optional)', icon: Icons.auto_stories_outlined),
            dropdownColor: AppTheme.surface,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('None')),
              ..._abilityKeys.entries
                  .map((e) => DropdownMenuItem<String?>(value: e.key, child: Text(e.value))),
            ],
            onChanged: (v) => setState(() => _spellcastingAbility = v),
          ),
          const SizedBox(height: 16),
          _text(_descCtrl, 'Description', icon: Icons.description_outlined, maxLines: 4, validator: _required),
        ];
      case 'RACE':
        return [
          _text(_indexNameCtrl, 'Index name (e.g. my-new-race)', icon: Icons.tag, validator: _required),
          const SizedBox(height: 16),
          _text(_nameCtrl, 'Name', icon: Icons.badge_outlined, validator: _required),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: _sizeCtrl,
            builder: (_, size, __) => DropdownButtonFormField<String>(
              initialValue: size,
              decoration: _decoration('Size', icon: Icons.straighten_outlined),
              dropdownColor: AppTheme.surface,
              style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
              items: const ['Small', 'Medium', 'Large']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => _sizeCtrl.value = v!,
            ),
          ),
          const SizedBox(height: 16),
          _text(_speedCtrl, 'Speed (feet)', icon: Icons.directions_walk,
              keyboardType: TextInputType.number,
              validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a number' : null),
          const SizedBox(height: 16),
          _sectionTitle('Ability score bonuses'),
          _abilityBonusRow(_abilityCtrls),
          const SizedBox(height: 16),
          _text(_descCtrl, 'Description', icon: Icons.description_outlined, maxLines: 4, validator: _required),
        ];
      case 'SUBRACE':
        return [
          DropdownButtonFormField<RaceAdminOption>(
            initialValue: _selectedRace,
            decoration: _decoration('Race', icon: Icons.groups_outlined),
            dropdownColor: AppTheme.surface,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            isExpanded: true,
            items: _races.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
            onChanged: (v) => setState(() => _selectedRace = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          _text(_indexNameCtrl, 'Index name (e.g. my-new-subrace)', icon: Icons.tag, validator: _required),
          const SizedBox(height: 16),
          _text(_nameCtrl, 'Name', icon: Icons.badge_outlined, validator: _required),
          const SizedBox(height: 16),
          _sectionTitle('Ability score bonuses'),
          _abilityBonusRow(_abilityCtrls),
          const SizedBox(height: 16),
          _text(_descCtrl, 'Description', icon: Icons.description_outlined, maxLines: 4, validator: _required),
        ];
      case 'ITEM':
        return [
          _text(_indexNameCtrl, 'Index name (e.g. my-new-item)', icon: Icons.tag, validator: _required),
          const SizedBox(height: 16),
          _text(_nameCtrl, 'Name', icon: Icons.badge_outlined, validator: _required),
          const SizedBox(height: 16),
          _text(_itemTypeCtrl, 'Item type (e.g. weapon, armor, magic_item, adventuring_gear)',
              icon: Icons.widgets_outlined, validator: _required),
          const SizedBox(height: 16),
          _text(_categoryCtrl, 'Category (e.g. Weapon, Wondrous Item)', icon: Icons.sell_outlined),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _text(_weightCtrl, 'Weight (lb.)', keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _text(_costCtrl, 'Cost (copper)', keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          _text(_descCtrl, 'Description', icon: Icons.description_outlined, maxLines: 4, validator: _required),
          _sectionTitle('Weapon (leave blank if not a weapon)'),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(Icons.content_copy, size: 16),
              label: const Text('Copy from existing weapon'),
              onPressed: _pickBaseWeapon,
            ),
          ),
          const SizedBox(height: 12),
          _text(_damageDiceCtrl, 'Damage dice (e.g. 1d8)'),
          const SizedBox(height: 16),
          _text(_damageTypeCtrl, 'Damage type (e.g. slashing)'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _weaponRange,
            decoration: _decoration('Weapon range'),
            dropdownColor: AppTheme.surface,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            items: const ['Melee', 'Ranged']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _weaponRange = v!),
          ),
          const SizedBox(height: 16),
          _text(_weaponPropertiesCtrl, 'Weapon properties (comma-separated)'),
          _sectionTitle('Armor (leave blank if not armor)'),
          _text(_armorClassCtrl, 'Armor class', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _text(_armorTypeCtrl, 'Armor type (e.g. Light Armor, Shield)'),
          _sectionTitle('Magic'),
          _text(_rarityCtrl, 'Rarity (e.g. Common, Rare)'),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _requiresAttunement,
            onChanged: (v) => setState(() => _requiresAttunement = v),
            activeThumbColor: AppTheme.primary,
            title: Text('Requires attunement',
                style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13)),
            contentPadding: EdgeInsets.zero,
          ),
          _sectionTitle('Mechanical bonuses (0 = none)'),
          Row(children: [
            Expanded(child: _text(_bonusAcCtrl, 'Bonus AC', keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _text(_bonusToHitCtrl, 'Bonus to hit', keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _text(_bonusDamageCtrl, 'Bonus damage', keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: _text(_bonusSavingThrowsCtrl, 'Bonus saving throws',
                    keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          Text('Set ability score to (blank = no override)',
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          _abilityBonusRow(_setToCtrls, hint: ''),
        ];
      case 'BACKGROUND':
        return [
          _text(_indexNameCtrl, 'Index name (e.g. my-new-background)', icon: Icons.tag, validator: _required),
          const SizedBox(height: 16),
          _text(_nameCtrl, 'Name', icon: Icons.badge_outlined, validator: _required),
          const SizedBox(height: 16),
          _text(_skillProficienciesCtrl, 'Skill proficiencies (comma-separated)', icon: Icons.checklist),
          const SizedBox(height: 16),
          _text(_toolProficienciesCtrl, 'Tool proficiencies (comma-separated)', icon: Icons.build_outlined),
          const SizedBox(height: 16),
          _text(_languagesCtrl, 'Languages (comma-separated)', icon: Icons.translate),
          const SizedBox(height: 16),
          _text(_languageOptionsCtrl, 'Language options (# player picks)',
              icon: Icons.tune, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _text(_featureCtrl, 'Feature name', icon: Icons.star_outline),
          const SizedBox(height: 16),
          _text(_featureDescCtrl, 'Feature description', icon: Icons.description_outlined, maxLines: 3),
          const SizedBox(height: 16),
          _text(_descCtrl, 'Description', icon: Icons.description_outlined, maxLines: 4, validator: _required),
          _sectionTitle('Roleplay suggestions (one per line, optional)'),
          _text(_personalityTraitsCtrl, 'Personality traits', maxLines: 3),
          const SizedBox(height: 16),
          _text(_idealsCtrl, 'Ideals', maxLines: 3),
          const SizedBox(height: 16),
          _text(_bondsCtrl, 'Bonds', maxLines: 3),
          const SizedBox(height: 16),
          _text(_flawsCtrl, 'Flaws', maxLines: 3),
        ];
      case 'FEAT':
        return [
          _text(_indexNameCtrl, 'Index name (e.g. my-new-feat)', icon: Icons.tag, validator: _required),
          const SizedBox(height: 16),
          _text(_nameCtrl, 'Name', icon: Icons.badge_outlined, validator: _required),
          const SizedBox(height: 16),
          _text(_descCtrl, 'Description', icon: Icons.description_outlined, maxLines: 4, validator: _required),
          const SizedBox(height: 16),
          _text(_prerequisitesCtrl, 'Prerequisites (comma-separated, e.g. Strength 13 or higher)',
              icon: Icons.rule),
          _sectionTitle('Fallback numeric bonus (optional)'),
          DropdownButtonFormField<String?>(
            initialValue: _effectModifierType,
            decoration: _decoration('Bonus type', icon: Icons.gps_fixed),
            dropdownColor: AppTheme.surface,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('None')),
              ..._effectModifierTypes.map((t) => DropdownMenuItem<String?>(value: t, child: Text(t))),
            ],
            onChanged: (v) => setState(() => _effectModifierType = v),
          ),
          const SizedBox(height: 16),
          _text(_effectModifierValueCtrl, 'Bonus value (e.g. +1, +10)'),
          const SizedBox(height: 16),
          _text(_choiceProficiencyCountCtrl, '"Pick N proficiencies" count (optional, e.g. Skilled = 3)',
              icon: Icons.checklist, keyboardType: TextInputType.number),
          _sectionTitle('Granted spells (optional)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _grantedSpells)
                Chip(
                  label: Text(s.label),
                  onDeleted: () => setState(() => _grantedSpells.remove(s)),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Add spell'),
                onPressed: _pickGrantedSpell,
              ),
            ],
          ),
        ];
      default:
        return const [];
    }
  }

  Future<void> _pickBaseWeapon() async {
    final chosen = await _showSearchPicker<ItemSearchOption>(
      title: 'Search weapons',
      search: _service.searchWeapons,
      labelOf: (w) => w.label,
    );
    if (chosen == null) return;
    setState(() {
      _damageDiceCtrl.text = chosen.damageDice ?? '';
      _damageTypeCtrl.text = chosen.damageType ?? '';
      if (chosen.weaponRange != null) _weaponRange = chosen.weaponRange!;
      _weaponPropertiesCtrl.text = chosen.weaponProperties.join(', ');
    });
  }

  Future<void> _pickGrantedSpell() async {
    final chosen = await _showSearchPicker<SpellSearchOption>(
      title: 'Search spells',
      search: _service.searchSpells,
      labelOf: (s) => s.label,
    );
    if (chosen != null && !_grantedSpells.any((s) => s.id == chosen.id)) {
      setState(() => _grantedSpells.add(chosen));
    }
  }

  Future<T?> _showSearchPicker<T>({
    required String title,
    required Future<List<T>> Function(String) search,
    required String Function(T) labelOf,
  }) async {
    final queryCtrl = TextEditingController();
    List<T> results = [];
    bool loading = false;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: queryCtrl,
                  autofocus: true,
                  style: GoogleFonts.lato(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: title,
                    hintStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceVariant,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (q) async {
                    setSheetState(() => loading = true);
                    final r = await search(q);
                    setSheetState(() { results = r; loading = false; });
                  },
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: results
                      .map((r) => ListTile(
                            title: Text(labelOf(r), style: GoogleFonts.lato(color: AppTheme.textPrimary)),
                            onTap: () => Navigator.pop(sheetContext, r),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_contentType == 'SUBCLASS' && _selectedClass == null) {
      setState(() => _error = 'Select a class');
      return;
    }
    if (_contentType == 'SUBRACE' && _selectedRace == null) {
      setState(() => _error = 'Select a race');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      switch (_contentType) {
        case 'CLASS':
          await _service.createClass(
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            hitDie: int.parse(_hitDieCtrl.text.trim()),
            proficiencies: _proficienciesCtrl.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            description: _descCtrl.text.trim(),
          );
          break;
        case 'SUBCLASS':
          await _service.createSubclass(
            classId: _selectedClass!.id,
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            subclassFlavor: _subclassFlavorCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            spellcastingAbility: _spellcastingAbility,
          );
          break;
        case 'RACE':
          await _service.createRace(
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            size: _sizeCtrl.value,
            speed: int.parse(_speedCtrl.text.trim()),
            abilityBonuses: _abilityMap(_abilityCtrls),
            description: _descCtrl.text.trim(),
          );
          break;
        case 'SUBRACE':
          await _service.createSubrace(
            raceId: _selectedRace!.id,
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            abilityBonuses: _abilityMap(_abilityCtrls),
            description: _descCtrl.text.trim(),
          );
          break;
        case 'ITEM':
          int? parseOrNull(TextEditingController c) =>
              c.text.trim().isEmpty ? null : int.tryParse(c.text.trim());
          await _service.createItem(
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            itemType: _itemTypeCtrl.text.trim(),
            category: _categoryCtrl.text.trim(),
            weight: double.tryParse(_weightCtrl.text.trim()) ?? 0,
            costInCopper: int.tryParse(_costCtrl.text.trim()) ?? 0,
            description: _descCtrl.text.trim(),
            damageDice: _damageDiceCtrl.text.trim().isEmpty ? null : _damageDiceCtrl.text.trim(),
            damageType: _damageTypeCtrl.text.trim().isEmpty ? null : _damageTypeCtrl.text.trim(),
            weaponRange: _damageDiceCtrl.text.trim().isEmpty ? null : _weaponRange,
            weaponProperties: _weaponPropertiesCtrl.text.trim().isEmpty
                ? null
                : _weaponPropertiesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
            armorClass: parseOrNull(_armorClassCtrl),
            armorType: _armorTypeCtrl.text.trim().isEmpty ? null : _armorTypeCtrl.text.trim(),
            rarity: _rarityCtrl.text.trim().isEmpty ? null : _rarityCtrl.text.trim(),
            requiresAttunement: _requiresAttunement,
            bonusAc: int.tryParse(_bonusAcCtrl.text.trim()) ?? 0,
            bonusToHit: int.tryParse(_bonusToHitCtrl.text.trim()) ?? 0,
            bonusDamage: int.tryParse(_bonusDamageCtrl.text.trim()) ?? 0,
            bonusSavingThrows: int.tryParse(_bonusSavingThrowsCtrl.text.trim()) ?? 0,
            setStrTo: parseOrNull(_setToCtrls['str']!),
            setDexTo: parseOrNull(_setToCtrls['dex']!),
            setConTo: parseOrNull(_setToCtrls['con']!),
            setIntTo: parseOrNull(_setToCtrls['int']!),
            setWisTo: parseOrNull(_setToCtrls['wis']!),
            setChaTo: parseOrNull(_setToCtrls['cha']!),
          );
          break;
        case 'BACKGROUND':
          await _service.createBackground(
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            skillProficiencies: _splitCommas(_skillProficienciesCtrl),
            toolProficiencies: _splitCommas(_toolProficienciesCtrl),
            languages: _splitCommas(_languagesCtrl),
            languageOptions: int.tryParse(_languageOptionsCtrl.text.trim()) ?? 0,
            feature: _featureCtrl.text.trim().isEmpty ? null : _featureCtrl.text.trim(),
            featureDescription:
                _featureDescCtrl.text.trim().isEmpty ? null : _featureDescCtrl.text.trim(),
            personalityTraits: _splitLines(_personalityTraitsCtrl),
            ideals: _splitLines(_idealsCtrl),
            bonds: _splitLines(_bondsCtrl),
            flaws: _splitLines(_flawsCtrl),
          );
          break;
        case 'FEAT':
          await _service.createFeat(
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            prerequisites: _splitCommas(_prerequisitesCtrl),
            effectModifierType: _effectModifierType,
            effectModifierValue: _effectModifierValueCtrl.text.trim().isEmpty
                ? null
                : _effectModifierValueCtrl.text.trim(),
            choiceProficiencyCount: int.tryParse(_choiceProficiencyCountCtrl.text.trim()),
            grantedSpellIds: _grantedSpells.isEmpty ? null : _grantedSpells.map((s) => s.id).toList(),
          );
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_contentTypes[_contentType]} created successfully'),
          backgroundColor: AppTheme.primary,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }
}
