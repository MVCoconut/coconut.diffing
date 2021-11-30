#if !macro
  import coconut.diffing.Root;
  #if coconut.vdom
    import coconut.vdom.*;
    import coconut.vdom.Html.*;
    import coconut.Ui.*;
  #else
    import coconut.fake.Renderer.*;
    import coconut.fake.Tags.*;
    import coconut.fake.*;
  #end
  import tink.state.*;
  import coconut.data.*;
  using tink.CoreApi;

  import #if coconut.vdom js.html.Element #else coconut.fake.Dummy #end as Native;
#end