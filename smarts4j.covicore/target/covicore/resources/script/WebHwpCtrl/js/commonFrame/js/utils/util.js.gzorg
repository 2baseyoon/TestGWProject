define([
    'jquery'
], function ($){
    //TF lib util 확장

    // 각 브라우저에서 제공하는 selector 확인 함수 할당
    var matchesFunc = (document.documentElement) ? (document.documentElement.matchesSelector
        || document.documentElement.mozMatchesSelector || document.documentElement.webkitMatchesSelector
        || document.documentElement.oMatchesSelector || document.documentElement.msMatchesSelector) : null
        ,	MOVE_KEY_CODE_ARR = [37, 38, 39, 40];

    return {
        /**
         * Top Offset 위치정보..
         * @param {Element} ele			- 대상 노드
         * @param {Element} limit			- 상위 제한(Break) 노드
         * @returns {Number}
         */
        getOffsetTop : function(ele, limit) {
            var offTop = ele.offsetTop
                ,	offParent = ele.offsetParent;

            while (offParent && offParent !== limit) {
                offTop += offParent.offsetTop;
                offParent = offParent.offsetParent;
            }

            return offTop;
        },

        /**
         * Left Offset 위치정보..
         * @param {Element} ele			- 대상 노드
         * @param {Element} limit			- 상위 제한(Break) 노드
         * @returns {Number}
         */
        getOffsetLeft : function(ele, limit) {
            var offLeft = ele.offsetLeft
                ,	offParent = ele.offsetParent;

            while (offParent && offParent !== limit) {
                offLeft += offParent.offsetLeft;
                offParent = offParent.offsetParent;
            }

            return offLeft;
        },

        /**
         * 대상 Element 의 실제 크기(Scroll 크기 기준)를 반환
         * @param {Element=} ele		- Node 객체(기본값 : document)
         * @return {Object}			- Scroll Size(x, y)
         */
        getScrollSize : function(ele) {
            if (ele === undefined || !ele) {
                ele = document;
            }

            var isDocument = (/[\#]?document$/i.test(ele.nodeName))
                ,	scWidth = 0
                ,	scHeight = 0;

            if (isDocument === true) {
                var cMode = (ele.compatMode === "CSS1Compat");
                scWidth = (cMode === true) ? ele.documentElement.scrollWidth : ele.body.scrollWidth || 0;
                scHeight = (cMode === true) ? ele.documentElement.scrollHeight : ele.body.scrollHeight || 0;
            } else {
                scWidth = ele.scrollWidth || 0;
                scHeight = ele.scrollHeight || 0;
            }

            return {"x" : scWidth, "y" : scHeight};
        },

        /**
         * 현재 Window 의 Full Size 를 반환(스크롤 포함)
         * @returns {{width: *, height: *}}
         */
        getWindowFullSize : function() {
            var curScrollSize = this.getScrollSize()
                ,	$win = $(window)
                ,	curScreenSize = {'width' : $win.width(), 'height' : $win.height()};

            return {
                'width' : (curScrollSize.width > curScreenSize.width) ? curScrollSize.width : curScreenSize.width,
                'height' : (curScrollSize.height > curScreenSize.height) ? curScrollSize.height : curScreenSize.height
            };
        },

        /**
         *	CurrentStyle 정보 가져오기
         *	@param {Element} node		- 대상 노드
         *	@param {string} istyle		- CSS 프로퍼티 Script Syntax(ex : backgroundColor)
         */
        getCurrentStyle : function(node, istyle) {
            var doc = window.document
                ,	curStyle = null;

            if (!(node && istyle)) {
                return null;
            }

            // 불필요한 try-catch문 제거
            //try {
            if (window.getComputedStyle) {
                var computedStyle = doc.defaultView.getComputedStyle(node, null);
                curStyle = computedStyle[istyle];
            } else if (node.currentStyle) {
                curStyle = node.currentStyle[istyle];
            } else {
                curStyle = node.style[istyle];
            }
            //} catch(exp) {
            //	console.warn(exp);
            //}

            return curStyle;
        },

        /**
         * 지정한 CSS3 속성의 스타일 값을 구하여 반환.
         * box-reflect와 같이 브라우저가 지원하지 않는 CSS3 Style은 직접 값을 구하고, 지원하는 브라우저는 Style 값을 가져온다.
         * @param {Element} node					- 대상 노드
         * @param {String} istyle					- CSS 프로퍼티 CSS Syntax(ex : box-reflect)
         * @param {Boolean=} useComputedStyle		- 상속된 스타일까지 체크할지 여부
         * @returns {String}						- CSS 값
         */
        getCss3Style : function(node, istyle, useComputedStyle) {
            if (!(node && node.nodeType === 1 && istyle)) {
                return "";
            }

            var sVal = (useComputedStyle === true) ? this.getCurrentStyle(node, istyle) : node.style[istyle]
                ,	strTag = ""
                ,	arrTag = null
                ,	match = null;

            // 노드의 outerHTML(노드를 포함한 html)을 가져온다.
            var getOuterHTML = function(target) {
                var html = ""
                    ,	divTempWrap;

                if (target.outerHTML) {
                    html = target.outerHTML;
                } else {
                    if (target.parentNode) {
                        html = target.parentNode.innerHTML;
                    } else {
                        divTempWrap = document.createElement("div");

                        divTempWrap.appendChild(target.cloneNode(false));
                        if (divTempWrap.innerHTML) {
                            html = divTempWrap.innerHTML;
                        }
                    }
                }

                return html;
            };

            // style 값이 undefined면 해당 CSS를 지원하고 있지 않은것이기에, 직접 HTML을 파싱해서 값을 구한다.
            if (sVal === undefined) {
                strTag = getOuterHTML(node);
                arrTag = strTag ? strTag.split(">") : null;

                if (!(arrTag && arrTag.length)) {
                    return "";
                }

                match = /box-reflect[\s]?\:[^;]*;/.exec(arrTag[0]);

                if (match) {
                    sVal = match[0].replace(";", "");
                } else {
                    sVal = "";
                }
            }

            return sVal;
        },

        /**
         *	style(css) 프로퍼티 개별 삭제
         *	@param {Element} node		- 대상 노드
         *	@param {string} cssName	- CSS 프로퍼티명(ex : background-color)
         */
        removeStyleProperty : function(node, cssName) {
            if (!(node && cssName)) {
                return;
            }

            var scriptName = cssName;

            try {
                if (node.style.removeProperty) {
                    node.style.removeProperty(cssName);
                } else {
                    if (scriptName.indexOf("-") != -1) {
                        var scriptAttr = scriptName.split("-")
                            ,	len = scriptAttr.length
                            ,	i;
                        scriptName = "";

                        for (i = 0; i < len; i++) {
                            scriptName += (i == 0) ? scriptAttr[i] : this.getUCFirst(scriptAttr[i]);
                        }
                    }

                    node.style.removeAttribute(scriptName);
                }
            } catch(exp) {
                console.warn(exp);
            }
        },

        /**
         * style 값이 기본값 등으로 나오면, 숫자 값으로 변경해서 반환한다. (현재는 initial 만 체크)
         * @param {String} sName		- 스타일 이름
         * @param {String} sVal		- 스타일 값 (스타일에서 추출한 String 값)
         * @returns {*}
         */
        getValidStyleVal : function(sName, sVal) {
            var validVal = sVal;

            if (!sName || typeof sName !== "string") {
                return validVal;
            }

            if (sVal && sVal === "initial") {
                if (sName.indexOf("padding") !== -1
                    || sName.indexOf("margin") !== -1
                    || sName.indexOf("border") !== -1
                    || sName === "text-indent") {
                    validVal = "0px";
                }
            }

            return validVal;
        },

        /**
         * DOM 생성 함수
         * @param {String} elementName                 : element 명
         * @param {Object=} propObj                     : properties {name: value}
         * @param {Object=} attrObj                     : 세팅할 attribute 정보
         * @returns {Object}
         */
        createDomEl : function(elementName, propObj, attrObj) {
            if (!elementName) {
                console.error("[Error] Invalid parameter.");

                return null;
            }

            var domEl, key;

            domEl = document.createElement(elementName);

            for (key in propObj) {
                if (propObj[key]) {
                    domEl[key] = propObj[key];
                }
            }

            for (key in attrObj) {
                if (attrObj[key]) {
                    domEl.setAttribute(key, attrObj[key]);
                }
            }

            return domEl;
        },

        /**
         * 지정한 부모 노드로 자식들을 append 하는 함수
         * @param {Object} parentNode                  : 부모노드
         * @param {Array|Object} childNodes            : 부모노드에 append 할 자식노드
         *                                                (여러 개일 경우 자식노드들의 배열)
         * @returns {Object}
         */
        appendChildNode : function (parentNode, childNodes) {
            var isArray = childNodes && childNodes.constructor === Array,
                len, i;

            if (parentNode == null || (!isArray && childNodes == null) || isArray && childNodes.length < 1) {
                console.error("Error: Invalid parameter.");
                return null;
            }

            if (isArray) {
                len = childNodes.length;

                for (i = 0; i < len; ++i) {
                    parentNode.appendChild(childNodes[i]);
                }
            } else {
                parentNode.appendChild(childNodes);
            }

            return parentNode;
        },

        /**
         * 불완전한 URL에 SessionStorage에 저장해 놓은 나머지 parameter들을 GET 방식으로 추가
         * @param {String=} url
         * @returns {*|string}
         */
        addParameterToUrl : function(url) {
            var attachedUrl = url || document.location.href,
                sessSto, keys, key, i, len;

            /**
             * 브라우저 보안 옵션에 따라 localStorage, sessionStorage 를 선언 하는 것만으로 에러가 발생할 수 있다.
             * 따라서 sessionStorage 선언은 try catch 문으로 에러 없이 진행 될 수 있도록 처리한다.
             * 참고 링크 : https://wiki.hancom.com:8443/pages/viewpage.action?pageId=15609400
             */
            try {
                sessSto = window.sessionStorage;
            } catch (excep) {
                sessSto = null;
                console.log("Unable to get sessionStorage", excep);
            }

            if (sessSto) {
                keys = window.Object.keys(sessSto);
                len = keys.length;

                for (i = 0; i < len; i++) {
                    key = keys[i];

                    if (key && key !== "smb_app" && key !== "skin") {
                        attachedUrl = attachedUrl + "&" + key + "=" + sessSto.getItem(key);
                    }
                }
            }

            return attachedUrl;
        },

        /**
         * 지정한 노드의 HTML 을 반환
         * @param {Element} ele			- 대상 노드
         * @returns {string}
         */
        getDocumentHTML : function(ele) {
            var docHTML = "";
            if ($.browser.mozilla) {
                docHTML = (new window.XMLSerializer()).serializeToString(ele);
            } else {
                docHTML = ele.documentElement.outerHTML;
            }

            return docHTML;
        },

        /**
         * Document에 HTML String 적용
         * @param {Element} ele			- 대상 노드
         * @param {String} html
         */
        setDocumentHTML : function(ele, html) {
            try {
                ele.open();
                ele.write(html);
                ele.close();
            } catch(exp) {
                console.warn(exp);
            }
        },

        /**
         * HTML 꺽쇠 기호 엔코드
         * @param {String} data
         * @returns {*}
         */
        setHTMLEncode : function(data) {
            if (!data) {
                return "";
            }

            var reData = data;
            reData = reData.replace(/&/g, "&amp;");
            reData = reData.replace(/</g, "&lt;");
            reData = reData.replace(/>/g, "&gt;");

            return reData;
        },

        /**
         * HTML 꺽쇠 기호 디코드
         * @param {String} data
         * @returns {*}
         */
        setHTMLDecode : function(data) {
            if (!data) {
                return "";
            }

            var reData = data;
            reData = reData.replace(/&gt;/g, ">");
            reData = reData.replace(/&lt;/g, "<");
            reData = reData.replace(/&amp;/g, "&");

            return reData;
        },

        /**
         * 파일 경로를 파싱하여 파일 이름 정보(이름, 확장자, 경로) 리턴 (HTML5 Lower)
         * @param {String} path			- 파일 경로
         * @returns {{fileName: string, fileExt: string, filePath: string}}
         */
        getFileName : function(path) {
            var fileName = ""
                ,	fileExt = ""
                ,	filePath = ""
                ,	isWindows = (navigator.userAgent.toLowerCase().indexOf("windows") !== -1)
                ,	separator = isWindows ? "\\" : "/";

            if (!isWindows && /fakepath/i.test(path) && /\\/.test(path)) {
                separator = "\\";
            }
            if (separator == "\\" && path.indexOf(separator) == -1 && path.indexOf("/") != -1) {
                separator = "/";
            }

            try {
                var arrFileName = path.split(separator)
                    ,	fullName = arrFileName[arrFileName.length - 1];

                filePath = path.substring(0, path.lastIndexOf(separator));
                fileName = fullName.substring(0, fullName.lastIndexOf("."));
                fileExt = fullName.substring(fullName.lastIndexOf(".") + 1);
            } catch(exp) {
                console.warn(exp);
            }

            return {
                "fileName" : fileName,
                "fileExt" : fileExt,
                "filePath" : filePath
            };
        },

        /**
         * 개체 파일 정보(이름, 확장자, 타입)를 리턴 (HTML5 Higher)
         * @param {Element} node			- 개체 파일 노드
         * @returns {*}
         */
        getFileInfo : function(node) {
            var $fileNode = $(node);
            if (!$fileNode.length) {
                return null;
            }

            var sFiles = $fileNode.get(0).files
                ,	info = {}
                ,	keys = ["name", "size", "type", "lastModifiedDate", "mainType", "subType"];

            if (sFiles && sFiles.length > 0) {
                var file = sFiles[0]
                    ,	keyLen = keys.length
                    ,	i;

                if (file) {
                    for (i = 0; i < keyLen; i++) {
                        if (file[keys[i]]) {
                            info[keys[i]] = file[keys[i]];
                        }
                    }
                }

                if (info['type']) {
                    var typeArr = info['type'].split("/");
                    if (typeArr[0]) {
                        info['mainType'] = typeArr[0];
                    }

                    if (typeArr[1]) {
                        info['subType'] = typeArr[1];
                    }
                } else {
                    if (file.name) {
                        var fileInfo = this.getFileName(file.name)
                            ,	fileExt = fileInfo.fileExt;

                        if (fileExt) {
                            fileExt = fileExt.toLocaleLowerCase();
                        }

                        if (fileExt == "mkv") {
                            info['mainType'] = "video";
                            info['subType'] = fileExt;
                            info['type'] = "video/x-mpeg";
                        } else if (fileExt == "wmf" || fileExt == "emf") {
                            info['mainType'] = "image";
                            info['subType'] = fileExt;
                            info['type'] = "image/x-" + fileExt;
                        }
                    }
                }
            } else {
                var filePath = $fileNode.val()
                    ,	fileParse = null;

                if (filePath) {
                    fileParse = this.getFileName(filePath);
                    if (fileParse) {
                        var fileType = fileParse.fileExt;
                        if (/(jpg|jpeg|gif|png|bmp)/i.test(fileType)) {
                            fileType = "image";
                        }

                        info['name'] = fileParse.fileName;
                        info['type'] = fileType + "/" + fileParse.fileExt;
                        info['mainType'] = fileType;
                        info['subType'] = fileParse.fileExt;
                    }
                }
            }

            return info;
        },

        /**
         *	파일 사이즈 가장 높은 단위로 전환하여 반환
         *	@param {number} filesize	- 실제파일 사이즈(단위 : byte)
         *	@param {number=} digit		- 소숫점 자리수
         */
        getFileSizeTransLate : function (filesize, digit) {
            if (!filesize || isNaN(filesize)) {
                return 0;
            }
            if (!digit) {
                digit = 0;
            }

            var transSize = 0
                ,	sizeUnit = {
                'YB' : 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024,
                'ZB' : 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024,
                'EB' : 1024 * 1024 * 1024 * 1024 * 1024 * 1024,
                'PB' : 1024 * 1024 * 1024 * 1024 * 1024,
                'TB' : 1024 * 1024 * 1024 * 1024,
                'GB' : 1024 * 1024 * 1024,
                'MB' : 1024 * 1024,
                'KB' : 1024
            }
                ,	precision = Math.pow(10, digit)
                ,	key
                ,	item;

            if (filesize <= 1024) {
                transSize = filesize + " Bytes";
            } else {
                for (key in sizeUnit) {
                    if (sizeUnit.hasOwnProperty(key)) {
                        item = sizeUnit[key];

                        if (filesize >= item) {
                            transSize = Math.round(filesize * precision / item) / precision + " " + key;
                            break;
                        }
                    }
                }
            }

            return String(transSize);
        },

        /**
         * 지정한 길이만큼 Zero숫자(0) 채워서 반환
         * @param {(Number|String)} value			- 대상 숫자
         * @param {Number} length					- 숫자 길이
         * @returns {String}
         */
        getFillZero : function(value, length) {
            if (value === undefined) {
                return null;
            }

            if (!length || isNaN(value)) {
                return value;
            }

            var result = String(value)
                ,	i;

            for (i = result.length; i < length; i++) {
                result = "0" + result;
            }

            return result;
        },

        /**
         * String 첫글자 대문자로 변환하여 리턴
         * @param {String} str			- 대상 문자열
         * @returns {String}
         */
        getUCFirst : function(str) {
            if (!str) {
                return "";
            }

            return str.substring(0, 1).toUpperCase() + str.substring(1);
        },

        /**
         * String 각 단어의 첫글자 대문자로 변환하여 리턴
         * @param {String} str			- 대상 문자열
         * @returns {string}
         */
        getUCWordsFirst : function(str) {
            if (!str) {
                return "";
            }

            var words = str.split(/ |-/g)
                ,	wordsLen = words.length
                ,	curWord = null
                ,	splitChar = null
                ,	curIdx = 0
                ,	resultStr = ""
                ,	i;

            for (i = 0; i < wordsLen; i++) {
                curWord = words[i];
                resultStr += this.getUCFirst(curWord);
                curIdx += curWord.length;

                splitChar = str.charAt(curIdx);
                if (splitChar) {
                    resultStr += splitChar;
                    curIdx++;
                }
            }

            return resultStr;
        },

        /**
         *	데이트값의 차이 구하기
         *	@param {(String|Object)} sDate			- 시작데이트 (문자열 시간|Date Obejct)
         *	@param {(String|Object)} eDate			- 끝데이트 (문자열 시간|Date Obejct)
         *	@param {String=} cmd					- 리턴 단위(d/h/m/s)
         *	@param {boolean=} isSumTimeOfDay		- 일(d) 단위시 시간값 계산 여부)
         */
        getDateDiff : function(sDate, eDate, cmd, isSumTimeOfDay) {
            var isValid = false
                ,	diff = 0
                ,	cVal = 0;

            if (!(sDate && eDate)) {
                return diff;
            }

            if (!cmd) {
                cmd = "d";
            }

            if (isSumTimeOfDay === undefined) {
                isSumTimeOfDay = true;
            }

            var setClearTime = function(targetDate) {
                targetDate.setHours(0);
                targetDate.setMinutes(0);
                targetDate.setSeconds(0);
                targetDate.setMilliseconds(0);
            };

            if (typeof sDate === "string" && typeof eDate === "string") {
                var sArr = sDate.split("-")
                    ,	eArr = eDate.split("-");

                if (sArr.length == 3 && eArr.length == 3) {
                    isValid = true;
                    sDate = new Date(sArr[0], parseInt(sArr[1], 10) - 1, sArr[2]);
                    eDate = new Date(eArr[0], parseInt(eArr[1], 10) - 1, eArr[2]);
                }
            } else if (typeof sDate === "object" && typeof eDate === "object") {
                if (sDate.getDate && eDate.getDate) {
                    isValid = true;
                }

                if (isValid && isSumTimeOfDay === false) {
                    setClearTime(sDate);
                    setClearTime(eDate);
                }
            }

            if (isValid) {
                switch (cmd) {
                    case "d" :	// Day
                        cVal = (1000 * 60 * 60 * 24);
                        break;
                    case "h" :	// Hour
                        cVal = (1000 * 60 * 60);
                        break;
                    case "m" :	// Minute
                        cVal = (1000 * 60);
                        break;
                    case "s" :	// Second
                        cVal = 1000;
                        break;
                }

                if (cVal > 0) {
                    diff = Math.ceil((eDate.getTime() - sDate.getTime()) / cVal);
                }
            }

            return diff;
        },

        /**
         * 브라우저 나라(언어) 코드 리턴
         * @param {String} dLanguage			- 디폴트로 사용될 언어코드(Full Code)
         * @returns {{shortCode: string, fullCode: string}}
         */
        getBrowserLanguage : function(dLanguage) {
            var fCode = ""
                ,	sCode = "";

            if (navigator.userLanguage) {
                fCode = navigator.userLanguage;
            } else if (navigator.language) {
                fCode = navigator.language;
            } else {
                fCode = dLanguage;
            }

            if (fCode) {
                fCode = fCode.toLowerCase();
            }

            if (fCode.length >= 2) {
                sCode = fCode.substring(0, 2);
            }
            if (sCode === "") {
                sCode = dLanguage;
            }

            return {
                "shortCode" : sCode,
                "fullCode" : fCode
            };
        },

        /**
         * 디바이스 정보 리턴
         * @returns {{isMobile: boolean, isAndroid: boolean, isIos: boolean, isIphone: boolean
		 * 			 , isIpad: boolean, isChrome: boolean, IsMac: boolean, IsLinux: boolean}}
         */
        getBrowserDevice : function() {
            var uat = navigator.userAgent.toLowerCase();

            return {
                isWindows : /(windows)/i.test(uat),
                isMobile : /(mobile|android|ipad|iphone)/i.test(uat),
                isAndroid : /(android)/i.test(uat),
                isIos : /(ipad|iphone|ipot)/i.test(uat),
                isIphone : /(iphone)/i.test(uat),
                isIpad : /(ipad)/i.test(uat),
                isChrome : /(chrome|crios)/i.test(uat),
                IsMac  : /macintosh/.test(uat),
                IsLinux  : /linux/.test(uat),
                isTizen  : /tizen/.test(uat)
            };
        },

        /**
         * 윈도우 시스템 BIT 정보 반환. (윈도우 시스템이 아니면 빈스트링 반환됨.)
         * @returns {String}		- 64bit or 32bit or ""
         */
        getWindowsSystemBit : function() {
            var uat = navigator.userAgent.toLowerCase()
                ,	winSysBit = "";

            if (uat.indexOf("windows") !== -1) {
                if (uat.indexOf("wow64") !== -1 || uat.indexOf("win64") !== -1) {
                    winSysBit = "64bit";
                } else {
                    winSysBit = "32bit";
                }
            }

            return winSysBit;
        },

        /**
         * 지원하는 마우스/터치 이벤트 이름을 리턴
         * @returns {{down: string, up: string, move: string}}
         */
        getMouseEventName : function() {
            var supportTouch = this.getBrowserDevice().isMobile;

            return {
                "down" : supportTouch ? "touchstart" : "mousedown",
                "up" : supportTouch ? "touchend" : "mouseup",
                "move" : supportTouch ? "touchmove" : "mousemove"
            };
        },

        /**
         *	상위 엘리먼트 찾기(태그 이름으로 찾기)
         *	@param {Node} node					- 대상노드
         *	@param {(String|Array)} tag		- 태그이름(string) or 태그이름배열(array)
         */
        findParentTagNode : function(node, tag) {
            var arrFlag = false
                ,	tagType = typeof tag
                ,	i;

            if (tagType === "object" && tag.length > 0) {
                for (i = 0; i < tag.length; i++) {
                    if (typeof tag[i] === "string") {
                        tag[i] = tag[i].toUpperCase();
                    }
                }

                arrFlag = true;
            } else if (tagType === "string") {
                if (tag) {
                    tag = tag.toUpperCase();
                }
            } else {
                tag = "";
            }

            if (arrFlag) {
                while (node && $.inArray(node.nodeName, tag) === -1) {
                    node = node.parentNode;
                }
            } else {
                while (node && node.nodeName !== tag) {
                    node = node.parentNode;
                }
            }

            return node;
        },

        /**
         * 지정한 노드가 query selector 가 가르키는 것과 일치 하는지 여부 반환.
         * @param {Element} node			- 대상 노드
         * @param {*} selector				- 쿼리 셀렉터 (노드, 쿼리 스트링 등)
         * @returns {*}
         */
        matches : function (node, selector) {
            if (!(node && node.nodeType == Node.ELEMENT_NODE)) {
                return false;
            }

            // 성능 개선을 위해 jQuery is 대신 native 직접 호출 (없다고 판단되는 경우 jQuery.is 호출)
            return matchesFunc? matchesFunc.call(node, selector) : $(node).is(selector);
        },

        /**
         *	상위 엘리먼트 찾기(Selector 로 찾기)
         *	@param {Node} node							- 대상노드
         *	@param {(String|Object)} selector			- jQuery Selector or jQuery Object
         *	@param {Node=} limit						- 도달노드(상위로 탐색하면서 도달노드에 도착하면 탐색 중단)
         *	@returns {Node}
         */
        findParentNode : function(node, selector, limit) {
            if (!node) {
                return null;
            }
            if (node.nodeType === 3) {
                node = node.parentNode;
            }
            if (limit && !(limit instanceof Node)) {
                // jQuery Selector 로 인정
                limit = $(limit).get(0);
            }

            try {
                while (node && !this.matches(node, selector) && node != limit) {
                    node = node.parentNode;
                }

                if (limit && limit == node) {
                    node = null;
                }
            } catch(ex) {
                node = null;
            }

            return node;
        },

        /**
         *	하위 엘리먼트 찾기
         *	@param {Node} targetNode							- 대상 노드
         *	@param {string=} pos								- 찾는 위치
         *		=> "first"	: 시작점 부터 찾기
         *		=> "last"	: 끝점 부터 찾기
         *	@param {(string|Object|function)=} filter			- 필터(jQuery Selector or jQuery Object or Function)
         *	@param {(string|Object|function)=} excludeFilter	- 제외 필터(jQuery Selector or jQuery Object or Function)
         *	@returns {Node}
         */
        findChildNode : function(targetNode, pos, filter, excludeFilter) {
            var isFind = false
                ,	breakFlag = false
                ,	childnode = null
                ,	checkFunc = filter
                ,	excludeFunc = excludeFilter
                ,	cNode;

            targetNode = $(targetNode).get(0);

            if (!targetNode || !targetNode.hasChildNodes()) {
                return null;
            }
            if (pos === undefined) {
                pos = "first";
            }

            if (typeof checkFunc !== "function") {
                checkFunc = function(node) {
                    if (typeof filter === "string") {
                        return $(node).is(filter);
                    }

                    return true;
                };
            }
            if (typeof excludeFunc !== "function") {
                excludeFunc = function(node) {
                    if (typeof excludeFilter === "string") {
                        return $(node).is(excludeFilter);
                    }

                    return false;
                };
            }

            cNode = (pos === "last") ? targetNode.lastChild : targetNode.firstChild;

            function execFindNode(nodes) {
                var n
                    ,	nLen = nodes.length
                    ,	fNode;

                if (nLen > 0) {
                    for (n = 0; n < nLen; n++) {
                        if (breakFlag) {
                            return;
                        }

                        fNode = nodes[n];

                        if (!excludeFunc(fNode)) {
                            if (checkFunc(fNode)
                                && !(fNode.nodeType == 3 && fNode.nodeValue.replace(/(?:\n|\t|\r)/g, '') === "")) {
                                childnode = fNode;

                                if (pos === "first") {
                                    breakFlag = true;
                                    break;
                                }
                            }

                            if (fNode.childNodes.length > 0) {
                                execFindNode(fNode.childNodes);
                            }
                        }
                    }
                }
            }

            while (!isFind) {
                execFindNode([cNode]);
                cNode = (pos === "last") ? cNode.previousSibling : cNode.nextSibling;

                if (!cNode || childnode) {
                    isFind = true;
                }
            }

            return childnode;
        },

        /**
         * 해당 node child 중에 className 을 class 로 포함한 node return (첫번째)
         * @param {Array} nodeArray
         * @param {String} className
         * @returns {Element}
         * @author <a href="mailto:igkang@hancom.com">강인구</a>
         */
        filterOneByClassName : function(nodeArray, className) {
            var foundNode = null
                ,	curNode
                ,	length
                ,	i = 0;

            if (nodeArray) {
                length = nodeArray.length;

                while (!foundNode && i < length) {
                    curNode = nodeArray[i];
                    if (this.hasClass(curNode, className)) {
                        foundNode = curNode;
                    }

                    i++;
                }
            }

            return foundNode;
        },

        /**
         *	findPrevNode, findNextNode. GT Park, 2013-09-02.
         *	find Prev/Next Node 는 HTML DOM Tree 를 1차원으로 바라보고(Dimension Reduction) 순회하는 Tree Traversal Algorithm 이다.
         *	DOM Tree를 1차원으로 바라보고 순회하는 경우, 탐색 순서는 아래의 예와 같다.
         *
         * 	-HTML
         * 		-BODY
         * 			-H1
         * 				-TEXT1
         * 			-P
         * 				-TEXT2 *
         * 			-DIV
         * 				-LI
         * 					-IMG
         * 			-TABLE
         *
         *	TEXT2를 기준으로 Prev 탐색을 연속 수행할 경우 : P 	- TEXT1 - H1 	- BODY 		- HTML 을 반환
         *	TEXT2를 기즌오르 Next 탐색을 연속 수행할 경우 : DIV 	- LI	- IMG	- TABLE 을 반환
         *
         *	Parameter 를 통해 Selector 를 활용한 탐색도 가능하다.
         *	@param {Node} node					- 대상 노드
         *	@param {*} selector				- 쿼리 셀렉터 (노드, 쿼리 스트링 등)
         *	@param {Node} breakpoint			- 제한(Break) 노드
         *	@returns {Node}
         */
        findPrevNode : function(node, selector, breakpoint) {
            var nodePtr = node;
            //,	offset = 0;

            var _findPrevNode = function (node) {
                if (!node) { return null; }

                var prevNode = node.previousSibling;
                while (prevNode && prevNode.lastChild) {
                    prevNode = prevNode.lastChild;
                }

                if (prevNode) {
                    return prevNode;
                }

                return node.parentNode;	// null or parent
            };

            while (nodePtr && !$(nodePtr = _findPrevNode(nodePtr)).is(selector) && nodePtr != breakpoint) {
                /*if (nodePtr.nodeType == 3) {
                 offset += nodePtr.nodeValue.length;
                 } else {
                 offset += 1;
                 }*/
            }

            return nodePtr;
        },

        findNextNode : function(node, selector, breakpoint) {
            var nodePtr = node;

            var _findNextNode = function (node) {
                if (!node) { return null; }

                if (node.firstChild) {
                    return node.firstChild;
                }
                if (node.nextSibling) {
                    return node.nextSibling;
                }

                var checkNode = node.parentNode;

                while (checkNode && !checkNode.nextSibling) {
                    checkNode = checkNode.parentNode;
                }

                return checkNode ? checkNode.nextSibling : null;
            };

            while (nodePtr && !$(nodePtr = _findNextNode(nodePtr)).is(selector) && nodePtr != breakpoint) {
                //
            }

            return nodePtr;
        },

        findPrevNodeAll : function(node, selector) {
            var nodes = []
                ,	nodePtr = node;

            while (nodePtr = this.findPrevNode(nodePtr, selector)) {
                //console.log(nodePtr);
                nodes.push(nodePtr);
            }

            return nodes;
        },

        findNextNodeAll : function(node, selector) {
            var nodes = []
                ,	nodePtr = node;

            while (nodePtr = this.findNextNode(nodePtr, selector)) {
                nodes.push(nodePtr);
            }
            return nodes;
        },


        /**
         *	지정한 브라우저 쿠키 생성하기
         *	@param {String} name		- 쿠키 이름
         *	@param {String} value		- 쿠키 값
         *	@param {Number} expFlag	    - 만료일(오늘을 기준으로 쿠키를 사용할 기간을 Day 기준으로 입력(ex : 30))
         */
        setCookieVal : function(name, value, expFlag) {
            var todayDate = new Date();

            todayDate.setDate(todayDate.getDate() + expFlag);

            document.cookie = name + "="
                + window.escape(value)
                + ((expFlag == null) ? "" : ("; expires=" + todayDate.toUTCString()))
                + "; path=/";
        },

        /**
         * 지정한 브라우저 쿠키 가져오기
         * @param {String} name		- 쿠키명
         * @returns {String}
         */
        getCookieVal : function(name) {
            var dc = document.cookie,
                prefix = name + "=",
                begin = dc.indexOf("; " + prefix),
                end;

            if (begin === -1) {
                begin = dc.indexOf(prefix);
                if (begin !== 0) {
                    return null;
                }
            } else {
                begin += 2;
            }

            end = document.cookie.indexOf(";", begin);
            if (end === -1) {
                end = dc.length;
            }

            return window.unescape(dc.substring(begin + prefix.length, end));
        },

        /**
         *	URL의 모든 정보를 파싱하여 반환
         *	@param {string=} url				 - 파싱할 URL(기본값 : location.href)
         *	@param {boolean=} isStrictMode	     - 엄격한 기준으로 파싱 여부(기본값 : loose)
         */
        parseURL : function(url, isStrictMode) {
            if (!url) {
                url = document.location.href;
            }

            // query 값에 @ 가 있을경우, 파싱에 문제가 생기므로, encode 문자로 치환해준다.
            url = url.replace(/@/g, "%40");

            var option = {
                strictMode: (isStrictMode === true),
                key: ["source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor"],
                q:   {
                    name:   "queryKey",
                    parser: /(?:^|&)([^&=]*)=?([^&]*)/g
                },
                parser: {
                    strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
                    loose:  /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/
                }
            };

            var	o   = option
                ,	m   = o.parser[o.strictMode ? "strict" : "loose"].exec(url)
                ,	uri = {}
                ,	i   = 14;

            while (i--) {
                uri[o.key[i]] = m[i] || "";
            }

            uri[o.q.name] = {};
            uri[o.key[12]].replace(o.q.parser, function ($0, $1, $2) {
                if ($0 && $1) {
                    // query 값에 @ 문자 치환값이 있으면, decode 해서 복원해 준다.
                    uri[o.q.name][$1] = $2.replace(/%40/g, "@");
                }
            });

            return uri;
        },

        // 컬러 RGB 코드에서 HEX 로 변환
        getRgbToHex : function(rgbCode) {
            if (!rgbCode) {
                return "";
            }
            rgbCode = rgbCode.replace(/[ ]/g, "");

            var tempColor = "";

            // RGB 코드를 Hex 코드로 변경
            var changeRgbHex = function(color) {
                var rgb_array = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"];

                if (color == 0) {
                    color = "00";
                } else {
                    var y = color / 16;
                    y = y + "a";

                    var hex1 = null
                        ,	hex2 = null
                        ,	u
                        ,	q
                        ,	l
                        ,	z
                        ,	xyz;

                    if (y.indexOf(".") === -1) {
                        u = y.indexOf("a");
                        q = y.substring(0, u);

                        hex1 = rgb_array[q];
                        hex2 = "0";
                    } else {
                        l = y.split(".");
                        q = l[0];
                        z = q * 16;
                        xyz = color - z;

                        hex1 = rgb_array[q];
                        hex2 = rgb_array[xyz];
                    }

                    color = hex1 + hex2;
                }

                return color;
            };

            if (/^rgb[a]?\(/i.test(rgbCode)) {
                tempColor = rgbCode.substr(rgbCode.indexOf("(") + 1);
                tempColor = tempColor.substr(0, tempColor.length - 1);
                tempColor = tempColor.split(",");

                var red = tempColor[0]
                    ,	green = tempColor[1]
                    ,	blue = tempColor[2]
                    ,	alpha = tempColor[3];

                // rgba(0,0,0,0)은 transparent 이므로 흰색으로 반환하고 나머지는 Hex 코드로 변환하여 반환한다.
                if (red == "0" && green == "0" && blue == "0" && alpha == "0") {
                    return "#ffffff";
                }

                return "#" + changeRgbHex(red) + changeRgbHex(green) + changeRgbHex(blue);
            }

            return rgbCode;
        },

        /**
         *	컬러 HEX 코드에서 RGB 로 변환
         *	@param {string} hexString	- 컬러 HEX 코드(예> #000000)
         *	@param {string=} defaultVal	- 계산에 실패할 경우 사용할 기본값(생략해도 무방)
         */
        getHexToRgb : function(hexString, defaultVal) {
            if (defaultVal === undefined) {
                defaultVal = null;
            }

            if (hexString.substr(0, 1) == '#') {
                hexString = hexString.substr(1);
            }

            var r = ""
                ,	g = ""
                ,	b = ""
                ,	rgbCode = "";

            if (hexString.length == 3) {
                r = hexString.substr(0, 1);
                r += r;
                g = hexString.substr(1, 1);
                g += g;
                b = hexString.substr(2, 1);
                b += b;
            } else if (hexString.length == 6) {
                r = hexString.substr(0, 2);
                g = hexString.substr(2, 2);
                b = hexString.substr(4, 2);
            } else {
                return defaultVal;
            }

            r = parseInt(r, 16);
            g = parseInt(g, 16);
            b = parseInt(b, 16);

            if (isNaN(r) || isNaN(g) || isNaN(b)) {
                rgbCode = defaultVal;
            } else {
                rgbCode = "rgb(" + r + ", " + g + ", " + b + ")";
            }

            return rgbCode;
        },

        /**
         * 컬러 RGB 코드에서 HSV 로 변환
         * @param {string} rgbCode         - 컬러 RGB 코드
         */
        getRgbToHsv: function (rgbCode) {
            var isRgbCode = rgbCode && /^rgb[a]?\(/i.test(rgbCode),
                r, g, b, rr, gg, bb, h, s, v,
                tempCode, rgbMax, rgbMin, deltaMax, deltaRgbVal;

            if (isRgbCode) {
                tempCode = rgbCode.substr(rgbCode.indexOf("(") + 1);
                tempCode = tempCode.substr(0, tempCode.length - 1);
                tempCode = tempCode.split(",");

                r = parseInt(tempCode[0]) / 255;
                g = parseInt(tempCode[1]) / 255;
                b = parseInt(tempCode[2]) / 255;
            }

            if (!isRgbCode || isNaN(r) || isNaN(g) || isNaN(b)) {
                return {h: 0, s: 0, v: 0};
            }

            rgbMax = Math.max(r, g, b);
            rgbMin = Math.min(r, g, b);
            h = 0;
            v = rgbMax;
            deltaMax = rgbMax - rgbMin;
            deltaRgbVal = function (val) {
                return (v - val) / 6 / deltaMax + 1 / 2;
            };

            if (deltaMax === 0) {
                s = 0;
            } else {
                s = deltaMax / v;

                rr = deltaRgbVal(r);
                gg = deltaRgbVal(g);
                bb = deltaRgbVal(b);

                if (r === v) {
                    h = bb - gg;
                } else if (g === v) {
                    h = (1 / 3) + rr - bb;
                } else if (b === v) {
                    h = (2 / 3) + gg - rr;
                }

                if (h < 0) {
                    h += 1;
                } else if (h > 1) {
                    h -= 1;
                }
            }

            return {
                h: Math.round(h * 360),
                s: Math.round(s * 100),
                v: Math.round(v * 100)
            };
        },

        /**
         * 컬러 HSV 코드에서 HEX 코드로 변환
         * @param {String|Number} hCode
         * @param {String|Number} sCode
         * @param {String|Number} vCode
         * @returns {string}
         */
        getHsvToHex: function (hCode, sCode, vCode) {
            if (hCode === undefined || sCode === undefined || vCode === undefined) {
                return "";
            }

            var hexString = "",
                s = parseInt(sCode) / 100,
                v = parseInt(vCode) / 100,
                r, g, b, i, f, p, q, t, h;

            if (s === 0) {
                r = g = b = v;
            } else {
                h = parseInt((hCode === 360) ? 0 : hCode) / 60;
                i = Math.floor(h);
                f = h - i;
                p = v * (1 - s);
                q = v * (1 - s * f);
                t = v * (1 - s * (1 - f));

                switch (i) {
                    case 0:
                        r = v;
                        g = t;
                        b = p;
                        break;

                    case 1:
                        r = q;
                        g = v;
                        b = p;
                        break;

                    case 2:
                        r = p;
                        g = v;
                        b = t;
                        break;

                    case 3:
                        r = p;
                        g = q;
                        b = v;
                        break;

                    case 4:
                        r = t;
                        g = p;
                        b = v;
                        break;

                    default:
                        r = v;
                        g = p;
                        b = q;
                }
            }

            r = Math.round(r * 255);
            g = Math.round(g * 255);
            b = Math.round(b * 255);

            if (r < 16) {
                hexString = hexString + "0";
            }
            hexString = hexString + r.toString(16);

            if (g < 16) {
                hexString = hexString + "0";
            }
            hexString = hexString + g.toString(16);

            if (b < 16) {
                hexString = hexString + "0";
            }
            hexString = hexString + b.toString(16);

            return  "#" + hexString;
        },

        /**
         * 컬러 HEX 코드에서 HSV 코드로 변환
         * @param {String} hexCode      - 컬러 HEX 코드(예> #000000)
         * @returns {Object}            - {h, s, v}
         */
        getHexToHsv: function(hexCode) {
            var colorCheckReg = /^#([A-Fa-f0-9]{6})$/,
                hCode, sCode, vCode,
                rgbCode, hsv;

            if (hexCode == null && !colorCheckReg.test(hexCode)) {
                return {h: 0, s: 0, v: 0};
            }

            rgbCode = this.getHexToRgb(hexCode);
            hsv = rgbCode && this.getRgbToHsv(rgbCode);

            if (hsv != null && typeof hsv === "object") {
                hCode = hsv.h;
                sCode = hsv.s;
                vCode = hsv.v;
            }

            return {
                h: hCode || 0,
                s: sCode || 0,
                v: vCode || 0
            };
        },

        /**
         *	pt 값을 px 값으로 계산하여 반환.
         *	@param {(String|Number)} ptValue	- 계산할 pt 값 (ex : "10pt" 또는 12 등)
         *	@param {Number=} digits			- 변환 결과의 소수점 자리수(0이면 소수점 없이 반환)
         *	@returns {Number}
         */
        convertPtToPx : function(ptValue, digits) {
            var number = parseFloat(ptValue) * 96 / 72;

            if (digits !== undefined && typeof digits === "number" && digits >= 0) {
                number = this.getRoundNumber(number, digits);
            }

            return number;
        },

        /**
         *	단위를 변환하여 반환.
         *	@param {(String|Number)} unitVal	    - 계산할 대상 단위(ex : 10pt => 만일 단위없이 숫자만 입력하면 기본단위인 px로 계산함)
         *	@param {Number=} digits			        - 변환 결과의 소수점 자리수(0이면 소수점 없이 반환)
         *	@param {String=} targetUnit            - 반환받을 단위를 지정한다.(ex : "px" => 지정되지 않으면 모든 단위를 반환함)
         *	@returns {Object}
         */
        getUnits : function(unitVal, digits, targetUnit) {
            if (unitVal == null) {
                return null;
            }

            var value = String(unitVal),
                units = {},
                numeric = value.match(/[\d|\.]+/),
                multiple = -1,
                minusMultiple = 1,
                unit, item, newUnits;

            var map = {
                pixel : "px",
                inch: "in",
                cm : "cm",
                mm : "mm",
                m : "m",
                point : "pt",
                pica : "pc",
                ex : "ex",
                twip : "twip",
                emu : "emu"
            };

            var unitCalculate = function(cmd, targetVal) {
                var calcVal = targetVal;

                if (!cmd) {
                    return calcVal;
                }

                switch (cmd) {
                    case "twipToPixel" :
                        calcVal = calcVal / 15;
                        break;
                    case "pixelToTwip" :
                        calcVal = calcVal * 15;
                        break;
                    case "emuToTwip" :
                        calcVal = calcVal / 635;
                        break;
                    case "twipToEmu" :
                        calcVal = calcVal * 635;
                        break;
                    case "inchToPixel" :
                        calcVal = calcVal * 96;
                        break;
                    case "inchToPoint" :
                        calcVal = calcVal * 72;
                        break;
                    case "centimeterToInch" :
                        calcVal = calcVal / 2.54;
                        break;
                    case "inchToCentimeter" :
                        calcVal = calcVal * 2.54;
                        break;
                    case "pointToPixel" :
                        calcVal = calcVal * 96 / 72;
                        break;
                    case "pointToPica" :
                        calcVal = (1/12) * calcVal;
                        break;
                    case "picaToPoint" :
                        calcVal = calcVal * 12;
                        break;
                    case "pixelToInch" :
                        calcVal = (1/96) * calcVal;
                        break;
                }

                return calcVal;
            };

            if (numeric === null) {
                return null;
            }

            // 소수점 자리수 제한 설정이 있다면, 설정값을 기록한다.
            if (digits !== undefined && typeof digits === "number" && digits >= 0) {
                multiple = Math.pow(10, digits);
            }

            // 변환 대상값이 음수값이면 -1 값을 기록한다.
            if (/^-/.test(value)) {
                minusMultiple = -1;
            }

            numeric = parseFloat(numeric[0]);

            unit = value.match(/\D+$/);
            unit = (unit == null) ? map.pixel : unit[0];

            // unit map 의 복사본을 생성하여 units 에 할당한다.
            for (item in map) {
                if (map[item] === unit) {
                    units[item] = numeric;
                } else {
                    units[item] = null;
                }
            }

            // pixel 을 기준으로 초기 계산을 진행한다.
            if (unit === "twip") {
                units.pixel = unitCalculate("twipToPixel", numeric);
            } else if (unit === "in") {
                units.pixel = unitCalculate("inchToPixel", numeric);
            } else if (unit === "cm") {
                units.inch = unitCalculate("centimeterToInch", numeric);
                units.pixel = unitCalculate("inchToPixel", units.inch);
            } else if (unit === "mm") {
                units.cm = numeric / 10;
                units.inch = unitCalculate("centimeterToInch", units.cm);
                units.pixel = unitCalculate("inchToPixel", units.inch);
            } else if (unit === "m") {
                units.cm = numeric * 100;
                units.inch = unitCalculate("centimeterToInch", units.cm);
                units.pixel = unitCalculate("inchToPixel", units.inch);
            } else if (unit === "pt") {
                units.pixel = unitCalculate("pointToPixel", numeric);
            } else if (unit === "pc") {
                units.point = unitCalculate("picaToPoint", numeric);
                units.pixel = unitCalculate("pointToPixel", units.point);
            } else if (unit === "emu") {
                units.twip = unitCalculate("emuToTwip", numeric);
                units.pixel = unitCalculate("twipToPixel", units.twip);
            }

            if (units.pixel === null) {
                return null;
            } else {
                // 지정 unit 이 있고, 지정 unit 이 이미 계산된 상태가 아니라면 모든 단위 계산을 진행한다.
                if (!(targetUnit && (targetUnit === unit || targetUnit === "px"))) {
                    // 초기변환에서 계산되지 않은 나머지 단위를 추가 계산한다.
                    if (units.inch === null) {
                        units.inch = unitCalculate("pixelToInch", units.pixel);
                    }
                    if (units.cm === null) {
                        units.cm = unitCalculate("inchToCentimeter", units.inch);
                    }
                    if (units.mm === null) {
                        units.mm = units.cm * 10;
                    }
                    if (units.m === null) {
                        units.m = units.cm / 100;
                    }
                    if (units.point === null) {
                        units.point = unitCalculate("inchToPoint", units.inch);
                    }
                    if (units.pica === null) {
                        units.pica = unitCalculate("pointToPica", units.point);
                    }
                    if (units.twip === null) {
                        units.twip = unitCalculate("pixelToTwip", units.pixel);
                    }
                    if (units.emu === null) {
                        units.emu = unitCalculate("twipToEmu", units.twip);
                    }
                }

                // 지정 unit 이 있다면, 지정 unit 만 unit map 에 재할당 한다.
                if (targetUnit) {
                    newUnits = {};

                    for (item in map) {
                        if (map[item] === targetUnit) {
                            newUnits[item] = units[item];
                            break;
                        }
                    }

                    units = newUnits;
                }

                // 변환된 단위의 최종값을 재할당 한다.(소수점 자리수, 음수처리)
                for (item in units) {
                    if (units.hasOwnProperty(item) && units[item] != null) {
                        if (multiple > -1) {
                            units[item] = Math.round(units[item] * multiple) / multiple;
                        }

                        units[item] = units[item] * minusMultiple;
                    }
                }
            }

            return units;
        },

        // 특수 공백을 제외한 순수 텍스트 반환.
        getTrimText : function(text) {
            if (!text) {
                return "";
            }

            return text.replace(/(?:\n|\t|\r)/g, "");
        },

        /**
         * 해당 string 이 testString 으로 시작하는지 여부 반환
         * @param {String} string
         * @param {String} testString
         * @returns {Boolean}
         * @author <a href="mailto:igkang@hancom.com">강인구</a>
         */
        isStartsWith : function(string, testString) {
            if (!(typeof string === "string" && typeof testString === "string")) {
                return false;
            }

            return string.slice(0, testString.length) === testString;
        },

        /**
         * 해당 string 이 testString 으로 끝나는지 여부 반환
         * @param {String} string
         * @param {String} testString
         * @returns {Boolean}
         * @author <a href="mailto:igkang@hancom.com">강인구</a>
         */
        isEndsWith : function(string, testString) {
            if (!(typeof string === "string" && typeof testString === "string")) {
                return false;
            }

            return string.slice(testString.length * -1) === testString;
        },

        // 객체 복사본을 반환.
        cloneObject : function(obj) {
            if (!obj) {
                return obj;
            }

            var newObj
                ,	keys
                ,	key
                ,	idx
                ,	length;

            if (this.isArray(obj)) {
                newObj = obj.slice(0);
                length = newObj.length;

                for (idx = 0; idx < length; idx++) {
                    newObj[idx] = this.cloneObject(newObj[idx]);
                }

            } else if (this.isObject(obj)) {
                //원본 객체 item 의 타입에 다른 clone 실행
                newObj = {};
                keys = Object.keys(obj);
                length = keys.length;

                for (idx = 0; idx < length; idx++) {
                    key = keys[idx];
                    newObj[key] = this.cloneObject(obj[key]);
                }

            } else {
                //object 타입중 객체와 배열만 Clone 을 진행한다.
                newObj = obj;
            }

            return newObj;
        },

        // cloneObject Alias
        deepClone : function(obj) {
            return this.cloneObject(obj);
        },

        // 유효하지 않은 특수문자 포함 여부(파일명 기준)
        isInvalidSpecialChar : function(str) {
            var pattern = /[\\\/\:\*\?\"\<\>\|\#\%\&\+]/;

            return pattern.test(str);
        },

        // keyCode의 Name을 정의한 Map Object를 반환.
        keyCodeMap : {
            //function keys
            "f1" : "112",
            "f2" : "113",
            "f3" : "114",
            "f4" : "115",
            "f5" : "116",
            "f6" : "117",
            "f7" : "118",
            "f8" : "119",
            "f9" : "120",
            "f10" : "121",
            "f11" : "122",
            "f12" : "123",

            //0-9
            "0" : "48",
            "1" : "49",
            "2" : "50",
            "3" : "51",
            "4" : "52",
            "5" : "53",
            "6" : "54",
            "7" : "55",
            "8" : "56",
            "9" : "57",

            //numpad
            "num0" : "96",
            "num1" : "97",
            "num2" : "98",
            "num3" : "99",
            "num4" : "100",
            "num5" : "101",
            "num6" : "102",
            "num7" : "103",
            "num8" : "104",
            "num9" : "105",
            "num*" : "106",
            "num+" : "107",
            "numenter" : "108",
            "num-" : "109",
            "num." : "110",
            "num/" : "111",
            "numlock" : "144",

            //general
            "cancel"      : "3",
            "backspace"   : "8",
            "tab" 		  : "9",
            "clear" 	  : "12",
            "enter" 	  : "13",
            "shift" 	  : "16",
            "ctrl" 		  : "17",
            "alt" 		  : "18",
            "menu" 		  : "18",
            "pause"		  : "19",
            "break"	 	  : "19",
            "capslock"    : "20",
            "koreanswitch": "21",
            "chinesechar" : "25",
            "escape"      : "27",
            "esc" 	 	  : "27",
            "space" 	  : "32",
            "spacebar"	  : "32",
            "pageup" 	  : "33",
            "pagedown" 	  : "34",
            "end"		  : "35",
            "home"		  : "36",
            "left"		  : "37",
            "up"		  : "38",
            "right" 	  : "39",
            "down" 		  : "40",
            "select" 	  : "41",
            "printscreen" : "42",
            "execute"	  : "43",
            "snapshot"	  : "44",
            "insert"	  : "45",
            "ins"		  : "45",
            "delete"	  : "46",
            "del"	      : "46",
            "help"		  : "47",
            "command"     : "91",
            "rcommand"    : "93",  // right command
            "ffcommand"   : "224", // firefox command
            "window"	  : "92",
            "scrolllock"  : "145",
            "scroll"	  : "145",
            ";"			  : "186",
            "semicolon"   : "186",
            "=" 		  : "187",
            "equal"		  : "187",
            "," 		  : "188",
            "comma"		  : "188",
            "-"			  : "189",
            "dash"		  : "189",
            "." 		  : "190",
            "period"	  : "190",
            "/"			  : "191",
            "`"			  : "192",
            "["			  : "219",
            "\\"		  : "220",
            "]" 		  : "221",
            "'" 		  : "222",
            "shift+movekeys" : function(e) { return e.shiftKey && MOVE_KEY_CODE_ARR.indexOf(e.keyCode) !== -1; },
            "ctrl+movekeys" : function(e) { return e.ctrlKey && !e.shiftKey && MOVE_KEY_CODE_ARR.indexOf(e.keyCode) !== -1; },
            "ctrl+shift+left" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 37; },
            "ctrl+shift+up" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 38; },
            "ctrl+shift+right" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 39; },
            "ctrl+shift+down" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 40; },
            "command+movekeys" : function(e) { return e.metaKey && !e.shiftKey && MOVE_KEY_CODE_ARR.indexOf(e.keyCode) !== -1; },
            "command+shift+left" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 37; },
            "command+shift+up" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 38; },
            "command+shift+right" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 39; },
            "command+shift+down" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 40; },
            "ctrl+backspace" : function(e) { return e.ctrlKey && e.keyCode === 8; },
            "shift+backspace" : function(e) { return e.shiftKey && e.keyCode === 8; },
            "command+backspace" : function(e) { return e.metaKey && e.keyCode === 8; },
            "alt+backspace" : function(e) { return e.altKey && e.keyCode === 8; },
            "ctrl+tab" : function(e) { return e.ctrlKey && e.keyCode === 9; },
            "command+tab" : function(e) { return e.metaKey && e.keyCode === 9; },
            "alt+tab" : function(e) { return e.altKey && e.keyCode === 9; },
            "shift+tab" : function(e) { return e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 9; },
            "only_tab" : function(e) { return !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 9; },
            "only_enter" : function(e) { return !e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 13; },
            "shift+enter" : function(e) { return e.shiftKey && e.keyCode === 13; },
            "ctrl+enter" : function(e) { return e.ctrlKey && e.keyCode === 13; },
            "command+enter" : function(e) { return e.metaKey && e.keyCode === 13; },
            "ctrl+space" : function(e) { return e.ctrlKey && !e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 32; },
            "shift+pageup" : function(e) { return e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 33; },
            "shift+pagedown" : function(e) { return e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 34; },
            "shift+insert" : function(e) { return e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 45; },
            "ctrl+insert" : function(e) { return e.ctrlKey && !e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 45; },
            "command+insert" : function(e) { return e.metaKey && !e.ctrlKey && !e.shiftKey && !e.altKey && e.keyCode === 45; },
            "ctrl+delete" : function(e) { return e.ctrlKey && !e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 46; },
            "shift+delete" : function(e) { return e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 46; },
            "ctrl+a" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 65; },
            "command+a" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 65; },
            "ctrl+b" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 66; },
            "command+b" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 66; },
            "ctrl+c" : function(e) { return e.ctrlKey && !e.shiftKey && !e.metaKey && !e.altKey && e.keyCode === 67; },
            "command+c" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 67; },
            "ctrl+shift+c" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 67; },
            "command+shift+c" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 67; },
            "ctrl+alt+d" : function(e) { return e.ctrlKey && e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 68; },
            "ctrl+e" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 69; },
            "command+e" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey  && e.keyCode === 69; },
            "ctrl+shift+e" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 69; },
            "command+shift+e" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 69; },
            "alt+shift+e" : function(e) { return e.altKey && e.shiftKey && !e.ctrlKey && !e.metaKey && e.keyCode === 69; },
            "ctrl+f" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 70; },
            "command+f" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 70; },
            "ctrl+alt+f" : function(e) { return e.ctrlKey && e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 70; },
            "ctrl+shift+g" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 71; },
            "command+shift+g" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 71; },
            "ctrl+h" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 72; },
            "ctrl+i" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 73; },
            "command+i" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 73; },
            "ctrl+alt+i" : function(e) { return e.ctrlKey && e.altKey && !e.metaKey && !e.shiftKey && e.keyCode === 73; },
            "command+alt+i" : function(e) { return e.metaKey && e.altKey && !e.ctrlKey && !e.shiftKey && e.keyCode === 73; },
            "alt+shift+i" : function(e) { return e.altKey && e.shiftKey && !e.ctrlKey && !e.metaKey && e.keyCode === 73; },
            "ctrl+j" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 74; },
            "command+j" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 74; },
            "ctrl+k" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 75; },
            "command+k" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 75; },
            "ctrl+l" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 76; },
            "command+l" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 76; },
            "ctrl+shift+l" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 76; },
            "command+shift+l" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 76; },
            "ctrl+m" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 77; },
            "command+m" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 77; },
            "ctrl+shift+m" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 77; },
            "command+shift+m" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 77; },
            "ctrl+n" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 78; },
            "command+n" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 78; },
            "alt+shift+n" : function(e) { return e.altKey && e.shiftKey && !e.ctrlKey && !e.metaKey && e.keyCode === 78; },
            "ctrl+p" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 80; },
            "command+p" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 80; },
            "alt+p" : function(e) { return e.altKey && !e.shiftKey && !e.ctrlKey && !e.metaKey && e.keyCode === 80; },
            "ctrl+r" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 82; },
            "command+r" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 82; },
            "ctrl+shift+r" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 82; },
            "command+shift+r" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 82; },
            "alt+shift+r" : function(e) { return e.altKey && e.shiftKey && !e.ctrlKey && !e.metaKey && e.keyCode === 82; },
            "ctrl+s" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 83; },
            "command+s" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 83; },
            "alt+s" : function(e) { return e.altKey && !e.shiftKey && !e.ctrlKey && !e.metaKey && e.keyCode === 83; },
            "ctrl+u" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 85; },
            "command+u" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 85; },
            "ctrl+v" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 86; },
            "alt+v" : function(e) { return e.altKey && !e.shiftKey && !e.ctrlKey && !e.metaKey && e.keyCode === 86; },
            "command+v" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 86; },
            "alt+shift+w" : function(e) { return e.altKey && e.shiftKey && !e.ctrlKey && !e.metaKey && e.keyCode === 87; },
            "ctrl+x" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 88; },
            "command+x" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 88; },
            "ctrl+y" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 89; },
            "ctrl+z" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 90; },
            "ctrl+shift+z" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 90; },
            "command+shift+z" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 90; },
            "command+z" : function(e) { return e.metaKey && !e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 90; },
            "ctrl+/" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && e.keyCode == 191; },
            "command+/" : function(e) { return e.metaKey && !e.ctrlKey && !e.altKey && !e.shiftKey && e.keyCode == 191; },
            "ctrl+f2" : function(e) { return e.ctrlKey && e.keyCode === 113; },
            "ctrl+f3" : function(e) { return e.ctrlKey && e.keyCode === 114; },
            "ctrl+f5" : function(e) { return e.ctrlKey && e.keyCode === 116; },
            "ctrl+f10" : function(e) { return e.ctrlKey && e.keyCode === 121; },
            "ctrl+shift+f5" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 116; },
            "command+shift+f5" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 116; },
            "ctrl+f6" : function(e) { return e.ctrlKey && e.keyCode === 117; },
            "only_f1" : function(e) { return !e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 112; },
            "only_f7" : function(e) { return !e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 118; },
            "only_f12" : function(e) { return !e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && e.keyCode === 123; },
            "ctrl+0" : function(e) { return e.ctrlKey && !e.altKey && (e.keyCode === 48 || e.keyCode === 96); },
            "command+0" : function(e) { return e.metaKey && !e.altKey && (e.keyCode === 48 || e.keyCode === 96); },
            "ctrl+1" : function(e) { return e.ctrlKey && !e.altKey && (e.keyCode === 49 || e.keyCode === 97); },
            "ctrl+2" : function(e) { return e.ctrlKey && !e.altKey && (e.keyCode === 50 || e.keyCode === 98); },
            "ctrl+3" : function(e) { return e.ctrlKey && !e.altKey && (e.keyCode === 51 || e.keyCode === 99); },
            "ctrl+shift+<" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 188; },
            "command+shift+<" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 188; },
            "ctrl+shift+>" : function(e) { return e.ctrlKey && e.shiftKey && !e.altKey && !e.metaKey && e.keyCode === 190; },
            "command+shift+>" : function(e) { return e.metaKey && e.shiftKey && !e.ctrlKey && !e.altKey && e.keyCode === 190; },
            "ctrl+[" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 219; },
            "command+[" : function(e) { return e.metaKey && !e.altKey && !e.shiftKey && !e.ctrlKey && e.keyCode === 219; },
            "ctrl+]" : function(e) { return e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey && e.keyCode === 221; },
            "command+]" : function(e) { return e.metaKey && !e.ctrlKey && !e.altKey && !e.shiftKey && e.keyCode === 221; },
            "shift+alt" : function(e) { return e.shiftKey && e.keyCode === 18 && !e.ctrlKey && !e.metaKey; },
            "alt+shift" : function(e) { return e.altKey && e.keyCode === 16 && !e.ctrlKey && !e.metaKey; },
            "not_composition" : function(e) { return !e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey; },
            "command_composition" : function(e) { return e.metaKey; },
            "alt_composition" : function(e) { return e.altKey; },
            "!ctrlkey !altkey" : function(e) { return (e.ctrlKey == false && e.altKey == false && e.keyCode != 17 && e.keyCode != 18);},
            "!ctrlkey !command" : function(e) { return (e.ctrlKey == false && (e.metaKey == false || e.metaKey == undefined) && e.keyCode != 17);},
            "!ctrlkey !altkey !command" : function(e) { return (e.ctrlKey == false && e.altKey == false
            && (e.metaKey == false || e.metaKey == undefined) && e.keyCode != 17 && e.keyCode != 18);},
            "!ctrlkey !altkey !shiftkey" : function(e) { return (e.ctrlKey == false && e.altKey == false && e.shiftKey == false
            && e.keyCode != 16 && e.keyCode != 17 && e.keyCode != 18);},
            "ctrlkey altkey !shiftkey" : function(e) { return (e.ctrlKey == true && e.altKey == true && !e.shiftKey && e.keyCode != 17 && e.keyCode != 18);},
            "ctrlkey altkey" : function(e) { return (e.ctrlKey == true && e.altKey == true && e.keyCode != 17 && e.keyCode != 18);},
            "movement keys" : function(e) {
                var isMoveKey = $.inArray(e.keyCode, [33, 34, 35, 36, 37, 38, 39, 40]) != -1;
                return (e.shiftKey && isMoveKey) || isMoveKey;
            },
            "all movement keys" : function(e) { return $.inArray(e.keyCode, [33, 34, 35, 36, 37, 38, 39, 40, 45]) != -1;},
            "function keys" : function(e) {
                var funcList = ["ctrl", "alt", "command", "rcommand", "ffcommand", "pause", "capslock", "esc", "window", "numlock", "scrolllock"]
                    ,	exist = false
                    ,	i
                    ,	len = funcList.length;

                for (i = 0; i < len; i++) {
                    if (this[funcList[i]] == e.keyCode) {
                        exist = true;
                        break;
                    }
                }

                return exist;
            },

            //알파벳 대문자 A-Z까지
            "a-z" : function(e) {
                return e.keyCode >= 65 && e.keyCode <= 90;
            },

            //알파벳 0-9부터  대문자 A-Z까지
            "0-1&a-z" : function(e) {
                return e.keyCode >= 48 && e.keyCode <= 90;
            },

            "input keys" : function(e) {
                return $.inArray(e.keyCode, [9, 13, 32]) != -1
                    || (e.keyCode >= 48 && e.keyCode <= 90)
                    || (e.keyCode >= 186 && e.keyCode <= 222)
                    || (e.keyCode >= 96 && e.keyCode <= 111)
                    || e.keyCode == 229;
            },

            "f1~f12" : function(e) {
                return $.inArray(e.keyCode, [112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123]) != -1;
            }

        },

        /**
         *	keyCode의 조합을 쉽게 찾고, callback을 실행시킬수 있는 메소드를 제공
         *	@param {object} context		- 호출 컨텍스트
         *	@param {object} eventObject	- event 객체
         *
         *	@method
         *	@name filter				- 지정하는 키 배열을 찾고, callback을 실행한다.
         *		@param {array} arr			- 매칭 키 배열
         *		@param {function} callback	- 매칭되는 키를 찾으면 실행되는 callback
         *	@name only
         *	@name is
         *	@name isMovementKeys
         *	@name isAllMovementKeys
         *	@name isInputKeys
         *	@name isFuncKeys
         */
        keyMap : function(context, eventObject) {
            if (! eventObject) {
                eventObject = context;
                context = this;
            }

            var _t = this
                ,	keyCode = eventObject.keyCode
                ,	isDefaultPrevented = (eventObject.originalEvent)
                ? eventObject.originalEvent.defaultPrevented
                : eventObject.defaultPrevented;

            if (isDefaultPrevented === undefined) {
                isDefaultPrevented = eventObject.isDefaultPrevented();
            }

            return {
                /**
                 * 지정한 keyName 이 눌렸는지 체크하여, 유효하면 callback 을 실행
                 * @param {Array} arr
                 * @param {Function} callback
                 */
                filter : function(arr, callback) {
                    var i
                        ,	len = arr.length
                        ,	keyName
                        ,	keyValue
                        ,	acceptKeys
                        ,	keyMap = this;

                    for (i = 0; i < len; i++) {
                        keyName = arr[i].toLowerCase();
                        keyValue = _t.keyCodeMap[keyName];
                        acceptKeys = $.inArray(keyName, ["tab", "only_tab"]) != -1;

                        if (! acceptKeys && isDefaultPrevented) {
                            break;
                        }

                        if ($.isFunction(keyValue) && keyValue(eventObject)) {
                            callback.call(context, keyName, keyMap);
                            break;
                        }

                        if (keyCode == keyValue) {
                            callback.call(context, keyName, keyMap);
                            break;
                        }
                    }

                    return this;
                },

                /**
                 * 지정한 keyName 만 눌렸는지 체크하여, 유효하면 callback 을 실행
                 * @param {Array} arr
                 * @param {Function} callback
                 */
                only : function(arr, callback) {
                    var i
                        ,	j
                        ,	arrLen = arr.length
                        ,	ignore = false
                        ,	keyName
                        ,	keyValue
                        ,	compKeys;

                    for (i = 0; i < arrLen; i++) {
                        keyName = arr[i];
                        compKeys = ["shiftKey", "ctrlKey", "altKey"];

                        if (keyName.indexOf("shift") != -1) {
                            compKeys = _t.without(compKeys, "shiftKey");
                        } else if(keyName.indexOf("alt") != -1) {
                            compKeys = _t.without(compKeys, "altKey");
                        } else if(keyName.indexOf("ctrl") != -1) {
                            compKeys = _t.without(compKeys, "ctrlKey");
                        }

                        ignore = false;
                        for (j = 0; j < compKeys.length; j++) {
                            if (eventObject[compKeys[j]]) {
                                ignore = true;
                            }
                        }

                        keyValue = _t.keyCodeMap[keyName];
                        if (!ignore && $.isFunction(keyValue) && keyValue(eventObject)) {
                            callback.call(context, keyName, this);
                            break;
                        }

                        if (!ignore && keyCode == keyValue) {
                            callback.call(context, keyName, this);
                            break;
                        }
                    }
                },

                /**
                 * 지정한 keyName 이 Event Object 값과 일치 여부 반환.
                 * @param {(Array|String)} obj
                 * @returns {boolean}
                 */
                is : function(obj) {
                    var exist = false
                        ,	keyName
                        ,	keyValue;

                    if (obj instanceof Array) {
                        var i
                            ,	len = obj.length;

                        for (i = 0; i < len; i++) {
                            keyName = obj[i];
                            keyValue = _t.keyCodeMap[keyName];

                            if (! keyValue) {
                                continue;
                            }

                            if ($.isFunction(keyValue)) {
                                exist = keyValue(eventObject);
                            } else {
                                exist = (keyCode == keyValue);
                            }

                            if (exist) {
                                break;
                            }
                        }
                    } else {
                        keyValue = _t.keyCodeMap[obj];
                        if ($.isFunction(keyValue)) {
                            exist = keyValue(eventObject);
                        } else {
                            exist = (keyCode == keyValue);
                        }
                    }

                    return exist;
                },

                //단순 방향키에 대한 일치여부
                isMovementKeys : function() {
                    return _t.keyCodeMap["movement keys"](eventObject);
                },

                //모든 방향키(left, right, up, down, homem, end, pgUp, pgDown.. )
                isAllMovementKeys : function() {
                    return _t.keyCodeMap["all movement keys"](eventObject);
                },

                isInputKeys : function() {
                    return _t.keyCodeMap["input keys"](eventObject);
                },

                isFuncKeys : function() {
                    return _t.keyCodeMap["function keys"](eventObject);
                }
            };
        },

        /**
         * colorName to Hex Map
         * 출처 : http://www.w3schools.com/html/html_colornames.asp
         */
        colorNameMap : {
            aliceblue : "#F0F8FF",
            antiquewhite : "#FAEBD7",
            aqua : "#00FFFF",
            aquamarine : "#7FFFD4",
            azure : "#F0FFFF",
            beige : "#F5F5DC",
            bisque : "#FFE4C4",
            black : "#000000",
            blanchedalmond : "#FFEBCD",
            blue : "#0000FF",
            blueviolet : "#8A2BE2",
            brown : "#A52A2A",
            burlywood : "#DEB887",
            cadetblue : "#5F9EA0",
            chartreuse : "#7FFF00",
            chocolate : "#D2691E",
            coral : "#FF7F50",
            cornflowerblue : "#6495ED",
            cornsilk : "#FFF8DC",
            crimson : "#DC143C",
            cyan : "#00FFFF",
            darkblue : "#00008B",
            darkcyan : "#008B8B",
            darkgoldenrod : "#B8860B",
            darkgray : "#A9A9A9",
            darkgreen : "#006400",
            darkkhaki : "#BDB76B",
            darkmagenta : "#8B008B",
            darkolivegreen : "#556B2F",
            darkorange : "#FF8C00",
            darkorchid : "#9932CC",
            darkred : "#8B0000",
            darksalmon : "#E9967A",
            darkseagreen : "#8FBC8F",
            darkslateblue : "#483D8B",
            darkslategray : "#2F4F4F",
            darkturquoise : "#00CED1",
            darkviolet : "#9400D3",
            deeppink : "#FF1493",
            deepskyblue : "#00BFFF",
            dimgray : "#696969",
            dodgerblue : "#1E90FF",
            firebrick : "#B22222",
            floralwhite : "#FFFAF0",
            forestgreen : "#228B22",
            fuchsia : "#FF00FF",
            gainsboro : "#DCDCDC",
            ghostwhite : "#F8F8FF",
            gold : "#FFD700",
            goldenrod : "#DAA520",
            gray : "#808080",
            green : "#008000",
            greenyellow : "#ADFF2F",
            honeydew : "#F0FFF0",
            hotpink : "#FF69B4",
            indianred : "#CD5C5C",
            indigo : "#4B0082",
            ivory : "#FFFFF0",
            khaki : "#F0E68C",
            lavender : "#E6E6FA",
            lavenderblush : "#FFF0F5",
            lawngreen : "#7CFC00",
            lemonchiffon : "#FFFACD",
            lightblue : "#ADD8E6",
            lightcoral : "#F08080",
            lightcyan : "#E0FFFF",
            lightgoldenrodyellow : "#FAFAD2",
            lightgray : "#D3D3D3",
            lightgreen : "#90EE90",
            lightpink : "#FFB6C1",
            lightsalmon : "#FFA07A",
            lightseagreen : "#20B2AA",
            lightskyblue : "#87CEFA",
            lightslategray : "#778899",
            lightsteelblue : "#B0C4DE",
            lightyellow : "#FFFFE0",
            lime : "#00FF00",
            limegreen : "#32CD32",
            linen : "#FAF0E6",
            magenta : "#FF00FF",
            maroon : "#800000",
            mediumaquamarine : "#66CDAA",
            mediumblue : "#0000CD",
            mediumorchid : "#BA55D3",
            mediumpurple : "#9370DB",
            mediumseagreen : "#3CB371",
            mediumslateblue : "#7B68EE",
            mediumspringgreen : "#00FA9A",
            mediumturquoise : "#48D1CC",
            mediumvioletred : "#C71585",
            midnightblue : "#191970",
            mintcream : "#F5FFFA",
            mistyrose : "#FFE4E1",
            moccasin : "#FFE4B5",
            navajowhite : "#FFDEAD",
            navy : "#000080",
            oldlace : "#FDF5E6",
            olive : "#808000",
            olivedrab : "#6B8E23",
            orange : "#FFA500",
            orangered : "#FF4500",
            orchid : "#DA70D6",
            palegoldenrod : "#EEE8AA",
            palegreen : "#98FB98",
            paleturquoise : "#AFEEEE",
            palevioletred : "#DB7093",
            papayawhip : "#FFEFD5",
            peachpuff : "#FFDAB9",
            peru : "#CD853F",
            pink : "#FFC0CB",
            plum : "#DDA0DD",
            powderblue : "#B0E0E6",
            purple : "#800080",
            rebeccapurple : "#663399",
            red : "#FF0000",
            rosybrown : "#BC8F8F",
            royalblue : "#4169E1",
            saddlebrown : "#8B4513",
            salmon : "#FA8072",
            sandybrown : "#F4A460",
            seagreen : "#2E8B57",
            seashell : "#FFF5EE",
            sienna : "#A0522D",
            silver : "#C0C0C0",
            skyblue : "#87CEEB",
            slateblue : "#6A5ACD",
            slategray : "#708090",
            snow : "#FFFAFA",
            springgreen : "#00FF7F",
            steelblue : "#4682B4",
            tan : "#D2B48C",
            teal : "#008080",
            thistle : "#D8BFD8",
            tomato : "#FF6347",
            turquoise : "#40E0D0",
            violet : "#EE82EE",
            wheat : "#F5DEB3",
            white : "#FFFFFF",
            whitesmoke : "#F5F5F5",
            yellow : "#FFFF00",
            yellowgreen : "#9ACD32"
        },

        /**
         * 지정한 colorName 에 해당하는 color Hex 코드를 반환.
         * @param {String} colorStr		- 컬러 이름(영문)
         * @returns {String}
         */
        getColorNameToHex : function(colorStr) {
            if (!colorStr && typeof colorStr != "string") {
                return "";
            }

            colorStr = colorStr.toLowerCase();
            return this.colorNameMap[colorStr] || "";
        },

        // childNodesMap method 에서 사용하는 내부 함수 (계속 search)
        _search : function(context, cNode, order, ignoreSelector, callback) {
            if (cNode.nodeType === Node.ELEMENT_NODE && cNode.childNodes.length > 0) {
                this.childNodesMap(context, cNode, order, ignoreSelector, callback);
            }
        },

        // childNodesMap method 에서 사용하는 내부 함수 (callback 수행)
        _fn : function(context, cNode, callback) {
            var exec = null;
            if (typeof callback === "function") {
                exec = callback;
            } else if(callback.exec) {
                exec = callback.exec;
            }

            if (context._stopLoop || exec(cNode) === false) {
                context._stopLoop = true;
            }
        },

        /**
         *	대상이 되는 모든 node의 child node를 탐색하여 callback 실행
         *	@param {object} context						- scope object
         *	@param {Element} node							- html dom element
         *	@param {string} order							- 탐색 순서
         *		=> "" : 상위 노드에서 부터 callback 될 경우 오름차순
         *		=> "desc" : 하위 노드에서 부터 callback 될 경우 order["desc"] 내림차순
         *	@param {string|jQuery object} ignoreSelector	- 제외 대상 셀렉터(jQuery Selector)
         *  @param {Object|Function} callback
         */
        childNodesMap : function(context, node, order, ignoreSelector, callback) {
            if (! context._originalNode) {
                context._originalNode = node;
            }

            // callback : 모든 childNode 에 대한 callback
            // ps. callback 내에서 return false 를 하면  stop

            if (! node) {
                return ;
            }

            var childNodes = []
                ,	i
                ,	child
                ,	length = 0;

            if (node instanceof $ || node instanceof Array) {
                childNodes = node;
                length = node.length;
            } else {
                childNodes = node.childNodes;
                length = childNodes.length;
            }

            if (context._stopLoop || (callback.filter && callback.filter(node) === false)) {
                return ;
            }

            for (i = 0; i < length; i++) {
                child = childNodes[i];

                if (context._stopLoop) {
                    break;
                }

                if (ignoreSelector && this.matches(child, ignoreSelector)) {
                    if (callback && callback.ignore) {
                        callback.ignore(child);
                    }
                    continue;
                }

                if (callback.filter && callback.filter(child) === false) {
                    continue;
                }

                if (order && order === "desc") {
                    this._search(context, child, order, ignoreSelector, callback);
                    this._fn(context, child, callback);
                } else {
                    this._fn(context, child, callback);
                    this._search(context, child, order, ignoreSelector, callback);
                }
            }

            if (context._originalNode === node) {
                delete context._originalNode;
                delete context._stopLoop;
            }
        },

        /**
         *	시작 노드부터 탐색을 하여 끝 노드까지 하위 depth, 상위 depth를 탐색
         *	@param {Element} startNode	- 시작 노드
         *	@param {Element} reachNode	- 도달 노드
         *	@param {function} callback	- reachNode에 도달했을경우 callback
         */
        /*findReachNodeToStart : function(startNode, reachNode, callback) {
         if (!startNode || !reachNode || !callback) {
         return;
         }

         var _this = this
         ,	found = false
         ,	parentNode;

         while (startNode) {
         // 하위 노드가 있다면 하위 노드로 탐색
         if (startNode.nodeType == 1) {
         found = false;
         _this.childNodesMap(this, startNode, "desc").each(function(node) {
         if (node == reachNode) {
         callback.done(node);
         found = true;
         return false;
         }

         callback.on(node);
         });

         if (found) {
         break;
         }
         }

         // 다음 또는 상위로 존재하는 엘리먼트를 탐색.
         if (startNode.nextSibling) {
         startNode = startNode.nextSibling;
         } else {
         parentNode = startNode.parentNode;
         while (!parentNode.nextSibling) {
         if (!parentNode.parentNode) {
         break;
         }

         parentNode = parentNode.parentNode;
         }

         startNode = parentNode.nextSibling;
         }

         // 현재노드가 reachNode와 동일하면 stop
         if (startNode) {
         if (startNode == reachNode) {
         callback.done(startNode);
         break;
         } else {
         callback.on(startNode);
         }
         }
         }

         if (!startNode) {
         callback.fail();
         }
         },*/

        // unicode 인지 아닌지 여부를 return
        /*isUnicode : function(s) {
         return /[^\\u0000-\\u00ff]/.test(s);
         },*/

        /**
         * 숫자 인지 여부 return
         * @param {Number} n
         * @returns {boolean}
         */
        isNumber : function(n) {
            return !isNaN(parseFloat(n)) && isFinite(n);
        },

        /**
         * 실수형인지 여부 반환
         * @param {*} n
         * @returns {boolean}
         */
        isFloat : function(n) {
            return n === +n && n !== (n|0);
        },

        /**
         * 정수형인지 여부 반환
         * @param {*} n
         * @returns {boolean}
         */
        isInteger : function(n) {
            return n === +n && n === (n|0);
        },

        /**
         * Array 인지 여부 반환
         * @param {*} value
         * @returns {boolean}
         */
        isArray : function (value) {
            return value &&
                typeof value === "object" &&
                typeof value.length === "number" &&
                typeof value.splice === "function" &&
                ! (value.propertyIsEnumerable("length"));
        },

        /**
         * Object 인지 여부 반환
         * @param {*} value
         */
        isObject : function(value) {
            return value !== null && typeof value === "object" && value.constructor === Object;
        },

        /** 두 array 가 갖고 있는 item 비교해서 모두 같은지 여부 반환
         * @param {Array} array1
         * @param {Array} array2
         * @param {boolean=} needSort - 정렬 후 비교하려면 true 지정 (순서무관 비교)
         * @return {boolean} 같은지 여부
         * @author <a href="mailto:igkang@hancom.com">강인구</a>
         */
        isEqualArray : function(array1, array2, needSort) {
            if (!(this.isArray(array1) && this.isArray(array2))) {
                return false;
            }

            if (array1 === array2) {
                // 같은 Ref Array
                return true;
            }

            var array1Len = array1.length
                ,	array2Len = array2.length
                ,	isEqual = false
                ,	i;

            if (array1Len === array2Len) {
                // 기본 isEqual = true 로 시작
                isEqual = true;

                if (needSort) {
                    // 원본 변경 없이 sort
                    array1 = array1.slice(0).sort();
                    array2 = array2.slice(0).sort();
                }

                i = 0;
                while (isEqual && i < array1Len) {
                    // 다른 item 이 있으면 isEqual = false 되면서 종료, 마지막까지 검사
                    isEqual = (array1[i] === array2[i]);
                    i++;
                }
            } // 길이 다르면 false

            return isEqual;
        },

        /**
         * parentNode 몰라도 그냥 baseNode의 after에 insertNode를 삽입
         * 즉, $(baseNode).after(insertNode)와 같은 기능
         * @param baseNode		{Node}	기준으로 삼고 싶은 노드. 즉 이 노드 뒤에 삽입
         * @param insertNode	{Node}	삽입하고자 하는 노드
         * @author <a href="mailto:koronya@hancom.com">신기훈</a>
         */
        insertAfter : function (baseNode, insertNode) {
            if (!(baseNode && insertNode)) {
                return;
            }

            var parentNode = baseNode.parentNode;
            if (!parentNode) {
                return;
            }

            // baseNode.nextSibling이 없으면 알아서 제일 뒤에 넣음
            parentNode.insertBefore(insertNode, baseNode.nextSibling);
        },

        /**
         * parentNode 몰라도 그냥 baseNode의 before에 insertNode를 삽입
         * 즉, $(baseNode).before(insertNode)와 같은 기능
         * @param baseNode		{Node}	기준으로 삼고 싶은 노드. 즉 이 노드 앞에 삽입
         * @param insertNode	{Node}	삽입하고자 하는 노드
         * @author <a href="mailto:koronya@hancom.com">신기훈</a>
         */
        insertBefore : function (baseNode, insertNode) {
            if (!(baseNode && insertNode)) {
                return;
            }

            var parentNode = baseNode.parentNode;
            if (!parentNode) {
                return;
            }

            parentNode.insertBefore(insertNode, baseNode);
        },

        /**
         * node를 wrapNode로 parent에 감싸줄 것을 지시하는 함수
         * $(node).wrap(wrapNode)와 같은 기능
         * 	span노드를 p로 감싸고 싶으면, wrap(span, p)와 같이 호출
         * @param node		{Node}	감싸지고 싶은 노드
         * @param wrapNode	{Node}	실제로 감쌀 노드
         * @author <a href="mailto:koronya@hancom.com">신기훈</a>
         */
        wrap : function (node, wrapNode) {
            if (!(node && wrapNode)) {
                return;
            }

            var parentNode = node.parentNode
                ,	nodeIdx;

            if (!parentNode) {
                return;
            }

            // wrapNode를 node의 before에 먼저 삽입 하고, node를 wrapNode의 child로 append!
            parentNode.insertBefore(wrapNode, node);
            wrapNode.appendChild(node);
        },

        /**
         * node의 부모 요소를 제거하는 함수
         * $(node).unwrap()과 같은 기능
         * 	<p><span1><span>123456789</span><span><br/></span><span><br/></span></span1></p>
         * 	위와 같은 상황에서 unwrap(span)을 해주면
         * 		결과는 <p><span>123456789</span><span><br/></span><span><br/></span></p>
         * @param node	{Node}	제거하고자 하는 부모의 자식노드
         * @author <a href="mailto:koronya@hancom.com">신기훈</a>
         */
        unwrap : function (node) {
            if (!node) {
                return;
            }

            var parentNode = node.parentNode
                ,	ancestorNode = parentNode.parentNode
                ,	childNodes = parentNode.childNodes
                ,	childNodesLen = childNodes.length
                ,	i;

            if (parentNode && ancestorNode) {
                for (i = 0 ; i < childNodesLen ; i++) {
                    // insertBefore를 하면, dom적으로 노드가 옮겨지므로, 제일 첫번째 것을 계속 순회하면 된다.
                    //this.insertBefore(parentNode, childNodes[i]);
                    this.insertBefore(parentNode, childNodes[0]);
                }
                ancestorNode.removeChild(parentNode);
            }
        },

        /**
         * number 를 소수 n번째(limit) 자리까지 나타나게 반올림
         * limit 를 지정 안하면 소수 4번째 자리까지 반올림함
         * @param {Number} number
         * @param {Number=} limit 소수 n번째 자리까지 나타내기 위할 때의 n
         * @returns {Number}
         * @author <a href="mailto:koronya@hancom.com">신기훈</a>
         */
        getRoundNumber : function (number, limit) {
            var limitNumber;
            if (limit === undefined) {
                limit = 4;
            }

            limitNumber = Math.pow(10, limit);
            return Math.round(number * limitNumber) / limitNumber;
        },

        /**
         * number 를 소수 n번째(limit) 자리까지 나타나게 올림
         * @param {Number} number
         * @param {Number=} limit		- default : 4
         * @returns {Number}
         */
        getCeilNumber : function (number, limit) {
            var limitNumber;
            if (limit === undefined) {
                limit = 4;
            }

            limitNumber = Math.pow(10, limit);
            return Math.ceil(number * limitNumber) / limitNumber;
        },

        /**
         * number 를 소수 n번째(limit) 자리까지 나타나게 내림
         * @param {Number} number
         * @param {Number=} limit		- default : 4
         * @returns {Number}
         */
        getFloorNumber : function (number, limit) {
            var limitNumber;
            if (limit === undefined) {
                limit = 4;
            }

            limitNumber = Math.pow(10, limit);
            return Math.floor(number * limitNumber) / limitNumber;
        },

        /**
         *	아라비아 숫자를 로마자로 변경하여 반환
         *	@param {Number} num				- 변경할 숫자
         *	@param {Boolean} isLowerCase	- 소문자로 반환할지 여부
         *	@param {Boolean} isClassical	- Classical Style 로 반환할지 여부(false 면 Original 로 반환)
         */
        getArabicToRoman : function(num, isLowerCase, isClassical) {
            var val = ""
                ,	romanNum = ["IIII", "V", "XXXX", "L", "CCCC", "D", "MMMM"]
                ,	romanLen = romanNum.length
                ,	i
                ,	x
                ,	d;

            if (isClassical === undefined) {
                isClassical = true;
            }

            for (i = 0; i < romanLen; i++) {
                x = romanNum[i].length + 1;
                d = num % x;

                val = romanNum[i].substr(0, d) + val;
                num = (num - d) / x;
            }

            if (isClassical) {
                val = val.replace(/DCCCC/g, "CM");
                val = val.replace(/CCCC/g, "CD");
                val = val.replace(/LXXXX/g, "XC");
                val = val.replace(/XXXX/g, "XL");
                val = val.replace(/VIIII/g, "IX");
                val = val.replace(/IIII/g, "IV");
            }

            if (isLowerCase) {
                val = val.toLowerCase();
            }

            return val;
        },

        /**
         * Object 형식의 Style 을 cssText 형식의 String 으로 변환하여 반환.
         * @param {Object} obj				- Style Object
         * @param {Boolean=} isReverse		- key 값과 value 값을 반대로 변환할지 여부
         * @returns {String}				- cssText 형식의 String
         */
        getCustomStyleToStyleObj : function(obj, isReverse) {
            var cssText = ""
                ,	arrCss = []
                ,	key
                ,	itemVal
                ,	cssVal;

            if (!obj || typeof obj !== "object") {
                return cssText;
            }

            for (key in obj) {
                itemVal = obj[key];
                cssVal = "";

                if (itemVal || itemVal === 0) {
                    if (isReverse === true) {
                        cssVal = itemVal + ":" + key;
                    } else {
                        cssVal = key + ":" + itemVal;
                    }

                    arrCss.push(cssVal);
                }
            }

            if (arrCss.length) {
                cssText = arrCss.join(";");
            }

            return cssText;
        },

        /**
         * Node 의 Style 또는 String Style 값을 Object 형태로 변환하여 반환.
         * @param {(Element|String)} node		- Node 또는 String Style
         * @param {Boolean=} isReverse		- key 값과 value 값을 반대로 변환할지 여부
         * @returns {Object}
         */
        getStyleObjToCustomStyle : function(node, isReverse) {
            var cssText = ""
                ,	cssValues = {}
                ,	cssTextList
                ,	css
                ,	arr
                ,	key
                ,	value;

            if (typeof node === "string") {
                if (node && node.indexOf(":") !== -1) {
                    cssText = node;
                }
            } else {
                if (node && node.style) {
                    cssText = node.style.cssText;
                }
            }

            if (!cssText) {
                return cssValues;
            }

            cssText = cssText.replace(/^\s*|\s*$/g, "");
            cssTextList = cssText.split(";");

            for (css in cssTextList) {
                if (cssTextList[css] != "") {
                    arr = cssTextList[css].split(/:(.+)/);
                    key = arr[0].replace(/^\s*|\s*$/g, "");
                    value = arr[1].replace(/^\s*|\s*$/g, "");

                    if (key && value) {
                        if (isReverse === true) {
                            cssValues[value] = key;
                        } else {
                            cssValues[key] = value;
                        }
                    }
                }
            }

            return cssValues;
        },

        /**
         * node 의 inline css 스타일 정보를 Object 형태로 리턴
         * @param {Element} node
         * @returns {Object}
         */
        getCssStyleObj : function(node) {
            if (!node || !node.style) {
                return null;
            }

            var cssObj = {}
                ,	cssText = node.style.cssText
                ,	cssTextList = cssText.split(";")
                ,	css
                ,	arr
                ,	key
                ,	value;

            for (css in cssTextList) {
                if (cssTextList[css].trim() != "") {
                    arr = cssTextList[css].split(":");
                    key = arr[0].replace(/^\s*|\s*$/g, "");
                    value = arr[1].replace(/^\s*|\s*$/g, "");

                    if (key == "color") {
                        value = this.getRgbToHex(value);
                    }

                    key = $.camelCase(key);
                    cssObj[key] = value;
                }
            }

            return cssObj;
        },

        /**
         * 지정한 cssText 를 지정한 노드에 등록한다.
         * @param {Element} node			- 대상 엘리먼트
         * @param {String} cssText			- 등록할 cssText
         */
        setCssTextToNode : function(node, cssText) {
            if (!(node && cssText)) {
                return;
            }

            var tempNode = document.createElement("span")
                ,	styleObj
                ,	key
                ,	item;

            tempNode.style.cssText = cssText;
            styleObj = this.getCssStyleObj(tempNode);

            for (key in styleObj) {
                item = styleObj[key];
                if (item) {
                    node.style[key] = item;
                }
            }
        },

        /**
         * User Data 정보를 리턴.
         * @param {Element} node		- 대상 노드
         * @param {String} name		- Data Attribute Name
         * @returns {String}
         */
        getData : function(node, name) {
            return ($(node).length) ? $(node).data(name) : "";
        },

        /**
         * User Data 를 생성.
         * @param {Element} node		- 대상 노드
         * @param {String} name		- Data Attribute Name
         * @param {String} val			- Data Value
         */
        createData : function(node, name, val) {
            $(node)
                .removeData(name)
                .attr('data-' + name, val);
        },

        /**
         * User Data 를 삭제.
         * @param {Element} node		- 대상 노드
         * @param {String} name		- Data Attribute Name
         */
        removeData : function(node, name) {
            $(node)
                .removeData(name)
                .removeAttr('data-' + name);
        },

        /**
         * 지정한 String Data에 포함된 공백을 웹문서에서 유효하게 표현할수 있도록 변환하여(&nbsp) 반환
         * @param {String} data
         * @returns {String}
         */
        changeSpaceToNbsp : function(data) {
            data = data.replace(/\&nbsp;/g, " ");

            //문단의 맨 처음이 공백인 경우 nbsp로 대체해준다.
            data = data.replace(/(<(?:span|font)[^>]*>)[ ]/gi, function(a, b) {
                if (!a) {
                    return "";
                }

                return b + "\u00a0";
            });

            data = data.replace(/[ ]{2,}/g, function(spaceVal) {
                var changeVal = " "
                    ,	i
                    ,	newSpaceVal;

                if (spaceVal.length > 1) {
                    for (i = 0; i < spaceVal.length - 1; i++) {
                        newSpaceVal = ((i % 2) === 0) ? "\u00a0" : " ";
                        changeVal += newSpaceVal;
                    }
                } else if(spaceVal.length == 1) {
                    changeVal = "\u00a0";
                } else {
                    changeVal = spaceVal;
                }

                return changeVal;
            });

            //span과 span 사이 공백이 연달아 있는 경우 앞의 공백은 살려주고 뒤에 공백은 nbsp로 대체해준다.
            data = data.replace(/([ ]<\/(?:span|font)\s*><(?:span|font)[^>]*>)[ ]/gi, function(a, b) {
                if (!a) {
                    return "";
                }

                return b + "\u00a0";
            });

            //문단의 맨 마지막이 공백인 경우 nbsp로 대체해준다.
            data = data.replace(/[ ](<\/(?:span|font)\s*>)/gi, function(a, b) {
                if (!a) {
                    return "";
                }

                return "\u00a0" + b;
            });

            return data;
        },

        /**
         * embed노드를 input으로 건내주면, 그 안에 svgDocument가 load되었는지를 체크해서
         *  load되었으면 그 svgDocument를 리턴하고
         *  그렇지 않으면 null을 리턴한다.
         *
         * @param embed 검사할 embed
         * @returns {*}
         * @author <a href="mailto:koronya@hancom.com">신기훈</a>
         */
        getSVGDocument : function (embed) {
            var svgDoc = null
                ,	svg = null;

            /**
             * E의 경우 embed안에 svg가 load되지 않은 경우에 getSVGDocument()를 하면 죽는다.
             * 따라서, 해당 경우에 load되지 않은 것이므로 null을 return
             * 이미 load되었으면 load된 svgDoc을 return
             */
            try {
                svgDoc = embed.getSVGDocument();
                //MS Edge에서는 로딩 때 svgDoc이 있고, svg가 없으므로 svg가 있는지도 확인한다.
                svg = svgDoc ? svgDoc.getElementsByTagName('svg')[0] : null;
            } catch (exp) {
                console.warn(exp);
            }

            return (!svg) ? null : svgDoc;
        },

        /**
         *	시작시간과 종료시간의 차이(소요시간)를 콘솔창에 출력
         *	@param {Object} startTime	- 시작시간(new Date().getTime())
         *	@param {Object} endTime	- 종료시간(new Date().getTime())
         *	@param {string} msg				- 콘솔에 소요시간과 함께 출력할 문자
         */
        printDiffTimeCount : function(startTime, endTime, msg) {
            var elapsed = endTime - startTime;
            console.log(msg + " Diff Time Count : " + (elapsed / 1000));
        },

        /**
         * 지정한 노드의 자식노드중 모든 텍스트노드를 배열로 반환
         * @param {Element} node			- 텍스트노드를 추출할 대상 노드
         * @param {Array} ret				- 리턴 받을 배열 지정 (ret Parameta는 지정하지 않아도 됨.)
         * @returns {Array}
         */
        getTextNodes : function(node, ret) {
            var textNodes = ret || []
                ,	nodes = node.childNodes
                ,	len = nodes.length
                ,	i
                ,	cur;

            for (i = 0; i < len; ++i) {
                cur = nodes[i];

                if (cur.nodeType === 1) {
                    this.getTextNodes(cur, textNodes);
                } else if (cur.nodeType === 3) {
                    textNodes.push(cur);
                }
            }

            return textNodes;
        },

        /**
         * Native Element.normalize 가 정상 동작 안하는 브라우저는 직접 구현한 모듈로 실행하고 아니면 Native 로 실행함.
         * @param {Element} ele
         */
        safeNormalize : function(ele) {
            if (!ele || ele.nodeType === 3) {
                return;
            }

            if (!($.browser.msie && $.browser.version && parseInt($.browser.version, 10) <= 11)) {
                ele.normalize();
                return;
            }

            var textNodes = this.getTextNodes(ele)
                ,	len = textNodes.length
                ,	i
                ,	item
                ,	target
                ,	idx
                ,	nextNode;

            if (len === 0) {
                return;
            }

            for (i = 0; i < len; i++) {
                item = textNodes[i];
                target = null;

                if (item) {
                    target = item.nextSibling;

                    while (target) {
                        if (target.nodeType === 3) {
                            idx = textNodes.indexOf(target);
                            nextNode = target.nextSibling;

                            if (idx != -1) {
                                textNodes[idx] = null;
                            }

                            if (target.nodeValue !== "") {
                                item.nodeValue += target.nodeValue;
                            }

                            target.parentNode.removeChild(target);
                            target = nextNode;
                        } else {
                            break;
                        }
                    }
                }
            }
        },

        /**
         * 지정한 String 을 camelCase 로 변환하여 반환. $.camelCase 와 동일하나 하이픈(-) 뿐만 아니고, 언더바(_)도 camelCase 로 변환함.
         * @param {String} name
         * @returns {String}
         */
        multiCamelCase : function(name) {
            if (!name || typeof name !== "string") {
                return name;
            }

            var arrNames = null
                ,	i = -1
                ,	len = -1
                ,	rename = name;

            if (rename.indexOf("-") !== -1) {
                arrNames = rename.split("-");
                len = arrNames.length;
                rename = "";

                for (i = 0; i < len; i++) {
                    rename += (i === 0) ? arrNames[i] : this.getUCFirst(arrNames[i]);
                }
            }

            if (rename.indexOf("_") !== -1) {
                arrNames = rename.split("_");
                len = arrNames.length;
                rename = "";

                for (i = 0; i < len; i++) {
                    rename += (i === 0) ? arrNames[i] : this.getUCFirst(arrNames[i]);
                }
            }

            return rename;
        },

        /**
         *	map을 바탕으로 template keyword를 가지는 expression string의 내용을 치환한다.
         *	매치되는 template keyword가 없다면 해당 template keyword는 제거됨
         *
         *	Example
         *
         *	str = "발견된 단어의 개수는 ${num}개 입니다";
         *	Util.substitute(str, {num : 1});
         *		=> 발견된 단어의 개수는 1개 입니다.
         *
         *	str = "총 ${sentences}개의 문장에서 ${keywords}개의 검색결과를 찾았습니다";
         *	Util.substitute(str, {keywords : 3});
         *		=> 총 개의 문장에서 3개의 검색결과를 찾았습니다.
         */
        substitute : function(strExpression, matchMap) {
            var resStr = strExpression || "";

            $.each(matchMap, function(key, value) {
                resStr = resStr.replace("${" + key + "}", value);
            });

            resStr = resStr.replace(/\$\{(.*)\}/g, "");

            return resStr;
        },

        /**
         * 이진검색 알고리즘
         * @param {Array} arr
         * @param {Number} lowIdx			- included
         * @param {Number} highIdx			- included
         * @param {Function=} funcCompare
         * @param {any} funcContext
         * @param {Boolean=} returnOnlyEqualIndex		- false 이면, 가장 근접한 값 중 낮은 index 를 반환한다.
         */
        binarySearch : function (arr, value, lowIdx, highIdx, funcCompare, funcContext, returnOnlyEqualIndex) {
            var	mid = Math.floor((lowIdx + highIdx) / 2)
                ,	curValue = arr ? arr[mid] : null
                ,	resCompare = 0;

            if (lowIdx > highIdx) {
                // Not Found
                if (returnOnlyEqualIndex) {
                    return -1;
                }

                // 정확한 index 를 찾을 수 없으면, value 보다 작은 값들 중 value 에 가장 근접한 index 를 반환한다.
                do {
                    mid = highIdx;
                    if (mid == -1) {
                        break;
                    }

                    curValue = arr ? arr[mid] : null;
                    resCompare = funcCompare;
                    if (funcCompare) {
                        resCompare = funcCompare.call(funcContext, mid, curValue, value);
                    } else {
                        resCompare = curValue - value;
                    }
                    highIdx -= 1;
                } while (resCompare >= 0);

                return mid;
            }

            if (funcCompare) {
                resCompare = funcCompare.call(funcContext, mid, curValue, value);

                if (resCompare === 1) {
                    return this.binarySearch(arr, value, lowIdx, mid-1, funcCompare, funcContext, returnOnlyEqualIndex);
                }

                if (resCompare === -1) {
                    return this.binarySearch(arr, value, mid+1, highIdx, funcCompare, funcContext, returnOnlyEqualIndex);
                }

                return mid;
            }

            if (curValue > value) {
                return this.binarySearch(arr, value, lowIdx, mid-1, funcCompare, funcContext, returnOnlyEqualIndex);

            }

            if (curValue < value) {
                return this.binarySearch(arr, value, mid+1, highIdx, funcCompare, funcContext, returnOnlyEqualIndex);

            }

            return mid;
        },

        /**
         * 테이블노드 안에서 지정한 Depth의 Tag 노드를 추출하여 반환.
         * @param {Element} targetNode			- 대상 테이블 노드 (또는 TBODY, TR, TD도 지원함)
         * @param {String} tag					- 추출할 태그명 ("TABLE", "TBODY", "TR", "TD" 만 지원함.)
         * @param {Number} depth				- 추출할 Depth
         * @param {Boolean=} isDepthAllChild	- Depth 이하의 Child를 모두 추출할지 여부
         * @returns {Array}					- 추출된 노드 리스트
         */
        findTableDepth : function(targetNode, tag, depth, isDepthAllChild) {
            var acceptTags = ["TABLE", "TBODY", "TR", "TD"]
                ,	findChilds = []
                ,	findDepthTables = []
                ,	findValidTables = []
                ,	i = 0
                ,	len = -1
                ,	baseTable = targetNode;

            if (!(baseTable && typeof tag === "string")) {
                return findChilds;
            }

            if (baseTable.nodeName !== "TABLE") {
                baseTable = this.findParentTagNode(baseTable, "table");
            }

            if (!baseTable) {
                return findChilds;
            }

            tag = tag.toUpperCase();

            if (acceptTags.indexOf(tag) === -1) {
                return findChilds;
            }

            if (!this.isNumber(depth)) {
                depth = 0;
            } else {
                if (typeof depth === "string") {
                    depth = parseInt(depth, 10);
                }
            }

            if (depth === 0) {
                if (!isDepthAllChild) {
                    var curNodeName = targetNode.nodeName;

                    // 0 depth에서 targetNode가 table이 아닐경우는 TR, TD만 인정하고 나머지는 인정하지 않는다.
                    if (curNodeName !== "TABLE" && (tag === "TABLE" || tag === "TBODY")) {
                        return findChilds;
                    }

                    if (curNodeName === "TABLE" && tag === "TABLE") {
                        findChilds.push(targetNode);
                    } else if (curNodeName !== "TD") {
                        findValidTables.push(targetNode);
                    }
                } else {
                    findValidTables.push(targetNode);
                }
            } else {
                findDepthTables = targetNode.querySelectorAll("table");
            }

            // depth 를 구분해야 하는 경우, 하위 유효한 테이블을 탐색한다.
            if (findDepthTables.length) {
                if (depth > 0) {
                    var cnt
                        ,	tbl
                        ,	checkNode;
                    len = findDepthTables.length;

                    for (i = 0; i < len; i++) {
                        cnt = 1;
                        tbl = findDepthTables[i];
                        checkNode = tbl.parentNode;

                        while (checkNode && checkNode !== baseTable) {
                            if (checkNode.nodeName === "TABLE") {
                                cnt++;
                            }

                            checkNode = checkNode.parentNode;
                        }

                        // depth 가 동일한 Table 만 추출한다.
                        if (cnt === depth) {
                            findValidTables.push(tbl);
                        }
                    }
                }
            }

            // 유효 테이블 내에서 지정한 Tag 를 탐색하여 추출한다.
            if (findValidTables.length) {
                len = findValidTables.length;

                var isWithSelf = false
                    ,	vTbl = null
                    ,	findItems = null;

                // 하위 depth 의 Tag 를 모두 추출해야 하는 경우의 처리
                if (isDepthAllChild === true) {
                    if (tag === "TABLE" && depth > 0) {
                        isWithSelf = true;
                    }

                    for (i = 0; i < len; i++) {
                        vTbl = findValidTables[i];
                        findItems = vTbl.querySelectorAll(tag);

                        if (isWithSelf === true && vTbl.nodeName === "TABLE") {
                            findChilds.push(vTbl);
                        }

                        findChilds = findChilds.concat(this.getCollectionToArray(findItems));
                    }
                } else {
                    // 현재 depth 만 추출 할 경우는, Native Property 를 활용하여 추출한다.
                    if (tag === "TABLE" && depth > 0) {
                        findChilds = findChilds.concat(this.getCollectionToArray(findValidTables));
                    } else {
                        var parentItems
                            ,	j
                            ,	cLen
                            ,	rowItem
                            ,	cells;

                        for (i = 0; i < len; i++) {
                            parentItems = null;
                            j = 0;
                            cLen = -1;
                            vTbl = findValidTables[i];

                            if (vTbl.nodeName === "TBODY") {
                                vTbl = vTbl.parentNode;
                            }

                            // 있을수 없으나, 혹시라도 vTbl node가 없으면 다음으로 넘긴다.
                            if (!vTbl) {
                                continue;
                            }

                            if (vTbl.nodeName === "TABLE") {
                                if (tag === "TBODY") {
                                    findChilds = findChilds.concat(this.getCollectionToArray(vTbl.tBodies));
                                } else {
                                    if (tag === "TR") {
                                        findChilds = findChilds.concat(this.getCollectionToArray(vTbl.rows));
                                    } else {
                                        parentItems = vTbl.rows;
                                        cLen = parentItems.length;
                                    }
                                }
                            } else {
                                if (vTbl.nodeName === "TR" && tag === "TD") {
                                    parentItems = [vTbl];
                                    cLen = parentItems.length;
                                }
                            }

                            if (cLen > 0) {
                                for (j = 0; j < cLen; j++) {
                                    rowItem = parentItems[j];
                                    cells = rowItem ? rowItem.cells : null;

                                    if (cells) {
                                        findChilds = findChilds.concat(this.getCollectionToArray(cells));
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return findChilds;
        },

        /**
         * Collection 을 Array 로 변환하여 반환
         * @param {HTMLCollection} collection		- 변환할 Collection
         * @returns {(Array|HTMLCollection)}		- 변환된 Array
         */
        getCollectionToArray : function(collection) {
            var newArr = collection;

            if (!(typeof collection === "object" && typeof collection.length === "number")) {
                return newArr;
            }

            if (typeof collection.splice !== "function") {
                try {
                    newArr = Array.prototype.slice.call(collection, 0);
                } catch (exp) {
                    var i
                        ,	len = collection.length;
                    newArr = [];

                    for (i = 0; i < len; i++) {
                        newArr[i] = collection[i];
                    }
                }
            }

            return newArr;
        },

        /**
         * rfc4122 version 4 compliant guid. http://byronsalau.com/blog/how-to-create-a-guid-uuid-in-javascript/
         * @returns {String}
         */
        generateGUID : function () {
            return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
                var	r = Math.random()*16|0
                    ,	v = (c === 'x' ? r : (r&0x3|0x8));

                return v.toString(16).toUpperCase();
            });
        },

        /**
         * 빈 객체인지 여부 반환. http://stackoverflow.com/questions/4994201/is-object-empty
         * @param {Object} obj
         * @returns {Boolean}
         */
        isEmptyObject : function (obj) {
            return (Object.keys(obj).length === 0);
        },

        //=============================== Optimized HTML DOM Manipulating Methods Begin =================================

        /**
         * element 의 classList 에 특정 클래스 이름이 있는지 여부를 반환한다.
         * http://jsperf.com/hasclass-jykim
         * @param {Element} el							- 대상 노드
         * @param {(String|Array)} className			- selector 가 아닌 단순한 클래스 이름 또는 배열을 받는다.
         * @return {boolean}
         */
        hasClass : function (el, className) {
            if (!(el && el.nodeType === 1 && className)) {
                return false;
            }

            var classList = el.classList || (el.getAttribute("class") || "").split(" "),
                classListLength = classList.length,
                clsArrLen = 0,
				result = false,
                i, j;

            if (this.isArray(className)) {
                clsArrLen = className.length;
                for (i = 0; i < clsArrLen; i++) {
                    for (j = 0; j < classListLength; j++) {
                        if (classList[j] == className[i]) {
                            result = true;
                            break;
                        }
                    }
                    if (result) {
                        break;
                    }
                }
            } else {
                for (i = 0; i < classListLength; i++) {
                    if (classList[i] == className) {
                        result = true;
                        break;
                    }
                }
            }

            return result;
        },

        /**
         * 지정한 노드에 클래스를 추가한다.
         * @param {Element} el          - 대상 노드
         * @param {String} className    - 클래스명(복수일때는 스페이스로 구분)
         * @param {Boolean=} addFirst   - 맨 앞에 추가
         */
        addClass : function(el, className, addFirst) {
            if (!(el && el.nodeType === 1 && typeof className === "string")) {
                return false;
            }

            var strClass = el.getAttribute("class") || "",
                strAddClass = "",
                classNames = className.split(" "),
				len = classNames.length,
                spaceChar, i, cls;

            for (i = 0; i < len; i++) {
                cls = classNames[i];
                if (cls && !this.hasClass(el, cls)) {
                    strAddClass += (strAddClass ? " " : "") + cls;
                }
            }

            if (strAddClass) {
                spaceChar = strClass ? " " : "";
                strClass = addFirst ? (strAddClass + spaceChar + strClass) : (strClass + spaceChar + strAddClass);
				el.setAttribute("class", strClass);
				//el.className = strClass + strAddClass;
            }
        },

        /**
         * 지정한 노드의 클래스를 삭제한다.
         * @param {Element} el			- 대상 노드
         * @param {String} className	- 클래스명(복수일때는 스페이스로 구분)
         */
        removeClass : function(el, className) {
            if (!(el && el.nodeType === 1 && typeof className === "string")) {
                return;
            }

            var classNames = className.split(" "),
                classList = el.classList || (el.getAttribute("class") || "").split(" "),
				len = classNames.length,
				clsLen = classList.length,
                isClassList = !!(el.classList),
                delClass = [],
                i, j, z, cls;

            if (!clsLen) {
                return;
            }

            for (i = 0; i < len; i++) {
                cls = classNames[i];
                if (cls) {
                    if (isClassList === true) {
                        classList.remove(cls);
                    } else {
                        for (j = 0; j < clsLen; j++) {
                            if (classList[j] === cls) {
                                delClass.push(j);
                                break;
                            }
                        }
                    }
                }

            }

            if (delClass.length) {
                var newClass = "";
                for (z = 0; z < classList.length; z++) {
                    if (delClass.indexOf(z) === -1) {
                        newClass += (newClass ? " " : "") + classList[z];
                    }
                }

				el.setAttribute("class", newClass);
				//el.className = newClass;
            }

			if (!el.getAttribute("class")) {
				el.removeAttribute("class");
			}
        },

        /**
         * 지정한 노드의 클래스 이름을 변경한다.
         * @param {Element} el					- 대상 노드
         * @param {(String|Object)} className	- 클래스명(복수일때는 Object)
         * @param {String=} replaceName		- 변경할 클래스명
         */
        replaceClass : function(el, className, replaceName) {
            if (!(el && el.nodeType === 1 && className)) {
                return;
            }

            if (typeof className === "string" && typeof replaceName !== "string") {
                return;
            }

            var objClass = {},
                classList = (el.getAttribute("class") || "").split(" "),
                clsLen = classList.length,
                useReplace = false,
				cls, rename, idx;

            if (!clsLen) {
                return;
            }

            if (typeof className === "object") {
                objClass = className;
            } else {
                objClass[className] = replaceName;
            }

            for (cls in objClass) {
                rename = objClass[cls];
                idx = classList.indexOf(cls);

                if (cls !== rename && idx !== -1) {
                    if (classList.indexOf(rename) === -1) {
                        classList[idx] = rename;
                        useReplace = true;
                    }
                }
            }

            if (useReplace === true) {
				el.setAttribute("class", classList.join(" "));
				//el.className = classList.join(" ");
            }
        },

        /**
         * 지정한 노드의 클래스가 있으면 삭제하고, 없으면 추가한다.
         * @param {Element} el			- 대상 노드
         * @param {String} className	- 클래스명(복수일때는 스페이스로 구분)
         */
        toggleClass : function(el, className) {
            if (!(el && el.nodeType === 1 && typeof className === "string")) {
                return;
            }

            var classNames = className.split(" "),
				len = classNames.length,
                i, cls;

            for (i = 0; i < len; i++) {
                cls = classNames[i];

                if (cls) {
                    if (this.hasClass(el, cls)) {
                        this.removeClass(el, cls);
                    } else {
                        this.addClass(el, cls);
                    }
                }
            }
        },

        /**
         * element 의 내용을 모두 비운다.
         * http://jsperf.com/jquery-html-vs-empty-vs-innerhtml
         * @param {Element} el
         */
        emptyNode : function (el) {
            var child = el.lastChild;

            while (child) {
                el.removeChild(child);
                child = el.lastChild;
            }
        },

        /**
         * node 를 parent (dom tree) 로부터 제외시킨다.
         * http://jsperf.com/jquery-remove-vs-childnode-remove/2
         * @param {Node} node
         */
        removeNode : function (node) {
            var parent = node.parentNode;

            if (parent) {
                parent.removeChild(node);
            }
        },

        /**
         * para node 를 위한 jQuery.fn.children(sel) 성능 최적화 메서드
         * hyperlink run 때문에 $.fn.find 를 쓰기엔 find 가 너무 느리다.
         * http://jsperf.com/find-vs-find-and-filter/15
         * a node 가 전달되면, 이를 hyperlink run 으로 간주한다.
         * http://jsperf.com/jquery-is-vs-tagname/6
         * @param {Element} para
         * @param {String=} sel
         * @returns {*}
         */
        childrenOfPara : function (para, sel) {
            var result
                ,	$para = $(para);

            // XHTML 에서는 nodeName 이 lowercase 로 올수 있음. 현재로선 HTML 용으로 uppercase 만 오는 것으로 간주한다.
            if (para.nodeName === "TABLE") {
                // TODO 테이블용 성능 개선
                result = $para.find(sel);

            } else {
                result = $para.children(sel);
                $.merge(result, $para.children("a").children(sel));
            }

            return result;
        },

        /**
         * 배열 원소들 중, 중복된 요소를 제외한 요소를 반환한다.
         * http://jsperf.com/array-unique2/26
         * @param {Array} arr
         * @returns {Array}
         */
        unique : function (arr) {
            var	result = []
                ,	i
                ,	arrLength = arr.length;

            if (typeof Set !== "undefined") {	// [IE<11] IE에서 미지원 스펙 객체에 직접 접근할 경우 죽는 문제 방지
                // ES6 의 Set 이 구현되어 있는 경우에 사용.
                var seen = new Set();

                for (i = 0; i < arrLength; i++) {
                    if (! seen.has(arr[i])) {
                        result[result.length] = arr[i];
                        seen.add(arr[i]);
                    }
                }

            } else {
                // ES6 의 Set 이 구현되지 않은 경우 Set 을 사용하지 않는 형태. (ES5 의 Array.prototype.indexOf)
                for (i = 0; i < arrLength; i++) {
                    if (result.indexOf(arr[i]) === -1) {
                        result[result.length] = arr[i];
                    }
                }
            }

            return result;
        },

        /**
         * container 에 item 이 포함되어 있는지 반환한다.
         * @param {(Array|Set)} container
         * @param {*} item
         * @returns {Boolean}
         */
        contains : function (container, item) {
            var result = false;

            if (container instanceof Array) {
                result = (container.indexOf(item) !== -1);

            } else if (container instanceof Set) {
                result = container.has(item);
            }

            return result;
        },

        /**
         * 지정한 Element 의 스크롤이 있는지 여부 반환.
         * @param {Element} ele
         * @param {String} strPos
         * @returns {Boolean}
         */
        hasScroll : function(ele, strPos) {
            var isScroll = false
                ,	scrollPos = (strPos === "top") ? "top" : "left"
                ,	scrollVal = -1
                ,	clientVal = -1;

            if (ele && ele.nodeType === 1) {
                scrollVal = (scrollPos === "top") ? ele.scrollHeight : ele.scrollWidth;
                clientVal = (scrollPos === "top") ? ele.clientHeight : ele.clientWidth;
            }

            if (scrollVal > -1 && clientVal > -1) {
                isScroll = (scrollVal !== clientVal);
            }

            return isScroll;
        },

        /**
         * 배열의 원소 중 지정한 원소를 제외하고 새로운 배열로 반환.
         * @param {Array} arr						- 원본 배열
         * @param {(Number|String|Array)} val		- 제외할 원소 (배열로 지정 가능)
         * @returns {Array}
         */
        without : function (arr, val) {
            if (!this.isArray(arr)) {
                return arr;
            }

            var newArr;

            // filter 에 사용될 콜백
            var checkCallBack = function(item) {
                var isCheck;

                if (val instanceof Array) {
                    isCheck = (val.indexOf(item) === -1);
                } else {
                    isCheck = (item !== val);
                }

                return isCheck;
            };

            if (arr.filter) {
                newArr = arr.filter(checkCallBack);
            } else {
                newArr = $.grep(arr, checkCallBack);
            }

            return newArr;
        },

        /**
         * array 요소를 shallow copy 한다.
         * http://jsperf.com/slice-vs-copy/10
         * @param {Array} arr
         * @returns {Array}
         */
        shallowCopyArray : function (arr) {
            var	result
                ,	len = arr.length
                ,	i;

//			result = [];
            result = new Array(len);
            for (i = 0; i < len; i++) {
                result[i] = arr[i];
            }

            return result;
        },

        /**
         * object 요소를 shallow copy 한다.
         * https://jsperf.com/cloning-an-object/2
         * @param {Object} obj
         * @param {Object=} mergeIn	- mergeIn 이 존재하면, mergeIn 에 obj 의 속성들이 덧씌워지고, 이 결과를 반환한다.
         * @returns {Object}
         */
        shallowCopyObject : function (obj, mergeIn) {
            var	target = mergeIn || {}
                ,	i;

            for (i in obj) {
                if (obj.hasOwnProperty(i)) {
                    target[i] = obj[i];
                }
            }
            return target;
        },

        /**
         * arr 의 요소를 reverse 한다. 원본 arr 의 순서가 변경된다. 주의요망.
         * https://jsperf.com/js-array-reverse-vs-while-loop/59
         * @param {Array} arr
         * @returns {*}
         */
        reverseArray : function (arr) {
            var	i
                ,	j
                ,	temp;

            for (i = 0, j = (arr.length - 1); i < j; i++, j--) {
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }

            return arr;
        },

        /**
         * 지정한 노드의 offsetWidth 값을 타입에 따라 반환 한다.
         * @param {Element} node		- offsetWidth 를 구할 대상 노드
         * @param {String=} type		- offsetWidth 을 구할 타입
         * 		- "accurate"			: offsetWidth 의 가장 정확한 값을 반환.(getBoundingClientRect 방식 - 소수점 8자리)
         * 		- "cssCalc"				: offsetWidth 를 css 랜더링 값을 계산하여 반환.(css sum 방식 - 대체로 소수점 2자리)
         * 		- "native"				: 노드의 offsetWidth property 값을 직접 반환 (property - 정수)
         * @returns {*}
         */
        getOffsetWidth : function(node, type) {
            var cssWidth
                ,	borderLeft
                ,	borderRight
                ,	paddingLeft
                ,	paddingRight
                ,	rect;

            if (!node || !node.parentNode) {
                return 0;
            }

            // 타입을 지정하지 않았으면, 가장 정교한 값을 반환하는 accurate 타입으로 지정한다.
            if (!type) {
                type = "accurate";
            }

            // native 타입이면 노드의 offsetWidth 값을 반환 한다.
            if (type === "native") {
                return node.offsetWidth;
            }

            // accurate 타입이면 노드의 getBoundingRect 정보 값을 반환 한다.(getBoundingRect 정보가 가장 정확한 값임.)
            if (type === "accurate") {
                rect = node.getBoundingClientRect();

                // rect 값이 있으면 반환 한다. 만일 없으면 CSS 계산 방식으로 반환한다.
                if (rect) {
                    return rect.width;
                }
            }

            /**
             * native 또는 accurate 타입이 아니면 CSS 계산 방식으로 반환 한다.
             * 계산 방식은 컨텐츠 너비 + 좌측 선 너비 + 우측 선 너비 + 좌측 여백 + 우측 여백
             */
            cssWidth = parseFloat(this.getCurrentStyle(node, "width"));
            borderLeft = parseFloat(this.getCurrentStyle(node, "borderLeftWidth"));
            borderRight = parseFloat(this.getCurrentStyle(node, "borderRightWidth"));
            paddingLeft = parseFloat(this.getCurrentStyle(node, "paddingLeft"));
            paddingRight = parseFloat(this.getCurrentStyle(node, "paddingRight"));

            return (cssWidth + borderLeft + borderRight + paddingLeft + paddingRight);

        },

        /**
         * 지정한 노드의 offsetHeight 값을 타입에 따라 반환 한다.
         * @param {Element} node		- offsetHeight 를 구할 대상 노드
         * @param {String=} type		- offsetHeight 을 구할 타입
         * 		- "accurate"			: offsetHeight 의 가장 정확한 값을 반환.(getBoundingClientRect 방식 - 소수점 8자리)
         * 		- "cssCalc"				: offsetHeight 를 css 랜더링 값을 계산하여 반환.(css sum 방식 - 대체로 소수점 2자리)
         * 		- "native"				: 노드의 offsetHeight property 값을 직접 반환 (property - 정수)
         * @returns {*}
         */
        getOffsetHeight : function(node, type) {
            var cssHeight
                ,	borderTop
                ,	borderBottom
                ,	paddingTop
                ,	paddingBottom
                ,	rect;

            if (!node || !node.parentNode) {
                return 0;
            }

            // 타입을 지정하지 않았으면, 가장 정교한 값을 반환하는 accurate 타입으로 지정한다.
            if (!type) {
                type = "accurate";
            }

            // native 타입이면 노드의 offsetHeight 값을 반환 한다.
            if (type === "native") {
                return node.offsetHeight;
            }

            // accurate 타입이면 노드의 getBoundingRect 정보 값을 반환 한다.(getBoundingRect 정보가 가장 정확한 값임.)
            if (type === "accurate") {
                rect = node.getBoundingClientRect();

                // rect 값이 있으면 반환 한다. 만일 없으면 CSS 계산 방식으로 반환한다.
                if (rect) {
                    return rect.height;
                }
            }

            /**
             * native 또는 accurate 타입이 아니면 CSS 계산 방식으로 반환 한다.
             * 계산 방식은 컨텐츠 높이 + 상단 선 너비 + 하단 선 너비 + 상단 여백 + 하단 여백
             */
            cssHeight = parseFloat(this.getCurrentStyle(node, "height"));
            borderTop = parseFloat(this.getCurrentStyle(node, "borderTopWidth"));
            borderBottom = parseFloat(this.getCurrentStyle(node, "borderBottomWidth"));
            paddingTop = parseFloat(this.getCurrentStyle(node, "paddingTop"));
            paddingBottom = parseFloat(this.getCurrentStyle(node, "paddingBottom"));

            return (cssHeight + borderTop + borderBottom + paddingTop + paddingBottom);

        },

        /**
         * 지정한 노드의 clientWidth 값을 타입에 따라 반환 한다.
         * @param {Element} node		- clientWidth 를 구할 대상 노드
         * @param {String=} type		- clientWidth 을 구할 타입
         * 		- "accurate"			: clientWidth 의 가장 정확한 값을 반환.(getBoundingClientRect 방식 - 소수점 8자리)
         * 		- "cssCalc"				: clientWidth 를 css 랜더링 값을 계산하여 반환.(css sum 방식 - 대체로 소수점 2자리)
         * 		- "native"				: 노드의 clientWidth property 값을 직접 반환 (property - 정수)
         * @returns {*}
         */
        getClientWidth : function(node, type) {
            var cssWidth
                ,	borderLeft
                ,	borderRight
                ,	paddingLeft
                ,	paddingRight
                ,	rect;

            if (!node || !node.parentNode) {
                return 0;
            }

            // 타입을 지정하지 않았으면, 가장 정교한 값을 반환하는 accurate 타입으로 지정한다.
            if (!type) {
                type = "accurate";
            }

            // native 타입이면 노드의 clientWidth 값을 반환 한다.
            if (type === "native") {
                return node.clientWidth;
            }

            // accurate 타입이면 노드의 getBoundingRect 정보 값을 반환 한다.(getBoundingRect 정보가 가장 정확한 값임.)
            if (type === "accurate") {
                rect = node.getBoundingClientRect();

                /**
                 * rect 값이 있으면 반환 한다. 만일 없으면 CSS 계산 방식으로 반환한다.
                 * clientWidth 값은 border 가 제외 되어야 하는데, getBoundingRect 의 width 값은 border 정보가 포함된 값이다.
                 * 따라서 border 정보를 css 값으로 구해서 직접 빼준다.
                 */
                if (rect) {
                    borderLeft = parseFloat(this.getCurrentStyle(node, "borderLeftWidth"));
                    borderRight = parseFloat(this.getCurrentStyle(node, "borderRightWidth"));

                    return rect.width - borderLeft - borderRight;
                }
            }

            /**
             * native 또는 accurate 타입이 아니면 CSS 계산 방식으로 반환 한다.
             * 계산 방식은 컨텐츠 너비 + 좌측 여백 + 우측 여백
             */
            cssWidth = parseFloat(this.getCurrentStyle(node, "width"));
            paddingLeft = parseFloat(this.getCurrentStyle(node, "paddingLeft"));
            paddingRight = parseFloat(this.getCurrentStyle(node, "paddingRight"));

            return (cssWidth + paddingLeft + paddingRight);

        },

        /**
         * 지정한 노드의 clientHeight 값을 타입에 따라 반환 한다.
         * @param {Element} node		- clientHeight 를 구할 대상 노드
         * @param {String=} type		- clientHeight 을 구할 타입
         * 		- "accurate"			: clientHeight 의 가장 정확한 값을 반환.(getBoundingClientRect 방식 - 소수점 8자리)
         * 		- "cssCalc"				: clientHeight 를 css 랜더링 값을 계산하여 반환.(css sum 방식 - 대체로 소수점 2자리)
         * 		- "native"				: 노드의 clientHeight property 값을 직접 반환 (property - 정수)
         * @returns {Number}
         */
        getClientHeight : function(node, type) {
            var cssHeight
                ,	borderTop
                ,	borderBottom
                ,	paddingTop
                ,	paddingBottom
                ,	rect;

            if (!node || !node.parentNode) {
                return 0;
            }

            // 타입을 지정하지 않았으면, 가장 정교한 값을 반환하는 accurate 타입으로 지정한다.
            if (!type) {
                type = "accurate";
            }

            // native 타입이면 노드의 clientHeight 값을 반환 한다.
            if (type === "native") {
                return node.clientHeight;
            }

            // accurate 타입이면 노드의 getBoundingRect 정보 값을 반환 한다.(getBoundingRect 정보가 가장 정확한 값임.)
            if (type === "accurate") {
                rect = node.getBoundingClientRect();

                /**
                 * rect 값이 있으면 반환 한다. 만일 없으면 CSS 계산 방식으로 반환한다.
                 * clientHeight 값은 border 가 제외 되어야 하는데, getBoundingRect 의 height 값은 border 정보가 포함된 값이다.
                 * 따라서 border 정보를 css 값으로 구해서 직접 빼준다.
                 */
                if (rect) {
                    borderTop = parseFloat(this.getCurrentStyle(node, "borderTopWidth"));
                    borderBottom = parseFloat(this.getCurrentStyle(node, "borderBottomWidth"));

                    return rect.height - borderTop - borderBottom;
                }
            }

            /**
             * native 또는 accurate 타입이 아니면 CSS 계산 방식으로 반환 한다.
             * 계산 방식은 컨텐츠 높이 + 상단 여백 + 하단 여백
             */
            cssHeight = parseFloat(this.getCurrentStyle(node, "height"));
            paddingTop = parseFloat(this.getCurrentStyle(node, "paddingTop"));
            paddingBottom = parseFloat(this.getCurrentStyle(node, "paddingBottom"));

            return (cssHeight + paddingTop + paddingBottom);

        },

        /**
         * Similar to  _.findIndex (as of underscore v1.8.0)
         // TODO Support object typed cont variables if required.
         * @param {Array} array
         * @param {Function} callback
         * @param {Any=} context
         * @returns {number}
         */
        findIndex : function (array, callback, context) {
            if (!array || !array.length || !callback) {
                return -1;
            }

            var	result = -1
                ,	length = array.length
                ,	i;

            for (i = 0; i < length; i++) {
                if (callback.call(context, array[i])) {
                    result = i;
                    break;
                }
            }

            return result;
        },

        /**
         * HTML DOM querySelector() wrapper method.
         * Support several polyfill for CSS selectors.
         * @param {Node} node
         * @param {String} selectors
         * @returns {?Node}
         */
        querySelectorWrapped : function (node, selectors) {
            if (!node || !selectors) {
                return null;
            }

            try {
                return node.querySelector(selectors);
            } catch (e) {
                // polyfill
                if (/(^|,)\s*:scope/.test(selectors)) {	// Support ":scope" psuedo-selector. (FF, IE)
                    var	result
                        ,	id = node.id
                        ,	newSelectors;

                    node.id = 'ID_' + this.generateGUID();
                    newSelectors = selectors.replace(/((^|,)\s*):scope/g, "$1#" + node.id);
                    if (node.parentNode) {
                        result = node.parentNode.querySelector(newSelectors);
                    } else if (!/(,)/.test(selectors)) {
                        result = document.querySelector(newSelectors);
                    } else {
                        throw "Util.querySelectorWrapped() : doesn't support the selectors in this browser. \"" + selectors + "\"";
                    }
                    node.id = id;
                    return result;
                } else {
                    throw e;
                }
            }
        },

        /**
         * 지정한 엘리먼트의 outerHTML (Full HTML) 를 구한다.
         * @param {Element} el          - 대상 엘리먼트
         * @returns {String}            - outerHTML (Full HTML)
         */
        outerHTML : function (el) {
            if (!el) {
                return "";
            }

            var outerHTML = el.outerHTML,
                tempDiv;

            if (!outerHTML) {
                tempDiv = document.createElement("div");
                tempDiv.appendChild(el.cloneNode(true));
                outerHTML = tempDiv.innerHTML;
            }

            return outerHTML;
        },

        //=============================== Optimized HTML DOM Manipulating Methods End ==================================

        /**
         * 문자에 대한 코드 포인트를 반환
         * @param str - 문자열 객체
         * @param pos - 문자의 위치
         * @returns {*}
         */
        codePointAt : function (str, pos) {
            if (!str) {
                return undefined;
            }

            var size
                ,	index
                ,	first
                ,	second;

            if (String.prototype.codePointAt) {
                return str.codePointAt();
            }

            size = str.length;
            index = pos ? Number(pos) : 0;

            if (isNaN(index)) {
                index = 0;
            }

            if (index < 0 || index >= size) {
                return undefined;
            }

            first = str.charCodeAt(index);

            if (first >= 0xD800 && first <= 0xDBFF && size > index + 1) {
                second = str.charCodeAt(index + 1);
                if (second >= 0xDC00 && second <= 0xDFFF) {
                    return (first - 0xD800) * 0x400 + second - 0xDC00 + 0x10000;
                }
            }

            return first;
        },

        /**
         * 코드 포인트와 연결된 문자열을 반환
         * @returns {*}
         */
        fromCodePoint : function () {
            if (String.fromCodePoint) {
                return String.fromCodePoint.apply(null, arguments);
            }

            var MAX_SIZE = 0x4000
                , 	codeUnits = []
                , 	highSurrogate
                , 	lowSurrogate
                , 	index = -1
                , 	length = arguments.length
                , 	result = ''
                ,	codePoint;

            if (!length) {
                return result;
            }

            while (++index < length) {
                codePoint = Number(arguments[index]);

                if (!isFinite(codePoint) || codePoint < 0 || codePoint > 0x10FFFF || Math.floor(codePoint) != codePoint) {
                    throw RangeError('Invalid code point: ' + codePoint);
                }

                if (codePoint <= 0xFFFF) {
                    codeUnits.push(codePoint);
                } else {
                    codePoint -= 0x10000;
                    highSurrogate = (codePoint >> 10) + 0xD800;
                    lowSurrogate = (codePoint % 0x400) + 0xDC00;
                    codeUnits.push(highSurrogate, lowSurrogate);
                }

                if (index + 1 == length || codeUnits.length > MAX_SIZE) {
                    result += String.fromCharCode.apply(null, codeUnits);
                    codeUnits.length = 0;
                }
            }

            return result;
        },

        /**
         * 현재 시간을 "시간 : 분 : AM/PM" 형식으로 출력한다.
         * @returns {String}                ex) "02:20 PM"
         */
        getCurrentTime : function() {
            var date = new Date(),
                hour = date.getHours(),
                minute = date.getMinutes(),
                ampm = (hour >= 12) ? " PM" : " AM",
                currentDate = "";

            if (hour == 0) {
                hour += 12;
            } else if (hour > 12) {
                hour -= 12;
            }

            currentDate += (hour < 10) ? "0" + hour : hour;
            currentDate += ":";
            currentDate += (minute < 10) ? "0" + minute : minute;
            currentDate += ampm;

            return currentDate;
        },

        /**
         * Local storage 로부터 정보 가져오기
         * @param {String} key                가져올 item 에 대한 key
         * @return {String}
         */
        getItemFromLocalStorage : function (key) {
            return JSON.parse(localStorage.getItem(key));
        },

        /**
         * Local storage 에 정보 저장하기
         * @param {String} key                  저장할 item 에 대한 key
         * @param {String} value                key에 저장할 값
         */
        setItemToLocalStorage : function (key, value) {
            localStorage.setItem(key, JSON.stringify(value));
        },

        /**
         * 이벤트 trigger 를 수행한다.
         * @param {Element} el                  대상 노드
         * @param {String} eventName            이벤트명
         * @returns {*}
         */
        triggerEvent : function (el, eventName) {
            var event;

            if (!(el && el.nodeType === 1 && typeof eventName === "string")) {
                return;
            }

            if (document.createEvent) {
                // chrome, firefox
                event = document.createEvent("HTMLEvents");
                event.initEvent(eventName, true, true);

                return !el.dispatchEvent(event);
            } else if (document.createEventObject) {
                // IE
                event = document.createEventObject();

                return el.fireEvent("on" + eventName, event);
            }
        },

        /**
         * 지정한 Object Key 의 값으로 소팅하여 반환한다.
         * @param {String} prop         - 소팅할 Object 의 Key (-keyname 은 내림차순 소팅)
         * @returns {function(*, *): number}
         */
        dynamicSort : function (prop) {
            var sortOrder = 1;

            if (prop[0] === "-") {
                sortOrder = -1;
                prop = prop.substr(1);
            }

            return function (a, b) {
                var result = (a[prop] < b[prop]) ? -1 : (a[prop] > b[prop]) ? 1 : 0;
                return result * sortOrder;
            }
        },

        isString : function (obj) {
            return (typeof obj === "string" || obj instanceof String);
        }
    };
});
