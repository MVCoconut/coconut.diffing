package coconut.diffing.internal;

class VNativeBase<Native, Concrete:Native> implements VNode<Native> {

  public final type:TypeId;
  public final key:Null<Key>;
  public final isSingular = true;

  public final ref:Null<coconut.ui.Ref<Concrete>>;
  public final children:Children<VNode<Native>>;

  public function new(type, ?key, ?ref, ?children) {
    this.type = type;
    this.key = key;
    this.ref = ref;
    this.children = children;
  }

  public function render(parent, cursor, later):RNode<Native> {
    return new RNativeBase(VNativeBase, parent, this, cursor, later);
  }

  public function create():Concrete
    return throw 'abstract';
}

class RNativeBase<Virtual:VNativeBase<Native, Concrete>, Native, Concrete:Native> implements RNode<Native> {
  public final type:TypeId;
  final native:Concrete;
  final children:RChildren<Native>;
  final cls:Class<Virtual>;
  var last:Virtual;
  public function new(cls, parent, v, cursor:Cursor<Native>, later) {
    this.cls = cls;
    this.last = v;
    this.type = v.type;
    this.native = v.create();
    this.children = new RChildren(parent, v.children, cursor.applicator.children(native), later);
    cursor.insert(native);
    switch v.ref {
      case null:
      case f: f(native);
    }
  }

  public function justInsert(cursor:Cursor<Native>, _)
    cursor.insert(native);

  function updateNative(native:Concrete, next:Virtual, last:Virtual) {
    throw 'abstract';
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>, later) {
    var next = Cast.down(next, cls);
    if (next == last) {
      justInsert(cursor, later);
      return;
    }

    updateNative(native, next, last);
    var prev = last;
    last = next;

    children.update(next.children, cursor.applicator.children(native), later);
    cursor.insert(native);
    if (prev.ref != next.ref) {
      switch prev.ref {
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