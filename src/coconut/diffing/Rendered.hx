package coconut.diffing;

@:structInit
class Rendered<Virtual, Real> {
  public var children(default, null):Map<NodeType, Array<RNode<Virtual, Real>>>;
  public var real(default, null):Array<Real>;
}