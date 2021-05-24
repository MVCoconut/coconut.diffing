package coconut.fake;

class DummyFactory extends Factory<Attr, Dummy, Dummy> {

  public final tag:String;

  public function new(tag) {
    this.tag = tag;
  }

  public function create(data:Attr):Dummy {
    var ret = new Dummy(tag);
    update(ret, data, null);
    return ret;
  }

  override public function adopt(dummy)
    return dummy;

  override public function hydrate(dummy:Dummy, _) {
    @:privateAccess dummy.wet = true;
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

