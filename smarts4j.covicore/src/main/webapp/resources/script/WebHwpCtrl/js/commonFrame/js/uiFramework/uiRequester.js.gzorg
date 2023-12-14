define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var $ = require("jquery"),
		CommonFrameUtil = require("commonFrameJs/utils/util");

	return {
		addSubPathIfNeeded: function(urlPath) {
			var pathname = window.location.pathname,
				subPath = pathname.indexOf("webFramework") !== -1,
				isTestMode = pathname.indexOf("framework") !== -1,
				href = urlPath;

			if (isTestMode) {
				if (subPath) {
					// tomcat 서버의 경로로 tester 에 접근했을 경우 경로
					if (CommonFrameUtil.isStartsWith(href, "framework")) {
						href = "/framework/webFramework/" + urlPath.slice(10); // "framework/" 이후부터
					} else {
						href = "/framework/" + urlPath;
					}

				} else {
					// cheese cake 으로 tester 에 접근했을 경우 경로
					href = "/" + urlPath;
				}
			}

			return href;
		},

		/**
		 * xml node 요청
		 * @param {String} xmlUrl		- xml 요청 url
		 * @param {String=} customXmlName
		 * @returns {Node}
		 */
		requestXml: function (xmlUrl, customXmlName) {
			var result = null,
				url = this.addSubPathIfNeeded(xmlUrl);

			// add version
			url += "?" + (window.__hctfwoVersion || String((new Date()).getTime()));

			if (customXmlName) {
				url += ("&custom=" + customXmlName + ".xml");
			}

			$.ajax({
				url: url,
				type: "GET",
				dataType: "xml",
				async: false,
				success: function (data) {
					result = data;
				},
				error: function (xhr) {
					console.log(xhr);
				}
			});

			return result;
		},

		/**
		 * template node 요청
		 * @param {String} templateUrl	- template 요청 url
		 * @param {String} name		- html name
		 * @returns {Node}
		 */
		requestTemplate: function (templateUrl, name) {
			var result = null,
				url = this.addSubPathIfNeeded(templateUrl + name + ".html");

			// add version
			url += "?" + (window.__hctfwoVersion || String((new Date()).getTime()));

			$.ajax({
				url: url,
				type: "GET",
				dataType: "html",
				async: false,
				success: function (data) {
					result = data;
				},
				error: function (xhr) {
					console.log(xhr);
				}
			});

			return result;
		},

		/**
		 * nls resource 요청
		 * @param {String} nlsUrl		- nls 요청 url
		 * @param {String} name		- nls file name
		 * @returns {Node}
		 */
		requestNls: function (nlsUrl, name) {
			var result = null,
				obj = {},
				url = this.addSubPathIfNeeded(nlsUrl + name + ".js"),
				strResult, idx, s1, s2;

			// add version
			url += "?" + (window.__hctfwoVersion || String((new Date()).getTime()));

			$.ajax({
				url: url,
				type: "GET",
				dataType: "text",
				async: false,
				success: function (data) {
					if (data) {
						result = data.match(/define[ ]?\([ ]?\{([\s\S]*)\}/);
						strResult = result && result[1] && result[1].split("\n");

						if (strResult) {
							strResult.forEach(function(d) {
								idx = d.indexOf(":");

								if (idx > -1) {
									s1 = d.substring(0, idx).trim();
									s2 = d.substring(idx + 1, d.length - 1).trim().replace(/^"(.*[^\\])"[ ]?[,]?/g, "$1").replace(/\\"/g, '"');

									// 리소스 맨 마지막 라인이 난독화 된 상태에서 이상 현상이 일어나 예외처리 해준다. (맨 앞에 더블쿼테이션이 남아 있음.)
									if (s2 && s2.substring(0, 1) === '"') {
										if (s2.substring(1, 2) !== '"') {
											s2 = s2.substring(1);
										}

										// 더블쿼테이션 2개는 빈 스트링값으로 처리해 준다.
										if (s2 === '"",' || s2 === '""') {
											s2 = "";
										}
									}

									obj[s1] = s2;
								}
							});
						}

						result = obj;
					}
				},
				error: function (xhr) {
					console.log(xhr);
				}
			});

			return result;
		}
	};
});
