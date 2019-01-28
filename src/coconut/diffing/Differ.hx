package coconut.diffing;

import coconut.diffing.Rendered;
import haxe.DynamicAccess as Dict;

class Differ<Real:{}> {
  function _renderAll(
    nodes:Array<VNode<Real>>, 
    later:Later,
    parent:Null<Widget<Real>>,
    with:{ 
      function native<A>(type:NodeType, key:Key, attr:A, ?children:Array<VNode<Real>>):Real; 
      function widget<A>(type:NodeType, key:Key, attr:A, t:WidgetType<A, Real>):Widget<Real>; 
      function widgetInst(w:Widget<Real>):Void;
    }
  ):Rendered<Real> {

    var byType = new Map<NodeType, TypeRegistry<RNode<Real>>>(),
        childList = [];

    function process(nodes:Array<VNode<Real>>)
      if (nodes != null) for (n in nodes) if (n != null) {
        inline function add(r:Dynamic, ref:Null<Dynamic>->Void, key:Null<Key>, type:Null<NodeType>, n) {
          
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

          case VWidget(type, ref, key, a, t):

            var w = with.widget(type, key, a, t);

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

  static var WIDGET_INST = ':widget-inst';

  public function renderAll(nodes:Array<VNode<Real>>, parent:Null<Widget<Real>>, later:Later):Rendered<Real> 
    return _renderAll(nodes, later, parent, {
      native: function (type, _, attr, ?children) return createNative(type, attr, children, parent, later),
      widget: function (_, _, a, t) return createWidget(t, a, parent, later),
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

  function placeholder(forTarget:Widget<Real>):VNode<Real>
    return throw 'abstract';

  public function updateAll(before:Rendered<Real>, nodes:Array<VNode<Real>>, parent:Null<Widget<Real>>, later:Later):Rendered<Real> {
    
    for (node in before.childList)
      switch node {
        case RNative(_, _, f) | RWidget(_, f) if (f != null): f(null);
        default:
      }

    function previous(t:NodeType, key:Key)
      return 
        switch before.byType[t] {
          case null: null;
          case v: 
            if (key == null) v.pull();
            else v.get(key);
        }    
        
    var after =  _renderAll(nodes, later, parent, {
      native: function native(type, key, nuAttr, ?nuChildren) return switch previous(type, key) {
        case null: 
          createNative(type, nuAttr, nuChildren, parent, later);
        case RNative(oldAttr, r, _): 
          updateNative(r, nuAttr, nuChildren, cast oldAttr, parent, later); //TODO: the cast here shouldn't be necessary
        default: throw 'assert';
      },
      widget: function (type, key, attr, widgetType) return switch previous(type, key) {
        case null: 
          createWidget(widgetType, attr, parent, later);
        case RWidget(w, _): 
          widgetType.update(attr, w); 
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
        switch unsetLastRender(real) {
          case null:
          case { childList: children }: 
            for (c in children) destroyRender(c);
        }
    }

  function _render(nodes:Array<VNode<Real>>, target:Real, parent:Null<Widget<Real>>, later:Later) {
    var ret = 
      switch getLastRender(target) {
        case null: renderAll(nodes, parent, later);
        case v: updateAll(v, nodes, parent, later);
      }  
    setLastRender(target, ret);
    setChildren(target, ret.flatten(later));
    return ret;
  }

  function setChildren(target:Real, children:Array<Real>)//TODO: passing the array of children directly may open opportunities for optimization
    throw 'abstract';     

  public function render(virtual:Array<VNode<Real>>, target:Real) 
    run(function (later) return _render(virtual, target, null, later));

  public function run<T>(f:Later->T):T {
    var after = [];
    var ret = f(function (later) if (later != null) after.push(later));
    for (f in after)
      f();
    return ret;
  }

  function unsetLastRender(target:Real):Rendered<Real>
    throw 'abstract';

  function setLastRender(target:Real, r:Rendered<Real>)
    throw 'abstract';

  function getLastRender(target:Real):Null<Rendered<Real>>
    return throw 'abstract';

  function updateNative<Attr>(real:Real, nuAttr:Attr, children:Null<Array<VNode<Real>>>, oldAttr:Attr, parent:Null<Widget<Real>>, later:Later) {
    updateAttr(real, nuAttr, oldAttr);
    _render(children, real, parent, later);
    return real;
  }

  function updateAttr<Attr>(real:Real, nuAttr:Attr, oldAttr:Attr) 
    throw 'abstract';

  function replaceWidgetContent(prev:Map<Real, Bool>, first:Real, total:Int, next:Rendered<Real>, later:Later)
    throw 'abstract';

  function createNative<Attr>(type:NodeType, attr:Attr, children:Null<Array<VNode<Real>>>, parent:Null<Widget<Real>>, later:Later):Real {
    var ret = initAttr(type, attr);
    _render(children, ret, parent, later);
    return ret;
  }

  function initAttr<Attr>(type:NodeType, attr:Attr):Real
    return throw 'abstract';

  static var EMPTY:Dict<Any> = {};  

  @:extern inline function updateObject<Target>(target:Target, newProps:Dict<Any>, oldProps:Dict<Any>, updateProp:Target->String->Any->Any->Void):Target {
    if (newProps == oldProps) return target;
    var keys = new Dict<Bool>();
    
    if (newProps == null) newProps = EMPTY;
    if (oldProps == null) oldProps = EMPTY;

    for(key in newProps.keys()) keys[key] = true;
    for(key in oldProps.keys()) keys[key] = true;
    
    for(key in keys.keys()) 
      switch [newProps[key], oldProps[key]] {
        case [a, b] if (a == b):
        case [nu, old]: updateProp(target, key, nu, old);
      }

    return target;
  }

  function removeChild(real:Real, child:Real)
    return throw 'abstract';

  function nativeParent(real:Real):Null<Real>
    return throw 'abstract';

  inline function setField(target:Dynamic, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    Reflect.setField(target, name, newVal);        
}