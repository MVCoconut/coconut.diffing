@:asserts
class Issue23 extends TestBase {
  public function test() {
    var state = new State(true);
    Renderer.mount(root, '
      <Isolated>
        <if ${state.value}>
          <>
            <div>Hello </div>
            <div>world</div>
          </>
        </if>
      </Isolated>
    ');

    var didThrow = false;
    try {
      state.value = false;
      Renderer.updateAll();
    }
    catch (e:haxe.Exception) didThrow = true;

    asserts.assert(!didThrow);
    asserts.assert(root.innerHTML == '');

    return asserts.done();
  }
}