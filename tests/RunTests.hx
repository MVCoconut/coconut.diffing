package ;

import tink.unit.*;
import tink.testrunner.*;

class RunTests {

  static function main() {
    Runner.run(TestBatch.make([
      new Issue23(),
      // new TodoMvc(),
    ])).handle(Runner.exit);
  }

}