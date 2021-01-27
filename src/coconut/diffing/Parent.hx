package coconut.diffing;

class Parent implements Child {
  final pendingUpdates = new Array<Child>();
  final parent:Null<Parent>;

  public function new(?parent)
    this.parent = parent;

  function scheduleUpdate(child:Child) {
    if (pendingUpdates.push(child) == 1)
      invalidateParent();
  }

  function update()
    switch pendingUpdates.length {
      case 0:
      case v:
        for (c in pendingUpdates.splice(0, v))
          c.update();
    }

  function invalidateParent()
    switch parent {
      case null:
        tink.state.Observable.schedule(update);
      case v:
        v.scheduleUpdate(this);
    }

}

interface Child {
  private function update():Void;
}