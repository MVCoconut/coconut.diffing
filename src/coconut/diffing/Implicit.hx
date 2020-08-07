package coconut.diffing;

import tink.state.*;

import coconut.ui.internal.*;
import coconut.ui.internal.ImplicitContext;
import coconut.diffing.VNode;

private typedef Attr<Real:{}> = {
  final children:Observable<Children<VNode<Real>>>;
  final defaults:ImplicitValues;
}

class Implicit<Real:{}> extends Widget<Real> {
  final children:Slot<Children<VNode<Real>>, Observable<Children<VNode<Real>>>>;

  function new(attr:Attr<Real>) {
    var children = new Slot<Children<VNode<Real>>, Observable<Children<VNode<Real>>>>(this);
    super(children.observe().map(c -> VNode.fragment(null, c)), noop, noop, noop);
    this.children = children;

    this._coco_implicits = new ImplicitContext();
    this._coco_implicits.update(attr.defaults);
  }

  static function noop() {}

  static final TYPE:WidgetType<Attr<Dynamic>, Dynamic> = {
    create: Implicit.new,
    update: (a, w) -> {
      var w = (cast w:Implicit<Dynamic>);
      w.children.setData(a.children);
      w._coco_implicits.update(a.defaults);
    }
  }

  static public function fromHxx<Real:{}>(attr:Attr<Real>):VNode<Real>
    return VWidget(cast TYPE, null, null, attr);
}