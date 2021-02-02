package coconut.fake;

abstract RenderResult(Node<Dummy>) from Node<Dummy> to Node<Dummy> {
  static final TEXT = new DummyFactory('');
  @:from static function ofString(s:String):RenderResult
    return TEXT.instantiate({ text: s });

  static public function fragment(o:{}, c:Children):RenderResult
    return Node.many(c);
}