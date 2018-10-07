package coconut.diffing;

typedef RNode<Native, Real> = NodeOf<RNodeKind<Native, Real>>;

enum RNodeKind<N, Real> {
  RNative(n:N, r:Real);
  RWidget<Attr>(w:Widget<N, Real>);
}