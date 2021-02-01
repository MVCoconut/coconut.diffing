package coconut.diffing;

import tink.state.Observable;

class Widget<Native> {

  @:noCompletion var _coco_implicits:coconut.ui.internal.ImplicitContext;
  @:noCompletion var _coco_viewMounted:Void->Void;
  @:noCompletion var _coco_viewUpdated:Void->Void;
  @:noCompletion var _coco_viewUnmounting:Void->Void;

  @:noCompletion var _coco_vStructure:Observable<VNode<Native>>;
  #if tink_state.debug
  @:noCompletion final _coco_toString:()->String;
  #end

  public function new(
    rendered:Observable<VNode<Native>>,
    mounted:Void->Void,
    updated:Void->Void,
    unmounting:Void->Void
    #if tink_state.debug , toString #end
  ) {
    #if tink_state.debug this._coco_toString = toString; #end
    this._coco_vStructure = rendered;

    this._coco_viewMounted = mounted;
    this._coco_viewUpdated = updated;
    this._coco_viewUnmounting = unmounting;
  }
}