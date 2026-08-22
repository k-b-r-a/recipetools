import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../provider/timers_provider.dart';
import '../widgets/floating_pill_app_bar.dart';
import '../utils/audio_alarm_service.dart';
import '../utils/notification_service.dart';

class KitchenTimersScreen extends ConsumerStatefulWidget {
  const KitchenTimersScreen({super.key});

  @override
  ConsumerState<KitchenTimersScreen> createState() => _KitchenTimersScreenState();
}

class _KitchenTimersScreenState extends ConsumerState<KitchenTimersScreen> {
  final ScrollController _scrollController = ScrollController();

  static const List<Color> _accentColors = [
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF6366F1), // Indigo
    Color(0xFFF43F5E), // Rose
    Color(0xFF06B6D4), // Cyan
    Color(0xFF8B5CF6), // Purple
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final timers = ref.watch(kitchenTimersProvider);
    final notifier = ref.read(kitchenTimersProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              buildFloatingPillAppBar(
                context: context,
                title: l10n.timers_title,
                controller: _scrollController,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (timers.isEmpty)
                      _buildEmptyState(theme, l10n)
                    else
                      _buildTimersList(timers, notifier, theme, l10n),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTimerDialog(context, notifier, l10n),
        icon: const Icon(Icons.timer_outlined),
        label: Text(
          l10n.timers_add_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }



  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              child: Icon(
                Icons.hourglass_empty_rounded,
                color: theme.colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.timers_no_timers,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.timers_no_timers_desc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimersList(
    List<KitchenTimerModel> timers,
    KitchenTimersNotifier notifier,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final timer = timers[index];
        final accentColor = _accentColors[timer.colorIndex % _accentColors.length];

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: timer.isFinished
                  ? theme.colorScheme.error.withValues(alpha: 0.8)
                  : accentColor.withValues(alpha: 0.3),
              width: timer.isFinished ? 2 : 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: timer.isFinished
                  ? theme.colorScheme.errorContainer.withValues(alpha: 0.15)
                  : null,
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: timer.isFinished ? theme.colorScheme.error : accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        timer.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20, color: accentColor),
                      onPressed: () => _showAddTimerDialog(context, notifier, l10n, existingTimer: timer),
                      tooltip: l10n.localeName == 'es' ? 'Editar' : 'Edit',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: theme.colorScheme.onSurfaceVariant),
                      onPressed: () => notifier.deleteTimer(timer.id),
                      tooltip: l10n.localeName == 'es' ? 'Eliminar' : 'Delete',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: timer.progress,
                            strokeWidth: 6,
                            backgroundColor: accentColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              timer.isFinished ? theme.colorScheme.error : accentColor,
                            ),
                          ),
                        ),
                        Icon(
                          timer.isFinished
                              ? Icons.alarm_on_rounded
                              : (timer.isRunning ? Icons.timer : Icons.pause),
                          color: timer.isFinished ? theme.colorScheme.error : accentColor,
                          size: 30,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timer.formattedTime,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [FontFeature.tabularFigures()],
                              color: timer.isFinished
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: (timer.isFinished
                                      ? theme.colorScheme.error
                                      : (timer.isRunning ? accentColor : theme.colorScheme.outline))
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              timer.isFinished
                                  ? (timer.formattedFinishedTime.isNotEmpty
                                      ? '${l10n.timers_finished} (${timer.formattedFinishedTime})'
                                      : l10n.timers_finished)
                                  : (timer.isRunning
                                      ? (l10n.localeName == 'es' ? 'En marcha' : 'Running')
                                      : (l10n.localeName == 'es' ? 'Pausado' : 'Paused')),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: timer.isFinished
                                    ? theme.colorScheme.error
                                    : (timer.isRunning ? accentColor : theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (timer.isFinished)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AudioAlarmService().stopAlarm();
                        NotificationService().cancelNotification(timer.id.hashCode);
                        notifier.deleteTimer(timer.id);
                      },
                      icon: const Icon(Icons.stop_circle_outlined, size: 22),
                      label: Text(
                        l10n.localeName == 'es' ? 'DETENER ALARMA' : 'STOP ALARM',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => notifier.addMinutes(timer.id, 1),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('+1m'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => notifier.resetTimer(timer.id),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text(l10n.localeName == 'es' ? 'Reiniciar' : 'Reset'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => notifier.toggleTimer(timer.id),
                        icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow, size: 18),
                        label: Text(timer.isRunning
                            ? (l10n.localeName == 'es' ? 'Pausar' : 'Pause')
                            : (l10n.localeName == 'es' ? 'Iniciar' : 'Start')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTimerDialog(
    BuildContext context,
    KitchenTimersNotifier notifier,
    AppLocalizations l10n, {
    KitchenTimerModel? existingTimer,
  }) {
    final nameController = TextEditingController(
      text: existingTimer != null ? existingTimer.name : '',
    );
    int selectedMinutes = existingTimer != null ? (existingTimer.remainingSeconds ~/ 60) : 5;
    int selectedSeconds = existingTimer != null ? (existingTimer.remainingSeconds % 60) : 0;
    int selectedColorIndex = existingTimer != null ? existingTimer.colorIndex : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 24.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existingTimer != null
                          ? (l10n.localeName == 'es' ? 'Editar Temporizador' : 'Edit Timer')
                          : l10n.timers_add_title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.timers_timer_name,
                        hintText: l10n.localeName == 'es' ? 'ej. Hervir Papas' : 'e.g. Boil Potatoes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.label_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.timers_duration,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimePickerColumn(
                          theme: theme,
                          label: l10n.localeName == 'es' ? 'Min' : 'Min',
                          value: selectedMinutes,
                          onIncrement: () => setModalState(() => selectedMinutes++),
                          onDecrement: () => setModalState(() {
                            if (selectedMinutes > 0) selectedMinutes--;
                          }),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                        _buildTimePickerColumn(
                          theme: theme,
                          label: l10n.localeName == 'es' ? 'Seg' : 'Sec',
                          value: selectedSeconds,
                          onIncrement: () => setModalState(() {
                            if (selectedSeconds < 55) selectedSeconds += 5;
                          }),
                          onDecrement: () => setModalState(() {
                            if (selectedSeconds >= 5) selectedSeconds -= 5;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [1, 3, 5, 10, 15, 30, 45, 60].map((m) {
                        return ChoiceChip(
                          label: Text('+$m m'),
                          selected: selectedMinutes == m && selectedSeconds == 0,
                          onSelected: (_) {
                            setModalState(() {
                              selectedMinutes = m;
                              selectedSeconds = 0;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_accentColors.length, (index) {
                        final color = _accentColors[index];
                        final isSelected = selectedColorIndex == index;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedColorIndex = index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        final totalSeconds = (selectedMinutes * 60) + selectedSeconds;
                        if (totalSeconds > 0) {
                          if (existingTimer != null) {
                            notifier.updateTimer(
                              existingTimer.id,
                              nameController.text,
                              totalSeconds,
                              selectedColorIndex,
                            );
                          } else {
                            notifier.addTimer(
                              nameController.text,
                              totalSeconds,
                              colorIndex: selectedColorIndex,
                            );
                          }
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(existingTimer != null ? Icons.check : Icons.play_arrow),
                      label: Text(
                        existingTimer != null
                            ? (l10n.localeName == 'es' ? 'Guardar Cambios' : 'Save Changes')
                            : (l10n.localeName == 'es' ? 'Iniciar Temporizador' : 'Start Timer'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimePickerColumn({
    required ThemeData theme,
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: onIncrement,
        ),
        Container(
          width: 64,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: onDecrement,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
