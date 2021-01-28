package coconut.fake;

class DummyCursor implements Cursor<Dummy> {

  public final applicator:Applicator<Dummy>;
  static var idCounter = 0;
  // static final inserted = new Map();
  var deleted = [];
  var index:Int;
  final target:Dummy;

  public function new(applicator, target, index) {
    this.applicator = applicator;
    this.target = target;
    this.index = index;
  }

  public function insert(native:Dummy) {
    target.insert(index++, native);
    if (native.get('className') == "todo-item-description") {
      // var key = native.innerHTML;
      // switch inserted[]
    }
      // trace(id, native.render());
  }

  public function close() {
    target.removeMany(deleted);
  }

  public function markForDeletion(native:Dummy)
    deleted.push(native);
}

class DummyApplicator implements Applicator<Dummy> {
  static public final INST = new DummyApplicator();
  function new() {}

  public function delete(n:Dummy)
    switch n.parent {
      case null:
      case p:
        p.remove(n);
    }

  public function emptyMarker()
    return new Dummy(null);

  public function siblings(n:Dummy)
    return switch n.parent {
      case null: throw 'assert';
      case parent: new DummyCursor(this, parent, parent.getChildIndex(n));
    }

  public function children(n:Dummy)
    return new DummyCursor(this, n, 0);

}