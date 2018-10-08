package coconut.diffing;

@:structInit
class Rendered<Virtual, Real> {
  public var byType(default, null):Map<NodeType, Array<RNode<Virtual, Real>>>;
  public var childList(default, null):Array<RNode<Virtual, Real>>;
}