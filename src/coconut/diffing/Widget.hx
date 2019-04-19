package coconut.diffing;

import tink.state.Observable;

class Widget<Real:{}> {

  @:noCompletion var _coco_viewMounted:Void->Void;
  @:noCompletion var _coco_viewUpdated:Void->Void;
  @:noCompletion var _coco_viewUnmounting:Void->Void;

  @:noCompletion var _coco_vStructure:Observable<VNode<Real>>;
  @:noCompletion var _coco_lastSnapshot:VNode<Real>;
  @:noCompletion var _coco_lastRender:Rendered<Real>;
  @:noCompletion var _coco_invalid:Bool = false;
  @:noCompletion var _coco_alive:Bool = false;
  @:noCompletion var _coco_parent:Widget<Real>;
  @:noCompletion var _coco_differ:Differ<Real>;
  @:noCompletion var _coco_link:CallbackLink;
    
  public function new(
    rendered:Observable<VNode<Real>>,
    mounted:Void->Void,
    updated:Void->Void,
    unmounting:Void->Void
  ) {

    this._coco_vStructure = rendered.map(function (r) return switch r {
      case null: @:privateAccess _coco_differ.applicator.placeholder(this);
      case VMany(nodes):
        function isEmpty(nodes:Array<VNode<Real>>) {
          for (n in nodes) if (n != null) switch n {
            case VMany(nodes): 
              if (!isEmpty(nodes)) return false;
            default: return false;
          }
          return true;
        }
        if (isEmpty(nodes)) @:privateAccess _coco_differ.applicator.placeholder(this);
        else r;
      default: r;
    });
    
    this._coco_viewMounted = mounted;
    this._coco_viewUpdated = updated;
    this._coco_viewUnmounting = unmounting;    
  }

  @:noCompletion function _coco_getRender(later:Later):Rendered<Real> {
    if (_coco_invalid) {
      _coco_invalid = false;
      var nuSnapshot = _coco_poll().value;
      if (nuSnapshot != _coco_lastSnapshot) {
        _coco_lastSnapshot = nuSnapshot;
        _coco_lastRender = _coco_differ.updateAll(_coco_lastRender, [nuSnapshot], this, later);
        later(_coco_viewUpdated);
        _coco_arm();
      }
    }
    return _coco_lastRender;
  }

  @:noCompletion function _coco_poll()
    return Observable.untracked(_coco_vStructure.measure);

  @:noCompletion var _coco_pendingChildren:Array<Widget<Real>> = [];
  @:noCompletion function _coco_scheduleChild(child:Widget<Real>) {
    _coco_pendingChildren.push(child);
    _coco_invalidate();
  }

  @:noCompletion function _coco_invalidate()
    if (!_coco_invalid) {
      _coco_invalid = true;
      if (_coco_parent != null)
        _coco_parent._coco_scheduleChild(this);
      else 
        defer(_coco_update.bind(null));
    }

  @:noCompletion function _coco_updateChildren(later:Null<Later>)
    if (_coco_pendingChildren.length > 0)
      for (c in _coco_pendingChildren.splice(0, _coco_pendingChildren.length))
        c._coco_update(later);

  @:noCompletion function _coco_performUpdate(later:Later) {

    var previous = _coco_lastRender;
    var next = _coco_getRender(later);

    _coco_updateChildren(later);

    if (previous == next) return;

    var previousCount = 0,
        first = null;
    
    previous.each(later, function (r) {
      if (first == null) first = r;
      previousCount++;
    });

    @:privateAccess _coco_differ.setChildren(later, previousCount, _coco_differ.applicator.traverseSiblings(first), next);
  }


  @:noCompletion function _coco_update(later:Null<Later>)
    if (_coco_invalid && _coco_alive) {
      if (later == null) _coco_differ.run(_coco_performUpdate);
      else _coco_performUpdate(later);
    }

  static var defer:Later = @:privateAccess Observable.schedule;
    // try {
    //   var p = js.Promise.resolve(true);
    //   function (cb:Void->Void) p.then(cast cb);
    // }
    // catch (e:Dynamic) Callback.defer;

  @:noCompletion function _coco_arm() {
    _coco_link.dissolve();//you never know
    _coco_link = _coco_poll().becameInvalid.handle(_coco_invalidate);
  }

  @:noCompletion function _coco_teardown() {
    _coco_alive = false;
    _coco_viewUnmounting();
    for (c in _coco_lastRender.childList)
      _coco_differ.destroyRender(c);
  }

  @:noCompletion function _coco_initialize(differ:Differ<Real>, parent:Widget<Real>, later:Later) {
    _coco_alive = true;
    _coco_parent = parent;
    _coco_differ = differ;
    _coco_lastRender = differ.renderAll(
      [_coco_lastSnapshot = _coco_poll().value],
      this,
      later
    );
    _coco_arm();
    later(_coco_viewMounted);
  }

}