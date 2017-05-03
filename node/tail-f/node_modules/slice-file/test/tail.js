var test = require('tap').test;
var lf = require('../');
var through = require('through2');
var fs = require('fs');
var wordFile = __dirname + '/data/words';

test('short tail', function (t) {
    t.plan(11);
    
    var xs = lf(wordFile);
    var res = [];
    
    xs.slice(-10).pipe(through(write, end));
    
    function write (line, _, next) {
        t.ok(Buffer.isBuffer(line));
        res.push(String(line));
        next();
    }
    
    function end () {
        t.deepEqual(res, [
            "élan's\n",
            "émigré\n",
            "émigré's\n",
            "émigrés\n",
            "épée\n",
            "épée's\n",
            "épées\n",
            "étude\n",
            "étude's\n",
            "études\n",
        ]);
    }
});

test('long tail', function (t) {
    var lines = fs.readFileSync(wordFile, 'utf8').split('\n');
    lines.pop();
    
    var xs = lf(wordFile);
    
    var amounts = [ 10, 100, 500, 1000, 5000, 10000 ];
    t.plan(amounts.length);
    
    (function shift () {
        if (amounts.length === 0) return;
        var n = amounts.shift();
        console.log('n=' + n);
        var res = [];
        
        xs.slice(-n).pipe(through(write, end));
        
        function write (line, _, next) {
            res.push(String(line).trim());
            next();
        }
        
        function end () {
            t.deepEqual(res, lines.slice(-n));
            shift();
        }
    })();
});
