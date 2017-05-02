var sf = require('../');
var xs = sf('/usr/share/dict/words');
xs.slice(-10).pipe(process.stdout);
