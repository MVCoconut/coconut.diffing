package coconut.diffing;

import tink.state.internal.ObjectMap;

typedef Key = Dynamic;

@:forward(set, exists)
abstract KeyMap<T>(ObjectMap<Dynamic, T>) {
  public inline function new()
    this = new ObjectMap();

  public inline function get(key:Key):T
    return switch this.get(key) {
      case null: null;
      case v: this.remove(key); v;
    }

  public inline function each(f:T->Void)
    this.forEach((v, _, _) -> f(v));
}