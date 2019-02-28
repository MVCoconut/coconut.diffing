package coconut.diffing;

abstract VNode<Real:{}>(VNodeData<Real>) from VNodeData<Real> to VNodeData<Real> {
  
  static public inline function fragment<R:{}>(attr:{}, children:coconut.ui.Children):VNode<R>
    return VMany(cast children);
}

enum VNodeData<Real:{}> {
  VNativeInst(n:Real);
  VWidgetInst(w:Widget<Real>);
  VMany(nodes:Array<VNode<Real>>);
  VNative<Attr>(type:NodeType, ?ref:Dynamic->Void, ?key:Key, a:Attr, ?children:Array<VNode<Real>>);
  VWidget<Attr>(type:NodeType, ?ref:Dynamic->Void, ?key:Key, a:Attr, t:WidgetType<Attr, Real>);
}