package coconut.diffing;

import tink.state.Observable;

class Widget<Native> {

  @:noCompletion var _coco_implicits:coconut.ui.internal.ImplicitContext;
  @:noCompletion var _coco_lifeCycle:WidgetLifeCycle<Native>;
  @:noCompletion final _coco_viewMounted:()->Void;
  @:noCompletion final _coco_viewUpdated:()->Void;
  @:noCompletion final _coco_viewUnmounting:()->Void;

  @:noCompletion var _coco_vStructure:Observable<VNode<Native>>;
  #if tink_state.debug
  @:noCompletion final _coco_toString:()->String;
  #end

  public function new<RenderResult:VNode<Native>>(
    rendered:Observable<RenderResult>,
    mounted:()->Void,
    updated:()->Void,
    unmounting:()->Void
    #if tink_state.debug , toString #end
  ) {
    #if tink_state.debug this._coco_toString = toString; #end
    this._coco_vStructure = cast rendered;

    this._coco_viewMounted = mounted;
    this._coco_viewUpdated = updated;
    this._coco_viewUnmounting = unmounting;
  }
}