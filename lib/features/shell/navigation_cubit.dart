import 'package:flutter_bloc/flutter_bloc.dart';

/// Вкладки нижньої навігації.
enum AppTab { home, plants, journal, profile }

/// Поточна вкладка головного екрана. Cubit – спрощений BLoC без подій:
/// екрани викликають методи, а не надсилають події (наприклад, «Усі записи»
/// на екрані рослини відкриває вкладку «Журнал»).
class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.home);

  void select(AppTab tab) => emit(tab);
}
