import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gestor_personajes_dnd/l10n/dnd_terms.dart';
import '../../../../config/app_theme.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';
import '../../../../models/wizard/background_option.dart';

String _trText(BuildContext context, {required String en, required String es, required String gl}) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'es') return es;
  if (code == 'gl') return gl;
  return en;
}

class StepBackground extends StatefulWidget {
  const StepBackground({super.key});

  @override
  State<StepBackground> createState() => _StepBackgroundState();
}

class _StepBackgroundState extends State<StepBackground> {
  String _tr({required String en, required String es, required String gl}) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'es') return es;
    if (code == 'gl') return gl;
    return en;
  }
  // Controladores para los campos de texto libre
  final _hairCtrl       = TextEditingController();
  final _eyesCtrl       = TextEditingController();
  final _skinCtrl       = TextEditingController();
  final _ageCtrl        = TextEditingController();
  final _heightCtrl     = TextEditingController();
  final _weightCtrl     = TextEditingController();
  final _personalityCtrl = TextEditingController();
  final _idealsCtrl     = TextEditingController();
  final _bondsCtrl      = TextEditingController();
  final _flawsCtrl      = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rellenar controllers con los valores guardados en el viewmodel
    final vm = context.read<CharacterCreatorViewModel>();
    _hairCtrl.text        = vm.hair;
    _eyesCtrl.text        = vm.eyes;
    _skinCtrl.text        = vm.skin;
    _ageCtrl.text         = vm.age;
    _heightCtrl.text      = vm.height;
    _weightCtrl.text      = vm.weight;
    _personalityCtrl.text = vm.personality;
    _idealsCtrl.text      = vm.ideals;
    _bondsCtrl.text       = vm.bonds;
    _flawsCtrl.text       = vm.flaws;

    // Persistir cambios en el viewmodel al escribir
    _hairCtrl.addListener(()        => vm.setHair(_hairCtrl.text));
    _eyesCtrl.addListener(()        => vm.setEyes(_eyesCtrl.text));
    _skinCtrl.addListener(()        => vm.setSkin(_skinCtrl.text));
    _ageCtrl.addListener(()         => vm.setAge(_ageCtrl.text));
    _heightCtrl.addListener(()      => vm.setHeight(_heightCtrl.text));
    _weightCtrl.addListener(()      => vm.setWeight(_weightCtrl.text));
    _personalityCtrl.addListener(() => vm.setPersonality(_personalityCtrl.text));
    _idealsCtrl.addListener(()      => vm.setIdeals(_idealsCtrl.text));
    _bondsCtrl.addListener(()       => vm.setBonds(_bondsCtrl.text));
    _flawsCtrl.addListener(()       => vm.setFlaws(_flawsCtrl.text));
  }

  @override
  void dispose() {
    _hairCtrl.dispose();
    _eyesCtrl.dispose();
    _skinCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _personalityCtrl.dispose();
    _idealsCtrl.dispose();
    _bondsCtrl.dispose();
    _flawsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    if (vm.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final bg = vm.selectedBackground;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text(_tr(en: 'Choose your Background', es: 'Elige tu trasfondo', gl: 'Escolle o teu trasfondo'),
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text(
          _tr(
            en: 'Your background reveals where you came from and your place in the world.',
            es: 'Tu trasfondo revela de donde vienes y tu lugar en el mundo.',
            gl: 'O teu trasfondo revela de onde vens e o teu lugar no mundo.',
          ),
          style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // ── Dropdown de selección ──────────────────────────────────
        _SectionTitle(_tr(en: 'Background', es: 'Trasfondo', gl: 'Trasfondo')),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: bg != null ? AppTheme.primary : AppTheme.surfaceVariant,
              width: bg != null ? 1.5 : 1,
            ),
          ),
          child: vm.isEditMode
              // Edit mode: load backgrounds lazily if not yet loaded
              ? vm.backgrounds.isEmpty
                  ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_tr(en: 'Loading backgrounds…', es: 'Cargando trasfondos…', gl: 'Cargando trasfondos…'),
                          style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        dropdownColor: AppTheme.surface,
                        value: bg?.id,
                        hint: Text(_tr(en: 'Select a background…', es: 'Selecciona un trasfondo…', gl: 'Selecciona un trasfondo…'),
                            style: GoogleFonts.lato(
                                color: AppTheme.textSecondary, fontSize: 14)),
                        items: vm.backgrounds.map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(localizeKnownName(context, b.name),
                              style: GoogleFonts.libreBaskerville(
                                  color: AppTheme.textPrimary, fontSize: 14)),
                        )).toList(),
                        onChanged: (id) {
                          if (id == null) return;
                          final chosen = vm.backgrounds.firstWhere((b) => b.id == id);
                          vm.selectBackground(chosen);
                        },
                      ),
                    )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    dropdownColor: AppTheme.surface,
                    value: bg?.id,
                    hint: Text(_tr(en: 'Select a background…', es: 'Selecciona un trasfondo…', gl: 'Selecciona un trasfondo…'),
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 14)),
                    items: vm.backgrounds.map((b) => DropdownMenuItem(
                      value: b.id,
                      child: Text(localizeKnownName(context, b.name),
                          style: GoogleFonts.libreBaskerville(
                              color: AppTheme.textPrimary, fontSize: 14)),
                    )).toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      final chosen = vm.backgrounds.firstWhere((b) => b.id == id);
                      final removed = vm.selectBackground(chosen);
                      if (removed.isNotEmpty && context.mounted) {
                        final names = removed.join(', ');
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(SnackBar(
                          content: Text(
                            _tr(
                              en: 'Conflict: $names ${removed.length == 1 ? 'is' : 'are'} already granted by this background — deselected from your class skills. Go back to Edit Class to re-pick.',
                              es: 'Conflicto: $names ${removed.length == 1 ? 'ya esta' : 'ya estan'} otorgado por este trasfondo. Se deselecciono en tus habilidades de clase. Vuelve a Editar clase para elegir de nuevo.',
                              gl: 'Conflito: $names ${removed.length == 1 ? 'xa esta' : 'xa estan'} outorgado por este trasfondo. Deseleccionouse nas habilidades da clase. Volve a Editar clase para escoller de novo.',
                            ),
                            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
                          ),
                          backgroundColor: AppTheme.surface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppTheme.primary, width: 1),
                          ),
                          duration: const Duration(seconds: 8),
                          action: SnackBarAction(
                            label: _tr(en: 'Dismiss', es: 'Cerrar', gl: 'Pechar'),
                            textColor: AppTheme.primary,
                            onPressed: () => messenger.hideCurrentSnackBar(),
                          ),
                        ));
                      }
                    },
                  ),
                ),
        ),

        // ── Detalle del background elegido ────────────────────────
        if (bg != null) ...[
          const SizedBox(height: 20),
          _BackgroundDetail(bg: bg),
        ],

        // ── Alignment ─────────────────────────────────────────────
        const SizedBox(height: 16),
        _SectionTitle(_tr(en: 'Alignment', es: 'Alineamiento', gl: 'Aliñamento')),
        const SizedBox(height: 8),
        _AlignmentGrid(
          selected: vm.alignment,
          onSelected: vm.setAlignment,
        ),

        const SizedBox(height: 24),

        // ── Características físicas ────────────────────────────────
        _SectionTitle(_tr(en: 'Physical Characteristics', es: 'Caracteristicas fisicas', gl: 'Caracteristicas fisicas')),
        const SizedBox(height: 10),
        _TextRow(label: _tr(en: 'Hair', es: 'Pelo', gl: 'Pelo'),   ctrl: _hairCtrl,   hint: _tr(en: 'e.g. Brown', es: 'ej. Castano', gl: 'ex. Castano')),
        _TextRow(label: _tr(en: 'Eyes', es: 'Ojos', gl: 'Ollos'),   ctrl: _eyesCtrl,   hint: _tr(en: 'e.g. Blue', es: 'ej. Azules', gl: 'ex. Azuis')),
        _TextRow(label: _tr(en: 'Skin', es: 'Piel', gl: 'Pel'),   ctrl: _skinCtrl,   hint: _tr(en: 'e.g. Tan', es: 'ej. Morena', gl: 'ex. Morena')),
        _TextRow(label: _tr(en: 'Age', es: 'Edad', gl: 'Idade'),    ctrl: _ageCtrl,    hint: _tr(en: 'e.g. 25', es: 'ej. 25', gl: 'ex. 25'),
            keyboardType: TextInputType.number),
        _TextRow(label: _tr(en: 'Height', es: 'Altura', gl: 'Altura'), ctrl: _heightCtrl, hint: _tr(en: "e.g. 5'10\"", es: 'ej. 1,78 m', gl: 'ex. 1,78 m')),
        _TextRow(label: _tr(en: 'Weight', es: 'Peso', gl: 'Peso'), ctrl: _weightCtrl, hint: _tr(en: 'e.g. 160 lbs', es: 'ej. 72 kg', gl: 'ex. 72 kg')),

        const SizedBox(height: 24),

        // ── Características personales ─────────────────────────────
        _SectionTitle(_tr(en: 'Personal Characteristics', es: 'Rasgos personales', gl: 'Trazos persoais')),
        const SizedBox(height: 10),
        _TextArea(label: _tr(en: 'Personality Traits', es: 'Rasgos de personalidad', gl: 'Rasgos de personalidade'), ctrl: _personalityCtrl,
          hint: _tr(en: 'Describe your character\'s personality…', es: 'Describe la personalidad del personaje…', gl: 'Describe a personalidade do personaxe…')),
        const SizedBox(height: 10),
        _TextArea(label: _tr(en: 'Ideals', es: 'Ideales', gl: 'Ideais'), ctrl: _idealsCtrl,
          hint: _tr(en: 'What are your ideals?', es: 'Cuales son tus ideales?', gl: 'Cales son os teus ideais?')),
        const SizedBox(height: 10),
        _TextArea(label: _tr(en: 'Bonds', es: 'Vinculos', gl: 'Vinculos'), ctrl: _bondsCtrl,
          hint: _tr(en: 'What bonds tie you to the world?', es: 'Que vinculos te atan al mundo?', gl: 'Que vinculos te atan ao mundo?')),
        const SizedBox(height: 10),
        _TextArea(label: _tr(en: 'Flaws', es: 'Defectos', gl: 'Defectos'), ctrl: _flawsCtrl,
          hint: _tr(en: 'What are your character\'s flaws?', es: 'Cuales son los defectos del personaje?', gl: 'Cales son os defectos do personaxe?')),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ── Background detail ─────────────────────────────────────────────────────────

