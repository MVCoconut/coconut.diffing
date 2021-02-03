package coconut.fake;

abstract RenderResult(VNode<Dummy>) from VNode<Dummy> to VNode<Dummy> {
  static final TEXT = new DummyFactory('');
  @:from static function ofString(s:String):RenderResult
    return TEXT.vnode({ text: s });

  static public function fragment(o:{}, c:Children):RenderResult
    return VNode.many(c);
}