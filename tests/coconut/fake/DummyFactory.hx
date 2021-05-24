package coconut.fake;

class DummyFactory implements Factory<Attr, Dummy, Dummy> {

  public final tag:String;
  public final type:TypeId = new TypeId();

  public function new(tag) {
    this.tag = tag;
  }

  public function create(data:Attr):Dummy {
    var ret = new Dummy(tag);
    update(ret, data, null);
    return ret;
  }

  public function adopt(_)
    return null;

  public function hydrate(_, _)
    throw 'not implemented';

  public function update(target:Dummy, next:Attr, prev:Attr) {

    for (k => v in next)
      target.attr[k] = v;

    if (prev != null)
      for (k in prev.keys())
        if (!next.exists(k))
          target.attr.remove(k);
  }
}

