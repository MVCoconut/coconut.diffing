package coconut.diffing;

@:pure @:final 
@:structInit class NodeOf<Kind> {
  public var key(default, null):Key;
  public var type(default, null):NodeType;
  @:pure(false) public var ref(default, null):Null<Any->Void>;
  public var kind(default, null):Kind;

  static public function many<Virtual, Real:{}>(attr:{}, children:Array<VNode<Virtual, Real>>):VNode<Virtual, Real>
    return {
      key: null,
      type: null,
      ref: null,
      kind: VMany(children)
    }  
}
