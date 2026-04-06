import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';
import '../../../../models/wizard/background_option.dart';

class StepBackground extends StatefulWidget {
  const StepBackground({super.key});

  @override
  State<StepBackground> createState() => _StepBackgroundState();
}

class _StepBackgroundState extends State<StepBackground> {
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
        Text('Choose your Background',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text(
          'Your background reveals where you came from and your place in the world.',
          style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // ── Dropdown de selección ──────────────────────────────────
        _SectionTitle('Background'),
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              dropdownColor: AppTheme.surface,
              value: bg?.id,
              hint: Text('Select a background…',
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 14)),
              items: vm.backgrounds.map((b) => DropdownMenuItem(
                value: b.id,
                child: Text(b.name,
                    style: GoogleFonts.cinzel(
                        color: AppTheme.textPrimary, fontSize: 14)),
              )).toList(),
              onChanged: (id) {
                if (id == null) return;
                final chosen = vm.backgrounds.firstWhere((b) => b.id == id);
                vm.selectBackground(chosen);
              },
            ),
          ),
        ),

        // ── Detalle del background elegido ────────────────────────
        if (bg != null) ...[
          const SizedBox(height: 20),
          _BackgroundDetail(bg: bg),
        ],

        const SizedBox(height: 24),

        // ── Características físicas ────────────────────────────────
        _SectionTitle('Physical Characteristics'),
        const SizedBox(height: 10),
        _TextRow(label: 'Hair',   ctrl: _hairCtrl,   hint: 'e.g. Brown'),
        _TextRow(label: 'Eyes',   ctrl: _eyesCtrl,   hint: 'e.g. Blue'),
        _TextRow(label: 'Skin',   ctrl: _skinCtrl,   hint: 'e.g. Tan'),
        _TextRow(label: 'Age',    ctrl: _ageCtrl,    hint: 'e.g. 25',
            keyboardType: TextInputType.number),
        _TextRow(label: 'Height', ctrl: _heightCtrl, hint: "e.g. 5'10\""),
        _TextRow(label: 'Weight', ctrl: _weightCtrl, hint: 'e.g. 160 lbs'),

        const SizedBox(height: 24),

        // ── Características personales ─────────────────────────────
        _SectionTitle('Personal Characteristics'),
        const SizedBox(height: 10),
        _TextArea(label: 'Personality Traits', ctrl: _personalityCtrl,
            hint: 'Describe your character\'s personality…'),
        const SizedBox(height: 10),
        _TextArea(label: 'Ideals', ctrl: _idealsCtrl,
            hint: 'What are your ideals?'),
        const SizedBox(height: 10),
        _TextArea(label: 'Bonds', ctrl: _bondsCtrl,
            hint: 'What bonds tie you to the world?'),
        const SizedBox(height: 10),
        _TextArea(label: 'Flaws', ctrl: _flawsCtrl,
            hint: 'What are your character\'s flaws?'),
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
        Text(bg.name,
            style: GoogleFonts.cinzel(
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
          _DetailSubtitle('Skill Proficiencies'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: bg.skillProficiencies.map((s) => _Chip(_formatProficiency(s))).toList(),
          ),
        ],

        // Tool proficiencies
        if (bg.toolProficiencies.isNotEmpty) ...[
          const SizedBox(height: 14),
          _DetailSubtitle('Tool Proficiencies'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: bg.toolProficiencies.map((s) => _Chip(_formatProficiency(s))).toList(),
          ),
        ],

        // Languages
        if (bg.languages.isNotEmpty) ...[
          const SizedBox(height: 14),
          _DetailSubtitle('Languages'),
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
              child: Text('Feature: ${widget.name}',
                  style: GoogleFonts.cinzel(
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
      style: GoogleFonts.cinzel(
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

String _formatProficiency(String raw) {
  // Strip known prefixes like "skill-", "tool-"
  final stripped = raw.replaceFirst(RegExp(r'^(skill|tool)-'), '');
  // Replace remaining hyphens with spaces and capitalise each word
  return stripped.split('-').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
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