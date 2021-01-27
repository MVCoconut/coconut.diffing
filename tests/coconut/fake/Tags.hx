package coconut.fake;

class Tags {
  static final DIV = VDummy.forTag('div');
  static public inline function div(attr:{ ?id:String, ?className:String, ?onclick:String }, ?children)
    return DIV(attr, children);

  static final BUTTON = VDummy.forTag('button');
  static public inline function button(attr:{ ?id:String, ?className:String, ?onclick:String }, ?children)
    return BUTTON(attr, children);

  static final CHECKBOX = VDummy.forTag('checkbox');
  static public inline function checkbox(attr:{ ?checked:Bool})
    return CHECKBOX(if (attr.checked) { checked: "checked" } else {});

}