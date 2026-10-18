import 'package:flutter/material.dart';

/// Тимчасові hardcoded-дані замість бекенду (ЛР3 – без бізнес-логіки).
abstract final class MockUser {
  static const String firstName = 'Микола';
  static const String fullName = 'Микола Гейко';
  static const String initials = 'МГ';
  static const String email = 'mykola.heiko@gmail.com';
  static const int plantsCount = 8;
  static const int journalCount = 126;
}

enum CareKind { water, feed }

class CareTask {
  final String action;
  final String plant;
  final String subtitle;
  final String image;
  final CareKind kind;
  final bool overdue;

  const CareTask({
    required this.action,
    required this.plant,
    required this.subtitle,
    required this.image,
    required this.kind,
    this.overdue = false,
  });

  IconData get icon => switch (kind) {
        CareKind.water => Icons.water_drop,
        CareKind.feed => Icons.science,
      };
}

class Plant {
  final String name;
  final String nextCare;
  final String image;

  const Plant({required this.name, required this.nextCare, required this.image});
}

const todayTasks = <CareTask>[
  CareTask(
    action: 'Полити',
    plant: 'Хлорофітум',
    subtitle: 'Прострочено на 1 день',
    image: 'assets/images/chloro.jpg',
    kind: CareKind.water,
    overdue: true,
  ),
  CareTask(
    action: 'Полити',
    plant: 'Монстера',
    subtitle: 'Вітальня · кожні 7 днів',
    image: 'assets/images/monstera.jpg',
    kind: CareKind.water,
  ),
  CareTask(
    action: 'Підживити',
    plant: 'Фікус',
    subtitle: 'Спальня · раз на 30 днів',
    image: 'assets/images/ficus.jpg',
    kind: CareKind.feed,
  ),
];

const myPlants = <Plant>[
  Plant(name: 'Спатифілум', nextCare: 'Полив · через 2 дні', image: 'assets/images/spathiphyllum.png'),
  Plant(name: 'Заміокулькас', nextCare: 'Полив · через 9 днів', image: 'assets/images/zamio.jpg'),
  Plant(name: 'Сансев’єрія', nextCare: 'Полив · через 12 днів', image: 'assets/images/sansevieria.jpg'),
  Plant(name: 'Ехеверія', nextCare: 'Полив · через 5 днів', image: 'assets/images/echeveria.jpg'),
];
