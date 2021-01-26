package coconut.diffing;

class VNative<Data, Native, Concrete:Native> implements VNode<Native> {

  public final type:TypeId;
  public final data:Data;
  public final factory:Factory<Data, Concrete>;
  public final ref:Null<coconut.ui.Ref<Concrete>>;
  public final children:ReadOnlyArray<VNode<Native>>;

  public function new(factory, data, ?ref, ?children) {
    this.factory = factory;
    this.type = factory.type;
    this.data = data;
    this.ref = ref;
    this.children = children;
  }

  public function render(parent, cursor) {
    return new RNative(parent, this, cursor);
  }
}

class RNative<Data, Native, Concrete:Native> implements RNode<Native> {
  public final type:TypeId;
  final native:Concrete;
  final children:RChildren<Native>;
  var last:VNative<Data, Native, Concrete>;
  public function new(parent, v, cursor:Cursor<Native>) {
    this.last = v;
    this.type = v.type;
    this.native = v.factory.create(v.data);
    {
      var cursor = cursor.applicator.children(native);
      this.children = new RChildren(parent, v.children, cursor);
      cursor.close();
    }
    cursor.insert(native);
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>) {
    var next = Cast.down(next, VNative);

    if (next.type != last.type) {
      trace(next, last);
      throw 'assert';
      next = last;
    }

    next.factory.update(native, next.data, last.data);
    last = next;

    {
      var cursor = cursor.applicator.children(native);
      children.update(next.children, cursor);
      cursor.close();
    }
    cursor.insert(native);
  }

  public function reiterate(applicator:Applicator<Native>)
    return applicator.siblings(native);

  public function delete(cursor:Cursor<Native>) {
    {
      var cursor = cursor.applicator.children(native);
      children.delete(cursor);
      cursor.close();
    }
    cursor.markForDeletion(native);
  }

}