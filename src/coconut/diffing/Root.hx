package coconut.diffing;

class Root<Native> implements Parent {
  final parent:Native;
  final applicator:Applicator<Native>;
  final rendered:RNode<Native>;

  public function new(parent, applicator) {
    this.parent = parent;
    this.applicator = applicator;
    this.rendered = process(c -> new RMany(this, [], c));
  }

  function process<X>(f):X {
    var cursor = applicator.children(parent);
    var ret = f(cursor);
    cursor.close();
    return ret;
  }

  static final byParent = new Map<{}, Root<Dynamic>>();
  static public function fromNative<Native:{}>(parent:Native, applicator:Applicator<Native>):Root<Native>
    return cast switch byParent[parent] {
      case null: byParent[parent] = new Root(parent, applicator);
      case v: v;
    }

  public function render(v:VNode<Native>)
    process(c -> rendered.update(new VMany([v]), c));
}
