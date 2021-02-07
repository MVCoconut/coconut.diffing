package coconut.diffing.internal;

class VMany<Native> implements VNode<Native> {
  static final TYPE = new TypeId();
  public final type = TYPE;
  public final key:Null<Key> = null;
  public final children:Children<VNode<Native>>;

  public function new(children)
    this.children = children;

  public function render(parent, cursor, later):RNode<Native>
    return new RMany(parent, children, cursor, later);
}

@:access(coconut.diffing.internal.VMany)
class RMany<Native> implements RNode<Native> {
  public final type = VMany.TYPE;

  final first:Native;
  final children:RChildren<Native>;

  public function new(parent:Parent, children:Children<VNode<Native>>, cursor:Cursor<Native>, later) {
    cursor.insert(this.first = cursor.applicator.createMarker());
    this.children = new RChildren(parent, children, cursor, later);
  }

  public function reiterate(applicator:Applicator<Native>) {
    return applicator.siblings(first);
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>, later) {
    cursor.insert(first);
    children.update(Cast.down(next, VMany).children, cursor, later);
  }

  public function justInsert(cursor:Cursor<Native>, later) {
    cursor.insert(first);
    children.justInsert(cursor, later);
  }

  public function destroy(applicator:Applicator<Native>) {
    applicator.releaseMarker(first);
    return children.destroy(applicator) + 1;
  }

  public function forEach(f) {
    f(first);
    children.forEach(f);
  }
}