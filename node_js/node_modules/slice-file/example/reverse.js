var sf = require('../');
var xs = sf('/usr/share/dict/words');
xs.sliceReverse(-10).pipe(process.stdout);
