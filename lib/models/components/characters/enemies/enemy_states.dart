enum EnemyState {
  idle,
  walk,
  attack,
  hurt,
  sleeping,
  wakingup,
  dead,
}

enum EnemyFacing {
  left,
  right,
  down,
  up,
}

enum EnemyStateFacing {
  idleleft(EnemyState.idle, EnemyFacing.left),
  idleright(EnemyState.idle, EnemyFacing.right),
  idledown(EnemyState.idle, EnemyFacing.down),
  idleup(EnemyState.idle, EnemyFacing.up),

  walkleft(EnemyState.walk, EnemyFacing.left),
  walkright(EnemyState.walk, EnemyFacing.right),
  walkdown(EnemyState.walk, EnemyFacing.down),
  walkup(EnemyState.walk, EnemyFacing.up),

  attackleft(EnemyState.attack, EnemyFacing.left),
  attackright(EnemyState.attack, EnemyFacing.right),
  attackdown(EnemyState.attack, EnemyFacing.down),
  attackup(EnemyState.attack, EnemyFacing.up),

  hurtup(EnemyState.hurt, EnemyFacing.up),
  hurtleft(EnemyState.hurt, EnemyFacing.left),
  hurtright(EnemyState.hurt, EnemyFacing.right),
  hurtdown(EnemyState.hurt, EnemyFacing.down),

  deadup(EnemyState.dead, EnemyFacing.up),
  deadleft(EnemyState.dead, EnemyFacing.left),
  deadright(EnemyState.dead, EnemyFacing.right),
  deaddown(EnemyState.dead, EnemyFacing.down),

  wakingupup(EnemyState.wakingup, EnemyFacing.up),
  wakingupleft(EnemyState.wakingup, EnemyFacing.left),
  wakingupright(EnemyState.wakingup, EnemyFacing.right),
  wakingupdown(EnemyState.wakingup, EnemyFacing.down),

  sleepingup(EnemyState.sleeping, EnemyFacing.up),
  sleepingleft(EnemyState.sleeping, EnemyFacing.left),
  sleepingright(EnemyState.sleeping, EnemyFacing.right),
  sleepingdown(EnemyState.sleeping, EnemyFacing.down),
  ;

  final EnemyState enemyState;
  final EnemyFacing enemyFacing;

  const EnemyStateFacing(this.enemyState, this.enemyFacing);

  static EnemyStateFacing fromStateFacing(EnemyState enemyState, EnemyFacing enemyFacing) {
    return EnemyStateFacing.values.firstWhere(
      (element) => element.enemyState == enemyState && element.enemyFacing == enemyFacing,
      orElse: () => EnemyStateFacing.idledown,
    );
  }
}

const enemy_idles = [
  EnemyStateFacing.idledown,
  EnemyStateFacing.idleup,
  EnemyStateFacing.idleleft,
  EnemyStateFacing.idleright,
];

const enemy_dead = [
  EnemyStateFacing.deaddown,
  EnemyStateFacing.deadup,
  EnemyStateFacing.deadleft,
  EnemyStateFacing.deadright,
];

const enemy_facings = [
  EnemyFacing.left,
  EnemyFacing.right,
  EnemyFacing.up,
  EnemyFacing.down,
];
