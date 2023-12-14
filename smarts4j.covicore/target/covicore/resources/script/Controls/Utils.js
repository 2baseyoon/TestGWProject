
//------------------------------------------------------------------ Base Utils -------------------------------------------------------------
// 서버컨트롤의 아이디로 객체 가져오기
function CFN_GetCtrlById(pId) {
	//return document.getElementById(new Function("id_" + pId).apply());
	return document.getElementById(window["id_" + pId]);
}

//------------------------------------------------------------------ Ajax -------------------------------------------------------------
//호출한 페이지를 로드함.
Common.AjaxLoad = function (pTargetid, pUrl, pData, pCallBack, pUserContext) {
    if(!_RiseAjaxError) {
        $.get(pUrl, pData, function (response, status, error) {
            if (status == "error") {
                CFN_ErrorAjax(pUrl, response, status, error);
            } else {
                try {
                    response = response.replace(/__EVENTVALIDATION/gi, "__EVENTVALIDATIONAjaxLoad");
                    response = response.replace(/__VIEWSTATE/gi, "__VIEWSTATEAjaxLoad");
                    $("#" + pTargetid).html(response);
                    if (pCallBack) {
                        pCallBack(pTargetid, pUserContext);
                    }
                } finally {
                    response = null;
                    status = null;
                    error = null;
                }
            }
        });
    }
}

//호출한 페이지를 로드하여 하단에 삽입
Common.AjaxAppend = function (pTargetid, pUrl, pData, pCallBack, pUserContext) {
    if(!_RiseAjaxError) {
        $.get(pUrl, pData, function (response, status, error) {
            if (status == "error") {
                CFN_ErrorAjax(pUrl, response, status, error);
            } else {
                try {
                    response = response.replace(/__EVENTVALIDATION/gi, "__EVENTVALIDATIONAjaxLoad");
                    response = response.replace(/__VIEWSTATE/gi, "__VIEWSTATEAjaxLoad");
                    $("#" + pTargetid).append(response);
                    if (pCallBack) {
                        pCallBack(pTargetid, pUserContext);
                    }
                } finally {
                    response = null;
                    status = null;
                    error = null;
                }
            }
        });
    }
}

//호출한 페이지를 리턴 함
Common.AjaxReturn = function (pUrl, pData, pCallBack, pUserContext) {
    if (!_RiseAjaxError) {
        $.get(pUrl, pData, function (response, status, error) {
            if (status == "error") {
                CFN_ErrorAjax(pUrl, response, status, error);
            } else {
                try {
                    if (typeof (js_msg) == "string") {
                        response = response.replace(/__EVENTVALIDATION/gi, "__EVENTVALIDATIONAjaxLoad");
                        response = response.replace(/__VIEWSTATE/gi, "__VIEWSTATEAjaxLoad");
                    }
                    if (pCallBack) {
                        pCallBack(response, pUserContext);
                    } else {
                        return response;
                    }
                } finally {
                    response = null;
                    status = null;
                    error = null;
                }
            }
        });
    }
}

//Call Ajax Json DataType
function CFN_CallAjaxJson(pUrl, pJsonData, pAsync, pCallBack) {
    if(_RiseAjaxError) {
            return;
        } else {
        var option = {
            type: "POST",
            contentType: "application/json; charset=utf-8",
            url: pUrl,
            data: pJsonData,
            dataType: "json",
            async: pAsync,
            error: function (response, status, error) {
                CFN_ErrorAjax(pUrl, response, status, error);
            }
        }

        if (pAsync) {
            $.extend(option, {
                success: function (msg) {
                    try {
                        if (msg != null) {
                            pCallBack(msg);
                        }
                    } finally {
                        option = null;
                    }
                }
            });
            $.ajax(option);
        } else {
            try {
                return $.ajax(option).responseText;
            } finally {
                option = null;
            }
        }
    }
}

// Call Ajax - Param, Type url, param, callbackFunc, bAsync, dataTP
function CFN_CallAjax(pUrl, pParam, pCallBack, pAsync, pDataType) {
    if (pDataType == null || pDataType == "") {
        pDataType = "html";
    }
    if(_RiseAjaxError) {
        return;
    } else {
        $.ajax({
            url: pUrl,
            data: pParam,
            dataType: pDataType,
            type: "POST",
            async: pAsync,
            success: function (result) {
                try {
                    pCallBack(result);
                } finally {
                    result = null;
                }
            },
            error : function (response, status, error) {
                CFN_ErrorAjax(pUrl, response, status, error);
            }
        });
    }
}

