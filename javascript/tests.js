'use strict';

var chrome = require('./chrome');

module.exports = [
	{
		name: 'BITRIX_SETUP',
		url: 'http://demo.bitrix.local/index.php',
		execute: function bitrix_setup() {
			return chrome.startCapture(this)
				.then(function () {
					return chrome.evaluate(function () {
						document.body.style.background = 'blue';
						console.log('Hi!');
					});
				}).then(function () {
					return chrome.evaluate(function () {
						document.body.style.background = 'red';
						console.log('Hi 2!');
					});
				});
		}
	}
];