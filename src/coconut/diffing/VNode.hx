package coconut.diffing;

typedef VNode<Virtual, Real:{}> = NodeOf<VNodeKind<Virtual, Real>>;

enum VNodeKind<Virtual, Real:{}> {
  VMany(nodes:Array<VNode<Virtual, Real>>);
  VNative(n:Virtual);
  VWidget<Attr>(a:Attr, t:WidgetType<Virtual, Attr, Real>);
}