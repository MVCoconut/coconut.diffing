package coconut.diffing;

abstract Node<Native>(VNode<Native>) from VNode<Native> to VNode<Native> {
  @:from static public inline function embed<Native>(n:Native):Node<Native> {
    return new VNativeInst(n);
  }

  static public inline function many<Native, RenderResult:Node<Native>>(c:Children<RenderResult>):Node<Native>
    return new VMany(c);
}