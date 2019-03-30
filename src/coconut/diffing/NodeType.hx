package coconut.diffing;

interface NodeType<Attr, Real:{}> {
  function create(a:Attr):Real;
  function update(w:Real, old:Attr, nu:Attr):Void;
}