package coconut.fake;

@:allow(RDummy)
class VDummy extends VNative<Attr, Dummy, Dummy> {
  static final byTag = new Map<String, (attr:Attr, ?children:Children)->VDummy>();

  function new(factory:DummyFactory, data, ?children:Children) {
    super(factory, data, null, cast children);
  }

  public function toString()
    return '<${(cast factory:DummyFactory).tag}#${type}>';

  static public function forTag(tag:String)
    return switch byTag[tag] {
      case null:
        var factory = new DummyFactory(new TypeId(), tag);
        byTag[tag] = (attr, ?children) -> new VDummy(factory, attr, children);
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

