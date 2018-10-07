package coconut.diffing;

import tink.state.Observable;

class Widget<Virtual, Real> implements Parent<Virtual, Real> {

  var _coco_vStructure:ObservableObject<Array<VNode<Virtual, Real>>>;
  var _coco_lastSnapshot:Array<VNode<Virtual, Real>>;
  var _coco_lastRender:Rendered<Virtual, Real>;
  var _coco_invalid:Bool = false;
  var _coco_parent:Parent<Virtual, Real>;
  var _coco_root:VRoot<Virtual, Real>;
  var _coco_link:CallbackLink;
  var _coco_type:String;

  function _coco_getRender():Rendered<Virtual, Real>
    return _coco_lastRender;

  function _coco_invalidate()
    if (!_coco_invalid) {
      _coco_invalid = true;
      if (_coco_parent != null)
        _coco_parent._coco_invalidate();
      _coco_root.schedule(this);
    }

  function _coco_update() if (_coco_invalid) {
    _coco_invalid = false;
    var nuSnapshot = _coco_vStructure.poll().value;
    if (nuSnapshot != _coco_lastSnapshot) {
      _coco_lastSnapshot = nuSnapshot;
      _coco_arm();
      _coco_lastRender = _coco_root.differ.update(_coco_lastRender, nuSnapshot, this);
    }
  }

  public function _coco_replaceChildren(w:Widget<Virtual, Real>, children:Rendered<Virtual, Real>):Void {}

  function _coco_arm() {
    _coco_link.dissolve();//you never know
    _coco_link = _coco_vStructure.poll().becameInvalid.handle(_coco_invalidate);
  }

  function _coco_getReal():Array<Real> {
    _coco_update();
    return _coco_lastRender.real;
  }
  
  function _coco_teardown() {
    //TODO: implement
  }

  function _coco_initialize() {
    _coco_lastRender = _coco_root.differ.renderAll(_coco_lastSnapshot = _coco_vStructure.poll().value);
    _coco_arm();
  }

}