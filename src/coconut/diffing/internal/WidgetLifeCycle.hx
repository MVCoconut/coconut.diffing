package coconut.diffing.internal;

import tink.state.internal.*;
import tink.state.Observable;
using tink.CoreApi;

@:access(coconut.diffing.Widget)
class WidgetLifeCycle<Native> extends Parent implements Observer {

  final owner:Widget<Native>;
  final rendered:RCell<Native>;
  final applicator:Applicator<Native>;

  public function new(owner, context, parent, cursor:Cursor<Native>, later, hydrate:Bool) {
    super(context, parent);
    this.owner = owner;
    #if debug
    if (owner._coco_lifeCycle != null)
      throw '${owner} has been mounted twice';
    #end
    owner._coco_lifeCycle = this;
    this.applicator = cursor.applicator;
    this.rendered = new RCell(this, poll(), cursor, later, hydrate);
    (owner._coco_vStructure:ObservableObject<VNode<Native>>).subscribe(this);
    later(owner._coco_viewMounted);
  }

  function poll()
    return Observable.untracked(() -> owner._coco_vStructure.value);

  public function reiterate(applicator)
    return rendered.reiterate(applicator);

  public function justInsert(cursor, later)
    rerender(later, cursor);

  public function rerender(later, ?cursor)
    if (rendered.update(poll(), cursor, later))
      later(owner._coco_viewUpdated);

  override public function performUpdate(later) {
    if (owner._coco_lifeCycle != this) return;
    rerender(later);
    super.performUpdate(later);
  }

  public function notify(from)
    invalidateParent();

  public function destroy(applicator:Applicator<Native>) {
    switch owner._coco_viewUnmounting {
      case null:
      case f: f();
    }
    (owner._coco_vStructure:ObservableObject<VNode<Native>>).unsubscribe(this);
    owner._coco_lifeCycle = null;
    return rendered.destroy(applicator);
  }

  public function forEach(f)
    rendered.forEach(f);
}