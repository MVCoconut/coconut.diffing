package coconut.diffing.macros;

import haxe.macro.Expr;
using tink.MacroApi;

class Setup {
  static function all() 
    coconut.ui.macros.ViewBuilder.afterBuild.whenever(function (ctx) {
      var t = ctx.target.target.name.asComplexType();
      var allAttributes = TAnonymous(ctx.attributes.concat(
        (macro class {
          @:optional var key(default, never):coconut.diffing.Key;
          @:optional var ref(default, never):$t->Void;
        }).fields      
      ));

      var attributes = ctx.attributes;

      ctx.target.addMembers(macro class {
        static public function fromHxx(attributes:$allAttributes) {
          return @:privateAccess coconut.ui.RenderResult.widget(
            $v{ctx.target.target.pack.concat([ctx.target.target.name]).join('.')},
            attributes.key,
            attributes.ref,
            attributes,
            {
              create: $i{ctx.target.target.name}.new,
              update: function (attr, v) (cast v:$t).__initAttributes(attr) //TODO: unhardcode method name ... should probably come from ctx
            }
          );
        }
      });
    });
}