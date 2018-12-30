package coconut.diffing;

enum RNode<Real:{}> {
  RNative<Attr>(a:Attr, r:Real, ?ref:Dynamic->Void);
  RWidget<Attr>(w:Widget<Real>, ?ref:Dynamic->Void);
}