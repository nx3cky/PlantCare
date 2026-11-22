import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/models/care_entry.dart';
import '../../core/data/models/plant.dart';
import '../../core/data/repositories/garden_repository.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/app_snack_bar.dart';
import 'bloc/journal_bloc.dart';

/// Швидкі дії з журналом, спільні для головного екрана й деталей рослини.
abstract final class CareActions {
  /// Відмічає процедуру, виконану щойно, і пропонує скасувати її в SnackBar.
  static void logNow(BuildContext context, Plant plant, CareType type) {
    final journal = context.read<JournalBloc>();
    final entry = CareEntry(
      id: context.read<GardenRepository>().newId(),
      plantId: plant.id,
      type: type,
      performedAt: DateTime.now(),
    );
    journal.add(JournalEntrySaved(entry));

    final interval = type == CareType.watering ? plant.wateringIntervalDays : plant.fertilizingIntervalDays;
    final next = interval == null
        ? ''
        : ' ${type == CareType.watering ? 'Наступний' : 'Наступне'}: ${DateFormatUa.shortDate(DateFormatUa.addDays(entry.performedAt, interval))}';
    context.showMessage(
      '${type.label} · ${plant.name} відмічено.$next',
      actionLabel: 'Скасувати',
      onAction: () => journal.add(JournalEntryDeleted(entry)),
    );
  }

  /// Видаляє запис і дає змогу відновити його.
  static void delete(BuildContext context, CareEntry entry, {String? plantName}) {
    final journal = context.read<JournalBloc>()..add(JournalEntryDeleted(entry));
    context.showMessage(
      'Запис «${entry.type.label}${plantName == null ? '' : ' · $plantName'}» видалено',
      actionLabel: 'Скасувати',
      onAction: () => journal.add(JournalEntrySaved(entry)),
    );
  }
}
