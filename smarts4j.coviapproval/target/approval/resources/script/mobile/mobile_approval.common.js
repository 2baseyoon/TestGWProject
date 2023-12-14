/**
 * 
 * 전자결재 모바일 공통 js 파일
 * 공통 이벤트 바인딩
 * 
 */

Common.getSecurityProperties = function (pKey){
	return mobile_comm_getSecurityProperties(pKey);
};
Common.getBaseCodeDic = function (pStrGroupCode, code){
	return mobile_comm_getBaseCodeDic(pStrGroupCode, code);
};
Common.Inform = function (message, title, callback) {
	if (!alert(message)) { if (callback) callback(true); }
};
Common.Confirm = function (message, title, callback) {
	if (confirm(message)) { if (callback) callback(true); }
};
Common.Warning = function (message, title, callback) {
	if (!alert(message)) { if (callback) callback(true); }
};
var g_ErrorMessage = "";
var g_ErrorSeq = 0;
Common.Error = function (message, title, callback) {
	if (g_ErrorMessage.indexOf(message) == -1) {
		if (g_ErrorSeq > 0) {
			g_ErrorMessage += "<strong>"+ g_ErrorSeq +") </strong> " + message + "\n";
		} else {
			g_ErrorMessage += message + "\n";
		}
	} else {
		g_ErrorMessage += ".";
	}
	
	++g_ErrorSeq;
	setTimeout(function () { if (!alert(g_ErrorMessage)) { if (callback) callback(true); } }, 350);
	setTimeout(function () { g_ErrorMessage = ""; g_ErrorSeq = 0; }, 1000);
}