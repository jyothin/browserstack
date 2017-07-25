// 1) Count is not thread safe
// 2) How to not read all the last lines for every new line that is made available
// in the log file
// 3) On socket connection close unregister the watchFile

var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);
var fs = require('fs');
var sf = require('slice-file');

app.get('/', function (req, res) {
  res.sendFile(__dirname + '/index.html');
});

var xs = sf(__dirname + '/test.log');
var count = -10;

io.on('connection', function (socket) {
  console.log('Connection establised...');

  var stream = xs.slice(count);
  var lines = '';
  stream.on('data', function (line) {
    lines += '<p>'+line+'</p>';
  });
  stream.on('end', function () {
    //console.log(lines);
    socket.emit('message', {
      'lines': lines
    })
  });

  //fs.watchFile('test.log', function (curr, prev) {
  fs.watchFile('test.log', {'interval': 500}, function (curr, prev) {
    console.log(`${curr.mtime}`);
    console.log(`${prev.mtime}`);
    count = count - 1;;
    var stream = xs.slice(count);
    var lines = '';
    stream.on('data', function (line) {
      lines += '<p>'+line+'</p>';
    });
    stream.on('end', function () {
      //console.log(lines);
      socket.emit('message', {
        'lines':
          lines
      })
    });
  });
});

var newLineCharacter = ["\n", "\r"];
function getLines(filepath, maxLineCount) {
  var fd = fs.open(filepath, 'r');
  var chars = 0;
  var lineCount = 0;
  var lines = '';
  var stat;
  fs.stat(__dirname + '/test.log', function (err, stats) {
    console.log(stats);
    stat = stats;
  });

  if (lines.length > stats.size) {
    lines = lines.substring(lines.length - stat.size);
  }

  if (lines.length >= stat.size || lineCount >= maxLineCount) {
    if (newLineCharacters.includes(lines.substring(0, 1))) {
      lines = lines.substring(0, 1);
    }
    return lines;
  }
}

server.listen(8080);
console.log('Listening on port 8080...');
