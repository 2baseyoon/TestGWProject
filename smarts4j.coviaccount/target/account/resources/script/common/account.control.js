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

Common.getDicList(["ACC_lbl_choice"]);

if (!window.accountCtrl) {
    window.accountCtrl = {};
}

(function(window) {
	var accountCtrl = {
		variables : {
			lang : "ko"
		},
		
		accountCtrlParams : {
			viewPageGridID : ""
		},
		
		AccountCtrlMap: {},
		
		// 보안취약 조치
		// caller 의 변수를 직접 넘기도록 변경
		// 호출쪽에서 eval 제거하고 아래 함수에서 직접 callback Apply 처리함.
		popupCallBackStr : function(pArr){ // AS-IS : ['params', 'pNames'] => To-Be : params, pName,..]
			var popupYN			= CFN_GetQueryString("popupYN");
			var openerID		= CFN_GetQueryString("openerID");
			var callBackFuncNm	= CFN_GetQueryString("callBackFunc");
			var callBack		= null;
			var parentFrameID	= openerID.substring(0,1).toLowerCase() + openerID.substring(1,openerID.length);
			var windowPopupYN   = CFN_GetQueryString("windowPopupYN");
			var __scope			= this;
			
			if(windowPopupYN == "Y") {
				__scope = opener[openerID];
			} else if(popupYN == 'Y'){
				try {
					__scope = coviCmn.getParentFrameObj(openerID)[openerID];
				}catch(e){
					__scope = null;
				}
				try{
					if(__scope == null || __scope == undefined){
						try {
							__scope = coviCmn.getParentFrameObj(parentFrameID)[openerID];
						} catch(e) { 
							__scope = coviCmn.getParentFrameObj(parentFrameID);
						}
					}else{
						__scope = coviCmn.getParentFrameObj(openerID)[openerID];
					}
				}catch (e) {
					__scope = coviCmn.getParentFrameObj(parentFrameID)[openerID];
				}
			} else{
				if(openerID == "") {
					__scope = parent.window;
				} else {
					if(parent._DocPath == window._DocPath) {
						__scope = opener.window[openerID];
					} else {
						__scope = parent.window[openerID];
					}
				}
			}
			
			// 객체없을때(경비결재 전결규정 팝업 openerID == "manageTreeItem")
			if(!__scope) __scope = parent.window;
				 
			callBack = __scope[callBackFuncNm];
			return callBack.apply(__scope, pArr);// scope 가 매우 중요함!!
		},
		
		pChangePopupSize : function(popupID,popupW,popupH){
			try {
				if(popupW != ''){
					var popupP	= $('#'+popupID+'_p');
					
					if(popupW.indexOf('px') == -1){
						popupW = popupW + 'px'
					}
					
					popupP[0].style.width	= popupW;
				}
				
				if(popupH != ''){
					var popupPH = $('#'+popupID+'_ph');
					var popupP	= $('#'+popupID+'_p');
					var popupHD	= $('#'+popupID+'_hideDiv');
					var popupHI	= $('#'+popupID+'_hideIfram');
					var popupIF = $('#'+popupID+'_if');
					var popupPC = $('#'+popupID+'_pc');
					
					if(popupH.indexOf('px') == -1){
						popupH = popupH + 'px'
					}
					popupP[0].style.height	= popupH + popupPH.height();
					popupHD[0].style.height = popupH + popupPH.height();
					popupHI[0].style.height = popupH + popupPH.height();
					popupIF[0].style.height = popupH;
					popupPC[0].style.height = popupH;
				}
			} catch (e) {
				coviCmn.traceLog(e);
			}
		},
		
		changePopupSize : function(w,h){
			
			if(w==null || w== undefined){
				w = '';
			}
			
			if(h==null || h== undefined){
				h = '';
			}
			
			var popupYN				= CFN_GetQueryString("popupYN");
			var popupID				= CFN_GetQueryString("popupID");
			var openerID			= CFN_GetQueryString("openerID");
			var changeSizeFuncNm	= CFN_GetQueryString("changeSizeFunc");
			var callBack			= '';
			var parentFrameID		= openerID.substring(0,1).toLowerCase() + openerID.substring(1,openerID.length);
			var __scope				= null;
			
			if(popupYN == 'Y'){
				try{
					__scope = coviCmn.getParentFrameObj(openerID)[openerID];
				}catch(e){
					__scope = null;
				}
				try{
					if(__scope == null || _scope == undefined){
						__scope = coviCmn.getParentFrameObj(parentFrameID)[openerID];
					}else{
						__scope = coviCmn.getParentFrameObj(openerID)[openerID];
					}
				}catch (e) {
					__scope = coviCmn.getParentFrameObj(parentFrameID)[openerID];
				}
			}else{
				if(openerID == "") {
					__scope = parent.window;
				} else {
					__scope = parent.window[openerID];
				}
			}
			
			if(w != ''){
				if(w.indexOf('px') == -1){
					w = w + 'px'
				}
				var layerInfo = $('.layer_divpop');
				layerInfo[0].style.width = w;
			}
			
			//eval(callBack);
			callBack = __scope[changeSizeFuncNm];
			callBack.apply(__scope, [popupID, w, h]);
		},
		
		popupCallBackStrObj : function(pArr){
			this.popupCallBackStr(pArr);
		},
		
		getGridViewPageNum : function(YN,gridPanel,pageSizeInfo){
			var rtNum	= 0;
			if(YN == 'Y'){
				rtNum = 1
			}else{
				var listCount	= gridPanel.page.listCount;
				var pageNo		= gridPanel.page.pageNo;
				var removedList	= gridPanel.removedList.length
				
				var info1 = (listCount - removedList) / pageSizeInfo;
				var info2 = (listCount - removedList) % pageSizeInfo;
				
				if(info1 < 1){
					rtNum = 1;
				}else{
					if(info2 == 0){
						rtNum = pageNo - 1;
					}else{
						rtNum = pageNo;
					}
				}
			}
			
			return rtNum;
		},
		
		getGridSwitch : function(col,key,value,onValue,offValue,onchangeFn){
			var me = this;
			
			var setID			= "AXInputSwitch" + key + + col + me.getViewPageDivID();
			var setType			= "text"
			var setOnValue		= onValue
			var setOffValue		= offValue
			var setKind			= "switch"
			var setStyle		= "width:35px;height:21px;border:0px none;float:none;"
			var setValue		= value;
			var setOnchangeFn	= onchangeFn;
				
			var gridSwitchStr =	"	<input	id			= '" +	setID			+ "'" 
							+	"			type		= '" +	setType			+ "'"
							+	"			on_value	= '" +	setOnValue		+ "'"
							+	"			off_value	= '" +	setOffValue		+ "'"
							+	"			kind		= '" +	setKind			+ "'"
							+	"			style		= '" +	setStyle		+ "'"
							+	"			value		= '" +	setValue		+ "'"
							+	"			onchange	= '" +	setOnchangeFn	+ "'"
							+	"	/>";
			return gridSwitchStr;
		},
		
		//현재 화면의 div id 를 return
		getViewPageDivID : function(){
			var pLpathname	= location.pathname.split('/')[3].split('.')[0];
			var temp = pLpathname;
			var pLsearch	= location.search;
			var pLsearchRA	= pLsearch.replace('?','');
			
			// Sub_URCode 에 dot 이 잇을경우 selector 로 사용시 Error.
			pLsearchRA	= pLsearchRA.replace(/\./gi,'-');
			
			var pLsearchRAS	= pLsearchRA.split('&');
			
			for(var sstr = 0; sstr < pLsearchRAS.length; sstr++){
				var searchStrsplitEQ    = pLsearchRAS[sstr].split('=');
				/*if(searchStrsplitEQ[0] == 'pageType') {
					pLpathname = pLpathname.replace(temp, 'account_' + searchStrsplitEQ[1]);
				}else if(searchStrsplitEQ[0] == 'fragments'){
					pLpathname += '';
				}else{
					pLpathname += searchStrsplitEQ[1];
				}*/
				
				if(searchStrsplitEQ[0] == 'fragments'){
					pLpathname += '';
				}else{
					pLpathname += searchStrsplitEQ[1];
				}
			}

			pLpathname += 'ViewArea'
				
			return pLpathname;
		},
		
		//현재 화면의 객체명을 return (ex.SimpleApplicationNORMAL)
		getViewPageObjectName : function(){
			var ObjName	= location.pathname.split('/')[3].split('.')[0];
			ObjName = ObjName.substring(ObjName.lastIndexOf("_") + 1);
			var pLsearch	= location.search;
			var pLsearchRA	= pLsearch.replace('?','');
			
			// Sub_URCode 에 dot 이 잇을경우 selector 로 사용시 Error.
			pLsearchRA	= pLsearchRA.replace(/\./gi,'-');
			
			var pLsearchRAS	= pLsearchRA.split('&');
			
			for(var sstr = 0; sstr < pLsearchRAS.length; sstr++){
				var searchStrsplitEQ    = pLsearchRAS[sstr].split('=');
				
				if(searchStrsplitEQ[0] == 'requesttype'){
					ObjName += searchStrsplitEQ[1];
				}
			}

			return ObjName;
		},
		
		getComboInfo : function(keyId){
			var me = this;
			var divID	= me.getViewPageDivID() + keyId + "Combo";
			var rtValue	= $('#'+divID);
			return rtValue;
		},
		
		//컴포넌트 정보 획득
		getInfo : function(keyId){
			var me = this;
			if(me.accountCtrl != undefined) { me = me.accountCtrl; }
			
			var divID	= me.getViewPageDivID();
			var findStr	= "[id = " + keyId + "]";
			
			var rtValue	= $('#'+divID).find(findStr);
			return rtValue;
		},

		//name으로 컴포넌트 정보 획득
		getInfoName : function(keyId){
			var me = this;
			if(me.accountCtrl != undefined) { me = me.accountCtrl; }
			
			var divID	= me.getViewPageDivID();
			var findStr	= "[name = " + keyId + "]";
			
			var rtValue	= $('#'+divID).find(findStr);
			return rtValue;
		},

		//여러조건으로 으로 컴포넌트 정보 획득
		getInfoStr : function(keyStr){
			var me = this;
			if(me.accountCtrl != undefined) { me = me.accountCtrl; }
			
			var divID	= me.getViewPageDivID();
			var findStr	= keyStr;
			
			var rtValue	= $('#'+divID).find(findStr);
			return rtValue;
		},
		
		setViewPageBindGrid : function(params){
			var me = this;
			
			var gridAreaID		= params.gridAreaID;
			var gridHeader		= params.gridHeader;
			var gridPanel		= params.gridPanel;
			var ajaxUrl			= params.ajaxUrl;
			var ajaxPars		= params.ajaxPars;
			var pageNoInfo		= params.pageNoInfo;
			var pageSizeInfo	= params.pageSizeInfo;
			var popupYN			= params.popupYN;
			var pagingTF		= params.pagingTF;
			var height			= params.height;
			var callback		= params.callback;
			var fitToWidth		= params.fitToWidth;

			var viewPageGridArea	= me.getInfo(gridAreaID);
			
			if(popupYN == 'Y'){
				viewPageGridArea	= $('#'+gridAreaID);
			}else{
				viewPageGridArea	= me.getInfo(gridAreaID);
			}
			
			var gridAreaChildren	= viewPageGridArea.children();
			var viewPageGridID		= "";
			
			if(gridAreaChildren.length > 0){
				viewPageGridID		= gridAreaChildren[0].id;
			}else{
				viewPageGridID		= me.getViewPageDivID() + gridAreaID + "Grid";
				var appendGridArea	= "<div id=\""+viewPageGridID+"\"></div>";
				viewPageGridArea.append(appendGridArea);
				me.setViewPageGridHeader(gridHeader,gridPanel);
			}
			
			me.setViewPageGridConfig(gridPanel,viewPageGridID,pageNoInfo,pageSizeInfo,pagingTF,height,fitToWidth);
			
			me.accountCtrlParams.viewPageGridID = viewPageGridID;
			
			gridPanel.bindGrid({
	 				ajaxUrl	: ajaxUrl
	 			,	ajaxPars: ajaxPars
	 			,	onLoad:function(){
		 				coviInput.setSwitch();
		 				gridPanel.fnMakeNavi(me.accountCtrlParams.viewPageGridID);
		 				me.accountCtrlParams.viewPageGridID = "";
		 				
		 				if(callback != null){
		 					if(typeof(callback)=="function"){
		 						callback();
		 					}
		 				}
	 				}
			});
			
		},
		
		setViewPageGridHeader : function(gridHeader,gridPanel) {
			gridPanel.setGridHeader(gridHeader);
		},
		
		setViewPageGridConfig : function(gridPanel,viewPageGridID,pageNoInfo,pageSizeInfo,pagingTF,height,fitToWidth){
			var pageParam	= {	pageNo		: pageNoInfo
							,	pageSize	: pageSizeInfo};
			
			var configObj = {	targetID		: viewPageGridID
							,	listCountMSG	: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>"
							,	height			: (height == undefined ? "auto" : height)
							,	page			: pageParam
							,	paging			: pagingTF	
							,	xscroll			: true
							,	fitToWidth		: (fitToWidth == undefined ? true : fitToWidth)
			};
			
			gridPanel.setGridConfig(configObj);
		},
		
		setGridBodyOption : function(gridPanel, ajaxUrl, ajaxPars) {
			
			gridPanel.config.body.onscrollend = function() {
				var me = this;
				
				if(gridPanel.page.listCount < gridPanel.page.pageNo * gridPanel.page.pageSize) {
					return;
				}
				
				gridPanel.page.pageNo = gridPanel.page.pageNo+1;
								
				ajaxPars.pageNo = gridPanel.page.pageNo;
				ajaxPars.pageSize = gridPanel.page.pageSize;
				
				$.ajax({
					url	: ajaxUrl,
					type: "POST",
					data: ajaxPars,
					success:function (data) {
						if(data.status == "SUCCESS"){
							if(data.list != undefined && data.list.length > 0) {
								var index = (gridPanel.page.pageNo - 1) * gridPanel.page.pageSize;
								gridPanel.pushList(data.list, index);
							}
						}else{
							Common.Error(data.message);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			}
		},
		
		pageRefresh : function(params){
			var me		= this;
			var divID	= me.getViewPageDivID();
			
			$('#'+divID).remove();
			
			var contentUrl	= location.pathname + location.search;
			contentUrl += (location.search == undefined || location.search == "" ? "?" : "&") + "fragments=content";
			
			$.ajax({
    			type : "GET",
    			beforeSend : function(req) {
    				req.setRequestHeader("Accept", "text/html;type=ajax");
    			},
    			url : contentUrl,
    			success : function(res) {
    				var resAddDiv	= res.replace('<script>','</div><script>');
    				resAddDiv	= "<div id = \"" + nowAjaxID + "ViewArea\">" + resAddDiv;
    				$("#content").append(resAddDiv);
    				var pageID			= nowAjaxUrl.split('/')[3].split('.')[0].split('_')[1];
    				var functionName	= 'pageInit';
    				evalPage(pageID,functionName,params)
    			},
    			error : function(response, status, error){
    				CFN_ErrorAjax(contentUrl, response, status, error);
    			}
    		});
		},
		
		refreshGrid : function(params){
			var me = this;
			
			var gridAreaID		= params.gridAreaID;
			var gridPanel		= params.gridPanel;
			var pageNoInfo		= params.pageNoInfo;
			var pageSizeInfo	= params.pageSizeInfo;
			var pagingTF		= params.pagingTF;
			var height			= params.height;
			var fitToWidth		= params.fitToWidth;
			
			var viewPageGridArea	= me.getInfo(gridAreaID);
			var gridAreaChildren	= viewPageGridArea.children();
			var viewPageGridID		= "";

			if(gridAreaChildren.length > 0){
				viewPageGridID		= gridAreaChildren[0].id;
			}else{
				viewPageGridID		= me.getViewPageDivID() + gridAreaID + "Grid";
				var appendGridArea	= "<div id=\""+viewPageGridID+"\"></div>";
				viewPageGridArea.append(appendGridArea);
			}
			
			me.accountCtrlParams.viewPageGridID = viewPageGridID;
			me.setViewPageGridConfig(gridPanel,viewPageGridID,pageNoInfo,pageSizeInfo,pagingTF,height,fitToWidth);
			
			coviInput.setSwitch();
			gridPanel.fnMakeNavi(me.accountCtrlParams.viewPageGridID);
			me.accountCtrlParams.viewPageGridID = "";
		},
		
		renderAXSelectMulti : function(AXSelectMultiArr, pCompanyCode){
			var me = this;
			var pCodeGroups = "";
			
			for(var i=0; i<AXSelectMultiArr.length; i++){
				var info = AXSelectMultiArr[i];
				pCodeGroups	+= accountCtrl.getTrimValue(info.codeGroup) + ',';
			}
			
			pCodeGroups	= pCodeGroups.substring(0,pCodeGroups.length-1);
			
			if(pCompanyCode == undefined || pCompanyCode == "") {
				pCompanyCode = accComm.getCompanyCodeOfUser();
			}
			
			$.ajax({
				type:"POST",
				data:{
					"codeGroups" : pCodeGroups,
					"CompanyCode" : pCompanyCode
				},
				url:"/account/accountCommon/getBaseCodeComboMulti.do",
				async	: false,
				success	: function (data) {
					for(var i=0; i<AXSelectMultiArr.length; i++){
						var info = AXSelectMultiArr[i];
						
						var codeGroup	= accountCtrl.getTrimValue(info.codeGroup);
						var target		= accountCtrl.getTrimValue(info.target);
						var lang		= accountCtrl.getTrimValue(info.lang);
						var onchange	= accountCtrl.getTrimValue(info.onchange);
						var oncomplete	= accountCtrl.getTrimValue(info.oncomplete);
						var defaultVal	= accountCtrl.getTrimValue(info.defaultVal);
						var useDefault	= accountCtrl.getTrimValue(info.useDefault);
						var notUsedVal = info.notUsedVal == "" || info.notUsedVal == null || info.notUsedVal == undefined ? new Array() : info.notUsedVal.split(",");
						
						var selectOption = accountCtrl.makeAXSelectData(data.list, codeGroup, lang, useDefault);
						
						for(var j = 0; j < notUsedVal.length; j++) {
							var index = selectOption.indexOf(notUsedVal[j]);
							selectOption.splice(index, 1);
						}
						
						var bindOption	= {
								reserveKeys: {
									optionValue	: "optionValue",
									optionText	: "optionText"
								},
								options: selectOption
							};

						if(	defaultVal	!= null			&&
							defaultVal	!= undefined	&&
							defaultVal	!= ""){
							bindOption.setValue = defaultVal;	
						}else if ((defaultVal == null || defaultVal	== undefined || defaultVal == "") && codeGroup == "CompanyCode"){
							bindOption.setValue = Common.getSession("DN_Code");
						}

						if(	onchange	!= null			&&
							onchange	!= undefined	&&
							onchange	!= ""){
							var onchangeFnName = onchange;
							bindOption.onchange = function(){
								if(window[onchangeFnName] != undefined){
									window[onchangeFnName](this);
								} else if(parent[onchangeFnName] != undefined){
									parent[onchangeFnName](this);
								} else if(opener[onchangeFnName] != undefined){
									opener[onchangeFnName](this);
								}
							};
						}

						var openerID		= CFN_GetQueryString("openerID");
						var targetArea		= "";
						var targetComboID	= "";

						if(openerID == "undefined"){
							targetArea	= accountCtrl.getInfo(target);
						}else{
							targetArea	= $("#" + target);
						}
						
						var targetChildren		= targetArea.children();
						var AttributeNameArr	= []
						var targetAttributes	= targetArea[0].attributes;
						
						for(var tas=0; tas<targetAttributes.length; tas++){
							AttributeNameArr.push(targetArea[0].attributes[tas].name)
						}

						if(targetChildren.length == 0){
							targetComboID			= accountCtrl.getViewPageDivID() + target + "Combo";
							var appendSelectArea	= "<select id=\""+targetComboID+"\" ";
							
							for(var attrNo = 0; attrNo<AttributeNameArr.length; attrNo++){
								if(AttributeNameArr[attrNo] == "id"){
									continue;
								}else{
									appendSelectArea += AttributeNameArr[attrNo] +" = \""+ targetArea[0].getAttribute(AttributeNameArr[attrNo]) + "\"";
									targetArea[0].removeAttribute(AttributeNameArr[attrNo]);
								}
								appendSelectArea += " ";
							}
							
							appendSelectArea += " ></select>";
							
							targetArea.append(appendSelectArea);
							
							$("#" + targetComboID).bindSelect(bindOption);
						}

						if(	oncomplete	!= null			&&
							oncomplete	!= undefined	&&
							oncomplete	!= ""){
							if(window[oncomplete] != undefined){
								window[oncomplete]();
							} else if(parent[oncomplete] != undefined){
								parent[oncomplete]();
							} else if(opener[oncomplete] != undefined){
								opener[oncomplete]();
							}
						}
					}
				}
			});
		},
		
		getTrimValue : function(key){
			if(key != undefined){
				key = key.trim();
			}
			return key
		},
		
		renderAXSelect : function(pCodeGroups, pTargets, lang, onchange, oncomplete, pDefaultVal, useDefault, pCompanyCode){
			
			if(pCompanyCode == undefined || pCompanyCode == "") {
				pCompanyCode = accComm.getCompanyCodeOfUser();
			}
			
			$.ajax({
				type:"POST",
				data:{
					"codeGroups" : pCodeGroups,
					"CompanyCode" : pCompanyCode
				},
				url:"/account/accountCommon/getBaseCodeCombo.do",
				async	: false,
				success	: function (data) {
					if(data.result == "ok"){
						if(	pCodeGroups == null	|| pCodeGroups == '' ||
							pTargets == null	|| pTargets == ''){
							return false;
						}
						
						var arrCodeGroup	= pCodeGroups.split(',');
						var arrTarget		= pTargets.split(',');
						var arrOnchange;
						if(onchange != null && onchange != ''){
							arrOnchange = onchange.split(',');	
						}
						var arrDefaultVal;
						if(pDefaultVal != null && pDefaultVal != '' && pDefaultVal != undefined){
							arrDefaultVal = pDefaultVal.split(',');	
						}
						
						for(var i = 0; i < arrCodeGroup.length; i++) {
							
							var selectOption = accountCtrl.makeAXSelectData(data.list, arrCodeGroup[i], lang, useDefault);
							var bindOption	= {
									reserveKeys: {
										optionValue	: "optionValue",
										optionText	: "optionText"
									},
									options: selectOption
								};
							
							if(arrDefaultVal != null && arrDefaultVal != undefined){
								bindOption.setValue = arrDefaultVal[i];	
							}else if((arrDefaultVal == null || arrDefaultVal == undefined) && arrCodeGroup[i] == "CompanyCode") { 
								bindOption.setValue = Common.getSession("DN_Code"); 
							}
							
							if(arrOnchange != null && arrOnchange != undefined){
								var onchangeFnName = arrOnchange[i];
								bindOption.onchange = function(){
									if(onchange != null){
										//method 호출
										if(onchangeFnName != null && onchangeFnName != ''){
											if(window[onchangeFnName] != undefined){
												window[onchangeFnName](this);
											} else if(parent[onchangeFnName] != undefined){
												parent[onchangeFnName](this);
											} else if(opener[onchangeFnName] != undefined){
												opener[onchangeFnName](this);
											}
										}
									}
								};
							}
							
							var openerID		= CFN_GetQueryString("openerID");
							var targetArea		= "";
							var targetComboID	= "";
							
							if(openerID == "undefined"){
								targetArea	= accountCtrl.getInfo(arrTarget[i]);
							}else{
								targetArea	= $("#" + arrTarget[i]);
							}

							var targetChildren		= targetArea.children();
							//var AttributeNameArr	= targetArea[0].getAttributeNames();
							//var AttributeNameArr	= ['id','class','onchange']
							var AttributeNameArr	= []
							var targetAttributes	= targetArea[0].attributes;
							
							for(var tas=0; tas<targetAttributes.length; tas++){
								AttributeNameArr.push(targetArea[0].attributes[tas].name)
							}
							
							if(targetChildren.length == 0){
								targetComboID			= accountCtrl.getViewPageDivID() + arrTarget[i] + "Combo";
								var appendSelectArea	= "<select id=\""+targetComboID+"\" ";
								
								for(var attrNo = 0; attrNo<AttributeNameArr.length; attrNo++){
									if(AttributeNameArr[attrNo] == "id"){
										continue;
									}else{
										appendSelectArea += AttributeNameArr[attrNo] +" = \""+ targetArea[0].getAttribute(AttributeNameArr[attrNo]) + "\"";
										targetArea[0].removeAttribute(AttributeNameArr[attrNo]);
									}
									appendSelectArea += " ";
								}
								
								appendSelectArea += " ></select>";
								
								targetArea.append(appendSelectArea);
								
								if(pTargets != "listCount") {
									$("#" + targetComboID).bindSelect(bindOption);
								} else {
									var optionStr = "";
									$(bindOption.options).each(function(i, obj) {
										optionStr += "<option value='" + obj.optionValue + "'>" + obj.optionText + "</option>";
									});
									$("#" + targetComboID).html(optionStr);
								}
							}
						}
						//method 호출
						
						if(oncomplete != null && oncomplete != ''){
							try{
								if(window[oncomplete] != undefined){
									window[oncomplete]();
								} else if(parent[oncomplete] != undefined){
									parent[oncomplete]();
								} else if(typeof(oncomplete)=='function'){
									oncomplete();
								} else if(opener[oncomplete] != undefined){
									opener[oncomplete]();
								}
							}
							catch(e){
								console.error(e)
							}
						}
						
					}
				},
				error:function (error){
					Common.Error(error.message);
				}
			});
		},

		/**
		 * 코드 그룹목록 조회
		 */
		renderAXSelectGrp : function(pTargets, lang, onchange, oncomplete, pDefaultVal, useDefault, pCompanyCode){
			
			if(pCompanyCode == undefined || pCompanyCode == "") {
				pCompanyCode = accComm.getCompanyCodeOfUser();
			}
			
			$.ajax({
				type:"POST",
				data:{
					"CompanyCode" : pCompanyCode
				},
				url:"/account/accountCommon/getBaseGrpCodeCombo.do",
				async	: false,
				success	: function (data) {
					if(data.result == "ok"){
						if(	pTargets == null	|| pTargets == ''){
							return false;
						}
						
						var CodeGroup	= "Group"

						var selectOption = accountCtrl.makeAXSelectData(data.list, CodeGroup, lang, useDefault);
						var bindOption	= {
								reserveKeys: {
									optionValue	: "optionValue",
									optionText	: "optionText"
								},
								options: selectOption
							};
						
						if(pDefaultVal != null && pDefaultVal != '' && pDefaultVal != undefined){
							bindOption.setValue = pDefaultVal;
						}
						

						if(onchange != null && onchange != ''){
							var onchangeFnName = onchange;
							bindOption.onchange = function(){
								if(onchange != null){
									//method 호출
									if(onchangeFnName != null && onchangeFnName != ''){
										if(window[onchangeFnName] != undefined){
											window[onchangeFnName](this);
										} else if(parent[onchangeFnName] != undefined){
											parent[onchangeFnName](this);
										} else if(opener[onchangeFnName] != undefined){
											opener[onchangeFnName](this);
										}
									}
								}
							};
						}
						
						var openerID		= CFN_GetQueryString("openerID");
						var targetArea		= "";
						var targetComboID	= "";
						
						if(openerID == "undefined"){
							targetArea	= accountCtrl.getInfo(pTargets);
						}else{
							targetArea	= $("#" + pTargets);
						}

						var targetChildren		= targetArea.children();
						//var AttributeNameArr	= targetArea[0].getAttributeNames();
						//var AttributeNameArr	= ['id','class','onchange']
						var AttributeNameArr	= []
						var targetAttributes	= targetArea[0].attributes;
						
						for(var tas=0; tas<targetAttributes.length; tas++){
							AttributeNameArr.push(targetArea[0].attributes[tas].name)
						}
						
						if(targetChildren.length == 0){
							targetComboID			= accountCtrl.getViewPageDivID() + pTargets + "Combo";
							var appendSelectArea	= "<select id=\""+targetComboID+"\" ";
							
							for(var attrNo = 0; attrNo<AttributeNameArr.length; attrNo++){
								if(AttributeNameArr[attrNo] == "id"){
									continue;
								}else{
									appendSelectArea += AttributeNameArr[attrNo] +" = \""+ targetArea[0].getAttribute(AttributeNameArr[attrNo]) + "\"";
									targetArea[0].removeAttribute(AttributeNameArr[attrNo]);
								}
								appendSelectArea += " ";
							}
							
							appendSelectArea += " ></select>";
							
							targetArea.append(appendSelectArea);
							
							$("#" + targetComboID).bindSelect(bindOption);
						}
						
						//method 호출
						if(oncomplete != null && oncomplete != ''){
							if(window[oncomplete] != undefined){
								window[oncomplete]();
							} else if(parent[oncomplete] != undefined){
								parent[oncomplete]();
							} else if(opener[oncomplete] != undefined){
								opener[oncomplete]();
							}
						}
						
					}
				},
				error:function (error){
					Common.Error(error.message);
				}
			});
		},
		
		refreshAXSelect : function(pTargets){
			if(	pTargets == null	|| pTargets == ''){
				return false;
			}
			var arrTarget		= pTargets.split(',');
			var bindOption	= {
					reserveKeys: {
						optionValue	: "optionValue",
						optionText	: "optionText"
					},
				};
			
			for(var i = 0; i < arrTarget.length; i++) {
				var targetComboID	= "";
				if(accountCtrl.getComboInfo(arrTarget[i])[0] != null){
					targetComboID		= accountCtrl.getComboInfo(arrTarget[i])[0].id;
					$("#" + targetComboID).bindSelect(bindOption);
				}
			}
		},
		
		makeAXSelectData : function(dataList, codeGroup, locale, useDefault){
			for(var i = 0; i < dataList.length; i++) {
			    var obj = dataList[i];
			    if(obj.hasOwnProperty(codeGroup)){
			    	var optionArray = new Array();
					if(useDefault!=null){
			    		var optionObj = new Object();
			    		optionObj.optionValue = "";
			    		optionObj.optionText = useDefault;	
						optionArray.push(optionObj);
					}
			    	var codeArray = obj[codeGroup];
			    	for(var j = 0; j < codeArray.length; j++) {
			    		var optionObj = new Object();
			    		var codeObj = codeArray[j];
			    		optionObj.optionValue = codeObj.Code;
				    	if(locale == null || locale == '' || locale == 'ko'){
				    		optionObj.optionText = codeObj.CodeName;	
				    	} else {
				    		//MultiCodeName으로 다국어 처리 할 것
				    	}
				    	optionArray.push(optionObj);
			    	}
			    }
			}
			return optionArray;
		},

		/*
		pTargets	: select의 ID
		data 		: 콤보의 데이터 목록
		useDefault	: 기본값
		dataField	: 데이터필드
		labelField	: 라벨필드
		*/
		createAXSelectData : function(pTargets, data, useDefault, dataField, labelField, onchange, oncomplete, pDefaultVal){
			var selectOption = accountCtrl.makeAXCustomSelectData(data, useDefault, dataField, labelField);
			var bindOption	= {
					reserveKeys: {
						optionValue	: "optionValue",
						optionText	: "optionText"
					},
					options: selectOption
				};
			
			if(pDefaultVal != null && pDefaultVal != undefined){
				bindOption.setValue = pDefaultVal;	
			}
			
			if(onchange != null && onchange != undefined){
				var onchangeFnName = onchange;
				bindOption.onchange = function(){
					if(onchange != null){
						//method 호출
						if(onchangeFnName != null && onchangeFnName != ''){
							if(window[onchangeFnName] != undefined){
								window[onchangeFnName](this);
							} else if(parent[onchangeFnName] != undefined){
								parent[onchangeFnName](this);
							} else if(opener[onchangeFnName] != undefined){
								opener[onchangeFnName](this);
							}
						}
					}
				};
			}
			
			var openerID		= CFN_GetQueryString("openerID");
			var targetArea		= "";
			var targetComboID	= "";

			if(openerID == "undefined"){
				targetArea	= accountCtrl.getInfo(pTargets);
			}else{
				targetArea	= $("#" + pTargets);
			}
			
			var targetChildren		= targetArea.children();
			var AttributeNameArr	= []
			var targetAttributes	= targetArea[0].attributes;
			
			for(var tas=0; tas<targetAttributes.length; tas++){
				AttributeNameArr.push(targetArea[0].attributes[tas].name)
			}

			if(targetChildren.length == 0){
				targetComboID			= accountCtrl.getViewPageDivID() + pTargets + "Combo";
				var appendSelectArea	= "<select id=\""+targetComboID+"\" ";
				
				for(var attrNo = 0; attrNo<AttributeNameArr.length; attrNo++){
					if(AttributeNameArr[attrNo] == "id"){
						continue;
					}else{
						appendSelectArea += AttributeNameArr[attrNo] +" = \""+ targetArea[0].getAttribute(AttributeNameArr[attrNo]) + "\"";
						targetArea[0].removeAttribute(AttributeNameArr[attrNo]);
					}
					appendSelectArea += " ";
				}
				
				appendSelectArea += " ></select>";
				
				targetArea.append(appendSelectArea);
				
				$("#" + targetComboID).bindSelect(bindOption);
			}
		},

		makeAXCustomSelectData : function(dataList, useDefault, inputDataField, inputLabelField){
	    	var optionArray = new Array();
			if(useDefault!=null){
	    		var optionObj = new Object();
	    		optionObj.optionValue = "";
	    		optionObj.optionText = useDefault;	
				optionArray.push(optionObj);
			}
	    	var codeArray = dataList;
	    	var dataField = inputDataField;
	    	var labelField = inputLabelField;
	    	if(inputDataField==null || inputDataField==undefined || inputDataField==''){
	    		dataField = 'data'		    	}
	    	if(inputLabelField==null || inputLabelField==undefined || inputLabelField==''){
	    		labelField = 'label'
	    	}
	    	
	    	for(var j = 0; j < codeArray.length; j++) {
	    		var optionObj = new Object();
	    		var codeObj = codeArray[j];
	    		optionObj.optionValue = codeObj[dataField];
	    		optionObj.optionText = codeObj[labelField];	
		    	optionArray.push(optionObj);
	    	}
			return optionArray;
		},
		/////////////////////////////////////////////////////////////////////////////////////////////
		//관리항목
		/////////////////////////////////////////////////////////////////////////////////////////////
		_setCtrlField : async function(me, CtrlCode, KeyNo, Rownum, ProofCode,divItem,type) {
			var openerID = CFN_GetQueryString("openerID");
			if(openerID=='undefined'){
				this.setCtrlFieldC(me, CtrlCode, KeyNo, Rownum, ProofCode,divItem,type);
			}else{
				await this.setCtrlFieldP(me, CtrlCode, KeyNo, Rownum, ProofCode,divItem,type);
			} 
		},
		//setCtrlFieldC : 신청서, setCtrlFieldP 수정팝업 //type DEL, ADD, undefined
		setCtrlFieldC : function(me, CtrlCode, KeyNo, Rownum, ProofCode,divItem,type) {
			if(type=='DEL'||type=='ADD') {
				accountCtrl.getInfoStr("[code='"+CtrlCode+"'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").closest("dl").remove();
				if(type=='DEL')return;
			}else{
				accountCtrl.getInfoStr("[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").remove();
			}
			if(CtrlCode == "" || CtrlCode == undefined) return;
            var AccountCtrlMap;
            if(me.ApplicationType=="SC"){
            	AccountCtrlMap = me.pageSimpAppComboData.AccountCtrlMap;
			}else if(me.ApplicationType=="CO"){
            	AccountCtrlMap = me.pageCombiAppComboData.AccountCtrlMap;
			}
            //ctrlcode 값을 배열로 저장
            var arrCtrl = [];
            var idx = 0;
            $.each(CtrlCode.split(","), function(i, item) {
            	//arrCtrl[idx++] = AccountCtrlMap[item];
            	var ctrlItem = AccountCtrlMap[item];
            	if(!ctrlItem) return true;
            	arrCtrl[idx++] = ctrlItem;
            });

            //정렬한 값을 표시
            var html = "";
            //var evalText = "";
            var evalFnArr = [];
            $.each(arrCtrl, function(i, item) {
                var keyno = KeyNo;
                var rownum = Rownum;
                var proofCode = ProofCode;
                var code = item.Code;
                var id= 'ctrl_' + proofCode + '_'+ code + '_' + keyno + '_' + rownum;
                var isNumberStyle = "", isNumberEvent = "";
                if(item.Reserved3 == "numeric"){
                    isNumberStyle = ' text-align: right; ';
                    isNumberEvent = ' accountCtrl.toAmtFormatCtrl(this); ';
                }
            	var requiredStar='';
            	if(item.Reserved2=='required')
            		requiredStar = '<span class="star"></span>'
                if(item.Reserved1.indexOf("input") > -1){  //INPUT
                    var inputwidth = "";
                    if(item.Reserved1 == "shortinput") inputwidth = "width:86px;";
                    else if(item.Reserved1 == "middleinput") inputwidth = "width:315px;";
                    else if(item.Reserved1 == "longinput") inputwidth = "width:630px;";
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dt style="width: 115px;">' + item.CodeName + requiredStar+'</dt><dd style="line-height: 1;">';
                    html += '<input type="text" code="' + code + '" id="' + id + '" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" '
                        + 'style="' + inputwidth + isNumberStyle + '" requiredVal="' + item.Reserved2 + '" value="'+(item.Reserved3 == "numeric"?0:'')+'"'
                        + 'onkeyup="' + isNumberEvent + ' accountCtrl._onSaveJson('+me.pageName+', this, \'CtrlArea\', \'' + proofCode + '\', \'' + keyno + '\', \'' + rownum + '\')"/>';
                    html += "</dd>";
                }else if(item.Reserved1 == "date"){  //DATE
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dt style="width: 115px;">' + item.CodeName + requiredStar+ '</dt><dd style="line-height: 1;">';
                    html += '<div class="dateSel type02" code="' + code + '" id="' + id + '" name="" viewTarget="' + id 
                        + '_Date" viewType = "Date" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" requiredVal="' + item.Reserved2 + '" '
                        + 'onchange="accountCtrl._onSaveJson('+me.pageName+', this, \'CtrlArea\',\'' + proofCode + '\', \'' + keyno + '\', \'' + rownum + '\')"></div></dd>';
                    
                    //evalText += "makeDatepicker('" + id + "', '" + id + "_Date', null, null, null, 100,null, 'code;" + code + "|requiredVal;" + item.Reserved2 + "');";
                   	evalFnArr.push({fn: makeDatepicker, args:[id, id+"_Date",null, null, null, 100, null, "code;"+code+"|requiredVal;"+item.Reserved2]});
                }else if(item.Reserved1 == "popup"){  //POPUP
                    var hid_id= 'ctrl_' + proofCode + '_hid'+ code + '_' + keyno + '_' + rownum;
                    var isMethodEvent = ""
                    if(item.Reserved3 != ""){
                        isMethodEvent = me.pageName+ '.' + item.Reserved3 + '(this, \'' + item.CodeName + '\'); ';
                    }
                    
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dt style="width: 115px;">' + item.CodeName+ requiredStar + '</dt><dd style="line-height: 1;">';
                    html += '<div class="searchBox02" style="width: 152px; display:inline-block;"><span>';
                    html += '<input type="hidden" id="' + hid_id + '" value=""'
                        + 'code="'+ code + '" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" popup="code" >';
                    html += '<input type="text" id="' + id + '" value="" requiredVal="' + item.Reserved2 + '" '
                        + 'code="' + code + '" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" popup="value" '
                        + 'style="border:none; height:23px;font-weight:normal;width: 120px;" disabled="disabled">';
                    html += '<button type="button" class="btnSearchType01" onClick="' + isMethodEvent + '"><spring:message code="Cache.ACC_btn_search"/></button></span></div>';
                    html += ' <span style="vertical-align: middle;" tag="span" code="' + code + '_desc" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '"></span></dd>';
                }else if(item.Reserved1 == "checkbox"){  //CHECKBOX
                    var isMethodEvent = ""
                    if(item.Reserved3 != ""){
                        isMethodEvent = me.pageName+ '.' + item.Reserved3 + '(this); ';
                    }
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dd style="line-height: 1;"><input type="checkbox" style="margin: 0 6px;" code="' + code + '" id="' + id + '" name="ctrl_' + item.Reserved3 + '"';
                    html += ' keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" value="" requiredVal="' + item.Reserved2 + '"';
                    html += ' onclick="' + isMethodEvent + 'accountCtrl._onSaveJson('+me.pageName+', this, \'CtrlArea\', \'' + proofCode + '\', \'' + keyno + '\', \'' + rownum + '\')" />';
                    html += "&nbsp; " + item.CodeName + "</dd>";
                }else if(item.Reserved1 == "select"){  //SELECT
                	var isMethodEvent = ""
                    if(item.Reserved3 != ""){
                    	isMethodEvent = me.pageName+ '.' + item.Reserved3 + '(this); ';
                    }
                	var name = item.Reserved4;
                	name = isEmptyStr(name)?"ETC":name;
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dt style="width: 115px;">' + item.CodeName + requiredStar+ '</dt><dd style="line-height: 1;">';
                    html += '<select class="selectType02" code="' + code + '" id="' + id + '" name="ctrl_' + name + '" tag="select" type="' + name+ '"';
                    html += ' keyno="' + keyno + '" rownum="' + rownum + '" proofcd="' + proofCode + '"';
                    html += ' onchange="' + isMethodEvent + ' accountCtrl._onSaveJson('+me.pageName+', this, \'CtrlArea\',\'' + proofCode + '\', \'' + keyno + '\', \'' + rownum + '\')"';
                    html += ' style="width: 120px;" requiredVal="' + item.Reserved2 + '">';
                	
                   
                    var appendChild = "<option value=''>"+ Common.getDic("ACC_lbl_choice") +"</option>";
                    if(!isEmptyStr(item.Reserved4)){

                        $.ajax({
    						type:"POST",
    						url:"/account/accountCommon/getBaseCodeData.do",
    						data:{
    							codeGroups : item.Reserved4,
    							CompanyCode : me.CompanyCode
    						},
    						async: false,
    						success:function (data) {
    							if(data.result == "ok"){
    								var List = data.list[item.Reserved4];
    								
    								for(var i = 0; i < List.length; i++) { 
    									appendChild = appendChild + "<option value=\"" + List[i]["Code"] + "\">" + List[i]["CodeName"] + "</option>";
    								}
    							}
    							else{
    								Common.Error(data);
    							}
    						},
    						error:function (error){
    							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
    						}
    					});
                    }
                    html += appendChild;
                    html += '</select></dd>';
                }
                html += "</dl>";
            });
            
            if(me.ApplicationType=="SC") {
            	if(accountCtrl.getInfoStr("[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").length > 0) {
            		accountCtrl.getInfoStr("[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'] :last").closest("dl").after(html);
            	} else {
            		accountCtrl.getInfoStr("[name='CostCenterField'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").closest("dl").after(html);
            	}
            	
            	//증빙분할 관리항목 스타일 제거
            	$("[name='DivAddArea'] dl[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").css({'display':'inline-table', 'width':'auto', 'margin':'0px 20px 7px 0px !important'});
            	$("[name='DivAddArea'] [name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'] dt").css({'display':'table-cell', 'font-weight':'bold', 'vertical-align':'middle'});
            	$("[name='DivAddArea'] [name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'] dd").css({'display':'table-cell', 'vertical-align':'top'});
            } else if(me.ApplicationType=="CO") {
            	accountCtrl.getInfoStr("[name='AccCtrlField'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").append(html);
            }
            
            //보안취약점 조치.
            //eval(evalText);
            for(var ei = 0; ei < evalFnArr.length; ei++){
				let callInfo = evalFnArr[ei];
				let fn = callInfo["fn"]; // function
				let args = callInfo["args"]; // array
				fn.apply(null, args);
			}
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            if(divItem=="" || divItem== undefined || divItem == null)return;
            var ctrlJsonVal = divItem.ReservedStr2_Div;
            var ctrlJsonVal2 = divItem.ReservedStr3_Div;
            if(ctrlJsonVal == "" || ctrlJsonVal == undefined) return;
            /*//임시..
            ctrlJsonVal =  ctrlJsonVal.replace(/\\/gi, '');
            ctrlJsonVal2 =  ctrlJsonVal2.replace(/\\/gi, '')*/
            var ctrlJsonParse = ctrlJsonVal;
            var ctrlJsonParse2 = ctrlJsonVal2;
            //값 바인딩
            $.each(ctrlJsonParse, function(key, value){
                if(accountCtrl.getInfoStr("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").length > 0){
                    if(accountCtrl.getInfoStr("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").attr("type") == "checkbox"){
                        if(value == "Y"){
                            accountCtrl.getInfoStr("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").prop("checked", true);
                        }
                    }
                    accountCtrl.getInfoStr("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").val(value);
                }else if(accountCtrl.getInfoStr("div[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").length > 0){
                    accountCtrl.getInfoStr("div[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").find("input[code='" + key + "']").val(value);
                }else if(accountCtrl.getInfoStr("span[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").length > 0){
                    accountCtrl.getInfoStr("span[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").text(value);
                }
                /*else{
                    accountCtrl.getInfoStr("select[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").val(value).prop("selected", true);
                }*/
            });
            //코드값 바인딩
            $.each(ctrlJsonParse2, function(key, value){
                if(accountCtrl.getInfoStr("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "'][popup='code']").length > 0){
                    if(typeof value == "object"){
                        accountCtrl.getInfoStr("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "'][popup='code']").val(JSON.stringify(value));
                    }else{
                        accountCtrl.getInfoStr("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "'][popup='code']").val(value);
                    }
                }
                else if(accountCtrl.getInfoStr("select[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").length > 0){
                    accountCtrl.getInfoStr("select[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").val(value).prop("selected", true);
                    if(!(type=='DEL'||type=='ADD'))accountCtrl.getInfoStr("select[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").trigger("onchange");
                }  
            });
		},
		getAccountCtrlMap: async function(companyCode) {
			accountCtrl.AccountCtrlMap = new Object();
			await accFetch("/account/accountCommon/getBaseCodeDataAll.do", "GET", {
				codeGroups: "AccountCtrl",
				CompanyCode: companyCode
			}).then((json) => {
				if (json.result == "ok") {
					let codeList = json.list.AccountCtrl;
					for (const element of codeList) {
						accountCtrl.AccountCtrlMap[element["Code"]] = element;
					}
				} else {
					Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
				}
			});
		},
		setCtrlFieldP : async function(me, CtrlCode, KeyNo, Rownum, ProofCode,divItem,type) {
			var companyCode = me.CompanyCode == undefined || me.CompanyCode == "" ? me.pageExpenceAppObj.CompanyCode : me.CompanyCode;
			var applicationType = me.ApplicationType == undefined || me.ApplicationType == "" ? me.pageExpenceAppObj.ApplicationType : me.ApplicationType;
			
			if(type=='DEL'||type=='ADD')
			{
				$("[code='"+CtrlCode+"'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").closest("dl").remove();
				if(type=='DEL')return;
			}
			else
				$("[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").remove();
				
			if(CtrlCode == "" || CtrlCode == undefined) return;
			if(Object.keys(accountCtrl.AccountCtrlMap).length == 0) { await accountCtrl.getAccountCtrlMap(companyCode); }
			
            //ctrlcode 값을 배열로 저장
            var arrCtrl = [];
            var idx = 0;
            $.each(CtrlCode.split(","), function(i, item) {
            	//arrCtrl[idx++] = accountCtrl.AccountCtrlMap[item];
            	var ctrlItem = accountCtrl.AccountCtrlMap[item];
            	if(!ctrlItem) return true;
            	arrCtrl[idx++] = ctrlItem;
            });
            
            //정렬한 값을 표시
            var html = "";
            //var evalText = "";
            var evalFnArr = [];
            $.each(arrCtrl, function(i, item) {
                var keyno = KeyNo;
                var rownum = Rownum;
                var proofCode = ProofCode;
                var code = item.Code;
                var id= 'ctrl_' + proofCode + '_'+ code + '_' + keyno + '_' + rownum;
                var isNumberStyle = "", isNumberEvent = "";
                if(item.Reserved3 == "numeric"){
                    isNumberStyle = ' text-align: right; ';
                    isNumberEvent = ' accountCtrl.toAmtFormatCtrl(this); ';
                }

            	var requiredStar='';
            	if(item.Reserved2=='required')
            		requiredStar = '<span class="star"></span>'
                if(item.Reserved1.indexOf("input") > -1){  //INPUT
                    var inputwidth = "";
                    if(item.Reserved1 == "shortinput") inputwidth = "width:86px;";
                    else if(item.Reserved1 == "middleinput") inputwidth = "width:315px;";
                    else if(item.Reserved1 == "longinput") inputwidth = "width:630px;";
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dt style="width: 115px;">' + item.CodeName + requiredStar+ '</dt><dd style="line-height: 1;">';
                    html += '<input type="text" code="' + code + '" id="' + id + '" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" '
                        + 'style="' + inputwidth + isNumberStyle + '" requiredVal="' + item.Reserved2 + '" value="'+(item.Reserved3 == "numeric"?0:'')+'"'
                        + 'onkeyup="' + isNumberEvent + ' accountCtrl._onSaveJson('+me.pageName+', this, \'CtrlArea\', \'' + proofCode + '\', \'' + keyno + '\', \'' + rownum + '\')"/>';
                    html += "</dd>";
                }else if(item.Reserved1 == "date"){  //DATE
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dt style="width: 115px;">' + item.CodeName + requiredStar+ '</dt><dd style="line-height: 1;">';
                    html += '<div class="dateSel type02" code="' + code + '" id="' + id + '" name="" viewTarget="' + id 
                        + '_Date" viewType = "Date" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" requiredVal="' + item.Reserved2 + '" '
                        + 'onchange="accountCtrl._onSaveJson('+me.pageName+', this, \'CtrlArea\',\'' + proofCode + '\', \'' + keyno + '\', \'' + rownum + '\')"></div></dd>';
                    
                    //evalText += "makeDatepicker('" + id + "', '" + id + "_Date', null, null, null, 100,null, 'code;" + code + "|requiredVal;" + item.Reserved2 + "');";
                    evalFnArr.push({fn: makeDatepicker, args:[id, id+"_Date",null, null, null, 100, null, "code;"+code+"|requiredVal;"+item.Reserved2]});
                }else if(item.Reserved1 == "popup"){  //POPUP
                    var hid_id= 'ctrl_' + proofCode + '_hid'+ code + '_' + keyno + '_' + rownum;
                    var isMethodEvent = ""
                    if(item.Reserved3 != ""){
                        isMethodEvent = me.pageName+ '.' + item.Reserved3 + '(this, \'' + item.CodeName + '\'); ';
                    }
                    
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dt style="width: 115px;">' + item.CodeName + requiredStar+ '</dt><dd style="line-height: 1;">';
                    html += '<div class="searchBox02" style="width: 152px; display:inline-block;"><span>';
                    html += '<input type="hidden" id="' + hid_id + '" value=""'
                        + 'code="'+ code + '" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" popup="code" >';
                    html += '<input type="text" id="' + id + '" value="" requiredVal="' + item.Reserved2 + '" '
                        + 'code="' + code + '" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" popup="value" '
                        + 'style="border:none; height:23px;font-weight:normal;width: 120px;" disabled="disabled">';
                    
                    html += '<button type="button" class="btnSearchType01" onClick="' + isMethodEvent + '"><spring:message code="Cache.ACC_btn_search"/></button></span></div>';
                    html += ' <span style="vertical-align: middle;" tag="span" code="' + code + '_desc" keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '"></span></dd>';
                }else if(item.Reserved1 == "checkbox"){  //CHECKBOX
                    var isMethodEvent = ""
                    if(item.Reserved3 != ""){
                        isMethodEvent = me.pageName+ '.' + item.Reserved3 + '(this); ';
                    }
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dd style="line-height: 1;"><input type="checkbox" style="margin: 0 6px;" code="' + code + '" id="' + id + '" name="ctrl_' + item.Reserved3 + '"';
                    html += ' keyno="' + keyno + '" proofcd="' + proofCode + '" rownum="' + rownum + '" value="" requiredVal="' + item.Reserved2 + '"';
                    html += ' onclick="' + isMethodEvent + 'accountCtrl._onSaveJson('+me.pageName+', this, \'CtrlArea\', \'' + proofCode + '\', \'' + keyno + '\', \'' + rownum + '\')" />';
                    html += "&nbsp; " + item.CodeName + "</dd>";
                }else if(item.Reserved1 == "select"){  //SELECT
                	var isMethodEvent = ""
                    if(item.Reserved3 != ""){
                    	isMethodEvent = me.pageName+ '.' + item.Reserved3 + '(this); ';
                    }

                	var name = item.Reserved4;
                	name = isEmptyStr(name)?"ETC":name;
                    html += "<dl name='CtrlArea' keyno='" + keyno + "' rownum='" + rownum + "'>";
                    html += '<dt style="width: 115px;">' + item.CodeName + requiredStar+ '</dt><dd style="line-height: 1;">';
                    html += '<select class="selectType02" code="' + code + '" id="' + id + '" name="ctrl_' + name + '" tag="select" type="' + name+ '"';
                    html += ' keyno="' + keyno + '" rownum="' + rownum + '" proofcd="' + proofCode + '"';
                    html += ' onchange="' + isMethodEvent + ' accountCtrl._onSaveJson('+me.pageName+', this, \'CtrlArea\',\'' + proofCode + '\', \'' + keyno + '\', \'' + rownum + '\')"';
                    html += ' style="width: 120px;" requiredVal="' + item.Reserved2 + '">';

                    
                    var appendChild = "<option value=''>"+ Common.getDic("ACC_lbl_choice") +"</option>";
                    if(!isEmptyStr(item.Reserved4)){

                        $.ajax({
    						type:"POST",
    						url:"/account/accountCommon/getBaseCodeData.do",
    						data:{
    							codeGroups : item.Reserved4,
    							CompanyCode : me.CompanyCode
    						},
    						async: false,
    						success:function (data) {
    							if(data.result == "ok"){
    								var List = data.list[item.Reserved4];
    								
    								for(var i = 0; i < List.length; i++) { 
    									appendChild = appendChild + "<option value=\"" + List[i]["Code"] + "\">" + List[i]["CodeName"] + "</option>";
    								}
    							}
    							else{
    								Common.Error(data);
    							}
    						},
    						error:function (error){
    							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
    						}
    					});
                    }
                    html += appendChild;
                    html += '</select></dd>';
                } 
                html += "</dl>";
            });
            
            if(applicationType=="SC") {
            	if($("[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").length > 0) {
            		$("[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'] :last").closest("dl").after(html);
            	} else {
            		$("[name='CostCenterField'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").closest("dl").after(html);
            	}
            	
            	//증빙분할 관리항목 스타일 제거
            	$("[name='DivAddArea'] dl[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").css({'display':'inline-table', 'width':'auto', 'margin':'0px 20px 7px 0px !important'});
            	$("[name='DivAddArea'] [name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'] dt").css({'display':'table-cell', 'font-weight':'bold', 'vertical-align':'middle'});
            	$("[name='DivAddArea'] [name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'] dd").css({'display':'table-cell', 'vertical-align':'top'});
            } else if(applicationType=="CO") {
            	$("[name='AccCtrlField'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").append(html);
            }
            
            //보안취약점 조치.
            //eval(evalText);
            for(var ei = 0; ei < evalFnArr.length; ei++){
				let callInfo = evalFnArr[ei];
				let fn = callInfo["fn"]; // function
				let args = callInfo["args"]; // array
				fn.apply(null, args);
			}
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            if(divItem=="" || divItem== undefined || divItem == null)return;
            var ctrlJsonVal = divItem.ReservedStr2_Div;
            var ctrlJsonVal2 = divItem.ReservedStr3_Div;
            if(ctrlJsonVal == "" || ctrlJsonVal == undefined) return;
            /*//임시..
            ctrlJsonVal =  ctrlJsonVal.replace(/\\/gi, '');
            ctrlJsonVal2 =  ctrlJsonVal2.replace(/\\/gi, '')*/
            var ctrlJsonParse = ctrlJsonVal;
            var ctrlJsonParse2 = ctrlJsonVal2;
            //값 바인딩
            $.each(ctrlJsonParse, function(key, value){
                if($("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").length > 0){
                    if($("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").attr("type") == "checkbox"){
                        if(value == "Y"){
                            $("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").prop("checked", true);
                        }
                    }
                    $("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").val(value);
                }else if($("div[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").length > 0){
                    $("div[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").find("input[code='" + key + "']").val(value);
                }else if($("span[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").length > 0){
                    $("span[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").text(value);
                }
                /*else{
                    $("select[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").val(value).prop("selected", true);
                }*/
            });
            //코드값 바인딩
            $.each(ctrlJsonParse2, function(key, value){
                if($("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "'][popup='code']").length > 0){
                    if(typeof value == "object"){
                        $("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "'][popup='code']").val(JSON.stringify(value));
                    }else{
                        $("input[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "'][popup='code']").val(value);
                    }
                }
                else if($("select[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").length > 0){
                    $("select[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").val(value).prop("selected", true);
                    if(!(type=='DEL'||type=='ADD')) $("select[keyno='" + KeyNo + "'][rownum='" + Rownum + "'][code='" + key + "']").trigger("onchange");
                }
            });
		},
		
		_onSaveJson : function(me, obj, nameType, ProofCode, keyno, Rownum) {
			var openerID = CFN_GetQueryString("openerID");
			if(openerID=='undefined')
				this.onSaveJsonC(me, obj, nameType, ProofCode, keyno, Rownum);
			else 
				this.onSaveJsonP(me, obj, nameType, ProofCode, keyno, Rownum);
		},
		onSaveJsonC : function (me, obj, nameType, ProofCode, keyno, Rownum) {
            var resValJson;
            var resJson;
            var jObjValJson = new Object();
            var jObjJson = new Object();
            accountCtrl.getInfoStr("[name='" + nameType + "'][keyno='" + keyno + "'][Rownum='"+Rownum+"']").each(function (i, item) {
                var eachItem;
                var popid = "";
                eachItem = $(item).find("input[code],select[code],span[code]");
                $.each(eachItem, function(j, jtem){
                	var val = $(jtem).val(); val = isEmptyStr(val)?'':val;
                	var text = $(jtem).text(); text = isEmptyStr(text)?'':text;
                    if($(jtem).attr("popup") != undefined){
                        if($(jtem).attr("popup") == "value"){
                            jObjValJson[$(jtem).attr("code") ] =  val;
                        }else{
                        	jObjJson[$(jtem).attr("code")] =  val;
                        }
                    }else if($(jtem).attr("tag") == "span"){
                        jObjValJson[$(jtem).attr("code") ] =  text;
                        jObjJson[$(jtem).attr("code")] =  text;
                    }else if($(jtem).attr("tag") == "select"){
                        jObjValJson[$(jtem).attr("code") ] =  $(jtem).find("option:checked").text();
                        jObjJson[$(jtem).attr("code")] = val;
                    }else{
                        jObjValJson[$(jtem).attr("code") ] =  val;
                        jObjJson[$(jtem).attr("code")] =  val;
                    }
                    popid = $(jtem).attr("code");
                });
               
            });
           /* resValJson = JSON.stringify(jObjValJson ); 
            resJson = JSON.stringify(jObjJson );   */
            resValJson = jObjValJson;
            resJson = jObjJson;
            if(me.ApplicationType=="SC")
        	{
            	me.simpApp_divInputChange(obj, ProofCode, keyno, Rownum, resValJson, "1");
                me.simpApp_divInputChange(obj, ProofCode, keyno, Rownum, resJson, "2");	
            }
            else if(me.ApplicationType=="CO")
        	{
            	me.combiCostApp_divInputChange(obj, ProofCode, keyno, Rownum, resValJson, "1");
                me.combiCostApp_divInputChange(obj, ProofCode, keyno, Rownum, resJson, "2");	
            }
        },
        onSaveJsonP : function (me, obj, nameType, ProofCode, keyno, Rownum) {
			var applicationType = me.ApplicationType == undefined || me.ApplicationType == "" ? me.pageExpenceAppObj.ApplicationType : me.ApplicationType;
			
            var resValJson;
            var resJson;
            var jObjValJson = new Object();
            var jObjJson = new Object();
            
            $("[name='" + nameType + "'][keyno='" + keyno + "'][Rownum='"+Rownum+"']").each(function (i, item) {
                var eachItem;
                var popid = "";
                eachItem = $(item).find("input[code],select[code],span[code]");
                $.each(eachItem, function(j, jtem){
                	var val = $(jtem).val(); val = isEmptyStr(val)?'':val;
                	var text = $(jtem).text(); text = isEmptyStr(text)?'':text;
                	if($(jtem).attr("popup") != undefined){
                        if($(jtem).attr("popup") == "value"){
                            jObjValJson[$(jtem).attr("code") ] =  val;
                        }else{
                        	jObjJson[$(jtem).attr("code")] =  val;
                        }
                    }else if($(jtem).attr("tag") == "span"){
                        jObjValJson[$(jtem).attr("code") ] =  text;
                        jObjJson[$(jtem).attr("code")] =  text;
                    }else if($(jtem).attr("tag") == "select"){
                        jObjValJson[$(jtem).attr("code") ] =  $(jtem).find("option:checked").text();
                        jObjJson[$(jtem).attr("code")] = val;
                    }else{
                        jObjValJson[$(jtem).attr("code") ] =  val;
                        jObjJson[$(jtem).attr("code")] =  val;
                    }
                    popid = $(jtem).attr("code");
                });
               
            });
           /* resValJson = JSON.stringify(jObjValJson ); 
            resJson = JSON.stringify(jObjJson );   */
            resValJson = jObjValJson;
            resJson = jObjJson;
            if(applicationType=="SC")
        	{
            	me.simpApp_divInputChange(obj, ProofCode, keyno, Rownum, resValJson, "1");
                me.simpApp_divInputChange(obj, ProofCode, keyno, Rownum, resJson, "2");	
            }
            else if(applicationType=="CO")
        	{
            	me.combiCostApp_divInputChange(obj, ProofCode, keyno, Rownum, resValJson, "1");
                me.combiCostApp_divInputChange(obj, ProofCode, keyno, Rownum, resJson, "2");	
            }
        },
      
        _modifyItemJson : function(me, CtrlCode, KeyNo, Rownum, ProofCode,Item,type){
			var openerID = CFN_GetQueryString("openerID");
			var CtrlItem =null;
			if(type=='DEL')
			{
				if(!isEmptyStr(Item.ReservedStr2_Div))
				{
					delete Item.ReservedStr2_Div[CtrlCode];
					delete Item.ReservedStr2_Div[CtrlCode+"_desc"];
					delete Item.ReservedStr3_Div[CtrlCode];
					delete Item.ReservedStr3_Div[CtrlCode+"_desc"];
				}
			}
			else{
				if(!Item.ReservedStr2_Div.hasOwnProperty(CtrlCode))
				{
					Item.ReservedStr2_Div[CtrlCode]='';
					Item.ReservedStr3_Div[CtrlCode]='';
					//Item.ReservedStr3_Div['D02_desc']='';
				}
				CtrlItem = $.extend(true, {}, Item); 
				$.each(CtrlItem.ReservedStr2_Div, function (index, item) {
					if(index.indexOf(CtrlCode)==-1)delete CtrlItem.ReservedStr2_Div[index];
				});
				$.each(CtrlItem.ReservedStr3_Div, function (index, item) {
					if(index.indexOf(CtrlCode)==-1)delete CtrlItem.ReservedStr3_Div[index];
				})
			}
			
			this._setCtrlField(me, CtrlCode, KeyNo, Rownum, ProofCode,CtrlItem,type);
		},
        
        toAmtFormatCtrl: function (obj) {
            
            var val = $(obj).val();

            val = val.replace(/[^0-9,-.]/g, "");
            var numVal = ckNaN(AmttoNumFormat(val));
            if (numVal > 99999999999) {
                numVal = 99999999999;
            }
            val = numVal;
            obj.value = toAmtFormat(numVal);

        }
	}
	
	window.accountCtrl = accountCtrl;
})(window);
