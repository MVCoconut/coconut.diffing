package coconut.diffing;

import coconut.diffing.internal.VNode as Internal;

abstract VNode<Native>(Internal<Native>) from Internal<Native> to Internal<Native> {
  @:from static public inline function embed<Native>(n:Native):VNode<Native>
    return new VNativeInst(n);

  static public inline function many<Native, RenderResult:VNode<Native>>(c:Children<RenderResult>):VNode<Native>
    return new VMany(c);
}