class _BackgroundDetail extends StatelessWidget {
  final BackgroundOption bg;
  const _BackgroundDetail({required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primary.withOpacity(0.4), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Nombre
        Text(localizeKnownName(context, bg.name),
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold)),

        // Descripción
        if (bg.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(bg.description,
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ],

        // Skill proficiencies
        if (bg.skillProficiencies.isNotEmpty) ...[
          const SizedBox(height: 14),
          _DetailSubtitle(_trText(context, en: 'Skill Proficiencies', es: 'Competencias de habilidad', gl: 'Competencias de habilidade')),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: bg.skillProficiencies.map((s) => _Chip(localizeSkillOrProficiency(context, s))).toList(),
          ),
        ],

        // Tool proficiencies
        if (bg.toolProficiencies.isNotEmpty) ...[
          const SizedBox(height: 14),
          _DetailSubtitle(_trText(context, en: 'Tool Proficiencies', es: 'Competencias de herramientas', gl: 'Competencias de ferramentas')),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: bg.toolProficiencies.map((s) => _Chip(localizeSkillOrProficiency(context, s))).toList(),
          ),
        ],

        // Languages
        if (bg.languages.isNotEmpty) ...[
          const SizedBox(height: 14),
          _DetailSubtitle(_trText(context, en: 'Languages', es: 'Idiomas', gl: 'Idiomas')),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: bg.languages.map((l) => _Chip(l)).toList(),
          ),
        ],

        // Feature
        if (bg.feature.isNotEmpty) ...[
          const SizedBox(height: 14),
          _FeatureBox(name: bg.feature, description: bg.featureDescription),
        ],
      ]),
    );
  }
}

