var test = require('tap').test;
var lf = require('../');
var through = require('through2');
var fs = require('fs');
var wordFile = __dirname + '/data/words';

test('implicit start=0', function (t) {
    t.plan(1);
    
    var file = __dirname + '/data/lines.txt';
    var s = lf(file).sliceReverse();
    var res = [];
    s.pipe(through(write, end));
    function write (buf, _, next) { res.push(String(buf)); next() }
    function end () {
        t.deepEqual(res, [
            "\n",
            "six\n",
            "five\n",
            "\n",
            "three\n",
            "two\n",
            "\n"
        ]);
    }
});

test('first ten', function (t) {
    t.plan(11);
    
    var xs = lf(wordFile);
    var res = [];
    
    xs.sliceReverse(0,10).pipe(through(write, end));
    
    function write (line, _, next) {
        t.ok(Buffer.isBuffer(line));
        res.push(String(line));
        next();
    }
    
    function end () {
        t.deepEqual(res, [
            "AM's\n",
            "AIDS's\n",
            "AI's\n",
            "ACTH's\n",
            "AC's\n",
            "ABM's\n",
            "AB's\n",
            "AA's\n",
            "A's\n",
            "A\n"
        ]);
    }
});

test('slices', function (t) {
    var lines = fs.readFileSync(wordFile, 'utf8').split('\n');
    lines.pop();
    
    var xs = lf(wordFile);
    
    var slices = [
        [ 10, 20 ],
        [ 100, 150 ],
        [ 2000, 4000 ],
        [ 3000, 3100 ],
        [ 240, 245 ],
        [ 500, 580 ],
        [ 2200, 2400 ],
        [ 2200, 2400 ],
        [ 10200, 10240 ],
        [ -500 ],
        [ -3000, -50 ],
        [ -8000, -5000 ],
        [ -5, 0 ],
        [ -50000 ],
        [ 70000 ]
    ];
    t.plan(slices.length);
    
    (function shift () {
        if (slices.length === 0) return;
        var n = slices.shift();
        var res = [];
        
        xs.sliceReverse(n[0], n[1]).pipe(through(write, end));
        
        function write (line, _, next) {
            res.push(String(line).trim());
            next();
        }
        
        function end () {
            t.deepEqual(res, lines.slice(n[0], n[1]).reverse());
            shift();
        }
    })();
});
