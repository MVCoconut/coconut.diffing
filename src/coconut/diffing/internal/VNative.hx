package coconut.diffing.internal;

class VNative<Data, Native, Concrete:Native> implements VNode<Native> {

  public final type:TypeId;
  public final data:Data;
  public final key:Null<Key>;
  public final isSingular = true;

  public final factory:Factory<Data, Native, Concrete>;
  public final ref:Null<coconut.ui.Ref<Concrete>>;
  public final children:Children<VNode<Native>>;

  public function new(factory, data, ?key, ?ref, ?children) {
    this.factory = factory;
    this.type = factory.type;
    this.data = data;
    this.key = key;
    this.ref = ref;
    this.children = children;
  }

  public function render(parent, cursor, later) {
    return new RNative(parent, this, cursor, later);
  }
}

class RNative<Data, Native, Concrete:Native> implements RNode<Native> {
  public final type:TypeId;
  final native:Concrete;
  final children:RChildren<Native>;
  var last:VNative<Data, Native, Concrete>;
  public function new(parent, v, cursor:Cursor<Native>, later) {
    this.last = v;
    this.type = v.type;
    this.native = v.factory.create(v.data);
    this.children = new RChildren(parent, v.children, cursor.applicator.children(native), later);
    cursor.insert(native);
    switch v.ref {
      case null:
      case f: f(native);
    }
  }

  public function justInsert(cursor:Cursor<Native>, _)
    cursor.insert(native);

  public function update(next:VNode<Native>, cursor:Cursor<Native>, later) {
    var next = Cast.down(next, VNative);
    if (next == last) {
      justInsert(cursor, later);
      return;
    }

    next.factory.update(native, next.data, last.data);
    var prev = last;
    last = next;

    children.update(next.children, cursor.applicator.children(native), later);
    cursor.insert(native);
    if (last.ref != next.ref) {
      switch last.ref {
        case null:
        case f: f(null);
      }
      switch next.ref {
        case null:
        case f: f(native);
      }
    }
  }

  public function reiterate(applicator:Applicator<Native>)
    return applicator.siblings(native);

  public function destroy(applicator:Applicator<Native>) {
    applicator.children(native).delete(children.destroy(applicator));
    switch last.ref {
      case null:
      case f: f(null);
    }
    return 1;
  }

  public function forEach(f)
    f(native);

}