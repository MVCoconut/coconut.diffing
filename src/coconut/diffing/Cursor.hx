package coconut.diffing;

interface Cursor<Real:{}> {
  function insert(real:Real):Bool;
  function delete():Bool;
  function step():Bool;
  function current():Real;
}