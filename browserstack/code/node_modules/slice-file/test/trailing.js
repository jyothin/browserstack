var test = require('tap').test;
var lf = require('../');

test('positive index trailing', function (t) {
    t.plan(1);
    var file = __dirname + '/data/trailing.txt';
    
    lf(file).slice(1, function (err, lines) {
        if (err) t.fail(err);
        t.deepEqual(lines.map(String), [
            'two\n', 'three'
        ]);
    });
});

test('negative index trailing', function (t) {
    t.plan(1);
    var file = __dirname + '/data/trailing.txt';
    
    lf(file).slice(-2, function (err, lines) {
        if (err) t.fail(err);
        t.deepEqual(lines.map(String), [
            'two\n', 'three'
        ]);
    });
});
