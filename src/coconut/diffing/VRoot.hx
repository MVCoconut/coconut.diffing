package coconut.diffing;

class VRoot<Virtual, Real> implements Parent<Virtual, Real> {
  
  public var differ(default, null):Differ<Virtual, Real>;
  public var target(default, null):Real;

  function _coco_getRender():Rendered<Virtual, Real>
    return rendered;

  var rendered:Rendered<Virtual, Real>;

  public function new(target, content, differ) {
    this.differ = differ;
    this.target = target;
    this.rendered = differ.mountInto(target, content);
  }

  var invalid:Bool = false;
  var _afterRefresh:Array<Void->Void> = [];

  public function afterRefresh(f)
    this._afterRefresh.push(f);

  function _coco_invalidate()
    if (!invalid) {
      invalid = true;
      Callback.defer(refresh);
    }

  var scheduled:Array<Widget<Virtual, Real>> = [];
  public function schedule(w:Widget<Virtual, Real>) //TODO: perhaps just passing the function would be alright
    scheduled.push(w);

  function refresh() {

    while (scheduled.length > 0)//TODO: make sure this terminates
      for (w in scheduled.splice(0, scheduled.length)) @:privateAccess w._coco_update();

    while (_afterRefresh.length > 0)//TODO: make sure this terminates
      for (f in _afterRefresh.splice(0, _afterRefresh.length)) f();

    invalid = false;
  }

  public function unmount() {
    differ.teardown(target);
    target = null;
  }

}