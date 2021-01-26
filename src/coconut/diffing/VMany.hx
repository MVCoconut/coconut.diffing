package coconut.diffing;

class VMany<Native> implements VNode<Native> {
  static final TYPE = new TypeId();
  static final EMPTY:ReadOnlyArray<Dynamic> = [];
  public final type = TYPE;
  public final children:ReadOnlyArray<VNode<Native>>;

  public function new(?children)
    this.children = switch children {
      case null: cast EMPTY;
      case v: v;
    }

  public function render(parent, cursor):RNode<Native>
    return new RMany(parent, children, cursor);
}