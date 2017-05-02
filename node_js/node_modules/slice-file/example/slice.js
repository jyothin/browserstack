var sf = require('../');
var words = sf('/usr/share/dict/words');
words.slice(22398,22408).pipe(process.stdout);
