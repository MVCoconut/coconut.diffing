package coconut.diffing;

class RCell<Native> {
  final empty:VNode<Native> = new VEmpty();
  final parent:Parent;
  final applicator:Applicator<Native>;
  var virtual:VNode<Native>;
  var rendered:RNode<Native>;

  public function new(parent, virtual, cursor) {
    this.parent = parent;
    if (virtual == null)
      virtual = empty;
    this.virtual = virtual;
    this.rendered = virtual.render(parent, cursor);
    this.applicator = cursor.applicator;
  }

  public inline function reiterate(applicator)
    return rendered.reiterate(applicator);

  public function update(virtual:VNode<Native>, ?cursor:Cursor<Native>) {
    var cursor = ensure(cursor);
    var unchanged = virtual == this.virtual;
    if (unchanged)
      rendered.justInsert(cursor);
    else {
      if (virtual == null)
        virtual = empty;
      var last = this.virtual;

      this.virtual = virtual;

      if (last.type == virtual.type)
        this.rendered.update(virtual, cursor);
      else {
        var old = this.rendered;
        this.rendered = virtual.render(parent, cursor);
        old.delete(cursor);
      }
    }
    return !unchanged;
  }

  inline function ensure(?cursor:Cursor<Native>)
    return
      if (cursor == null) reiterate(applicator);
      else cursor;

  public function delete(?cursor)
    this.rendered.delete(ensure(cursor));

  public inline function count()
    return rendered.count();
}