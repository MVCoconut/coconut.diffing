package coconut.diffing;

enum RNode<N, Real:{}> {
  RNative(n:N, r:Real, ?ref:Dynamic->Void);
  RWidget<Attr>(w:Widget<N, Real>, ?ref:Dynamic->Void);
}