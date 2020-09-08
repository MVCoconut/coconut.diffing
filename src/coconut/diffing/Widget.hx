package coconut.diffing;

import coconut.ui.internal.ImplicitContext;
import tink.state.Observable;
import tink.state.internal.*;

private class Invalidation<T:{}> implements Invalidatable {
  final widget:Widget<T>;
  final link:CallbackLink;

  function new<X>(widget, vstructure:ObservableObject<X>) {
    this.widget = widget;
    link = vstructure.onInvalidate(this);
  }

  #if tink_state.debug
  @:keep public function toString()
    return @:privateAccess widget._coco_toString();
  #end

  public function invalidate()
    @:privateAccess widget._coco_invalidate();

  static public function setup<T:{}>(widget, vstructure)
    return new Invalidation(widget, vstructure).link;
}

class Widget<Real:{}> {

  @:noCompletion var _coco_viewMounted:Void->Void;
  @:noCompletion var _coco_viewUpdated:Void->Void;
  @:noCompletion var _coco_viewUnmounting:Void->Void;

  @:noCompletion var _coco_vStructure:ObservableObject<VNode<Real>>;
  @:noCompletion var _coco_lastSnapshot:VNode<Real>;
  @:noCompletion var _coco_lastRender:Rendered<Real>;
  @:noCompletion var _coco_invalid:Bool = false;
  @:noCompletion var _coco_alive:Bool = false;
  @:noCompletion var _coco_parent:Widget<Real>;
  @:noCompletion var _coco_differ:Differ<Real>;
  @:noCompletion var _coco_link:CallbackLink;
  @:noCompletion var _coco_implicits:coconut.ui.internal.ImplicitContext;
  #if tink_state.debug
  @:noCompletion final _coco_toString:()->String;
  #end

  public function new(
    rendered:Observable<VNode<Real>>,
    mounted:Void->Void,
    updated:Void->Void,
    unmounting:Void->Void
    #if tink_state.debug , toString #end
  ) {
    #if tink_state.debug this._coco_toString = toString; #end
    _coco_vStructure = rendered;

    this._coco_viewMounted = mounted;
    this._coco_viewUpdated = updated;
    this._coco_viewUnmounting = unmounting;
  }

  @:noCompletion function _coco_getRender(later:Later):Rendered<Real> {
    if (_coco_invalid) {
      _coco_invalid = false;
      var nuSnapshot = _coco_poll();
      if (nuSnapshot != _coco_lastSnapshot) {
        _coco_lastSnapshot = nuSnapshot;
        _coco_lastRender = _coco_differ.updateAll(_coco_lastRender, [nuSnapshot], this, later);
        later(_coco_viewUpdated);
      }
    }
    return _coco_lastRender;
  }

  @:noCompletion inline function _coco_poll()
    return switch Observable.untracked(_coco_vStructure.getValue) {
      case null: @:privateAccess _coco_differ.applicator.placeholder(this);
      case r = VMany(nodes):
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
      case r: r;
    }

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
        defer(() -> _coco_update(null));
    }

  @:noCompletion function _coco_updateChildren(later:Null<Later>)
    if (_coco_pendingChildren.length > 0)
      for (c in _coco_pendingChildren.splice(0, _coco_pendingChildren.length))
        inline c._coco_update(later);

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
      if (later == null) _coco_differ.run(later -> _coco_performUpdate(later));
      else _coco_performUpdate(later);
    }

  static var defer:Later = @:privateAccess Observable.schedule;

  static public var liveCount = 0;
  @:noCompletion function _coco_teardown() {
    if (!_coco_alive) throw 'wtf???';
    liveCount--;
    _coco_alive = false;
    _coco_link.cancel();
    _coco_viewUnmounting();
    for (c in _coco_lastRender.childList)
      _coco_differ.destroyRender(c);
  }

  @:noCompletion function _coco_initialize(differ:Differ<Real>, parent:Widget<Real>, later:Later) {
    _coco_alive = true;
    liveCount++;
    _coco_parent = parent;
    _coco_differ = differ;

    if (_coco_implicits == null)
      _coco_implicits =
        if (parent == null) new ImplicitContext();
        else parent._coco_implicits;

    _coco_link = Invalidation.setup(this, _coco_vStructure);

    _coco_lastRender = differ.renderAll(
      [_coco_lastSnapshot = _coco_poll()],
      this,
      later
    );
    later(_coco_viewMounted);
  }

}