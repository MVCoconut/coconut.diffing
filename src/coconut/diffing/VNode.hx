package coconut.diffing;

import coconut.diffing.NodeType;

abstract VNode<Real:{}>(VNodeData<Real>) from VNodeData<Real> to VNodeData<Real> {
  
  static public inline function fragment<R:{}>(attr:{}, children:coconut.ui.Children):VNode<R>
    return VMany(cast children);
}

enum VNodeData<Real:{}> {
  VNativeInst(n:Real);
  VWidgetInst(w:Widget<Real>);
  VMany(nodes:Array<VNode<Real>>);
  VNative<Attr>(type:NodeType<Attr, Real>, ?ref:Dynamic->Void, ?key:Key, a:Attr, ?children:Array<VNode<Real>>);
  VWidget<Attr>(type:WidgetType<Attr, Real>, ?ref:Dynamic->Void, ?key:Key, a:Attr);
}