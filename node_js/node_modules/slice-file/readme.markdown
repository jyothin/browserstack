# slice-file

stream file slices by line number indexes

[![build status](https://secure.travis-ci.org/substack/slice-file.png)](http://travis-ci.org/substack/slice-file)

# example

## positive slice

``` js
var sf = require('slice-file');
var words = sf('/usr/share/dict/words');
words.slice(22398,22408).pipe(process.stdout);
```

```
beep
beep's
beeped
beeper
beeper's
beepers
beeping
beeps
beer
beer's
```

## tail

``` js
var sf = require('slice-file');
var xs = sf('/usr/share/dict/words');
xs.slice(-10).pipe(process.stdout);
```

```
élan's
émigré
émigré's
émigrés
épée
épée's
épées
étude
étude's
études
```

# follow

Like `tail -f`, slice-file can stream updates after the initial slice.

```
var sf = require('slice-file');
var xs = sf('/var/mail/' + process.env.USER);
xs.follow(-10).pipe(process.stdout);
```

at first the previous 10 lines will render:

```
$ node example/mail.js 
    id A2181740063; Fri, 12 Apr 2013 03:08:30 -0700 (PDT)
Subject: beep boop
To: <substack@beep>
X-Mailer: mail (GNU Mailutils 2.2)
Message-Id: <20130412100830.A2181740063@beep>
Date: Fri, 12 Apr 2013 03:08:30 -0700 (PDT)
From: substack@beep

oh hello


```

then if a message is sent:

```
$ echo ahoy thar | mail -s 'oy' substack
```

we see more data from the file:

```
From substack@beep  Fri Apr 12 03:09:13 2013
Return-Path: <substack@beep>
X-Original-To: substack@beep
Delivered-To: substack@beep
Received: by beep (Postfix, from userid 1000)
    id 5E0C7740063; Fri, 12 Apr 2013 03:09:13 -0700 (PDT)
Subject: oy
To: <substack@beep>
X-Mailer: mail (GNU Mailutils 2.2)
Message-Id: <20130412100913.5E0C7740063@beep>
Date: Fri, 12 Apr 2013 03:09:13 -0700 (PDT)
From: substack@beep

ahoy thar

```

# reverse

You can also slice in reverse order, which is more efficient for
negative-indexed slices because the lines don't need to be buffered:

``` js
var sf = require('slice-file');
var xs = sf('/usr/share/dict/words');
xs.sliceReverse(-10).pipe(process.stdout);
```

```
événements
événement
évolués
évolué
étuis
étui's
étui
études
étude's
étude
```

# methods

``` js
var sf = require('slice-file')
```

## var xs = sf(filename, opts={})

Create a slice-file instance `xs` from a `filename` and some options `opts`.

These `opts` are passed to `fs.open()`:

* `opts.flags` - string flags to open the file with, default `"r"`
* `opts.mode` - mask to open the file with, default `0666`

If you already have a file descriptor open you can pass `opts.fd` to skip
calling `fs.open()`.

Use `opts.bufsize` to set how much data to read in each chunk. Default 4096.

## var stream = xs.slice(i, j, cb)

Return a readable stream that emits each line between line numbers `[i,j)`
exactly like `Array.prototype.slice()`. Each line data buffer includes a
trailing `"\n"` except for the last line if there is no trailing newline before
the EOF.

Just like `Array.prototype.slice()`, `i` and `j` may be negative.

If `cb(err, lines)` is given, the lines will be buffered into `lines`.

## var stream = xs.sliceReverse(i, j, cb)

Return a readable stream that emits each line between line numbers `[i,j)`
just like `.slice()` but in reverse order. This is more efficient for
negative-indexed slices because the lines don't need to be buffered.

If `cb(err, lines)` is given, the lines will be buffered into `lines`.

## var stream = xs.follow(i, j)

Return a readable stream of lines like `xs.slice()`, but instead of ending when
the end of the file is reached, watch the file and stream new lines appended to
the end of the file.

This feature takes its name from `tail -f`.

## xs.close()

Close the underlying file descriptor, stop any streams, and stop any file
watchers.

# install

With [npm](https://npmjs.org) do:


```
npm install slice-file
```

# license

MIT
