package coconut.diffing;

interface Cursor<Native> {
  final applicator:Applicator<Native>;
  function insert(native:Native):Void;
  function markForDeletion(native:Native):Void;
  function close():Void;
}