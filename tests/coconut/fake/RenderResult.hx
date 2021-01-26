package coconut.fake;

abstract RenderResult(VNode<Dummy>) from VNode<Dummy> to VNode<Dummy> {
  @:from static function ofString(s:String):RenderResult
    return VDummy.forTag('')({ text: s });
}