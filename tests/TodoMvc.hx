#if coconut.vdom
import coconut.vdom.*;
#else
import coconut.fake.Tags.*;
import coconut.fake.*;
#end
import coconut.data.*;
import tink.unit.*;
import tink.testrunner.*;
using tink.CoreApi;

@:asserts
class TodoMvc {

  function new() {

  }
  @:variant(false)
  @:variant(true)
  public function testBasic(keyed:Bool) {
    var items = new tink.state.State<List<TodoItem>>(null),
        root =
          #if coconut.vdom
            js.Browser.document.createElement('main')
          #else
            new Dummy('root')
          #end
        ;

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
    Renderer.mount(root, '<TodoListView list=${items} keyed=${keyed} />');
    function descriptions()
      return [for (d in byClass("todo-item-description")) d.innerHTML].join(',');

    asserts.assert(descriptions() == '');
    update([new TodoItem({ description: 'a' })]);
    asserts.assert(descriptions() == 'a');
    update([new TodoItem({ description: 'a' }), new TodoItem({ description: 'b' })]);
    asserts.assert(descriptions() == 'a,b');
    items.value.first().sure().description = 'c';
    asserts.assert(descriptions() == 'a,b');
    Renderer.updateAll();
    asserts.assert(descriptions() == 'c,b');
    // trace(byClass("footer")[0].innerHTML);
    return asserts.done();
  }
  static function main() {
    Runner.run(TestBatch.make([
      new TodoMvc()
    ])).handle(Runner.exit);
  }
}

class TodoItem implements Model {
  @:editable var done:Bool = false;
  @:editable var description:String;
}

class TodoListView extends View {
  @:attribute var list:List<TodoItem>;
  @:attribute var keyed:Bool;
  function render() '
    <div class="todo-list">
      <for ${item in list}>
        <TodoItemView key=${if (keyed) item else null} item=${item} />
      </for>
      <div class="footer">
        <if ${list.length > 0}>
          ${switch list.count(i -> !i.done) {
            case 1: '1 item left';
            case v: '$v items left';
          }}
        </if>
      </div>
    </div>
  ';
}

class TodoItemView extends View {
  @:attribute var item:TodoItem;
  function render() '
    <div class="todo-item">
      <div class="todo-item-description">${item.description}</div>
    </div>
  ';
}