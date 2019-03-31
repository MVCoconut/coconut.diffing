package coconut.diffing;

import coconut.diffing.Rendered;
import coconut.diffing.NodeType;
import haxe.DynamicAccess as Dict;

class Differ<Real:{}> {
  var applicator:Applicator<Real>;

  public function new(applicator) 
    this.applicator = applicator;
  
  function _renderAll(
    nodes:Array<VNode<Real>>, 
    later:Later,
    parent:Null<Widget<Real>>,
    with:{ 
      function native<A>(type:NodeType<A, Real>, key:Key, attr:A, ?children:Array<VNode<Real>>):Real; 
      function widget<A>(type:WidgetType<A, Real>, key:Key, attr:A):Widget<Real>; 
      function widgetInst(w:Widget<Real>):Void;
    }
  ):Rendered<Real> {

    var byType = new Map<{}, TypeRegistry<RNode<Real>>>(),
        childList = [];

    function process(nodes:Array<VNode<Real>>)
      if (nodes != null) for (n in nodes) if (n != null) {
        inline function add(r:Dynamic, ref:Null<Dynamic>->Void, key:Null<Key>, type:{}, n) {
          
          var registry = switch byType[type] {
            case null: byType[type] = new TypeRegistry();
            case v: v;
          }

          if (ref != null)
            later(function () ref(r));

          switch key {
            case null: registry.put(n);
            case k: registry.set(k, n);
          }
          childList.push(n);
        }
        
        switch n {
          case VNative(type, ref, key, attr, children):

            var real = with.native(type, key, attr, children);
            
            add(real, ref, key, type, RNative(attr, real, ref));

          case VWidget(type, ref, key, a):

            var w = with.widget(type, key, a);

            add(w, ref, key, type, RWidget(w, ref));
          
          case VMany(nodes): 
          
            process(nodes);

          case VNativeInst(n):

            childList.push(RNative(null, n, null));

          case VWidgetInst(w):

            with.widgetInst(w);
            add(w, null, w, WIDGET_INST, RWidget(w, null));
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
      native: function (type, _, attr, ?children) return createNative(type, attr, children, parent, later),
      widget: function (t, _, a) return createWidget(t, a, parent, later),
      widgetInst: function (w) mountInstance(w, parent, later),
    });

  function mountInstance(w:Widget<Real>, parent:Null<Widget<Real>>, later:Later)
    @:privateAccess {    
      if (w._coco_alive) Error.withData('Same widget instance mounted twice', w);
      w._coco_initialize(this, parent, later);
    }

  function createWidget<A>(t:WidgetType<A, Real>, a:A, parent:Null<Widget<Real>>, later:Later) {
    var ret = t.create(a);
    @:privateAccess ret._coco_initialize(this, parent, later);
    return ret;
  }

  public function updateAll(before:Rendered<Real>, nodes:Array<VNode<Real>>, parent:Null<Widget<Real>>, later:Later):Rendered<Real> {
    
    for (node in before.childList)
      switch node {
        case RNative(_, _, f) | RWidget(_, f) if (f != null): f(null);
        default:
      }

    function previous(t:{}, key:Key)
      return 
        switch before.byType[t] {
          case null: null;
          case v: 
            if (key == null) v.pull();
            else v.get(key);
        }    
        
    var after = _renderAll(nodes, later, parent, {
      native: function native(type, key, nuAttr, ?nuChildren) return switch previous(type, key) {
        case null: 
          createNative(type, nuAttr, nuChildren, parent, later);
        case RNative(oldAttr, r, _): 
          type.update(r, cast oldAttr, nuAttr);
          _render(nuChildren, r, parent, later);
          r;
        default: throw 'assert';
      },
      widget: function (type, key, attr) return switch previous(type, key) {
        case null: 
          createWidget(type, attr, parent, later);
        case RWidget(w, _): 
          type.update(attr, w); 
          w;
        default: throw 'assert';
      },
      widgetInst: function (w) return switch previous(WIDGET_INST, w) {
        case null: mountInstance(w, parent, later);
        case RWidget(w, _): // nothing to do presumably
        default: throw 'assert';
      }
    });
      
    for (registry in before.byType)
      registry.each(destroyRender);

    return after; 
  }

  public inline function destroyRender(r:RNode<Real>) 
    switch r {
      case RWidget(w, _): @:privateAccess w._coco_teardown();
      case RNative(_, real, _): 
        switch applicator.unsetLastRender(real) {
          case null:
          case { childList: children }: 
            for (c in children) destroyRender(c);
        }
    }

  function _render(nodes:Array<VNode<Real>>, target:Real, parent:Null<Widget<Real>>, later:Later) {
    var ret = 
      switch applicator.getLastRender(target) {
        case null: renderAll(nodes, parent, later);
        case v: updateAll(v, nodes, parent, later);
      }  
    applicator.setLastRender(target, ret);
    applicator.setChildren(target, ret.flatten(later));
    return ret;
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

  function createNative<Attr>(type:NodeType<Attr, Real>, attr:Attr, children:Null<Array<VNode<Real>>>, parent:Null<Widget<Real>>, later:Later):Real {
    var ret = type.create(attr);
    _render(children, ret, parent, later);
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