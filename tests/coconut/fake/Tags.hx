package coconut.fake;

class Tags {
  static final DIV = VDummy.forTag('div');
  static public inline function div(attr:{ ?id:String, ?onclick:String }, ?children) {
    return DIV(attr, children);
  }
  static final BUTTON = VDummy.forTag('button');
  static public inline function button(attr:{ ?id:String, ?onclick:String }, ?children) {
    return BUTTON(attr, children);
  }
}