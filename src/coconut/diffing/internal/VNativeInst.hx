package coconut.diffing.internal;

class VNativeInst<Native:{}> implements VNode<Native> implements RNode<Native> {
  static final TYPE = new TypeId();
  public final type:TypeId = TYPE;
  public final key:Key;// perhaps this should simply be the instance itself
  public final isSingular = true;
  final native:Native;

  public function new(native) {
    this.native = native;
    this.key = native;
  }

  public function render(_, cursor:Cursor<Native>, later, hydrate:Bool) {//TODO: consider detecting double mounting
    cursor.insert(native);
    return this;
  }

  public function reiterate(applicator:Applicator<Native>)
    return applicator.siblings(native);

  public function justInsert(cursor, _)
    cursor.insert(native);

  public function update(next:VNode<Native>, cursor:Cursor<Native>, _):Void
    inline justInsert(cursor, _);

  public function destroy(_):Int
    return 1;

  public function forEach(f)
    f(native);
}