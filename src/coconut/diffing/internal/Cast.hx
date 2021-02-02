package coconut.diffing.internal;

class Cast {
  static public function exactly<X>(v:Dynamic, c:Class<X>):X
    return
      #if debug
        if (Type.getClass(v) == c) v;
        else throw (['invalid cast', v, c]:Array<Dynamic>);
      #else
        v;
      #end
}