//공용 컴포넌트 ERROR에 대한 처리(에러처리중 에러가 발생하면 인증 오류로 봄.)
function CFN_ErrorAjax(pURL, pResponse, pStatus, pError) {
	// TODO 모바일 처리
    try {
        var l_ResStatus = pStatus; // 에러코드
        var l_AlertMsg = "";
        var l_AlertTrace = "";
        var l_RiseError = false;
        var l_Language = localStorage.getItem("DictionaryLang") == null ? "ko" : localStorage.getItem("DictionaryLang");
        var _SystemMode = Common.isDevMode;
        
        //모바일 여부
        var mobileFilter = "win16|win32|win64|mac|macintel|linux";
        var isMobile = false;
        if(navigator.platform){
        	if(mobileFilter.indexOf(navigator.platform.toLowerCase())<0){
        		isMobile = true;
        	}
        }

        if (l_ResStatus == 401) { // 인증 만료
        	if(l_Language == "ko") {
        		l_AlertMsg = "<strong>서비스 이용에 불편을 드려 죄송합니다.</strong><br /><br />[" + l_ResStatus + "] 현재 시스템에 대한 인증정보를 확인 할 수 없습니다. <br /><br />로그인 페이지로 이동하시겠습니까?";
        	} else {
        		l_AlertMsg = "<strong>Sorry for the inconvenience in the use of the service.</strong><br /><br />[" + l_ResStatus + "] The current system cannot be verified for authentication. <br /><br />Are you sure you want to go to the login page?";
        	}
        	
        	_RiseAjaxError = true;

            var error401 = function(){
            	var loginURL = "/covicore/login.do";
            	
                if (parent.location.href != self.location.href) {
                    parent.location.href = loginURL;
                } else {
                    self.location.href = loginURL;
                }
            };
            
            if(!isMobile){
	            Common.Confirm(l_AlertMsg, pError, function (pResult) {
	                if (pResult) {
	                	error401();
	                } else {
	                    _RiseAjaxError = false;
	                }
	            });
            }else{
            	if(confirm(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, "")) == true){
            		error401();
            	}else{
            		_RiseAjaxError = false;
            	}
            }
            
        } else if (l_ResStatus == 502) { // 네트워크 끊긴 경우
        	if(l_Language == "ko") {
        		l_AlertMsg = "<strong>서비스 이용에 불편을 드려 죄송합니다.</strong><br /><br />[" + l_ResStatus + "] 네트워크 상태가 원활하지 않습니다. 잠시후 다시 시도해 보십시요.";
        	} else {
        		l_AlertMsg = "<strong>Sorry for the inconvenience in the use of the service.</strong><br /><br />[" + l_ResStatus + "] The network status is not as smooth. Try again after a while.";
        	}
        	
            _RiseAjaxError = true;
            if(!isMobile){
	            Common.Error(l_AlertMsg, pError, function () {
	                _RiseAjaxError = false;
	            });
            }else{
            	alert(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, ""));
            }
            
        } else if (l_ResStatus == 404 || l_ResStatus == 403) { // 페이지가 없거나 사이트에 접근이 거부
        	if(l_Language == "ko") {
        		l_AlertMsg = "<strong>서비스 이용에 불편을 드려 죄송합니다.</strong><br />[" + l_ResStatus + "] 요청하신 페이지가 없거나 서비스에 대한 접근이 거부되었습니다.";
        	} else {
        		l_AlertMsg = "<strong>Sorry for the inconvenience in the use of the service.</strong><br /><br />[" + l_ResStatus + "] The requested page does not exist or has been denied access to the service.";
        	}
        	
            if(_SystemMode != "N") {
                l_AlertMsg += "<br /><br />URL : "+ pURL;
            } else {
                l_AlertMsg += "<br /><br /><font color='white'>URL : "+ pURL +"</font>"
            }
            if(!isMobile){
            	Common.Error(l_AlertMsg, pError);
            }else{
            	alert(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, ""));
            }
            
        } else if (l_ResStatus == 500 || l_ResStatus == 503) { // 서버 내부 오류
            try {
                l_AlertMsg = "<strong>" + $.parseJSON(pResponse.responseText).Message + "</strong>";
                l_AlertTrace = $.parseJSON(pResponse.responseText).StackTrace.replace(/'/gi, "").replace(/"/gi, "").replace(/\r\n/gi, "<br />").replace(/\n/gi, "<br />");
            } catch (e) {
                l_RiseError = true;
            }

            if (l_RiseError) { // Response 객체를 파싱하다 에러가 발생한 경우
            	if(l_Language == "ko") {
            		l_AlertMsg = "<strong>서비스 이용에 불편을 드려 죄송합니다.</strong><br /><br />[" + l_ResStatus + "] 요청하신 서비스에 문제가 발생하였습니다.<br /><br />잠시후 다시 시도해 보십시요.<br />문제가 계속해서 발생시 관리자에게 문의하여 주십시요.";
            	} else {
            		l_AlertMsg = "<strong>Sorry for the inconvenience in the use of the service.</storng><br /><br />[" + l_ResStatus + "] If you have problems in the service request.<br /><br />Try again after a while.<br />Problem continues to occur, contact your administrator.";
            	}
            	
            } else if (_SystemMode != "N") {
                l_AlertMsg += "<br /><br />URL : " + pURL + "<br /><br /><center><div style='width:400px;height:100px;overflow:auto;' align='left'>" + l_AlertTrace + "</div></center>";
            } else {
                l_AlertMsg += "<br /><font color='white'>URL : " + pURL + "</font>";
            }
            
            if(!isMobile){
            	Common.Error(l_AlertMsg, pError);
            }else{
            	alert(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, ""));
            }
        } else { // 알지 못하는 오류
            try {
            	if (pResponse.status == "401"){
            		if(l_Language == "ko") {
                		l_AlertMsg = "<strong>서비스 이용에 불편을 드려 죄송합니다.</strong><br /><br />[" + l_ResStatus + "] 현재 시스템에 대한 인증정보를 확인 할 수 없습니다. <br /><br />로그인 페이지로 이동하시겠습니까?";
                	} else {
                		l_AlertMsg = "<strong>Sorry for the inconvenience in the use of the service.</strong><br /><br />[" + l_ResStatus + "] The current system cannot be verified for authentication. <br /><br />Are you sure you want to go to the login page?";
                	}
            		
                	_RiseAjaxError = true;

                    var error401 = function(){
                    	var loginURL = "/covicore/login.do";
                    	
                        if (parent.location.href != self.location.href) {
                            parent.location.href = loginURL;
                        } else {
                            self.location.href = loginURL;
                        }
                    };
                    
                    if(!isMobile){
                    	Common.Confirm(l_AlertMsg, pError, function (result) {
        	                if (result) {
        	                	error401();
        	                } else {
        	                    _RiseAjaxError = false;
        	                }
        	            });
                    }else{
                    	if(confirm(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, "")) == true){
                    		error401();
                    	}else{
                    		_RiseAjaxError = false;
                    	}
                    }
                    
            	} else if (pResponse.status == 404 || pResponse.status == 403) { // 페이지가 없거나 사이트에 접근이 거부
            		if(l_Language == "ko") {
            			l_AlertMsg = "<strong>서비스 이용에 불편을 드려 죄송합니다.</strong><br />[" + l_ResStatus + "] 요청하신 페이지가 없거나 서비스에 대한 접근이 거부되었습니다.";
                	} else {
                		l_AlertMsg = "<strong>Sorry for the inconvenience in the use of the service.</strong><br /><br />[" + l_ResStatus + "] The requested page does not exist or has been denied access to the service.";
                	}
                	
                	
                    if(_SystemMode != "N") {
                        l_AlertMsg += "<br /><br />URL : "+ pURL;
                    } else {
                        l_AlertMsg += "<br /><br /><font color='white'>URL : "+ pURL +"</font>"
                    }
                    
                    if(!isMobile){
                    	Common.Error(l_AlertMsg, pError);
                    }else{
                    	alert(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, ""));
                    }
                    
            	} else if (pResponse.status == "461"){
            		g_ErrorMessage = "";
            		g_ErrorSeq = 0;
            		
            		if(l_Language == "ko") {
            			l_AlertMsg = "<strong>권한 오류</strong><br />요청하신 작업에 대한  처리가  거부되었습니다. <br />처리 가능한 업무인지 확인바랍니다.";
                	} else {
                		l_AlertMsg = "<strong>Permission error</strong><br />The processing of your requested job has been denied. <br />Please check if it can be handled.";
                	}
                	
                	pError = "No permission";
                	
                	if(!isMobile){
                    	Common.Error(l_AlertMsg, pError);
                    }else{
                    	alert(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, ""));
                    }
            	} else {
	                //l_AlertMsg = "<strong>※ " + $.parseJSON(pResponse.responseText).Message + "</strong>";
	                //l_AlertTrace = $.parseJSON(pResponse.responseText).StackTrace.replace(/'/gi, "").replace(/"/gi, "").replace(/\r\n/gi, "<br />").replace(/\n/gi, "<br />");
	                //Common.Error(l_AlertMsg, pError);
	                
	                //pError은 메세지 값임 출력 메세지로 전달하고 타이틀값 조정(Common.Error의 두번째 값은 타이틀임) kimhy2. 2023.07.12
            		l_AlertTrace = pError;
	                pError = "Error";
	            	if(l_Language == "ko") {
	            		l_AlertMsg = "<strong>서비스 이용에 불편을 드려 죄송합니다.</strong><br /><br />[" + l_ResStatus + "] 요청하신 서비스에 문제가 발생하였습니다.<br /><br />잠시후 다시 시도해 보십시요.<br />문제가 계속해서 발생시 관리자에게 문의하여 주십시요.";
	            	} else {
	            		l_AlertMsg = "<strong>Sorry for the inconvenience in the use of the service.</storng><br /><br />[" + l_ResStatus + "] If you have problems in the service request.<br /><br />Try again after a while.<br />Problem continues to occur, contact your administrator.";
	            	}
	                
	                if (_SystemMode != "N") {
	                    l_AlertMsg += "<br /><br />URL : " + pURL + "<br /><br /><center><div style='width:400px;height:200px;overflow:auto;' align='left'>" + l_AlertTrace + "</div></center>";
	                } else {
	                    l_AlertMsg += "<br /><span style='display:none'>URL : " + pURL +"["+ l_AlertTrace+ "]</span>";
	                }
	                if(!isMobile){
                    	Common.Error(l_AlertMsg, pError);
                    }else{
                    	alert(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, ""));
                    }
            	}    
            } catch (e) {
                l_RiseError = true;
                
                if (l_RiseError) { // Response 객체를 파싱하다 에러가 발생한 경우
                	l_AlertMsg = "<strong>서비스 이용에 불편을 드려 죄송합니다.</strong><br /><br />[" + l_ResStatus + "] 요청하신 서비스에 문제가 발생하였습니다.<br /><br />잠시후 다시 시도해 보십시요.<br />문제가 계속해서 발생시 관리자에게 문의하여 주십시요.";
                } else if (_SystemMode != "N") {
                    l_AlertMsg += "<br /><br />URL : " + pURL + "<br /><br /><center><div style='width:400px;height:200px;overflow:auto;' align='left'>" + l_AlertTrace + "</div></center>";
                } else {
                    l_AlertMsg += "<br /><font color='white'>URL : " + pURL + "</font>";
                }
                
                if(!isMobile){
                	Common.Error(l_AlertMsg, pError);
                }else{
                	alert(l_AlertMsg.replace("{0}", l_ResStatus).replaceAll("<br />", "\n").replace(/(<([^>]+)>)/gi, ""));
                }
            }
        }
    } catch (e) {
        alert("Error: " + e.message + "\r\n"+e.stack);
        return false;
    } finally {
        pResponse = null;
        pStatus = null;
        pError = null;
    }
}


