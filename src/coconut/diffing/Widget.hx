package coconut.diffing;

import tink.state.Observable;

class Widget<Virtual, Real> implements Parent<Virtual, Real> {

  @:noCompletion var _coco_viewMounted:Void->Void;
  @:noCompletion var _coco_viewUpdated:Void->Void;
  @:noCompletion var _coco_viewUnmounting:Void->Void;

  @:noCompletion var _coco_vStructure:ObservableObject<Array<VNode<Virtual, Real>>>;
  @:noCompletion var _coco_lastSnapshot:Array<VNode<Virtual, Real>>;
  @:noCompletion var _coco_lastRender:Rendered<Virtual, Real>;
  @:noCompletion var _coco_invalid:Bool = false;
  @:noCompletion var _coco_parent:Parent<Virtual, Real>;
  @:noCompletion var _coco_differ:Differ<Virtual, Real>;
  @:noCompletion var _coco_link:CallbackLink;
    
  public function new(
    rendered:Observable<VNode<Virtual, Real>>,
    mounted:Void->Void,
    updated:Void->Void,
    unmounting:Void->Void
  ) {
    this._coco_vStructure = rendered.map(function (r) return [r]);
    this._coco_viewMounted = mounted;
    this._coco_viewUpdated = updated;
    this._coco_viewUnmounting = unmounting;    
  }

  @:noCompletion function _coco_getRender(later:Later):Rendered<Virtual, Real> {
    if (_coco_invalid) {
      _coco_invalid = false;
      var nuSnapshot = _coco_vStructure.poll().value;
      if (nuSnapshot != _coco_lastSnapshot) {
        _coco_lastSnapshot = nuSnapshot;
        _coco_lastRender = @:privateAccess _coco_differ.updateAll(_coco_lastRender, nuSnapshot, this, later);
        _coco_arm();
        later(_coco_viewUpdated);
      }
    }
    return _coco_lastRender;
  }

  @:noCompletion function _coco_invalidate()
    if (!_coco_invalid) {
      _coco_invalid = true;
      if (_coco_parent != null)
        _coco_parent._coco_invalidate();
      defer(_coco_update);//TODO: this is not optimal
    }

  @:noCompletion function _coco_update()
    if (_coco_invalid) 
      _coco_differ.run(function (later) _coco_getRender(later));

  static function defer(f:Void->Void)
    Callback.defer(f);

  @:noCompletion function _coco_arm() {
    _coco_link.dissolve();//you never know
    _coco_link = _coco_vStructure.poll().becameInvalid.handle(_coco_invalidate);
  }

  @:noCompletion function _coco_teardown() {
    _coco_viewUnmounting();
    for (c in _coco_lastRender.childList)
      @:privateAccess _coco_differ.destroyRender(c);
  }

  @:noCompletion function _coco_initialize(differ:Differ<Virtual, Real>, parent:Parent<Virtual, Real>, later:Later) {
    _coco_parent = parent;
    _coco_differ = differ;
    _coco_lastRender = @:privateAccess differ.renderAll(
      _coco_lastSnapshot = _coco_vStructure.poll().value,
      parent,
      later
    );
    _coco_arm();
    later(_coco_viewMounted);
  }

}