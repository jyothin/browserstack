var sf = require('../');
var xs = sf('/var/mail/' + process.env.USER);
xs.follow(-10).pipe(process.stdout);