//------------------------------------------------------------------ Cookie -------------------------------------------------------------
//쿠키를 생성합니다.
//pStrKey : 키
//pStrValue : 값
//pDtExpires : 만료일 [지정하지 않을경우(==null) 1일로 설정, undefiend일 경우는 OneTime Cookie]
function CFN_SetCookieDate(pStrKey, pStrValue, pDtExpires) {
	var strKey = (typeof pStrKey != 'undefined') ? pStrKey.replace(/\n/g,'').replace(/\r/g,'') : '';
	var strValue = (typeof pStrValue != 'undefined') ? pStrValue.replace(/\n/g,'').replace(/\r/g,'') : '';
	var dtExpires = (typeof pDtExpires != 'undefined') ? pDtExpires.replace(/\n/g,'').replace(/\r/g,'') : '';
	if (pDtExpires == undefined || pDtExpires == "undefined") { // OneTime Colkies ie에서는 처리 안됨.
		document.cookie = strKey + '=' + escape(strValue) + ';expires=Session;path=/';
	} else {
		document.cookie = strKey + '=' + escape(strValue) + ';expires=' + dtExpires.toGMTString() + ';path=/';
	}
}

//pStrKey : 키
//pStrValue : 값
//pDtExpires : 유지기간(milisecond) [지정하지 않을경우(==null) 현재일에 1일을 더한 설정]
function CFN_SetCookieDay(pStrKey, pStrValue, pExpiresDuration) {
	var dtExpires = new Date();
	//if (pExpiresDuration == null && pExpiresDuration == 0) {
	if (pExpiresDuration == null || pExpiresDuration == 0) {
		dtExpires = CFN_GetDateAddMilisecond(null, 24 * 60 * 60 * 1000)
	} else {
		dtExpires = CFN_GetDateAddMilisecond(null, pExpiresDuration)
	}
	document.cookie = pStrKey + '=' + escape(pStrValue) + ';expires=' + dtExpires.toGMTString() + ';path=/';
}

//만료일을 과거로 설정하여 쿠키를 삭제합니다.
//pStrKey : 키
function CFN_DelCookie(pStrKey) {
	var dtExpires = new Date(); // 오늘 날짜
	dtExpires = CFN_GetDateAddMilisecond(null, -24 * 60 * 60 * 1000)
	document.cookie = pStrKey + "=;expires=" + dtExpires.toGMTString() + ';path=/';
}

//쿠키를 조회합니다.
//pStrKey : 키
function CFN_GetCookie(pStrKey) {
	var oCookies = document.cookie;
	var aStrCookies = oCookies.split("; ");
	for (var i = 0; i < aStrCookies.length; i++) {
		var sKeyValues = aStrCookies[i].split("=");
		if (sKeyValues[0] == pStrKey) {
			return unescape(sKeyValues[1]);
		}
	}
	return "";
}


//------------------------------------------------------------------ 문자열 -------------------------------------------------------------
// 왼쪽에 특정문자를 채워 반환
function CFN_PadLeft(pString, pCount, pPadChar) {
	var l_PadString = '';
	pString = pString.toString();

	if (pString.length < pCount) {
		for (var i = 0; i < pCount - pString.length; i++) {
			l_PadString += pPadChar;
		}
	}
	return l_PadString + pString;
}

// 오른쪽에 특정문자를 채워 반환
function CFN_PadRight(pString, pCount, pPadChar) {
	var l_PadString = '';
	pString = pString.toString();

	if (pString.length < pCount) {
		for (var i = 0; i < pCount - pString.length; i++) {
			l_PadString += pPadChar;
		}
	}
	return pString + l_PadString;
}

// 문자열 바이트로 잘라 내기
function CFN_AdjustLenByte(strText, maximum) {
	var inc = 0;
	var nbytes = 0;
	var strReturn = '';
	var szLen = strText.length;

	for (var i = 0; i < szLen; i++) {
		var chr = strText.charAt(i);
		if (escape(chr).length > 4) {
			inc = 2;
		} else if (chr != '\r') {
			inc = 1;
		}
		if ((nbytes + inc) > maximum) {
			break;
		}
		nbytes += inc;
		strReturn += chr;
	}
	return strReturn;
}

// 문자열 잘라내기
function CFN_AdjustLen(strText, maximum) {
	var inc = 0;
	var nbytes = 0;
	var strReturn = '';
	var szLen = strText.length;

	for (var i = 0; i < szLen; i++) {
		var chr = strText.charAt(i);
		if (chr != '\r') {
			inc = 1;
		}
		if ((nbytes + inc) > maximum) {
			break;
		}
		nbytes += inc;
		strReturn += chr;
	}
	return strReturn;
}

// 문자의 길이 바이트 체크
function CFN_CalByte(strText) {
	var nbytes = 0;
	for (var i = 0; i < strText.length; i++) {
		var chr = strText.charAt(i);
		if (escape(chr).length > 4) {
			nbytes += 2;
		} else if (chr != '\r') {
			nbytes++;
		}
	}
	return nbytes;
}

// 입력 문자 수자 인지 체크
function CFN_IsNum(pKeyCode) {
	if (pKeyCode == 8) {
		return true;
	} else if (pKeyCode < 48 || pKeyCode > 57) {
		return false;
	} else {
		return true;
	}
}

