package coconut.diffing;

class Differ<Virtual, Real> {

  function _renderAll(
    nodes:Array<VNode<Virtual, Real>>, 
    with:{ 
      function native(type:NodeType, v:Virtual):Real; 
      function widget<A>(type:NodeType, attr:A, t:WidgetType<Virtual, A, Real>):Widget<Virtual, Real>; 
    }
  ):Rendered<Virtual, Real> {

    var children = new Map<NodeType, Array<RNode<Virtual, Real>>>(),
        real = [];

    for (n in nodes) {
      var bucket = switch children[n.type] {
        case null: children[n.type] = [];
        case v: v;
      }
      function add(r:Dynamic, kind) {
        
        if (n.ref != null)
          n.ref(r);//TODO: schedule ref rather than calling directly
        bucket.push({
          key: n.key,
          type: n.type,
          ref: n.ref,
          kind: kind
        });
      }
      switch n.kind {
        case VNative(v):

          var r = with.native(n.type, v);

          real.push(r);
          
          add(r, RNative(v, r));
        case VWidget(a, t):

          var w = with.widget(n.type, a, t);
          var r = @:privateAccess w._coco_getReal();
          for (r in r)
            real.push(r);

          add(w, RWidget(w));
      }
    }
    
    return {
      children: children,
      real: real,
    }    
  }
  public function renderAll(nodes:Array<VNode<Virtual, Real>>):Rendered<Virtual, Real> 
    return _renderAll(nodes, {
      native: function (_, v) return create(v),
      widget: function (_, a, t) return t.create(a)
    });
  
  public function mountInto(target:Real, nodes:Array<VNode<Virtual, Real>>):Rendered<Virtual, Real> {
    var ret = renderAll(nodes);
    setChildren(target, ret.real);
    return ret;
  }

  public function update(rendered:Rendered<Virtual, Real>, nodes:Array<VNode<Virtual, Real>>, w:Widget<Virtual, Real>) {
    
    for (bucket in rendered.children)
      for (r in bucket) switch r {
        case { ref: null }:
        case { ref: f }: f(null);
      }

    function previous(t:NodeType)
      return 
        switch rendered.children[t] {
          case null: null;
          case v: v.pop();
        }

    var ret = _renderAll(nodes, {
      native: function (type, nu) return switch previous(type) {
        case null: create(nu);
        case { kind: RNative(old, r) }: updateNative(r, nu, old); r;
        default: throw 'assert';
      },
      widget: function (type, attr, widgetType) return switch previous(type) {
        case null: widgetType.create(attr);
        case { kind: RWidget(w) }: widgetType.update(attr, w); w;
        default: throw 'assert';
      },
    });   

    for (bucket in rendered.children)
      for (r in bucket) switch r.kind {
        case RWidget(w): @:privateAccess w._coco_teardown();
        default:
      }

    updateParent(@:privateAccess w._coco_parent, w, rendered, ret);

    return ret;
  }

  function updateParent(parent:Parent<Virtual, Real>, child:Widget<Virtual, Real>, before:Rendered<Virtual, Real>, after:Rendered<Virtual, Real>) {
    if (parent == null) return;
    else {
      var changed = before.real.length != after.real.length;

      if (!changed)
        for (i in 0...before.real.length) 
          if (before.real[i] != after.real[i]) {
            changed = true;
            break;
          }

      if (!changed) return;
    }
  }

  function updateNative(real:Real, nu:Virtual, old:Virtual) 
    throw 'abstract';

  function create(n:Virtual):Real 
    return throw 'abstract';

  function spliceChildren(target:Real, children:Array<Real>, start:Real, oldCount:Int)
    throw 'abstract';

  function setChildren(target:Real, children:Array<Real>)
    throw 'abstract';

  public function teardown(target:Real) 
    setChildren(target, []);
}