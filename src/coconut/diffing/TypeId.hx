package coconut.diffing;

abstract TypeId(Int) to Int {
  static var idCounter:Int;
  static function __init__()
    idCounter++;
  public inline function new()
    this = idCounter++;
}