//천단위에 컴마 찍기
function CFN_AddComma(objValue) {
	//숫자형으로 올 경우 대비
	if (!isNaN(objValue))  objValue = objValue+"";	
	var objTempDot = "";
	var objTemp = "";
	var objTempValue = '';
	var objFlag = '';
	if (objValue.indexOf(".") > -1) {
		objTemp = objValue.split(".")[0];
		objTempDot = objValue.split(".")[1];
	} else {
		objTemp = objValue;
	}

	objTemp = objTemp.replace(/,/g, '');
	if (objTemp.charAt(0) == '-') {
		objFlag = 'Y';
		objTemp = objTemp.substring(1);
	}

	if (objTemp.length > 3) {
		var tempV1 = objTemp.substring(0, objTemp.length % 3);
		var tempV2 = objTemp.substring(objTemp.length % 3, objTemp.length);

		if (tempV1.length != 0) {
			tempV1 += ',';
		}
		objTempValue += tempV1;

		for (var i = 0; i < tempV2.length; i++) {
			if (i % 3 == 0 && i != 0) {
				objTempValue += ',';
			}
			objTempValue += tempV2.charAt(i);
		}
	} else {
		objTempValue = objTemp;
	}

	if (objFlag == 'Y') {
		objTempValue = '-' + objTempValue;
	}

	if (objTempDot != "") {
		objTempValue = objTempValue + "." + objTempDot;
	}
	return objTempValue;
}

//////////////////////////////////////////레이어 팝업 Iframe에서 콜백 메써드 호출 ////////////////////////////////
//팝업에서 부모 페이지의 콜백 함수를 호출합니다.
//<param name="pStrIFrameName">부모 창을 찾기 위한 IFrame ID</param>
//<param name="pStrCallBackMethodName">부모 창의 Call Back 함수 명</param>
//<param name="pStrValue">부모 창의 Call Back 함수에 넘겨줄 값</param>
function XFN_CallBackMethod_Call(pStrIFrameName, pStrCallBackMethodName, pStrValue) {
	let ptFunc;
	let scope;
	if (pStrIFrameName == "") {
	   if (opener != null) {
		   //ptFunc = new Function("a", "opener." + pStrCallBackMethodName + "(a)");
		   //ptFunc = opener[pStrCallBackMethodName];
		   scope = opener;
	   } else { 
		   //ptFunc = new Function("a", "parent." + pStrCallBackMethodName + "(a)");
		   //ptFunc = parent[pStrCallBackMethodName];
		   scope = parent;
	   }
	} else {
//	   var sCallBack = "";
//	   var sTemp = "";
//	   for (var i = 0; i < pStrIFrameName.split(";").length; i++) {
//	       sTemp = pStrIFrameName.split(";")[i];
//	       if (sTemp == "") {
//	           break;
//	       }
//	
//	       if (i == 0) {
//	           sCallBack = "$(\"#" + sTemp + "_if\", parent.document)[0].contentWindow";
//	       } else {
//	           sCallBack += "$(\"#" + sTemp + "_if\")[0].contentWindow";
//	       }
//	       sCallBack += ".";
//	   }
//	   ptFunc = new Function("a", sCallBack + pStrCallBackMethodName + "(a)");
		//ptFunc = coviCmn.getParentFrameObj(pStrIFrameName)[pStrCallBackMethodName];
		scope = coviCmn.getParentFrameObj(pStrIFrameName);
	}
	ptFunc = scope;
	let ns = pStrCallBackMethodName;
	if(ns.indexOf(".") > -1){
		ns = pStrCallBackMethodName.split(".");
	}else{
		ns = [pStrCallBackMethodName];
	}
	for(var i = 0; i < ns.length; i++){
		ptFunc = ptFunc[ns[i]];
	}
	ptFunc(pStrValue);
}

//입력값 앞에 '0'을 붙여서 입력받는 자리수의 문자열을 반환한다.
function XFN_AddFrontZero(inValue, digits) {
    var result = "";
    inValue = inValue.toString();

    if (inValue.length < digits) {
        for (var i = 0; i < digits - inValue.length; i++)
            result += "0";
    }
    result += inValue
    return result;
}

//입력된 값에 HTML 테그 또는 스크립트가 들어 있는지 검사
function XFN_ValidationCheckXSS() {
	// XSS 클래스 미지정시 : HTML 자체 입력불가
	// NoScriptXSS : 스크립트, style만 불가(HTML 테그는 입력 가능)
	// NoCheckXSS : XSS 체크를 하지않음(Html로 노출되지 않거나 cs단에서 처리함.)
	var l_HtmlCheckValue = false;
	var l_ScriptCheckValue = false;
	var l_oTarget;

	// XSS 관련 CSS를 지정하지않는 모든 input, TextArea는 XSS 체크 대상임.
	$("input").each(function () {
		if (!($(this).hasClass("NoScriptXSS")) && !($(this).hasClass("NoCheckXSS"))
				&& XFN_CheckHTMLinText($(this).val())) {
			l_HtmlCheckValue = true;
			l_oTarget = $(this);
		}
	});
	if (!l_HtmlCheckValue) {
		$("textarea").each(function () {
			if (!($(this).hasClass("NoScriptXSS")) && !($(this).hasClass("NoCheckXSS"))
					&& XFN_CheckHTMLinText($(this).val())) {
				l_HtmlCheckValue = true;
				l_oTarget = $(this);
			}
		});
	}
	if (!l_HtmlCheckValue) {
		// 스크립트 입력 불가 Input, TextArea Check
		$("input").each(function () {
			if ($(this).hasClass("NoScriptXSS") && XFN_CheckInputLimit($(this).val())) {
				$(this).focus();
				l_ScriptCheckValue = true;
				l_oTarget = $(this);
			}
		});
		if (!l_ScriptCheckValue) {
			$("textarea").each(function () {
				if ($(this).hasClass("NoScriptXSS") && XFN_CheckInputLimit($(this).val())) {
					$(this).focus();
					l_ScriptCheckValue = true;
					l_oTarget = $(this);
				}
			});
		}
	}
	// 메시지 반환
	if (l_ScriptCheckValue || l_HtmlCheckValue) {
		var l_WarningMsg = "";
		// 히든 필드에 입력 불가 값 존재로 Focus 넘길 수 없음
		if ($(l_oTarget).attr("type") == "hidden" || $(l_oTarget).css("display") == "none") { 
			if (l_ScriptCheckValue) { // 스크립트 입력불가
				l_WarningMsg = Common.getDic("msg_ThisPageLimitedScript");
			} else {  // HTML 테그 입력 불가
				l_WarningMsg = Common.getDic("msg_ThisPageLimitedHTMLTag");
			}
			if (CFN_GetQueryString("CFN_OpenLayerName") == "undefined") {
				Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]");
			} else {
				parent.Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]");
			}
			return false;
		} else { 
			if (l_ScriptCheckValue) { // 스크립트 입력불가
				l_WarningMsg = Common.getDic("msg_ThisInputLimitedScript");
			} else {  // HTML 테그 입력 불가
				l_WarningMsg = Common.getDic("msg_ThisInputLimitedHTMLTag");
			}

			if (CFN_GetQueryString("CFN_OpenLayerName") == "undefined") {
				Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]", function () { $(l_oTarget).focus(); });
			} else {
				parent.Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]", function () { $(l_oTarget).focus(); });
			}
			return false;
		}
	} else {
		return true;
	}
}

