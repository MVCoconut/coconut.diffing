package coconut.diffing;

//TODO: make an opt-in for `typedef Key = Dynamic; abstract KeyMap<T>(js.Map<Key, T>) { ... }`

abstract Key(String) from String to String {

  @:from static function ofFloat(f:Float):Key
    return Std.string(f);

  @:from static function ofObject(o:{}) untyped {
    return ofFloat(cast haxe.ds.ObjectMap.getId(o) || haxe.ds.ObjectMap.assignId(o));
  }

}

@:forward(set, exists)
abstract KeyMap<T>(Map<String, T>) {
  public inline function new() 
    this = new Map();

  public inline function get(key:Key):T
    return switch this.get(key) {
      case null: null;
      case v: this.remove(key); v;
    }

  public inline function each(f:T->Void)
    for (v in this) f(v);
}