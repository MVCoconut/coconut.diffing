package coconut.diffing;

abstract TypeId(Int) to Int {
  static var idCounter = 0;
  public inline function new()
    this = idCounter++;
}