package coconut.diffing;

import coconut.diffing.Key;

@:structInit
class Rendered<Real:{}> {
  public var byType(default, null):Map<{}, TypeRegistry<RNode<Real>>>;//TODO: splitting this by native vs. widgets might be a good idea
  public var childList(default, null):Array<RNode<Real>>;

  public function flatten(later):Array<Real> {//TODO: report bug - not specifying return type here leads to compiler error
    var ret = [];
    each(later, function (r) ret.push(r));
    return ret;
  }

  public function first(later):Real {
    try each(later, function (r) throw { F: r })
    catch (d:Dynamic) 
      if (d.F != null) return d.F;
      else Error.rethrow(d);
    return null;
  }

  public function each(later:Later, f:Real->Void) {
    function rec(children:Array<RNode<Real>>)
      for (c in children) switch c {
        case RNative(_, r, _): f(r);
        case RWidget(w, _): 
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
  
  public function pull() 
    return
      if (unkeyed == null) null;
      else unkeyed.shift();//TODO: find better solution for platforms where shifting is slow

  @:extern public inline function each(f:V->Void) {
    if (keyed != null) keyed.each(f);
    if (unkeyed != null) for (v in unkeyed) f(v);
  }
}