package coconut.diffing.internal;

class VMany<Native> implements VNode<Native> {
  static final TYPE = new TypeId();
  public final type = TYPE;
  public final key:Null<Key> = null;
  public final children:Children<VNode<Native>>;
  public final isSingular = false;

  public function new(children)
    this.children = children;

  public function render(parent, cursor, later, hydrate:Bool):RNode<Native>
    return new RMany(parent, children, cursor, later, hydrate);
}

@:access(coconut.diffing.internal.VMany)
class RMany<Native> implements RNode<Native> {
  public final type = VMany.TYPE;

  final children:RChildren<Native>;

  public function new(parent:Parent, children:Children<VNode<Native>>, cursor:Cursor<Native>, later, hydrate) {
    this.children = new RChildren(parent, ensure(children), cursor, later, hydrate);
  }

  final empty:Children<VNode<Native>> = [new VEmpty()];
  function ensure(c:Children<VNode<Native>>) {
    for (n in c)
      if (n != null) return c;
    return empty;
  }

  public function reiterate(applicator:Applicator<Native>)
    return @:privateAccess children.order[0].reiterate(applicator);

  public function update(next:VNode<Native>, cursor:Cursor<Native>, later)
    children.update(ensure(Cast.down(next, VMany).children), cursor, later);

  public function justInsert(cursor:Cursor<Native>, later)
    children.justInsert(cursor, later);

  public function destroy(applicator:Applicator<Native>)
    return children.destroy(applicator) + 1;

  public function forEach(f)
    children.forEach(f);
}