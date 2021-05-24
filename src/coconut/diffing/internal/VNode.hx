package coconut.diffing.internal;

interface VNode<Native> {
  final type:TypeId;
  final key:Null<Key>;
  final isSingular:Bool;
  function render(parent:Parent, cursor:Cursor<Native>, later:(task:()->Void)->Void, ?previous:Native):RNode<Native>;
}