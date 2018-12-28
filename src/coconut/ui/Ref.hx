package coconut.ui;

import haxe.macro.*;

class Ref<T> {
  
  public var current(default, null):T;
  
  var setter:RefSetter<T>;
  
  public function new() 
    setter = function (value) current = value;

}

@:callable
abstract RefSetter<T>(T->Void) from T->Void {

  @:from static inline function ofSetter<T>(r:Ref<T>):RefSetter<T>
    return @:privateAccess r.setter;
    
}