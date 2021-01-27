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

  public function update(virtual:VNode<Native>, ?cursor:Cursor<Native>)
    if (virtual != this.virtual)
      withCursor(cursor, cursor -> {
        if (virtual == null)
          virtual = empty;
        var last = this.virtual;

        this.virtual = virtual;

        if (last.type == virtual.type)
          this.rendered.update(virtual, cursor);
        else {
          this.rendered.delete(cursor);
          this.rendered = virtual.render(parent, cursor);
        }
      });

  inline function withCursor(cursor, f)
    switch cursor {
      case null:
        var cursor = reiterate(applicator);
        f(cursor);
        cursor.close();
      case c:
        f(c);
    }

  public function delete(?cursor)
    withCursor(cursor, cursor -> this.rendered.delete(cursor));
}