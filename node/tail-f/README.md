### Run the app
`npm install`

`node app.js`

### To view the log updates
In your browser go to `http://localhost:8080`

### Update log file
* The log file that is displayed is `test.log`
* To update the log file `echo "Test 30" >> test.log`

### NPM Dependencies
* Express to run the webserver
* socket.io to establish a socket connection between the client and the server
* fs to watch for file changes
* slice-file to slice a file and extract lines from a file
