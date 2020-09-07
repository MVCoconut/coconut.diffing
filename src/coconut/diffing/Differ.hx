package coconut.diffing;

import coconut.diffing.Rendered;
import coconut.diffing.NodeType;
import haxe.DynamicAccess as Dict;

private typedef Ref = Null<Dynamic->Void>;

class Differ<Real:{}> {
  var applicator:Applicator<Real>;

  public function new(applicator)
    this.applicator = applicator;

  function _renderAll(
    nodes:Array<VNode<Real>>,
    later:Later,
    parent:Null<Widget<Real>>,
    with:{
      function native<A>(type:NodeType<A, Real>, ref:Ref, key:Key, attr:A, ?children:Array<VNode<Real>>):Real;
      function widget<A>(type:WidgetType<A, Real>, ref:Ref, key:Key, attr:A):Widget<Real>;
      function widgetInst(w:Widget<Real>):Void;
    }
  ):Rendered<Real> {

    var byType = new tink.state.internal.ObjectMap<{}, TypeRegistry<RNode<Real>>>(),
        childList = [];

    function process(nodes:Array<VNode<Real>>)
      if (nodes != null) for (n in nodes) if (n != null) {
        inline function add(r:Dynamic, key:Null<Key>, type:{}, n) {

          var registry = switch byType[type] {
            case null: byType[type] = new TypeRegistry();
            case v: v;
          }

          switch key {
            case null: registry.put(n);
            case k: registry.set(k, n);
          }
          childList.push(n);
        }

        switch n {
          case VNative(type, ref, key, attr, children):

            var real = with.native(type, ref, key, attr, children);

            add(real, key, type, RNative(attr, real, ref));

          case VWidget(type, ref, key, a):

            var w = with.widget(type, ref, key, a);

            add(w, key, type, RWidget(w, ref));

          case VMany(nodes):

            process(nodes);

          case VNativeInst(n):

            childList.push(RNative(null, n, null));

          case VWidgetInst(w):

            with.widgetInst(w);
            add(w, w, WIDGET_INST, RWidget(w, null));
        }
      }

    process(nodes);

    return {
      byType: byType,
      childList: childList,
    }
  }

  static var WIDGET_INST = {};

  public function renderAll(nodes:Array<VNode<Real>>, parent:Null<Widget<Real>>, later:Later):Rendered<Real>
    return _renderAll(nodes, later, parent, {
      native: function (type, ref, _, attr, ?children) return createNative(type, ref, attr, children, parent, later),
      widget: function (t, ref, _, a) return createWidget(t, ref, a, parent, later),
      widgetInst: function (w) mountInstance(w, parent, later),
    });

  function mountInstance(w:Widget<Real>, parent:Null<Widget<Real>>, later:Later)
    @:privateAccess {
      if (w._coco_alive) Error.withData('Same widget instance mounted twice', w);
      w._coco_initialize(this, parent, later);
    }

  function createWidget<A>(t:WidgetType<A, Real>, ref:Ref, a:A, parent:Null<Widget<Real>>, later:Later) {
    var ret = t.create(a);
    @:privateAccess ret._coco_initialize(this, parent, later);
    if (ref != null)
      later(ref.bind(ret));
    return ret;
  }

  inline function callRef(ref:Ref, old:Ref, v:Dynamic, later:Later)
    if (ref != old) {
      if (old != null) old(null);
      if (ref != null) later(ref.bind(v));
    }

