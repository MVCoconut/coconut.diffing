package coconut.diffing;

interface Applicator<Native> {
  function siblings(n:Native):Cursor<Native>;
  function children(n:Native):Cursor<Native>;
  function createMarker():Native;
  function releaseMarker(marker:Native):Void;
}