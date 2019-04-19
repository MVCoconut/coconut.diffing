package coconut.diffing;

interface Applicator<Real:{}> {
  function unsetLastRender(target:Real):Rendered<Real>;
  function setLastRender(target:Real, r:Rendered<Real>):Void;
  function getLastRender(target:Real):Null<Rendered<Real>>;
  function traverseSiblings(first:Real):Cursor<Real>;
  function traverseChildren(parent:Real):Cursor<Real>;
  function placeholder(forTarget:Widget<Real>):VNode<Real>;
}