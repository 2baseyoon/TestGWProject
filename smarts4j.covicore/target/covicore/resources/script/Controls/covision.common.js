/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2017.06.19</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///공통 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/

/*var licVariables = {
		dictionary : { 
				nolic : 'The license expires. Please contact the administrator.',
				lictemp : 'Temporary license is in use. Please contact your administrator.'
		}
};*/





$.ajaxSetup({
    beforeSend: function (xhr, opts){
    	if(!opts.disableProgress){
	    	var pLeft = "200px";
	    	if(CFN_GetQueryString("CFN_OpenWindowName") != "undefined" || CFN_GetQueryString("CFN_OpenLayerName") != "undefined") pLeft = "0px"; // 팝업일경우 progress 중앙정렬
	    	if ($(".divpop_overlay").size() == 0 ){
		        var overlay = $('<div id="dupe_overlay" class="divpop_overlay" style="position:fixed;z-index:100;top:0px;left:0px;width:100%;height:100%;opacity:0.4;">'+
		        		'<div style="width: 100%; height: 100%;display: table;"><span style="display: table-cell;text-align: center;vertical-align: middle;padding-left: ' + pLeft + '">'+
		    			'<img src="/covicore/resources/images/covision/loding16.gif" style="background: white;padding: 1em;border-radius: .7em;border: 1px solid #888;">'+
		    			'</span></div>'+
		    			'	</div>');
		        overlay.appendTo(document.body);
	    	}    
	    	$(".divpop_overlay").show();
    	}
        xhr.setRequestHeader("AJAX","true");
 	   	try{
 	   		if (typeof PARAM_VALID != "undefined" && PARAM_VALID=="Y" && opts.type=="POST" && opts.data != undefined ){
				var objString = "";
				var tmpProto = Object.getPrototypeOf(opts.data);
				var keys = "";
				var vals = "";
		    	var params = opts.data;
		    
				if (tmpProto == Object.getPrototypeOf(new FormData())){
/*		        	for (var  pair of params.entries()) {
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
		   coviCmn.traceLog(e);
	   }	
    },
    complete : function(xhr){
    	$(".divpop_overlay").hide();
    	/*var pathname = window.location.pathname;
    		
    	if(pathname.match("/covicore/login")=='/covicore/login'){
    		
			if(xhr.getResponseHeader('COVI_LICENSE_STATUS') == 'LX_LICENSE'){
				
			}else if(xhr.getResponseHeader('COVI_LICENSE_STATUS') == 'EX_LICENSE' && coviCmn.getCookie("LICALERT") == ""){
				coviCmn.setCookieByMin("LICALERT", "true", 60);
				alert(licVariables.dictionary.lictemp);
			}else if((xhr.getResponseHeader('COVI_LICENSE_STATUS') == 'NO_LICENSE'||xhr.getResponseHeader('COVI_LICENSE_STATUS') == 'NOT_VALID_DOMAIN') 
					&& coviCmn.getCookie("LICALERT") == ""){
				coviCmn.setCookieByMin("LICALERT", "true", 1); 
				alert(licVariables.dictionary.nolic);
				coviCmn.clearLocalCache();
				location.href = "/covicore/logout.do";
			}
		}else{
			//만료 알림 여부 확인
			if(xhr.getResponseHeader('COVI_LICENSE_STATUS') == 'EX_LICENSE' && coviCmn.getCookie("LICALERT") == ""){
				coviCmn.setCookieByMin("LICALERT", "true", 60); 	
				alert(licVariables.dictionary.lictemp);
			} else if((xhr.getResponseHeader('COVI_LICENSE_STATUS') == 'NO_LICENSE'||xhr.getResponseHeader('COVI_LICENSE_STATUS') == 'NOT_VALID_DOMAIN') 
					&& coviCmn.getCookie("LICALERT") == ""){
				coviCmn.setCookieByMin("LICALERT", "true", 1); 
				alert(licVariables.dictionary.nolic);
				coviCmn.clearLocalCache();
				location.href = "/covicore/logout.do";
			}
		}*/
    	
    	
    }
});

// .html로 js로드시(메뉴틀릭) 캐싱되도록 수정
$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
	if ( options.dataType == 'script' || originalOptions.dataType == 'script' ) {
		options.cache = true;
	}
});

if (!window.coviCmn) {
    window.coviCmn = {};
}

(function(window) {
	
	var coviCmn = {
			codeMap : {},
			configMap : {},
			commonVariables : {
				frontPath : '/FrontStorage/'
			},
			timeZoneInfos : [{"id":"Africa\/Abidjan","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Accra","name":"가나 표준시","offset":"+00:00"},{"id":"Africa\/Addis_Ababa","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Africa\/Algiers","name":"중앙 유럽 시간","offset":"+00:00"},{"id":"Africa\/Asmara","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Africa\/Asmera","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Africa\/Bamako","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Bangui","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Banjul","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Bissau","name":"그리니치 표준시","offset":"-01:00"},{"id":"Africa\/Blantyre","name":"중앙 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Brazzaville","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Bujumbura","name":"중앙 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Cairo","name":"동유럽 시간","offset":"+02:00"},{"id":"Africa\/Casablanca","name":"서유럽 시간","offset":"+00:00"},{"id":"Africa\/Ceuta","name":"중앙 유럽 시간","offset":"+00:00"},{"id":"Africa\/Conakry","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Dakar","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Dar_es_Salaam","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Africa\/Djibouti","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Africa\/Douala","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/El_Aaiun","name":"서유럽 시간","offset":"-01:00"},{"id":"Africa\/Freetown","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Gaborone","name":"중앙 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Harare","name":"중앙 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Johannesburg","name":"남아프리카 표준시","offset":"+02:00"},{"id":"Africa\/Juba","name":"동부 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Kampala","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Africa\/Khartoum","name":"동부 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Kigali","name":"중앙 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Kinshasa","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Lagos","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Libreville","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Lome","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Luanda","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Lubumbashi","name":"중앙 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Lusaka","name":"중앙 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Malabo","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Maputo","name":"중앙 아프리카 시간","offset":"+02:00"},{"id":"Africa\/Maseru","name":"남아프리카 표준시","offset":"+02:00"},{"id":"Africa\/Mbabane","name":"남아프리카 표준시","offset":"+02:00"},{"id":"Africa\/Mogadishu","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Africa\/Monrovia","name":"그리니치 표준시","offset":"-00:44"},{"id":"Africa\/Nairobi","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Africa\/Ndjamena","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Niamey","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Nouakchott","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Ouagadougou","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Porto-Novo","name":"서부 아프리카 시간","offset":"+01:00"},{"id":"Africa\/Sao_Tome","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Timbuktu","name":"그리니치 표준시","offset":"+00:00"},{"id":"Africa\/Tripoli","name":"동유럽 시간","offset":"+02:00"},{"id":"Africa\/Tunis","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Africa\/Windhoek","name":"서부 아프리카 시간","offset":"+02:00"},{"id":"America\/Adak","name":"하와이 알류샨 표준시","offset":"-11:00"},{"id":"America\/Anchorage","name":"알래스카 표준시","offset":"-10:00"},{"id":"America\/Anguilla","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Antigua","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Araguaina","name":"브라질리아 시간","offset":"-03:00"},{"id":"America\/Argentina\/Buenos_Aires","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/Catamarca","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/ComodRivadavia","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/Cordoba","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/Jujuy","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/La_Rioja","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/Mendoza","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/Rio_Gallegos","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/Salta","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/San_Juan","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/San_Luis","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/Tucuman","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Argentina\/Ushuaia","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Aruba","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Asuncion","name":"파라과이 시간","offset":"-04:00"},{"id":"America\/Atikokan","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Atka","name":"하와이 알류샨 표준시","offset":"-11:00"},{"id":"America\/Bahia","name":"브라질리아 시간","offset":"-03:00"},{"id":"America\/Bahia_Banderas","name":"중부 표준시","offset":"-08:00"},{"id":"America\/Barbados","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Belem","name":"브라질리아 시간","offset":"-03:00"},{"id":"America\/Belize","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Blanc-Sablon","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Boa_Vista","name":"아마존 시간","offset":"-04:00"},{"id":"America\/Bogota","name":"콜롬비아 시간","offset":"-05:00"},{"id":"America\/Boise","name":"산지 표준시","offset":"-07:00"},{"id":"America\/Buenos_Aires","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Cambridge_Bay","name":"산지 표준시","offset":"-07:00"},{"id":"America\/Campo_Grande","name":"아마존 시간","offset":"-04:00"},{"id":"America\/Cancun","name":"동부 표준시","offset":"-06:00"},{"id":"America\/Caracas","name":"베네수엘라 시간","offset":"-04:00"},{"id":"America\/Catamarca","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Cayenne","name":"프랑스령 기아나 시간","offset":"-03:00"},{"id":"America\/Cayman","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Chicago","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Chihuahua","name":"산지 표준시","offset":"-06:00"},{"id":"America\/Coral_Harbour","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Cordoba","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Costa_Rica","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Creston","name":"산지 표준시","offset":"-07:00"},{"id":"America\/Cuiaba","name":"아마존 시간","offset":"-04:00"},{"id":"America\/Curacao","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Danmarkshavn","name":"그리니치 표준시","offset":"-03:00"},{"id":"America\/Dawson","name":"태평양 표준시","offset":"-09:00"},{"id":"America\/Dawson_Creek","name":"산지 표준시","offset":"-08:00"},{"id":"America\/Denver","name":"산지 표준시","offset":"-07:00"},{"id":"America\/Detroit","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Dominica","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Edmonton","name":"산지 표준시","offset":"-07:00"},{"id":"America\/Eirunepe","name":"에이커 시간","offset":"-05:00"},{"id":"America\/El_Salvador","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Ensenada","name":"태평양 표준시","offset":"-08:00"},{"id":"America\/Fort_Nelson","name":"그리니치 표준시","offset":"-08:00"},{"id":"America\/Fort_Wayne","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Fortaleza","name":"브라질리아 시간","offset":"-03:00"},{"id":"America\/Glace_Bay","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Godthab","name":"서부 그린랜드 시간","offset":"-03:00"},{"id":"America\/Goose_Bay","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Grand_Turk","name":"대서양 표준시","offset":"-05:00"},{"id":"America\/Grenada","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Guadeloupe","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Guatemala","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Guayaquil","name":"에쿠아도르 시간","offset":"-05:00"},{"id":"America\/Guyana","name":"가이아나 시간","offset":"-03:45"},{"id":"America\/Halifax","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Havana","name":"쿠바 표준시","offset":"-05:00"},{"id":"America\/Hermosillo","name":"산지 표준시","offset":"-08:00"},{"id":"America\/Indiana\/Indianapolis","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Indiana\/Knox","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Indiana\/Marengo","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Indiana\/Petersburg","name":"동부 표준시","offset":"-06:00"},{"id":"America\/Indiana\/Tell_City","name":"중부 표준시","offset":"-05:00"},{"id":"America\/Indiana\/Vevay","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Indiana\/Vincennes","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Indiana\/Winamac","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Indianapolis","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Inuvik","name":"산지 표준시","offset":"-08:00"},{"id":"America\/Iqaluit","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Jamaica","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Jujuy","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Juneau","name":"알래스카 표준시","offset":"-08:00"},{"id":"America\/Kentucky\/Louisville","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Kentucky\/Monticello","name":"동부 표준시","offset":"-06:00"},{"id":"America\/Knox_IN","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Kralendijk","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/La_Paz","name":"볼리비아 시간","offset":"-04:00"},{"id":"America\/Lima","name":"페루 시간","offset":"-05:00"},{"id":"America\/Los_Angeles","name":"태평양 표준시","offset":"-08:00"},{"id":"America\/Louisville","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Lower_Princes","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Maceio","name":"브라질리아 시간","offset":"-03:00"},{"id":"America\/Managua","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Manaus","name":"아마존 시간","offset":"-04:00"},{"id":"America\/Marigot","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Martinique","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Matamoros","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Mazatlan","name":"산지 표준시","offset":"-08:00"},{"id":"America\/Mendoza","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Menominee","name":"중부 표준시","offset":"-05:00"},{"id":"America\/Merida","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Metlakatla","name":"태평양 표준시","offset":"-08:00"},{"id":"America\/Mexico_City","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Miquelon","name":"피에르 미크론 표준시","offset":"-04:00"},{"id":"America\/Moncton","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Monterrey","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Montevideo","name":"우루과이 시간","offset":"-03:00"},{"id":"America\/Montreal","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Montserrat","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Nassau","name":"동부 표준시","offset":"-05:00"},{"id":"America\/New_York","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Nipigon","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Nome","name":"알래스카 표준시","offset":"-11:00"},{"id":"America\/Noronha","name":"Fernando de Noronha 시간","offset":"-02:00"},{"id":"America\/North_Dakota\/Beulah","name":"중부 표준시","offset":"-07:00"},{"id":"America\/North_Dakota\/Center","name":"중부 표준시","offset":"-07:00"},{"id":"America\/North_Dakota\/New_Salem","name":"중부 표준시","offset":"-07:00"},{"id":"America\/Ojinaga","name":"산지 표준시","offset":"-06:00"},{"id":"America\/Panama","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Pangnirtung","name":"동부 표준시","offset":"-04:00"},{"id":"America\/Paramaribo","name":"수리남 시간","offset":"-03:30"},{"id":"America\/Phoenix","name":"산지 표준시","offset":"-07:00"},{"id":"America\/Port-au-Prince","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Port_of_Spain","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Porto_Acre","name":"에이커 시간","offset":"-05:00"},{"id":"America\/Porto_Velho","name":"아마존 시간","offset":"-04:00"},{"id":"America\/Puerto_Rico","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Rainy_River","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Rankin_Inlet","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Recife","name":"브라질리아 시간","offset":"-03:00"},{"id":"America\/Regina","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Resolute","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Rio_Branco","name":"에이커 시간","offset":"-05:00"},{"id":"America\/Rosario","name":"아르헨티나 시간","offset":"-03:00"},{"id":"America\/Santa_Isabel","name":"태평양 표준시","offset":"-08:00"},{"id":"America\/Santarem","name":"브라질리아 시간","offset":"-04:00"},{"id":"America\/Santiago","name":"칠레 시간","offset":"-03:00"},{"id":"America\/Santo_Domingo","name":"대서양 표준시","offset":"-04:30"},{"id":"America\/Sao_Paulo","name":"브라질리아 시간","offset":"-03:00"},{"id":"America\/Scoresbysund","name":"동부 그린랜드 시간","offset":"-02:00"},{"id":"America\/Shiprock","name":"산지 표준시","offset":"-07:00"},{"id":"America\/Sitka","name":"알래스카 표준시","offset":"-08:00"},{"id":"America\/St_Barthelemy","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/St_Johns","name":"뉴펀들랜드 표준시","offset":"-03:30"},{"id":"America\/St_Kitts","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/St_Lucia","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/St_Thomas","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/St_Vincent","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Swift_Current","name":"중부 표준시","offset":"-07:00"},{"id":"America\/Tegucigalpa","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Thule","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Thunder_Bay","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Tijuana","name":"태평양 표준시","offset":"-08:00"},{"id":"America\/Toronto","name":"동부 표준시","offset":"-05:00"},{"id":"America\/Tortola","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Vancouver","name":"태평양 표준시","offset":"-08:00"},{"id":"America\/Virgin","name":"대서양 표준시","offset":"-04:00"},{"id":"America\/Whitehorse","name":"태평양 표준시","offset":"-08:00"},{"id":"America\/Winnipeg","name":"중부 표준시","offset":"-06:00"},{"id":"America\/Yakutat","name":"알래스카 표준시","offset":"-09:00"},{"id":"America\/Yellowknife","name":"산지 표준시","offset":"-07:00"},{"id":"Antarctica\/Casey","name":"서부 표준시(오스트레일리아)","offset":"+08:00"},{"id":"Antarctica\/Davis","name":"Davis 시간","offset":"+07:00"},{"id":"Antarctica\/DumontDUrville","name":"뒤몽 뒤르빌 시간","offset":"+10:00"},{"id":"Antarctica\/Macquarie","name":"매콰리 섬 표준시","offset":"+11:00"},{"id":"Antarctica\/Mawson","name":"모슨 시간","offset":"+06:00"},{"id":"Antarctica\/McMurdo","name":"뉴질랜드 표준시","offset":"+12:00"},{"id":"Antarctica\/Palmer","name":"칠레 시간","offset":"-03:00"},{"id":"Antarctica\/Rothera","name":"로제라 표준시","offset":"+00:00"},{"id":"Antarctica\/South_Pole","name":"뉴질랜드 표준시","offset":"+12:00"},{"id":"Antarctica\/Syowa","name":"Syowa 시간","offset":"+03:00"},{"id":"Antarctica\/Troll","name":"세계 표준시","offset":"+00:00"},{"id":"Antarctica\/Vostok","name":"Vostok 시간","offset":"+06:00"},{"id":"Arctic\/Longyearbyen","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Asia\/Aden","name":"아랍 표준시","offset":"+03:00"},{"id":"Asia\/Almaty","name":"알마아타 시간","offset":"+06:00"},{"id":"Asia\/Amman","name":"동유럽 시간","offset":"+02:00"},{"id":"Asia\/Anadyr","name":"아나디르 시간","offset":"+13:00"},{"id":"Asia\/Aqtau","name":"악타우 시간","offset":"+05:00"},{"id":"Asia\/Aqtobe","name":"악토브 시간","offset":"+05:00"},{"id":"Asia\/Ashgabat","name":"투르크메니스탄 시간","offset":"+05:00"},{"id":"Asia\/Ashkhabad","name":"투르크메니스탄 시간","offset":"+05:00"},{"id":"Asia\/Baghdad","name":"아랍 표준시","offset":"+03:00"},{"id":"Asia\/Bahrain","name":"아랍 표준시","offset":"+04:00"},{"id":"Asia\/Baku","name":"아제르바이잔 시간","offset":"+04:00"},{"id":"Asia\/Bangkok","name":"인도차이나 반도 시간","offset":"+07:00"},{"id":"Asia\/Barnaul","name":"그리니치 표준시","offset":"+07:00"},{"id":"Asia\/Beirut","name":"동유럽 시간","offset":"+02:00"},{"id":"Asia\/Bishkek","name":"키르키즈스탄 시간","offset":"+06:00"},{"id":"Asia\/Brunei","name":"브루나이 시간","offset":"+08:00"},{"id":"Asia\/Calcutta","name":"인도 표준시","offset":"+05:30"},{"id":"Asia\/Chita","name":"이르쿠츠크 시간","offset":"+09:00"},{"id":"Asia\/Choibalsan","name":"Choibalsan 시간","offset":"+07:00"},{"id":"Asia\/Chongqing","name":"중국 표준시","offset":"+08:00"},{"id":"Asia\/Chungking","name":"중국 표준시","offset":"+08:00"},{"id":"Asia\/Colombo","name":"인도 표준시","offset":"+05:30"},{"id":"Asia\/Dacca","name":"방글라데시 시간","offset":"+06:00"},{"id":"Asia\/Damascus","name":"동유럽 시간","offset":"+02:00"},{"id":"Asia\/Dhaka","name":"방글라데시 시간","offset":"+06:00"},{"id":"Asia\/Dili","name":"티모르-레스테 시간","offset":"+09:00"},{"id":"Asia\/Dubai","name":"걸프만 표준시","offset":"+04:00"},{"id":"Asia\/Dushanbe","name":"타지키스탄 시간","offset":"+06:00"},{"id":"Asia\/Gaza","name":"동유럽 시간","offset":"+02:00"},{"id":"Asia\/Harbin","name":"중국 표준시","offset":"+08:00"},{"id":"Asia\/Hebron","name":"동유럽 시간","offset":"+02:00"},{"id":"Asia\/Ho_Chi_Minh","name":"인도차이나 반도 시간","offset":"+08:00"},{"id":"Asia\/Hong_Kong","name":"홍콩 시간","offset":"+08:00"},{"id":"Asia\/Hovd","name":"Hovd 시간","offset":"+06:00"},{"id":"Asia\/Irkutsk","name":"이르쿠츠크 시간","offset":"+08:00"},{"id":"Asia\/Istanbul","name":"동유럽 시간","offset":"+02:00"},{"id":"Asia\/Jakarta","name":"서인도네시아 시간","offset":"+07:00"},{"id":"Asia\/Jayapura","name":"동부 인도네시아 시간","offset":"+09:00"},{"id":"Asia\/Jerusalem","name":"이스라엘 표준시","offset":"+02:00"},{"id":"Asia\/Kabul","name":"아프가니스탄 시간","offset":"+04:30"},{"id":"Asia\/Kamchatka","name":"페트로파블로프스크-캄차츠키 시간","offset":"+12:00"},{"id":"Asia\/Karachi","name":"파키스탄 시간","offset":"+05:00"},{"id":"Asia\/Kashgar","name":"중국 표준시","offset":"+06:00"},{"id":"Asia\/Kathmandu","name":"네팔 시간","offset":"+05:30"},{"id":"Asia\/Katmandu","name":"네팔 시간","offset":"+05:30"},{"id":"Asia\/Khandyga","name":"한디가 표준시","offset":"+09:00"},{"id":"Asia\/Kolkata","name":"인도 표준시","offset":"+05:30"},{"id":"Asia\/Krasnoyarsk","name":"크라스노야르스크 시간","offset":"+07:00"},{"id":"Asia\/Kuala_Lumpur","name":"말레이시아 시간","offset":"+07:30"},{"id":"Asia\/Kuching","name":"말레이시아 시간","offset":"+08:00"},{"id":"Asia\/Kuwait","name":"아랍 표준시","offset":"+03:00"},{"id":"Asia\/Macao","name":"중국 표준시","offset":"+08:00"},{"id":"Asia\/Macau","name":"중국 표준시","offset":"+08:00"},{"id":"Asia\/Magadan","name":"마가단 시간","offset":"+11:00"},{"id":"Asia\/Makassar","name":"중앙 인도네시아 시간","offset":"+08:00"},{"id":"Asia\/Manila","name":"필리핀 시간","offset":"+08:00"},{"id":"Asia\/Muscat","name":"걸프만 표준시","offset":"+04:00"},{"id":"Asia\/Nicosia","name":"동유럽 시간","offset":"+02:00"},{"id":"Asia\/Novokuznetsk","name":"크라스노야르스크 시간","offset":"+07:00"},{"id":"Asia\/Novosibirsk","name":"노브시빌스크 시간","offset":"+07:00"},{"id":"Asia\/Omsk","name":"Omsk 시간","offset":"+06:00"},{"id":"Asia\/Oral","name":"Oral 표준시","offset":"+05:00"},{"id":"Asia\/Phnom_Penh","name":"인도차이나 반도 시간","offset":"+07:00"},{"id":"Asia\/Pontianak","name":"서인도네시아 시간","offset":"+08:00"},{"id":"Asia\/Pyongyang","name":"한국 표준시","offset":"+09:00"},{"id":"Asia\/Qatar","name":"아랍 표준시","offset":"+04:00"},{"id":"Asia\/Qyzylorda","name":"Qyzylorda 표준시","offset":"+05:00"},{"id":"Asia\/Rangoon","name":"미얀마 시간","offset":"+06:30"},{"id":"Asia\/Riyadh","name":"아랍 표준시","offset":"+03:00"},{"id":"Asia\/Saigon","name":"인도차이나 반도 시간","offset":"+08:00"},{"id":"Asia\/Sakhalin","name":"사할린 시간","offset":"+11:00"},{"id":"Asia\/Samarkand","name":"우즈베키스탄 시간","offset":"+05:00"},{"id":"Asia\/Seoul","name":"한국 표준시","offset":"+09:00"},{"id":"Asia\/Shanghai","name":"중국 표준시","offset":"+08:00"},{"id":"Asia\/Singapore","name":"싱가포르 시간","offset":"+07:30"},{"id":"Asia\/Srednekolymsk","name":"Srednekolymsk Time","offset":"+11:00"},{"id":"Asia\/Taipei","name":"중국 표준시","offset":"+08:00"},{"id":"Asia\/Tashkent","name":"우즈베키스탄 시간","offset":"+06:00"},{"id":"Asia\/Tbilisi","name":"그루지야 시간","offset":"+04:00"},{"id":"Asia\/Tehran","name":"이란 표준시","offset":"+03:30"},{"id":"Asia\/Tel_Aviv","name":"이스라엘 표준시","offset":"+02:00"},{"id":"Asia\/Thimbu","name":"부탄 시간","offset":"+05:30"},{"id":"Asia\/Thimphu","name":"부탄 시간","offset":"+05:30"},{"id":"Asia\/Tokyo","name":"일본 표준시","offset":"+09:00"},{"id":"Asia\/Ujung_Pandang","name":"중앙 인도네시아 시간","offset":"+08:00"},{"id":"Asia\/Ulaanbaatar","name":"울란바타르 시간","offset":"+07:00"},{"id":"Asia\/Ulan_Bator","name":"울란바타르 시간","offset":"+07:00"},{"id":"Asia\/Urumqi","name":"중국 표준시","offset":"+06:00"},{"id":"Asia\/Ust-Nera","name":"우스티네라 표준시","offset":"+09:00"},{"id":"Asia\/Vientiane","name":"인도차이나 반도 시간","offset":"+07:00"},{"id":"Asia\/Vladivostok","name":"블라디보스톡 시간","offset":"+10:00"},{"id":"Asia\/Yakutsk","name":"야츠크 시간","offset":"+09:00"},{"id":"Asia\/Yekaterinburg","name":"예카테린버그 시간","offset":"+05:00"},{"id":"Asia\/Yerevan","name":"아르메니아 시간","offset":"+04:00"},{"id":"Atlantic\/Azores","name":"아조레스 시간","offset":"-01:00"},{"id":"Atlantic\/Bermuda","name":"대서양 표준시","offset":"-04:00"},{"id":"Atlantic\/Canary","name":"서유럽 시간","offset":"+00:00"},{"id":"Atlantic\/Cape_Verde","name":"까뽀베르데 시간","offset":"-02:00"},{"id":"Atlantic\/Faeroe","name":"서유럽 시간","offset":"+00:00"},{"id":"Atlantic\/Faroe","name":"서유럽 시간","offset":"+00:00"},{"id":"Atlantic\/Jan_Mayen","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Atlantic\/Madeira","name":"서유럽 시간","offset":"+00:00"},{"id":"Atlantic\/Reykjavik","name":"그리니치 표준시","offset":"+00:00"},{"id":"Atlantic\/South_Georgia","name":"사우스 조지아 표준시","offset":"-02:00"},{"id":"Atlantic\/St_Helena","name":"그리니치 표준시","offset":"+00:00"},{"id":"Atlantic\/Stanley","name":"포클랜드 군도 시간","offset":"-04:00"},{"id":"Australia\/ACT","name":"동부 표준시(뉴사우스웨일즈)","offset":"+10:00"},{"id":"Australia\/Adelaide","name":"중부 표준시(남부 오스트레일리아)","offset":"+09:30"},{"id":"Australia\/Brisbane","name":"동부 표준시(퀸즐랜드)","offset":"+10:00"},{"id":"Australia\/Broken_Hill","name":"중부 표준시(남부 오스트레일리아\/뉴사우스웨일즈)","offset":"+09:30"},{"id":"Australia\/Canberra","name":"동부 표준시(뉴사우스웨일즈)","offset":"+10:00"},{"id":"Australia\/Currie","name":"동부 표준시(뉴사우스웨일즈)","offset":"+10:00"},{"id":"Australia\/Darwin","name":"중부 표준시(북부 지역)","offset":"+09:30"},{"id":"Australia\/Eucla","name":"중앙 서부 표준시(오스트레일리아)","offset":"+08:45"},{"id":"Australia\/Hobart","name":"동부 표준시(태즈메이니아)","offset":"+11:00"},{"id":"Australia\/LHI","name":"로드 하우 표준시","offset":"+10:00"},{"id":"Australia\/Lindeman","name":"동부 표준시(퀸즐랜드)","offset":"+10:00"},{"id":"Australia\/Lord_Howe","name":"로드 하우 표준시","offset":"+10:00"},{"id":"Australia\/Melbourne","name":"동부 표준시(빅토리아)","offset":"+10:00"},{"id":"Australia\/NSW","name":"동부 표준시(뉴사우스웨일즈)","offset":"+10:00"},{"id":"Australia\/North","name":"중부 표준시(북부 지역)","offset":"+09:30"},{"id":"Australia\/Perth","name":"서부 표준시(오스트레일리아)","offset":"+08:00"},{"id":"Australia\/Queensland","name":"동부 표준시(퀸즐랜드)","offset":"+10:00"},{"id":"Australia\/South","name":"중부 표준시(남부 오스트레일리아)","offset":"+09:30"},{"id":"Australia\/Sydney","name":"동부 표준시(뉴사우스웨일즈)","offset":"+10:00"},{"id":"Australia\/Tasmania","name":"동부 표준시(태즈메이니아)","offset":"+11:00"},{"id":"Australia\/Victoria","name":"동부 표준시(빅토리아)","offset":"+10:00"},{"id":"Australia\/West","name":"서부 표준시(오스트레일리아)","offset":"+08:00"},{"id":"Australia\/Yancowinna","name":"중부 표준시(남부 오스트레일리아\/뉴사우스웨일즈)","offset":"+09:30"},{"id":"Brazil\/Acre","name":"에이커 시간","offset":"-05:00"},{"id":"Brazil\/DeNoronha","name":"Fernando de Noronha 시간","offset":"-02:00"},{"id":"Brazil\/East","name":"브라질리아 시간","offset":"-03:00"},{"id":"Brazil\/West","name":"아마존 시간","offset":"-04:00"},{"id":"CET","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"CST6CDT","name":"중부 표준시","offset":"-06:00"},{"id":"Canada\/Atlantic","name":"대서양 표준시","offset":"-04:00"},{"id":"Canada\/Central","name":"중부 표준시","offset":"-06:00"},{"id":"Canada\/East-Saskatchewan","name":"중부 표준시","offset":"-06:00"},{"id":"Canada\/Eastern","name":"동부 표준시","offset":"-05:00"},{"id":"Canada\/Mountain","name":"산지 표준시","offset":"-07:00"},{"id":"Canada\/Newfoundland","name":"뉴펀들랜드 표준시","offset":"-03:30"},{"id":"Canada\/Pacific","name":"태평양 표준시","offset":"-08:00"},{"id":"Canada\/Saskatchewan","name":"중부 표준시","offset":"-06:00"},{"id":"Canada\/Yukon","name":"태평양 표준시","offset":"-08:00"},{"id":"Chile\/Continental","name":"칠레 시간","offset":"-03:00"},{"id":"Chile\/EasterIsland","name":"Easter Is. 시간","offset":"-06:00"},{"id":"Cuba","name":"쿠바 표준시","offset":"-05:00"},{"id":"EET","name":"동유럽 시간","offset":"+02:00"},{"id":"EST","name":"동부 표준시","offset":"-05:00"},{"id":"EST5EDT","name":"동부 표준시","offset":"-05:00"},{"id":"Egypt","name":"동유럽 시간","offset":"+02:00"},{"id":"Eire","name":"그리니치 표준시","offset":"+01:00"},{"id":"Etc\/GMT","name":"GMT+00:00","offset":"+00:00"},{"id":"Etc\/GMT+0","name":"GMT+00:00","offset":"+00:00"},{"id":"Etc\/GMT+1","name":"GMT-01:00","offset":"-01:00"},{"id":"Etc\/GMT+10","name":"GMT-10:00","offset":"-10:00"},{"id":"Etc\/GMT+11","name":"GMT-11:00","offset":"-11:00"},{"id":"Etc\/GMT+12","name":"GMT-12:00","offset":"-12:00"},{"id":"Etc\/GMT+2","name":"GMT-02:00","offset":"-02:00"},{"id":"Etc\/GMT+3","name":"GMT-03:00","offset":"-03:00"},{"id":"Etc\/GMT+4","name":"GMT-04:00","offset":"-04:00"},{"id":"Etc\/GMT+5","name":"GMT-05:00","offset":"-05:00"},{"id":"Etc\/GMT+6","name":"GMT-06:00","offset":"-06:00"},{"id":"Etc\/GMT+7","name":"GMT-07:00","offset":"-07:00"},{"id":"Etc\/GMT+8","name":"GMT-08:00","offset":"-08:00"},{"id":"Etc\/GMT+9","name":"GMT-09:00","offset":"-09:00"},{"id":"Etc\/GMT-0","name":"GMT+00:00","offset":"+00:00"},{"id":"Etc\/GMT-1","name":"GMT+01:00","offset":"+01:00"},{"id":"Etc\/GMT-10","name":"GMT+10:00","offset":"+10:00"},{"id":"Etc\/GMT-11","name":"GMT+11:00","offset":"+11:00"},{"id":"Etc\/GMT-12","name":"GMT+12:00","offset":"+12:00"},{"id":"Etc\/GMT-13","name":"GMT+13:00","offset":"+13:00"},{"id":"Etc\/GMT-14","name":"GMT+14:00","offset":"+14:00"},{"id":"Etc\/GMT-2","name":"GMT+02:00","offset":"+02:00"},{"id":"Etc\/GMT-3","name":"GMT+03:00","offset":"+03:00"},{"id":"Etc\/GMT-4","name":"GMT+04:00","offset":"+04:00"},{"id":"Etc\/GMT-5","name":"GMT+05:00","offset":"+05:00"},{"id":"Etc\/GMT-6","name":"GMT+06:00","offset":"+06:00"},{"id":"Etc\/GMT-7","name":"GMT+07:00","offset":"+07:00"},{"id":"Etc\/GMT-8","name":"GMT+08:00","offset":"+08:00"},{"id":"Etc\/GMT-9","name":"GMT+09:00","offset":"+09:00"},{"id":"Etc\/GMT0","name":"GMT+00:00","offset":"+00:00"},{"id":"Etc\/Greenwich","name":"그리니치 표준시","offset":"+00:00"},{"id":"Etc\/UCT","name":"세계 표준시","offset":"+00:00"},{"id":"Etc\/UTC","name":"세계 표준시","offset":"+00:00"},{"id":"Etc\/Universal","name":"세계 표준시","offset":"+00:00"},{"id":"Etc\/Zulu","name":"세계 표준시","offset":"+00:00"},{"id":"Europe\/Amsterdam","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Andorra","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Astrakhan","name":"그리니치 표준시","offset":"+04:00"},{"id":"Europe\/Athens","name":"동유럽 시간","offset":"+02:00"},{"id":"Europe\/Belfast","name":"그리니치 표준시","offset":"+01:00"},{"id":"Europe\/Belgrade","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Berlin","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Bratislava","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Brussels","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Bucharest","name":"동유럽 시간","offset":"+02:00"},{"id":"Europe\/Budapest","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Busingen","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Chisinau","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Copenhagen","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Dublin","name":"그리니치 표준시","offset":"+01:00"},{"id":"Europe\/Gibraltar","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Guernsey","name":"그리니치 표준시","offset":"+01:00"},{"id":"Europe\/Helsinki","name":"동유럽 시간","offset":"+02:00"},{"id":"Europe\/Isle_of_Man","name":"그리니치 표준시","offset":"+01:00"},{"id":"Europe\/Istanbul","name":"동유럽 시간","offset":"+02:00"},{"id":"Europe\/Jersey","name":"그리니치 표준시","offset":"+01:00"},{"id":"Europe\/Kaliningrad","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Kiev","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Lisbon","name":"서유럽 시간","offset":"+01:00"},{"id":"Europe\/Ljubljana","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/London","name":"그리니치 표준시","offset":"+01:00"},{"id":"Europe\/Luxembourg","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Madrid","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Malta","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Mariehamn","name":"동유럽 시간","offset":"+02:00"},{"id":"Europe\/Minsk","name":"모스크바 표준시","offset":"+03:00"},{"id":"Europe\/Monaco","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Moscow","name":"모스크바 표준시","offset":"+03:00"},{"id":"Europe\/Nicosia","name":"동유럽 시간","offset":"+02:00"},{"id":"Europe\/Oslo","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Paris","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Podgorica","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Prague","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Riga","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Rome","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Samara","name":"사마라 시간","offset":"+04:00"},{"id":"Europe\/San_Marino","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Sarajevo","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Simferopol","name":"모스크바 표준시","offset":"+03:00"},{"id":"Europe\/Skopje","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Sofia","name":"동유럽 시간","offset":"+02:00"},{"id":"Europe\/Stockholm","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Tallinn","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Tirane","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Tiraspol","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Ulyanovsk","name":"그리니치 표준시","offset":"+04:00"},{"id":"Europe\/Uzhgorod","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Vaduz","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Vatican","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Vienna","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Vilnius","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Volgograd","name":"모스크바 표준시","offset":"+04:00"},{"id":"Europe\/Warsaw","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Zagreb","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Europe\/Zaporozhye","name":"동유럽 시간","offset":"+03:00"},{"id":"Europe\/Zurich","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"GB","name":"그리니치 표준시","offset":"+01:00"},{"id":"GB-Eire","name":"그리니치 표준시","offset":"+01:00"},{"id":"GMT","name":"그리니치 표준시","offset":"+00:00"},{"id":"GMT+0","name":"GMT+00:00","offset":"+00:00"},{"id":"GMT-0","name":"GMT-00:00","offset":"+00:00"},{"id":"GMT0","name":"GMT+00:00","offset":"+00:00"},{"id":"Greenwich","name":"그리니치 표준시","offset":"+00:00"},{"id":"HST","name":"하와이 표준시","offset":"-10:00"},{"id":"Hongkong","name":"홍콩 시간","offset":"+08:00"},{"id":"Iceland","name":"그리니치 표준시","offset":"+00:00"},{"id":"Indian\/Antananarivo","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Indian\/Chagos","name":"영인도 제도 시간","offset":"+05:00"},{"id":"Indian\/Christmas","name":"크리스마스섬 시간","offset":"+07:00"},{"id":"Indian\/Cocos","name":"코코스 군도 시간","offset":"+06:30"},{"id":"Indian\/Comoro","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Indian\/Kerguelen","name":"프랑스 남부 지방 및 남극 지역 시간","offset":"+05:00"},{"id":"Indian\/Mahe","name":"세이셀 시간","offset":"+04:00"},{"id":"Indian\/Maldives","name":"몰디브 시간","offset":"+05:00"},{"id":"Indian\/Mauritius","name":"모리셔스 시간","offset":"+04:00"},{"id":"Indian\/Mayotte","name":"동부 아프리카 시간","offset":"+03:00"},{"id":"Indian\/Reunion","name":"리유니언 시간","offset":"+04:00"},{"id":"Iran","name":"이란 표준시","offset":"+03:30"},{"id":"Israel","name":"이스라엘 표준시","offset":"+02:00"},{"id":"Jamaica","name":"동부 표준시","offset":"-05:00"},{"id":"Japan","name":"일본 표준시","offset":"+09:00"},{"id":"Kwajalein","name":"마셜제도 시간","offset":"-12:00"},{"id":"Libya","name":"동유럽 시간","offset":"+02:00"},{"id":"MET","name":"중부 유럽 시간","offset":"+01:00"},{"id":"MST","name":"산지 표준시","offset":"-07:00"},{"id":"MST7MDT","name":"산지 표준시","offset":"-07:00"},{"id":"Mexico\/BajaNorte","name":"태평양 표준시","offset":"-08:00"},{"id":"Mexico\/BajaSur","name":"산지 표준시","offset":"-08:00"},{"id":"Mexico\/General","name":"중부 표준시","offset":"-06:00"},{"id":"NZ","name":"뉴질랜드 표준시","offset":"+12:00"},{"id":"NZ-CHAT","name":"Chatham 표준시","offset":"+12:45"},{"id":"Navajo","name":"산지 표준시","offset":"-07:00"},{"id":"PRC","name":"중국 표준시","offset":"+08:00"},{"id":"PST8PDT","name":"태평양 표준시","offset":"-08:00"},{"id":"Pacific\/Apia","name":"서사모아 시간","offset":"-11:00"},{"id":"Pacific\/Auckland","name":"뉴질랜드 표준시","offset":"+12:00"},{"id":"Pacific\/Bougainville","name":"Bougainville Standard Time","offset":"+10:00"},{"id":"Pacific\/Chatham","name":"Chatham 표준시","offset":"+12:45"},{"id":"Pacific\/Chuuk","name":"추크 표준시","offset":"+10:00"},{"id":"Pacific\/Easter","name":"Easter Is. 시간","offset":"-06:00"},{"id":"Pacific\/Efate","name":"비누아투 시간","offset":"+11:00"},{"id":"Pacific\/Enderbury","name":"피닉스 군도 시간","offset":"-12:00"},{"id":"Pacific\/Fakaofo","name":"토켈라우 시간","offset":"-11:00"},{"id":"Pacific\/Fiji","name":"피지 시간","offset":"+12:00"},{"id":"Pacific\/Funafuti","name":"투발루 시간","offset":"+12:00"},{"id":"Pacific\/Galapagos","name":"갈라파고스 시간","offset":"-05:00"},{"id":"Pacific\/Gambier","name":"감비아 시간","offset":"-09:00"},{"id":"Pacific\/Guadalcanal","name":"솔로몬 군도 시간","offset":"+11:00"},{"id":"Pacific\/Guam","name":"차모로 표준시","offset":"+10:00"},{"id":"Pacific\/Honolulu","name":"하와이 표준시","offset":"-10:00"},{"id":"Pacific\/Johnston","name":"하와이 표준시","offset":"-10:00"},{"id":"Pacific\/Kiritimati","name":"라인 군도 시간","offset":"-10:40"},{"id":"Pacific\/Kosrae","name":"코스래 시간","offset":"+12:00"},{"id":"Pacific\/Kwajalein","name":"마셜제도 시간","offset":"-12:00"},{"id":"Pacific\/Majuro","name":"마셜제도 시간","offset":"+12:00"},{"id":"Pacific\/Marquesas","name":"마르케사스 시간","offset":"-09:30"},{"id":"Pacific\/Midway","name":"사모아 표준시","offset":"-11:00"},{"id":"Pacific\/Nauru","name":"나우루 시간","offset":"+11:30"},{"id":"Pacific\/Niue","name":"니우에 시간","offset":"-11:30"},{"id":"Pacific\/Norfolk","name":"노퍽 시간","offset":"+11:30"},{"id":"Pacific\/Noumea","name":"뉴 칼레도니아 시간","offset":"+11:00"},{"id":"Pacific\/Pago_Pago","name":"사모아 표준시","offset":"-11:00"},{"id":"Pacific\/Palau","name":"팔라우 시간","offset":"+09:00"},{"id":"Pacific\/Pitcairn","name":"Pitcairn 표준시","offset":"-08:30"},{"id":"Pacific\/Pohnpei","name":"폰페이 표준시","offset":"+11:00"},{"id":"Pacific\/Ponape","name":"폰페이 표준시","offset":"+11:00"},{"id":"Pacific\/Port_Moresby","name":"파푸아뉴기니 시간","offset":"+10:00"},{"id":"Pacific\/Rarotonga","name":"쿠크 군도 시간","offset":"-10:30"},{"id":"Pacific\/Saipan","name":"차모로 표준시","offset":"+10:00"},{"id":"Pacific\/Samoa","name":"사모아 표준시","offset":"-11:00"},{"id":"Pacific\/Tahiti","name":"타히티 시간","offset":"-10:00"},{"id":"Pacific\/Tarawa","name":"길버트 군도 시간","offset":"+12:00"},{"id":"Pacific\/Tongatapu","name":"통가 시간","offset":"+13:00"},{"id":"Pacific\/Truk","name":"추크 표준시","offset":"+10:00"},{"id":"Pacific\/Wake","name":"웨이크 시간","offset":"+12:00"},{"id":"Pacific\/Wallis","name":"월리스 후투나 시간","offset":"+12:00"},{"id":"Pacific\/Yap","name":"추크 표준시","offset":"+10:00"},{"id":"Poland","name":"중앙 유럽 시간","offset":"+01:00"},{"id":"Portugal","name":"서유럽 시간","offset":"+01:00"},{"id":"ROC","name":"그리니치 표준시","offset":"+08:00"},{"id":"ROK","name":"한국 표준시","offset":"+09:00"},{"id":"Singapore","name":"싱가포르 시간","offset":"+07:30"},{"id":"Turkey","name":"동유럽 시간","offset":"+02:00"},{"id":"UCT","name":"세계 표준시","offset":"+00:00"},{"id":"US\/Alaska","name":"알래스카 표준시","offset":"-10:00"},{"id":"US\/Aleutian","name":"하와이 알류샨 표준시","offset":"-11:00"},{"id":"US\/Arizona","name":"산지 표준시","offset":"-07:00"},{"id":"US\/Central","name":"중부 표준시","offset":"-06:00"},{"id":"US\/East-Indiana","name":"동부 표준시","offset":"-05:00"},{"id":"US\/Eastern","name":"동부 표준시","offset":"-05:00"},{"id":"US\/Hawaii","name":"하와이 표준시","offset":"-10:00"},{"id":"US\/Indiana-Starke","name":"중부 표준시","offset":"-06:00"},{"id":"US\/Michigan","name":"동부 표준시","offset":"-05:00"},{"id":"US\/Mountain","name":"산지 표준시","offset":"-07:00"},{"id":"US\/Pacific","name":"태평양 표준시","offset":"-08:00"},{"id":"US\/Pacific-New","name":"태평양 표준시","offset":"-08:00"},{"id":"US\/Samoa","name":"사모아 표준시","offset":"-11:00"},{"id":"UTC","name":"세계 표준시","offset":"+00:00"},{"id":"Universal","name":"세계 표준시","offset":"+00:00"},{"id":"W-SU","name":"모스크바 표준시","offset":"+03:00"},{"id":"WET","name":"서유럽 시간","offset":"+00:00"},{"id":"Zulu","name":"세계 표준시","offset":"+00:00"}],
			aclVariables : {},
			aclActionTable : {},
			aclBeforeVariables : "",
			guid : function(){
				return coviCmn.ramdomString4() + '-' + coviCmn.ramdomString4() + '-' + coviCmn.ramdomString4() + '-' + coviCmn.ramdomString4();
			},
			ramdomString4 : function(){
				var rn = window.crypto.getRandomValues(new Uint32Array(1))/4294967296;
				return Math.floor((1 + rn) * 0x10000).toString(16).substring(1);
			},
			getLocalTimeZoneInfo : function(timezoneId){
				var ret;
				for (var i = 0; i < coviCmn.timeZoneInfos.length; i++) {
					var timezoneObj = coviCmn.timeZoneInfos[i];
					if(timezoneObj.id == timezoneId){
						ret = timezoneObj;
					}
				}
				return ret;
			},
			getLocalTime : function(utc, timezoneId){
				var utcDate;
				
				if(utc instanceof Date){
					utcDate = utc;
				} else {
					var agent = navigator.userAgent.toLowerCase();
					
					if ( ((navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1))
							|| (agent.indexOf("firefox") != -1) ) {
						utc = utc.split(" ")[0]+"T"+utc.split(" ")[1];
						utc = utc.replace(".0","");
						utcDate = new Date(utc);
					}else{
						utcDate = new Date(utc);
					}
					
				}
				
				var localTimeZoneId;
				if(timezoneId != null){
					localTimeZoneId = timezoneId;
				} else {
					localTimeZoneId = "Asia/Seoul";
				}
				
				var offset = coviCmn.getLocalTimeZoneInfo(localTimeZoneId).offset;

				var operator = offset.substr(0, 1);
				var hours = Number(offset.substr(1, 2));
				var minutes = Number(offset.substr(4, 2));
				
				var localDate = utcDate;
				if(operator == '+'){
					localDate.setHours(utcDate.getHours() + hours);
					localDate.setMinutes(utcDate.getMinutes() + minutes);
				} else if(operator == '-'){
					localDate.setHours(utcDate.getHours() - hours);
					localDate.setMinutes(utcDate.getMinutes() - minutes);
				}
				return localDate;
			},
			getParentFrame : function (frameID){
				var parentFrame = "";
		        var sTemp = "";
		        for (var i = 0; i < frameID.split(";").length; i++) {
		            sTemp = frameID.split(";")[i];
		            if (sTemp == "") {
		                break;
		            }

		            if (i == 0) {
		            	parentFrame = "$(\"#" + sTemp + "_if\", parent.document)[0].contentWindow";
		            } else {
		            	parentFrame += "$(\"#" + sTemp + "_if\")[0].contentWindow";
		            }
		            parentFrame += ".";
		        }
		        return parentFrame;
			},
			//상위 프레임을 obj 형식으로 넘겨줌
			//보안취약 관련 eval 제거
			getParentFrameObj: function (frameID){
				var parentFrame = window;
				var sTemp = "";
				for (var i = 0; i < frameID.split(";").length; i++) {
					sTemp = frameID.split(";")[i];
					if (sTemp == "") {
						break;
					}
					
					if (i == 0) {
						//parentFrame = "$(\"#" + sTemp + "_if\", parent.document)[0].contentWindow";
						parentFrame = $("#" + sTemp + "_if", parent.document)[0].contentWindow;
					} else {
						//parentFrame += "$(\"#" + sTemp + "_if\")[0].contentWindow";
						parentFrame = parentFrame.$("#" + sTemp + "_if")[0].contentWindow;
					}
					//if(i != frameID.split(";").length - 1){
					//	parentFrame += ".";
					//}
				}
				//return eval(parentFrame);
				return parentFrame;
			},
			setCookie : function(cname, cvalue, exdays) {
			    var d = new Date();
			    d.setTime(d.getTime() + (exdays*24*60*60*1000));
			    var expires = "expires="+ d.toUTCString();
			    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
			},
			setCookieByMin : function(cname, cvalue, mins) {
			    var d = new Date();
			    d.setTime(d.getTime() + (mins*60*1000));
			    var expires = "expires="+ d.toUTCString();
			    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
			},
			getCookie : function(cname) {
			    var name = cname + "=";
			    var decodedCookie = decodeURIComponent(document.cookie);
			    var ca = decodedCookie.split(';');
			    for(var i = 0; i <ca.length; i++) {
			        var c = ca[i];
			        while (c.charAt(0) == ' ') {
			            c = c.substring(1);
			        }
			        if (c.indexOf(name) == 0) {
			            return c.substring(name.length, c.length);
			        }
			    }
			    return "";
			},
			checkFnExist : function(fname){
				var bExist = false;
				try{
					if(fname != null && fname != ''){
						if(window[fname] != undefined){
							bExist = true;
						} else if(parent[fname] != undefined){
							bExist = true;
						} else if(opener && opener[fname] != undefined){
							bExist = true;
						}
					} 
				} catch(e) {
					//Avoid DOMException: Blocked a frame with origin "http://localhost:8080" from accessing a cross-origin frame.
					return false;
				}
				return bExist;
			},
			isNull: function(value, defaultVal){
				  if(typeof(value) == 'undefined' || value == null || value == 'undefined' ){
					  return defaultVal;
				  }
				  return value;	
			},
			//loadImageFilePath:function(serviceType, filePath, savedName){
			//	return coviCmn.loadImage(Common.getBaseConfig('BackStoragePath').replace("{0}", Common.getSession("DN_Code")) +  serviceType +'/' + filePath + savedName);
			//},
			loadImage : function(imgPath) {
				return "/covicore/common/photo/photo.do?img=" + encodeURIComponent(imgPath) ;
			},
			loadImageId : function(imgId) {
				return "/covicore/common/view/"+imgId+".do";
			},
			loadImageIdThumb : function(imgId) {
				return "/covicore/common/preview/"+imgId+".do";
			},	
			imgError : function(image, isProf) {
			    image.onerror = "";
			    if (isProf == true){
				    image.src = "/covicore/resources/images/no_profile.png";
			    }
			    else{
				    image.src = "/covicore/resources/images/no_image.jpg";
			    }    
			    return true;
			},
			clearCache : function(isReload, isAlert){
				//localCache(sessionStorage) 삭제
				localCache.removeAll();
				
				//coviStorage(localStorage) 다국어 기초설정 정보 삭제
				coviStorage.clear("ALL");
				
				//server redis cache 삭제
				$.ajax({
					url:"/covicore/cache/clearUserCache.do",
		 			type:"post",
		 			data:{},
		 			success : function(res) {
						if (res.status == "SUCCESS") {
							if(isAlert===true) {
								Common.Inform(Common.getDic("msg_com_processSuccess"), "", function () {
									if (isReload) {
										if (isReload == 'home') {	// 겸직 변경인 경우, 홈으로 이동. (겸직 변경으로 인해 권한이 없는 위치에서 리로드 되는 것 방지) 캐시초기화 후 홈이동을 원하는 경우, home 파라미터 이용
											location.href = "/covicore";
										} else {
											location.reload();
										}
									}
								});
							}else{
								if (isReload) {
									if (isReload == 'home') {	// 겸직 변경인 경우, 홈으로 이동. (겸직 변경으로 인해 권한이 없는 위치에서 리로드 되는 것 방지) 캐시초기화 후 홈이동을 원하는 경우, home 파라미터 이용
										location.href = "/covicore";
									} else {
										location.reload();
									}
								}
							}
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/cache/clearUserCache.do", response, status, error);
					}
		 		});
			},
			reloadCache:function(pCacheType, domainId){
				localCache.removeAll();
				coviStorage.clear(pCacheType);

				$.ajax({
					url:"/covicore/cache/reloadCache.do",
					type:"post",
					data:{
						"replicationFlag": coviCmn.configMap["RedisReplicationMode"],
						"cacheType" : pCacheType,
						"domainId":domainId
					},
					success: function (res) { 
						Common.Inform(Common.getDic("msg_Processed"),"Information",function(){
							location.reload();
			    		});
					},
					error : function (error){
						alert("error : "+error);
					}
				});
			},
			clearLocalCache : function(){
				//localcache 삭제
				localCache.removeAll();
			},
			sessionOut : function(msg,  redirectAfterTime  , callback, callbackLogOut){
				if( redirectAfterTime === undefined || redirectAfterTime === ""){
					redirectAfterTime = 30;
				}
				var sessionCountDic = Common.getDic("msg_sessionTimeoutCountdown").replace("{0}", redirectAfterTime);
				var alertMessage = msg + '<br/><br/>'+String.format("<span id='sessionTimeoutCountdown'>"+sessionCountDic+"</span>");
				
				Common.Confirm(alertMessage, Common.getDic("lbl_sessionExpire"),function(result){
					if(result){
						clearInterval(sessionTimer); 
						callback();
					} else {
						XFN_LogOut();
					}
				});
				
				var counter = redirectAfterTime;
				let startDate = new Date();
				clearInterval(sessionTimer); 
	            // create a timer that runs every second
	            sessionTimer = setInterval(function(){
	            	counter -= 1;
	            	counter = redirectAfterTime-Math.floor(((new Date()).getTime()- startDate.getTime())/1000);
//					console.log("count:["+new Date()+"]"+counter);
	            	// if the counter is 0, logout
	                if(counter <= 0) {
	                	if(  $('#sessionTimeoutCountdown').size() > 0 ){
	                		callbackLogOut();	
	                	}
	                	
	                } else {
	                    $('#sessionTimeoutCountdown').text(counter);
	                };
	            }, 1000);
			
	            
	            //logout 이벤트 추가 
	            $(".dialog_bottom").find("input[value=Logout]").on("click", function(){
	            	callbackLogOut();
	            });
			},
			continuSession : function(){
				var pKey = "USERID";
				
				localCache.remove("SESSION_"+ pKey)
				Common.getSession(pKey);
			},
			webBrowserVersion : function(){
				     var agt = navigator.userAgent.toLowerCase(); 
					 if (agt.indexOf("chrome") != -1) 
					      return ''; 
					 if (agt.indexOf("opera") != -1) 
					      return ''; 
				     if (agt.indexOf("firefox") != -1) 
				          return ''; 
					 if (agt.indexOf("safari") != -1) 
					      return ''; 
					 if (agt.indexOf("edge") != -1) 
					      return ''; 
				     if ( (navigator.appName == 'Netscape' && agt.indexOf('trident') != -1) || agt.indexOf("msie") != -1) {
				    	  var rv = -1; 
				    	  if (navigator.appName == 'Microsoft Internet Explorer') 
						   { 
				    			var ua = navigator.userAgent; 
								var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})"); 
								if (re.exec(ua) != null) {
									rv = parseFloat(RegExp.$1); 
								}
							    
								if(rv != 0 && rv <= 10){
									return 'x';
								}else{
									return '';
								}
						   }else{
							  return '';
						   } 

					}
				    return 'x';

			},
			convertNull:function(orgVal, repalceChar){
				if (orgVal == null) return repalceChar;
				else return orgVal;
			},
			getTimeFormat:function(time){
				var str = XFN_ReplaceAllSpecialChars(time);

				if (str.length < 4) return str;

				if (str.length == 4)
				{
					return str.substring(0, 2) + ":" + str.substring(2, 4);
				}
				else
				{
					if (str.length < 6) time = AttendUtils.paddingStr(str, "R", "0", 6);

					return str.substring(0, 2) + ":" + str.substring(2, 4) + ":" + str.substring(4, 6);
				}
			},
			getDateFormat:function(time, fmt){
				if (time == null) return "";
				if (fmt == null) fmt = ".";
				var str = XFN_ReplaceAllSpecialChars(time);

				if (str.length < 4) return str;

				if (str.length == 4)
				{
					return str.substring(0, 2) + fmt + str.substring(2, 4);
				}
				else if (str.length == 6)
				{
					return str.substring(0, 4) + fmt + str.substring(4, 6);
				}
				else if (str.length == 8)
				{
					return str.substring(0, 4) + fmt + str.substring(4, 6) + fmt + str.substring(6, 8);
				}
			},
			getDateTimeFormat:function(time){
				var str = XFN_ReplaceAllSpecialChars(time);
				str= str.replace(" ", "");

				if (str.length < 4) return str;

				if (str.length == 4)
				{
					return str.substring(0, 2) + "." + str.substring(2, 4);
				}
				else if (str.length == 6)
				{
					return str.substring(0, 4) + "." + str.substring(4, 6);
				}
				else if (str.length == 8)
				{
					return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8);
				}
				else if (str.length == 10){
					return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8) +" " + str.substring(8, 10) ;
				}
				else if (str.length == 12){
					return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8) +" " + str.substring(8, 10) + ":" + str.substring(10, 12);
				}
				else if (str.length == 14){
					return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8) +" " + str.substring(8, 10) + ":" + str.substring(10, 12) + ":" + str.substring(12, 14);
				}
			},	
			openDicLayerPopup:function(option, openerID) { //다국어 팝업
				var url = "";
				url += "/covicore/control/calldic.do?lang=" + option.lang;
				url += "&hasTransBtn=" + option.hasTransBtn;
				url += "&useShort=" + option.useShort;
				url += "&dicCallback=" + option.dicCallback;
				url += "&allowedLang=" +( option.allowedLang==undefined?"ko,en,ja,zh":option.allowedLang);
				url += "&popupTargetID=" + option.popupTargetID;
				url += "&styleType=" + ( option.styleType==undefined?"U":option.styleType);
				
				if (option.init != undefined) url += "&init=" + option.init;
				if (option.initData!=undefined) url += "&initData=" + option.initData;
				if (option.dicID!=undefined) url += "&dicID=" + option.dicID;
				
				Common.open("", openerID==undefined||openerID==""?"DictionaryPopup":openerID, Common.getDic("lbl_MultiLangSet"), url, "500px", "270px", "iframe", true, null, null, true);
			},
			getGridCheckListToArray:function(grdObj, colId){//체크 데이타 배열로 리섵
				var checkList = grdObj.getCheckedList(0);
				var paramArr = new Array();
				$(checkList).each(function(i, v) {
						var str = v[colId];
						paramArr.push(str);
				});
				
				return paramArr;
				
			},
			openOrgChartPopup:function(pPopupTit, orgType, option){
				var popupTit= Common.getDic("lbl_DeptOrgMap");
				var url = "";
				url += "/covicore/control/goOrgChart.do?";
				url += "&type=" + orgType;
				url += "&treeKind="+(option.treeKind==null||option.treeKind==undefined?"Dept":option.treeKind);
				url += "&callBackFunc=" + option.callBackFunc;
				url += "&checkboxRelationFixed=" + (option.checkboxRelationFixed=="false"?false:true);
				option.init!= undefined?url += "&init=" + option.init:"";
				
				switch (orgType){
					case "A1":
						width=550;
						popupTit= pPopupTit;
						break;
					default:		
						width=1060;
				}
				CFN_OpenWindow(url,popupTit,width,"580","");
			},
			showLoadingOverlay : function(){
				this.toggleLoadingOverlay({mode:"show"});
			},
			hideLoadingOverlay : function(){
				this.toggleLoadingOverlay({mode:"hide"});
			},
			viewHelp:function(obj){
				$(obj).siblings('.helppopup').toggle('active');
			},
			toggleLoadingOverlay : function(opt){
				var mode = "toggle";
				if(opt && opt.mode == "show"){
					mode = "show";
				}
				if(opt && opt.mode == "hide"){
					mode = "hide";
				}
				
				var _id = "loading_spinner";
				var __html = "<div id='"+_id+"' style='display:none;width: 100%; height: 100%;top: 0; left: 0;display: none;opacity: .4;background: silver;position: fixed;z-index: 9999;'>";
				__html += "<div style='width: 100%; height: 100%;display: table;'><span style='display: table-cell;text-align: center;vertical-align: middle;'>";
				__html += "<img src='/groupware/resources/images/loader.gif' style='background: #fff; padding: 1em; border-radius: .7em;'>";
				__html += "</span></div>";
				__html += "</div>";
				if ($('#'+_id).length == 0){
					$("body").append(__html);
				}
				var $loadgingDiv = $('#'+_id);
				if ((mode == "toggle" && $loadgingDiv.is(':hidden')) || mode == "show") {
					$loadgingDiv.show();
				}else{
					if((mode == "toggle" && !$loadgingDiv.is(':hidden')) || mode == "hide"){
						$loadgingDiv.hide();
					}
				}
			},
			random:function(){
				return window.crypto.getRandomValues(new Uint32Array(1))/4294967296;
			},
			traceLog:function(log){
				console.log("covision error:"+log);
			},
			getCoviSwitch:function(id, data, callback){//swith  control 공통 생성
				if (data == undefined) data = {"on":"Y","off":"N", "defVal":"N", "retVal":""};
				var retVal = (typeof data.retVal == 'object') ? JSON.stringify(data.retVal) : data.retVal;
				return "<div class='alarm type01' style='padding:0px '><input on_value='"+data["on"]+"' off_value='"+data["off"]+"' id='"+id+ "' style='display:none'>" +
						"<a href='javascript:;' class='onOffBtn"+(data["defVal"] == data["on"]?" on":"")+"' data-return-value='"+retVal+"' onclick=\"coviCmn.toggleSwitch(this, '"+id+"', '', "+callback+")\";><span></span></a></div>";									
			},
			toggleSwitch: function(thisObj, id, pRetVal, callback){
				let obj = $(document.getElementById(id)); // id에 .이 들어가는 경우 대응하여 document.getElementById로 요소를 가져와 jquery 객체로 변환
				if ($(thisObj).hasClass("on")) //
					obj.val(obj.attr("off_value"));
				else
					obj.val(obj.attr("on_value"));
				$(thisObj).toggleClass("on");
				var retVal = ($(thisObj).attr('data-return-value') == null) ? pRetVal : $(thisObj).attr('data-return-value');
				return callback(retVal, obj.val(), thisObj);
			},
			getCoviGridFormat:function(sFormat, item, key, addition, callback){
				if (!item.hasOwnProperty(key)) return "";
				let html= "";
				let addArr;
				switch (sFormat)
				{
					case "DIC":
						html= CFN_GetDicInfo(item[key]);
						break;
					case "TERM":
						addArr =  addition.split(",");
						let startDate = addArr[0]; 
						let endDate= addArr[1];
						html = coviCmn.isNull(item[startDate], '')+ '~' + coviCmn.isNull(item[endDate], '');
						break;
					case "FLOWER":
						addArr =  addition.split(",");
						let id = addArr[0]== ""?"UR_Code": addArr[0];
						let name= (addArr.length==1 || addArr[1]== "")?"DisplayName": addArr[1];
						
						html = "<div class='flowerPopup' onclick='coviCtrl.setFlowerName(this)' data-user-code='"+ item[id] +"' data-user-mail=''>"+
								"<a class='btnFlowerName'><span class='fcStyle'>"+item[name]+
								"</span></a></div>";
						break;
					case "LINK":
						html =  "<div class=tblLink><a href=#>"+ coviCmn.isNull(item[key], '')+ "</a></div>";
						break;
					case "DATE":
						return CFN_TransLocalTime(item[key].toString().replaceAll("-",""), "yyyy-MM-dd");
						break;
					case "NUMBER":
						return Number(item[key]);
						break;
				}
				return html;
			},
			// NS.NS.ns.fn 형태의 함수명 Invoke
			// evel 또는 new Function 하지 않도록
			// 함수외 multiline script 수행은 예외
			callFnBasedNamespace : function() {
				var fnStr = arguments[0];
				fnStr = fnStr.replace("()","").replace(";","");
				var args = [];
				for(var i = 0; i < arguments.length; i++){
					if(i > 0) {
						args.push(arguments[i]);
					}
				}
				
				if(fnStr.indexOf(".") > 0){
					let _scope = window;
					let wholeFn = window;
					let fnarr = fnStr.split(".");
					for(var i = 0; i < fnarr.length; i++){
						if(i < fnarr.length - 1){
							_scope = _scope[fnarr[i]];
						}
						wholeFn = wholeFn[fnarr[i]];
					}
					return wholeFn.apply(_scope, args);
				}else{
					return window[fnStr].apply(this, args);
				}
			}
		};
	
	window.coviCmn = coviCmn;
	
	if(!String.prototype.startsWith) {
		String.prototype.startsWith = function(searchString, position) {
			position = position || 0;
			return this.indexOf(searchString, position) === position;
		};
	}
	
	if (!String.prototype.endsWith) {
		String.prototype.endsWith = function(searchString, position) {
			var subjectString = this.toString();
			if (typeof position !== 'number' || !isFinite(position) 
					|| Math.floor(position) !== position || position > subjectString.length){
				position = subjectString.length;
			}
		    
			position -= searchString.length;
			var lastIndex = subjectString.indexOf(searchString, position);
			return lastIndex !== -1 && lastIndex === position;
		};
	}
})(window);

