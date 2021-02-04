package coconut.fake;

private typedef Data = haxe.DynamicAccess<String>;

@:forward
@:transitive
abstract Attr(Data) from Data to Data {
  @:from static function ofMap(map:Map<String, String>):Attr {
    var ret = new Data();
    for (k => v in map)
      ret[k] = v;
    return ret;
  }
}