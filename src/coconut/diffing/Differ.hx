package coconut.diffing;

import coconut.diffing.Rendered;
import haxe.DynamicAccess as Dict;

class Differ<Virtual, Real> {

  function _renderAll(
    nodes:Array<VNode<Virtual, Real>>, 
    root:VRoot<Virtual, Real>,
    with:{ 
      function native(type:NodeType, key:Key, v:Virtual):Real; 
      function widget<A>(type:NodeType, key:Key, attr:A, t:WidgetType<Virtual, A, Real>):Widget<Virtual, Real>; 
    }
  ):Rendered<Virtual, Real> {

    var byType = new Map<NodeType, TypeRegistry<RNode<Virtual, Real>>>(),
        childList = [];

    for (n in nodes) {
      var registry = switch byType[n.type] {
        case null: byType[n.type] = new TypeRegistry();
        case v: v;
      }
      function add(r:Dynamic, kind) {
        
        if (n.ref != null)
          root.afterRendering(function () n.ref(r));

        var n:RNode<Virtual, Real> = {
          key: n.key,
          type: n.type,
          ref: n.ref,
          kind: kind
        }

        registry.put(n);
        childList.push(n);
      }
      switch n.kind {
        case VNative(v):

          var r = with.native(n.type, n.key, v);
          
          add(r, RNative(v, r));
        case VWidget(a, t):

          var w = with.widget(n.type, n.key, a, t);

          add(w, RWidget(w));
      }
    }

    if (childList.length == 0) throw 'empty return is currently not supported';
    
    return {
      byType: byType,
      childList: childList,
    }    
  }
  
  public function renderAll(nodes:Array<VNode<Virtual, Real>>, root:VRoot<Virtual, Real>):Rendered<Virtual, Real> 
    return _renderAll(nodes, root, {
      native: function (type, _, v) return create(type, v, root),
      widget: function (_, _, a, t) return createWidget(t, a, root),
    });
  
  public function mountInto(target:Real, nodes:Array<VNode<Virtual, Real>>, root:VRoot<Virtual, Real>):Rendered<Virtual, Real> {
    var ret = renderAll(nodes, root);
    setChildren(target, flatten(ret.childList));
    return ret;
  }

  function createWidget<A>(t:WidgetType<Virtual, A, Real>, a:A, root:VRoot<Virtual, Real>) {
    var ret = t.create(a);
    @:privateAccess ret._coco_initialize(root);
    return ret;
  }

  public function update(before:Rendered<Virtual, Real>, nodes:Array<VNode<Virtual, Real>>, w:Widget<Virtual, Real>, root:VRoot<Virtual, Real>) {
    
    for (registry in before.byType)
      registry.each(function (r) switch r {
        case { ref: null }:
        case { ref: f }: f(null);
      });

    function previous(t:NodeType, key:Key)
      return 
        switch before.byType[t] {
          case null: null;
          case v: 
            if (key == null) v.pull();
            else v.get(key);
        }

    var after = _renderAll(nodes, root, {
      native: function (type, key, nu) return switch previous(type, key) {
        case null: create(type, nu, root);
        case { kind: RNative(old, r) }: updateNative(r, nu, old); r;
        default: throw 'assert';
      },
      widget: function (type, key, attr, widgetType) return switch previous(type, key) {
        case null: createWidget(widgetType, attr, root);
        case { kind: RWidget(w) }: widgetType.update(attr, w); w;
        default: throw 'assert';
      },
    });   

    for (registry in before.byType)
      registry.each(function (r) switch r.kind {
        case RWidget(w): @:privateAccess w._coco_teardown();
        default:
      });

    var before = flatten(before.childList);
    switch nativeParent(before[0]) {
      case null:
      case parent:
        spliceChildren(parent, flatten(after.childList), before[0], before.length);
    }

    return after;
  }

  function nativeParent(real:Real):Null<Real> 
    return throw 'abstract';

  function updateNative(real:Real, nu:Virtual, old:Virtual) 
    throw 'abstract';

  function create(type:NodeType, n:Virtual, root:VRoot<Virtual, Real>):Real 
    return throw 'abstract';

  function flatten(children):Array<Real> {
    var ret = [];
    function rec(children:Array<RNode<Virtual, Real>>)
      for (c in children) switch c.kind {
        case RNative(_, r): ret.push(r);
        case RWidget(w): rec(@:privateAccess w._coco_getRender().childList);
      }
    rec(children);
    return ret;
  }

  function spliceChildren(target:Real, children:Array<Real>, start:Real, oldCount:Int)
    throw 'abstract';

  function setChildren(target:Real, children:Array<Real>)//TODO: passing the array of children directly may open opportunities for optimization
    throw 'abstract';

  public function teardown(target:Real) 
    setChildren(target, []);

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

  inline function setField(target:Dynamic, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    Reflect.setField(target, name, newVal);    
}