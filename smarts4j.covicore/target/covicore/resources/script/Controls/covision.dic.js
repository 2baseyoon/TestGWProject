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
///다국어 처리 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/
if (!window.coviDic) {
    window.coviDic = {};
}

(function(window) {
	var coviDic = {
			dicMap:{},
			config : {
				lang : 'ko',
				hasTransBtn : 'true',
				translateAllowedLang : 'ko,en,ja,zh',
				allowedLang : 'ko,en,ja,zh',
				useShort : 'true',
				dicCallback : '',
				popupTargetID : '',
				init : '',
				openerID: '',
				initData : '',
				dicID:''
					
			},
			makeTr : function(langName, langCode, bcolSpan){
				var html = '';
				html += '<tr>';
				if(coviDic.config.useShort == 'true'){
					html += '	<th>' + langName + ' Short</th>';
					html += '	<td>';
					if(coviDic.config.styleType == "U"){
						html += '		<input type="text" id="' + langCode + '_short" class="menuName04"/>';
					}else{
						html += '		<input type="text" id="' + langCode + '_short"  style="width: 70%;height:25px" class="AXInput"/>';
					}
					if(coviDic.config.hasTransBtn == 'true' && langCode != 'ko' && coviDic.config.translateAllowedLang.indexOf(langCode) > -1){
						if(coviDic.config.styleType == "U"){
							html += '<a onclick="coviDic.translate(\'' + langCode + '\', \'short\'); return false;" class="btnTypeDefault" >' + Common.getDic("lbl_Translation") + '</a>';
						}else{
							html += '<input type="button" value="번역" onclick="coviDic.translate(\'' + langCode + '\', \'short\'); return false;" class="AXButton"  />';	
						}	
					}
					html += '	</td>';	
					html += '	<th>' + langName + ' Full</th>';
					html += '	<td>';
				}else{
					html += '	<th>' + langName + ' Full</th>';
					if(bcolSpan){
						html += '	<td colspan="3">';
					}else{
						html += '	<td >';
					}
				}
				if(coviDic.config.styleType == "U"){
					html += '		<input type="text" id="' + langCode + '_full" class="menuName04"/>';
				}else{
					html += '		<input type="text" id="' + langCode + '_full"  style="width: 70%;height:25px" class="AXInput"/>';
				}
				if(coviDic.config.hasTransBtn == 'true'){
					if (langCode == 'ko'){
						if(coviDic.config.styleType == "U"){
							html += '<a onclick="coviDic.translate(\''+coviDic.config.allowedLang+'\', \'full\'); return false;" class="btnTypeDefault"  >' + Common.getDic("lbl_AllTranslation") + '</a>';
						}else{
							html += '<input type="button" value="전체번역" onclick="coviDic.translate(\''+coviDic.config.allowedLang+'\', \'full\'); return false;" class="AXButton"  />';	
						}
					}
					else if (coviDic.config.translateAllowedLang.indexOf(langCode) > -1){
						if(coviDic.config.styleType == "U"){
							html += '<a onclick="coviDic.translate(\'' + langCode + '\', \'full\'); return false;" class="btnTypeDefault" >' + Common.getDic("lbl_Translation") + '</a>';
						}else{
							html += '<input type="button" value="번역" onclick="coviDic.translate(\'' + langCode + '\', \'full\'); return false;" class="AXButton"  />';	
						}
					}
				}
				html += '	</td>';
				html += '</tr>';
				return html;
			},
			render : function(target, option) {
				
				if(option != null){
					coviDic.config.lang = option.lang;
					coviDic.config.hasTransBtn = option.hasTransBtn;
					coviDic.config.allowedLang = option.allowedLang;
					coviDic.config.useShort = option.useShort;
					coviDic.config.dicCallback = option.dicCallback;
					coviDic.config.popupTargetID = option.popupTargetID;
					coviDic.config.init = option.init;
					coviDic.config.openerID = option.openerID;
					coviDic.config.styleType = option.styleType;
					coviDic.config.initData = option.initData;
					coviDic.config.dicID = option.dicID;
				}
				
				var html = '';
				if(coviDic.config.styleType == "U"){
					html += '<div class="sadmin_pop">';
					html += '		<table class="sadmin_table sa_menuBasicSetting">';
				}else{
					html += '<div>';
					html += '	<table  class="AXFormTable">';
				}
				html += '		<colgroup>';
				if(coviDic.config.useShort == 'true'){
					html += '			<col width="20%"/>';
					html += '			<col width="30%"/>';
					html += '			<col width="20%"/>';
					html += '			<col width="30%"/>';
				} else {
					html += '			<col width="30%"/>';
					html += '			<col width="70%"/>';
				}
				html += '		</colgroup>';
				
				if(coviDic.config.allowedLang.indexOf('ko') > -1){
					html += coviDic.makeTr('한국어', 'ko', false);	
				}
				if(coviDic.config.allowedLang.indexOf('en') > -1){
					html += coviDic.makeTr('English', 'en', false);
				}
				if(coviDic.config.allowedLang.indexOf('ja') > -1){
					html += coviDic.makeTr('日本語', 'ja', false);
				}
				if(coviDic.config.allowedLang.indexOf('zh') > -1){
					html += coviDic.makeTr('中國語', 'zh', false);
				}
				if(coviDic.config.allowedLang.indexOf('lang1') > -1){
					html += coviDic.makeTr('Lang1', 'lang1', false);
				}
				if(coviDic.config.allowedLang.indexOf('lang2') > -1){
					html += coviDic.makeTr('Lang2', 'lang2', false);
				}
				if(coviDic.config.allowedLang.indexOf('lang3') > -1){
					html += coviDic.makeTr('Lang3', 'lang3', false);
				}
				if(coviDic.config.allowedLang.indexOf('lang4') > -1){
					html += coviDic.makeTr('Lang4', 'lang4', false);
				}
				if(coviDic.config.allowedLang.indexOf('lang5') > -1){
					html += coviDic.makeTr('Lang5', 'lang5', false);
				}
				if(coviDic.config.allowedLang.indexOf('lang6') > -1){
					html += coviDic.makeTr('Lang6', 'lang6', false);
				}
				html += '	</table>';
				if(coviDic.config.styleType == "U"){
					html += '	<div class="bottomBtnWrap">';
					html += '		<a onclick="coviDic.setDic()" class="btnTypeDefault btnTypeBg" >' + Common.getDic("btn_Confirm") + '</a>';
					html += '		<a onclick="coviDic.close()" class="btnTypeDefault">' + Common.getDic("btn_Cancel") + '</a>';
					html += '	</div>';
				}else{
					html += '	<div align="center" style="padding-top: 10px">';
					html += '		<input type="button" value="'+ Common.getDic("btn_save") +'" onclick="coviDic.setDic()" class="AXButton red"/>';
					html += '		<input type="button" value="' + Common.getDic("btn_Cancel") + '" onclick="coviDic.close()" class="AXButton"/>';
					html += '	</div>';
				}
				html += '</div>';
				
				$('#' + target).html(html);
				//initdata 초기 넘어온 값(공통함수에서 값으로 초기값 넘길경우 kimhy2)
		    	if (coviDic.config.initData!= undefined && coviDic.config.initData!= null && coviDic.config.initData != ''){
	    			coviDic.bindData(coviDic.config.initData);
		    	}else if(coviDic.config.init != undefined && coviDic.config.init != null && coviDic.config.init != ''){	//init method 호출
		    		if(coviDic.config.openerID != undefined && coviDic.config.openerID != ''){
		    			//보안취약 조치. eval, Function 미사용
		    			//coviDic.bindData( new Function ("return "+ coviCmn.getParentFrame( coviDic.config.openerID )+coviDic.config.init +"()").apply() );
		    			let frmeWindow = coviCmn.getParentFrameObj(coviDic.config.openerID);
		    			if(jQuery.isFunction(frmeWindow[coviDic.config.init])){
			    			coviDic.bindData( frmeWindow[coviDic.config.init].apply(this) );
						}
		    			
		    		}else if(window[coviDic.config.init] != undefined){
						coviDic.bindData(window[coviDic.config.init]());
					} else if(parent[coviDic.config.init] != undefined){
						coviDic.bindData(parent[coviDic.config.init]());
					} else if(opener[coviDic.config.init] != undefined){
						coviDic.bindData(opener[coviDic.config.init]());
					}
		    	}
		    	
			},
			renderInclude:function(target, option) {
				
				if(option != null){
					coviDic.config.lang = option.lang;
					coviDic.config.hasTransBtn = option.hasTransBtn;
					coviDic.config.allowedLang = option.allowedLang;
					coviDic.config.useShort = option.useShort;
					coviDic.config.dicCallback = option.dicCallback;
					coviDic.config.popupTargetID = option.popupTargetID;
					coviDic.config.init = option.init;
					coviDic.config.initData = option.initData;
					coviDic.config.openerID = option.openerID;
					coviDic.config.styleType = option.styleType;
					coviDic.config.dicID = option.dicID;
				}
				
				//다국어 디자인 깨짐 현상 조치를 위한 div > tr객체 변경 작업
				var html = '';
				var bcolSpan = true;
				if(coviDic.config.styleType == "U"){
					html += '<div>';
					html += '	<table  class="sadmin_table sa_menuBasicSetting">';
					html += '		<colgroup>';
					html += '			<col width="90px"/>';
					html += '			<col width="100%"/>';
					html += '		</colgroup>';
					bcolSpan = false;
				}else if(coviDic.config.styleType == "T"){
					html += '<div>';
					html += '	<table  class="AXFormTable" width=650px style="border:0px">';
					html += '		<colgroup>';
					html += '			<col width="90px"/>';
					html += '			<col width="100%"/>';
					html += '		</colgroup>';
					bcolSpan = false;
				}else{
					//	html += '	<table  class="AXFormTable" width=650px style="border:0px">';
					bcolSpan = true;
				}
				
				if(coviDic.config.allowedLang.indexOf('ko') > -1){
					html += coviDic.makeTr('한국어', 'ko', bcolSpan);	
				}
				if(coviDic.config.allowedLang.indexOf('en') > -1){
					html += coviDic.makeTr('English', 'en', bcolSpan);
				}
				if(coviDic.config.allowedLang.indexOf('ja') > -1){
					html += coviDic.makeTr('日本語', 'ja', bcolSpan);
				}
				if(coviDic.config.allowedLang.indexOf('zh') > -1){
					html += coviDic.makeTr('中國語', 'zh', bcolSpan);
				}
				if(coviDic.config.allowedLang.indexOf('lang1') > -1){
					html += coviDic.makeTr('Lang1', 'lang1', bcolSpan);
				}
				if(coviDic.config.allowedLang.indexOf('lang2') > -1){
					html += coviDic.makeTr('Lang2', 'lang2', bcolSpan);
				}
				if(coviDic.config.allowedLang.indexOf('lang3') > -1){
					html += coviDic.makeTr('Lang3', 'lang3', bcolSpan);
				}
				if(coviDic.config.allowedLang.indexOf('lang4') > -1){
					html += coviDic.makeTr('Lang4', 'lang4', bcolSpan);
				}
				if(coviDic.config.allowedLang.indexOf('lang5') > -1){
					html += coviDic.makeTr('Lang5', 'lang5', bcolSpan);
				}
				if(coviDic.config.allowedLang.indexOf('lang6') > -1){
					html += coviDic.makeTr('Lang6', 'lang6', bcolSpan);
				}
				if(coviDic.config.styleType == "U" || coviDic.config.styleType == "T"){
					html += '</table>';
					html += '</div>';
					$('#' + target).html(html);
				}else{
					$('#' + target + " > tbody > tr:last").before(html);
				}
				//init method 호출
		    	if(coviDic.config.init != null && coviDic.config.init != ''){
		    		if(coviDic.config.openerID != undefined && coviDic.config.openerID != ''){
		    			//보안취약 조치. eval, Function 미사용
		    			//coviDic.bindData( new Function ("return "+ coviCmn.getParentFrame( coviDic.config.openerID )+coviDic.config.init +"()").apply() );
		    			let frmeWindow = coviCmn.getParentFrameObj(coviDic.config.openerID);
		    			if(jQuery.isFunction(frmeWindow[coviDic.config.init])){
			    			coviDic.bindData( frmeWindow[coviDic.config.init].apply(this) );
						}
		    		}else if(window[coviDic.config.init] != undefined){
						coviDic.bindData(window[coviDic.config.init]());
					} else if(parent[coviDic.config.init] != undefined){
						coviDic.bindData(parent[coviDic.config.init]());
					} else if(opener[coviDic.config.init] != undefined){
						coviDic.bindData(opener[coviDic.config.init]());
					}
		    	}
			},
			bindData : function(dicData){
				if($.type(dicData) === 'string' && dicData != ''){
					var splittedMultiLang = dicData.split(';')
					
					if($('#ko_full').length && splittedMultiLang[0] != undefined) {
						$('#ko_full').val(splittedMultiLang[0]);
					}
					if($('#en_full').length && splittedMultiLang[1] != undefined) {
						$('#en_full').val(splittedMultiLang[1]);
					}
					if($('#ja_full').length && splittedMultiLang[2] != undefined) {
						$('#ja_full').val(splittedMultiLang[2]);
					}
					if($('#zh_full').length && splittedMultiLang[3] != undefined) {
						$('#zh_full').val(splittedMultiLang[3]);
					}
					if($('#lang1_full').length && splittedMultiLang[4] != undefined) {
						$('#lang1_full').val(splittedMultiLang[4]);
					}
					if($('#lang2_full').length && splittedMultiLang[5] != undefined) {
						$('#lang2_full').val(splittedMultiLang[5]);
					}
					if($('#lang3_full').length && splittedMultiLang[6] != undefined) {
						$('#lang3_full').val(splittedMultiLang[6]);
					}
					if($('#lang4_full').length && splittedMultiLang[7] != undefined) {
						$('#lang4_full').val(splittedMultiLang[7]);
					}
					if($('#lang5_full').length && splittedMultiLang[8] != undefined) {
						$('#lang5_full').val(splittedMultiLang[8]);
					}
					if($('#lang6_full').length && splittedMultiLang[9] != undefined) {
						$('#lang6_full').val(splittedMultiLang[9]);
					}
				} else {
					if($('#ko_short').length) {
						$('#ko_short').val(dicData.KoShort);
					}
					if($('#ko_full').length) {
						$('#ko_full').val(dicData.KoFull);
					}
					if($('#en_short').length) {
						$('#en_short').val(dicData.EnShort);
					}
					if($('#en_full').length) {
						$('#en_full').val(dicData.EnFull);
					}
					if($('#ja_short').length) {
						$('#ja_short').val(dicData.JaShort);
					}
					if($('#ja_full').length) {
						$('#ja_full').val(dicData.JaFull);
					}
					if($('#zh_short').length) {
						$('#zh_short').val(dicData.ZhShort);
					}
					if($('#zh_full').length) {
						$('#zh_full').val(dicData.ZhFull);
					}
					if($('#lang1_short').length) {
						$('#lang1_short').val(dicData.Lang1Short);
					}
					if($('#lang1_full').length) {
						$('#lang1_full').val(dicData.Lang1Full);
					}
					if($('#lang2_short').length) {
						$('#lang2_short').val(dicData.Lang2Short);
					}
					if($('#lang2_full').length) {
						$('#lang2_full').val(dicData.Lang2Full);
					}
					if($('#lang3_short').length) {
						$('#lang3_short').val(dicData.Lang3Short);
					}
					if($('#lang3_full').length) {
						$('#lang3_full').val(dicData.Lang3Full);
					}
					if($('#lang4_short').length) {
						$('#lang4_short').val(dicData.Lang4Short);
					}
					if($('#lang4_full').length) {
						$('#lang4_full').val(dicData.Lang4Full);
					}
					if($('#lang5_short').length) {
						$('#lang5_short').val(dicData.Lang5Short);
					}
					if($('#lang5_full').length) {
						$('#lang5_full').val(dicData.Lang5Full);
					}
					if($('#lang6_short').length) {
						$('#lang6_short').val(dicData.Lang6Short);
					}
					if($('#lang6_full').length) {
						$('#lang6_full').val(dicData.Lang6Full);
					}
				}
			},
			convertDic : function(data){
				var multiLangName = '';
				multiLangName += data.KoFull + ';';
				multiLangName += data.EnFull + ';';
				multiLangName += data.JaFull + ';';
				multiLangName += data.ZhFull + ';';
				multiLangName += data.Lang1Full + ';';
				multiLangName += data.Lang2Full + ';';
				multiLangName += data.Lang3Full + ';';
				multiLangName += data.Lang4Full + ';';
				multiLangName += data.Lang5Full + ';';
				multiLangName += data.Lang6Full + ';';
				return multiLangName;
			},
			setDic : function(){
				//validation 추가
				var dicData = coviDic.makeDic();
//				dicData
				//validation 부분 보완할 것
				if (dicData.KoFull == '') {
					parent.Common.Warning("다국어 값을 입력하여 주세요.", "Warning Dialog", function () { });
				} else {
					//callback method 호출
					if(coviDic.config.dicCallback != null && coviDic.config.dicCallback != ''){
						if(coviDic.config.openerID != undefined && coviDic.config.openerID != ''){
							XFN_CallBackMethod_Call(coviDic.config.openerID ,coviDic.config.dicCallback,JSON.stringify(dicData));
						} else if(parent[coviDic.config.dicCallback] != undefined){
							parent[coviDic.config.dicCallback](dicData);
						} else if(opener[coviDic.config.dicCallback] != undefined){
							opener[coviDic.config.dicCallback](dicData);
						} else if(window[coviDic.config.dicCallback] != undefined){
							window[coviDic.config.dicCallback](dicData);
						}
					}
					coviDic.close();
				}
			},
			makeDic : function(){
				var dicObj = {
					KoShort : '',
					KoFull : '',
					EnShort : '',
					EnFull : '',
					JaShort : '',
					JaFull : '',
					ZhShort : '',
					ZhFull : '',
					Lang1Short : '',
					Lang1Full : '',
					Lang2Short : '',
					Lang2Full : '',
					Lang3Short : '',
					Lang3Full : '',
					Lang4Short : '',
					Lang4Full : '',
					Lang5Short : '',
					Lang5Full : '',
					Lang6Short : '',
					Lang6Full : '',
					DicID : '',
					popupTargetID:''
				};
				dicObj.DicID = coviDic.config.dicID;
				dicObj.popupTargetID= coviDic.config.popupTargetID;

				if($('#ko_short').length) {
					dicObj.KoShort = $('#ko_short').val();
				}
				if($('#ko_full').length) {
					dicObj.KoFull = $('#ko_full').val();
				}
				if($('#en_short').length) {
					dicObj.EnShort = $('#en_short').val();
				}
				if($('#en_full').length) {
					dicObj.EnFull = $('#en_full').val();
				}
				if($('#ja_short').length) {
					dicObj.JaShort = $('#ja_short').val();
				}
				if($('#ja_full').length) {
					dicObj.JaFull = $('#ja_full').val();
				}
				if($('#zh_short').length) {
					dicObj.ZhShort = $('#zh_short').val();
				}
				if($('#zh_full').length) {
					dicObj.ZhFull = $('#zh_full').val();
				}
				if($('#lang1_short').length) {
					dicObj.Lang1Short = $('#lang1_short').val();
				}
				if($('#lang1_full').length) {
					dicObj.Lang1Full = $('#lang1_full').val();
				}
				if($('#lang2_short').length) {
					dicObj.Lang2Short = $('#lang2_short').val();
				}
				if($('#lang2_full').length) {
					dicObj.Lang2Full = $('#lang2_full').val();
				}
				if($('#lang3_short').length) {
					dicObj.Lang3Short = $('#lang3_short').val();
				}
				if($('#lang3_full').length) {
					dicObj.Lang3Full = $('#lang3_full').val();
				}
				if($('#lang4_short').length) {
					dicObj.Lang4Short = $('#lang4_short').val();
				}
				if($('#lang4_full').length) {
					dicObj.Lang4Full = $('#lang4_full').val();
				}
				if($('#lang5_short').length) {
					dicObj.Lang5Short = $('#lang5_short').val();
				}
				if($('#lang5_full').length) {
					dicObj.Lang5Full = $('#lang5_full').val();
				}
				if($('#lang6_short').length) {
					dicObj.Lang6Short = $('#lang6_short').val();
				}
				if($('#lang6_full').length) {
					dicObj.Lang6Full = $('#lang6_full').val();
				}
				
				return dicObj;
			},
			translate : function(langCode, langType){
				var text = "";
				var src_lang = "ko";
				
				//영어 텍스트가 있을시 영어, 아니면 한글을 통해 번역 시도
				if($("#en_" + langType).val() != "" && $("#ko_" + langType).val() == ""){
					text = $("#en_" + langType).val();
					src_lang = "en";
				} else if ($("#ko_" + langType).val() != ""){
					text = $("#ko_" + langType).val();
					src_lang = "ko";
				}
				
				if (text == "") {
			        parent.Common.Warning("다국어 값을 입력하여 주세요.", "Warning Dialog", function () { });
			    } else {
			    	$.ajax({
						url:"/covicore/dic/translate.do",
						data:{
							"text" : text,
							"src_lang" : src_lang,
							"dest_lang" : langCode
						},
						type:"post",
						success:function (data) {
							if(data.status == "SUCCESS"){
								data.lang.map(function (v, i) {
									$("#" + v.dicLang + "_" + langType).val(v.text);	
								});
							} else {
								alert(data.message);
							}
						},
						error : function(response, status, error){
							CFN_ErrorAjax("dic/translate.do", response, status, error);
						}
					});
			    }
				
				
			},
			close : function(){

				if(window.opener){
					window.close();
				}else{
					parent.Common.close(coviDic.config.popupTargetID);
				}
			}			
			
	};
	
	window.coviDic = coviDic;
})(window);
