package coconut.diffing;

@:pure @:final 
@:structInit class NodeOf<Kind> {
  public var key(default, null):Key;
  public var type(default, null):NodeType;
  public var ref(default, null):Null<Any->Void>;
  public var kind(default, null):Kind;
}
