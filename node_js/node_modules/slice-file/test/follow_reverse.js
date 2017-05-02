var test = require('tap').test;
var sf = require('../');
var fs = require('fs');
var through = require('through2');

var file = __dirname + '/data/follow.txt';
var initSrc = [ 'one', 'two', 'three', 'four', 'five', 'six', '' ].join('\n');
fs.writeFileSync(file, initSrc);

test('slice a following instance', function (t) {
    t.plan(6);
    
    var xs = sf(file);
    var res = [];
    xs.follow(-3).pipe(through(function (line, _, next) {
        res.push(String(line));
        if (res.length === 3) {
            t.deepEqual(res, [ 'four\n', 'five\n', 'six\n' ]);
            fs.appendFile(file, [ 'seven', 'eight', 'nine', '' ].join('\n'));
        }
        else if (res.length === 6) {
            t.deepEqual(res, [
                'four\n', 'five\n', 'six\n',
                'seven\n', 'eight\n', 'nine\n'
            ]);
            fs.appendFile(file, [ 'ten', 'eleven' ].join('\n'));
        }
        else if (res.length === 7) {
            t.deepEqual(res, [
                'four\n', 'five\n', 'six\n',
                'seven\n', 'eight\n', 'nine\n',
                'ten\n'
            ]);
            fs.appendFile(file, '\n');
        }
        else if (res.length === 8) {
            t.deepEqual(res, [
                'four\n', 'five\n', 'six\n',
                'seven\n', 'eight\n', 'nine\n',
                'ten\n', 'eleven\n'
            ]);
            
            xs.sliceReverse(0, 3, function (err, lines) {
                t.deepEqual(
                    lines.map(String),
                    [ 'three\n', 'two\n', 'one\n' ]
                );
                xs.sliceReverse(-3, function (err, lines) {
                    t.deepEqual(
                        lines.map(String),
                        [ 'eleven\n', 'ten\n', 'nine\n' ]
                    );
                    xs.close();
                })
                xs.close();
            })
        }
        next();
    }));
});
