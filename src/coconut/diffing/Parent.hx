package coconut.diffing;

interface Parent<Virtual, Real> {
  // private function _coco_getRender():Rendered<Virtual, Real>;
  private function _coco_invalidate():Void;
}