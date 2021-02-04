package coconut.diffing;

abstract Key({}) from {} to {} {

  @:from static function ofFloat(f:Float):Key
    return Std.string(f);

  inline function isString()
    return Std.is(this, String);

}