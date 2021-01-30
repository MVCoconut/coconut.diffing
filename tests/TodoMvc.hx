#if coconut.vdom
import coconut.vdom.*;
#else
import coconut.fake.Tags.*;
import coconut.fake.*;
#end
import tink.state.*;
import coconut.data.*;
import tink.unit.*;
import tink.testrunner.*;
using tink.CoreApi;

@:asserts
class TodoMvc {
  var root:#if coconut.vdom js.html.Element #else Dummy #end;
  var items:State<List<TodoItem>>;

  function new() {

  }
  @:before public function init() {
    items = new State(null);
    root = createRoot();
    return Promise.NOISE;
  }

  function createRoot() {
    return
      #if coconut.vdom
        js.Browser.document.createElement('main')
      #else
        new Dummy('main')
      #end
    ;
  }

  function byClass(name:String)
    return
      #if coconut.vdom
        [for (e in root.getElementsByClassName(name)) e];
      #else
        root.find(d -> d.get('className') == name);
      #end

  function update(value) {
    items.set(value);
    Renderer.updateAll();
  }

  function add(desc)
    update(items.value.prepend(new TodoItem({ description: desc })));

  @:variant(false)
  @:variant(true)
  public function testInsertion(keyed:Bool) {

    Renderer.mount(root, '<TodoListView list=${items} keyed=${keyed} />');
    function found()
      return [for (d in byClass("todo-item-description")) d.innerHTML].join(',');

    function expected()
      return [for (item in items.value) item.description].join(',');
    asserts.assert(found() == expected());
    add('a');
    asserts.assert(found() == expected());
    add('b');
    asserts.assert(found() == expected());
    add('c');
    asserts.assert(found() == expected());
    add('d');
    asserts.assert(found() == expected());
    var index = 0;
    update([for (item in items.value) if (index++ % 2 == 0) item]);
    asserts.assert(found() == expected());

    return asserts.done();
  }

  public function testUpdates() {
    var filter = new State(Complete);
    add('a');
    Renderer.mount(root, '<TodoListView filter=${filter} list=${items} />');
    var before = root.innerHTML;
    filter.set(All);
    Renderer.updateAll();// <-- this update causes dom out of order
    filter.set(Complete);
    Renderer.updateAll();
    asserts.assert(root.innerHTML == before);
    return asserts.done();
  }

  static function main() {
    Runner.run(TestBatch.make([
      new TodoMvc()
    ])).handle(Runner.exit);
  }
}

private class TodoItem implements Model {
  @:editable var done:Bool = false;
  @:editable var description:String;
  public function toString() {
    return 'Todo($description)';
  }
}

enum abstract Filter(String) to String {
  var All;
  var Active;
  var Complete;
  public inline function includes(i:TodoItem)
    return switch (cast this:Filter) {
      case All: true;
      case Active: !i.done;
      case Complete: i.done;
    }
}

class TodoListView extends View {
  @:attribute var list:List<TodoItem>;
  @:controlled var filter:Filter = All;
  @:attribute var keyed:Bool = true;
  function render() '
    <div class="todo-list">
      <Header list=${list} />
      <for ${item in list}>
        <if ${filter.includes(item)}>
          <TodoItemView key=${if (keyed) item else null} item=${item} />
        </if>
      </for>
      <Footer list=${list} filter=${filter} />
    </div>
  ';
}

private class Header extends View {
  @:attribute var list:List<TodoItem>;
  function render() '
    <div id="header" class=${if (list.length == 0) "idle" else "busy"} />
  ';
}

private class Footer extends View {
  @:attribute var list:List<TodoItem>;
  @:controlled var filter:Filter = All;
  function render() '
    <div id="footer" class=${filter}>
      <if ${list.length > 0}>
        ${switch list.count(i -> !i.done) {
          case 1: '1 item left';
          case v: '$v items left';
        }}
      </if>
    </div>
  ';
}

private class TodoItemView extends View {
  @:attribute var item:TodoItem;
  function render() '
    <div class="todo-item">
      <div class="todo-item-description">${item.description}</div>
    </div>
  ';
}