class _FeatureBox extends StatefulWidget {
  final String name;
  final String description;
  const _FeatureBox({required this.name, required this.description});

  @override
  State<_FeatureBox> createState() => _FeatureBoxState();
}

class _FeatureBoxState extends State<_FeatureBox> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text('${_trText(context, en: 'Feature', es: 'Rasgo', gl: 'Rasgo')}: ${widget.name}',
                  style: GoogleFonts.libreBaskerville(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
            Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary,
              size: 18,
            ),
          ]),
          if (_expanded && widget.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(widget.description,
                style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 12)),
          ],
        ]),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.libreBaskerville(
          color: AppTheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold));
}

class _DetailSubtitle extends StatelessWidget {
  final String title;
  const _DetailSubtitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.lato(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold));
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: GoogleFonts.lato(
                color: AppTheme.textPrimary, fontSize: 11)),
      );
}

class _TextRow extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType keyboardType;

  const _TextRow({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: GoogleFonts.lato(
                color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 12),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _TextArea extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;

  const _TextArea({
    required this.label,
    required this.ctrl,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.lato(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        maxLines: 3,
        style:
            GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 12),
          contentPadding: const EdgeInsets.all(10),
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
        ),
      ),
    ]);
  }
}

// ── Alignment 3×3 grid picker ─────────────────────────────────────────────────
// Layout: columns = Lawful / Neutral / Chaotic, rows = Good / Neutral / Evil

