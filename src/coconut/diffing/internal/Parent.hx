package coconut.diffing.internal;

import coconut.ui.internal.ImplicitContext;

class Parent implements Child {
  final pendingUpdates = new Array<Child>();
  final parent:Null<Parent>;
  final context:ImplicitContext;

  public function new(context:ImplicitContext, ?parent) {
    this.context = context;
    this.parent = parent;
  }

  function scheduleUpdate(child:Child) {
    if (pendingUpdates.push(child) == 1)
      invalidateParent();
  }

  static public function withLater<X>(f:(later:(task:()->Void)->Void)->X) {
    var tasks = [];
    var ret = f(function (task) if (task != null) tasks.push(task));
    for (t in tasks)
      t();
    return ret;
  }

  function performUpdate(later)
    if (pendingUpdates.length > 0)
      for (c in pendingUpdates.splice(0, pendingUpdates.length))
        c.performUpdate(later);

  function invalidateParent()
    switch parent {
      case null:
        tink.state.Observable.schedule(() -> withLater(performUpdate));//TODO: consider looping
      case v:
        v.scheduleUpdate(this);
    }

}

interface Child {
  private function performUpdate(later:(task:()->Void)->Void):Void;
}