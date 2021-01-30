package coconut.diffing;

import tink.CoreApi.CallbackLink;
import tink.state.internal.*;
import tink.state.Observable;

class VWidget<Data, Native, Concrete:Widget<Native>> implements VNode<Native> {
  public final type:TypeId;
  public final data:Data;
  public final factory:Factory<Data, Concrete>;
  public final ref:Null<coconut.ui.Ref<Concrete>>;
  public final key:Null<Key>;

  public function new(factory, data, ?key, ?ref) {
    this.factory = factory;
    this.type = factory.type;
    this.data = data;
    this.ref = ref;
    this.key = key;
  }

  public function render(parent, cursor) {
    return new RWidget(parent, this, cursor);
  }
}

class RWidget<Data, Native, Concrete:Widget<Native>> implements RNode<Native> {
  final widget:Concrete;
  final lifeCycle:WidgetLifeCycle<Native>;

  var last:VWidget<Data, Native, Concrete>;
  public final type:TypeId;
  public function new(parent, v:VWidget<Data, Native, Concrete>, cursor:Cursor<Native>) {
    this.last = v;
    this.type = v.type;
    this.widget = v.factory.create(v.data);
    this.lifeCycle = new WidgetLifeCycle(widget, parent, cursor);

    switch v.ref {
      case null:
      case f: f(widget);
    }
  }

  public function count()
    return lifeCycle.count();

  public function update(next:VNode<Native>, cursor:Cursor<Native>) {
    var next:VWidget<Data, Native, Concrete> = Cast.down(next, VWidget);

    if (next.ref != last.ref) {
      switch last.ref {
        case null:
        case f: f(null);
      }
      switch  next.ref {
        case null:
        case f: f(null);
      }
    }

    var prev = last.data;
    last = next;
    next.factory.update(widget, next.data, prev);
    lifeCycle.rerender(cursor);
  }

  public function reiterate(applicator:Applicator<Native>)
    return lifeCycle.reiterate(applicator);

  public function delete(cursor:Cursor<Native>) {
    lifeCycle.destroy(cursor);
    switch last.ref {
      case null:
      case f: f(null);
    }
  }
}

@:access(coconut.diffing.Widget)
class WidgetLifeCycle<Native> extends Parent implements Invalidatable {

  var owner:Widget<Native>;
  final rendered:RCell<Native>;
  final applicator:Applicator<Native>;
  final link:CallbackLink;

  public function new(owner, parent, cursor:Cursor<Native>) {
    super(parent);
    this.owner = owner;
    this.applicator = cursor.applicator;
    this.rendered = new RCell(this, poll(), cursor);
    this.link = (owner._coco_vStructure:ObservableObject<VNode<Native>>).onInvalidate(this);
  }

  function poll()
    return Observable.untracked(() -> owner._coco_vStructure.value);

  public function reiterate(applicator)
    return rendered.reiterate(applicator);

  public function rerender(?cursor) {
    rendered.update(poll(), cursor);
  }

  override public function update() {
    if (owner == null) return;
    rerender();
    super.update();
  }

  public inline function count()
    return rendered.count();

  public function invalidate()
    invalidateParent();

  public function destroy(cursor:Cursor<Native>) {
    link.cancel();
    rendered.delete(cursor);
    owner = null;
  }
}