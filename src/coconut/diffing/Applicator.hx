package coconut.diffing;

interface Applicator<Native> {
  /**
    Creates a cursor to iterate the children of `n` starting with the very first one.
  **/
  function children(n:Native):Cursor<Native>;
  /**
    Creates a cursor to iterate the siblings of `n` starting `n` itself
  **/
  function siblings(n:Native):Cursor<Native>;
  /**
    Creates a native marker node. The differ uses this as an insertion point left behind by empty fragments or views.
   */
  function createMarker():Native;
  /**
    Releases back a marker that is no longer used. Implementors may choose to do nothing or to pool it for reuse in `createMarker`.
  **/
  function releaseMarker(marker:Native):Void;
}