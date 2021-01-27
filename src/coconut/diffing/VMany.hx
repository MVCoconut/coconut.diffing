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

  public function render(parent, cursor):RNode<Native>
    return new RMany(parent, children, cursor);
}

@:access(coconut.diffing.VMany)
class RMany<Native> implements RNode<Native> {
  public final type = VMany.TYPE;

  var byType = new Map<TypeId, Array<RNode<Native>>>();
  var counts = new Map<TypeId, Int>();
  final first:Native;
  final children:RChildren<Native>;

  public function new(parent:Parent, children:ReadOnlyArray<VNode<Native>>, cursor:Cursor<Native>) {
    cursor.insert(this.first = cursor.applicator.emptyMarker());
    this.children = new RChildren(parent, children, cursor);
  }

  public function reiterate(applicator:Applicator<Native>) {
    return applicator.siblings(first);
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>) {
    cursor.insert(first);
    children.update(Cast.down(next, VMany).children, cursor);
  }

  public function delete(cursor:Cursor<Native>):Void {
    cursor.markForDeletion(first);
    children.delete(cursor);
  }
}