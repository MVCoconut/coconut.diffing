package coconut.diffing;

import coconut.diffing.Key;

@:structInit
class Rendered<Virtual, Real:{}> {
  public var byType(default, null):Map<NodeType, TypeRegistry<RNode<Virtual, Real>>>;//TODO: splitting this by native vs. widgets might be a good idea
  public var childList(default, null):Array<RNode<Virtual, Real>>;

  public function flatten(later) {
    var ret = [];
    each(later, function (r) ret.push(r));
    return ret;
  }

  @:extern public inline function each(later:Later, f:Real->Void) {
    function rec(children:Array<RNode<Virtual, Real>>)
      for (c in children) switch c.kind {
        case RNative(_, r): f(r);
        case RWidget(w): 
          rec(@:privateAccess w._coco_getRender(later).childList);
      }
    rec(childList);
  }   
}

class TypeRegistry<V> {
  
  var keyed:KeyMap<V>;
  var unkeyed:Array<V>;
  
  public function new() {}

  public function get(key:Key)
    return 
      if (keyed == null) null 
      else keyed.get(key);

  public function set(key:Key, value) {
    if (keyed == null) 
      keyed = new KeyMap();

    #if debug
    if (keyed.exists(key))
      throw 'duplicate key $key';
    #end
    keyed.set(key, value);
  }

  public function put(v) {
    if (unkeyed == null) unkeyed = [];
    unkeyed.push(v);
  }
  
  var reversed:Bool = false;
  public function pull() 
    return
      if (unkeyed == null) null;
      else unkeyed.shift();//TODO: find better solution for platforms where shifting is slow

  @:extern public inline function each(f:V->Void) {
    if (keyed != null) keyed.each(f);
    if (unkeyed != null) for (v in unkeyed) f(v);
  }
}