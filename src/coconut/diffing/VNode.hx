package coconut.diffing;

interface VNode<Native> {
  final type:TypeId;
  function render(parent:Parent, cursor:Cursor<Native>):RNode<Native>;
}