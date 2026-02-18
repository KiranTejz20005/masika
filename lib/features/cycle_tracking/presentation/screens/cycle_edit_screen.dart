import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/models/cycle_log.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class CycleEditScreen extends ConsumerStatefulWidget {
  const CycleEditScreen({super.key, required this.log});

  final CycleLog log;

  @override
  ConsumerState<CycleEditScreen> createState() => _CycleEditScreenState();
}

class _CycleEditScreenState extends ConsumerState<CycleEditScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  late String _mood;
  late String _flow;
  late Set<String> _symptoms;

  @override
  void initState() {
    super.initState();
    _startDate = widget.log.startDate;
    _endDate = widget.log.endDate;
    _mood = widget.log.mood;
    _flow = widget.log.flow;
    _symptoms = widget.log.symptoms.toSet();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: isStart ? _startDate : _endDate,
    );
    if (selected == null) return;
    if (!mounted) return;
    setState(() {
      if (isStart) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
  }

  void _save() {
    final updated = CycleLog(
      id: widget.log.id,
      startDate: _startDate,
      endDate: _endDate,
      cycleLengthDays: _endDate.difference(_startDate).inDays + 1,
      symptoms: _symptoms.toList(),
      mood: _mood,
      flow: _flow,
    );
    ref.read(cycleLogsProvider.notifier).update(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('edit_log'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.t('period_start')),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _pickDate(isStart: true),
                    child: Text(_startDate.toLocal().toString().split(' ').first),
                  ),
                  const SizedBox(height: 12),
                  Text(t.t('period_end')),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _pickDate(isStart: false),
                    child: Text(_endDate.toLocal().toString().split(' ').first),
                  ),
                ],
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.t('symptoms')),
                  Wrap(
                    spacing: 8,
                    children: [
                      t.t('symptom_cramps'),
                      t.t('symptom_headache'),
                      t.t('symptom_bloating'),
                      t.t('symptom_severe_cramps'),
                    ].map((symptom) {
                      final selected = _symptoms.contains(symptom);
                      return FilterChip(
                        label: Text(symptom),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _symptoms.add(symptom);
                            } else {
                              _symptoms.remove(symptom);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _mood,
                    items: [
                      DropdownMenuItem(
                        value: 'calm',
                        child: Text(t.t('mood_calm')),
                      ),
                      DropdownMenuItem(
                        value: 'irritable',
                        child: Text(t.t('mood_irritable')),
                      ),
                      DropdownMenuItem(
                        value: 'low',
                        child: Text(t.t('mood_low')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _mood = value ?? 'calm'),
                    decoration: InputDecoration(labelText: t.t('mood')),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _flow,
                    items: [
                      DropdownMenuItem(
                        value: 'light',
                        child: Text(t.t('flow_light')),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text(t.t('flow_medium')),
                      ),
                      DropdownMenuItem(
                        value: 'heavy',
                        child: Text(t.t('flow_heavy')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _flow = value ?? 'medium'),
                    decoration: InputDecoration(labelText: t.t('flow')),
                  ),
                ],
              ),
            ),
            PrimaryButton(label: t.t('save_log'), onPressed: _save),
          ],
        ),
      ),
    );
  }
}
