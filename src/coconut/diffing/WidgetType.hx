package coconut.diffing;

typedef WidgetType<Attr, Real:{}> = {
  function create(a:Attr):Widget<Real>;
  function update(a:Attr, w:Widget<Real>):Void;
}