//입력필드에 XSS체크가 있는 것만 체크
function XFN_ValidationCheckOnlyXSS() {
	// XSS 클래스 미지정시 : HTML 스크립트 입력 가능
	// HtmlCheckXSS : HTML 입력 불가
	// ScriptCheckXSS : 스크립트만 입력 불가
	var l_HtmlCheckValue = false;
	var l_ScriptCheckValue = false;
	var l_oTarget;

	// Html 태그 입력 불가
	$(".HtmlCheckXSS").each(function () {
		if (!l_HtmlCheckValue) {
			if (XFN_CheckHTMLinText($(this).val())) {
				l_HtmlCheckValue = true;
				l_oTarget = $(this);
			}
		}
	});
	// <script>, <style> 입력 불가
	if (!l_HtmlCheckValue) {
		$(".ScriptCheckXSS").each(function () {
			if (!l_ScriptCheckValue) {
				if (XFN_CheckInputLimit($(this).val())) {
					l_ScriptCheckValue = true;
					l_oTarget = $(this);
				}
			}
		});
	}

	// <script> 입력 불가
	if (!l_HtmlCheckValue) {
		$(".ScriptCheckXSSOnlyScript").each(function () {
			if (!l_ScriptCheckValue) {
				if (XFN_CheckInputLimitOnlyScript($(this).val())) {
					l_ScriptCheckValue = true;
					l_oTarget = $(this);
				}
			}
		});
	}
 
	// 메시지 반환
	if (l_ScriptCheckValue || l_HtmlCheckValue) {
		var l_WarningMsg = "";
		// 히든 필드에 입력 불가 값 존재로 Focus 넘길 수 없음
		if ($(l_oTarget).attr("type") == "hidden" || $(l_oTarget).css("display") == "none") {
			if (l_ScriptCheckValue) { // 스크립트 입력불가
				l_WarningMsg = Common.getDic("msg_ThisPageLimitedScript");
			} else {  // HTML 테그 입력 불가
				l_WarningMsg = Common.getDic("msg_ThisPageLimitedHTMLTag");
			}
			if (CFN_GetQueryString("CFN_OpenLayerName") == "undefined") {
				Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]");
			} else {
				parent.Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]");
			}
			return false;
		} else {
			if (l_ScriptCheckValue) { // 스크립트 입력불가
				l_WarningMsg = Common.getDic("msg_ThisInputLimitedScript");
			} else {  // HTML 테그 입력 불가
				l_WarningMsg = Common.getDic("msg_ThisInputLimitedHTMLTag");
			}

			if (CFN_GetQueryString("CFN_OpenLayerName") == "undefined") {
				Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]", function () { $(l_oTarget).focus(); });
			} else {
				parent.Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]", function () { $(l_oTarget).focus(); });
			}
			return false;
		}
	} else {
		return true;
	}
}

//html 태그 및 스크립트 방지
function XFN_CheckHTMLinText(pValue) {
    var newPValue = pValue.replace(/<[^<가-힣]+?>/gi, '');
    if (pValue != newPValue) {
        //pValue = newPValue;
        return true;
    }
    else {
        return false;
    }
}

