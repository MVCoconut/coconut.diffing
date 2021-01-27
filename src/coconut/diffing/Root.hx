package coconut.diffing;

class Root<Native> implements Parent {
  final parent:Native;
  final applicator:Applicator<Native>;
  final rendered:RCell<Native>;

  public function new(parent, applicator) {
    this.parent = parent;
    this.applicator = applicator;
    var cursor = applicator.children(parent);
    this.rendered = new RCell(this, null, cursor);
    cursor.close();
  }

  static final byParent = new Map<{}, Root<Dynamic>>();
  static public function fromNative<Native:{}>(parent:Native, applicator:Applicator<Native>):Root<Native>
    return cast switch byParent[parent] {
      case null: byParent[parent] = new Root(parent, applicator);
      case v: v;
    }

  public function render(v:VNode<Native>)
    this.rendered.update(v);
}