  public function updateAll(before:Rendered<Real>, nodes:Array<VNode<Real>>, parent:Null<Widget<Real>>, later:Later):Rendered<Real> {


    function previous(t:{}, key:Key)
      return
        switch before.byType[t] {
          case null: null;
          case v:
            if (key == null) v.pull();
            else v.get(key);
        }

    var after = _renderAll(nodes, later, parent, {
      native: function native(type, ref, key, nuAttr, ?nuChildren) return switch previous(type, key) {
        case null:
          createNative(type, ref, nuAttr, nuChildren, parent, later);
        case RNative(oldAttr, r, oldRef):
          type.update(r, cast oldAttr, nuAttr);
          _render(nuChildren, r, parent, later);
          callRef(ref, oldRef, r, later);
          r;
        default: throw 'assert';
      },
      widget: function (type, ref, key, attr) return switch previous(type, key) {
        case null:
          createWidget(type, ref, attr, parent, later);
        case RWidget(w, oldRef):
          type.update(attr, w);
          callRef(ref, oldRef, w, later);
          w;
        default: throw 'assert';
      },
      widgetInst: function (w) return switch previous(WIDGET_INST, w) {
        case null: mountInstance(w, parent, later);
        case RWidget(w, _): // nothing to do presumably
        default: throw 'assert';
      }
    });

    before.byType.forEach((registry, _, _) -> registry.each(r -> destroyRender(r)));

    return after;
  }

  public inline function destroyRender(r:RNode<Real>) {
    var ref =
      switch r {
        case RWidget(w, ref):
          @:privateAccess w._coco_teardown();
          ref;
        case RNative(_, real, ref):
          switch applicator.unsetLastRender(real) {
            case null:
            case { childList: children }:
              for (c in children) destroyRender(c);
          }
          ref;
      }

    if (ref != null) ref(null);
  }

  function _render(nodes:Array<VNode<Real>>, target:Real, parent:Null<Widget<Real>>, later:Later) {

    var lastCount = 0;
    var ret =
      switch applicator.getLastRender(target) {
        case null:
          renderAll(nodes, parent, later);
        case v:
          lastCount = v.justCount();
          updateAll(v, nodes, parent, later);
      }

    applicator.setLastRender(target, ret);
    setChildren(
      later,
      lastCount,
      applicator.traverseChildren(target),
      ret
    );

    return ret;
  }

  function setChildren(later, previousCount:Int, cursor:Cursor<Real>, next:Rendered<Real>) {
    var insertedCount = 0,
        currentCount = 0,
        deletedCount = 0;

    next.each(later, function (r) {
      while (true)
        switch cursor.current() {
          case null: break;//for some reason this is not covered by default
          case applicator.getLastRender(_) => null:
            deletedCount++;
            cursor.delete();
          default: break;
        }
      currentCount++;
      if (r == cursor.current()) cursor.step();
      else if (cursor.insert(r)) insertedCount++;
    });

    var deleteCount = previousCount + insertedCount - currentCount - deletedCount;

    for (i in 0...deleteCount)
      if (!cursor.delete()) break;
  }

  public function render(virtual:Array<VNode<Real>>, target:Real)
    run(function (later) return _render(virtual, target, null, later));

  public function run<T>(f:Later->T):T {
    var after = [];
    var ret = f(function (later) if (later != null) after.push(later));
    for (f in after)
      f();
    return ret;
  }

  function createNative<Attr>(type:NodeType<Attr, Real>, ref:Ref, attr:Attr, children:Null<Array<VNode<Real>>>, parent:Null<Widget<Real>>, later:Later):Real {
    var ret = type.create(attr);
    if (children != null)
      _render(children, ret, parent, later);
    if (ref != null)
      later(ref.bind(ret));
    return ret;
  }

  static var EMPTY:Dict<Any> = {};

  @:extern inline static public function updateObject<Target>(target:Target, newProps:Dict<Any>, oldProps:Dict<Any>, updateProp:Target->String->Any->Any->Void):Target {
    if (newProps == oldProps) return target;

    var keys =
      if (newProps == null) {
        newProps = EMPTY;
        oldProps;
      }
      else if (oldProps == null) {
        oldProps = EMPTY;
        newProps;
      }
      else {
        var ret = #if haxe4 newProps.copy() #else Reflect.copy(newProps) #end;
        for (key in oldProps.keys()) ret[key] = true;
        ret;
      }


    for(key in keys.keys())
      switch [newProps[key], oldProps[key]] {
        case [a, b] if (a == b):
        case [nu, old]: updateProp(target, key, nu, old);
      }

    return target;
  }
}