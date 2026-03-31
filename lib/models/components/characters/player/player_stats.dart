class PlayerStats {
  final int level;
  final int hp;
  final int maxhp;
  final int attack;
  final int xp;
  final int xprequired;

  PlayerStats({
    this.level = 1,
    this.hp = 10,
    this.maxhp = 10,
    this.attack = 1,
    this.xp = 0,
    this.xprequired = 100,
  });

  double get hpPercent => hp / maxhp;
  double get xpPercent => xp / xprequired;

  PlayerStats copyWith({
    int? level,
    int? hp,
    int? maxhp,
    int? attack,
    int? xp,
    int? xprequired,
  }) {
    return PlayerStats(
      level: level ?? this.level,
      hp: (hp ?? this.hp).clamp(0, (maxhp ?? this.maxhp)),
      maxhp: maxhp ?? this.maxhp,
      attack: attack ?? this.attack,
      xp: xp ?? this.xp,
      xprequired: xprequired ?? this.xprequired,
    );
  }

  factory PlayerStats.baselevel() {
    return PlayerStats(
      level: 1,
      hp: 10,
      maxhp: 10,
      attack: 1,
      xp: 0,
      xprequired: 100,
    );
  }
}
