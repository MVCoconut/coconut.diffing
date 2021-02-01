package coconut.diffing;

class RCell<Native> {
  final empty:VNode<Native> = new VEmpty();
  final parent:Parent;
  final applicator:Applicator<Native>;
  var virtual:VNode<Native>;
  var rendered:RNode<Native>;

  public function new(parent, virtual, cursor, later) {
    this.parent = parent;
    if (virtual == null)
      virtual = empty;
    this.virtual = virtual;
    this.rendered = virtual.render(parent, cursor, later);
    this.applicator = cursor.applicator;
  }

  public inline function reiterate(applicator)
    return rendered.reiterate(applicator);

  public function update(virtual:VNode<Native>, ?cursor:Cursor<Native>, later) {
    var cursor = switch cursor {
      case null: reiterate(applicator);
      case v: v;
    }
    var unchanged = virtual == this.virtual;
    if (unchanged)
      rendered.justInsert(cursor, later);
    else {
      if (virtual == null)
        virtual = empty;
      var last = this.virtual;

      this.virtual = virtual;

      if (last.type == virtual.type)
        this.rendered.update(virtual, cursor, later);
      else {
        var old = this.rendered;
        this.rendered = virtual.render(parent, cursor, later);
        cursor.delete(old.destroy(applicator));
      }
    }
    return !unchanged;
  }

  public function destroy(applicator)
    return this.rendered.destroy(applicator);

}