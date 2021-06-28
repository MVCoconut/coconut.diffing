package coconut.diffing.internal;

class VEmpty<Native> implements VNode<Native>  {

  static final TYPE = new TypeId();
  public final type:TypeId = TYPE;
  public final key:Null<Key> = null;
  public final isSingular = true;

  public function new() {}

  public function render(_, cursor:Cursor<Native>, _, hydrate:Bool):RNode<Native> {
    return new REmpty(cursor);
  }
}

class REmpty<Native> implements RNode<Native> {
  public final type:TypeId = @:privateAccess VEmpty.TYPE;

  final marker:Native;

  public function new(cursor:Cursor<Native>)
    cursor.insert(this.marker = cursor.applicator.createMarker());

  public function reiterate(applicator:Applicator<Native>):Cursor<Native>
    return applicator.siblings(marker);

  public function update(next:VNode<Native>, cursor:Cursor<Native>, later)
    inline justInsert(cursor, later);

  public function justInsert(cursor, _)
    cursor.insert(marker);

  public function destroy(applicator:Applicator<Native>) {
    applicator.releaseMarker(marker);
    return 1;
  }

  public function forEach(f)
    f(marker);

}