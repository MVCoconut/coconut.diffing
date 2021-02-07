package coconut.diffing.internal;

class Cast {
  static public inline function down<X>(v:Dynamic, c:Class<X>):X
    return
      #if debug
        if (Std.is(v, c)) v;
        else throw 'invalid cast';
      #else
        v;
      #end
}
