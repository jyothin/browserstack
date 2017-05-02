var test = require('tap').test;
var sf = require('../');
var fs = require('fs');

test('undefined begin, 0 end', function (t) {
    t.plan(1);
    
    var file = __dirname + '/data/lines.txt';
    var lines = fs.readFileSync(file, 'utf8')
        .split('\n')
        .slice(0,-1)
        .map(function (line) { return line + '\n' })
    ;
    
    sf(file).slice(undefined, 0, function (err, xs) {
        t.deepEqual(xs, lines.slice(undefined, 0)); // []
    });;
});
