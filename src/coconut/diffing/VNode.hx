package coconut.diffing;

abstract VNode<Virtual, Real:{}>(VNodeData<Virtual, Real>) from VNodeData<Virtual, Real> to VNodeData<Virtual, Real> {
  
  static public inline function fragment<V, R:{}>(attr:{}, children):VNode<V, R>
    return VMany(children);
}

enum VNodeData<Virtual, Real:{}> {
  VMany(nodes:Array<VNode<Virtual, Real>>);
  VNative(type:NodeType, ?ref:Dynamic->Void, ?key:Key, n:Virtual);
  VWidget<Attr>(type:NodeType, ?ref:Dynamic->Void, ?key:Key, a:Attr, t:WidgetType<Virtual, Attr, Real>);
}