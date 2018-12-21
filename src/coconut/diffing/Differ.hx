package coconut.diffing;

import coconut.diffing.Rendered;
import haxe.DynamicAccess as Dict;

class Differ<Virtual, Real:{}> {
  function _renderAll(
    nodes:Array<VNode<Virtual, Real>>, 
    later:Later,
    with:{ 
      function native(type:NodeType, key:Key, v:Virtual):Real; 
      function widget<A>(type:NodeType, key:Key, attr:A, t:WidgetType<Virtual, A, Real>):Widget<Virtual, Real>; 
    }
  ):Rendered<Virtual, Real> {

    var byType = new Map<NodeType, TypeRegistry<RNode<Virtual, Real>>>(),
        childList = [];

    function process(nodes:Array<VNode<Virtual, Real>>)
      if (nodes != null) for (n in nodes) {
        function add(r:Dynamic, kind) {
          
          var registry = switch byType[n.type] {
            case null: byType[n.type] = new TypeRegistry();
            case v: v;
          }

          if (n.ref != null)
            later(function () n.ref(r));

          var n:RNode<Virtual, Real> = {
            key: n.key,
            type: n.type,
            ref: n.ref,
            kind: kind
          }

          switch n.key {
            case null: registry.put(n);
            case k: registry.set(k, n);
          }
          childList.push(n);
        }
        switch n.kind {
          case VNative(v):

            var r = with.native(n.type, n.key, v);
            
            add(r, RNative(v, r));
          case VWidget(a, t):

            var w = with.widget(n.type, n.key, a, t);

            add(w, RWidget(w));
          
          case VMany(nodes): 
          
            process(nodes);
        }
      }
    
    process(nodes);

    return {
      byType: byType,
      childList: childList,
    }    
  }  

  public function renderAll(nodes:Array<VNode<Virtual, Real>>, parent:Null<Widget<Virtual, Real>>, later:Later):Rendered<Virtual, Real> 
    return _renderAll(nodes, later, {
      native: function (type, _, v) return createNative(type, v, parent, later),
      widget: function (_, _, a, t) return createWidget(t, a, parent, later),
    });

  function createWidget<A>(t:WidgetType<Virtual, A, Real>, a:A, parent:Null<Widget<Virtual, Real>>, later:Later) {
    var ret = t.create(a);
    @:privateAccess ret._coco_initialize(this, parent, later);
    return ret;
  }

  function placeholder(forTarget:Widget<Virtual, Real>):VNode<Virtual, Real>
    return throw 'abstract';

  public function updateAll(before:Rendered<Virtual, Real>, nodes:Array<VNode<Virtual, Real>>, parent:Null<Widget<Virtual, Real>>, later:Later):Rendered<Virtual, Real> {
    
    for (node in before.childList)
      switch node.ref {
        case null:
        case f: f(null);
      }

    function previous(t:NodeType, key:Key)
      return 
        switch before.byType[t] {
          case null: null;
          case v: 
            if (key == null) v.pull();
            else v.get(key);
        }    
        
    var after =  _renderAll(nodes, later, {
      native: function (type, key, nu) return switch previous(type, key) {
        case null: createNative(type, nu, parent, later);
        case { kind: RNative(old, r) }: updateNative(r, nu, old, parent, later); r;
        default: throw 'assert';
      },
      widget: function (type, key, attr, widgetType) return switch previous(type, key) {
        case null: createWidget(widgetType, attr, parent, later);
        case { kind: RWidget(w) }: widgetType.update(attr, w); w;
        default: throw 'assert';
      },
    });  
      
    for (registry in before.byType)
      registry.each(destroyRender);

    return after; 
  }

  public inline function destroyRender(r:RNode<Virtual, Real>) 
    switch r.kind {
      case RWidget(w): @:privateAccess w._coco_teardown();
      case RNative(_, r): 
        switch unsetLastRender(r) {
          case null:
          case { childList: children }: 
            for (c in children) destroyRender(c);
        }
    }

  function _render(nodes:Array<VNode<Virtual, Real>>, target:Real, parent:Null<Widget<Virtual, Real>>, later:Later) {
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

  public function render(virtual:Array<VNode<Virtual, Real>>, target:Real) 
    run(_render.bind(virtual, target, null));

  public function run<T>(f:Later->T):T {
    var after = [];
    var ret = f(function (later) if (later != null) after.push(later));
    for (f in after)
      f();
    return ret;
  }

  function unsetLastRender(target:Real):Rendered<Virtual, Real>
    throw 'abstract';

  function setLastRender(target:Real, r:Rendered<Virtual, Real>)
    throw 'abstract';

  function getLastRender(target:Real):Null<Rendered<Virtual, Real>>
    return throw 'abstract';

  function updateNative(real:Real, nu:Virtual, old:Virtual, parent:Null<Widget<Virtual, Real>>, later:Later) 
    throw 'abstract';

  function replaceWidgetContent(prev:Map<Real, Bool>, first:Real, total:Int, next:Rendered<Virtual, Real>, later:Later)
    throw 'abstract';

  function createNative(type:NodeType, n:Virtual, parent:Null<Widget<Virtual, Real>>, later:Later):Real 
    return throw 'abstract';  

  static var EMPTY:Dict<Any> = {};  

  @:extern inline function updateObject<Target>(element:Target, newProps:Dict<Any>, oldProps:Dict<Any>, updateProp:Target->String->Any->Any->Void) {
    if (newProps == oldProps) return;
    var keys = new Dict<Bool>();
    
    if (newProps == null) newProps = EMPTY;
    if (oldProps == null) oldProps = EMPTY;

    for(key in newProps.keys()) keys[key] = true;
    for(key in oldProps.keys()) keys[key] = true;
    
    for(key in keys.keys()) 
      switch [newProps[key], oldProps[key]] {
        case [a, b] if (a == b):
        case [nu, old]: updateProp(element, key, nu, old);
      }
  }

  function removeChild(real:Real, child:Real)
    return throw 'abstract';

  function nativeParent(real:Real):Null<Real>
    return throw 'abstract';

  inline function setField(target:Dynamic, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    Reflect.setField(target, name, newVal);        
}