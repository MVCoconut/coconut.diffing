package coconut.diffing;

interface WidgetType<Virtual, Attr, Real> {
  function create(a:Attr):Widget<Virtual, Real>;
  function update(a:Attr, w:Widget<Virtual, Real>):Void;
}