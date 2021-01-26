package coconut.diffing;

import tink.CoreApi.CallbackLink;
import tink.state.internal.*;
import tink.state.Observable;

class VWidget<Data, Native, Concrete:Widget<Native>> implements VNode<Native> {
  public final type:TypeId;
  public final data:Data;
  public final factory:Factory<Data, Concrete>;
  public final ref:Null<coconut.ui.Ref<Concrete>>;

  public function new(factory, data, ?ref, ?children) {
    this.factory = factory;
    this.type = factory.type;
    this.data = data;
    this.ref = ref;
  }

  public function render(parent, cursor) {
    return new RWidget(parent, this, cursor);
  }
}

class RWidget<Data, Native, Concrete:Widget<Native>> implements RNode<Native> {
  final widget:Concrete;
  final lifeCycle:WidgetLifeCycle<Native>;

  var last:Data;
  public final type:TypeId;
  public function new(parent, v:VWidget<Data, Native, Concrete>, cursor:Cursor<Native>) {
    this.last = v.data;
    this.type = v.type;
    this.widget = v.factory.create(v.data);
    this.lifeCycle = new WidgetLifeCycle(widget, parent, cursor);
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>) {
    var next:VWidget<Data, Native, Concrete> = Cast.down(next, VWidget);
    var prev = last;
    next.factory.update(widget, last = next.data, prev);
    lifeCycle.update(cursor);
  }

  public function reiterate(applicator:Applicator<Native>)
    return lifeCycle.reiterate(applicator);

  public function delete(cursor:Cursor<Native>)
    lifeCycle.destroy(cursor);
}

@:access(coconut.diffing.Widget)
class WidgetLifeCycle<Native> implements Invalidatable {

  final owner:Widget<Native>;
  final rendered:RNode<Native>;
  final applicator:Applicator<Native>;
  final link:CallbackLink;
  final parent:Parent;

  public function new(owner, parent, cursor:Cursor<Native>) {
    this.owner = owner;
    this.parent = parent;
    this.applicator = cursor.applicator;
    this.rendered = poll().render(parent, cursor);
    this.link = (owner._coco_vStructure:ObservableObject<VNode<Native>>).onInvalidate(this);
  }

  function poll()
    return Observable.untracked(() -> owner._coco_vStructure.value);

  public function reiterate(applicator)
    return rendered.reiterate(applicator);

  public function update(cursor)
    rendered.update(poll(), cursor);

  public function invalidate()
    update(rendered.reiterate(applicator));

  public function destroy(cursor:Cursor<Native>) {
    link.dissolve();
    rendered.delete(cursor);
  }
}