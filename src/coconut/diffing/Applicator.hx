package coconut.diffing;

interface Applicator<Native> {
  // function delete(n:Native):Void;
  function siblings(n:Native):Cursor<Native>;
  function children(n:Native):Cursor<Native>;
  function emptyMarker():Native;
}