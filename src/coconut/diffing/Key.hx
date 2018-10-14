package coconut.diffing;

abstract Key({}) from {} to {} {

  @:from static function ofFloat(f:Float):Key
    return Std.string(f);

  inline function isString()
    return Std.is(this, String);

}

class KeyMap<T> {
  var strings:Map<String, T>;
  var objs:Map<{}, T>;

  public function new() {}

  public function get(key:Key):T
    return 
      if (@:privateAccess key.isString()) 
        if (strings == null) null;
        else {
          var key:String = cast key;
          var ret = strings.get(key);
          if (ret != null) strings.remove(key);
          ret;
        }
      else 
        if (objs == null) null;
        else {
          var ret = objs.get(key);
          if (ret != null) objs.remove(key);
          ret;
        }

  public function set(key:Key, value:T) 
    if (@:privateAccess key.isString()) {
      var key:String = cast key;
      if (strings == null) strings = [key => value];
      else strings.set(key, value);
    }
    else 
      if (objs == null) objs = [key => value];
      else objs.set(key, value);
  
  public function exists(key:Key):Bool 
    return 
      if (@:privateAccess key.isString()) 
        if (strings == null) false;
        else strings.exists(cast key);
      else 
        if (objs == null) false;
        else objs.exists(key);
   
  public inline function each(f:T->Void) {
    if (strings != null) for (v in strings) f(v);
    if (objs != null) for (v in objs) f(v);
  }
  
}