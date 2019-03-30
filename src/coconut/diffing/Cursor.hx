package coconut.diffing;

interface Cursor<Real:{}> {
  function insert(real:Real):Void;
  function step():Bool;
  function current():Real;
}