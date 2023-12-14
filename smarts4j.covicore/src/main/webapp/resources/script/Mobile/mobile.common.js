/**
 * 
 * SmartS4j / MobileOffice / 모바일 공통 js 파일
 * 함수명 : mobile_comm_...
 * 
 */


/**
 * 
 * 기본 이벤트 바인딩
 * 
 */

$(document).on('pagebeforecreate', function (e, data){
	//로그인 페이지 화면 로드 시 실제 로그인 페이지 이동
	mobile_comm_sessionTimeOutCheck();
});

// 비정상적인 세션종료로 로그인 페이지가 로드된 경우 처리
function mobile_comm_sessionTimeOutCheck(){
	if($("#sessionTimeOutCheck").length > 0){
		$(".login_wrap").hide();
		location.href='/covicore/login.do';
	}
}
 
$(window).on('popstate', function(event) {
	try {
		var history_data = JSON.parse(window.sessionStorage["mobile_history_data"]);
		let idx  = history_data.length>2?history_data.length - 2:0;
		if(history_data[idx].indexOf(event.delegateTarget.location.pathname) > -1) {
			window.sessionStorage["mobile_history_index"] = parseInt(window.sessionStorage["mobile_history_index"]) - 1;
		}
		var thisPop = $("#" + $.mobile.activePage.attr( "id" ));
		if($(thisPop).attr("data-role") == "dialog"){
			setTimeout(function(){ $(thisPop).remove()}, 150);
		}
	} catch(e) {mobile_comm_log(e);
	}
});

$(document).on("scrollstop", function (e) {
	mobile_comm_scrollEvent(e);
});


/**
 * 
 * JQM 이벤트 바인딩
 * 
 */
// JQM> pagecreate 공통
$(document).on('pagecreate', function (e, data) {
	
	//팝업일 경우 당겨서 새로고침 방지 호출
	if($(this)[0].location.hash.indexOf("dialog") > -1){
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}
	} 
});

// JQM> pageshow 공통 
$(document).on('pageshow', function (e) {
	//뒤로가기 버튼 display 처리
	try {
		if(mobile_comm_isAndroidApp()) {
		    window.covimoapp.onJQMShow(e.target.id);
		} else if(mobile_comm_isiOSApp()) {
		    window.webkit.messageHandlers.callbackHandler.postMessage({ type:'onjqmshow', page: e.target.id }); 
		}
	} catch(e) {
		mobile_comm_log(e);
	}
	
	//음성인식 바인딩
	if(mobile_comm_isMobileApp() && mobile_comm_getSession('lang') == "ko" && mobile_comm_getBaseConfig("IsUseVoiceRecognition") == "Y") {
		// 보이스 인풋 컨트롤 바인딩
		setTimeout("mobile_comm_VoiceInputCtrlBind()", 100);
	}
	
	//home.do에서 전체메뉴 open
	if(e.target.id == "portal_home_page") {
		mobile_comm_openleftmenu();
	}else{
		mobile_comm_closeleftmenu();
	}

	mobile_comm_hideload();
	// mobile_comm_uploadhtml();
	
	//작성페이지 키보드 이벤트 처리 추가
	if(e.target.id.indexOf("_write_") > -1) {
		$("#" + e.target.id + " input, textarea").each(function() {
			$(this).bind("focus", function() {
				$("header").css("position", "absolute");
			});
			$(this).bind("blur",function() {
				$("header").css("position", "fixed");
			});
		});
	}
	
	//에디터 초기화 방지
	if($(this)[0].location.hash.indexOf("dialog") > -1){ 
		if($(e.target).find("#MobileEditorFrame").length && $(e.target).attr("IsAppend") == "Y" && mobileEditor.tempHtml != ""){
			mobileEditor.setBody(mobileEditor.tempHtml);
			mobileEditor.tempHtml = "";
			$("#MobileEditorFrame").contents().find("#covieditorContainer").height(mobileEditor.tempHeight);
		}
		
		if($(e.target).find(".opt_setting").length > 0) {
			$(e.target).find(".opt_setting").each(function () {
				if($(this).attr('onclick') == undefined || $(this).attr('onclick') == "") {
					$(this).unbind().click(function () {
						if(!$(this).hasClass('disable')) {
							if($(this).hasClass('on')) {
								$(this).removeClass('on');
							} else {
								$(this).addClass('on');
							}
						}
					});
				}
			});
		}
	}
});

//에디터 초기화 방지
$(document).on('pagebeforehide', function (e) {
	if($(this)[0].location.hash.indexOf("dialog") > -1){ 
		if($(e.target).attr("IsAppend") != "Y") {
			if($(e.target).find("#MobileEditorFrame").length  && document.getElementById('MobileEditorFrame').contentWindow.tinymce != undefined){//에디터가 있고 렌더링이 되어있으면
				mobileEditor.tempHtml = mobileEditor.getBodyTemp();
				mobileEditor.tempHeight = $("#MobileEditorFrame").contents().find("#covieditorContainer").height();
			}
		}
	} 
});


//JQM> pagecreate 공통
$(document).on('pagehide', function (e) {
	//페이지 이동시 유지 및 팝업시 컨텐츠 제거 처리
	if($(this)[0].location.hash.indexOf("dialog") > -1){
		// 돔을 계속 뜯었다 붙였다 하는 것 막기(메일의 경우 iFrame에 들어 있는 객체가 초기화됨)
		if($(e.target).attr("IsAppend") != "Y") {
			$("#mobile_content").append($(e.target));
			if($(e.target).find(".hasDatepicker")){
				$(e.target).find(".hasDatepicker").removeClass('hasDatepicker').removeData('datepicker').unbind();
				$(e.target).find(".input_date").datepicker({
				    dateFormat : 'yy.mm.dd',
				    dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
				});
			}
			
			$(e.target).attr("IsAppend", "Y");
		}			
	} else {
		$("#" + e.target.id).remove();
	}
});







/**
 * 
 * 공통 함수 (pc)
 * 
 */



/**
 * coviMobileStorage : 모바일 로컬 스토리지 관련 함수 제공
 * 
 * @author dyjo
 * @since 2019.04.16
 */
