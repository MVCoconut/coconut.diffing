package coconut.fake;

class DummyCursor implements Cursor<Dummy> {

  public final applicator:Applicator<Dummy>;
  static var idCounter = 0;
  var index:Int;
  final target:Dummy;

  public function new(applicator, target, index) {
    this.applicator = applicator;
    this.target = target;
    this.index = index;
  }

  public function insert(native:Dummy) {
    target.insert(index++, native);
  }

  public function current()
    return target.getChild(index);

  public function delete(count:Int) {
    target.removeRange(index, count);
  }
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

  public function createMarker()
    return new Dummy(null);

  public function releaseMarker(marker) {

  }

  public function siblings(n:Dummy)
    return switch n.parent {
      case null: throw 'assert';
      case parent: new DummyCursor(this, parent, parent.getChildIndex(n));
    }

  public function children(n:Dummy)
    return new DummyCursor(this, n, 0);

}