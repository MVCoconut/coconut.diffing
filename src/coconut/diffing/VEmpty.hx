package coconut.diffing;

class VEmpty<Native> implements VNode<Native>  {

  static final TYPE = new TypeId();
  public final type:TypeId = TYPE;
  public function new() {}

  public function render(_, cursor:Cursor<Native>):RNode<Native> {
    return new REmpty(cursor);
  }
}

class REmpty<Native> implements RNode<Native> {
  public final type:TypeId = @:privateAccess VEmpty.TYPE;

  final marker:Native;

  public function new(cursor:Cursor<Native>)
    cursor.insert(this.marker = cursor.applicator.emptyMarker());

  public function reiterate(applicator:Applicator<Native>):Cursor<Native>
    return applicator.siblings(marker);

  public function update(next:VNode<Native>, cursor:Cursor<Native>):Void
    cursor.insert(marker);

  public function delete(cursor:Cursor<Native>):Void
    cursor.markForDeletion(marker);


}