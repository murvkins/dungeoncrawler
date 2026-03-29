enum RenderPriority {
  floor(0),
  props(1000),
  player(990),
  enemy(990),
  upperwalls(1000),
  torches(3000),
  walls(4000),
  darkness(5000),
  ;

  final int value;
  const RenderPriority(this.value);
}
