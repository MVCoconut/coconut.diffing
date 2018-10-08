package coconut.diffing;

typedef Key = String;

@:forward
abstract KeyMap<T>(Map<String, T>) {
  
  public inline function new()
    this = new Map();

  @:extern public inline function each(f:T->Void)
    for (v in this) f(v);
}