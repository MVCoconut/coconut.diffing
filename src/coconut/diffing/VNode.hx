package coconut.diffing;

import coconut.diffing.NodeType;

@:pure
abstract VNode<Real:{}>(VNodeData<Real>) from VNodeData<Real> to VNodeData<Real> {

  static public inline function native<Attr, Real:{}>(type:NodeType<Attr, Real>, ref:Real->Void, key:Key, attr:Attr, ?children:coconut.ui.ChildrenOf<VNode<Real>>):VNode<Real>
    return cast VNative(type, ref, key, attr, cast children);

  static public inline function fragment<Real:{}>(attr:{}, children:coconut.ui.ChildrenOf<VNode<Real>>):VNode<Real>
    return VMany(cast children);
}

enum VNodeData<Real:{}> {
  VNativeInst(n:Real);
  VWidgetInst(w:Widget<Real>);
  VMany(nodes:Array<VNode<Real>>);
  VNative<Attr>(type:NodeType<Attr, Real>, ref:Dynamic->Void, key:Key, a:Attr, ?children:Array<VNode<Real>>);
  VWidget<Attr>(type:WidgetType<Attr, Real>, ref:Dynamic->Void, key:Key, a:Attr);
}