//받은 입력값 특수문자 변환 처리1
function XFN_ChangeInputValue(pValue) {
    var strReturenValue = "";
    strReturenValue = pValue.replace(/&/gi, '&amp;').replace(/</gi, '&lt;').replace(/>/gi, '&gt;').replace(/"/gi, '&quot;').replace(/'/gi, '&apos;');
    return strReturenValue;
}

//받은 입력값 특수문자 변환 처리2
function XFN_ChangeOutputValue(pValue) {
    var strReturenValue = "";
    strReturenValue = pValue.replace(/&amp;/gi, '&').replace(/&lt;/gi, '<').replace(/&gt;/gi, '>').replace(/&quot;/gi, '"').replace(/&apos;/gi, '\'').replace(/&nbsp;/gi, ' ');
    return strReturenValue;
}

//문자열 중에 스크립트가 있는지 체크하는 함수 ex) "<script>aa </script>" 있는지 체크함.
function XFN_CheckInputLimit(pValue) {
    var rx =/<\s*script.+?<\/\s*script\s*>/gi;
    if (pValue.match(rx)) {
        return true;
    } else {
        rx = /<\s*style.+?<\/\s*style\s*>/gi;
        if (pValue.match(rx)) {
            return true;
        } else {
            return false;
        }
    }
}

//문자열 중에 스크립트가 있는지 스크립트만 체크하는 함수 ex) "<script>aa </script>" 있는지 체크함.
function XFN_CheckInputLimitOnlyScript(pValue) {
    var rx = /<\s*script.+?<\/\s*script\s*>/gi;
    if (pValue.match(rx)) {
        return true;
    } else {
        return false;
    }
}

/*Smart2Guide-개발가이드-스크립트 기능(oneNote)에 적혀있는 함수가 아님. 필요하다고 생각되어 추가됨*/
//받은 문자열 모든 키보드 특수기호 제거 후 반환
function XFN_ReplaceAllSpecialChars(pValue) {
	//정규식으로 제거
	if(pValue){
		var specialChars = /[~@!#$^%&*=+|:;?"<,.>'`(){}-]/;
		pValue = String(pValue).split(specialChars).join("");
		//정규식으로 제거 안되는 기호들 제거
		pValue = pValue.split('/').join("").split('_').join("").split('[').join("").split(']').join("").split('\\').join("");
		return pValue;
	}
	return "";

}

//문자열내의 특정문자들을 모두 replace 해주는 함수
//문자열, 원래문자, 바뀔문자
function XFN_ReplaceAllChars(entry, orginVal, newVal) {
  var temp = "" + entry;
  while (temp.indexOf(orginVal) > -1) {
      var pos = temp.indexOf(orginVal);
      temp = "" + (temp.substring(0, pos) + newVal +
		temp.substring((pos + orginVal.length), temp.length));
  }
  return temp;
}

//문자열, 원래문자, 바뀔문자
function XFN_ReplaceAllRegExp(pSource, pOriginVal, pNewVal) {
    var rx = new RegExp("(^|\\s)" + pOriginVal + "(\\s|$)");
    return pSource.replace(rx, pNewVal);
}


/* XFN_RemoveEditorContentStyle,
 * XFN_ConvertGridToExcelHTML 함수는
 * .NET에서 사용되던 URL이 포함되어 있어 작성하지 않음 */

//-------------------------------------------------------------- Date ---------------------------------------------------------
//시작, 종료일 비교
function CFN_CheckDateStartEnd(startDate, endDate) {
	var ArrStart, ArrEnd
	var isLater = false;

	if (startDate.indexOf("(") > -1) {
		startDate = startDate.replace(startDate.substr(startDate.indexOf("("), (startDate.length - 1)), "");
	}

	if (endDate.indexOf("(") > -1) {
		endDate = endDate.replace(endDate.substr(endDate.indexOf("("), (endDate.length - 1)), "");
	}

	if (startDate.indexOf("-") > -1) {
		ArrStart = startDate.split("-")
	} else if (startDate.indexOf(".") > -1) {
		ArrStart = startDate.split(".")
	} else if (startDate.indexOf("/") > -1) {
		ArrStart = startDate.split("/")
	} else {
		var l_dateLength = startDate.length;
		if (l_dateLength == 6) {
			ArrStart = (startDate.substr(0, 4) + "-" + startDate.substr(4, 1) + "-" + startDate.substr(5, 1)).split("-");
		} else if (l_dateLength == 7) {
			ArrStart = (startDate.substr(0, 4) + "-" + startDate.substr(4, 1) + "-" + startDate.substr(5, 2)).split("-");
		} else if (l_dateLength == 8) {
			ArrStart = (startDate.substr(0, 4) + "-" + startDate.substr(4, 2) + "-" + startDate.substr(6, 2)).split("-");
		}
	}

	if (endDate.indexOf("-") > -1) {
		ArrEnd = endDate.split("-")
	} else if (endDate.indexOf(".") > -1) {
		ArrEnd = endDate.split(".")
	} else if (startDate.indexOf("/") > -1) {
		ArrEnd = endDate.split("/")
	} else {
		var l_dateLength = endDate.length;
		if (l_dateLength == 6) {
			ArrEnd = (endDate.substr(0, 4) + "-" + endDate.substr(4, 1) + "-" + endDate.substr(5, 1)).split("-");
		} else if (l_dateLength == 7) {
			ArrEnd = (endDate.substr(0, 4) + "-" + endDate.substr(4, 1) + "-" + endDate.substr(5, 2)).split("-");
		} else if (l_dateLength == 8) {
			ArrEnd = (endDate.substr(0, 4) + "-" + endDate.substr(4, 2) + "-" + endDate.substr(6, 2)).split("-");
		}
	}

	if(ArrStart != undefined && ArrEnd != undefined){
		if (Number(ArrStart[0]) > Number(ArrEnd[0])) {
			isLater = true;
		} else if (Number(ArrStart[0]) == Number(ArrEnd[0])) {
			if (Number(ArrStart[1]) > Number(ArrEnd[1])) {
				isLater = true;
			} else if (Number(ArrStart[1]) == Number(ArrEnd[1])) {
				if (Number(ArrStart[2]) > Number(ArrEnd[2])) {
					isLater = true;
				}
			}
		}
	}
	
	return isLater;
}

//시작, 종료 시간 비교
function CFN_CheckTimeStartEnd(startTime, endTime) {
	var sTime = startTime.value.split(':');
	var eTime = endTime.value.split(':');
	var isLater = false;

	if (Number(sTime[0]) > Number(eTime[0])) {
		isLater = true;
	} else if (Number(sTime[0]) == Number(eTime[0])) {
		if (Number(sTime[1]) > Number(eTime[1])) {
			isLater = true;
		} else if (Number(sTime[1]) == Number(eTime[1])) {
			if (Number(sTime[2]) > Number(eTime[2])) {
				isLater = true;
			}
		}
	}

	return isLater;
}

//시간 비교
function CFN_DiffDate(pStartDate, pEndDate, type) {
	//날짜 비교
	var ReturnValue = '';
	switch (type) {
		case 'day': ReturnValue = ((((pEndDate - pStartDate) / 1000) / 60) / 60) / 24;
			break;
		case 'hour': ReturnValue = ((((pEndDate - pStartDate) / 1000) / 60) / 60);
			break;
		case 'min': ReturnValue = (((pEndDate - pStartDate) / 1000) / 60);
			break;
		case 'sec': ReturnValue = ((pEndDate - pStartDate) / 1000);
			break;
	}

	return ReturnValue;
}

//날짜 변환 반환
function CFN_GetDateAddMilisecond(pTargetDate, pAddMilisecond) {
	var dtDate = new Date();
	if (pTargetDate != null) {
		dtDate = pTargetDate
	}
	var numb = Date.parse(dtDate);
	dtDate.setTime(numb + pAddMilisecond);

	return dtDate;
}

//날짜를 문자열(yyyy.mm.dd)로 변경합니다.
//<param name="pObjDate">문자열(yyyy-mm-dd)로 변경할 날짜</param>
function XFN_getDateString(pObjDate, pFormat) {
    var sYear = pObjDate.getFullYear();
    var sMonth = XFN_AddFrontZero(pObjDate.getMonth() + 1, 2);
    var sDay = XFN_AddFrontZero(pObjDate.getDate(), 2);
    if (pFormat != undefined && pFormat != "") {
        return pFormat.replace("yyyy", sYear).replace("MM", sMonth).replace("dd", sDay);
    } else {
        return sYear + "-" + sMonth + "-" + sDay;
    }
}

//문자열 Local Date Format을 서버 포멧으로 단순변환
function XFN_TransDateServerFormat(pLocalDate) {
    var l_strResult = "";
    var l_strServerDateFormat = "yyyy-MM-dd";
    var l_strLocalFormat = "yyyy-MM-dd";
    var l_strCheckDate = "";

    //2016.01.29 다양한 포맷에 대응하도록 수정
    var s_DateFormat = "";   //서버 포맷 연결자

    // 입력 포멧 확인
    if (l_strServerDateFormat.indexOf(".") > -1) { s_DateFormat = "."; }
    if (l_strServerDateFormat.indexOf("-") > -1) { s_DateFormat = "-"; }
    if (l_strServerDateFormat.indexOf("/") > -1) { s_DateFormat = "/"; }

    if (pLocalDate.indexOf(".") > -1) { pLocalDate = pLocalDate.replace(/\./g, s_DateFormat); }
    if (pLocalDate.indexOf("-") > -1) { pLocalDate = pLocalDate.replace(/\-/g, s_DateFormat);; }
    if (pLocalDate.indexOf("/") > -1) { pLocalDate = pLocalDate.replace(/\//g, s_DateFormat); }

    if (pLocalDate != "") {
        l_strCheckDate = l_strServerDateFormat.replace("yyyy", pLocalDate.substr(l_strServerDateFormat.indexOf("yyyy"), 4)).replace("MM", pLocalDate.substr(l_strServerDateFormat.indexOf("MM"), 2)).replace("dd", pLocalDate.substr(l_strServerDateFormat.indexOf("dd"), 2));
        if (pLocalDate.length == 10) {
            if (l_strCheckDate != pLocalDate) {
                l_strResult = l_strServerDateFormat.replace("yyyy", pLocalDate.substr(l_strLocalFormat.indexOf("yyyy"), 4)).replace("MM", pLocalDate.substr(l_strLocalFormat.indexOf("MM"), 2)).replace("dd", pLocalDate.substr(l_strLocalFormat.indexOf("dd"), 2));
            } else {
                l_strResult = l_strCheckDate;
            }
        } else if (pLocalDate.length > 10) {
            if (l_strCheckDate != pLocalDate.substr(0,10)) {
                l_strResult = l_strServerDateFormat.replace("yyyy", pLocalDate.substr(l_strLocalFormat.indexOf("yyyy"), 4)).replace("MM", pLocalDate.substr(l_strLocalFormat.indexOf("MM"), 2)).replace("dd", pLocalDate.substr(l_strLocalFormat.indexOf("dd"), 2));
            } else {
                l_strResult = l_strCheckDate;
            }
            l_strResult += pLocalDate.substr(10, pLocalDate.length - 10);
        } else {
            l_strResult = pLocalDate;
        }
    }

    return l_strResult;
}

//날짜를 문자열(yyyy-mm-dd)로 변경합니다.
//y=연도(yyyy/yy)
//M=월(MM/M)
//d=일(dd/d)
//H=시(24시간)(HH/H)
//h=시(12시간)(hh/h)
//m=분(mm/m)
//<param name="pStrFormat">변경할 문자열(yyyy.mm.dd)</param>
//<param name="pObjDate">변경할 날짜</param>
function XFN_getDateTimeString(pStrFormat, pObjDate) {
 var sYear = pObjDate.getFullYear();
 var sMonth = XFN_AddFrontZero(pObjDate.getMonth() + 1, 2);
 var sDay = XFN_AddFrontZero(pObjDate.getDate(), 2);
 var sHours = XFN_AddFrontZero(pObjDate.getHours(), 2);
 var sHhours = sHours;
 var sMinute = XFN_AddFrontZero(pObjDate.getMinutes(), 2);
 var sSecond = XFN_AddFrontZero(pObjDate.getSeconds(), 2);
 if (sHhours > 12) {
     sHhours = XFN_AddFrontZero(sHhours - 12, 2);
 }
 //return pStrFormat.replace("yyyy", sYear).replace("MM", sMonth).replace("dd", sDay).replace("HH", sHours).replace("hh", sHhours).replace("mm", sMinute);
 return pStrFormat.replace("yyyy", sYear).replace("MM", sMonth).replace("dd", sDay).replace("HH", sHours).replace("hh", sHhours).replace("mm", sMinute).replace("ss", sSecond);
}

//날짜를 문자열(hh:mm:ss)로 변경합니다.
//<param name="pObjDate">문자열(hh:mm:ss)로 변경할 날짜</param>
function XFN_getTimeString(pObjDate) {
 return sHours + ":" + sMinute + ":" + sSecond;
}

//오늘날짜 구하기
function XFN_getCurrDate(pSplitStr, pFormat) {  //pSplitStr: 년월일사이에 나타낼 구분문자
    var now = new Date(CFN_GetLocalCurrentDate());
    var year = now.getFullYear();
    var month = now.getMonth() + 1;
    var date = now.getDate();
    if (month < 10)  //월이 한자리수인 경우
        month = "0" + month;
    if (date < 10)   //일이 한자리수인 경우
        date = "0" + date;

    var currDate = "";
    if (pFormat == undefined) {
        currDate = year + pSplitStr + month + pSplitStr + date;   //예: 2009-10-02
    } else {
        if (pFormat == 'dot' || pFormat == 'dash' || pFormat == 'slash' || pFormat == 'enslash') {
            currDate = year + pSplitStr + month + pSplitStr + date;   //예: 2009-10-02
        } else {
            currDate = pFormat.replace("yyyy", year).replace("MM", month).replace("dd", date);
        }
    }
    return currDate;
}

//현재날짜에 일수 더하기 빼기
function XFN_addMinusDateByCurrDate(pCaculDays, pSplitStr, pFormat) {  //pCaculDays:더하거나 뺄 일수 , pSplitStr: 년월일사이에 나타낼 구분문자
    var date = new Date(CFN_GetLocalCurrentDate());
    var sDate;
    sDate = date.getDate() + pCaculDays * 1; //현재날짜에 더해(빼)줄 날짜를 계산
    date.setDate(sDate); //계산된 날짜로 다시 세팅

    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var date = date.getDate();

    if (month < 10)  //월이 한자리수인 경우
        month = "0" + month;
    if (date < 10)   //일이 한자리수인 경우
        date = "0" + date;

    var resultDate = "";   //예: 2009-10-02
    if (pFormat == undefined) {
        resultDate = year + pSplitStr + month + pSplitStr + date;   //예: 2009-10-02
    } else {
        if (pFormat == 'dot' || pFormat == 'dash' || pFormat == 'slash' || pFormat == 'enslash') {
            resultDate = year + pSplitStr + month + pSplitStr + date;   //예: 2009-10-02
        } else {
            resultDate = pFormat.replace("yyyy", year).replace("MM", month).replace("dd", date);
        }
    }

    return resultDate;
}

//특정날짜에 일수 더하기 빼기
function XFN_addMinusDateBySomeDate(pYear, pMonth, pDay, pCaculDays, pSplitStr, pFormat) {  //pYear, pMonth, pDay (특정날짜 년,월,일)
    var date = new Date(pYear, pMonth-1, pDay);
    var sDate;
    sDate = date.getDate() + pCaculDays * 1; //특정날짜에 더해(빼)줄 날짜를 계산
    date.setDate(sDate); //계산된 날짜로 다시 세팅

    var year = date.getFullYear();
    var month = date.getMonth()+1;
    var date = date.getDate();

    if (month < 10)  //월이 한자리수인 경우
        month = "0" + month;
    if (date < 10)   //일이 한자리수인 경우
        date = "0" + date;

    var resultDate = "";   //예: 2009-10-02
    if (pFormat == undefined) {
        resultDate = year + pSplitStr + month + pSplitStr + date;   //예: 2009-10-02
    } else {
        if (pFormat == 'dot' || pFormat == 'dash' || pFormat == 'slash' || pFormat == 'enslash') {
            resultDate = year + pSplitStr + month + pSplitStr + date;   //예: 2009-10-02
        } else {
            resultDate = pFormat.replace("yyyy", year).replace("MM", month).replace("dd", date);
        }
    }

    return resultDate;
}

//javascript DelayTime 주기
function XFN_ScriptDelayTime(pMSeconds) {
    var then, now;
    then = new Date().getTime();
    now = then;
    while ((now - then) < pMSeconds) {
        now = new Date().getTime();
    }
}

/* 아래 함수는 기초설정값 구성한 후 주석 제거 */
//문자열 Server Format을 Local Date Format으로 단순변환
function XFN_TransDateLocalFormat(pServerDate, pLocalFormat) {
    var l_strResult = "";
    var l_strServerDateFormat = "yyyy-MM-dd";
    var l_strCheckDate = "";
    if (pLocalFormat == undefined || pLocalFormat == "") {
        pLocalFormat = "yyyy-MM-dd";
    }
    //2016.01.29 다양한 포맷에 대응하도록 수정
    var l_DateFormat = "";   //로컬 포맷 연결자

    // 입력 포멧 확인
    if (pLocalFormat.indexOf(".") > -1) { l_DateFormat = "."; }
    if (pLocalFormat.indexOf("-") > -1) { l_DateFormat = "-"; }
    if (pLocalFormat.indexOf("/") > -1) { l_DateFormat = "/"; }

    if (pServerDate.indexOf(".") > -1) { pServerDate = pServerDate.replace(/\./g, l_DateFormat); }
    if (pServerDate.indexOf("-") > -1) { pServerDate = pServerDate.replace(/\-/g, l_DateFormat); }
    if (pServerDate.indexOf("/") > -1) { pServerDate = pServerDate.replace(/\//g, l_DateFormat); }

    if (pServerDate != "") {

        l_strCheckDate = pLocalFormat.replace("yyyy", pServerDate.substr(pLocalFormat.indexOf("yyyy"), 4)).replace("MM", pServerDate.substr(pLocalFormat.indexOf("MM"), 2)).replace("dd", pServerDate.substr(pLocalFormat.indexOf("dd"), 2));

        if (pServerDate.length == 10) {
            if (l_strCheckDate != pServerDate) {
                l_strResult = pLocalFormat.replace("yyyy", pServerDate.substr(l_strServerDateFormat.indexOf("yyyy"), 4)).replace("MM", pServerDate.substr(l_strServerDateFormat.indexOf("MM"), 2)).replace("dd", pServerDate.substr(l_strServerDateFormat.indexOf("dd"), 2));
            } else {
                l_strResult = l_strCheckDate;
            }
        } else if (pServerDate.length > 10) {
            if (l_strCheckDate != pServerDate.substr(0, 10)) {
                l_strResult = pLocalFormat.replace("yyyy", pServerDate.substr(l_strServerDateFormat.indexOf("yyyy"), 4)).replace("MM", pServerDate.substr(l_strServerDateFormat.indexOf("MM"), 2)).replace("dd", pServerDate.substr(l_strServerDateFormat.indexOf("dd"), 2));
            } else {
                l_strResult = l_strCheckDate;
            }
            l_strResult += pServerDate.substr(10, pServerDate.length - 10);
        } else {
            l_strResult = pServerDate;
        }
    }

    return l_strResult;
}



////////////////date 관련///////////////////
Date.prototype.yyyymmddhhmm = function() {
	   var yyyy = this.getFullYear();
	   var mm = this.getMonth() < 9 ? "0" + (this.getMonth() + 1) : (this.getMonth() + 1); // getMonth() is zero-based
	   var dd  = this.getDate() < 10 ? "0" + this.getDate() : this.getDate();
	   var hh = this.getHours() < 10 ? "0" + this.getHours() : this.getHours();
	   var min = this.getMinutes() < 10 ? "0" + this.getMinutes() : this.getMinutes();
	   return "".concat(yyyy).concat("-").concat(mm).concat("-").concat(dd).concat(" ").concat(hh).concat(":").concat(min);
	  };
//////////////////////////////////////////////


/*Date format*/

Date.prototype.format = function(f) {
    if (!this.valueOf()) return " ";
    
    /* Common.getDicList 는 cache 없이 서버요청을 함.
    Common.getDicList(["lbl_Sunday","lbl_Monday","lbl_Tuesday","lbl_Wednesday","lbl_Thursday","lbl_Friday","lbl_Saturday"
    	, "lbl_AM", "lbl_PM"]);
	*/
	
	var weekName = [];
	if(f.indexOf("E") > -1){
	    weekName = [Common.getDic("lbl_Sunday"), Common.getDic("lbl_Monday"), Common.getDic("lbl_Tuesday")
    		, Common.getDic("lbl_Wednesday"), Common.getDic("lbl_Thursday"), Common.getDic("lbl_Friday"), Common.getDic("lbl_Saturday")];
	}
    
    var d = this;
    var h;

    return f.replace(/(yyyy|yy|MM|M|dd|d|E|hh|mm|ss|a\/p)/gi, function($1) {
        switch ($1) {
            case "yyyy": return d.getFullYear();
            case "yy": return (d.getFullYear() % 1000).zf(2);
            case "MM": return (d.getMonth() + 1).zf(2);
            case "M": return (d.getMonth() + 1);
            case "dd": return d.getDate().zf(2);
            case "d": return d.getDate();
            case "E": return weekName[d.getDay()];
            case "HH": return d.getHours().zf(2);
            case "hh": return ((h = d.getHours() % 12) ? h : 12).zf(2);
            case "mm": return d.getMinutes().zf(2);
            case "ss": return d.getSeconds().zf(2);
            case "a/p": return d.getHours() < 12 ? Common.getDic("lbl_AM") : Common.getDic("lbl_PM");
            default: return $1;
        }
    });
};

String.prototype.string = function(len){var s = '', i = 0; while (i++ < len) { s += this; } return s;};
String.prototype.zf = function(len){return "0".string(len - this.length) + this;};
Number.prototype.zf = function(len){return this.toString().zf(len);};

/* getStringDateToString(format,StringDate)
 * 용도 : mysql 기본 date형식을 바꾸는 fromat으로 바꾼다
 * getStringDateToString("yyyy-MM-dd HH:mm:ss","2016-01-01 11:11:11.0")
 *
//2011년 09월 11일 오후 03시 45분 42초
coviCmn.traceLog(new Date().format("yyyy년 MM월 dd일 a/p hh시 mm분 ss초"));

//2011-09-11
coviCmn.traceLog(new Date().format("yyyy-MM-dd"));

//'11 09.11
coviCmn.traceLog(new Date().format("'yy MM.dd"));

//2011-09-11 일요일
coviCmn.traceLog(new Date().format("yyyy-MM-dd E"));

//현재년도 : 2011
coviCmn.traceLog("현재년도 : " + new Date().format("yyyy"));
 * */
function getStringDateToString(a,b){
	if (b == "" || b == null || b == "undefined") return "";
	var datevar = Date.createFromMysql(b);
	return datevar.format(a);
}

function strToDate(strDate){
	if(strDate == undefined || typeof strDate != "string" || strDate.length < 6){
		return null;
	}
	
	strDate = strDate.replaceAll("-","/").replaceAll(".","/");
	
	return (new Date(strDate));
}

Date.createFromMysql = function(mysql_string)
{ 
   var t, result = null;

   if( typeof mysql_string === 'string' )
   {
      t = mysql_string.split(/[- :]/);

      //when t[3], t[4] and t[5] are missing they defaults to zero
      result = new Date(t[0], t[1] - 1, t[2], t[3] || 0, t[4] || 0, t[5] || 0);          
   }

   return result;   
}


//HTML문자열에서 텍스트만 뽑아오는 함수
function removeHtml(html){
	//
	html = html.replace(/<br>/ig, "\n");
	html = html.replace(/&nbsp;/ig, " ");
	// HTML 태그제거
	html = html.replace(/<(\/)?([a-zA-Z]*)(\s[a-zA-Z]*=[^>]*)?(\s)*(\/)?>/ig, "");
	html = html.replace(/<(no)?script[^>]*>.*?<\/(no)?script>/ig, "");
	html = html.replace(/<style[^>]*>.*<\/style>/ig, "");
	html = html.replace(/<(\"[^\"]*\"|\'[^\']*\'|[^\'\">])*>/ig, "");
	html = html.replace(/&[^;]+;/ig, "");
	html = html.replace(/\\s\\s+/ig, "");
	//
	return html;
} 



// ----------------------------------------------------- Array  -----------------------------------------------------------
function arrayCompare(arrayA, arrayB){
	if (arrayA.length != arrayB.length) { return false; }
    // sort modifies original array
    // (which are passed by reference to our method!)
    // so clone the arrays before sorting
    var a = jQuery.extend(true, [], arrayA);
    var b = jQuery.extend(true, [], arrayB);
    a.sort(); 
    b.sort();
    for (var i = 0, l = a.length; i < l; i++) {
        if (a[i] !== b[i]) { 
            return false;
        }
    }
    return true;
}
