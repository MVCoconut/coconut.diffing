package coconut.diffing;

interface Applicator<Real:{}> {
  function unsetLastRender(target:Real):Rendered<Real>;
  function setLastRender(target:Real, r:Rendered<Real>):Void;
  function getLastRender(target:Real):Null<Rendered<Real>>;
  function setChildren(target:Real, children:Array<Real>):Void;
  function getParent(target:Real):Real;
  function removeChild(target:Real, child:Real):Void;
  function createCursor(target:Real):Cursor<Real>;
  function placeholder(forTarget:Widget<Real>):VNode<Real>;//this seems a bit ill-placed
}