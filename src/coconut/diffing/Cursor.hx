package coconut.diffing;

interface Cursor<Native> {
  /**
    A reference back to the applicator that created this cursor.
  **/
  final applicator:Applicator<Native>;
  /**
    Inserts a native node at the current cursor position.

    Please note that:

    1. The native element may already be a child of the parent node being iterated over
    2. The native element may even be at the current cursor position.
  **/
  function insert(native:Native):Void;
  /**
    Delete `count` elements from the current position.
  **/
  function delete(count:Int):Void;
}