class _AlignmentGrid extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _AlignmentGrid({required this.selected, required this.onSelected});

  // Row-major order: [LG, NG, CG, LN, TN, CN, LE, NE, CE]
  static const _cells = [
    ('Lawful Good',      'LG'),
    ('Neutral Good',     'NG'),
    ('Chaotic Good',     'CG'),
    ('Lawful Neutral',   'LN'),
    ('True Neutral',     'TN'),
    ('Chaotic Neutral',  'CN'),
    ('Lawful Evil',      'LE'),
    ('Neutral Evil',     'NE'),
    ('Chaotic Evil',     'CE'),
  ];

  static const _rowLabels    = ['Good', 'Neutral', 'Evil'];
  static const _columnLabels = ['Lawful', 'Neutral', 'Chaotic'];

  Color _cellColor(String value) {
    if (value == selected) return AppTheme.primary;
    if (value.contains('Good'))    return const Color(0xFF1A3A2A);
    if (value.contains('Evil'))    return const Color(0xFF3A1A1A);
    return AppTheme.surfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Column headers
      Row(children: [
        ..._columnLabels.map((l) => Expanded(
          child: Center(
            child: Text(localizeAlignment(context, l),
                style: GoogleFonts.libreBaskerville(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold)),
          ),
        )),
        const SizedBox(width: 52), // spacer for right-side row labels
      ]),
      const SizedBox(height: 4),
      // Grid rows
      for (int row = 0; row < 3; row++)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            // 3 cells
            for (int col = 0; col < 3; col++) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final value = _cells[row * 3 + col].$1;
                    onSelected(selected == value ? null : value);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 52,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: _cellColor(_cells[row * 3 + col].$1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected == _cells[row * 3 + col].$1
                            ? AppTheme.primary
                            : AppTheme.divider,
                        width: selected == _cells[row * 3 + col].$1 ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(_cells[row * 3 + col].$2,
                          style: GoogleFonts.libreBaskerville(
                              color: selected == _cells[row * 3 + col].$1
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
            // Row label on the right
            SizedBox(
              width: 52,
              child: Text(localizeAlignment(context, _rowLabels[row]),
                  textAlign: TextAlign.left,
                  style: GoogleFonts.libreBaskerville(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
    ]);
  }
}