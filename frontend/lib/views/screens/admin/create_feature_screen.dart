import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/admin/content_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';

/// #9 (panel de admin): crear una feature/rasgo con su mecánica de #8.2 en un solo formulario
/// que se adapta tanto a "a qué pertenece" (Class/Subclass/Race/Subrace) como al "mechanicType"
/// elegido -- solo pide los campos que hacen falta, no un formulario de texto libre (requisito
/// explícito de #9 en Aurora_Fixes.md).
///
/// GRANT_PROFICIENCY no aparece como opción cuando "belongs to" = Class: no existe ninguna
/// tabla de "otorgamiento de competencia por feature de clase base" en el esquema (las
/// competencias de clase son la lista estática DndClass.proficiencies, no un grant por feature)
/// -- ver AdminClassFeatureService. Race/Subrace no tienen campo de nivel (a diferencia de
/// Class/Subclass): race_traits/subrace_traits no tienen columna de nivel en este esquema.
class CreateFeatureScreen extends StatefulWidget {
  const CreateFeatureScreen({super.key});

  @override
  State<CreateFeatureScreen> createState() => _CreateFeatureScreenState();
}

const _belongsToOptions = <String, String>{
  'CLASS': 'Class (base class feature)',
  'SUBCLASS': 'Subclass',
  'RACE': 'Race',
  'SUBRACE': 'Subrace',
};

const _mechanicTypesAll = <String, String>{
  'NONE': 'None (purely descriptive)',
  'RESOURCE_POOL': 'Resource Pool (limited uses, e.g. Ki)',
  'NUMERIC_BONUS': 'Numeric Bonus (e.g. +CHA to AC)',
  'GRANT_SPELL': 'Grant Spell',
  'GRANT_PROFICIENCY': 'Grant Proficiency',
};

const _traitTypes = <String, String>{
  'PASSIVE': 'Passive (darkvision, resistances...)',
  'COMBAT': 'Combat (attack bonus, activatable action...)',
  'CHOICE_REQUIRED': 'Choice required',
};

const _recoveryTypes = <String, String>{
  'SHORT_REST': 'Short Rest',
  'LONG_REST': 'Long Rest',
  'SHORT_OR_LONG_REST': 'Short or Long Rest',
};