var coviMobileStorage = {
	/* session 데이터를 저장하기 위한 객체 */ 
	session : null,
	
	/* 다국어 데이터를 저장하기 위한 객체 */ 
	dictionary : null,
	
	/* 기초설정 데이터를 저장하기 위한 객체 */ 
	baseConfig : null,
	baseConfigLocal : null,
	
	/* 로컬 스토리지 초기화 */
	init : function () {
		if (coviMobileStorage.session == null) {
			coviMobileStorage.session = mobile_comm_getSession();
		}
		
		if (coviMobileStorage.dictionary == null) {
			coviMobileStorage.dictionary = coviMobileStorage.getValue("Dictionary");
		}
	},
	
	/* 로컬 스토리지 사용 가능 여부 확인 */
	isAvailable : function () {
		var x = "__storage_test__";
		
		try {
			localStorage.setItem(x, x);
			localStorage.removeItem(x);
		    return true;
		} catch(e) {
			return false;
		}		
	},
	
	/* callback 함수를 지원하는 비동기 Ajax 함수 */
	asyncSubmit : function (url, params, callback) {
		$.ajax({
			async : true,
			url : url,
			type : "POST",
			data : JSON.stringify(params),
			dataType : "json",
			contentType : "application/json; charset=utf-8",
			success : function (result) {
				callback(result);
			},
			error : function (response, status, error) {
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});				
	},
	
	/* session 객체에서 특정 키에 해당하는 값 리턴 */ 
	getSessionValue : function (key) {
		if (coviMobileStorage.session == null) {
			coviMobileStorage.session = mobile_comm_getSession();
		}
		
		var sessionValue = coviMobileStorage.session[key];
		return sessionValue;
	},
	
	/* 로컬 스토리지에서 특정 키에 해당하는 값 리턴 */
	getValue : function (key) {
		var value = localStorage.getItem(key);
		return value;
	},
	
	/* 로컬 스토리지에 키와 값을 저장 */
	setValue : function (key, value) {
		localStorage.setItem(key, value);
	},
	
	/* 로컬 스토리지에서 Dictionary 데이터 조회 */
	getDictionary : function () {
		if (coviMobileStorage.dictionary == null) {
			coviMobileStorage.dictionary = coviMobileStorage.getValue("Dictionary");
		}
		
		return coviMobileStorage.dictionary;
	},
	
	setConfig : function () {
		coviMobileStorage.baseConfigLocal = coviMobileStorage.getValue("BaseConfig_"+mobile_comm_getSession("DN_ID"));
		coviMobileStorage.baseConfig = coviMobileStorage.getValue("BaseConfig_0");
	},
	
	/* Dictionary 데이터에서 특정 다국어 코드에 해당하는 메시지 리턴 */
	getMessage : function (key) {
		var msg = null;	
		var dictionary = coviMobileStorage.getDictionary();
		if (dictionary != null) {
			var beginIdx = dictionary.indexOf("†" + key + "§") + 1;
			
			if (beginIdx != 0) {
				var endIdx = dictionary.indexOf("†", beginIdx);
				var dicData = dictionary.substring(beginIdx, endIdx);
			
				if (dicData != null) {
					msg = dicData.split("§")[1];
				}
			} else {
				msg = "";
			}
		}
		
		return msg;
	},
	
	/* 로컬 스토리지의 Dictionary, DictionarySyncTime 데이터 삭제 */
	clear : function (pType) {
		if(pType != undefined){
			if(pType == "Dictionary") {
				localStorage.removeItem("Dictionary");
				localStorage.removeItem("DictionarySyncTime");
				localStorage.removeItem("DictionaryLang");
				coviMobileStorage.dictionary = null;
			} else if(pType == "Config") {
				localStorage.removeItem("BaseConfig_0");
				localStorage.removeItem("BaseConfig_"+mobile_comm_getSession("DN_ID"));
				localStorage.removeItem("BaseConfigSyncTime");	
				coviMobileStorage.baseConfigLocal = null;	
				coviMobileStorage.baseConfig = null;
			}
		} else {
			localStorage.removeItem("Dictionary");
			localStorage.removeItem("DictionarySyncTime");
			localStorage.removeItem("DictionaryLang");
			localStorage.removeItem("BaseConfig_0");
			localStorage.removeItem("BaseConfig_"+mobile_comm_getSession("DN_ID"));
			localStorage.removeItem("BaseConfigSyncTime");	
			coviMobileStorage.baseConfigLocal = null;	
			coviMobileStorage.baseConfig = null;
			coviMobileStorage.dictionary = null;
		}		
	},
	getBaseConfig: function(key, pDN_ID) {
		var baseConfigDN = null;
		var msg = "";
		if( pDN_ID == undefined ) {
			pDN_ID = mobile_comm_getSession("DN_ID");
		}
		
		if(coviMobileStorage.baseConfigLocal == null) {
			coviMobileStorage.baseConfigLocal = localStorage.getItem("BaseConfig_"+pDN_ID);	
			coviMobileStorage.baseConfig = localStorage.getItem("BaseConfig_0");
		}
		
		if(pDN_ID == 0){
			baseConfigDN = coviMobileStorage.baseConfig;
		} else {
			baseConfigDN = coviMobileStorage.baseConfigLocal;	
		}
		
        if (baseConfigDN != null) {
            var beginIdx = baseConfigDN.indexOf("†" + key + "§") + 1;
            if (beginIdx != 0) {
                var endIdx = (baseConfigDN.indexOf("†", beginIdx) === -1) ? baseConfigDN.length : baseConfigDN.indexOf("†", beginIdx);
                var dicData = baseConfigDN.substring(beginIdx, endIdx);
				
                if (dicData != null) {
                    msg = dicData.split("§")[1];
                }
            } else {
                if(pDN_ID != 0 && pDN_ID != undefined){ //현재 도메인에 지정된 기초설정 값이 없을 경우 그룹사(공용)값 조회
                	msg = coviMobileStorage.getBaseConfig(key,0);
                }
            }
        }else{ //그룹사(공용), 현재 도메인 모두에 설정된 값이 없을 경우 
        	msg = mobile_comm_getBaseConfigDirect(key, pDN_ID);
        }
		
        return msg;
	},
	
	/* 로컬 스토리지 동기화 */
	syncStorage : function () {
		var isAvailable = coviMobileStorage.isAvailable();
		if (isAvailable) {
			var isSubmit = true;
			// 다국어 동기화 
			var dicSyncLang = coviMobileStorage.getValue("DictionaryLang");
			var dicSyncTime = coviMobileStorage.getValue("DictionarySyncTime");
			if (dicSyncTime != undefined && dicSyncTime != "") {
				var sysSyncLang = coviMobileStorage.getSessionValue("lang");
				var sysSyncTime = coviMobileStorage.getSessionValue("SYS_SYNC_TIME");
				// 언어가 다를 경우 재캐싱 하여야 함. hbkim
				if (sysSyncTime != null && sysSyncTime != "") {
					var dtime = parseInt(dicSyncTime);
					var stime = parseInt(sysSyncTime);
					if (dtime > stime) {
						isSubmit = false;
					}
				} else {
					isSubmit = false;
				}
			}
	
			if (isSubmit) {
				coviMobileStorage.session = mobile_comm_getSession();
				var url = "/covicore/common/syncStorage.do";
				var params = {};
				
				coviMobileStorage.asyncSubmit(url, params, function (result) {
					var target = result;
					
					if (target != null) {
						coviMobileStorage.clear('Dictionary');
						coviMobileStorage.setValue("DictionaryLang", coviMobileStorage.getSessionValue("lang"));	
						for (var key in target) {
							coviMobileStorage.setValue(key, target[key]);
						}
					}
					coviMobileStorage.dictionary = null;
					coviMobileStorage.getDictionary();
				});
			}
			
			// 기초설정값 동기화 
			isSubmit = true; 
			var configSyncTime = coviMobileStorage.getValue("BaseConfigSyncTime");
			if (configSyncTime != undefined && configSyncTime != "") {
				var sysSyncTime = coviMobileStorage.getSessionValue("SYS_BASE_CONFIG_SYNC_TIME");
				// 언어가 다를 경우 재캐싱 하여야 함. hbkim
				if (sysSyncTime != null && sysSyncTime != "") {
					var dtime = parseInt(configSyncTime);
					var stime = parseInt(sysSyncTime);
					if (dtime > stime) {
						isSubmit = false;
					}
				} else {
					isSubmit = false;
				}
			}
			
			if (isSubmit) {
				var params = { objectType: "BASE_CONFIG" };
				coviMobileStorage.asyncSubmit("/covicore/common/syncBaseCfNCd.do", params, function (result) {
                    var target = result;

                    if (target != null) {
                    	coviMobileStorage.clear('Config');

                        for (var key in target) {
                        	coviMobileStorage.setValue(key, target[key]);
                        }
                    }
                    coviMobileStorage.setConfig(); 
                });
			}
			
		} else {
			alert("This browser do not support Local Storage.");
		}
	}
};

//모바일 글로벌 캐시
var mobile_globalCache = {};

// 다국어/기초설정 로컬스토리지 동기화 
coviMobileStorage.syncStorage();

//기초설정값 조회
function mobile_comm_getBaseConfig(pKey, pDN_ID) {
	var returnData = coviMobileStorage.getBaseConfig(pKey, pDN_ID);
	if( returnData == null || returnData == "") {
		returnData = mobile_comm_getBaseConfigDirect(pKey, pDN_ID);
	}
		
	return returnData;
};

//기초설정값 바로 Radis에서 가져오기
function mobile_comm_getBaseConfigDirect(pKey, pDN_ID) {
	
	var returnData = "";
	
	if(pDN_ID == undefined) {
		pDN_ID = mobile_comm_getSession("DN_ID");	// TODO: 0으로 변경해야 함
	}
	
	var jsonData = {};
	jsonData["key"] = pKey;
	jsonData["dn_id"] = pDN_ID;
	
	if (mobile_globalCache[pKey + "_" + pDN_ID] == "undefined" || mobile_globalCache[pKey + "_" + pDN_ID] == null) {
		var url = "/covicore/common/getbaseconfig.do";
		$.ajax({
			url: url,
			data: jsonData,
			type: "post",
			async: false,
			success: function(res) {
				if (res.status == "SUCCESS") {
					returnData = res.value;
					mobile_globalCache[pKey + "_" + pDN_ID] = returnData;
				} else {
					alert("mobile_comm_getSession : " + res.message);
				}
			},
			error: function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
	} else {
		returnData = mobile_globalCache[pKey + "_" + pDN_ID];
	}
	
	return returnData;
};


//기초설정값 일괄 조회
/*
 * 기초설정 일괄 조회용 공통 스크립트 pConfigArray 기초설정값 : (Array) ["ImageServiceURL",
 * "BoardMain", ...] ex) mobile_comm_getBaseConfigList(["lbl_Registor",
 * "lbl_Approval", "lbl_Rejected"]);
 */
function mobile_comm_getBaseConfigList(pConfigArray){
	var sDN_ID = mobile_comm_getSession("DN_ID");
	var arrConfig = {};
	if(typeof (pConfigArray) != "object" && pConfigArray.indexOf(";") > -1) {
		arrConfig = pConfigArray.split(";");
	}
	
	// 캐시에 존재한다면 지운다.
	$(arrConfig).each(function (idx, obj) {
		if(mobile_globalCache[obj + "_" + sDN_ID] != undefined) {
			var idx = arrConfig.indexOf(obj)
			if (idx > -1) {
				$(arrConfig).splice(idx, 1)
			}
		}
	});
	
	// 가져올 설정값일 있을 경우만 호출한다.
	if(arrConfig.length > 0){
		var param = {
			configArray : encodeURIComponent(JSON.stringify(arrConfig))
		}
		
		$.ajax({
			url:"/covicore/common/getBaseConfigList.do",
			data: param,
			type:"post",
			async:false,
			success: function (res) {
				if(res.status == "SUCCESS"){
					// $.extend(mobile_globalCache, res.configMap);
					$(arrConfig).each(function (idx, obj) {
						mobile_globalCache[obj + "_" + sDN_ID] =  res.configMap[obj];
					});
				}
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror("/covicore/common/getBaseConfigList.do", response, status, error);
			}
 		});	
	}
}

// 기초코드값 조회
function mobile_comm_getBaseCode(pCodeGroup) {
	
	var returnData = "";
	
	if (pCodeGroup == undefined || pCodeGroup == null) return returnData;
	
	if (mobile_globalCache["CODE_" + pCodeGroup] == "undefined" || mobile_globalCache["CODE_" + pCodeGroup] == null) {
		var url = "/covicore/common/getbasecode.do";
		var jsonData = {};
		jsonData["key"] = pCodeGroup;
		$.ajax({
			url : url,
			data : jsonData,
			type : "post",
			async : false,
			success : function(res) {
				returnData = res.value;
				mobile_globalCache["CODE_" + pCodeGroup] = returnData;
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
		
	} else {
		returnData = mobile_globalCache["CODE_" + pCodeGroup];
	}
	
	return returnData;
}

//기초코드값 일괄조회
/*
 * 기초코드 일괄 조회용 공통 스크립트 pCodeArray 기초코드 : (Array) ["BizSection", "TodoMsgType",
 * ...] ex) mobile_comm_getBaseCodeList(["BizSection", "TodoMsgType", ...]);
 * 
 */
function mobile_comm_getBaseCodeList(pCodeArray){
	if(pCodeArray.length > 0){
		var param = {
			codeGroupArray : encodeURIComponent(JSON.stringify(pCodeArray))
		}
		
		$.ajax({
			url:"/covicore/common/getBaseCodeList.do",
			data: param,
			type:"post",
			async:false,
			success: function (res) {
				if(res.status == "SUCCESS"){
					// $.extend(mobile_globalCache, res.codeMap);
					$(pCodeArray).each(function (idx, obj) {
						var dicItem = res.configMap[obj];
						mobile_globalCache["CODE_" + obj] = dicItem;
					});
				}
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror("/covicore/common/getBaseCodeList.do", response, status, error);
			}
		});	
	}
}

function mobile_comm_getBaseCodeDic(pStrGroupCode, code ) {
    if (pStrGroupCode == undefined) return;

    var returnData = "";

	if (mobile_globalCache["CODE_" + pStrGroupCode] == "undefined" || mobile_globalCache["CODE_" + pStrGroupCode] == null) {
		var jsonData = {};
		jsonData["key"] = pStrGroupCode;
		
		$.ajax({
			url : "/covicore/common/getbasecode.do",
			data : jsonData,
			type : "post",
			async : false,
			success : function(res) {
				returnData = res.value;
				mobile_globalCache["CODE_" + pStrGroupCode] = returnData;
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror("/covicore/common/getbasecode.do", response, status, error);
			}
		});
		
	} else {
		returnData = mobile_globalCache["CODE_" + pStrGroupCode];
	}

    if (code != null && code != ""){
        for (var i = 0; i < returnData["CacheData"].length; i++) {
    		var item = returnData["CacheData"][i];
    		if (code == item["Code"]) return CFN_GetDicInfo(item["MultiCodeName"]);
    	}
        return pStrGroupCode+"_"+code;
    }
    else     return returnData;
};

//세션 조회
function mobile_comm_getSession(pKey) {
	var returndata = "";
	if (typeof pKey == undefined || mobile_globalCache[pKey] == "undefined" || mobile_globalCache[pKey] == null) {
		var url = "/covicore/common/getSession.do";
		$.ajax({
			url : url,
			data : {
				"key" : pKey
			},
			type : "post",
			async : false,
			success : function(res) {
				if (res.status == "SUCCESS") {
					if ($(res.resultList).length >= 1 && pKey != undefined && pKey != "" && pKey != null) {
						returndata = res.resultList[pKey];
						mobile_globalCache[pKey] = returndata;
					} else if ($(res.resultList).length >= 1) {
						returndata = res.resultList;
						$.extend(mobile_globalCache, res.resultList);
					} else {
						returndata = res.resultList;
						mobile_globalCache[pKey] = returndata;
					}
				} else {
					alert("mobile_comm_getSession : " + res.message);
				}
			},
			error: function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
	} else {
		returndata = mobile_globalCache[pKey]
	}
	
	return returndata;
}

// 다국어 조회
/* 기존 mobile_comm_getDic 함수에 로컬 스토리지로부터 다국어 조회하는 코드 추가 - dyjo 2019.04.16 */
function mobile_comm_getDic(pKey) {
	var returnData = "";
	var dicMap = {};
	if(pKey!==null && pKey!==undefined && pKey.indexOf(';') > -1){
		var dictionary = coviMobileStorage.getDictionary();
		
		if (dictionary != null) {
			
			var msg = "";
			$.each(pKey.split(";"), function (idx, pDic) {
				if (pDic != undefined && pDic != "") {
					msg = coviMobileStorage.getMessage(pDic);
					dicMap[pDic] = msg;
				}
			});
			returnData = {};			
			returnData[0] = dicMap;
		}
	} else {
		returnData = coviMobileStorage.getMessage(pKey);	
	}
	 
	if (returnData == null || returnData == "" ) {
		var jsonData = {};
		var lang = mobile_comm_getSession("lang");
		jsonData["keys"] = pKey;
		
		if (mobile_globalCache[pKey] == "undefined" || mobile_globalCache[pKey] == null || mobile_globalCache[pKey] == "") {
			var url = "/covicore/common/getdicall.do";
			$.ajax({
				url: url,
				data: jsonData,
				type: "post",
				async: false,
				success: function(res) {
					if (res.status == "SUCCESS") {
						returnData = res.list;
						$.extend(mobile_globalCache, res.dicMap);
						mobile_globalCache[pKey] = returnData;
					} else {
						alert("mobile_comm_getDic : " + res.message);
					}
				},
				error: function(response, status, error){
					mobile_comm_ajaxerror(url, response, status, error);
				}
			});
		} else {
			returnData = mobile_globalCache[pKey];
		}
	}
	
	return returnData;
}

//다국어 일괄조회
/*
 * 다국어 일괄 조회용 공통 스크립트 pDicArray 다국어코드 : (Array) ["lbl_Registor", "lbl_Approval",
 * "lbl_Rejected"] pDicType 다국어 타입 : (String) Full, Short pLocale 국가코드 :
 * (String) ko, en, ja, zh
 * 
 * ex) mobile_comm_getDicList(["lbl_Registor", "lbl_Approval", "lbl_Rejected"]);
 * 
 */
/* 기존 mobile_comm_getDicList 함수에 로컬 스토리지로부터 다국어 조회하는 코드 추가 - dyjo 2019.04.16 */
function mobile_comm_getDicList(pDicArray, pDicType, pLocale){
	if(pDicArray.length > 0){
		var dictionary = coviMobileStorage.getDictionary();
		
		if (dictionary != null) {
			var dicMap = {};
			var msg = "";

			$.each(pDicArray, function (idx, pDic) {
				if (pDic != undefined && pDic != "") {
					msg = coviMobileStorage.getMessage(pDic);
					dicMap[pDic] = msg;
				}
			});
			
			$.extend(mobile_globalCache, dicMap)
		} else {		
			var param = {
				dicArray : encodeURIComponent(JSON.stringify(pDicArray))
			}
			
			$.ajax({
				url:"/covicore/common/getDicList.do",
				data: param,
				type:"post",
				async:false,
				success: function (res) {
					if(res.status == "SUCCESS"){
						$.extend(mobile_globalCache, res.dicMap);
					}
				},
				error:function(response, status, error){
					mobile_comm_ajaxerror("/covicore/common/getDicList.do", response, status, error);
				}
			});
		}
	}
}

/* 기존 mobile_comm_getDicAll 함수에 로컬 스토리지로부터 다국어 조회하는 코드 추가 - dyjo 2019.04.16 */
function mobile_comm_getDicAll(pStr, pDicType, pLocale) {
	var returnData = {};
	var jsonData = {};

	if(pDicType != "" && pDicType != undefined && pDicType != null && pDicType != "undefined" && pDicType != "null"){
		jsonData["dicType"] = pDicType;
	}

	if(pLocale != "" && pLocale != undefined && pLocale != null && pLocale != "undefined" && pLocale != "null"){
		jsonData["locale"] = pLocale;
	}else{
		var lang = mobile_comm_getSession("lang");
		if(typeof lang != undefined && lang != ""){
			jsonData["locale"] = lang;
		} else {
			jsonData["locale"] = "ko";
		}
	}

	var keyStrs="";
	
	if($.isArray(pStr)==true){
		$(pStr).each(function(idx, obj){
			keyStrs += obj+";";
		});
	} else {
		keyStrs = pStr;
	}
	
	var arrKeys = keyStrs.split(";");

	if(arrKeys.length > 1){
		var dictionary = coviMobileStorage.getDictionary();
		
		if (dictionary != null) {
			var msg = "";
			$.each(arrKeys, function (idx, obj) {
				if (obj != null) {
					msg = coviMobileStorage.getMessage(obj.toString());
					returnData[obj.toString()] = msg;
				}
			});
			
			return returnData;	
		} else {
			// 로컬캐쉬 체크
			var pKeys = "";
			$(arrKeys).each(function (i, item) {
				if(item != ""){
					if(mobile_globalCache[item] != undefined) {
						returnData[item] = mobile_globalCache[item];
					} else {
						pKeys += item + ";";
					}	
				}
			});

			if(pKeys.split(';').length > 1){
				jsonData["keys"] = pKeys;
				
				$.ajax({
					url:"/covicore/common/getdicall.do",			// [2016-10-26]
																	// 박경연.
																	// approval/user에서
																	// 접근할 때 문제가
																	// 있음
					data:jsonData,
					type:"post",
					async:false,
					success: function (res) {
						$(pKeys.split(';')).each(function (idx, obj) {
							var dicItem = res.list[0][obj];
							returnData[obj.toString()] = dicItem;
							mobile_globalCache[obj] = dicItem;
						});
					},
					error:function(response, status, error){
						mobile_comm_ajaxerror("/covicore/common/getdicall.do", response, status, error);
					}
				});
			}
		
			return returnData;
		}
	} else {
		arrKeys[0] = arrKeys[0] == null ? "" : arrKeys[0];
		return mobile_comm_getDic(arrKeys[0]);
	}
	
};

// 다국어 값을 원하는 언어값으로 리턴
function mobile_comm_getDicInfo(pValue, pLangCode) {
	var returndata = pValue;
	var languageIndex = { "ko": 0, "en": 1, "ja": 2, "zh": 3, "e1": 4, "e2": 5, "e3": 6, "e4": 7, "e5": 8, "e6": 9 }; // 다국어
																														// 인덱스
																														// 값
	var arrValue = null;

	try {
		if(pLangCode == undefined) {
			pLangCode = mobile_comm_getSession('lang');
		}
		
		if(pLangCode == undefined || pLangCode == "") {
			pLangCode = "ko";
		}
		
		arrValue = pValue.split(';');
		if(languageIndex[pLangCode] <= arrValue.length) {
			returndata = arrValue[languageIndex[pLangCode]];
		}
		if(returndata == undefined || returndata == ""){
			returndata = arrValue[0];
		}
	} catch(e) {mobile_comm_log(e);
	}
	
	if(returndata == undefined) {
		returndata = "";
	}
	
	return returndata;
}

//로컬캐시,로컬스토리지 Clear
function mobile_comm_clearLocalCache() {
// localCache.data = {};
	mobile_globalCache.data = {};
// localStorage.clear(); // 로컬 스토리지 다국어 적용을 위해 주석 처리 - dyjo 2019.04.16
}

// 캐시 지우기
function mobile_comm_clearCache() {
// localCache = {};
	mobile_globalCache = {};
	sessionStorage.clear();
	var sUrl = "/covicore/cache/clearUserCache.do";
	
	$.ajax({
		url:sUrl,
			type:"post",
			data:{},
			success : function(res) {
			if (res.status == "SUCCESS") {
				alert(mobile_comm_getDic("msg_ProcessOk"), "", function(){
					location.reload();
				});
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(sUrl, response, status, error);
		}
	});
}

//global properties 값 가져오기
function mobile_comm_getGlobalProperties(pKey) {
	var returnData = "";
	
	if (Storage !== void(0) && localStorage.getItem(pKey) != null) {
		returnData = localStorage.getItem(pKey);
	} else {
		if(pKey != undefined && pKey != ""){
			$.ajax({
				url : "/covicore/helper/getglobalproperties.do", // [2016-06-09]
																	// 박경연.
																	// approval에서
																	// 접근할 때 문제가
																	// 있음
				data : {
					"key" : pKey
				},
				type : "post",
				async : false,
				success : function(res) {
					if(res.status == "SUCCESS"){
						returnData = res.value;
						localStorage.setItem(pKey, returnData);
					}
					else{
						returnData = undefined;
					}
				},
				error:function(response, status, error){
					mobile_comm_ajaxerror("helper/getglobalproperties.do", response, status, error);
				}
			});
		}
	}
	return returnData;
}

// Extension Properties 값 가져오기
function mobile_comm_getExtensionProperties(pKey){
	var returnData = "";
	
	if (mobile_globalCache[pKey] == "undefined" || mobile_globalCache[pKey] == null || mobile_globalCache[pKey] == "") {
		if(pKey != undefined && pKey != ""){
			$.ajax({
				url : "/covicore/helper/getextensionproperties.do",
				data : {
					"key" : pKey
				},
				type : "post",
				async : false,
				success : function(res) {
					if(res.status == "SUCCESS"){
						returnData = res.value;
						mobile_globalCache[pKey] = returnData;
					}
					else{
						returnData = undefined;
					}
				},
				error:function(response, status, error){					
					mobile_comm_ajaxerror(url, response, status, error);
				}
			});
		}
	}else{
		returnData = mobile_globalCache[pKey];
	}	
	return returnData;
}

// Security Properties 값 가져오기
function mobile_comm_getSecurityProperties(pKey){
	var returnData = "";
	
	if (mobile_globalCache[pKey] == "undefined" || mobile_globalCache[pKey] == null || mobile_globalCache[pKey] == "") {
		if(pKey != undefined && pKey != ""){
			$.ajax({
				url : "/covicore/helper/getsecurityproperties.do",
				data : {
					"key" : pKey
				},
				type : "post",
				async : false,
				success : function(res) {
					if(res.status == "SUCCESS"){
						returnData = res.value;
						mobile_globalCache[pKey] = returnData;
					}
					else{
						returnData = undefined;
					}
				},
				error:function(response, status, error){					
					mobile_comm_ajaxerror(url, response, status, error);
				}
			});
		}
	}else{
		returnData = mobile_globalCache[pKey];
	}	
	return returnData;
}

// Extension Properties 값 가져오기
function mobile_comm_getExtensionProperties(pKey){
	var returnData = "";
	
	if (mobile_globalCache[pKey] == "undefined" || mobile_globalCache[pKey] == null || mobile_globalCache[pKey] == "") {
		if(pKey != undefined && pKey != ""){
			$.ajax({
				url : "/covicore/helper/getsecurityproperties.do",
				data : {
					"key" : pKey
				},
				type : "post",
				async : false,
				success : function(res) {
					if(res.status == "SUCCESS"){
						returnData = res.value;
						mobile_globalCache[pKey] = returnData;
					}
					else{
						returnData = undefined;
					}
				},
				error:function(response, status, error){					
					mobile_comm_ajaxerror(url, response, status, error);
				}
			});
		}
	}else{
		returnData = mobile_globalCache[pKey];
	}	
	return returnData;
}


















/**
 * 
 * 모바일 공통 함수
 * 
 */

//페이지 이동
function mobile_comm_go(url, ispopup) {
	if(url == undefined || url == "") {
		return;
	}

/*	if (url.indexOf("/groupware/mobile/portal")== -1){	//portal 아닌경우 
		$("#mobile_content").removeClass("ui_portal");
	}*/
	// Teams Add-In 용 파라미터 추가
	try {
		if (_IsTeamsAddIn) {
			if (url.indexOf("teamsaddin=") == -1) {
				if (url.indexOf("?") > -1) {
					url += "&teamsaddin=Y";
				} else {
					url += "?teamsaddin=Y";
				}
			}
		}
	} catch(e) { 
		mobile_comm_log(e);
	}

	// 페이지가 통합알림일 경우, 이동할 페이지가 통합알림이면, 메뉴를 닫고 종료한다.
	if ($('#portal_integrated_page[data-role=page]').length > 0 && url.indexOf('integrated') > -1){
		mobile_comm_closeleftmenu(); return;
	}
	
	if(ispopup != "Y") {
		$("div:jqmData(role='page'), div:jqmData(role='dialog')").remove();
	}
	
//	var thisPop = $("#"+$.mobile.activePage.attr( "id" ));
//	
//	if($(thisPop).attr("data-role") == "dialog"){
//		
//	} else if(location.pathname == url.split("?")[0]) {		
//		mobile_comm_closeleftmenu();
//		
//		return;
//	} 
	
	mobile_comm_showload();
	
	// sessionStorage에 페이지 이동을 기록
	var arrHistoryData = new Array();
	try {
        JSON.parse(window.sessionStorage["mobile_history_data"]).length;
        arrHistoryData = JSON.parse(window.sessionStorage.getItem("mobile_history_data"));
    } catch (e) {
    	arrHistoryData = new Array();
    }
	arrHistoryData.push(url);
	
	window.sessionStorage["mobile_history_data"] = JSON.stringify(arrHistoryData);
	window.sessionStorage["mobile_history_index"] = arrHistoryData.length - 1;

	var sUrl = url;
	if(ispopup == "Y") {
		if(sUrl.indexOf("?") > -1) {
			sUrl += "&IsPopup=Y";
		} else {
			sUrl += "?IsPopup=Y";
		}
	}
	var sOption = { transition: '', reloadPage: true };
	if(ispopup == "Y") {
		sOption = { transition: 'pop', role: 'dialog', reload: true };
	}
	
	// 웹전용 하단메뉴 닫기
	if($("#btnBottomMenuOpen").hasClass("Bmenu_close")){
		$("#btnBottomMenuOpen").click();
	}
	
	//dialog가 아닌경우 조직도 view 모드로 변경
	if(url == "/covicore/mobile/org/list.do" && ispopup != "Y") {
		window.sessionStorage["mode"] = "View";
	}
	
	// 페이지 이동시 음성인식 중지
	if(mobile_comm_isMobileApp()){
		mobile_comm_callappstopvoicerecognition();
	}
	
	// 인디메일 링크 연결 등을 위해 추가함
	if(sUrl.toUpperCase().indexOf("HTTP://") > -1 || sUrl.toUpperCase().indexOf("HTTPS://") > -1) {
		location.href = sUrl;
		mobile_comm_hideload();
	} else {
		// if(ispopup == "Y") {
		// $.mobile.changePage(sUrl, sOption);
		// } else {
			$.mobile.defaultPageTransition = "none";
			$.mobile.pageContainer.pagecontainer("change", sUrl, sOption);	
		// }
	}
	
	if($(".bg_dim").css("display") != "none") {
		$(".bg_dim").hide();
	}
	var exmenu = $(".dropMenu");
	var dropmenu= $(".btn_drop_menu");
	if(exmenu.length > 0)
		$(exmenu).removeClass('show');		
	if(dropmenu.length > 0){		
		$(dropmenu).siblings('div.exmenu_layer').hide();
	}
}

//페이지 이동-(웹)새창 (앱)외부브라우저
function mobile_comm_openurl(url) {
	try {
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.callBrowser(url);
		} else if(mobile_comm_isiOSApp()) {
			window.webkit.messageHandlers.callbackHandler.postMessage({ type:'covibrowser', url: url }); 
		} else {
			window.open(url, "openurl", "", true);
		}
	} catch (e) {mobile_comm_log(e);
	}
}

//뒤로가기
function mobile_comm_back(pPopNextPage) {

	// mobile_comm_showload();
	// 자원작성 시 입력된 값 초기화
	// window.sessionStorage.removeItem("ResourceWrite_SelectResource_ID_" +
	// mobile_comm_getSession("UR_Code"));
	// window.sessionStorage.removeItem("ResourceWrite_SelectResource_Name_" +
	// mobile_comm_getSession("UR_Code"));

	var thisPop = $("#" + $.mobile.activePage.attr( "id" ));
	// 페이지 이동시 음성인식 중지
	if(mobile_comm_isMobileApp()){
		mobile_comm_callappstopvoicerecognition();
	}
	if(pPopNextPage != undefined){
		setTimeout(function() {mobile_comm_go(pPopNextPage, 'Y');}, 100);
	}

	if($(thisPop).attr("data-role") == "dialog"){
		if(pPopNextPage != undefined){
			$(thisPop).remove();
		} else {
			setTimeout(function(){ $(thisPop).remove()}, 150);
		}
		// Push를 통해 팝업을 바로 띄운 경우 닫기 버튼에서 메인으로 이동
		if(history.length == 1){
			location.href = "/"
		} else {
			history.back();	
		}
	} else {
		history.back();

	}
}

//파라미터 조회 - pPageID : 특정 페이지 내 파라미터 조회 시 사용
//Get 방식으로 호출되는 페이지에서 QueryString을 파싱하여 파라메터를 가져오는 함수
function mobile_comm_getQueryString(pParamName, pPageID) {// 대소문자 가림
	var _QureyObject = {};
	var queryString = "";
	if(pPageID != undefined && pPageID != "" && $("#"+pPageID).length > 0 
		&& $("#"+pPageID).attr("data-url") != undefined && $("#"+pPageID).attr("data-url").indexOf('?') > -1){
		queryString = $("#"+pPageID).attr("data-url").split('?')[1].split('&');
	} else {
		queryString = location.search.replace('?', '').split('&');
	}
	var querylength = queryString.length;
	for (var i = 0; i < querylength; i++) {
		var name = queryString[i].split('=')[0];
		var value = queryString[i].split('=')[1];
		_QureyObject[name] = value;
	}
	if (_QureyObject[pParamName] == "undefined" || _QureyObject[pParamName] == null) {
		return "undefined";
	} else {
		try {
			return _QureyObject[pParamName];
		} finally {
			_QureyObject = null;
		}
	}
}

//특정 url의 파라미터 조회 
function mobile_comm_getQueryStringForUrl(pURL, pParamName) {// 대소문자 가림
	
	var _QureyObject = {};
	
	if(pURL != null && pURL != undefined && pURL.indexOf("?") > -1) {
		var queryString = pURL.split('?')[1].split('&');
		var querylength = queryString.length;
		for (var i = 0; i < querylength; i++) {
			var name = queryString[i].split('=')[0];
			var value = queryString[i].split('=')[1];
			_QureyObject[name] = value;
		}
		if (_QureyObject[pParamName] == "undefined" || _QureyObject[pParamName] == null) {
			return "undefined";
		} else {
			try {
				return _QureyObject[pParamName];
			} finally {
				_QureyObject = null;
			}
		}
	} else {
		return "";
	}
}

function mobile_comm_toggleclass(pObj, pClass) {
	$(pObj).toggleClass(pClass);
}

//로딩중 보이기/숨기기
function mobile_comm_showload() {
	$("div.mobile_loading").show();
}
function mobile_comm_hideload() {
	$("div.mobile_loading").hide();
}

//닫기/뒤로가기 보이기/숨기기
function mobile_comm_showback() {
	if($('div[data-role="dialog"]').find('div.l_header > .btn_back, .btn_close').length > 0) {
		$('div[data-role="dialog"]').find('div.l_header > .btn_back, .btn_close').show();
	} else {
		$('div.l_header > .btn_back, .btn_close').show();
	}
}
function mobile_comm_hideback() {
	$('div.l_header > .btn_back, .btn_close').hide();
}

//본문 내 인라인 이미지 url 변경(pc도메인 절대경로 -> 상대경로)
function mobile_comm_replacebodyinlineimg(obj) {
	
	//본문 내 링크 처리 (pc용 도메인 - 모바일 도메인으로 변경 / 기타 http,https 링크-외부 브라우져 호출)
	var pcServiceDomainList = mobile_comm_getBaseConfig("PCServiceDomainList").toLowerCase();
	
	$(obj).find("img").each(function() {
		try {			
			var $this = $(this);
			var img_url = $this.attr('src');
			if(img_url != null && img_url != "") {
				if(img_url.indexOf("//") > -1){
					var imgprotocol = img_url.split("//")[0];				//인라인이미지 프로토콜
					var imgdomain = img_url.split("//")[1].split("/")[0];	//인라인이미지 도메인
					
					if (pcServiceDomainList.indexOf(imgdomain.toLowerCase()) > -1) { // PC도메인을 모바일용으로 변경
						$this.attr("src", $this.attr('src').replace(imgprotocol + '//' + imgdomain, ''));
					}
				}
			}
		} catch(e) {
			mobile_comm_log("mobile_comm_replacebodyinlineimg"+e);
		}
	});
}

//본문 내 링크 url 변경(pc도메인 -> 접속사이트도메인)
function mobile_comm_replacebodylink(obj, isIframe) {
	
	//본문 내 링크 처리 (pc용 도메인 - 모바일 도메인으로 변경 / 기타 http,https 링크-외부 브라우져 호출)
	var pcServiceDomainList = mobile_comm_getBaseConfig("PCServiceDomainList").toLowerCase();
	
	$(obj).find("a").each(function() {
		try {		
			var $this = $(this);
			if($this.attr('href') != null && $this.attr('href') != "" && $this.attr('href') != "#") {
			
				var linkprotocol = $this.attr('href').split("//")[0];				//링크 프로토콜
				var linkdomain = $this.attr('href').split("//")[1].split("/")[0];	//링크 도메인
				
				if (pcServiceDomainList.indexOf(linkdomain.toLowerCase()) > -1) { // PC도메인을 모바일용으로 변경
					$this.attr("href", window.location.protocol + "//" + window.location.host + $this.attr('href').replace(linkprotocol + '//' + linkdomain, ''));
					$this.attr("target", "_blank");
				} else if ($this.attr('href').startsWith("http")) { // 기타 사이트인 경우
					$this.attr("href", "javascript: " + ((isIframe == "Y") ? "parent." : "") + "mobile_comm_openurl('" + $this.attr('href') + "');");
					$this.attr("target", "_self");
				} else {
					// 그대로 유지
				}
			}
		} catch(e) {
			mobile_comm_log(e);
		}
	});
}

//워터마크 처리
function mobile_comm_showwatermark() {
	$('.watermarked').each(function (){
		if($(this).attr('data-watermark') != "") {
			$(this).attr('data-watermark', ($(this).attr('data-watermark') + '     ').repeat(300));
		} else {
			$(this).attr('class', '');
		}
	});
}

//썸네일 이미지 조회
function mobile_comm_getThumbSrc(bizSection, fileID){
	var returnData = "";

	if(bizSection != undefined && bizSection != "" && fileID != undefined && fileID != "" ){
		
		if (window.sessionStorage.getItem("THUMB_" + bizSection + "_" + fileID) != null) {
			returnData = window.sessionStorage.getItem("THUMB_" + bizSection + "_" + fileID);
		} else {
			$.ajax({
				url : "/covicore/mobile/comment/previewsrc/" + bizSection + "/" + fileID + ".do",
				type : "get",
				success : function(res) {
					window.sessionStorage.setItem("THUMB_" + bizSection + "_" + fileID,  "/covicore/common/photo/photo.do?img=" + res, "");
				},
				error:function(response, status, error){
					//mobile_comm_ajaxerror("/covicore/mobile/comment/previewsrc/" + bizSection + "/" + fileID + ".do", response, status, error);
				}
			});
			returnData = "/covicore/mobile/comment/preview/" + bizSection + "/" + fileID + ".do";
		}
	} else {
		if(bizSection == "Community"){
			returnData = mobile_community_noimg();
		}else{
			returnData = mobile_comm_noimg();
		}
		
	}

	return returnData;
}

//로그아웃
function mobile_comm_logout() {
	location.href = "/covicore/logout.do";
	
	//로그아웃 시 앱 호출
	try {
		if(mobile_comm_isAndroidApp()) {
			
			/*
			 * Android
			 * public void LogoutGW()
			 * */
			
			window.covimoapp.LogoutGW();
			
		} else if(mobile_comm_isiOSApp()) {
			/*
			 * window.webkit.messageHandlers.name.postMessage(messageBody)
			 * */
			
			window.webkit.messageHandlers.callbackHandler.postMessage({ type:'logoutgw'}); 
		}
	} catch (e) {mobile_comm_log(e);
	}
}

//AJAX 오류 공통처리
function mobile_comm_ajaxerror(url, res, status, error) {
	// TODO: 에러 로그처리
	
	mobile_comm_hideload();
	
	if(res.status != 0) {
		alert('ERROR-' + error + '(' + url + ')');
	}
}

//Image 오류 공통처리
function mobile_comm_imageerror(pObj, isProf) {
	$(pObj).onerror = "";
    $(pObj).attr("src", mobile_comm_noimg(isProf));
}

//NoPerson 경로 조회
function mobile_comm_noperson() {
	//프로필, 조직도 등 사람 이미지 없는 경우 noimg 경로
	return mobile_comm_noimg(true);
	
	//mobile_comm_getGlobalProperties("css.path") > /HtmlSite/smarts4j_n
}

function mobile_comm_nogroup() {
	//프로필, 조직도 등 사람 이미지 없는 경우 noimg 경로(그룹)
	return mobile_comm_noimg(false);
}

//NoImage 경로 조회
function mobile_comm_noimg(isProf) {
	
	//섬네일 등 이미지 없는 경우 noimg 경로
//	image.onerror = "";
    if (isProf == true){
	    return "/covicore/resources/images/no_profile.png";
    }
    else{
	    return  "/covicore/resources/images/no_image.jpg";
    }    
    //return mobile_comm_replaceAll(mobile_comm_getBaseConfig('BackStorage'), '{0}', mobile_comm_getSession('DN_Code'));
	//return mobile_comm_getGlobalProperties("css.path") + '/mobile/resources/images/noImage.jpg';
}

//이미지 경로 조회
function mobile_comm_getimg(imgPath) {
	return "/covicore/common/photo/photo.do?img=" + encodeURIComponent(imgPath);
}

function mobile_comm_getImgById(bizSection, imgId) { // bizSection 불필요
	return "/covicore/common/view/"+imgId+".do";
}

//이미지 경로 조회
//function mobile_comm_getImgFilePath(serviceType, filePath, savedName) {
//	return mobile_comm_getimg(mobile_comm_getBaseConfig('BackStoragePath').replace("{0}", mobile_comm_getSession("DN_Code")) +  serviceType +'/' + filePath + savedName);
//}

//문자열내의 특정문자들을 모두 replace 해주는 함수
function mobile_comm_replaceAll(entry, orginVal, newVal) {// 문자열, 원래문자, 바뀔문자
	var ret = entry;
	if(orginVal != newVal) {
		var pos = 0;
		while (ret.indexOf(orginVal) > -1) {
			pos = ret.indexOf(orginVal);
			ret = "" + (ret.substring(0, pos) + newVal + ret.substring((pos + orginVal.length), ret.length));
		}
	}
	return ret;
}

//입력값 앞에 '0'을 붙여서 입력받는 자리수의 문자열을 반환한다.
function mobile_comm_AddFrontZero(inValue, digits) {
    var result = "";
    var cnt;
    inValue = inValue.toString();
    cnt = inValue.length;

    if (cnt < digits) {
        for (var i = 0; i < digits - cnt; i++)
            result += "0";
    }
    result += inValue
    return result;
}

// 천단위에 컴마 찍기
function mobile_comm_addComma(objValue) {
    var objTempDot = "";
    var objTemp = "";
    var objTempValue = '';
    var objFlag = '';
    var objLength;
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
    objLength = objTemp.length;
    if (objLength > 3) {
        var tempV1 = objTemp.substring(0, objLength % 3);
        var tempV2 = objTemp.substring(objLength % 3, objLength);

        if (tempV1.length != 0) {
            tempV1 += ',';
        }
        objTempValue += tempV1;
        
        var tempV2length = tempV2.length;
        for (var i = 0; i < tempV2length; i++) {
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

//SSO 쿠키 가져오기
function mobile_comm_getSSOCookie(cname){
	var name = cname + "=";
	var ca = document.cookie.split(';');
	var cookielength = ca.length;
	for(var i = 0; i < cookielength; i++) {
	    var c = ca[i];
	    while (c.charAt(0) == ' ') {
	        c = c.substring(1);
	    }
	    if (c.indexOf(name) == 0) {
	        return c.substring(name.length, c.length);
	    }
	}
	return "";
}




/**
 * 
 * 좌측메뉴(pc-상단메뉴) / 상단메뉴(pc-좌측메뉴) / 웹 하단 바
 * 
 */

//[좌측메뉴] 그리기
function mobile_comm_menu(data) {
	
    var menuHtml = "";  
    var bizHtml = "";
    $(data).each(function (i, menu){
    	if(menu.MobileURL != undefined && menu.MobileURL != "" && menu.IsUse == "Y") {
    		if(menu.BizSection != undefined && menu.BizSection != "") {
    			bizHtml = " biz='" + menu.BizSection + "'";
    			bizHtml += " menuid='" + menu.Reserved1 + "'";
    		} else {
    			bizHtml = "";
    		}

    		var MobileURL = menu.MobileURL;
    		
    		menuHtml += "<li" + bizHtml + ">";
    		if(menu.MobileTarget.toUpperCase() == "NEW" && menu.MobileURL.toLowerCase().startsWith("http") && menu.Reserved1!="token") {
				menuHtml += "    <a href=\"javascript: mobile_comm_openurl('" + MobileURL + "');\">";
    			menuHtml += "		<i class='" + mobile_comm_getmenuclass(menu.BizSection, menu.IconClass) + "'></i>";
	    		menuHtml += "		<span class='mtit'>" + menu.DisplayName + "</span>";
	    		menuHtml += "		<span class='mcnt' style='display: none;'></span>";
	    		menuHtml += "    </a>";
	        	menuHtml += "</li>";
			} else if(mobile_comm_getBaseConfig("isUseMail") == 'Y' && mobile_comm_getBaseConfig("isUseExchMail") == 'Y' && menu.Reserved1=="token") {
				menuHtml += "    <a href=\"javascript: mobile_comm_mailopen('" + MobileURL + "');\">";
    			menuHtml += "		<i class='" + mobile_comm_getmenuclass('MAIL', menu.IconClass) + "'></i>";
	    		menuHtml += "		<span class='mtit'>" + menu.DisplayName + "</span>";
	    		menuHtml += "		<span class='mcnt' id='mpMailcnt' style='display: none;'></span>";
	    		menuHtml += "    </a>";
	        	menuHtml += "</li>";
			} else {
				menuHtml += "    <a href=\"javascript: mobile_comm_go('" + MobileURL + "');\">";
    			menuHtml += "		<i class='" + mobile_comm_getmenuclass(menu.BizSection, menu.IconClass) + "'></i>";
	    		menuHtml += "		<span class='mtit'>" + menu.DisplayName + "</span>";
	    		menuHtml += "		<span class='mcnt' style='display: none;'></span>";
	    		menuHtml += "    </a>";
	        	menuHtml += "</li>";
			}
        	// menuHtml += menu.BizSection + ", " + menu.DisplayName;// + ", " +
			// menu.MobileURL;
        	// menuHtml += menu.BizSection + ", " + menu.DisplayName;// + ", " +
			// menu.MobileURL;
    	}
    	
    	if(menu.Sub.length > 0) {
    		$(menu.Sub).each(function (i, submenu){
    	    	if(submenu.MobileURL != undefined && submenu.MobileURL != "" && submenu.IsUse == "Y") {
    	    		if(submenu.BizSection != undefined && submenu.BizSection != "") {
    	    			bizHtml = " biz='" + submenu.BizSection + "'";
    	    		} else {
    	    			bizHtml = "";
    	    		}
    	    		menuHtml += "<li" + bizHtml + ">";
            		if(submenu.MobileTarget.toUpperCase() == "NEW" && submenu.MobileURL.toLowerCase().startsWith("http")) {
						menuHtml += "    <a href=\"javascript: mobile_comm_openurl('" + submenu.MobileURL + "');\">";
					} else {
						menuHtml += "    <a href=\"javascript: mobile_comm_go('" + submenu.MobileURL + "');\">";
					}
            		menuHtml += "		<i class='" + mobile_comm_getmenuclass((submenu.BizSection == "" ? submenu.MobileURL.split("/")[3] : submenu.BizSection), submenu.IconClass) + "'></i>";
            		menuHtml += "		<span class='mtit'>" + submenu.DisplayName + "</span>";
            		menuHtml += "		<span class='mcnt' style='display: none;'></span>";
            		menuHtml += "	</a>";
                	menuHtml += "</li>";
        	    	// menuHtml += submenu.BizSection + ", " +
					// submenu.DisplayName;// + ", " + submenu.MobileURL;
    	    	}
    	    });
    	}
    });
    
    return menuHtml;
	
}

//[좌측메뉴] 메뉴 class 조회
function mobile_comm_getmenuclass(bizsection, iconclass) {
	var menu_class = "";
	
	if(bizsection != null && bizsection != undefined){
		switch(bizsection.toUpperCase()) {
		case "ORG":
			menu_class = "ico_all_menu12 img_n12";	// 조직도
			break;
		case "MAIL":
			menu_class = "ico_all_menu03 img_n03";	// 메일
			break;
		case "APPROVAL":
			menu_class = "ico_all_menu01 img_n01";	// 전자결재
			break;
		case "SCHEDULE":
			menu_class = "ico_all_menu02 img_n02";	// 일정관리
			break;
		case "DOC":
			menu_class = "ico_all_menu04 img_n04";	// 문서관리
			break;
		case "TSQUARE":
			menu_class = "ico_all_menu10 img_n10";	// 타임스퀘어(BizSection 없음)
			break;
		case "SURVEY":
			menu_class = "ico_all_menu06 img_n06";	// 설문
			break;
		case "COMMUNITY":
			menu_class = "ico_all_menu07 img_n07";	// 커뮤니티
			break;
		case "BOARD":
			menu_class = "ico_all_menu09 img_n09";	// 게시판
			break;
		case "RESOURCE":
			menu_class = "ico_all_menu05 img_n05";	// 자원예약
			break;
		case "TASK":
			menu_class = "ico_all_menu11 img_n11";	// 업무관리
			break;
		case "BIZCARD":
			menu_class = "ico_all_menu08 img_n08";	// 인명관리(BizSection 없음)
			break;
		case "VACATION":
			menu_class = "ico_all_menu13 img_n13";	// 휴가관리
			break;
		case "ATTEND":
		case "ATTENDANCE":
			menu_class = "ico_all_menu14 img_n14";	// 근태관리
			break;
		case "ACCOUNT":
			menu_class = "ico_all_menu01 img_n01";	// e-Accounting
			break;
		case "WEBHARD":
			menu_class = "ico_all_menu15 img_n15";	// 웹하드
			break;
		case "WORKREPORT":
			menu_class = "ico_all_menu17 img_n17";	// 업무보고
			break;
		case "COLLAB":
			menu_class = "ico_all_menu21 img_n21";	// 협업스페이스
			break;
		case "CRM":
			menu_class = "ico_all_menu22 img_n22";	// crm
			break;
		case "MOBILE":
			if(iconclass != null && iconclass != undefined){
				menu_class = "ico_all_menu" + iconclass + " img_n" + iconclass;	//기타-bizsection이 Mobile인 경우 IconClass 값으로 클래스 셋팅
			}
			break;
		}
	}	
	
	return menu_class;
}

//[좌측메뉴] 사용자 정보 및 겸직정보 그리기 
function mobile_comm_LeftLoad(){
	$("#user_profile_photo").css("background-image", "url('" + mobile_comm_getimg(mobile_comm_getSession("PhotoPath")) + "'), url('" + mobile_comm_noperson() + "')");
	$("#user_profile_name").html(mobile_comm_getSession("USERNAME"));
	$("#user_profile_dept_position").html("<span>" + mobile_comm_getSession("DEPTNAME") + "</span>" + mobile_comm_getSession("UR_JobTitleName"));
	mobile_portal_createAddJobSelect();
	var useMobileTheme = mobile_comm_getBaseConfig("useMobileTheme");
	if(useMobileTheme == "Y"){
		var urTheme = mobile_comm_getSession("UR_ThemeType"); 			
		$(".topH_colorSbox").show();
		$("#user_theme_color").attr("class",$("#user_theme_"+urTheme).attr("class"));
	}
	
	if(!mobile_comm_isAndroidApp() && !mobile_comm_isiOSApp()) {
		if(mobile_comm_getBaseConfig("MobileWebBottomMenuUse") != "N" && window.self == window.top) {
			$("#btnBottomMenuLayout").show();	
		}
	}
}

//[좌측메뉴] 열기
function mobile_comm_openleftmenu() {
	var odim = $('.bg_dim');
	if(odim.length >0)
		$(odim).hide();
	$('#mobile_content').hide();
	$('#mobile_left').show();
	
	// MP/CP통합앱-좌측메뉴 open상태 전달
    try {
    	
    	if(mobile_comm_isAndroidApp()) {
    		window.covimoapp.SetPullToRefresh(false);
    		mobile_comm_callappstopvoicerecognition();
    	}
    	if(mobile_comm_isiOSApp()) {
    		mobile_comm_callappstopvoicerecognition();
    	}
    	
    	window.covimoapp.SetOpenLeftMenu(true);
    	
    } catch (e) {
        mobile_comm_log('SetOpenLeftMenu 없음');
    }
    
	// 타일조회에서도 카운트 표시되도로 수정
	if($("#ul_leftmenu").html() != "")
		mobile_home_setCntInit("ul_leftmenu");
	// mobile_portal_setInteratedCntInit();
}

//[좌측메뉴] 닫기
function mobile_comm_closeleftmenu() {
	$('#mobile_left').hide();
	$('#mobile_content').show();
	
	// MP/CP통합앱-좌측메뉴 open상태 전달
    try {
    	window.covimoapp.SetOpenLeftMenu(false);
    } catch (e) {
        mobile_comm_log('SetOpenLeftMenu 없음');
    }
}

//[좌측메뉴] 열기 또는 닫기
function mobile_comm_openorcloseleftmenu() {
	if($('#mobile_left').css('display') == 'none') {
		mobile_comm_openleftmenu();
	} else {
		mobile_comm_closeleftmenu();
	}
}


//[상단메뉴] 그리기
function mobile_comm_getTopMenuHtml(datalist) {	
	var sHtml = "";
	var nSubLength = 0;
	$(datalist).each(function (i, data){
		
		nSubLength = data.Sub.length;
		
		sHtml += "<li>";
		sHtml += "    <div class=\"h_tree_menu\">";
		if(nSubLength > 0) {
			sHtml += "    <ul class=\"h_tree_menu_list\">";
			sHtml += "        <li>";
			sHtml += "            <a href=\"#\" class=\"t_link not_tree\">";// TODO:링크 처리
			sHtml += "                <span class=\"t_ico_close\"></span><span class=\"t_ico_app\"></span>";// TODO: t_ico_app 클래스 처리
			sHtml += "                " + data.DisplayName;
			sHtml += "            </a>";
			sHtml += "        </li>";
			sHtml += "    </ul>";
		} else {
			sHtml += "    <a href=\"#\" class=\"t_link\">";// TODO: 링크 처리
			sHtml += "        <span class=\"t_ico_app\"></span>";// TODO: 클래스 처리
			sHtml += "        " + data.DisplayName;
			sHtml += "    </a>";
		}
		sHtml += "    </div>";
		sHtml += "</li>";
		
		if(nSubLength > 0) {
			sHtml += "<ul class=\"sub_list\">";
			$(data.Sub).each(function (j, subdata){
				sHtml += "    <li>";
				sHtml += "        <a href=\"#\" class=\"t_link\">";// TODO: 링크 처리
				sHtml += "            <span class=\"t_ico_board\"></span>";
				sHtml += "            " + subdata.DisplayName;
				sHtml += "        </a>";
				sHtml += "    </li>";
			});
			sHtml += "</ul>";
		}
	});
	
	return sHtml;
}

//[상단메뉴] 열고 닫기
function mobile_comm_TopMenuClick(objid,isColse) {
	var odim = $('.left_bg_dim');
	var pobj = $('#' + objid).parent();
	var ppobj = $(pobj).parent();
	if (!$(ppobj).hasClass('show') && isColse != true) {
		$(ppobj).addClass('show');
		$(pobj).show();		
		if(odim.length > 0)
			$(odim).show();
//		try {
//			if(mobile_comm_isAndroidApp()) {
//				window.covimoapp.SetPullToRefresh(false);
//			}
//		} catch(e) {}		
	} else {	
		$(ppobj).removeClass('show');
		$(pobj).hide();
		if(odim.length > 0)
			$(odim).hide();
//		try {
//			if(mobile_comm_isAndroidApp()) {
//				window.covimoapp.SetPullToRefresh(true);
//			}
//		} catch(e) {}
	}
}


//[상단메뉴] 메뉴명 셋팅
function mobile_comm_setTopMenuName(objid, name) {
	$('#' + objid).html(name);
}

//[웹하단바] 하단바 열고 닫기
function mobile_comm_BottomMenuLayout(pObj){
	if($(pObj).hasClass("Bmenu_open")){
		$("#btnBottomMenu").show();
		$(pObj).removeClass("Bmenu_open").addClass("Bmenu_close");
	} else {
		$("#btnBottomMenu").hide();
		$(pObj).removeClass("Bmenu_close").addClass("Bmenu_open");
	}	
}





/**
 * 
 * 리스트 자동더보기 관련 스크롤 처리
 * 
 */


// 스크롤 더보기 이벤트
function mobile_comm_scrollEvent(e){	
	var l_ActiveID = $.mobile.activePage.attr( "id" );
	try{
		if($("#mobile_content").css("display") != "none" && $("#"+l_ActiveID).find(".btn_list_more").css("display") != "none" && $("#"+l_ActiveID).find(".menu_link.gnb.show").length == 0) {				
			if(typeof window["mobile_"+l_ActiveID+"_ListAddMore"] == "function") {
				var extHeader = l_ActiveID =="webhard_list_page" ? $("#webhard_list_loc").outerHeight() : 0;
				var screenHeight = $.mobile.getScreenHeight(),
				contentHeight = $("#"+l_ActiveID).find("div.cont_wrap").outerHeight(),		
				header = $("#"+l_ActiveID).find("header .ui-header").outerHeight() - 1,	        
		        scrolled = $(window).scrollTop(),
		        scrollEnd = contentHeight - screenHeight + header -extHeader - 10;
		    	if (scrolled >= scrollEnd) {
		    		window["mobile_"+l_ActiveID+"_ListAddMore"](); 
		    	}
		    }
		}
	}catch(ex){mobile_comm_log(ex)}
}

// Disable touch move
function mobile_comm_disablescroll() {
    $(document).on('touchmove', mobile_comm_preventdefault);
}

// Enable touch move
function mobile_comm_enablescroll() {
    $(document).unbind('touchmove', mobile_comm_preventdefault)
}

//prevent default
function mobile_comm_preventdefault(e) {
    e.preventDefault();
}



/*
 * !
 * 
 * 검색 공통처리
 * 
 */

function mobile_comm_opensearch(){
	var osearch = $('.ly_search');
	if(osearch)
		$(osearch).show();
}

function mobile_comm_closesearch(){
	var osearch = $('.ly_search');
	if(osearch)
		$(osearch).hide();	
}

function mobile_comm_cleansearch(){	
	$("[id='mobile_search_input']").val('');
}

function mobile_comm_searchinputui(id){
	if ($('#' + id).val().length > 0) {
        $("#VoiceListener_" + id).remove();
        $('#' + id + '_btn').show();
    } else if ($('#' + id).val().length == 0) {
    	$('#' + id + '_btn').hide();

        //음성인식 컨트롤  바인딩
    	if(mobile_comm_isMobileApp() && mobile_comm_getSession('lang') == "ko" && mobile_comm_getBaseConfig("IsUseVoiceRecognition") == "Y") {
    		// 보이스 인풋 컨트롤 바인딩
    		setTimeout("mobile_comm_VoiceInputCtrlBind()", 100);
    	}
    }
}


/*
 * !
 * 
 * 조직도 공통처리
 * 
 */

// 조직도 열기
function mobile_comm_openOrg(pMode) {
	var url = "/covicore/mobile/org/list.do";
	url += "?mode=" + pMode;
	
	mobile_comm_go(url, 'Y');
}




/*
 * !
 * 
 * 첨부 공통처리
 * 
 */

//첨부 객체
var mobile_comm_uploadfilesObj = {
	fileInfos : [], // 파일 정보
	files : []		// multipart file
};

//전자결재용 첨부 객체
var mobile_obj_filelist = [];

//업로드

//파일업로드 html 생성
function mobile_comm_uploadhtml(fileinfo){
	var useWebhard = mobile_comm_getBaseConfig("isUseWebhard");
	var useWebhardAttach = mobile_comm_getBaseConfig("useWebhardAttach");	
	
	mobile_obj_filelist = [];	//첨부 객체 초기화
	
	var $attach = $('div[covi-mo-attachupload]').filter(":last");//[class*=-active]
	
	var system = $attach.attr('system');
	var accept = "";
	var controlID = "";
	var uploaderID = "";
	
	if($attach.attr('accept') != undefined) {
		accept = $attach.attr('accept');
	}
	accept = mobile_comm_uploadaccept(accept);
	
	if($attach.attr('controlID') != undefined) {
		controlID = $attach.attr('controlID');
		uploaderID = "_" + controlID;
	}
	
	if($attach.html() != "")
		return ;
	
	//첨부파일 객체 초기화
	mobile_comm_uploadfilesObj = {
		fileInfos : [],
		files : []
	};
	
	var sHtml = "";
	if(system != "Mail"){
		sHtml += "<div class=\"files_wrap\">";
		sHtml += "    <div class=\"add_files_area\">";
		sHtml += "      <p id='pAttachInit' style='margin-left:-5px;' class=\"tx\">" + mobile_comm_getDic("lbl_attach") + "</p>";
		sHtml += "		<a id='pAttachAdd'  style='margin-left:-20px;display:none;' href=\"javascript:mobile_comm_files_areaToggle();\" class=\"Mail_tx\">";		
		sHtml += "			<span class=\"Mail_text\">"+mobile_comm_getDic("lbl_attach")+"</span>";
		sHtml += "			<span class=\"Mail_tx_num\" id=\"sAttachWrite_txNum\">0</span>";
		sHtml += "			<span class=\"Mail_tx_capacity\" id=\"sAttachWrite_txCapacity\">(0KB)</span>";
		sHtml += "			<span class=\"Mail_tx_btn open\" id=\"sAttachWrite_txBtn\">버튼</span>";
		sHtml += "		</a>";
		if("Y" == useWebhard && "Y" == useWebhardAttach)
			sHtml += "  <a onclick=\"moobile_comm_webhardupload();return false;\" class=\"btn_webhard_n\" style=\"right:45px;\"></a>";
		sHtml += "      <a onclick=\"$('#mobile_attach_input" + uploaderID + "').click();\" class=\"btn_add_n\"></a>";	// 추가
		sHtml += "      <input type=\"file\" id=\"mobile_attach_input" + uploaderID + "\" onchange=\"mobile_comm_changeupload(this, '" + system + "');\" multiple " + accept + " style=\"display: none;\"/>";
		sHtml += "  </div>";
		sHtml += "  <ul id=\"mobile_attach_uplodedfiles" + uploaderID + "\" style='display:none;'></ul>";
		sHtml += "</div>";
	}else{				
		sHtml += "<div id=\"mail_mailWriteFileArea\" class=\"files_wrap\">";
		sHtml += "	<div class=\"add_files_area\">";
		sHtml += "      <p id='pAttachInit' style='margin-left:-5px;' class=\"tx\">" + mobile_comm_getDic("lbl_attach") + "</p>";
		sHtml += "		<a id='pAttachAdd'  style='margin-left:-20px;display:none;' href=\"javascript:mobile_mail_files_areaToggle();\" class=\"Mail_tx\">";		
		sHtml += "			<span class=\"Mail_text\">"+mobile_comm_getDic("lbl_attach")+"</span>";
		sHtml += "			<span class=\"Mail_tx_num\" id=\"mail_mailWrite_txNum\">0</span>";
		sHtml += "			<span class=\"Mail_tx_capacity\" id=\"mail_mailWrite_txCapacity\">(0KB)</span>";
		sHtml += "			<span class=\"Mail_tx_btn open\" id=\"mail_mailWrite_txBtn\">버튼</span>";
		sHtml += "		</a>";				
		if("Y" == useWebhard && "Y" == useWebhardAttach)
			sHtml += "	<a onclick=\"moobile_comm_webhardupload('Mail');return false;\" class=\"btn_webhard_n\" style=\"right:45px;\"></a>";		
		sHtml += "		<a onclick=\"$('#mobile_attach_input').click();\" class=\"btn_add_n ui-link\"></a>";				
		sHtml += "		<input type=\"file\" onchange=\"mobile_mail_inputFile(this);return false;\" id=\"mobile_attach_input\" multiple style=\"display:none;\">";					
		sHtml += "	</div>";
		sHtml += "	<ul id=\"mobile_attach_uplodedfiles\" style='display:none;'></ul>";
		sHtml += "</div>";		
	}
	
	$attach.html(sHtml).trigger("create");
	
	if(fileinfo != undefined){
		var setFileObjID;
		
		if(system == "Account" && controlID != "") {
			setFileObjID = "account_write_AttachInfo" + uploaderID;
		}
		else {
			setFileObjID = "mobile_attach_uplodedfiles" + uploaderID;
		}
		
		mobile_comm_setfile(setFileObjID, fileinfo, system, controlID);
		
		if(system == "Approval") {
			readfiles(fileinfo);
			SetFileInfo(fileinfo);
		}
		else if(system != "Mail") {
			// 첨부파일 용량정보 표시
			mobile_comm_writeSetFilesInfo();	
		}
	}	
}

//input accept 셋팅
function mobile_comm_uploadaccept(pAccept) {	
	var sRet = pAccept;
	
	switch(pAccept.toUpperCase()) {
		case "":
			break;
		case "IMAGE":
			sRet = "accept=\"image/*\"";
			break;
	}
	
	return sRet;
}

//파일 선택 후 - 파일 업로드 시작
function mobile_comm_changeupload(ele, system) {
	var $ele = $(ele);
	var $files = $ele.prop('files');
	var fileslength = $files.length;
	var tempFileInfos = {  							//임시 파일 정보
		fileInfos : [], //파일 정보
		files : []		//multipart file
	};
	var controlID = "";
	
	if($ele.closest("div[covi-mo-attachupload]").attr("controlID") != undefined) {
		controlID = $ele.closest("div[covi-mo-attachupload]").attr("controlID");
	}
	
	//업로드한 파일 정보($files) 기반으로 임시 파일 정보(tempFileInfos) 구성
	for (var i = 0; i < fileslength; i++) {
		//TODO: validation체크
		var fileObj = new Object();
		fileObj.FileName = encodeURIComponent($files[i].name);
		fileObj.Size = $files[i].size;
		fileObj.FileID = '';
		fileObj.FilePath = '';
		fileObj.SavedName = '';
		fileObj.FileType = 'normal';
		
		if(controlID != "") {
			fileObj.ControlID = controlID;
		}
		
		tempFileInfos.files.push($files[i]);
		tempFileInfos.fileInfos.push(fileObj);	
	}	
	
	if(system != 'Approval') {
		// 로딩 시작
		mobile_comm_showload();
		
		var sUrl = "/covicore/mobile/comment/uploadToFront.do";
		var fileData = new FormData();				//파일 정보 Form(ajax parameter용)
		var tempFileslength = tempFileInfos.files.length;
		//임시 파일 정보(tempFileInfos) 기반으로 파일 정보 Form(fileData) 구성
		fileData.append("fileInfos", JSON.stringify(tempFileInfos.fileInfos));
		if(system == 'Account'){
			sUrl = "/account/control/uploadToFront.do";
			fileData.append("servicePath", "");
		}else{
			fileData.append("servicePath", mobile_comm_replaceAll(mobile_comm_getBaseConfig('ProfileImagePath'), '{0}', mobile_comm_getSession('DN_Code')));
		}
		for (var j = 0; j < tempFileslength; j++) {
			if (typeof tempFileInfos.files[j] == 'object') {
				fileData.append("files", tempFileInfos.files[j]);
			}
		}	
		
		//프론트에 파일 업로드
		$.ajax({
			url: sUrl,
			data: fileData,
			type:"post",
			dataType : 'json',
			async: true,
			processData : false,
			contentType : false,
			success:function (res) {
				if (res.status == "SUCCESS") {
					$files =  res.list;
					mobile_comm_UploadCallBack($files, tempFileInfos, system, controlID);
				} else {
					$files = {};
					alert(res.message);
				}
				// 로딩 Hide
				setTimeout("mobile_comm_hideload()", 300);
			},
			error:function(response, status, error){
				// 로딩 Hide
				setTimeout("mobile_comm_hideload()", 300);
				mobile_comm_ajaxerror(sUrl, response, status, error);
			}			
		});
	}
	else {
		mobile_comm_UploadCallBack($files, tempFileInfos, system, controlID);
	}
}

//파일 업로드 후
function mobile_comm_UploadCallBack(pFiles, tempFileInfos, system, controlID){
	var $files = pFiles
	var fileslength = $files.length;
	var uploaderID = "";
	var i;
	
	if(controlID != "") {
		uploaderID = "_" + controlID;
	}
	
	for (i = 0; i < fileslength; i++) {
		$files[i].FilePath = '';
		if(system == 'Board' && $files[i].Size > _mobile_board_write.Config.LimitFileSize){
			alert(mobile_comm_getDic("msg_checkFileSize").replace("{0}",mobile_comm_convertFileSize(_mobile_board_write.Config.LimitFileSize)));
			tempFileInfos.files.splice(i,1);
			tempFileInfos.fileInfos.splice(i,1);
			$files.splice(i,1);
			fileslength--;
		}
	}

	//mobile_comm_uploadfilesObj에 파일 정보 추가
	if(system == 'Account') {
		mobile_comm_uploadfilesObj.files = $.merge( mobile_comm_uploadfilesObj.files, tempFileInfos.files);
		mobile_comm_uploadfilesObj.fileInfos = $.merge( mobile_comm_uploadfilesObj.fileInfos,  tempFileInfos.fileInfos);
	}else{
		mobile_comm_uploadfilesObj.files = $.merge( mobile_comm_uploadfilesObj.files, tempFileInfos.files);
		mobile_comm_uploadfilesObj.fileInfos = $.merge( mobile_comm_uploadfilesObj.fileInfos,  $files);
	}
	
	var totalFileSize =0;
	var allfileslength = mobile_comm_uploadfilesObj.files.length;
	var sendmessage = false;
	if(system == 'Board'){
		for(var j = 0; j < allfileslength; j++) {
			totalFileSize = totalFileSize + (mobile_comm_uploadfilesObj.files[j].size == undefined ? parseInt(mobile_comm_uploadfilesObj.files[j].Size) : mobile_comm_uploadfilesObj.files[j].size);
			if(totalFileSize > _mobile_board_write.Config.TotalFileSize){
				if(sendmessage == false){
					alert(mobile_comm_getDic("msg_checkTotalFileSize").replace("{0}",mobile_comm_convertFileSize(_mobile_board_write.Config.TotalFileSize)));
					sendmessage = true;
				}
				mobile_comm_uploadfilesObj.files.splice(j,1);
				mobile_comm_uploadfilesObj.fileInfos.splice(j,1);
				allfileslength--;
				fileslength--;
				j--;
			}
		}	
	}
	
	var sFileHtml = "";
	
	//추가된 파일 그리기
	for (i = 0; i < fileslength; i++) {	
		if(system == "Approval") {
			sFileHtml += "<li name='sAttachWrite_liFile' data-filename='" + $files[i].name + "' data-filesize='" + $files[i].size + "' data-savedname='' value='" +'_0' + ':' + $files[i].name + ':NEW::' + 'normal' + "'>";
			sFileHtml += "    <a class=\"add_files\">";
			sFileHtml += "        <span class=\"ico_file " + mobile_comm_getFileExtension($files[i].name) + "\"></span>";
			sFileHtml += "        <p class=\"tit\"><span class='file_name'>" + $files[i].name +"</span>";
			sFileHtml += "        	<span class=\"file_size\">" + mobile_comm_convertFileSize($files[i].size) + "</span>";
			sFileHtml += " 		  </p>";
			sFileHtml += "		  <input type='hidden' name='hiAttachWrite_fileSize' value = '" + $files[i].size + "'>";
			sFileHtml += "    </a>";
			sFileHtml += "    <a onclick=\"mobile_comm_delFile(this);\" class='add_del ui-link'></a>"
			sFileHtml += "</li>";
		} else if(system == "Account" && controlID != "") {
			sFileHtml += "<span name='sAttachWrite_liFile' data-filename='" + $files[i].FileName.replace(/\'/gi, "&#39;") + "' data-filesize='" + $files[i].Size + "' data-savedname='" + $files[i].SavedName + "' data-frontaddpath='" + $files[i].FrontAddPath + "' data-controlid='" + controlID + "'>";
			sFileHtml += "	<p class='detail_file'>" + $files[i].FileName + "<a onclick='mobile_comm_delFile(this);' class='nea_del ui-link'></a></p>";
			sFileHtml += "		  <input type='hidden' name='hiAttachWrite_fileSize' value = '" + $files[i].Size + "'>";
			sFileHtml += "</span>";
		} else {
			sFileHtml += "<li name='sAttachWrite_liFile' data-filename='" + $files[i].FileName + "' data-filesize='" + $files[i].Size + "' data-savedname='" + $files[i].SavedName + "'>";
			sFileHtml += "    <a class=\"add_files\">";
			sFileHtml += "        <span class=\"ico_file " + mobile_comm_getFileExtension($files[i].FileName) + "\"></span>";
			sFileHtml += "        <p class=\"tit\"><span class='file_name'>" + $files[i].FileName +"</span>";
			sFileHtml += "        	<span class=\"file_size\">" + mobile_comm_convertFileSize($files[i].Size) + "</span>";
			sFileHtml += " 		  </p>";
			sFileHtml += "		  <input type='hidden' name='hiAttachWrite_fileSize' value = '" + $files[i].Size + "'>";
			sFileHtml += "    </a>";
			sFileHtml += "    <a onclick=\"mobile_comm_delFile(this);\" class='add_del ui-link'></a>"
			sFileHtml += "</li>";
		}
	}

	if(system == "Account" && controlID != "") {
		$('#account_write_AttachInfo' + uploaderID + '').append(sFileHtml);
	}
	else {
		$('#mobile_attach_uplodedfiles' + uploaderID + '').show();
		$('#mobile_attach_uplodedfiles' + uploaderID + '').append(sFileHtml);
	}
		
	// 첨부파일 용량등 표시
	mobile_comm_writeSetFilesInfo();
	
	//전자결재 첨부파일 업로드 추가
	if(typeof(readfiles) != "undefined") { 
		var aObjFiles = [];
		var aObjFileListlength = mobile_obj_filelist.length;
		
		if (mobile_obj_filelist.length == 0) {
			readfiles(mobile_comm_uploadfilesObj.files); //CommonControls.js 내 함수
			SetFileInfo(mobile_comm_uploadfilesObj.files);
		} else {
			for (i = 0; i < fileslength; i++) {
				var bCheck = false;
				for (var j = 0; j < aObjFileListlength; j++) {
					if (tempFileInfos.files[i].name == mobile_obj_filelist[j].name) { // 중복됨
						bCheck = true;
						alert(mobile_comm_getDic("msg_AlreadyAddedFile"));
						break;
					}
				}
				if (!bCheck) {
					aObjFiles.push(tempFileInfos.files[i]);
				}
			}
			readfiles(aObjFiles);
			SetFileInfo(aObjFiles);
		}
	}
}

//첨부목록 접기/펼치기
function mobile_comm_files_areaToggle(){
	var txBtn = $('#sAttachWrite_txBtn');
	txBtn.toggleClass("close");
	if(txBtn.hasClass("close")){
		$('#mobile_attach_uplodedfiles').hide();
	}else{
		$('#mobile_attach_uplodedfiles').show();
	}
}

//웹하드 파일 업로드 팝업 호출
function moobile_comm_webhardupload(pType){
	if(pType == undefined || pType == "")
		pType = "common";
	var sUrl = "/webhard/mobile/webhard/list.do";
	var pCallback = "mobile_comm_changewebhardupload();";
	if(pType == "Mail")
		pCallback = "mobile_mail_changewebhardupload();";	
	window.sessionStorage["webhardopentype"] = pType;	
	window.sessionStorage["callback"] = pCallback;
	
	mobile_comm_go(sUrl, 'Y');
}

//웹하드 파일 업로드 후
function mobile_comm_changewebhardupload(pFileinfo){
	var fileinfo = (pFileinfo == undefined) ? window.sessionStorage["webhardfileinfo"] : pFileinfo;	
	fileinfo = (fileinfo == "") ? "[]" : fileinfo;
	var $files = JSON.parse(fileinfo);
	var fileslength = $files.length;
	var i;
	
	for (i = 0; i < fileslength; i++) {
		$files[i].FilePath = '';
	}

	// mobile_comm_uploadfilesObj에 파일 정보 추가
	mobile_comm_uploadfilesObj.files = $.merge( mobile_comm_uploadfilesObj.files, $files);
	mobile_comm_uploadfilesObj.fileInfos = $.merge( mobile_comm_uploadfilesObj.fileInfos, $files);	
	
	var sFileHtml = "";
	var system = $('#mobile_attach_uplodedfiles').closest("div[covi-mo-attachupload]").attr("System");
	
	// 추가된 파일 그리기
	for (i = 0; i < fileslength; i++) {	
		if(system != "Approval") {
			sFileHtml += "<li name='sAttachWrite_liFile' data-filename='" + $files[i].FileName + "' data-filesize='" + $files[i].Size + "' data-savedname='" + $files[i].SavedName + "'>";
			sFileHtml += "    <a class=\"add_files\">";
			sFileHtml += "        <span class=\"ico_file " + mobile_comm_getFileExtension($files[i].FileName) + "\"></span>";
			sFileHtml += "        <p class=\"tit\"><span class=\"file_name\">" + $files[i].FileName+"</span>";
			sFileHtml += "        	<span class=\"file_size\">" + mobile_comm_convertFileSize($files[i].Size) + "</span>";
			sFileHtml += "        </p>";
			sFileHtml += "		  <input type='hidden' name='hiAttachWrite_fileSize' value = '" + $files[i].Size + "'>";
			sFileHtml += "    </a>";
			sFileHtml += "    <a onclick=\"mobile_comm_delFile(this);\" class='add_del ui-link'></a>"
			sFileHtml += "</li>";
		} else {
			sFileHtml += "<li name='sAttachWrite_liFile' data-filename='" + $files[i].FileName + "' data-filesize='" + $files[i].Size + "' data-savedname='' value='" +'_0' + ':' + $files[i].FileName + ':NEW:' + $files[i].SavedName + ':' + 'webhard' + "'>";
			sFileHtml += "    <a class=\"add_files\">";
			sFileHtml += "        <span class=\"ico_file " + mobile_comm_getFileExtension($files[i].FileName) + "\"></span>";
			sFileHtml += "        <p class=\"tit\"><span class='file_name'>" + $files[i].FileName +"</span>";
			sFileHtml += "        	<span class=\"file_size\">" + mobile_comm_convertFileSize($files[i].Size) + "</span>";
			sFileHtml += " 		  </p>";
			sFileHtml += "		  <input type='hidden' name='hiAttachWrite_fileSize' value = '" + $files[i].Size + "'>";
			sFileHtml += "    </a>";
			sFileHtml += "    <a onclick=\"mobile_comm_delFile(this);\" class='add_del ui-link'></a>"
			sFileHtml += "</li>";
		}
	}

	$('#mobile_attach_uplodedfiles').show();
	$('#mobile_attach_uplodedfiles').append(sFileHtml);
	
	// 첨부파일 용량등 표시
	mobile_comm_writeSetFilesInfo();
		
	// 전자결재 첨부파일 업로드 추가
	if(typeof(readfiles) != "undefined") { 
		var aObjFiles = [];
		var aObjFileListlength = mobile_obj_filelist.length;
		
		if (mobile_obj_filelist.length == 0) {
			readfiles($files); // CommonControls.js 내 함수
			SetFileInfo($files);
		} else {
			for (i = 0; i < fileslength; i++) {
				var bCheck = false;
				for (var j = 0; j < aObjFileListlength; j++) {
					if ($files[i].FileName == mobile_obj_filelist[j].FileName) { // 중복됨
						bCheck = true;
						alert(mobile_comm_getDic("msg_AlreadyAddedFile"));
						break;
					}
				}
				if (!bCheck) {
					aObjFiles.push($files[i]);
				}
			}
			readfiles(aObjFiles);
			SetFileInfo(aObjFiles);
		}
	}
}

//첨부파일 정보 setting (수정 등)
function mobile_comm_setfile(target, file, system, controlID){
	if(file != undefined){
		var fileslength = file.length;
		for (var i = 0; i < fileslength; i++ ){
			var fileObj = mobile_comm_makefileobj(file[i].FileID, file[i].FileName, file[i].Size, file[i].FilePath, file[i].SavedName);
			mobile_comm_uploadfilesObj.files.push(file[i]);
			mobile_comm_uploadfilesObj.fileInfos.push(fileObj);
			
			var sFileHtml = "";
			if(system == "Approval") {
				sFileHtml += "<li name='sAttachWrite_liFile' data-filename='" + file[i].FileName + "' data-filesize='" + file[i].Size + "' data-savedname='' value='" + file[i].MessageID + '_' + file[i].Seq + ':' + file[i].FileName + ':OLD:' + file[i].SavedName + "'>";
				sFileHtml += "    <a class=\"add_files\">";
				sFileHtml += "        <span class=\"ico_file " + mobile_comm_getFileExtension(file[i].FileName) + "\"></span>";
				sFileHtml += "        <p class=\"tit\"><span class='file_name'>" + file[i].FileName +"</span>";
				sFileHtml += "        	<span class=\"file_size\">" + mobile_comm_convertFileSize(file[i].Size) + "</span>";
				sFileHtml += " 		  </p>";
				sFileHtml += "		  <input type='hidden' name='hiAttachWrite_fileSize' value = '" + file[i].Size + "'>";
				sFileHtml += "    </a>";
				sFileHtml += "    <a onclick=\"mobile_comm_delFile(this);\" class='add_del ui-link'></a>"
				sFileHtml += "</li>";
			} else if(system == "Account" && controlID != "") {
				sFileHtml += "<span name='sAttachWrite_liFile' data-filename='" + file[i].FileName + "' data-filesize='" + file[i].Size + "' data-savedname='" + file[i].SavedName + "' data-fileid='" + file[i].FileID + "' data-controlid='" + controlID + "'>"
				sFileHtml += "	<p class='detail_file'>" + file[i].FileName + "<a onclick='mobile_comm_delFile(this);' class='nea_del ui-link'></a></p>";
				sFileHtml += "		  <input type='hidden' name='hiAttachWrite_fileSize' value = '" + file[i].Size + "'>";
				sFileHtml += "</span>";
			} else {
				sFileHtml += "<li name='sAttachWrite_liFile' data-filename='" + file[i].FileName + "' data-filesize='" + file[i].Size + "' data-savedname='" + file[i].SavedName + "'>";
				sFileHtml += "    <a class=\"add_files\">";
				sFileHtml += "        <span class=\"ico_file " + mobile_comm_getFileExtension(file[i].FileName) + "\"></span>";
				sFileHtml += "        <p class=\"tit\"><span class='file_name'>" + file[i].FileName +"</span>";
				sFileHtml += "        	<span class=\"file_size\">" + mobile_comm_convertFileSize(file[i].Size) + "</span>";
				sFileHtml += " 		  </p>";
				sFileHtml += "		  <input type='hidden' name='hiAttachWrite_fileSize' value = '" + file[i].Size + "'>";
				sFileHtml += "    </a>";
				sFileHtml += "    <a onclick=\"mobile_comm_delFile(this);\" class='add_del ui-link'></a>"
				sFileHtml += "</li>";
			}
			
			$('#' + target).append(sFileHtml).trigger("create");
		}
		
		if(sFileHtml != "") {
			$('#' + target).show();
		}
	}
}

// 파일 삭제
function mobile_comm_delFile(elem){	
	var $con = $(elem).parent('li');
	
	if($con.length == 0) {
		if($(elem).parent('.detail_file').length > 0) {
			$con = $(elem).parent(".detail_file").parent('span');
		}
		else {
			$con = $(elem);
		}
	}
	
	var escapedFileName = $con.attr('data-filename');
	var fileSize = $con.attr('data-filesize');
	
	// 파일 정보 삭제
	mobile_comm_uploadfilesObj.fileInfos = $.map(mobile_comm_uploadfilesObj.fileInfos, function(item, index) {
		if(item.FileName == encodeURIComponent(escapedFileName) && item.Size == fileSize){
	        return null;
	    }
		
		return item;
	});
	
	// 물리 파일 삭제
	mobile_comm_uploadfilesObj.files = $.map(mobile_comm_uploadfilesObj.files, function(item, index) {
		if(item.name == escapedFileName && item.size == fileSize){
	        return null;
	    }
		
		return item;
	});
	
	// 전자결재 첨부파일 처리
	mobile_obj_filelist = $.map(mobile_obj_filelist, function(item, index) {
		if((item.name == escapedFileName && item.size == fileSize) || (item.FileName == escapedFileName && item.Size == fileSize)){
	        return null;
	    }
		
		return item;
	});
	
	$con.remove();

	// 첨부파일 용량정보 표시
	mobile_comm_writeSetFilesInfo();
}


//다운로드

//파일다운로드 html 생성
function mobile_comm_downloadhtml(fileinfo, pSystem) {	
	var sHtml = "";
	var sFileHtml = "";
		
	if(fileinfo.length > 0) {
		if(pSystem == "Mail"){
			// 확장자 구분
			var imageExt = "JPG,GIF,PNG,BMP";
			var excelExt = "XLS,XLSX";
			var docExt = "DOC,DOCX";
			var zipExt = "ZIP,7ZIP,RAR,ALZ,EGG,TAR";
			var pptExt = "PPT,PPTX";
			var pdfExt = "PDF";
			var attInfoTotalSize = 0;
			var cnt = fileinfo.length;
			
			sFileHtml = "";
			for(var i=0; i<cnt; i++){
				var attItem = fileinfo[i];
				var attExt = attItem.att_name.substring(attItem.att_name.lastIndexOf(".")+1);
				var iconHtml = "";
				if(attExt != null && attExt != ""){
					if(excelExt.indexOf(attExt.toUpperCase()) != -1){
						iconHtml = "<span class='ico_file xlsx'></span>";
					}else if(docExt.indexOf(attExt.toUpperCase()) != -1){
						iconHtml = "<span class='ico_file docx'></span>";
					}else if(zipExt.indexOf(attExt.toUpperCase()) != -1){
						iconHtml = "<span class='ico_file zip'></span>";
					}else if(pptExt.indexOf(attExt.toUpperCase()) != -1){
						iconHtml = "<span class='ico_file pptx'></span>";
					}else if(pdfExt.indexOf(attExt.toUpperCase()) != -1){
						iconHtml = "<span class='ico_file pdf'></span>";
					}else if(imageExt.indexOf(attExt.toUpperCase()) != -1){
						// iconHtml = "<span class='ico_file'><img src=''
						// alt=''/></span>";
						iconHtml = "<span class='ico_file default'></span>";
					}else{
						iconHtml = "<span class='ico_file default'></span>";
					}
				}else{
					iconHtml = "<span class='ico_file default'></span>";
				}				
				sFileHtml += "<li>";
				sFileHtml += "	<a href='#' onclick='mobile_mail_mailReadAttFileDownload(\"SINGLE\", this);' name='mail_mailRead_AttacheFile' class='ui-link' data-file-name=\""+attItem.att_name+"\" data-read-type='SINGLE' data-file-uid=\""+attItem.att_uid+"\" data-file-index=\""+attItem.att_index+"\" data-file-name=\""+attItem.att_name+"\"  data-file-token=\""+attItem.FileToken+"\">";
				sFileHtml += iconHtml;
				sFileHtml += "		<p class='tit'><span>"+ attItem.att_name +"</span>";
				sFileHtml += "		<span class='file_size'>"+ mobile_comm_convertFileSize(attItem.att_size) +"</span></p>";
				sFileHtml += "	</a>";
				sFileHtml += "</li>";								
				attInfoTotalSize += attItem.att_size; // totalSize
			}
			
			sHtml += "<div class=\"add_Mailfiles_area\">";				
			sHtml += "<a href=\"javascript:mobile_mail_mailRead_AttFileTotalInfo();\" name=\"mail_mailRead_AttFileTotalInfo\" class=\"Mail_tx\">";
			sHtml += "	<span class=\"Mail_text\">"+mobile_comm_getDic("CPMail_AttachementFile")+"</span>";				
			sHtml += "	<span name=\"mail_mailRead_AttFileInfoTotalCount\" class=\"Mail_tx_num\">"+cnt+"</span>";
			sHtml += "	<span name=\"mail_mailRead_AttFileInfoTotalSize\" class=\"Mail_tx_capacity\">("+ mobile_comm_convertFileSize(attInfoTotalSize) +")</span>";
			sHtml += "	<span name=\"mail_mailRead_AttInfoArrow\" class=\"Mail_tx_btn close\">버튼</span>";				
			sHtml += "</a>";
			sHtml += "<a href=\"javascript:alert('모바일에서 지원하지 않는 기능입니다.')\" name=\"mail_mailRead_AttacheFileAllSaveBtn\" class=\"btn_all_save\" style=\"display:none;\">"+mobile_comm_getDic("CPMail_AllSave")+"</a>";			
			sHtml += "</div>";							
			sHtml += "<ul class=\"mail_mailRead_AttFileDetailArea\" style=\"display: none;\">";
			sHtml += sFileHtml;
			sHtml += "</ul>";
		}else{
			
			var sFileSize = 0;
			var sFileCnt = 0;
			
			sFileHtml = "";
			$(fileinfo).each(function (i, file) {			
				sFileHtml += "<li>";
				sFileHtml += "    <a onclick=\"mobile_comm_getFile('" + (file.FileID) + "', '" + (file.FileName).replace(/\'/gi, "\\'") + "', '" + file.FileToken + "');\">";
				sFileHtml += "        <span class=\"ico_file " + mobile_comm_getFileExtension(file.FileName) + "\"></span>";
				sFileHtml += "        <p class=\"tit\"><span>" + file.FileName + "</span>";
				sFileHtml += "        <span class=\"file_size\">" + mobile_comm_convertFileSize(file.Size) + "</span></p>";
				sFileHtml += "    </a>";
				sFileHtml += "</li>";	
				++sFileCnt;
				sFileSize = sFileSize + parseInt(file.Size);
			});
			
			sHtml += "<div class=\"files_acc\" style='border-bottom: 1px solid #ddd;" + (pSystem == "Survey" ? " border-top: 1px solid #ddd;" : "") + "'>";
			sHtml += "  <a href=\"javascript:mobile_Read_AttFileTotalInfo(); \" class=\"Mail_tx\">";
			sHtml += "	<span class=\"Mail_text\">"+mobile_comm_getDic("CPMail_AttachementFile")+"</span>";
			sHtml += "	<span class=\"Mail_tx_num\">"+sFileCnt+"</span>";
			sHtml += "	<span class=\"Mail_tx_capacity\">("+ mobile_comm_convertFileSize(sFileSize) +")</span>";
			sHtml += "	<span name='sRead_AttInfoArrow' class=\"Mail_tx_btn close\">버튼</span>";
			sHtml += "	</a>";
			sHtml += "</div>";
			sHtml += "<ul class=\"files_area\" id='ulViewFileList' style='display:none;'>";
			sHtml += sFileHtml;
			sHtml += "</ul>";	
			
		}
	}
	
	mobile_comm_uploadfilesObj.fileInfos = fileinfo;
	return sHtml;
}

//파일다운로드
/**
 * - bizSection:String 파라메터 추가 ex) MAIL - params:Ojbect 파라메터 추가 ex) params.url =
 * "/mail/userMail/mailAttDown.do"
 * 
 * /covicore/common/fileDown.do 기초설정값 조회로 변경 
 * (* 메일 일반첨부, 대용량첨부는 그대로 유지) /mail/userMail/mailAttDown.do, /mail/downloadlargefiles/dodownloadlargefiles.do
 * 
 */
function mobile_comm_getFile(pFileID, pFileName, pFileToken, bizSection, params) {
	
	var url;
	var downurl;
	
	if(bizSection == undefined) {
		bizSection = "";
	}
	if(params != undefined && params != null && bizSection.toUpperCase() == "CPMAIL") {
		params.url = params.url + "&sysType=Mail&fileName=" + encodeURIComponent(pFileName)
				+ "&fileID=" + pFileID 
				+ "&fileToken=" + encodeURIComponent(pFileToken) 
				+ "&userCode=" + encodeURIComponent(mobile_comm_getSession("UR_Code"));		
	}
	if(mobile_comm_getBaseConfig("MobileUseDocConverter") == "Y") {//MobileUseDocConverter-문서변환 사용여부 (Y/N) 

		// TOOD: 문서변환 연동 처리 필요
		
		var WaterMarkText = mobile_comm_getBaseConfig("MobileWatermarkText");   // 기초설정 MobileWatermarkText 값을 읽어온다.

	    if (WaterMarkText.indexOf("@@") > -1) {
	        WaterMarkText = WaterMarkText.split("@@")[1];
	        WaterMarkText = mobile_comm_getSession(WaterMarkText);   
	    }
		
		try {
			// 사이냅 변환 확장자 검사
			var fileExtension = pFileName.split(".").pop().toLowerCase();
			var docExtension = mobile_comm_getBaseConfig("MobileDocConvertorType").split(",");
			
			if(docExtension.indexOf(fileExtension) < 0) {
				alert(mobile_comm_getDic("lbl_apv_warning_extension")); //지원하지 않는 확장자입니다.
				return;
			}	
			
			if(bizSection.toUpperCase() == "CPMAIL"){
				url = location.protocol + "//" + location.host + params.url;
			}else if(bizSection.toUpperCase() == "WEBHARD"){
				url = location.protocol + "//" + location.host + "/webhard/mobile/webhard/user/downloadFile.do?fileUuid="+pFileID;
			}else{
				downurl = mobile_comm_getBaseConfig("FilePreviewDownURL");
				if(downurl == undefined || downurl == "") {
					downurl = "/covicore/common/filePreviewDown.do";
				}
				url = location.protocol + "//" + location.host + downurl 
				+ "?fileID=" + pFileID 
				+ "&fileName=" + encodeURIComponent(pFileName) 
				+ "&fileToken=" + encodeURIComponent(pFileToken) 
				+ "&userCode=" + encodeURIComponent(mobile_comm_getSession("UR_Code"));
			}
			
			if(mobile_comm_isAndroidApp()) {
				
				/*
				 * Android public void callDocConverter(String fileID, String
				 * fileUrl)
				 * 
				 * //window.covimoapp.callDocConverter('114366',
				 * 'http://10.10.31.15:8080/covicore/common/fileDown.do?fileID=114366&fileName=식권신청서.xls')
				 */
				
				try {
	                if (mobile_comm_getBaseConfig("IsSetMobileWatermark") != "Y") {  // 모바일용 워터마크 적용 X
	                    window.covimoapp.callDocConverter(pFileID, url);
	                } else {    // 모바일용 워터마크 적용 O
	                	window.covimoapp.callDocConverter(pFileID, url, WaterMarkText);
	                }
	            } catch (e) {
	                mobile_comm_log('callDocConverter catch - ' + e);
	            }
				
			} else if(mobile_comm_isiOSApp()) {
				/*
				 * window.webkit.messageHandlers.name.postMessage(messageBody)
				 */
				
				// location.href = "covifileview://" + pFileID + "||" + url;
				
				try {
	                if (mobile_comm_getBaseConfig("IsSetMobileWatermark") != "Y") {  // 모바일용 워터마크 적용 X
	                    window.webkit.messageHandlers.callbackHandler.postMessage({ type:'covifileview', fileid: pFileID, url: url });
	                } else {    // 모바일용 워터마크 적용 O
	                	window.webkit.messageHandlers.callbackHandler.postMessage({ type:'covifileview', fileid: pFileID, url: url, watermark: WaterMarkText });
	                }
	            } catch (e) {
	                mobile_comm_log('covifileview catch - ' + e);
	            }
			} else {
				//window.open(mobile_comm_getBaseConfig("MobileDocConverterURL")+ "?fileID=" + pFileID + "&fileToken="+ encodeURIComponent(pFileToken), "viewer", "", true);
				url = mobile_comm_getBaseConfig("MobileDocConverterURL") 
					+ "?fileID=" + pFileID 
					+ "&fileName=" + encodeURIComponent(pFileName) 
					+ "&fileToken=" + encodeURIComponent(pFileToken) 
					+ "&userCode=" + encodeURIComponent(mobile_comm_getSession("UR_Code"));				

				if(bizSection.toUpperCase() == "CPMAIL"){
					url = url + "&sysType=Mail&"+params.url.replace("/mail/userMail/mailAttDown.do?","");
				}
				window.open(url, "viewer", "", true);
/*				if (mobile_comm_getBaseConfig("IsSetMobileWatermark") != "Y") {  // 모바일용 워터마크 적용 X
					window.open(mobile_comm_getBaseConfig("MobileDocConverterURL")+ "?fileID=" + pFileID + "&fileToken="+ encodeURIComponent(pFileToken), "viewer", "", true);
				} else {
					window.open(mobile_comm_getBaseConfig("MobileDocConverterURL")+ "?fileID=" + pFileID + "&fileToken="+ encodeURIComponent(pFileToken) + "&watermarkText=" + WaterMarkText, "viewer", "", true);
				}*/
			}
		} catch (e) {
			mobile_comm_log('mobile_comm_getFile catch - ' + e);
		}
	} else {
		
		if(mobile_comm_isiOSApp()) {
			if(bizSection.toUpperCase() == "CPMAIL"){
				url = location.protocol + "//" + location.host + params.url;
			}else{
				downurl = mobile_comm_getBaseConfig("FilePreviewDownURL");
				if(downurl == undefined || downurl == "") {
					downurl = "/covicore/common/filePreviewDown.do";
				}
				url = location.protocol + "//" + location.host 
					+ downurl + "?fileID=" + pFileID + "&fileName=" + encodeURIComponent(pFileName) 
					+ "&fileToken=" + encodeURIComponent(pFileToken) + "&userCode=" + encodeURIComponent(mobile_comm_getSession("UR_Code"));
			}
			window.webkit.messageHandlers.callbackHandler.postMessage({type:'covifiledown', url: url});
		} else {
			// 첨부파일 다운로드
			var anchor = $('<a />');
			if(bizSection.toUpperCase() == "CPMAIL"){
				anchor.attr('href', params.url);
			} else {
				downurl = mobile_comm_getBaseConfig("FileDownURL");
				if(downurl == undefined || downurl == "") {
					downurl = "/covicore/common/fileDown.do";
				}
				if(/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
					downurl = mobile_comm_getBaseConfig("FilePreviewDownURL");
					if(downurl == undefined || downurl == "") {
						downurl = "/covicore/common/filePreviewDown.do";
					}
					anchor.attr('href', downurl + '?fileID=' + pFileID + '&fileName=' + encodeURIComponent(pFileName) 
							+ "&fileToken=" + encodeURIComponent(pFileToken) + "&userCode=" + encodeURIComponent(mobile_comm_getSession("UR_Code")));
				} else {
					anchor.attr('href', downurl + '?fileID=' + pFileID + '&fileName=' + encodeURIComponent(pFileName) 
							+ "&fileToken=" + encodeURIComponent(pFileToken));
				}
			}
			anchor.attr('download', pFileName);		// 다운로드시 생성될 파일명 ( 저장시점의 원본파일명 )
			anchor[0].click();
			anchor.remove();
		}
	}
}


//첨부목록 접기/펼치기
function mobile_Read_AttFileTotalInfo() {
	var spanAttFileTotalInfoArrow = $("span[name=sRead_AttInfoArrow]");
	if(spanAttFileTotalInfoArrow.hasClass("open")){
		$("#ulViewFileList").hide();
		spanAttFileTotalInfoArrow.removeClass("open").addClass("close");		
	}else{
		$("#ulViewFileList").show();
		spanAttFileTotalInfoArrow.removeClass("close").addClass("open");		
	}
}


//공통

// fileobj 형태로 데이터 가공
function mobile_comm_makefileobj(fileId, fileName, fileSize, filePath, savedName){	
	var fileObj = new Object();
	fileObj.FileName = encodeURIComponent(fileName);
	fileObj.Size = fileSize;
	fileObj.FileID = fileId;
	fileObj.FilePath = filePath;
	fileObj.SavedName = savedName;
	fileObj.FileType = "normal";
	
	return fileObj;
}

// 첨부된 파일 개수, 용량 합계 설정
function mobile_comm_writeSetFilesInfo(){
	var liFiles = $('#mobile_attach_uplodedfiles li[name=sAttachWrite_liFile]');
	var fileSizeSum = 0;
	var fileSizeText = '';
	var cnt = liFiles.length;
	for(var i=0 ; i<cnt ; i++){
		var fileSize = $(liFiles[i]).find('[name=hiAttachWrite_fileSize]').val();
		fileSizeSum = fileSizeSum + Number(fileSize);
	}
	
	if(fileSizeSum == 0){
		fileSizeText = fileSizeText + '0KB';
		$('#mobile_attach_uplodedfiles').hide();
		$('#pAttachInit').show();
		$('#pAttachAdd').hide();
	}else{
		$('#mobile_attach_uplodedfiles').show();
		$('#pAttachInit').hide();
		$('#pAttachAdd').show();
		fileSizeText = fileSizeText + mobile_comm_convertFileSize(fileSizeSum);
	}
	fileSizeText = '('+ fileSizeText + ')';
	$('#sAttachWrite_txNum').html(cnt);
	$('#sAttachWrite_txCapacity').html(fileSizeText);
}

// 파일사이즈 공통처리
function mobile_comm_convertFileSize(byte) {	
	var sRet = "";
    var nSize = parseInt(byte);
    var sUnit = "Byte";

    if (nSize >= 1024) {
        nSize = nSize / 1024;
        sUnit = "KB";
    }
    if (nSize >= 1024) {
        nSize = nSize / 1024;
        sUnit = "MB";
    }
    if (nSize >= 1024) {
        nSize = nSize / 1024;
        sUnit = "GB";
    }
    if (nSize >= 1024) {
        nSize = nSize / 1024;
        sUnit = "TB";
    }

    sRet = mobile_comm_addComma(nSize.toFixed(0).toString()) + sUnit;

    return sRet;
}

// 첨부 확장자 css
function mobile_comm_getFileExtension(pFileName) {
	var sRet = "default";
	
	var fileExtension = pFileName.substring(pFileName.lastIndexOf(".") + 1);
	fileExtension = fileExtension.replace('/./g', '');
	
	switch(fileExtension.toUpperCase()) {
		case "PPT":
		case "PPTX":
			sRet = "pptx";
			break;
		case "PDF":
			sRet = "pdf";
			break;
		case "ZIP":
			sRet = "zip";
			break;
		case "XLS":
		case "XLSX":
			sRet = "xlsx";
			break;
		case "DOC":
		case "DOCX":
			sRet = "docx";
			break;
	}
	
	return sRet;
}

// 첨부 확장자
function mobile_comm_getFileExtensionName(pFileName) {
	
	var fileExtension = pFileName.substring(pFileName.lastIndexOf(".") + 1);
	fileExtension = fileExtension.replace('/./g', '');
	
	return fileExtension;
}


//전자결재 관련

//전자결재 전용 - mobile_obj_filelist push
function readfiles(files) {
	for (var i = 0; i < files.length; i++) {
		mobile_obj_filelist.push(files[i]);
	}
}

//전자결재 전용 - 파일 정보 히든필드에 셋팅
function SetFileInfo(pObjFileInfo) {
	var aObjFileInfo = new Array();
	aObjFileInfo = pObjFileInfo;
	var sFileInfo = "";
	var sFileInfoTemp = "";
	var nLength = aObjFileInfo.length; 
	for (var i = 0; i < nLength; i++) {
		var attachType = (aObjFileInfo[i].FileType == undefined ? "normal" : aObjFileInfo[i].FileType); 	// webhard
																											// or
																											// normal
		var name = (aObjFileInfo[i].name == undefined ? aObjFileInfo[i].FileName : aObjFileInfo[i].name);
		var size = (aObjFileInfo[i].size == undefined ? aObjFileInfo[i].Size : aObjFileInfo[i].size);

		sFileInfo += name + ":" + size + ":" + "NEW" + ":" + "0" + ":" + attachType + ":" + "|";
		sFileInfoTemp += name + ":" + name.split(',')[name.split(',').length - 1] + ":" + size + "|";
	}
	try {
		if (document.getElementById("mobile_attach_uplodedfiles").value == null) {
			document.getElementById("mobile_attach_uplodedfiles").value = "";
		}
		document.getElementById("mobile_attach_uplodedfiles").value += sFileInfo;
		document.getElementById("hidFileSize").value += sFileInfoTemp;
	} catch(e) {mobile_comm_log(e);
	}
}







/**
 * 
 * 위치/지도
 * 
 */

var mobile_comm_intervalid = null;
var mobile_comm_icheckcnt = 0;     // 위치정보 확인 횟수

//위치/지도 보여주기
function mobile_comm_showLocation(pUrl) {
	// TODO: 위치/지도 보여주기 처리 필요
	// alert(pUrl + ' 보여주기 !!');
}

//앱에 위치정보 요청
function mobile_comm_callapplocation() {

    // 데이터 초기화
    $('#mobile_locationcode').val('');
    $('#mobile_locationaddress').val('');
    mobile_comm_icheckcnt = 0;

    // 위치정보 요청 시작
    alert('위치 확인을 시작합니다.');
    mobile_comm_showload();

    try {
		if(mobile_comm_isAndroidApp()) {
		    window.covimoapp.GetLocationInfo();
		} else if(mobile_comm_isiOSApp()) {
		    window.webkit.messageHandlers.callbackHandler.postMessage({ type:'getlocationinfo' }); 
		}
		
		var intervalid = mobile_comm_intervalid = window.setInterval(function () {
            if (++mobile_comm_icheckcnt === 10 || $('#mobile_locationcode').val() != "") {
                window.clearInterval(intervalid);

                if (mobile_comm_intervalid != null) {
                	mobile_comm_getaddress($('#mobile_locationcode').val());
                    return;
                }
            }
        }, 2 * 1000);
	} catch(e) {
		mobile_comm_log(e);
	}
}

// 위치정보(위도/경도) 저장
function mobile_comm_callapplocation_callback(pLocationCode) {
    $('#mobile_locationcode').val(pLocationCode);
}

// 위치정보(위도/경도)로 주소 조회
// 1) 구글API사용
// - https://developers.google.com/maps/documentation/geocoding/start
// - 개발용 CoviMDM2019 apikey AIzaSyCC_8iNuntWM-HtLhKZUGcsx1dU1_zRhA4 (*결제 기능 사용안할
// 경우 하루 제한량 있으며, 너무 적음)
// - 기존 CoviMDM apikye AIzaSyCXD1t5j5Wb-5msxdxRlUXU5j4O1ilITf8
/*
 * function mobile_comm_getaddress(pLocationCode) {
 * 
 * //{"lat":"37.5622471","lon":"126.839661","time":"yyyy-MM-dd HH:mm:ss"}
 * 
 * var jsonlocationinfo; try { jsonlocationinfo = JSON.parse(pLocationCode); }
 * catch(e) { mobile_comm_log(e); }
 * 
 * var code = pLocationCode;
 * 
 * if(jsonlocationinfo == undefined || jsonlocationinfo.lat == undefined ||
 * jsonlocationinfo.lon == undefined || (jsonlocationinfo.lat == "0.0" &&
 * jsonlocationinfo.lon == "0.0")) { mobile_comm_hideload();
 * 
 * alert('위치 확인 불가'); return ""; }
 * 
 * var apiurl =
 * "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyCXD1t5j5Wb-5msxdxRlUXU5j4O1ilITf8";
 * apiurl += "&latlng=" + jsonlocationinfo.lat + "," + jsonlocationinfo.lon;
 * 
 * $.get(apiurl, function (data, status) {
 * 
 * var address = data.results[0].formatted_address; var count =
 * data.results.length; for (var i = 0; i < count; i++) { mobile_comm_log(i + ": " +
 * data.results[i].formatted_address); if(i == 0) { //지번 주소를 사용 address =
 * data.results[i].formatted_address; } // if(i == 1) { //도로명 주소를 사용 //FIXME:
 * 도로명주소 없을 수도 있음 // address = data.results[i].formatted_address; // } }
 * 
 * $('#mobile_locationaddress').val(address);
 * 
 * mobile_comm_hideload();
 * 
 * alert('!!테스트알림!! 주소: ' + $('#mobile_locationaddress').val()); }); }
 */

// 2) nominatim 사용
// - 사용예>
// https://nominatim.openstreetmap.org/reverse?format=json&lat=54.9824031826&lon=9.2833114795&addressdetails=1
// /*
function mobile_comm_getaddress(pLocationCode) {
	
	// {"lat":"37.5622471","lon":"126.839661","time":"yyyy-MM-dd HH:mm:ss"}
	
	var jsonlocationinfo;
	try {
		jsonlocationinfo = JSON.parse(pLocationCode);
	} catch(e) {
		mobile_comm_log(e);
	}
	
	if(jsonlocationinfo == undefined || jsonlocationinfo.lat == undefined || jsonlocationinfo.lon == undefined
			|| (jsonlocationinfo.lat == "0.0" && jsonlocationinfo.lon == "0.0")) {
		mobile_comm_hideload();
		
		alert('위치 확인 불가');
		return "";
	}
	
	var apiurl = "https://nominatim.openstreetmap.org/reverse?format=json&addressdetails=1";
	apiurl += "&lat=" + jsonlocationinfo.lat;
	apiurl += "&lon=" + jsonlocationinfo.lon;
	
    $.get(apiurl, function (data, status) {
    	var address = (data.address.country != undefined) ? data.address.country : "";
    	address += " ";
    	address += (data.address.city != undefined) ? data.address.city : "";
    	address += " ";
    	address += (data.address.town != undefined) ? data.address.town : "";
    	address += " ";
    	address += (data.address.road != undefined) ? data.address.road : "";
    	address += " ";
    	address += (data.address.house_number != undefined) ? data.address.house_number : "";
    	address += " ";
    	address += (data.address.building != undefined) ? data.address.building : "";
    	
    	$('#mobile_locationaddress').val(address);
        
    	mobile_comm_hideload();
    	
    	alert('!!테스트알림!! 주소: ' + $('#mobile_locationaddress').val());
    });
}




/**
 * 
 * 앱 공통
 * 
 */

function mobile_comm_isMobileApp() {
	if(navigator.userAgent.toString().indexOf(" com.covision.moapp(android)") > -1
			|| navigator.userAgent.toString().indexOf(" com.covision.moapp(ios)") > -1) {
		return true;
	} else {
		return false;
	}
}

function mobile_comm_isAndroidApp() {
	if(navigator.userAgent.toString().indexOf(" com.covision.moapp(android)") > -1) {
		return true;
	} else {
		return false;
	}
}

function mobile_comm_isiOSApp() {
	if(navigator.userAgent.toString().indexOf(" com.covision.moapp(ios)") > -1) {
		return true;
	} else {
		return false;
	}
}

//현재 웹뷰 체크
function mobile_comm_RequestActiveFragment(){
	var strReturn = "web";
	try {
		if(mobile_comm_isAndroidApp()) {
			strReturn = window.covimoapp.RequestActiveFragment();
		} else if(mobile_comm_isiOSApp()) {
			/*
			 * window.webkit.messageHandlers.name.postMessage(messageBody)
			 * */
			strReturn = window.webkit.messageHandlers.callbackHandler.postMessage({ type:'RequestActiveFragment'});
		}
	} catch(e) {
		mobile_comm_log(e);
	}
	
	return strReturn;
	
}



/**
 * 
 * 앱 - 음성인식
 * 
 */


//음성인식 값을 넣어야 할 객체 아이디
var mobile_VoiceInputId = null;
var mobile_VoiceInputType = "change"; // change - 값 교체, append - 값 추가 , callback - 콜백 호출
var mobile_VoiceInputObj = null;
var mobile_VoiceInputCallBack = "";
var mobile_VoiceCallback = null;

//음성인식 호출
function mobile_comm_callappvoicerecognition(pCallBackMethod) {
	
	if(typeof pCallBackMethod != "undefined"){
		mobile_VoiceCallback = pCallBackMethod;	
	}		
	      
	//음성인식 리스너 앱을 통해 호출
	try {
		if(mobile_comm_isAndroidApp()) {
			/*
			 * Android
			 * public void RequestVoiceRecognition()
			 * */
			window.covimoapp.RequestVoiceRecognition();
		} else if(mobile_comm_isiOSApp()) {
			/*
			 * window.webkit.messageHandlers.name.postMessage(messageBody)
			 * */
			window.webkit.messageHandlers.callbackHandler.postMessage({ type:'covivoicerecognition'});
		}  else {
			alert(mobile_comm_getDic("모바일 앱에서만 지원하는 기능입니다."));
		}
	} catch (e) {
		mobile_comm_log(e);
	}
}

//음성인식 stop
function mobile_comm_callappstopvoicerecognition() {
//	alert('음성인식 리스너 stop.');
	      
	//음성인식 리스너 앱을 통해 호출
	try {
		if(mobile_comm_isAndroidApp()) {
			/*
			 * Android
			 * public void RequestStopVoiceRecognition()
			 * */
			window.covimoapp.RequestStopVoiceRecognition();
		} else if(mobile_comm_isiOSApp()) {
			/*
			 * window.webkit.messageHandlers.name.postMessage(messageBody)
			 * */
			window.webkit.messageHandlers.callbackHandler.postMessage({ type:'covivoicestoprecognition'});
		}  else {
			alert(mobile_comm_getDic("모바일 앱에서만 지원하는 기능입니다."));
		}
	} catch (e) {
		mobile_comm_log(e);
	}
}

//음성인식 리스너 호출
function mobile_comm_voicerecognition_callback(pVoiceResult) {
	// pVoiceResult는 '퇴직 부서,퇴직 보소,퇴직 보석,돼지 부속,퇴직 분석' 형식으로 응답
	var arrayResult = pVoiceResult.split(','); // {퇴직 부서, 퇴직 보소, 퇴직 보석, 돼지 부속, 퇴직 분석}
	
	if(typeof(mobile_VoiceCallback) != "undefined" && mobile_VoiceCallback != null) {
		mobile_VoiceCallback(arrayResult);
	}
}

// 보이스 인풋 컨트롤 바인딩
function mobile_comm_VoiceInputCtrlBind(){
	var varThisPage = $("#"+$.mobile.activePage.attr( "id" ))
	$(varThisPage).find(".mobileViceInputCtrl").each(function(){
		$(this).css({"padding-right":"25px"}); // 입력박스의 패딩 조정
		var l_id = $(this).attr("id");
		var l_voiceInputType = $(this).attr("voiceInputType");
		var l_voiceCallBack = $(this).attr("voiceCallBack");
		var l_voiceStyle = $(this).attr("voiceStyle");
		
		if($("#VoiceListener_"+l_id).length == 0){
			$(this).after('<a onclick="mobile_comm_VoiceInput(this)" id="VoiceListener_'+ l_id +'" mobile_VoiceInputId="'+l_id+'" mobile_VoiceInputType="'+l_voiceInputType+'" mobile_VoiceInputCallBack="'+l_voiceCallBack+'" class="btn_vw used" style="'+ l_voiceStyle +' display: none;"><span>사용</span></a>');
			
			if($(this).val().length > 0) {
				$('#' + l_id + '_btn').show();
			} else {
				$("#VoiceListener_"+ l_id).show();
			}
		}
	});
}

// 음성입력 컨트롤 제어
function mobile_comm_VoiceInput(pObj){
	if(typeof(pObj) != "undefined"){
		mobile_VoiceInputObj = pObj;	
	}
	if($(mobile_VoiceInputObj).hasClass("used")){
		if(mobile_VoiceInputId != null && mobile_VoiceInputId != $(mobile_VoiceInputObj).attr("mobile_VoiceInputId")){
			$("#VoiceListener_"+mobile_VoiceInputId).removeClass("act").addClass("used");
		}
		$(mobile_VoiceInputObj).removeClass("used").addClass("act");
		mobile_VoiceInputId = $(mobile_VoiceInputObj).attr("mobile_VoiceInputId");
		mobile_VoiceInputType = $(mobile_VoiceInputObj).attr("mobile_VoiceInputType");
		mobile_VoiceInputCallBack = $(mobile_VoiceInputObj).attr("mobile_VoiceInputCallBack");
		// 음성인식 리스너 활성화
		mobile_comm_callappvoicerecognition(mobile_comm_VoiceInputCallBack);
	} else {
		$(mobile_VoiceInputObj).removeClass("act").addClass("used");
		// 음성인식 리스너 중지
		mobile_comm_callappstopvoicerecognition();
	}
}

// 음성입력 컨트롤 콜백
function mobile_comm_VoiceInputCallBack(pResult, pList){
	if($(mobile_VoiceInputObj).hasClass("act")){
		$(mobile_VoiceInputObj).removeClass("act").addClass("used");
	}
	if(pResult != ""){
		if(pResult.length > 1 && pList != "Y"){
			var strList = "";
			for(var i = 0; i < pResult.length; i++){
				var strInputTxt = pResult[i];
				strList += ("<li onclick='mobile_comm_VoiceInputCallBack(\"{0}\", \"Y\")'><span class='voice_search_kw'>{0}</span></li>").replace("{0}", strInputTxt).replace("{0}", strInputTxt);
			}
			if(strList != ""){
				$("#divViceInputMulti").remove();
				var varThisPage = $("#"+$.mobile.activePage.attr( "id" ))
				var strLayer = "";
				
				strLayer += '<div class="mobile_popup_wrap" id="divViceInputMulti" style="display:none;">';
				strLayer += '	<div class="voice_search_wrap">';
				strLayer += '		<a href="javascript:$(\'#divViceInputMulti\').hide()" class="btn_voice_cancel"><span>닫기</span></a>';
				strLayer += '		<div class="voice_search_list_scroll">';
				strLayer += '			<ul class="voice_search_list" id=\'ulInputText\'>';
				strLayer += '			</ul>';
				strLayer += '		</div>';
				strLayer += '	</div>';
				strLayer += '</div>';
				$(varThisPage).append(strLayer)
				$("#ulInputText").html(strList);
				$("#divViceInputMulti").show();
			}
		// 미스 매치, 미입력 => 음성인식 재호출
		} else if(pResult == "**no_match" || pResult == "**no_speech"){
			setTimeout("mobile_comm_VoiceInput()", 100);
		// 사용자가 중지
		} else if(pResult == "**stop"){
			//mobile_comm_callappstopvoicerecognition();
		} else {
			// 단일건 등록
			if(mobile_VoiceInputType == "change"){
				$("#"+mobile_VoiceInputId).val(pResult);	
			} else if(mobile_VoiceInputType == "append"){
				$("#"+mobile_VoiceInputId).val($("#"+mobile_VoiceInputId).val() +' '+ pResult);
			} else if(mobile_VoiceInputType == "callback"){
				if(mobile_VoiceInputId != "") {
					$("#"+mobile_VoiceInputId).val(pResult);	
				}
				let ptFunc = new Function('a', mobile_VoiceInputCallBack+'(a)');
				ptFunc(pResult) ;
			}
			
			if(pList == "Y"){
				$("#divViceInputMulti").hide();
			}
		}		
	}
}




/**
 * 
 * 앱 - OCR
 * 
 */

var mobile_OcrCallback = null;

//영수증 OCR 함수 호출
function mobile_comm_callappextractreceiptinfo(pCallBackMethod) {
	
	if(typeof pCallBackMethod != "undefined"){
		mobile_OcrCallback = pCallBackMethod;	
	}		
	      
	// 영수증 OCR 앱을 통해 호출
	try {
		if(mobile_comm_isAndroidApp()) {
			/*
			 * Android
			 * public void RequestExtractReceiptInfo()
			 * */
			window.covimoapp.RequestExtractReceiptInfo();
			mobile_comm_showload();
		} else if(mobile_comm_isiOSApp()) {
			/*
			 * window.webkit.messageHandlers.name.postMessage(messageBody)
			 * */
			window.webkit.messageHandlers.callbackHandler.postMessage({ type:'coviOCR'});
			mobile_comm_showload();
		}  else {
			alert(mobile_comm_getDic("모바일 앱에서만 지원하는 기능입니다."));
		}
	} catch (e) {
		mobile_comm_log(e);
	}
}

//OCR 콜백
function mobile_comm_extractreceiptinfo_callback(pOcrResult, pImageData) {
    // pVoiceResult는 줄바꿈 기준으로 영수증 정보를 추출한 string 배열, 구분자 설정 필요. 임시 설정 " , " (comma)
	
	if(!pOcrResult || !pImageData){
		alert(mobile_comm_getDic("OCR인증에 실패하였습니다. 다시 시도해주세요."));
		mobile_comm_hideload();
		return;
	}

    var Base64Converter = {
    		
        // private property
        _keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",

        // public method for decoding
        decode: function (input) {
            var output = "";
            var chr1, chr2, chr3;
            var enc1, enc2, enc3, enc4;
            var i = 0;

            input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
            while (i < input.length) {
                enc1 = this._keyStr.indexOf(input.charAt(i++));
                enc2 = this._keyStr.indexOf(input.charAt(i++));
                enc3 = this._keyStr.indexOf(input.charAt(i++));
                enc4 = this._keyStr.indexOf(input.charAt(i++));

                chr1 = (enc1 << 2) | (enc2 >> 4);
                chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
                chr3 = ((enc3 & 3) << 6) | enc4;

                output = output + String.fromCharCode(chr1);
                if (enc3 != 64) {
                    output = output + String.fromCharCode(chr2);
                }
                if (enc4 != 64) {
                    output = output + String.fromCharCode(chr3);
                }
            }
            output = Base64Converter._utf8_decode(output);
            return output;
        },
        
        // private method for UTF-8 decoding
        _utf8_decode: function (utftext) {
            var string = "";
            var i = 0;
            var c = 0, c1 = 0, c2 = 0, c3 = 0;

            while (i < utftext.length) {
                c = utftext.charCodeAt(i);
                if (c < 128) {
                    string += String.fromCharCode(c);
                    i++;
                }
                else if ((c > 191) && (c < 224)) {
                    c2 = utftext.charCodeAt(i + 1);
                    string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
                    i += 2;
                }
                else {
                    c2 = utftext.charCodeAt(i + 1);
                    c3 = utftext.charCodeAt(i + 2);
                    string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
                    i += 3;
                }
            }
            return string;
        }
    }

    var extractResult = Base64Converter.decode(pOcrResult);
    var base64ImgData;

    if (mobile_comm_isiOSApp()) {
        base64ImgData = decodeURIComponent(pImageData);
    } else {
        base64ImgData = pImageData
    }

    // 웹에서 처리할 부분 임시 테스트 , 추출 (일반/주유/택시)
    //      ], :, 대부분 2가지로 구분.
    //      가맹점명, 매장명, 점포명, 상호
    //      가맹점주소, 주소, 차량 번호(택시)
    //      결제날짜, 승인일시, 발행일시, 매출일, 거래일시 (날짜 + 시간), 승하차시간(택시)
    //      결제시간    :   (2020-02-05    12:46:22,  20/02/05 12:46:22, 2020년2월5일(수) 12:46)
    //      결제금액, 합계금액, 승인금액, 금액, 합계, 총합계, 판매금액, total, 영수금액, 승차 요금(택시)
    var results = extractResult.split("\n");

    var groupMatcher = "";
    var namePattern = /.*(장|포|점)\s{0,}(명)/;
    var taxiNamePattern = /[가-힣]*\s{0,}(택시|상운|흥업|실업|교통|운수|\(주\))/;
    var taxiNumberPattern = /..\d\d(자|바|아|사)\d*/;
    var gasStationNamePattern = /.*\s{0,}(주유소)/;
    var addressPattern = /[가-힣].*(로|동)\s{0,}[0-9].*/;    // .*[로]\s{0,}[0-9].*
    var datePattern = /(19|20|)\d{2}\s{0,}(-|년|\/)\s{0,}(0[1-9]|[1-9]|1[012])\s{0,}(-|월|\/)\s{0,}(0[1-9]|[12][0-9]|3[0-1]|[0-9])\s{0,}(\s{0,}일|\s{0,})/;
    var timePattern = /(0[0-9]|1[0-9]|2[0-3]):([0-5][0-9])(:([0-5][0-9])|)/;
    var moneyPattern = /(\d|,)*(,|\.)([0-9][0-9][0-9])/;

    var ocrResult = { UseDate: "", UseTime: "", StoreName: "", TotalAmount: "", StoreAddress: "" }
    var checkType = "";
    if (extractResult.includes("주유"))
        checkType = "주유";
    else if (extractResult.includes("택시") || extractResult.includes("승하차")) {
        checkType = "택시";
    }

    // base64_string 파일로 변환
    var ocrImgArr = base64ImgData.split(','),
       mime = ocrImgArr[0].match(/:(.*?);/)[1],
       bstr = atob(ocrImgArr[1]),
       n = bstr.length,
       u8arr = new Uint8Array(n);

    while (n--) {
        u8arr[n] = bstr.charCodeAt(n);
    }
    
    var ocrImgFile = new File([u8arr], "receipt.png", { type: mime });
    var i;
    
    // 가맹점명
    for (i = 0; i < results.length; i++) {
        switch (checkType) {
            case "주유":
                groupMatcher = gasStationNamePattern.exec(results[i]);
                if (groupMatcher != null) {
                    ocrResult.StoreName = groupMatcher[0];
                }
                break;
            case "택시":
                groupMatcher = taxiNamePattern.exec(results[i]);
                if (groupMatcher != null) {
                    ocrResult.StoreName = groupMatcher[0];
                }
                break;
            default:
                groupMatcher = namePattern.exec(results[i]);
                if (groupMatcher != null) {
                    if (results[i].includes(":")) {
                        ocrResult.StoreName = results[i].split(":")[1];
                    }
                    else if (results[i].includes("]")) {
                        ocrResult.StoreName = results[i].split(":")[1];
                    }
                    else {
                        ocrResult.StoreName = results[i];
                    }
                }
        }
    }

    // 가맹점 주소
    for (i = 0; i < results.length; i++) {
        switch (checkType) {
            case "택시":
                groupMatcher = taxiNumberPattern.exec(results[i]);
                if (groupMatcher != null) {
                    ocrResult.StoreAddress = groupMatcher[0];
                }
                break;
            default:
                groupMatcher = addressPattern.exec(results[i]);
                if (groupMatcher != null) {
                    if (results[i].includes(":")) {
                        ocrResult.StoreAddress = results[i].split(":")[1];
                    }
                    else if (results[i].includes("]")) {
                        ocrResult.StoreAddress = results[i].split(":")[1];
                    }
                    else {
                        ocrResult.StoreAddress = results[i];
                    }
                }
        }
    }

    // 거래일자
    for (i = 0; i < results.length; i++) {
        groupMatcher = datePattern.exec(results[i]);
        if (groupMatcher != null) {

            if (groupMatcher[0].includes('-')) {
                ocrResult.UseDate = groupMatcher[0];
            } else if (groupMatcher[0].includes('.')) {
                ocrResult.UseDate = groupMatcher[0].replace('.', '-');
            } else if (groupMatcher[0].includes('/')) {
                ocrResult.UseDate = groupMatcher[0].replace('/', '-');

                if (groupMatcher[0].split('/')[0].length == 2) {
                    ocrResult.UseDate = "20" + groupMatcher[0].replace(/\//g, '-');
                }
            } else if (groupMatcher[0].includes('년') || groupMatcher[0].includes('월') || groupMatcher[0].includes('일')) {
                var tempYear = groupMatcher[0].split('년')[0];
                var tempMonth = groupMatcher[0].split('월')[0].substring(groupMatcher[0].split('월')[0].length - 2, groupMatcher[0].split('월')[0].length);
                var tempDay = groupMatcher[0].split('일')[0].substring(groupMatcher[0].split('일')[0].length - 2, groupMatcher[0].split('일')[0].length);

                ocrResult.UseDate = tempYear + "-" + tempMonth + "-" + tempDay;
            }
        }
    }

    // 거래시간
    for (i = 0; i < results.length; i++) {
        groupMatcher = timePattern.exec(results[i]);
        if (groupMatcher != null) {
            if (groupMatcher[0].length != 8) {
                ocrResult.UseTime = groupMatcher[0] + ":00";
            } else {
                ocrResult.UseTime = groupMatcher[0];
            }
        }
    }

    // 거래금액
    var MaximumMoney = 0;
    for (i = 0; i < results.length; i++) {
        groupMatcher = moneyPattern.exec(results[i]);
        if (groupMatcher != null && MaximumMoney < parseInt(groupMatcher[0].replace(/,/g, ""))) {
            MaximumMoney = parseInt(groupMatcher[0].replace(/,|\./g, ""));
            ocrResult.TotalAmount = MaximumMoney.toString();
        }
    }

    if (typeof (mobile_OcrCallback) != "undefined" && mobile_OcrCallback != null) {
        mobile_OcrCallback(ocrImgFile, ocrResult);
    }

    mobile_comm_hideload();
}




/**
 * 
 * 앱 - 연락처동기화
 * 
 */

//선택된 사용자 연락처 동기화
function mobile_comm_syncuserphonenumber(pUserCodes, pGroupCodes) {
	alert('연락처 동기화를 시작합니다.');
	var sUserCodes = pUserCodes;
	var sGroupCodes = pGroupCodes;	// 기술연구소, 영업팀
	
	try {
		if(mobile_comm_isAndroidApp()) {
			/*
			 * Android
			 * public void RequestVoiceRecognition()
			 * */
			window.covimoapp.SyncUserPhoneNumber(sUserCodes, sGroupCodes);
		} else if(mobile_comm_isiOSApp()) {
			/*
			 * window.webkit.messageHandlers.name.postMessage(messageBody)
			 * */
			window.webkit.messageHandlers.callbackHandler.postMessage({ type:'covisynccontact', pUserCodes: sUserCodes, pGroupCodes: sGroupCodes });
		}  else {
			alert(mobile_comm_getDic("모바일 앱에서만 지원하는 기능입니다."));
		}
	} catch (e) {
		mobile_comm_log(e);
	}
}




/**
 * 
 * 메일
 * 
 */

/* 2020.1.9 메일 사용 안할시 포탈에서 JS 로드 못해오는 오류 해결위해 함수 추가*/
function mobile_comm_getClassProfile(addr){
	var bgCase1 = /[A-D]/;
	var bgCase2 = /[E-H]/;
	var bgCase3 = /[I-L]/;
	var bgCase4 = /[M-P]/;
	var bgCase5 = /[Q-T]/;
	var bgCase6 = /[U-X]/;
	var bgCase7 = /[Y-Z0-1]/; // Y~Z + 0-1
	var bgCase8 = /[2-5]/;
	var bgCase9 = /[6-9]/;
	
	var result= "BGcolor01";
	if(typeof(addr) == "string"){
		var firstChar = addr.substring(0,1).toUpperCase();
		if(bgCase1.test(firstChar)){
			result = "BGcolor01";
		}else if(bgCase2.test(firstChar)){
			result = "BGcolor02";
		}else if(bgCase3.test(firstChar)){
			result = "BGcolor03";
		}else if(bgCase4.test(firstChar)){
			result = "BGcolor04";
		}else if(bgCase5.test(firstChar)){
			result = "BGcolor01";
		}else if(bgCase6.test(firstChar)){
			result = "BGcolor02";
		}else if(bgCase7.test(firstChar)){
			result = "BGcolor03";
		}else if(bgCase8.test(firstChar)){
			result = "BGcolor04";
		}else if(bgCase9.test(firstChar)){
			result = "BGcolor01";
		}else{
			result = "BGcolor02";
		}
	}
	
	return result;
}

function mobile_comm_convertCode(str){
	if(str != null){
		str = str.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\"/g,"&quot;").replace(/\'/g,"&#39;").replace(/,/g,"&#44;");		
	}
	return str;
}







/*
 * ! 날짜/시간 공통처리
 */

// 날짜를 문자열(yyyy.mm.dd)로 변경합니다.
// y=연도(yyyy/yy), M=월(MM/M), d=일(dd/d), H=시(24시간)(HH/H), h=시(12시간)(hh/h),
// m=분(mm/m)
function mobile_comm_getDateTimeString(format, objDate) {
	var sYear = objDate.getFullYear();
	var sMonth = mobile_comm_AddFrontZero(objDate.getMonth() + 1, 2);
	var sDay = mobile_comm_AddFrontZero(objDate.getDate(), 2);
	var sHours = mobile_comm_AddFrontZero(objDate.getHours(), 2);
	var sHhours = sHours;
	var sMinute = mobile_comm_AddFrontZero(objDate.getMinutes(), 2);
	var sSecond = mobile_comm_AddFrontZero(objDate.getSeconds(), 2);
	if (sHhours > 12) {
	    sHhours = mobile_comm_AddFrontZero(sHhours - 12, 2);
	}
	
	if(format.includes(":ss")) {
		return format.replace("yyyy", sYear).replace("MM", sMonth).replace("dd", sDay).replace("HH", sHours).replace("hh", sHhours).replace("mm", sMinute).replace("ss", sSecond);
	} else {
		return format.replace("yyyy", sYear).replace("MM", sMonth).replace("dd", sDay).replace("HH", sHours).replace("hh", sHhours).replace("mm", sMinute);
	}	
}

// 날짜시간을 타입별로 변경
// 리스트> 몇초전/몇분전/몇시간전/10.27/2016.12.10 (초없음)
// 상세>
function mobile_comm_getDateTimeString2(type, date) {
	if (date == undefined || date == "") {
        return date;
    }

    if (typeof date == "object") {
    	date = mobile_comm_getDateTimeString("yyyy-MM-dd HH:mm", date);
    } else {
    	date = date.replace(/\./gi, '-');
    }
    
    var nYear = new Number(date.split(" ")[0].split("-")[0]);
    var nMonth = new Number(date.split(" ")[0].split("-")[1]);
    var nDate = new Number(date.split(" ")[0].split("-")[2]);
    var nHour = new Number(date.split(" ")[1].split(":")[0]);
    var nMin = new Number(date.split(" ")[1].split(":")[1]); 
    
	var sRet = date;
	var dtDate = null;
	var dtNow = null;
	
	try {
		dtDate = new Date(nYear, nMonth - 1, nDate, nHour, nMin);
		if(mobile_comm_getBaseConfig("useTimeZone") != "Y"){
			dtNow = new Date();
		} else {
			dtNow = new Date(CFN_GetLocalCurrentDate());
		}
				
		if(type.toUpperCase() == "LIST") {
			if (dtNow.getFullYear() == dtDate.getFullYear()
                && (dtNow.getMonth() + 1) == (dtDate.getMonth() + 1)
                && dtNow.getDate() == dtDate.getDate()) {
				
				var msecPerMinute = 1000 * 60;
				var msecPerHour =  msecPerMinute * 60;
				
				var interval = dtNow.getTime() - dtDate.getTime();
				
				// Calculate the hours, minutes, and seconds.
				var hours = Math.floor(interval / msecPerHour );
				// interval = interval - (hours * msecPerHour );

				var minutes = Math.floor(interval / msecPerMinute );
				// interval = interval - (minutes * msecPerMinute );

				var seconds = Math.floor(interval / 1000 );
				
				if(hours > 0) {
					sRet = hours + "시간전";	// TODO: 다국어처리
				} else {
					if(minutes > 0) {
						sRet = minutes + "분전";	// TODO: 다국어처리
					} else {
						if(seconds > 0) {
							sRet = seconds + "초전";	// TODO: 다국어처리
						} else {
							sRet = dtDate.getFullYear() + "." + (dtDate.getMonth() + 1) + "." + dtDate.getDate();	// TODO:
																													// 시간
																													// 포맷
																													// 처리??
						}
					}
				}
	        } else {
	        	sRet = dtDate.getFullYear() + "." + (dtDate.getMonth() + 1) + "." + dtDate.getDate();	// TODO:
																										// 시간
																										// 포맷
																										// 처리??
	        }
		} else if(type.toUpperCase() == "VIEW") {
			sRet = dtDate.getFullYear() + "." + mobile_comm_AddFrontZero(dtDate.getMonth() + 1, 2) + "." + mobile_comm_AddFrontZero(dtDate.getDate(), 2)
			 + " " + mobile_comm_AddFrontZero(dtDate.getHours(), 2) + ":" + mobile_comm_AddFrontZero(dtDate.getMinutes(), 2);	// TODO:
																																// 시간
																																// 포맷
																																// 처리??
		} else {
			sRet = mobile_comm_getDateTimeString(type, dtDate);
		}
	} catch(e) {mobile_comm_log(e);
	}
	
	return sRet;
}

// 날짜시간을 타입별로 변경
// 리스트> 몇초전/몇분전/몇시간전/10.27/2016.12.10 (초있음)
// 상세>
function mobile_comm_getDateTimeString3(type, date) {
	if (date == undefined || date == "") {
        return date;
    }

    if (typeof date == "object") {
    	date = mobile_comm_getDateTimeString("yyyy-MM-dd HH:mm:ss", date);
    } else {
    	date = date.replace(/\./gi, '-');
    }
    
    var nYear = new Number(date.split(" ")[0].split("-")[0]);
    var nMonth = new Number(date.split(" ")[0].split("-")[1]);
    var nDate = new Number(date.split(" ")[0].split("-")[2]);
    var nHour = new Number(date.split(" ")[1].split(":")[0]);
    var nMin = new Number(date.split(" ")[1].split(":")[1]); 
    var nSec = new Number(date.split(" ")[1].split(":")[2]);
    
	var sRet = date;
	var dtDate = null;
	var dtNow = null;
	
	try {
		dtDate = new Date(nYear, nMonth - 1, nDate, nHour, nMin, nSec);
		if(mobile_comm_getBaseConfig("useTimeZone") != "Y"){
			dtNow = new Date();
		} else {
			dtNow = new Date(CFN_GetLocalCurrentDate());	
		}
		
		if(type.toUpperCase() == "LIST") {
			if (dtNow.getFullYear() == dtDate.getFullYear()
                && (dtNow.getMonth() + 1) == (dtDate.getMonth() + 1)
                && dtNow.getDate() == dtDate.getDate()) {
				
				var msecPerMinute = 1000 * 60;
				var msecPerHour =  msecPerMinute * 60;
				
				var interval = dtNow.getTime() - dtDate.getTime();
				
				// Calculate the hours, minutes, and seconds.
				var hours = Math.floor(interval / msecPerHour );
				// interval = interval - (hours * msecPerHour );

				var minutes = Math.floor(interval / msecPerMinute );
				// interval = interval - (minutes * msecPerMinute );

				var seconds = Math.floor(interval / 1000 );
				
				if(hours > 0) {
					sRet = hours + "시간전";	// TODO: 다국어처리
				} else {
					if(minutes > 0) {
						sRet = minutes + "분전";	// TODO: 다국어처리
					} else {
						if(seconds > 0) {
							sRet = seconds + "초전";	// TODO: 다국어처리
						} else {
							sRet = dtDate.getFullYear() + "." + (dtDate.getMonth() + 1) + "." + dtDate.getDate();	// TODO:
																													// 시간
																													// 포맷
																													// 처리??
						}
					}
				}
	        } else {
	        	sRet = dtDate.getFullYear() + "." + (dtDate.getMonth() + 1) + "." + dtDate.getDate();	// TODO:
																										// 시간
																										// 포맷
																										// 처리??
	        }
		} else if(type.toUpperCase() == "VIEW") {
			sRet = dtDate.getFullYear() + "." + mobile_comm_AddFrontZero(dtDate.getMonth() + 1, 2) + "." + mobile_comm_AddFrontZero(dtDate.getDate(), 2)
			 + " " + mobile_comm_AddFrontZero(dtDate.getHours(), 2) + ":" + mobile_comm_AddFrontZero(dtDate.getMinutes(), 2);	// TODO:
																																// 시간
																																// 포맷
																																// 처리??
		} else {
			sRet = mobile_comm_getDateTimeString(type, dtDate);
		}
	} catch(e) {mobile_comm_log(e);
	}
	
	return sRet;
}

//날짜 형식 바꿈
function mobile_comm_ReplaceDate(dateStr) {

    var regexp = /\./g;

    if (typeof dateStr == "string") {
    	if (dateStr.indexOf("-") > -1) {
            regexp = /-/g;
        } else if (dateStr.indexOf(".") > -1) {
            regexp = /\./g;
        } else if (dateStr.indexOf("/") > -1) {
            regexp = /\//g;
        }
        
        return dateStr.replace(regexp, "/");
    } else {
        var tempDate = new Date(dateStr);
        
        dateStr = tempDate.getFullYear() + "/" + (tempDate.getMonth() + 1) + "/" + tempDate.getDate() + " " + mobile_comm_AddFrontZero(tempDate.getHours(), 2) + ":" + mobile_comm_AddFrontZero(tempDate.getMinutes(), 2);
        
        return dateStr;
    }
}


function mobile_comm_random(){
	return window.crypto.getRandomValues(new Uint32Array(1))/4294967296;
}

function mobile_comm_log(e){
	console.log("covision mobile:"+e);
}

function mobile_common_void_reload() {
    location.href = location.href;
}

///////////////////////////////////////////// Common 객체 임시이동
var Common = {};
var g_ErrorMessage = '';
var g_ErrorSeq=0;

// 기타 양식 내 Common 및 XEasy 관련
Common.Error = function(message, title, callback) {
	if (g_ErrorMessage.indexOf(message) == -1) {
	     if (g_ErrorSeq > 0) {
	         g_ErrorMessage += "<strong>"+ g_ErrorSeq +") </strong> " + message + "<br />";
	     } else {
	         g_ErrorMessage += message + "<br />";
	     }
	 } else {
	     g_ErrorMessage += ".";
	 }

	 ++g_ErrorSeq;
	 setTimeout(function () { $.alerts.error(g_ErrorMessage, title, callback); }, 350);
	 setTimeout(function () { g_ErrorMessage = ""; g_ErrorSeq = 0; }, 1000);
};

Common.Warning = function (message, title, callback) {
	setTimeout(function () { $.alerts.warning(message, title, callback); }, 350);
};

// PC 다운로드 모바일 용다운로드로 변경
Common.fileDownLoad = function (pFileID, pFileName, pFileToken) {
	mobile_comm_getFile(pFileID, pFileName, pFileToken);
};


Common.getBaseCode = function(pStrGroupCode) {
	if (pStrGroupCode == undefined || pStrGroupCode == null) return;
	
	var jsonData = {};
	jsonData["key"] = pStrGroupCode;
	
	var returnData = "";
	if (mobile_approvalCache.exist("CODE_"+pStrGroupCode)) {
		returnData = mobile_approvalCache.get("CODE_"+pStrGroupCode);
	} else {
		$.ajax({
			url : "/covicore/common/getbasecode.do",
			data : jsonData,
			type : "post",
			async : false,
			success : function(res) {
				returnData = res.value;
				mobile_approvalCache.set("CODE_"+pStrGroupCode, returnData, "");
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror("/covicore/common/getbasecode.do", response, status, error);
			}
		});
	}
	
	return returnData;
};

Common.getBaseConfig = function(pKey, pDN_ID) {
	return mobile_comm_getBaseConfig(pKey, pDN_ID);
};
Common.getBaseConfigList = function(pConfigArray) {
	return mobile_comm_getBaseConfigList(pConfigArray);
};
Common.getBaseCode = function(pCodeGroup){
	return mobile_comm_getBaseCode(pCodeGroup);
};
Common.getBaseCodeList = function(pCodeArray){
	return mobile_comm_getBaseCodeList(pCodeArray);
};
Common.getDic = function(pStr, pDicType, pLocale) {
	return mobile_comm_getDic(pStr);
};
Common.getDicList = function(pDicArray, pDicType, pLocale){
	return mobile_comm_getDicList(pDicArray, pDicType, pLocale);
};
Common.getDicAll = function(pDicArray, pDicType, pLocale){
	return mobile_comm_getDicAll(pDicArray, pDicType, pLocale);
};
Common.getSession = function(pKey){
	return mobile_comm_getSession(pKey);
};
Common.Progress = function(){
	mobile_comm_showload();
};
Common.AlertClose = function(){
	mobile_comm_hideload();
};

// 표준 날짜 포멧 관련
var _StandardServerDateFormat = "yyyy-MM-dd HH:mm:ss";

var _UR_DateFullFormat = "yyyy-MM-dd HH:mm:ss";
var _UR_DateFormat = "yyyy-MM-dd HH:mm";
var _UR_DateSimpleFormat = "yyyy-MM-dd";

var _ServerDateFullFormat = "yyyy-MM-dd HH:mm:ss";
var _ServerDateFormat = "yyyy-MM-dd HH:mm";
var _ServerDateSimpleFormat = "yyyy-MM-dd";

//////////////////////////////////////////TimeZone Start ////////////////////////////////

//서버시간을 자신의 타임존 시간으로 변환하여 반환함.
//pLocalFormat - 임력하지 않으면 로컬 포멧으로 변환하여 반환함.
function CFN_TransLocalTime(pServerTime, pLocalFormat) {
	var l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS;  // 입력 년월일시분초
	var l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus, l_UR_TimeZone;  // 타임존 시분초 +- 여부
	var l_StringDate, l_StringTime, l_DateFormat = "", l_DateFormatCount;  // 입력 날짜, 입력 시간, 입력날짜 형식, 입력한 값 길이
	var l_ReturnString = "";
	
	if (pServerTime =="" || pServerTime == undefined) return "";
	
	//pServerTime이 Date Object로 넘어올 경우 처리
	if(typeof pServerTime === "object") {
		pServerTime = new Date(pServerTime.time).format("yyyy-MM-dd HH:mm:ss")
	}
	
	l_DateFormatCount = pServerTime.length;
	
	// 1. 날짜(2011-01-04)와 시간(09:12, 08:12:12)이 같이 들어와야 한다.
	if (pServerTime.indexOf(" ") == -1) {
		if (pServerTime.length == 10) {
			pServerTime += " 00:00:00";
		}
		else if (pServerTime.length === 8 && pServerTime.indexOf('-')===-1) {
			pServerTime = pServerTime.substring(0,4)+"-"+pServerTime.substring(4,6)+"-"+pServerTime.substring(6) + " 00:00:00";
		}
		else {
			return pServerTime;
		}
	}
	
	l_StringDate = pServerTime.split(' ')[0];
	l_StringTime = pServerTime.split(' ')[1];
	
	// 2. 날짜 형식은 "-", ".", "/"을 받는다.
	// 입력 포멧 확인
	if (l_StringDate.indexOf(".") > -1) { l_DateFormat = "."; }
	if (l_StringDate.indexOf("-") > -1) { l_DateFormat = "-"; }
	if (l_StringDate.indexOf("/") > -1) { l_DateFormat = "/"; }
	
	if (l_DateFormat == "") {
	   return pServerTime;
	}
	
	l_StringDate = l_StringDate.replace(/-/g, "")
	l_StringDate = l_StringDate.replace(/\./g, "")
	l_StringDate = l_StringDate.replace(/\//g, "")
	l_StringTime = l_StringTime.replace(/:/g, "")
	
	// 3. 시간은 시분까지는 들어와야 한다.(초는 없어도 됨.)
	if (l_StringDate.length != 8 || l_StringTime.length < 4) {
	   return pServerTime;
	}
	
	// 형식에 맞게 숫자를 체워줌
	l_StringTime = CFN_PadRight(l_StringTime, 6, "0");
	
	// 입력받은 일시 분해
	l_InputYear = l_StringDate.substring(0, 4);
	l_InputMonth = l_StringDate.substring(4, 6) - 1; // 월은 1을 빼줘야 함.
	l_InputDay = l_StringDate.substring(6, 8);
	l_InputHH = l_StringTime.substring(0, 2);
	l_InputMM = l_StringTime.substring(2, 4);
	l_InputSS = l_StringTime.substring(4, 6);
	
	// 시간 형식 체크
	var l_InputDate = new Date(l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS);
	if (l_InputDate.getFullYear() != l_InputYear 
		|| l_InputDate.getMonth() != l_InputMonth 
		|| l_InputDate.getDate() != l_InputDay 
		|| l_InputDate.getHours() != l_InputHH 
		|| l_InputDate.getMinutes() != l_InputMM 
		|| l_InputDate.getSeconds() != l_InputSS) {
	   return pServerTime;
	}
	
	// 9999년의 타임존 처리는 패스함(9999년은 대부분 영구를 의미함)
	if(mobile_comm_getBaseConfig("useTimeZone") == "Y" && pServerTime.indexOf('9999') == -1){
		 // 자신의 타임존 시간 가져오기(세션에 정의된 타임존 값을 가져옴.)
		if (typeof _UR_TimeZone == "undefined") {
			l_UR_TimeZone = mobile_comm_getSession("UR_TimeZone");
		}
	 	else {
			l_UR_TimeZone = _UR_TimeZone;
		}
		l_Minus = l_UR_TimeZone.substring(0, 1);
		l_TimeZone = l_UR_TimeZone.replace("-", "").replace(":", "").replace(":", "");
		l_ZoneHH = l_TimeZone.substring(0, 2);
		l_ZoneMM = l_TimeZone.substring(2, 4);
		l_ZoneSS = l_TimeZone.substring(4, 6);
		
		var l_TimeZoneTime = (parseInt(l_ZoneHH, 10) * 3600000) + (parseInt(l_ZoneMM, 10) * 60000) + (parseInt(l_ZoneSS, 10) * 1000)
		
		if (l_Minus == "-") {
			l_InputDate.setTime(l_InputDate.getTime() - l_TimeZoneTime);
		}
		else {
			l_InputDate.setTime(l_InputDate.getTime() + l_TimeZoneTime);
		}
	}    
	
	if (pLocalFormat == undefined || pLocalFormat == "") {
		// 포멧을 지정하지 않을 경우 원래 요청한 (로컬 표준포멧의)형식으로 반환
		pLocalFormat = "yyyy-MM-dd HH:mm:ss".replace(/-/gi, l_DateFormat);
		
		l_ReturnString = pLocalFormat
			.replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
			.replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
			.replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
			.replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
			.replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
			.replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
		l_ReturnString = l_ReturnString.substr(0, l_DateFormatCount);
	}
	else {
		// 사용자가 포멧을 지정하여 요청하면 요청한 데로 반환
		l_ReturnString = pLocalFormat
			.replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
			.replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
			.replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
			.replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
			.replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
			.replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	}
	
	return l_ReturnString;
}

//타임존 시간을 서버시간으로 변환하여 반환함.
//pServerFormat - 임력하지 않으면 서버 포멧으로 변환하여 반환함.
//pUrTimeZone - 사용자 타임존 값으로 입력하지 않으면 세션에서 조회
function CFN_TransServerTime(pLocalTime, pServerFormat, pUrTimeZone) {
	var l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS;  // 입력 년월일시분초
	var l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus, l_UR_TimeZone;  // 타임존 시분초 +- 여부
	var l_StringDate, l_StringTime, l_DateFormat = "", l_DateFormatCount;  // 입력 날짜, 입력 시간, 입력날짜 형식, 입력한 값 길이
	l_DateFormatCount = pLocalTime.length;
	
	//1. 날짜(2011-01-04)와 시간(09:12, 08:12:12)이 같이 들어와야 한다.
	if (pLocalTime.indexOf(" ") == -1) {
		 if (pLocalTime.length == 10) {
		     pLocalTime += " 00:00:00";
		 } else {
		     return pLocalTime;
		 }
	}
	
	// 0000으로 넘어온 값은 빈값으로 치환하여 리턴
	if (pLocalTime.indexOf("0000") > -1) {
		return "";
	}
	
	l_StringDate = pLocalTime.split(' ')[0]
	l_StringTime = pLocalTime.split(' ')[1]
	
	//2. 날짜 형식은 "-", ".", "/"을 받는다.
	//입력 포멧 확인
	if (l_StringDate.indexOf(".") > -1) { l_DateFormat = "."; }
	if (l_StringDate.indexOf("-") > -1) { l_DateFormat = "-"; }
	if (l_StringDate.indexOf("/") > -1) { l_DateFormat = "/"; }
	
	if (l_DateFormat == "") {
	 return pLocalTime;
	}
	l_StringDate = l_StringDate.replace(/-/g, "")
	l_StringDate = l_StringDate.replace(/\./g, "")
	l_StringDate = l_StringDate.replace(/\//g, "")
	l_StringTime = l_StringTime.replace(/:/g, "")
	
	//3. 시간은 시분까지는 들어와야 한다.(초는 없어도 됨.)
	if (l_StringDate.length != 8 || l_StringTime.length < 4) {
	 return pLocalTime;
	}
	
	//형식에 맞게 숫자를 체워줌
	l_StringTime = CFN_PadRight(l_StringTime, 6, "0");
	
	//입력받은 일시 분해
	l_InputYear = l_StringDate.substring(0, 4);
	l_InputMonth = l_StringDate.substring(4, 6) - 1; // 월은 1을 빼줘야 함.
	l_InputDay = l_StringDate.substring(6, 8);
	l_InputHH = l_StringTime.substring(0, 2);
	l_InputMM = l_StringTime.substring(2, 4);
	l_InputSS = l_StringTime.substring(4, 6);
	
	//시간 형식 체크
	var l_InputDate = new Date(l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS);
	if (l_InputDate.getFullYear() != l_InputYear || l_InputDate.getMonth() != l_InputMonth || l_InputDate.getDate() != l_InputDay ||
	 l_InputDate.getHours() != l_InputHH || l_InputDate.getMinutes() != l_InputMM || l_InputDate.getSeconds() != l_InputSS) {
	 return pLocalTime;
	}
	
	// 9999년의 타임존 처리는 패스함(9999년은 대부분 영구를 의미함)
	if(mobile_comm_getBaseConfig("useTimeZone") == "Y" && pLocalTime.indexOf('9999') == -1){
		 // 자신의 타임존 시간 가져오기(세션에 정의된 타임존 값을 가져옴.)
		 if (typeof pUrTimeZone != "undefined"){
			 l_UR_TimeZone = pUrTimeZone
		 }else if (typeof _UR_TimeZone == "undefined") {
		     l_UR_TimeZone = mobile_comm_getSession("UR_TimeZone");
		 } else {
		     l_UR_TimeZone = _UR_TimeZone;
		 }
		 l_Minus = l_UR_TimeZone.substring(0, 1);
		 l_TimeZone = l_UR_TimeZone.replace("-", "").replace(":", "").replace(":", "");
		 l_ZoneHH = l_TimeZone.substring(0, 2);
		 l_ZoneMM = l_TimeZone.substring(2, 4);
		 l_ZoneSS = l_TimeZone.substring(4, 6);
		
		 var l_TimeZoneTime = (parseInt(l_ZoneHH, 10) * 3600000) + (parseInt(l_ZoneMM, 10) * 60000) + (parseInt(l_ZoneSS, 10) * 1000)
		
		 if (l_Minus == "-") {
		     l_InputDate.setTime(l_InputDate.getTime() + l_TimeZoneTime);
		 } else {
		     l_InputDate.setTime(l_InputDate.getTime() - l_TimeZoneTime);
		 }
	}
	
	var l_ReturnString = "";
	
	if (pServerFormat == undefined || pServerFormat == "") {
		// 포멧을 지정하지 않을 경우 원래 요청한 (로컬 표준포멧의)형식으로 반환
		pServerFormat = "yyyy-MM-dd HH:mm:ss".replace(/-/gi, l_DateFormat);
	 
		l_ReturnString = pServerFormat
			.replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
			.replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
			.replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
			.replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
			.replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
			.replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
		l_ReturnString = l_ReturnString.substr(0, l_DateFormatCount);
	} else {	// 사용자가 포멧을 지정하여 요청하면 요청한 데로 반환
		l_ReturnString = pServerFormat
		.replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
		.replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
		.replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
		.replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
		.replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
		.replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	}
	
	return l_ReturnString;
}

//지정한 컨테이너 안의 특정 class를 준 하위 텍스트의 타임죤 처리
function CFN_TransLocalTimeContainer(pContainerID, pTargetClass) {
	$("#" + pContainerID).each(function () {
	   $(this).find("." + pTargetClass).each(function () {
	       $(this).text(CFN_TransLocalTime($(this).text()))
	       $(this).removeClass(pTargetClass);
	   });
	});
}

//오늘 날짜에 해당하는 Local시간 문자열을 리턴
function CFN_GetLocalCurrentDate(pLocalFormat) {
	 var l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus;
    var toTime = new Date();
    var hour = toTime.getTimezoneOffset() / 60;

    // GMT(그리니치 표준시) 런던(GMT + 0) 시간 구하기
    var calGmtHour = toTime.setHours(toTime.getHours() + hour);
    var calGmt = new Date();

	if(Common.getBaseConfig("useTimeZone") == "Y"){
		calGmt = new Date(calGmtHour);
	    var l_StandardTimeZoneValue = Common.getBaseConfig("StandardTimeZoneValue"); // 서버시간과 표준시(GMT)와의 차이 값
	    l_Minus = l_StandardTimeZoneValue.substring(0, 1);
	    l_TimeZone = l_StandardTimeZoneValue.replace("-", "").replace(":", "").replace(":", "");
	    l_ZoneHH = l_TimeZone.substring(0, 2);
	    l_ZoneMM = l_TimeZone.substring(2, 4);
	    l_ZoneSS = l_TimeZone.substring(4, 6);
	
	    var l_TimeZoneTime = (parseInt(l_ZoneHH, 10) * 3600000) + (parseInt(l_ZoneMM, 10) * 60000) + (parseInt(l_ZoneSS, 10) * 1000)
	
	    if (l_Minus == "-") {
	        calGmt.setTime(calGmt.getTime() + l_TimeZoneTime);
	    } else {
	        calGmt.setTime(calGmt.getTime() - l_TimeZoneTime);
	    }
	} 

    var strServerTime = calGmt.getFullYear() + '-' + CFN_PadLeft(calGmt.getMonth() + 1, 2, "0") + '-' + CFN_PadLeft(calGmt.getDate(), 2, "0") + ' '
        + CFN_PadLeft(calGmt.getHours(), 2, "0") + ':' + CFN_PadLeft(calGmt.getMinutes(), 2, "0") + ':' + CFN_PadLeft(calGmt.getSeconds(), 2, "0");

	return CFN_TransLocalTime(strServerTime, pLocalFormat);
}

//////////////////////////////////////////TimeZone  End ////////////////////////////////

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
    var l_strServerDateFormat = "";
    var l_strLocalFormat = "";
    var l_strCheckDate = "";
    
    l_strServerDateFormat = (typeof _ServerDateSimpleFormat == "undefined") ? mobile_comm_getBaseConfig("ServerDateSimpleFormat") : _ServerDateSimpleFormat;
	l_strLocalFormat = (typeof _CalenderDateFormat == "undefined") ? mobile_comm_getBaseConfig("CalenderDateFormat") : _CalenderDateFormat;

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
  
  date = date.getDate();

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
  
  date = date.getDate();

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
    var l_strServerDateFormat = "";
    var l_strCheckDate = "";
    l_strServerDateFormat = (typeof _ServerDateSimpleFormat == "undefined") ? mobile_comm_getBaseConfig("ServerDateSimpleFormat") : _ServerDateSimpleFormat;
    pLocalFormat = (pLocalFormat == undefined || pLocalFormat == "") ? mobile_comm_getBaseConfig("CalenderDateFormat") : _CalenderDateFormat;

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



//------------------------------------------------------------------ 문자열 -------------------------------------------------------------
//왼쪽에 특정문자를 채워 반환
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

//오른쪽에 특정문자를 채워 반환
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

//문자열 바이트로 잘라 내기
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

//문자열 잘라내기
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

//문자의 길이 바이트 체크
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

//입력 문자 수자 인지 체크
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


//GMT+0를 GMT+9로 강제변경
//pServerTime - GMT0시간
//pLocalFormat - 임력하지 않으면 로컬 포멧으로 변환하여 반환함.
//pUrTimeZone - 사용자 타임존 값으로 입력하지 않으면 세션에서 조회
function CFN_TransLocalTime4GMT9(pServerTime, pLocalFormat) {
	var l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS;  // 입력 년월일시분초
	var l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus, l_UR_TimeZone;  // 타임존 시분초 +- 여부
	var l_StringDate, l_StringTime, l_DateFormat = "", l_DateFormatCount;  // 입력 날짜, 입력 시간, 입력날짜 형식, 입력한 값 길이
	l_DateFormatCount = pServerTime.length;
	
	// 1. 날짜(2011-01-04)와 시간(09:12, 08:12:12)이 같이 들어와야 한다.
	if (pServerTime.indexOf(" ") == -1) {
	   if (pServerTime.length == 10) {
	       pServerTime += " 00:00:00";
	   } else {
	       return pServerTime;
	   }
	}
	
	l_StringDate = pServerTime.split(' ')[0]
	l_StringTime = pServerTime.split(' ')[1]
	
	// 2. 날짜 형식은 "-", ".", "/"을 받는다.
	// 입력 포멧 확인
	if (l_StringDate.indexOf(".") > -1) { l_DateFormat = "."; }
	if (l_StringDate.indexOf("-") > -1) { l_DateFormat = "-"; }
	if (l_StringDate.indexOf("/") > -1) { l_DateFormat = "/"; }
	
	if (l_DateFormat == "") {
	   return pServerTime;
	}
	l_StringDate = l_StringDate.replace(/-/g, "")
	l_StringDate = l_StringDate.replace(/\./g, "")
	l_StringDate = l_StringDate.replace(/\//g, "")
	l_StringTime = l_StringTime.replace(/:/g, "")
	
	// 3. 시간은 시분까지는 들어와야 한다.(초는 없어도 됨.)
	if (l_StringDate.length != 8 || l_StringTime.length < 4) {
	   return pServerTime;
	}
	
	// 형식에 맞게 숫자를 체워줌
	l_StringTime = CFN_PadRight(l_StringTime, 6, "0");
	
	// 입력받은 일시 분해
	l_InputYear = l_StringDate.substring(0, 4);
	l_InputMonth = l_StringDate.substring(4, 6) - 1; // 월은 1을 빼줘야 함.
	l_InputDay = l_StringDate.substring(6, 8);
	l_InputHH = l_StringTime.substring(0, 2);
	l_InputMM = l_StringTime.substring(2, 4);
	l_InputSS = l_StringTime.substring(4, 6);
	
	// 시간 형식 체크
	var l_InputDate = new Date(l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS);
	if (l_InputDate.getFullYear() != l_InputYear || l_InputDate.getMonth() != l_InputMonth || l_InputDate.getDate() != l_InputDay ||
	   l_InputDate.getHours() != l_InputHH || l_InputDate.getMinutes() != l_InputMM || l_InputDate.getSeconds() != l_InputSS) {
	   return pServerTime;
	}
	
	//자신의 타임존 시간 가져오기(세션에 정의된 타임존 값을 가져옴.)
	if (typeof _UR_TimeZone == "undefined") {
	     l_UR_TimeZone = mobile_comm_getSession("UR_TimeZone");
	} else {
	     l_UR_TimeZone = _UR_TimeZone;
	}
	l_Minus = l_UR_TimeZone.substring(0, 1);
	l_TimeZone = l_UR_TimeZone.replace("-", "").replace(":", "").replace(":", "");
	l_ZoneHH = l_TimeZone.substring(0, 2);
	l_ZoneMM = l_TimeZone.substring(2, 4);
	l_ZoneSS = l_TimeZone.substring(4, 6);
	
	var l_TimeZoneTime = (parseInt(l_ZoneHH, 10) * 3600000) + (parseInt(l_ZoneMM, 10) * 60000) + (parseInt(l_ZoneSS, 10) * 1000)
	
	if (l_Minus == "-") {
	     l_InputDate.setTime(l_InputDate.getTime() - l_TimeZoneTime);
	} else {
	     l_InputDate.setTime(l_InputDate.getTime() + l_TimeZoneTime);
	}

	var l_ReturnString = "";
	
	if (pLocalFormat == undefined || pLocalFormat == "") {
		// 포멧을 지정하지 않을 경우 원래 요청한 (로컬 표준포멧의)형식으로 반환
		pLocalFormat = "yyyy-MM-dd HH:mm:ss".replace(/-/gi, l_DateFormat);
		
		l_ReturnString = pLocalFormat
			.replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
			.replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
			.replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
			.replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
			.replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
			.replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
		l_ReturnString = l_ReturnString.substr(0, l_DateFormatCount);
	}
	else // 사용자가 포멧을 지정하여 요청하면 요청한 데로 반환
	{
		l_ReturnString = pLocalFormat
			.replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
			.replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
			.replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
			.replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
			.replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
			.replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	}
	
	return l_ReturnString;
}

//ko(0)-한국어, en(1)-영어, ja(2)-일본어, zh(3)-중국어, e1(4)-추가 언어1, e2(5)-추가 언어2, e3(6)-추가 언어3, e4(7)-추가 언어4, e5(8)-추가 언어5, e6(9)-추가 언어6
var _LanguageIndex = { "ko": 0, "en": 1, "ja": 2, "zh": 3, "e1": 4, "e2": 5, "e3": 6, "e4": 7, "e5": 8, "e6": 9 }; // 다국어 인덱스 값

// 특정 언어로 입력된 정보를 보여주기(';'로 구분된 다국어 정보)
function CFN_GetDicInfo(pStringInfo, pLanguageCode) {
	var l_Return = "";
	try{
		if (pStringInfo == undefined) {
			pStringInfo = "undefined";
		}
		if (pLanguageCode == undefined) {
			if (typeof _LanguageCode == "undefined") {
				pLanguageCode = mobile_comm_getSession("lang");
			} else {
				pLanguageCode = _LanguageCode;
			}
		}

		var l_ArrInfo = pStringInfo.split(';');

		//배열에 없는 값인지 체크
		if (_LanguageIndex[pLanguageCode] <= l_ArrInfo.length) {
			l_Return = l_ArrInfo[_LanguageIndex[pLanguageCode]];
		}
		if(l_Return == undefined || l_Return == ""){
			l_Return = l_ArrInfo[0];
		}
		return l_Return;
	}catch(e){mobile_comm_log(e);
	}finally{
		l_Return = null;
	}
}

//받은 입력값 특수문자 변환 처리2
function XFN_ChangeOutputValue(pValue) {
    var strReturenValue = "";
    strReturenValue = pValue.replace(/&amp;/gi, '&').replace(/&lt;/gi, '<').replace(/&gt;/gi, '>').replace(/&quot;/gi, '"').replace(/&apos;/gi, '\'').replace(/&nbsp;/gi, ' ');
    return strReturenValue;
}

String.format = function() {
    // The string containing the format items (e.g. "{0}")
    // will and always has to be the first argument.
	var theString = arguments[0];
	
	// start with the second argument (i = 1)
	for (var i = 1; i < arguments.length; i++) {
		// "gm" = RegEx options for Global search (more than one instance)
		var regEx = new RegExp("\\{" + (i - 1) + "\\}", "gm");
		theString = theString.replace(regEx, arguments[i]);
    }
	return theString;
};

$.ajaxSetup({
    beforeSend: function (xhr, opts){
  	   try{
	       if (PARAM_VALID=="Y" && opts.type=="POST" && opts.data != undefined ){
				var objString = "";
				var tmpProto = Object.getPrototypeOf(opts.data);
				var keys = "";
				var vals = "";
		    	var params = opts.data;
		    
				if (tmpProto == Object.getPrototypeOf(new FormData())){
/*			    	for (var pair of params.entries()) {
			    		if (pair[1].toString() != '[object File]' && !(pair[0]  == 'false' && pair[1].toString() == '[object Object]')){
			        		vals += pair[0]+"||"+coviSec.getHeader(pair[1],"SHA256")+"††";
			    		}	
			    	}*/
				}else if(tmpProto == Object.getPrototypeOf({})){
			    	for (var key in params) {

			    		if (params.hasOwnProperty(key)){
			        		vals += key+"||"+coviSec.getHeader(params[key],"SHA256")+"††";
			    		}	
			    	}		
				}else {
					if (opts.contentType.indexOf("application/json")>-1){
						vals =coviSec.getHeader(params,"SHA256");
					}else{
						if (params.indexOf("EXCLUDE_VALD") > -1 || params == "" || params == "{}") return;
		
						var ajaxParams = params.split("&");
						
						for(var i=0; i < ajaxParams.length; i++){
							var tmp = ajaxParams[i].split("=");
							
							if (tmp.length>0 && tmp[0]!= ""){
				        		vals += tmp[0]+"||"+coviSec.getHeader(decodeURIComponent(tmp[1]),"SHA256")+"††";
							}
						}
					}	
				}
				if (vals.length>0){
			    	xhr.setRequestHeader('CSA_SM',"" +  coviSec.getHeader(vals, "K"));
				}	
	       }
	   }catch(e){
		   mobile_comm_log(e);
	   }
    }   
})

//Base64
var Base64 = {
	utf8_to_b64 : function ( str ) {
		return window.btoa(unescape(encodeURIComponent( str )));
	},
	b64_to_utf8 : function ( str ) {
		return decodeURIComponent(escape(window.atob( str )));
	}
}

function mobile_comm_getS3Properties(pKey) {
	var returnData = "";

	if (mobile_globalCache[pKey] != undefined) {
		returnData = mobile_globalCache[pKey];
	} else {
		if (pKey != undefined && pKey != "") {
			$.ajax({
				url: "/covicore/helper/getS3properties.do", // [2016-06-09] 박경연. approval에서 접근할 때 문제가 있음
				data: {
					"key": pKey
				},
				type: "post",
				async: false,
				success: function (res) {
					if (res.status == "SUCCESS") {
						returnData = res.value;
						mobile_globalCache[pKey] = returnData;
					}
					else {
						returnData = undefined;
						//localCache.set(pKey, returnData, "");
					}
				},
				error: function (response, status, error) {
					mobile_comm_ajaxerror("helper/getS3properties.do", response, status, error);
					//				alert($.parseJSON(response.responseText).Message);
				}
			});
		}
	}
	return returnData;
}

var AwsS3 = {
	isActive: function(){
		var s3AP_URL_val = mobile_comm_getGlobalProperties("s3.ap.url");
		if(s3AP_URL_val!=null && s3AP_URL_val!=""){
			var arrS3APurl = s3AP_URL_val.split(".");
			if(arrS3APurl.length==5) {
				var isActive = mobile_comm_getS3Properties(mobile_comm_getSession("DN_Code"));
				if (isActive != null && isActive === "Y") {
					return true;
				}
			}
		}
		return false;
	},
	getS3ApUrl: function (){
		return "/covicore/common/photo/photo.do?img=";
	}
}

//페이지 이동 - MP 메일 연동
function mobile_comm_mailopen(url) {
	// 메일 서비스 URL
	var mailSvcUrl = mobile_comm_getBaseConfig("Exch_mailSvcUrl");
	// 메일 SLO 기초 설정
	var MailServerSLOUrl = mobile_comm_getBaseConfig("Exch_MailServerSLOUrl");
	
	if(mobile_comm_isiOSApp()) { // 아이폰 이동
		url = mailSvcUrl + url;
		window.webkit.messageHandlers.callbackHandler.postMessage({ type:"loadWebview", url:url});
	} else if (mobile_comm_isAndroidApp()) { // 안드로이드 이동
		url = mailSvcUrl + url;
		window.covimoapp.loadWebView(url);
	} else { // 모바일 웹 이동(JWT토큰 인증)
		var result = GetEncryptToken();
		url = encodeURIComponent(url);
		url = '?ReturnUrl='+url;
		url = mailSvcUrl + MailServerSLOUrl + url + "&token="+result;
		mobile_comm_go(url);
	}
}


/*
	Subject : Token 발급 
	Method : GetEncryptToken
	jwt 토큰 발급 common/jwtToken.do 호출
*/
function GetEncryptToken() {
	var token;
		$.ajax({
			type: "GET",
			async: false,
			url: "/covicore/common/jwtToken.do",
			success: function(data) {
				token = data.JWTtoken;
			}
		}); 
	return token;
}

/*function mobile_comm_imgError(image, isProf) {
    image.onerror = "";
    if (isProf == true){
	    image.src = "/covicore/resources/images/no_profile.png";
    }
    else{
	    image.src = "/covicore/resources/images/no_image.jpg";
    }    
    return true;
}
*/

String.prototype.left = function(length){
	return (this.length <= length) ? this : this.substring(0, length);
}

String.prototype.right = function(length){
	return (this.length <= length) ? this : this.substring(this.length - length, this.length);
}

var backStoragePath = null;
var sessionDnCode = null;
function mobile_comm_replaceInlinePhotoMig(html) {
	try{
		if(this.backStoragePath == null){
			this.backStoragePath = mobile_comm_getBaseConfig("BackStorage");
		}
		if(this.sessionDnCode == null){
			this.sessionDnCode = mobile_comm_getSession("DN_Code");
		}
		let _backStoragePath = this.backStoragePath.replace("{0}", this.sessionDnCode);
		let domain = document.domain;
		let regexp = new RegExp(domain + "/gwstorage/", "gi");
		let replacedHtml = html.replace(regexp, domain+"/covicore/common/photo/photo.do?img="+_backStoragePath);
		
		return replacedHtml;
	}catch(e){
		return html;
	}
}