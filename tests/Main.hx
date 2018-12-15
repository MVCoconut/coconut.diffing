class Main extends coconut.ui.View {
  static function main() {
    coconut.Ui.hxx('<Main/>').renderInto(js.Browser.document.body);
  }
  function render() '<div><Foo depth={5} /></div>';
}

class Foo extends coconut.ui.View {
	
  @:state var key:Int = 0;
  @:attribute var depth:Int;

	function render() '
    <if {depth > 0}>
      <Foo depth={depth - 1} />
    <else>
      <div key=${key} onclick=${key++}>Key: $key</div>
    </if>  
  ';
}