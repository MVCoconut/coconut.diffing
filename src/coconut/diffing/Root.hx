package coconut.diffing;

import coconut.ui.internal.ImplicitContext;

enum abstract Hydration(Int) {
  var No;
  var Into;
  var Onto;
}

class Root<Native> extends Parent {
  final rendered:RCell<Native>;

  public function new(parent, applicator:Applicator<Native>, ?content, hydration = No) {
    super(new ImplicitContext());
    var rendered = Parent.withLater(later -> new RCell(this, content, if (hydration == Onto) applicator.siblings(parent) else applicator.children(parent), later, hydration != No));
    this.rendered = rendered;
  }

  static final byParent = new Map<{}, Root<Dynamic>>();
  static public function fromNative<Native:{}>(parent:Native, applicator:Applicator<Native>):Root<Native>
    return cast switch byParent[parent] {
      case null: byParent[parent] = new Root(parent, applicator);
      case v: v;
    }

  public function render(v:VNode<Native>)
    Parent.withLater(later -> this.rendered.update(v, later));
}
