package coconut.diffing;

interface RNode<Native> {
  final type:TypeId;//TODO: figure out if this is needed
  function reiterate(applicator:Applicator<Native>):Cursor<Native>;
  function update(next:VNode<Native>, cursor:Cursor<Native>, later:(task:()->Void)->Void):Void;
  function justInsert(cursor:Cursor<Native>, later:(task:()->Void)->Void):Void;
  function destroy(applicator:Applicator<Native>):Int;
}