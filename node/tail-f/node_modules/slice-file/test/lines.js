var test = require('tap').test;
var lf = require('../');
var through = require('through2');
var fs = require('fs');

test('lines', function (t) {
    var file = __dirname + '/data/lines.txt';
    var lines = fs.readFileSync(file, 'utf8')
        .split('\n')
        .slice(0,-1)
        .map(function (line) { return line + '\n' })
    ;
    t.plan(lines.length * 2 + 11);
    
    var s = lf(file);
    (function next (n) {
        var xs = [];
        s.slice(n).pipe(through(write, end));
        function write (buf, _, next) { xs.push(String(buf)); next() }
        function end () {
            t.deepEqual(lines.slice(n), xs);
        }
        if (n > -5 - lines.length) next(n - 1)
    })(lines.length + 5);
});
