package coconut.diffing;

class VMany<Native> implements VNode<Native> {
  static final TYPE = new TypeId();
  public final type = TYPE;
  public final children:ReadOnlyArray<VNode<Native>>;

  public function new(children)
    this.children = children;

  public function render(parent, cursor):RNode<Native>
    return new RMany(parent, children, cursor);
}