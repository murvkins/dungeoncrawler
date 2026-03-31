class EnemyStats {
  final int level;
  int hp;
  final int maxhp;
  final int attack;
  final int xpreward;

  EnemyStats({
    this.level = 1,
    this.hp = 10,
    this.maxhp = 10,
    this.attack = 1,
    this.xpreward = 10,
  });

  EnemyStats copyWith({
    int? level,
    int? hp,
    int? maxhp,
    int? attack,
    int? xpreward,
  }) {
    return EnemyStats(
      level: level ?? this.level,
      hp: (hp ?? this.hp).clamp(0, (maxhp ?? this.maxhp)),
      maxhp: maxhp ?? this.maxhp,
      attack: attack ?? this.attack,
      xpreward: xpreward ?? this.xpreward,
    );
  }

  factory EnemyStats.forFloor(int f) {    
    return EnemyStats(
      level: f,
      hp: 5 + (f * 2),
      maxhp: 5 + (f * 2),
      attack: 1 + (f ~/ 3),
      xpreward: 10 + (f * 5),
    );
  }
}
