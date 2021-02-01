package coconut.diffing;

class VMany<Native> implements VNode<Native> {
  static final TYPE = new TypeId();
  static final EMPTY:ReadOnlyArray<Dynamic> = [];
  public final type = TYPE;
  public final key:Null<Key> = null;
  public final children:ReadOnlyArray<VNode<Native>>;

  public function new(?children)
    this.children = switch children {
      case null: cast EMPTY;
      case v: v;
    }

  public function render(parent, cursor, later):RNode<Native>
    return new RMany(parent, children, cursor, later);
}

@:access(coconut.diffing.VMany)
class RMany<Native> implements RNode<Native> {
  public final type = VMany.TYPE;

  final first:Native;
  final children:RChildren<Native>;

  public function new(parent:Parent, children:ReadOnlyArray<VNode<Native>>, cursor:Cursor<Native>, later) {
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

  public function count()
    return 1 + children.count();

  public inline function justInsert(cursor:Cursor<Native>, later) {
    cursor.insert(first);
    children.justInsert(cursor, later);
  }

  public function delete(cursor:Cursor<Native>):Void {
    cursor.delete(count());
    cursor.applicator.releaseMarker(first);
  }
}