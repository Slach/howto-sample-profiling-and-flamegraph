'use strict';

var tests = require('./tests');
var spawn = require('child_process').spawn;

var chromeBinary = '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome';
var chromeBootTime = 10000;
var chromeInstance;
var keepAlive = require('net').createServer().listen();

function main() {
	startChrome();
	console.log('Waiting ' + chromeBootTime / 1000 + ' seconds for Chrome to wake up...');
	
	setTimeout(function () {
		runTests().then(onComplete).catch(onError);
	}, chromeBootTime);
}

function startChrome() {
	chromeInstance = spawn(chromeBinary, ['--remote-debugging-port=9222']);
}

function runTests() {
	return tests.reduce(function (currentExecutor, nextTest) {
		return currentExecutor.then(function () {
			return nextTest.execute();
		});
	}, Promise.resolve());
}

function onComplete() {
	chromeInstance.kill();
	process.exit(0);
}

function onError(error) {
	chromeInstance.kill();
	throw error;
	process.exit(1);
}

main();