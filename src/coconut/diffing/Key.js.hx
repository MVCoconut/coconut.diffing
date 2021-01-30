package coconut.diffing;

import tink.state.internal.ObjectMap;

typedef Key = Dynamic;

@:forward(count)
abstract KeyMap<T>(ObjectMap<Dynamic, T>) {
  public inline function new()
    this = new ObjectMap();

  public inline function get(key:Key):T
    return switch this.get(key) {
      case null: null;
      case v: this.remove(key); v;
    }

  public inline function exists(key:Key)
    return this.exists(key);

  public inline function set(key:Key, value:T)
    this.set(key, value);

  public inline function each(f:T->Void)
    this.forEach((v, _, _) -> f(v));

  public inline function eachEntry(f:Key->T->Void)
    this.forEach((v, k, _) -> f(k, v));

}