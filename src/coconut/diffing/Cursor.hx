package coconut.diffing;

abstract class Cursor<Native> {
  /**
    A reference back to the applicator that created this cursor.
  **/
  public final applicator:Applicator<Native>;
  public function new(applicator)
    this.applicator = applicator;
  /**
    Inserts a native node at the current cursor position.

    Please note that:

    1. The native node may already be a child of the parent node being iterated over
    2. The native node may even be at the current cursor position.
  **/
  public abstract function insert(native:Native):Void;
  /**
    Delete `count` nodes from the current position.
  **/
  public abstract function delete(count:Int):Void;
  /**
    Returns the current node. Only used for hydration (which is only truly relevant for coconut.vdom)
  **/
  public function current():Null<Native>
    return null;
}