package coconut.fake;

import haxe.ds.ReadOnlyArray;

@:allow(RDummy)
class VDummy extends VNative<Attr, Dummy, Dummy> {
  static final byTag = new Map<String, (attr:Attr, ?children:ReadOnlyArray<VNode<Dummy>>)->VDummy>();

  function new(factory:DummyFactory, data, ?children)
    super(factory, data, null, children);

  static public function forTag(tag:String)
    return switch byTag[tag] {
      case null:
        byTag[tag] = (attr, ?children) -> new VDummy(new DummyFactory(new TypeId(), tag), attr, children);
      case v: v;
    }
}

class DummyFactory implements Factory<Attr, Dummy> {

  public final type:TypeId;
  public final tag:String;

  public function new(type, tag) {
    this.type = type;
    this.tag = tag;
  }

  public function create(data:Attr):Dummy {
    var ret = new Dummy(tag);
    update(ret, data, null);
    return ret;
  }

  public function update(target:Dummy, next:Attr, prev:Attr) {

    for (k => v in next)
      target.attr[k] = v;

    if (prev != null)
      for (k in prev.keys())
        if (!next.exists(k))
          target.attr.remove(k);
  }
}

