import coconut.ui.*;

typedef Rec = coconut.data.Record<{ foo: Int }>;

class Main extends View {
  static function main() {
    var r = new Rec({ foo: 42});
    // coconut.Ui.hxx('<Main/>').renderInto(js.Browser.document.body);
    coconut.Ui.hxx('
      <main>
        <Blargh>
          <blub>
            Foo: {foo}
            <button onclick={r.update({ foo: r.foo + 1})}>{r.foo}</button>
            <Outer>{r.foo}</Outer>
          </blub>
        </Blargh>      
      </main>
    ').renderInto(js.Browser.document.body);
  }
  function render() return null;//'<div><Foo depth={5} /></div>';
}

// class Foo extends View {
	
//   @:state var key:Int = 0;
//   @:attribute var depth:Int;

// 	function render() '
//     <if {depth > 0}>
//       <Foo depth={depth - 1} />
//     <else>
//       <div key=${key} onclick=${key++}>Key: $key</div>
//     </if>  
//   ';
// }

class Outer extends View {
  @:attribute var children:Children;
  function render() {
    trace('render Outer');
    return @hxx '<div data-id={viewId}>Outer: {...children} <Inner>{...children}</Inner></div>';
  }
  override function viewDidUpdate()
    trace('updated Outer');
}


class Inner extends View {
  @:attribute var children:Children;
  function render() {
    trace('render Inner');
    return @hxx '<div data-id={viewId}>Inner: {...children}</div>';
  }

  override function viewDidUpdate()
    trace('updated Inner');
}

class Blargh extends View {
  @:attribute function blub(attr:{ foo:String }):Children;
  @:state var hidden:Bool = false;
  function render() '
    <if {!hidden}>
      <>
        <div>1</div>
        <div>2</div>
        {...blub({ foo: "yeah" })}
        <button onclick={hide}>Hide</button>
      </>
    </if>
  ';

  function hide() {
    hidden = true; 
    @in(1) @do hidden = false;
  }
  // function render() '
  //   <div>
  //     {...blub({ foo: "yeah" })}
  //   </div>
  // ';

}