package coconut.diffing;

import coconut.data.Value;
import coconut.ui.internal.*;
import coconut.ui.internal.ImplicitContext;
import coconut.diffing.VNode;

private typedef Attr<Real:{}, RenderResult:VNode<Real>> = {
  final children:Value<Children<RenderResult>>;
  final defaults:ImplicitValues;
}

class Implicit<Real:{}, RenderResult:VNode<Real>> extends Widget<Real> {

  final children:Slot<Children<RenderResult>, Value<Children<RenderResult>>>;

  function new(attr:Attr<Real, RenderResult>) {
    this.children = new Slot<Children<RenderResult>, Value<Children<RenderResult>>>(this);

    children.setData(attr.children);

    super(children.observe().map(c -> VNode.fragment(null, c)), noop, noop, noop);

    this._coco_implicits = new ImplicitContext();
    this._coco_implicits.update(attr.defaults);
  }

  static function noop() {}

  static public function type<Real:{}, RenderResult:VNode<Real>>():WidgetType<Attr<Real, RenderResult>, Real>
    return {
      create: Implicit.new,
      update: (a, w) -> {
        var w = (cast w:Implicit<Real, RenderResult>);
        w.children.setData(a.children);
        w._coco_implicits.update(a.defaults);
      }
    }
}