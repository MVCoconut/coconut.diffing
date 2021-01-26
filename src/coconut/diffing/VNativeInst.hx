package coconut.diffing;

class VNativeInst<Native> implements VNode<Native> implements RNode<Native> {
  static final TYPE = new TypeId();
  public final type:TypeId = TYPE;
  final native:Native;

  public function new(native) {
    this.native = native;
  }

  public function render(cursor:Cursor<Native>) {//TODO: consider detecting double mounting
    cursor.insert(native);
    return this;
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>):Void {
    var next = Cast.down(next, VNativeInst);
    cursor.insert(next.native);
    if (next.native != native)
      delete(cursor);
  }

  public function delete(cursor:Cursor<Native>):Void {
    cursor.markForDeletion(native);
  }

}