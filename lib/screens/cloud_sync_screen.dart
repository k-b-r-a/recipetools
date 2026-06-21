import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../provider/cloud_sync_provider.dart';
import '../widgets/floating_pill_app_bar.dart';

class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatDateTime(DateTime dt, String locale) {
    try {
      final format = DateFormat.yMMMd(locale).add_Hm();
      return format.format(dt);
    } catch (_) {
      final format = DateFormat.yMMMd('en').add_Hm();
      return format.format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final syncState = ref.watch(cloudSyncProvider);
    final syncNotifier = ref.read(cloudSyncProvider.notifier);

    // Listen to changes in success/error messages to show SnackBar notifications
    ref.listen<CloudSyncState>(cloudSyncProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: theme.colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              buildFloatingPillAppBar(
                context: context,
                title: l10n.cloud_sync_title,
                controller: _scrollController,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildConnectionHeader(syncState, syncNotifier, theme, l10n),
                    const SizedBox(height: 24),
                    if (syncState.signedIn) ...[
                      _buildBackupActionsCard(syncState, syncNotifier, theme, l10n),
                      const SizedBox(height: 24),
                      _buildBackupsListHeader(theme, l10n),
                      const SizedBox(height: 12),
                      if (syncState.backups.isEmpty)
                        _buildEmptyBackupsPlaceholder(theme, l10n)
                      else
                        _buildBackupsList(syncState, syncNotifier, theme, l10n),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          if (syncState.loading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionHeader(
    CloudSyncState state,
    CloudSyncNotifier notifier,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              child: Icon(
                state.signedIn ? Icons.cloud_done_outlined : Icons.backup_outlined,
                color: theme.colorScheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.signedIn ? l10n.cloud_sync_connected : l10n.cloud_sync_disconnected,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (state.signedIn && state.email != null) ...[
              const SizedBox(height: 4),
              Text(
                state.email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.cloud_sync_desc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (!state.signedIn)
              ElevatedButton.icon(
                onPressed: () => notifier.signIn(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.login),
                label: Text(
                  l10n.cloud_sync_connect_btn,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => notifier.signOut(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: Text(l10n.cloud_sync_disconnect_btn),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupActionsCard(
    CloudSyncState state,
    CloudSyncNotifier notifier,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    // Check if the service is in simulation mode to show Sandbox Badge
    final isSim = ref.read(googleDriveSyncServiceProvider).isSimulationMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSim) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.developer_mode, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.cloud_sync_sandbox_badge,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.cloud_sync_sandbox_desc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: () => _confirmBackup(context, notifier, l10n),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.cloud_upload_outlined),
          label: Text(
            l10n.cloud_sync_backup_btn,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBackupsListHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.cloud_sync_backups_header,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: () => ref.read(cloudSyncProvider.notifier).refreshBackups(),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildEmptyBackupsPlaceholder(ThemeData theme, AppLocalizations l10n) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cloud_sync_no_backups,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupsList(
    CloudSyncState state,
    CloudSyncNotifier notifier,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.backups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final backup = state.backups[index];
        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  child: Icon(Icons.storage, color: theme.colorScheme.secondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatBytes(backup.sizeBytes),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.circle,
                            size: 4,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDateTime(backup.dateCreated, l10n.localeName),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings_backup_restore, color: theme.colorScheme.primary),
                      onPressed: () => _confirmRestore(context, notifier, backup.id, l10n),
                      tooltip: 'Restore',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      onPressed: () => _confirmDelete(context, notifier, backup.id, l10n),
                      tooltip: 'Delete',
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

  void _confirmBackup(BuildContext context, CloudSyncNotifier notifier, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cloud_sync_backup_confirm_title),
        content: Text(l10n.cloud_sync_backup_confirm_desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.discard_button),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              notifier.createBackup();
            },
            child: Text(l10n.save_button),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(
    BuildContext context,
    CloudSyncNotifier notifier,
    String backupId,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cloud_sync_restore_confirm_title),
        content: Text(l10n.cloud_sync_restore_confirm_desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.discard_button),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              notifier.restoreBackup(backupId);
            },
            child: Text(l10n.settings_reset_db_confirm),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CloudSyncNotifier notifier,
    String backupId,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cloud_sync_delete_confirm_title),
        content: Text(l10n.cloud_sync_delete_confirm_desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.discard_button),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              notifier.deleteBackup(backupId);
            },
            child: Text(l10n.delete_button),
          ),
        ],
      ),
    );
  }
}
