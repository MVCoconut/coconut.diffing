package coconut.diffing.internal;

class VWidget<Data, Native, Concrete:Widget<Native>> implements VNode<Native> {
  public final type:TypeId;
  public final data:Data;
  public final factory:WidgetFactory<Data, Native, Concrete>;
  public final ref:Null<coconut.ui.Ref<Concrete>>;
  public final key:Null<Key>;
  public final isSingular = false;

  public function new(factory, data, ?key, ?ref) {
    this.factory = factory;
    this.type = factory.type;
    this.data = data;
    this.ref = ref;
    this.key = key;
  }

  public function render(parent, cursor, later) {
    return new RWidget(parent, this, cursor, later);
  }
}

class RWidget<Data, Native, Concrete:Widget<Native>> extends WidgetLifeCycle<Native> implements RNode<Native> {
  public final type:TypeId;
  final widget:Concrete;
  var last:VWidget<Data, Native, Concrete>;

  public function new(parent:Parent, v:VWidget<Data, Native, Concrete>, cursor:Cursor<Native>, later) {

    var context = parent.context;
    var widget = v.factory.create(v.data, context);

    super(widget, context, parent, cursor, later);

    this.last = v;
    this.type = v.type;
    this.widget = widget;

    switch v.ref {
      case null:
      case f: f(widget);
    }
  }

  public function update(next:VNode<Native>, cursor:Cursor<Native>, later) {

    var next:VWidget<Data, Native, Concrete> = Cast.down(next, VWidget);
    if (last == next)
      return justInsert(cursor, later);

    if (next.ref != last.ref) {
      switch last.ref {
        case null:
        case f: f(null);
      }
      switch  next.ref {
        case null:
        case f: f(widget);
      }
    }

    last = next;
    next.factory.update(widget, next.data);
    this.rerender(later, cursor);
  }

  override public function destroy(applicator:Applicator<Native>) {
    switch last.ref {
      case null:
      case f: f(null);
    }
    return super.destroy(applicator);
  }
}