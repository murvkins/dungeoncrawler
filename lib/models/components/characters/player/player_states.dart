enum PlayerState {
  idle,
  walk,
  attack,
  hurt,
  dead,
}

enum PlayerFacing {
  left,
  right,
  down,
  up,
}

enum PlayerStateFacing {
  idleleft(PlayerState.idle, PlayerFacing.left),
  idleright(PlayerState.idle, PlayerFacing.right),
  idledown(PlayerState.idle, PlayerFacing.down),
  idleup(PlayerState.idle, PlayerFacing.up),

  walkleft(PlayerState.walk, PlayerFacing.left),
  walkright(PlayerState.walk, PlayerFacing.right),
  walkdown(PlayerState.walk, PlayerFacing.down),
  walkup(PlayerState.walk, PlayerFacing.up),

  attackleft(PlayerState.attack, PlayerFacing.left),
  attackright(PlayerState.attack, PlayerFacing.right),
  attackdown(PlayerState.attack, PlayerFacing.down),
  attackup(PlayerState.attack, PlayerFacing.up),

  hurtleft(PlayerState.hurt, PlayerFacing.left),
  hurtright(PlayerState.hurt, PlayerFacing.right),
  hurtdown(PlayerState.hurt, PlayerFacing.down),
  hurtup(PlayerState.hurt, PlayerFacing.up),

  deadleft(PlayerState.dead, PlayerFacing.left),
  deadright(PlayerState.dead, PlayerFacing.right),
  deaddown(PlayerState.dead, PlayerFacing.down),
  deadup(PlayerState.dead, PlayerFacing.up),
  ;

  final PlayerState playerState;
  final PlayerFacing playerFacing;

  const PlayerStateFacing(this.playerState, this.playerFacing);

  static PlayerStateFacing fromStateFacing(PlayerState playerState, PlayerFacing playerFacing) {
    return PlayerStateFacing.values.firstWhere(
      (element) => element.playerState == playerState && element.playerFacing == playerFacing,
      orElse: () => PlayerStateFacing.idledown,
    );
  }
}
