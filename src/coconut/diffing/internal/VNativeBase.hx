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

  public function render(parent, cursor, later, hydrate:Bool):RNode<Native> {
    return new RNativeBase(this, VNativeBase, parent, cursor, later, hydrate);
  }

  public function create(?previous:Native):Concrete
    return throw 'abstract';
}

class RNativeBase<Virtual:VNativeBase<Native, Concrete>, Native, Concrete:Native> implements RNode<Native> {
  public final type:TypeId;
  final native:Concrete;
  final children:RChildren<Native>;
  final cls:Class<Virtual>;
  var last:Virtual;

  public function new(v, cls, parent, cursor:Cursor<Native>, later, hydrate) {
    this.last = v;
    this.cls = cls;
    this.type = v.type;
    this.native = v.create(if (hydrate) cursor.current() else null);
    this.children = new RChildren(parent, v.children, cursor.applicator.children(native), later, hydrate);
    cursor.insert(native);
    switch v.ref {
      case null:
      case f: f(native);
    }
  }

  public function justInsert(cursor:Cursor<Native>, _)
    cursor.insert(native);

  function updateNative(native:Concrete, next:Virtual, last:Virtual, parent:Parent, later:(task:()->Void)->Void) {// TODO: Pretty sure this is a text book case of a fragile base class, but right it gets the job done
    throw 'abstract';
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>, later) {
    var next = Cast.down(next, cls);
    if (next == last) {
      justInsert(cursor, later);
      return;
    }

    updateNative(native, next, last, children.parent, later);
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