package coconut.fake;

class Tags {
  static final DIV = VDummy.forTag('div');
  static public inline function div(hxxMeta, attr:{ ?id:String, ?className:String, ?onclick:String }, ?children)
    return DIV(hxxMeta, attr, children);

  static final BUTTON = VDummy.forTag('button');
  static public inline function button(hxxMeta, attr:{ ?id:String, ?className:String, ?onclick:String }, ?children)
    return BUTTON(hxxMeta, attr, children);

  static final CHECKBOX = VDummy.forTag('checkbox');
  static public inline function checkbox(hxxMeta, attr:{ ?checked:Bool})
    return CHECKBOX(hxxMeta, if (attr.checked) { checked: "checked" } else {});

}