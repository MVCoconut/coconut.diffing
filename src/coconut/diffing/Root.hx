package coconut.diffing;

import coconut.ui.internal.ImplicitContext;

class Root<Native> extends Parent {
  final rendered:RCell<Native>;

  public function new(parent, applicator:Applicator<Native>) {
    super(new ImplicitContext());
    this.rendered = new RCell(this, null, applicator.children(parent));
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
