package coconut.fake;

class Tags {

  static final DIV = new DummyFactory('div');

  static public inline function div(hxxMeta:HxxMeta, attr:{ ?id:String, ?className:String, ?onclick:String }, ?children:Children)
    return DIV.vnode(attr, hxxMeta.key, hxxMeta.ref, children);

  static final BUTTON = new DummyFactory('button');
  static public inline function button(hxxMeta, attr:{ ?id:String, ?className:String, ?onclick:String }, ?children)
    return BUTTON.vnode(attr, hxxMeta.key, hxxMeta.ref, children);

  static final CHECKBOX = new DummyFactory('checkbox');
  static public inline function checkbox(hxxMeta, attr:{ ?checked:Bool})
    return CHECKBOX.vnode(if (attr.checked) { checked: "checked" } else {}, hxxMeta.key, hxxMeta.ref);

}

private typedef HxxMeta = {
  @:optional var key(default, never):Key;
  @:optional var ref(default, never):coconut.ui.Ref<Dummy>;
}