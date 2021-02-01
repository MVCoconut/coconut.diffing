package coconut.diffing;

interface VNode<Native> {
  final type:TypeId;
  final key:Null<Key>;
  function render(parent:Parent, cursor:Cursor<Native>, later:(task:()->Void)->Void):RNode<Native>;
}