class _CreateFeatureScreenState extends State<CreateFeatureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ContentAdminService();

  String _belongsTo = 'SUBCLASS';

  bool _loadingRefs = true;
  String? _loadError;
  List<ClassAdminOption> _classes = [];
  List<SubclassAdminOption> _subclasses = [];
  List<RaceAdminOption> _races = [];

  ClassAdminOption? _selectedClass;
  SubclassAdminOption? _selectedSubclass;
  RaceAdminOption? _selectedRace;
  RaceAdminOption? _selectedRaceForSubrace;
  List<SubraceAdminOption> _subracesForSelectedRace = [];
  SubraceAdminOption? _selectedSubrace;
  bool _loadingSubraces = false;

  final _indexNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _levelCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _traitType = 'PASSIVE';

  String _mechanicType = 'NONE';

  final _resourceMaxFormulaCtrl = TextEditingController();
  String _recoveryType = 'SHORT_REST';

  final _bonusTargetFieldCtrl = TextEditingController();
  final _bonusFormulaCtrl = TextEditingController();
  final _bonusConditionCtrl = TextEditingController();

  SpellSearchOption? _selectedSpell;
  final _spellRequiredLevelCtrl = TextEditingController(text: '1');
  ProficiencySearchOption? _selectedProficiency;

  bool _saving = false;
  String? _error;

  bool get _isRaceOrSubrace => _belongsTo == 'RACE' || _belongsTo == 'SUBRACE';

  Map<String, String> get _availableMechanicTypes {
    if (_belongsTo == 'CLASS') {
      return Map.fromEntries(
          _mechanicTypesAll.entries.where((e) => e.key != 'GRANT_PROFICIENCY'));
    }
    return _mechanicTypesAll;
  }

  @override
  void initState() {
    super.initState();
    _loadRefs();
  }

  Future<void> _loadRefs() async {
    try {
      final classes = await _service.getAllClasses();
      final subclasses = await _service.getAllSubclasses();
      final races = await _service.getAllRacesForAdmin();
      classes.sort((a, b) => a.name.compareTo(b.name));
      subclasses.sort((a, b) => a.label.compareTo(b.label));
      races.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) {
        setState(() {
          _classes = classes;
          _subclasses = subclasses;
          _races = races;
          _loadingRefs = false;
        });
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

  Future<void> _loadSubracesForRace(RaceAdminOption race) async {
    setState(() { _loadingSubraces = true; _selectedSubrace = null; _subracesForSelectedRace = []; });
    try {
      final list = await _service.getSubracesForRace(race.id);
      list.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) setState(() { _subracesForSelectedRace = list; _loadingSubraces = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loadingSubraces = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: const BackButton(color: AppTheme.textPrimary),
        title: Text('Add Feature',
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
                        initialValue: _belongsTo,
                        decoration: _decoration('Belongs to', icon: Icons.account_tree_outlined),
                        dropdownColor: AppTheme.surface,
                        style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
                        isExpanded: true,
                        items: _belongsToOptions.entries
                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _belongsTo = v!;
                          _error = null;
                          if (_mechanicType == 'GRANT_PROFICIENCY' && _belongsTo == 'CLASS') {
                            _mechanicType = 'NONE';
                          }
                        }),
                      ),
                      const SizedBox(height: 16),
                      ..._buildTargetPicker(),
                      const SizedBox(height: 16),
                      _text(_indexNameCtrl, 'Index name (e.g. my-new-feature)',
                          icon: Icons.tag, validator: _required),
                      const SizedBox(height: 16),
                      _text(_nameCtrl, 'Name', icon: Icons.badge_outlined, validator: _required),
                      const SizedBox(height: 16),
                      if (!_isRaceOrSubrace) ...[
                        _text(_levelCtrl, 'Level (1-20)',
                            icon: Icons.stairs_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n < 1 || n > 20) return 'Enter a level 1-20';
                              return null;
                            }),
                        const SizedBox(height: 16),
                      ],
                      if (_isRaceOrSubrace) ...[
                        DropdownButtonFormField<String>(
                          initialValue: _traitType,
                          decoration: _decoration('Trait type', icon: Icons.category_outlined),
                          dropdownColor: AppTheme.surface,
                          style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
                          isExpanded: true,
                          items: _traitTypes.entries
                              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (v) => setState(() => _traitType = v!),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _text(_descCtrl, 'Description',
                          icon: Icons.description_outlined, maxLines: 4, validator: _required),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        initialValue: _availableMechanicTypes.containsKey(_mechanicType)
                            ? _mechanicType
                            : 'NONE',
                        decoration: _decoration('Mechanic type', icon: Icons.settings_outlined),
                        dropdownColor: AppTheme.surface,
                        style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
                        isExpanded: true,
                        items: _availableMechanicTypes.entries
                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _mechanicType = v!;
                          _selectedSpell = null;
                          _selectedProficiency = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      ..._buildMechanicFields(),
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
                              : Text('Create Feature',
                                  style: GoogleFonts.libreBaskerville(
                                      fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
                  ),
                ),
    );
  }

  List<Widget> _buildTargetPicker() {
    switch (_belongsTo) {
      case 'CLASS':
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
        ];
      case 'SUBCLASS':
        return [
          DropdownButtonFormField<SubclassAdminOption>(
            initialValue: _selectedSubclass,
            decoration: _decoration('Subclass', icon: Icons.account_tree_outlined),
            dropdownColor: AppTheme.surface,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            isExpanded: true,
            items: _subclasses.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
            onChanged: (v) => setState(() => _selectedSubclass = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ];
      case 'RACE':
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
        ];
      case 'SUBRACE':
        return [
          DropdownButtonFormField<RaceAdminOption>(
            initialValue: _selectedRaceForSubrace,
            decoration: _decoration('Race', icon: Icons.groups_outlined),
            dropdownColor: AppTheme.surface,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            isExpanded: true,
            items: _races.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
            onChanged: (v) {
              setState(() => _selectedRaceForSubrace = v);
              if (v != null) _loadSubracesForRace(v);
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          if (_loadingSubraces)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          else
            DropdownButtonFormField<SubraceAdminOption>(
              initialValue: _selectedSubrace,
              decoration: _decoration('Subrace', icon: Icons.diversity_3_outlined),
              dropdownColor: AppTheme.surface,
              style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
              isExpanded: true,
              items: _subracesForSelectedRace
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSubrace = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
        ];
      default:
        return const [];
    }
  }

  List<Widget> _buildMechanicFields() {
    switch (_mechanicType) {
      case 'RESOURCE_POOL':
        return [
          _text(_resourceMaxFormulaCtrl, 'Max uses formula (e.g. level, proficiency_bonus)',
              icon: Icons.functions, validator: _required),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _recoveryType,
            decoration: _decoration('Recovers on', icon: Icons.hotel_outlined),
            dropdownColor: AppTheme.surface,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            items: _recoveryTypes.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _recoveryType = v!),
          ),
          const SizedBox(height: 16),
        ];
      case 'NUMERIC_BONUS':
        return [
          _text(_bonusTargetFieldCtrl, 'Target field (e.g. AC, SAVING_THROW_ALL)',
              icon: Icons.gps_fixed, validator: _required),
          const SizedBox(height: 16),
          _text(_bonusFormulaCtrl, 'Bonus formula (e.g. charisma_modifier)',
              icon: Icons.functions, validator: _required),
          const SizedBox(height: 16),
          _text(_bonusConditionCtrl, 'Condition (optional)', icon: Icons.rule),
          const SizedBox(height: 16),
        ];
      case 'GRANT_SPELL':
        return [
          _PickerTile(label: 'Spell', value: _selectedSpell?.label, onTap: _pickSpell),
          if (_isRaceOrSubrace) ...[
            const SizedBox(height: 16),
            _text(_spellRequiredLevelCtrl, 'Required character level',
                icon: Icons.stairs_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter a number' : null),
          ],
          const SizedBox(height: 16),
        ];
      case 'GRANT_PROFICIENCY':
        return [
          _PickerTile(label: 'Proficiency', value: _selectedProficiency?.label, onTap: _pickProficiency),
          const SizedBox(height: 16),
        ];
      default:
        return const [];
    }
  }

  Future<void> _pickSpell() async {
    final chosen = await _showSearchPicker<SpellSearchOption>(
      title: 'Search spells',
      search: _service.searchSpells,
      labelOf: (s) => s.label,
    );
    if (chosen != null) setState(() => _selectedSpell = chosen);
  }

  Future<void> _pickProficiency() async {
    final chosen = await _showSearchPicker<ProficiencySearchOption>(
      title: 'Search proficiencies',
      search: _service.searchProficiencies,
      labelOf: (p) => p.label,
    );
    if (chosen != null) setState(() => _selectedProficiency = chosen);
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
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
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
                            title: Text(labelOf(r),
                                style: GoogleFonts.lato(color: AppTheme.textPrimary)),
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
    if (_mechanicType == 'GRANT_SPELL' && _selectedSpell == null) {
      setState(() => _error = 'Select a spell');
      return;
    }
    if (_mechanicType == 'GRANT_PROFICIENCY' && _selectedProficiency == null) {
      setState(() => _error = 'Select a proficiency');
      return;
    }
    if (_belongsTo == 'SUBRACE' && _selectedSubrace == null) {
      setState(() => _error = 'Select a subrace');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      switch (_belongsTo) {
        case 'CLASS':
          await _service.createClassFeature(
            classId: _selectedClass!.id,
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            level: int.parse(_levelCtrl.text.trim()),
            description: _descCtrl.text.trim(),
            mechanicType: _mechanicType,
            resourceMaxFormula:
                _mechanicType == 'RESOURCE_POOL' ? _resourceMaxFormulaCtrl.text.trim() : null,
            resourceRecoveryType: _mechanicType == 'RESOURCE_POOL' ? _recoveryType : null,
            bonusTargetField:
                _mechanicType == 'NUMERIC_BONUS' ? _bonusTargetFieldCtrl.text.trim() : null,
            bonusFormula: _mechanicType == 'NUMERIC_BONUS' ? _bonusFormulaCtrl.text.trim() : null,
            bonusCondition: _mechanicType == 'NUMERIC_BONUS' && _bonusConditionCtrl.text.trim().isNotEmpty
                ? _bonusConditionCtrl.text.trim()
                : null,
            spellId: _mechanicType == 'GRANT_SPELL' ? _selectedSpell!.id : null,
          );
          break;
        case 'SUBCLASS':
          await _service.createSubclassFeature(
            subclassId: _selectedSubclass!.id,
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            level: int.parse(_levelCtrl.text.trim()),
            description: _descCtrl.text.trim(),
            mechanicType: _mechanicType,
            resourceMaxFormula:
                _mechanicType == 'RESOURCE_POOL' ? _resourceMaxFormulaCtrl.text.trim() : null,
            resourceRecoveryType: _mechanicType == 'RESOURCE_POOL' ? _recoveryType : null,
            bonusTargetField:
                _mechanicType == 'NUMERIC_BONUS' ? _bonusTargetFieldCtrl.text.trim() : null,
            bonusFormula: _mechanicType == 'NUMERIC_BONUS' ? _bonusFormulaCtrl.text.trim() : null,
            bonusCondition: _mechanicType == 'NUMERIC_BONUS' && _bonusConditionCtrl.text.trim().isNotEmpty
                ? _bonusConditionCtrl.text.trim()
                : null,
            spellId: _mechanicType == 'GRANT_SPELL' ? _selectedSpell!.id : null,
            proficiencyId: _mechanicType == 'GRANT_PROFICIENCY' ? _selectedProficiency!.id : null,
          );
          break;
        case 'RACE':
        case 'SUBRACE':
          final isRace = _belongsTo == 'RACE';
          await _service.createRacialTrait(
            targetType: _belongsTo,
            targetId: isRace ? _selectedRace!.id : _selectedSubrace!.id,
            indexName: _indexNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            traitType: _traitType,
            mechanicType: _mechanicType,
            resourceMaxFormula:
                _mechanicType == 'RESOURCE_POOL' ? _resourceMaxFormulaCtrl.text.trim() : null,
            resourceRecoveryType: _mechanicType == 'RESOURCE_POOL' ? _recoveryType : null,
            bonusTargetField:
                _mechanicType == 'NUMERIC_BONUS' ? _bonusTargetFieldCtrl.text.trim() : null,
            bonusFormula: _mechanicType == 'NUMERIC_BONUS' ? _bonusFormulaCtrl.text.trim() : null,
            bonusCondition: _mechanicType == 'NUMERIC_BONUS' && _bonusConditionCtrl.text.trim().isNotEmpty
                ? _bonusConditionCtrl.text.trim()
                : null,
            spellId: _mechanicType == 'GRANT_SPELL' ? _selectedSpell!.id : null,
            spellRequiredLevel: _mechanicType == 'GRANT_SPELL'
                ? (int.tryParse(_spellRequiredLevelCtrl.text.trim()) ?? 1)
                : 1,
            proficiencyId: _mechanicType == 'GRANT_PROFICIENCY' ? _selectedProficiency!.id : null,
          );
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Feature created successfully'),
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

class _PickerTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _PickerTile({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            const Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(value ?? 'Tap to select $label',
                  style: GoogleFonts.lato(
                      color: value == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                      fontSize: 13)),
            ),
          ]),
        ),
      );
}
