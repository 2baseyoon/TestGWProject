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
///<createDate>2017.06.22</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///권한지정 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/

/// <summary>

/// 조직도 유형(Type): 대상 1자리(A/B/C/D) + 구분1자리(0/1/2)
/// [A0: 직원 조회용(2열)]
/// [B1: 사용자 선택(3열-1명만)]
/// [B9: 사용자 선택(3열-여러명)]
/// [C1: 그룹 선택(3열-1개만)]
/// [C9: 그룹 선택(3열-여러개)]
/// [D1: 사용자/그룹 선택(3열-1개만)]
/// [D9: 사용자/그룹 선택(3열-여러개) [Default]]

/// Tree 종류[TreeKind]
/// [Dept - 부서(부서 조직도만 필요시)]
/// [Group - 그룹(권한 설정, 사용자 검색 등) : 부서, 그룹(배포그룹 제외)]

/// </summary>
//# sourceURL=covision.orgchart.js
var coviOrg = (function () {
	var coviOrgObj={};
	
	var orgDic =  Common.getDicAll(["lbl_officer", "lbl_apv_deptsearch", "btn_Confirm","btn_Close", "lbl_apv_person","btn_apv_search",
	                                ,"msg_OrgMap03","msg_OrgMap04","msg_OrgMap05","msg_OrgMap06","lbl_name","lbl_dept" , "msg_EnterSearchword"
	                                ,"lbl_MobilePhone", "lbl_apv_InPhone", "lbl_Role", "lbl_JobPosition","lbl_JobLevel","msg_NoDataList", "lbl_CompanyNumber"
	                                ,"OrgTreeKind_Dept","OrgTreeKind_Group", "lbl_UserProfile", "lbl_DeptOrgMap" , "lbl_group","lbl_OpenAll","lbl_CloseAll", "lbl_apv_recinfo_td2"
									,"lbl_com_exportAddress", "lbl_apv_appMail", "lbl_com_Absense", "lbl_com_searchByName", "lbl_com_searchByDept", "lbl_com_searchByPhone"
									, "lbl_com_searchByRole", "lbl_com_searchByJobPosition", "lbl_com_searchByJobLevel", "lbl_Mail_Contact"
									,"CPMail_Dept","CPMail_Contact", "CPMail_Personal", "CPMail_Company"]);
	
	var sessionObj = Common.getSession();
	var lang = sessionObj["lang"];
	var ProfileImagePath = Common.getBaseConfig("ProfileImagePath").replace("/{0}", ""); //프로필 이미지 경로
	var companyCode = CFN_GetQueryString("companyCode") == "undefined" ? sessionObj["DN_Code"] : CFN_GetQueryString("companyCode");
	var useAffiliateSearch = Common.getBaseConfig("useAffiliateSearch");
	
	var $this = coviOrgObj;
	var tmpSearchWord = "";
	var BizCardShareType = "";
	var searchList = "groupTree";
	
	coviOrgObj.groupTree = new AXTree();
	
	if (Common.getBaseConfig("orgchartTreeCheckAll") == 'N'){
		coviOrgObj.groupTree.gridCheckClick = function(){}
	}
	
	coviOrgObj.config = {
			targetID: '',
			type:'D9',
			treeKind:'Dept',
			drawOpt:'LMARB', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
			callbackFunc: '', 
			openerID:'',
			allCompany: useAffiliateSearch,     /// 타 계열사 검색 허용 여부
			groupDivision: '',
			communityId: '',
			bizcardKind:'',
			onlyMyDept:'N',
			userParams:'',
			dragEndFunc:'', // dragend event name
			defaultValue:'',
			loadMyDept:'',
	}; 
	
	
	coviOrgObj.imgError = function(image) {
	    image.onerror = "";
	    image.src = "/covicore/resources/images/no_profile.png";
	    return true;
	}
	
	//public 함수 
	coviOrgObj.render = function(orgOpt){
		setConfig(orgOpt);
		insertBasicHTML();
		setSelect();
		
		if($this.config.drawOpt.charAt(0)=="L"){
			if($this.config.loadMyDept=="N")
			{
				setInitGroupTreeData("N"); //loadMyDept
			}
			else{
				setInitGroupTreeData("Y"); //loadMyDept
			}
		}
		
		setSelectedData();
	
		$(document).on("click", "a[id='changeGroupTree']", function(){
			searchList = "groupTree";
			changeMenu("groupTreeDiv");
			$(".appListBot").attr("style", "height: calc(100% - " + $(".appListTop").outerHeight() + "px) !important; margin-top:" + $(".appListTop").outerHeight() + "px !important;");
		});
		$(document).on("click", "a[id='changeBizCard']", function(){
			$("#divTabTray").find("a").parent().removeClass("active");
			$("#bizCardListAll").parent().addClass("active");
			searchList = "bizCard";
			changeMenu("BizCardDiv");
			$(".appListBot").attr("style", "height: calc(50% - " + $(".appListTop").outerHeight() + "px) !important; margin-top:" + $(".appListTop").outerHeight() + "px !important;");
			try{
				ClickLeft($("a[class='bizCardGroup'][value='P']").get(0));
			}catch(ex){
				coviCmn.traceLog(ex);
			}
		});
		
		// 연락처 그룹 변경시
		$(document).on("click", "a[class^='bizCardGroup']" , function(){
			$("#allchk").attr("checked", false);
			$("#allchk_BizCard").attr("checked", false);
			ClickLeft(this);
		});
		
	};

	coviOrgObj.returnData = function(){
		if($this.config.type=="A0"){
			$this.closeLayer();
			return;
		}

		if($this.config.type=="A1"){
			$("#orgSearchList input:radio").each(function() {
				if ($(this).is(":checked")) {
					//var dataobj =  new Function ("return ("+this.value+")").apply();
					var dataobj =  jQuery.parseJSON(this.value);
					addSelectedRow("people",dataobj);
				}
			});
		}else if($this.config.type=="B1"){
			if($("#orgSelectedList_people").find("tr").size()>1){
				Common.Warning(orgDic["msg_OrgMap03"]); //선택목록의 임직원(사용자) 항목은 1개만 추가 할 수 있습니다.
				return;
			}
		}else if($this.config.type=="C1"){
			if($("#orgSelectedList_dept").find("tr").size()>1){
				Common.Warning(orgDic["msg_OrgMap04"]); //선택목록의 부서(그룹) 항목은 1개만 추가 할 수 있습니다.
				return;
			}
		}else if($this.config.type=="D1"){
			if(($("#orgSelectedList_people").find("tr").size() + $("#orgSelectedList_dept").find("tr").size()) >1){
				Common.Warning(orgDic["msg_OrgMap05"]); // 선택목록의 임직원(사용자) / 부서(그룹) 항목은 1개만 추가 할 수 있습니다.
				return;
			}
		}

		if($this.config.callbackFunc != undefined && $this.config.callbackFunc  != ''){
			if($this.config.openerID != undefined && $this.config.openerID != ''){
	
				// 21.09.13, 웹하드 고도화. 웹하드 소스 구조 변경으로 postMessage로 팝업창 파라미터 전달.
				// 조건 1. 이전 주소값이 웹하드일 경우.
				// 조건 2. 콜백함수가 'OrgCallBack_SetShareMember'일 때.
				if ( (document.referrer.indexOf("/webhard/layout/user_BoxList.do") > -1) && ($this.config.callbackFunc === 'OrgCallBack_SetShareMember') ) {
					var opnrID = coviCmn.getParentFrame( $this.config.openerID );
					window.parent.postMessage(
						{functionName : "toParent", param1 : opnrID, param2 : makeOrgJsonData(), param3: $this.config.openerID+"_if"}
						, '*'
					);
				} else {
					//보안취약점 조치(eval, Function)
					//var temFunc = new Function('param', coviCmn.getParentFrame( $this.config.openerID )+$this.config.callbackFunc+"(param)");
					//temFunc(makeOrgJsonData());
					let oFrame = coviCmn.getParentFrameObj($this.config.openerID);
					if(jQuery.isFunction(oFrame[$this.config.callbackFunc])){
						oFrame[$this.config.callbackFunc].apply(this, [makeOrgJsonData()]);
					}
				}
				
    		}else if(window[$this.config.callbackFunc] != undefined){
				window[$this.config.callbackFunc](makeOrgJsonData());
			} else if(parent && parent[$this.config.callbackFunc] != undefined){
				parent[$this.config.callbackFunc](makeOrgJsonData());
			} else if(opener && opener[$this.config.callbackFunc] != undefined){
				opener[$this.config.callbackFunc](makeOrgJsonData());
			} else{
				 try{
				 	let addFrame = null;
				 	if(parent)addFrame = parent;
				 	else if (opener)addFrame = opener;
				 	
			        //let thisFunc= new Function("a", addFrame+$this.config.callbackFunc+"(a)");
			        //thisFunc(makeOrgJsonData());
			        addFrame[$this.config.callbackFunc].apply(this, makeOrgJsonData());
			        
			     }catch(e){console.log(e);}
			}	
		}
		
		$this.closeLayer();
	}
	
	coviOrgObj.closeLayer = function(){
		Common.Close();
	}
	
	coviOrgObj.getUserOfGroupList = function(nodeValue){
		
		if($this.config.type=="C1"||$this.config.type=="C9"||$this.config.drawOpt.charAt(1)!="M")
			return ;
		
		var deptCode = nodeValue;
		var groupType = $("#groupTypeSelect").val()
		//DeptCoded 가 최상위 GENERAL 이면 가운데 목록에 표시하지 않는다,.
		$("#selDeptTxt").text((deptCode=="GENERAL" ? "" : getGroupName(deptCode)));
		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);

		$.ajax({
			type:"POST",
			data:{
				"deptCode" : deptCode,
				"groupType" : groupType,
			},
			async:false,
			url:"/covicore/control/getUserList.do",
			success:function (data) {
				setMemberList(data);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getUserList.do", response, status, error);
			}
		});
	}
	
	coviOrgObj.allCheck = function(obj, bSelf){
		var table;
		if (bSelf == true){
			table= $(obj).closest('table');
		}
		else{
			table= $("#orgSearchList").closest('table');
		}	
		$('tbody tr td input[type="checkbox"]:not(:disabled)',table).prop('checked', $(obj).prop('checked'));
	}
	coviOrgObj.allCheck_BizCard = function(obj, pType){
		var table= $("#orgSearchList_BizCard_" + pType).closest('table');
		$('tbody tr td input[type="checkbox"]',table).prop('checked', $(obj).prop('checked'));
	}
	
	coviOrgObj.sendRight = function(){
		if($this.config.drawOpt.charAt(3)!="R")
			return;
		
		var dupStr=""; //중복된 데이터
		var dataobj = {};
		
		if(searchList == "bizCard"){
			var type = "people";
			// 연락처
			$("#orgSearchList_BizCard_UR input:checkbox").each(function() {
				if ($(this).is(":checked")) {
					var isOld = false;
					//dataobj =  new Function ("return ("+this.value+")").apply();
					dataobj =  jQuery.parseJSON(this.value);
					var oldSelectList_people = getSelectedData(type);	// 선택한 데이터 가져옴
					
					if (oldSelectList_people.length != 0) {
						for(var i=0; i<oldSelectList_people.length; i++){
	 						if(oldSelectList_people[i] == (diffStr + dataobj.BizCardType + "-" + dataobj.ShareType + "-" + dataobj.ID)){
								dupStr += $(this)[0].name +", "
								isOld = true;
								break;
							}
						}
					}
					if (!isOld) {		// 이미 추가된 목록이 아닐 때만
						addSelectedRow(type,dataobj);
					}
				}
			});
			
		}else{
			var type = $("#orgSearchList tr:first-child").attr("type"); 
			var diffStr = (type == "dept" ? "orgSelectedList_dept" : "orgSelectedList_people") ;
			
			// 사원
			$("#orgSearchList input:checkbox").each(function() {
				if ($(this).is(":checked")) {
					var isOld = false;
					dataobj = jQuery.parseJSON(this.value);
					var oldSelectList_people = getSelectedData(type);	// 선택한 데이터 가져옴
					
					if (oldSelectList_people.length != 0) {
						for(var i=0; i<oldSelectList_people.length; i++){
	 						if(oldSelectList_people[i] == (diffStr + dataobj.UserID)){
								dupStr += $(this)[0].name +", "
								isOld = true;
								break;
							}
						}
					}
					
					if (!isOld) {		// 이미 추가된 목록이 아닐 때만
						addSelectedRow(type,dataobj);
					}
					
				}
			});		
			
			// 부서
			var deptArr = $this.groupTree.getCheckedTreeList("checkbox");		// 체크된 부서 항목
			
			for (var i=0;i< deptArr.length; i++) {
				var isOld = false;
				var oldSelectList_dept = getSelectedData("dept");		// 선택한 데이터 가져옴
				
				if (oldSelectList_dept.length != 0) {
					for (var j=0; j<oldSelectList_dept.length; j++) {
						if (oldSelectList_dept[j] == ('orgSelectedList_dept'+deptArr[i].GroupID)) {
							dupStr += deptArr[i].nodeName +", ";
							isOld = true;
							break;
						}
					}
				}
				
				if (!isOld) {
					addSelectedRow("dept",deptArr[i]);
				}
			}
		}

		// 선택목록으로 이동후 체크박스 모두 해제
		$("#orgSearchList input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$.each($this.groupTree.list,function(idx,obj){
			if(obj.__checked){
				$this.groupTree.updateTree(idx, obj, {__checked: false});
			}
		});
		
		$("#orgSearchList_BizCard_UR input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		$("#orgSearchList_BizCard_GR input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("input:checkbox[id^=groupTree]").each(function(idx,obj){
			$(obj).prop("checked",false)
		});

		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);
		
		if(dupStr != ""){
			dupStr = dupStr.substr(0, dupStr.length-2);
			Common.Warning(dupStr +orgDic["msg_OrgMap06"]); //은(는) 이미 선택목록에 추가되어 있습니다.
		}
	}
	
	coviOrgObj.sendLeft = function(){
		if($this.config.drawOpt.charAt(3)!="R")
			return;
		
		$("#orgSelectedList_people input:checkbox").each(function(){
			if($(this).is(":checked")){
				$(this).parent().parent().remove();
			}
		});

		$("#orgSelectedList_dept input:checkbox").each(function(){
			if($(this).is(":checked")){
				$(this).parent().parent().remove();
			}
		});
	}
	
	
	coviOrgObj.setParamData = function(data){
		if(data == null || data == '')
			return;
			
		var jsonData;
		if(typeof(data)=='object'){
			jsonData = data;
		}else{
			jsonData = $.parseJSON(data);	
		}
		
		$(jsonData.item).each(function(i){
			if(this.itemType == "user")
				addSelectedRow("people",this);
			else if(this.itemType == "group")
				addSelectedRow("dept",this);
		});
	}
	
	coviOrgObj.close = function(){
		//alert('close');
		parent.Common.close($this.config.popupID);
	}			
	
	coviOrgObj.contentDoubleClick = function(obj){
		$(obj).find("input[type='checkbox']").prop("checked", "checked");
		$(obj).find("input[type='radio']").prop("checked", "checked");
		coviOrgObj.sendRight();
	}
	
	// 검색 목록 드래그 시작
	coviOrgObj.void_ListItem_ondragstart = function(pObjEvent) {
		if (pObjEvent.target.nodeName != "TR") {
			return;
		}
		var sData = "ORGMAP§§§";
		sData += $(pObjEvent.target).find("INPUT[type='checkbox']").attr("id");
		// IE는 text만 가능
		pObjEvent.dataTransfer.setData("text", sData);
	}
	
	// 검색 목록 드래그 종료 처리
	coviOrgObj.void_ListItem_ondragend = function(pObjEvent) {
		var tmpFuncName = this.config.dragEndFunc;
		try{
			if(tmpFuncName ){
				//let ptFunc = new Function('a', tmpFuncName+"(a)");
				//ptFunc(pObjEvent);
				if(jQuery.isFunctoin(window[tmpFuncName])){
					window[tmpFuncName].apply(this, [pObjEvent]);
				}
			}

		}catch(ex){
			coviCmn.traceLog("void_ListItem_ondragend error:" + ex.message);
		}
	}
	
	coviOrgObj.goUserInfoPopup = function(userID){

		var qString = CFN_GetQueryString("type");
		if (qString === "A1") {
			var targetUrl = "/covicore/control/callMyInfo.do?userID="+userID;
			var widthX = 810;	// 팝업창 x 크기.
			var heightY = 500;
			var popupX = (window.screen.width/2) - (widthX/2); 		// screen의 중간과 팝업창의 중간을 맞춤.
			var popupY = (window.screen.height/2)-(heightY/2);
			var targetInfo = "width="+widthX+", height="+heightY+", left="+popupX+", top="+popupY;
			window.open(targetUrl, "MyInfo", targetInfo);
		} else {
			parent.Common.open("","MyInfo",orgDic["lbl_UserProfile"],"/covicore/control/callMyInfo.do?userID="+userID,"810px","500px","iframe",true,null,null,true); //사용자 프로필
		}
	}
	coviOrgObj.changeBackgroundColor = function(obj){
		$("#orgSearchList").find("tr").css("background", "");
		$(obj).closest("tr").css('background', '#eef7f9');
	}
	
	//Tree 함수
	coviOrgObj.groupTree.displayIcon = function(value){
		if(value){
			$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","block");
		}else{
			$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","none");
		}
	}
	coviOrgObj.groupTree.getCheckedTreeList = function(inputType){
		var collect = [];
		var list = this.list;
		
		this.body.find("input[type="+inputType+"]").each(function(){
			var arr = this.id.split('_'); 
			if(this.checked && (arr[1] == "treeCheckbox" || arr[1]== "treeRadio")){
				var itemIndex = this.id.replace(arr[0]+ "_" + arr[1] + "_", "");
				for(var i=0; i < list.length; i++)
					if(list[i].no == itemIndex)
						collect.push(list[i]);
			}
		});
		return collect;
	}
	
	//private 함수 
	//초기 설정값 셋팅
	function setConfig(orgOpt){
		$this.config.targetID = orgOpt.targetID;	
		
		if(!isEmpty(orgOpt.type)){
			$this.config.type = orgOpt.type;	
			if(orgOpt.type == "A0"){ //조회용일 경우 선택화면 안 그림
				orgOpt.drawOpt = "LM__B" ; 
			}
			else if(orgOpt.type == "A1"){ //2단계인 경우  선택화면 안 그림
				orgOpt.drawOpt = "LM_RB" ; 
			}
		}
		/*if(!isEmpty(orgOpt.treeKind)){
			$this.config.treeKind = orgOpt.treeKind;	
		}*/

		$this.config.checkboxRelationFixed = orgOpt.checkboxRelationFixed || false;
		$this.config.treeKind = isEmptyDefault(orgOpt.treeKind , $this.config.treeKind );
		$this.config.drawOpt = isEmptyDefault(orgOpt.drawOpt , $this.config.drawOpt );
		$this.config.callbackFunc = isEmptyDefault(orgOpt.callbackFunc , $this.config.callbackFunc);
		$this.config.openerID = isEmptyDefault(orgOpt.openerID , $this.config.openerID);
		$this.config.allCompany = isEmptyDefault(orgOpt.allCompany , $this.config.allCompany);
		if(Common.getGlobalProperties("isSaaS") == "Y") {
			// SaaS 그룹웨어의 경우 사간검색 무조건 불가능
			$this.config.allCompany = "N";
		}
		$this.config.groupDivision = isEmptyDefault(orgOpt.groupDivision , $this.config.groupDivision);
		$this.config.communityId = isEmptyDefault(orgOpt.communityId , $this.config.communityId);
		$this.config.bizcardKind = isEmptyDefault(orgOpt.bizcardKind , $this.config.bizcardKind);	
		$this.config.dragEndFunc = isEmptyDefault(orgOpt.dragEndFunc , $this.config.dragEndFunc);
		if($this.config.bizcardKind != undefined && $this.config.bizcardKind != null){
			$this.config.bizcardKind = $this.config.bizcardKind.toUpperCase();
		}
		if(orgOpt.onlyMyDept != undefined && orgOpt.onlyMyDept != null){
			$this.config.onlyMyDept = isEmptyDefault(orgOpt.onlyMyDept , $this.config.onlyMyDept) ;
		}

		if(orgOpt.userParams != undefined && orgOpt.userParams != null){
			$this.config.userParams = isEmptyDefault(orgOpt.userParams , $this.config.userParams) ;
		}
		if(orgOpt.defaultValue != undefined && orgOpt.defaultValue != null){
			$this.config.defaultValue = isEmptyDefault(orgOpt.defaultValue , $this.config.defaultValue) ;
		}
		if(orgOpt.loadMyDept != undefined && orgOpt.loadMyDept != null){
			$this.config.loadMyDept = isEmptyDefault(orgOpt.loadMyDept , $this.config.loadMyDept) ;
		}
		
		
	}	
	
	//기본 HTML 바인딩
	function insertBasicHTML(){
		var html = '', btnHtml = '';
		
		//부서 및 그룹 트리 
		if($this.config.drawOpt.charAt(0) === 'L'){
			if($this.config.bizcardKind != ""){
				html += ' 		<div class="tblList tblCont tblBizcardList" style="margin-top:0px;"> ';
				html += '			<div id ="changeType" class="tblFilterTop">';
				html += '				<ul class="filterList">';
				html += '					<li><a id = "changeGroupTree">'+orgDic["CPMail_Dept"]+'</a></li>';
				html += '					<li><a id = "changeBizCard">'+orgDic["CPMail_Contact"]+'</a></li>';
				html += ' 				</ul>';
				html += '			</div>';
				html += '		</div>';
			}
			html += '			<div class="appTree" id="BizCardDiv" style = "display:none">';
			html += '				<table class="tableStyle t_center hover">';
			html += '					<tbody id="groupMailSearchList">';
			html += '						<ul id="leftmenu" class="contLnbMenu bizcardMenu">'
			var	mailUrl = "/mail/layout/bizcard_BizCardPersonList.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard";
			html += "";
			html += "							<li class='menuAllContact' data-menu-id='' data-menu-alias='undefined' data-menu-url=" + mailUrl + ">";
			html += "								<div class='selOnOffBoxChk type02 boxList active'>"; // child Area	
			html += "									<div class='menuAllContact01'>";
			html += "										<a class='bizCardGroup' value='P'>";
			html += "											<span uid='"+orgDic["CPMail_Personal"]+"'>"+orgDic["CPMail_Personal"]+"</span></a>";
			//html += "	<div class='menuAllContactList'></div>";
			html += "									</div>";
			html += "									<div class='menuAllContact02' data-menu-id='' data-menu-alias='undefined' data-menu-url='%2Fmail%2Flayout%2Fbizcard_BizCardPersonListForD.do%3FCLSYS%3Dbizcard%26CLMD%3Duser%26CLBIZ%3DBizcard'>";
			html += "										<a class='bizCardGroup' value='D'>";
			html += "											<span uid='"+orgDic["CPMail_Dept"]+"'>"+orgDic["CPMail_Dept"]+"</span></a>";
			//html += "	<div class='menuAllContactList'></div>";
			html += "									</div>";
			html += "									<div class='menuAllContact03' data-menu-id='' data-menu-alias='undefined' data-menu-url='%2Fmail%2Flayout%2Fbizcard_BizCardPersonListForU.do%3FCLSYS%3Dbizcard%26CLMD%3Duser%26CLBIZ%3DBizcard'>";
			html += "										<a class='bizCardGroup' value='U'>";
			html += "											<span uid='"+orgDic["CPMail_Company"]+"'>"+orgDic["CPMail_Company"]+"</span></a>";
			//html += "	<div class='menuAllContactList'></div>";
			html += "									</div>";
			html += "								</div>";
			html += "							</li>";
			html += "						</ul>"
			html += '					</tbody>';
			html += '				</table>';
			html += '			</div>';
			html += '			<div class="appTree" id="groupTreeDiv">';
			html += '				<div class="appTreeTop">';
			html += '					<select id="companySelect" class="treeSelect" style="display: none;"></select>';
			if($this.config.treeKind.toUpperCase() == "GROUP"){
				html += '		 			<div style="height:3px; width:100%;"></div>'
				html += '		 			<select id="groupTypeSelect" class="treeSelect" style="display: none;"></select>';
			}
			html += '				</div>';
			html += '				<div class="appTreeBot">';
			
			if($this.config.type == "A0" || $this.config.type == "A1" || $this.config.type == "B1" || $this.config.type == "B9") {
				html += '					<div id="groupTree" class="radio" style="height:100%;"></div>';
			} else {
				html += '					<div id="groupTree" style="height:100%;"></div>';
			}

			html += '				</div>';
			html += '			</div>';
		}
		
		
		if($this.config.drawOpt.charAt(1) === 'M'){
			html += '			<div id="searchdiv" class="appList_top_b searchBox02">';
			html += '			<select id="searchType" class="j_appSelect">';
			if($this.config.type != "C1" &&  $this.config.type != "C9" ){
					html += '				<option value="person">'+orgDic["lbl_apv_person"]+'</option>';
			}
			if($this.config.type != "B1" &&  $this.config.type != "B9"){
					html += '				<option value="dept">'+orgDic["lbl_dept"]+'</option>';
			}
			html += '			</select>';
			html += '			<input style="width: 192px;" type="text" autocomplete="off" placeholder="'+orgDic["msg_EnterSearchword"]+'" id="searchWord" name="inputSelector_onsearch"  data-axbind="selector"  ><a class="btnSearchType01" >'+orgDic["btn_apv_search"]+'</a>';
			html += '			</div>';
			html += '			<div id="searchdiv_BizCard" style="display:none;" class="appList_top_b searchBox02">';
			html += '				<input style="width: 274px;" type="text" autocomplete="off" placeholder="'+orgDic["msg_EnterSearchword"]+'" id="searchWord_BizCard" name="inputSelector_onsearch_BizCard"  data-axbind="selector"  ><a class="btnSearchType01" onclick="var e = $.Event( \'keydown\', { keyCode: 13 } ); $(\'#searchWord_BizCard\').trigger( e );">'+orgDic["btn_apv_search"]+'</a>';
			html += '			</div>';
			html += '			<div id="divSearchList_Main" class="appList" style="overflow:hidden;">';
			html += '				<table class="tableStyle t_center hover appListTop" style="width:276px;">';
			html += '					<thead>';
			html += '						<tr>';
			html += '							<th>';
			if($this.config.type != "C1" &&  $this.config.type != "C9"  && $this.config.type != "A0" && $this.config.type != "A1"){
				html += '								<input type="checkbox" id="allchk" name="allchk" onchange="coviOrg.allCheck(this)" style="  float: left;    margin: 8px;    height: 14px;	">';
				html += '								<label for="allchk"><span id="selDeptTxt" style="float: left;font-weight: normal;margin-top: 8px;margin-right: 8px;max-width: 236px;text-align: left;margin-bottom: 8px;"></span></label>';
			}
			html += '							</th>';
			html += '						</tr>';            
			html += '					</thead>';
			html += '				</table>';
			html += '				<div class="appListBot" style="height: 393px;	">';
			html += '					<table class="tableStyle t_center hover">';
			html += '						<colgroup>';
			if($this.config.type != "A0"){
				html += '							<col style="width:30px">';
				html += '							<col style="width:50px">';
				html += '							<col style="width:*">';
			}else{
				html += '							<col style="width:80px">';
				html += '							<col style="width:*">';
				html += '							<col style="width:*">';
				html += '							<col style="width:*">';
			}
			html += '						</colgroup>';
			html += '						<tbody id="orgSearchList">';
			html += '						</tbody>';
			html += '					</table>';
			html += '					<div id="orgSearchListMessage" style="position: absolute; top: 230px; left: 295px;"></div>';
			html += '				</div>';
			html += '			</div>';
			
			html += '			<div id="divSearchList_BizCard" class="appList" style="overflow:hidden; display:none;">';
			html += '				<table class="tableStyle t_center hover appListTop" style="width:276px;">';
			html += '					<thead>';
			html += '						<tr>';
			html += '							<th>';
			html += '								<div>';
			html += '									<input type="checkbox" id="allchk_BizCard_UR" name="allchk_BizCard_UR" onchange="coviOrg.allCheck_BizCard(this, \'UR\')" style="  float: left;    margin: 8px;    height: 14px;	">';
			html += '								</div>';
			html += '								<label for="allchk_BizCard_UR"><span style="font-weight: normal; margin-top: 8px; margin-right: 20px; float: left;">'+orgDic["lbl_Mail_Contact"]+'</span></label>';
			html += '								<div id="divBizCardPaging_UR" class="org_paging" style="display:none;">';
			html += '									<table cellspacing="0" cellpadding="0">';
			html += '										<tbody>';
			html += '											<tr>';
			html += '												<td width="25" align="left" valign="middle">';
			html += '													<a style="cursor: pointer;" onclick="coviOrg.BizCardPageMove_onclick(\'PREV\', \'UR\');">&lt;</a>';
			html += '												</td>';
			html += '												<td align="left" valign="middle">';
			html += '													<input id="hidBizCardCurPage_UR" type="hidden" value="1">';
			html += '													<span class="gray"><span id="spanBizCardCurPage_UR">1</span>&nbsp;/&nbsp;<span id="spanBizCardTotalPage_UR">1</span></span>';
			html += '												</td>';
			html += '												<td align="right" valign="middle" style="padding-left: 10px;">';
			html += '													<a style="cursor: pointer;" onclick="coviOrg.BizCardPageMove_onclick(\'NEXT\', \'UR\');">&gt;</a>';
			html += '												</td>';
			html += '											</tr>';
			html += '										</tbody>';
			html += '									</table>';
			html += '								</div>';
			html += '							</th>';
			html += '						</tr>';            
			html += '					</thead>';	
			html += '				</table>';

			if($this.config.bizcardKind == "ALL"){
				html += '				<div class="appListBot" style="height: 176px;">';
			}else{
				html += '				<div class="appListBot" style="height: 393px;">';
			}
			html += '					<table class="tableStyle t_center hover">';
			html += '						<colgroup>';
			html += '							<col style="width:30px">';
			html += '							<col style="width:*">';
			html += '						</colgroup>';
			html += '						<tbody id="orgSearchList_BizCard_UR">';
			html += '						</tbody>';		
			html += '					</table>';
			html += '					<div id="orgSearchListMessage_BizCard_UR" style="position: absolute; top: 210px; left: 295px;"></div>';
			html += '				</div>';
			
			if($this.config.bizcardKind == "ALL"){
				html += '				<table class="tableStyle t_center hover appListTop" style="width:276px;">';
				html += '					<thead>';
				html += '						<tr>';
				html += '							<th>';
				html += '								<div>';
				html += '									<input type="checkbox" id="allchk_BizCard_GR" name="allchk_BizCard_GR" onchange="coviOrg.allCheck_BizCard(this, \'GR\')" style="  float: left;    margin: 8px;    height: 14px;	">';
				html += '								</div>';
				html += '								<label for="allchk_BizCard_GR"><span style="font-weight: normal; margin-top: 8px; margin-right: 20px; float: left;">'+orgDic["lbl_group"]+'</span></label>';
				html += '								<div id="divBizCardPaging_GR" class="org_paging" style="display:none;">';
				html += '									<table cellspacing="0" cellpadding="0">';
				html += '										<tbody>';
				html += '											<tr>';
				html += '												<td width="25" align="left" valign="middle">';
				html += '													<a style="cursor: pointer;" onclick="coviOrg.BizCardPageMove_onclick(\'PREV\', \'GR\');">&lt;</a>';
				html += '												</td>';
				html += '												<td align="left" valign="middle">';
				html += '													<input id="hidBizCardCurPage_GR" type="hidden" value="1">';
				html += '													<span class="gray"><span id="spanBizCardCurPage_GR">1</span>&nbsp;/&nbsp;<span id="spanBizCardTotalPage_GR">1</span></span>';
				html += '												</td>';
				html += '												<td align="right" valign="middle" style="padding-left: 10px;">';
				html += '													<a style="cursor: pointer;" onclick="coviOrg.BizCardPageMove_onclick(\'NEXT\', \'GR\');">&gt;</a>';
				html += '												</td>';
				html += '											</tr>';
				html += '										</tbody>';
				html += '									</table>';
				html += '								</div>';
				html += '								</th>';
				html += '							</tr>';            
				html += '						</thead>';	
				html += '					</table>';
				html += '				<div class="appListBot" style="height: 176px;">';
				html += '					<table class="tableStyle t_center hover">';
				html += '						<colgroup>';
				html += '							<col style="width:30px">';
				html += '							<col style="width:*">';
				html += '						</colgroup>';
				html += '						<tbody id="orgSearchList_BizCard_GR">';
				html += '						</tbody>';		
				html += '					</table>';
				html += '					<div id="orgSearchListMessage_BizCard_GR" style="position: absolute; top: 430px; left: 295px;"></div>';
				html += '				</div>';
			}
			
			html += '			</div>';
		}
		
		if($this.config.drawOpt.charAt(2) === 'A'){
			html += ' 			<div class="arrowBtn">';
			html += ' 				<input type="button" class="btnRight" value="&gt;" onclick="coviOrg.sendRight()"/>';
			html += '				<input type="button" class="btnLeft"  value="&lt;" onclick="coviOrg.sendLeft()"/>';
			html += '			</div>';
		}

		if($this.config.drawOpt.charAt(3) === 'R'){
			if($this.config.type.charAt(0) === 'B') {
				html += ' 			<div class="appSel">';
				html += '  				 <div class="selTop" style="height: 100% !important;">';
				html += '    				<table class="tableStyle t_center hover infoTableBot">';
				html += '      					<colgroup>';
				html += '     						<col style="width:50px">';
				html += '      						<col style="width:*">';
				html += '						</colgroup>';
				html += '						<thead>';
				html += '							<tr>';
				html += '								<td colspan="2"><h3 class="titIcn">'+orgDic["lbl_officer"]+'</h3></td>'; //임직원
				html += '							</tr>';
				html += '						</thead>';
				html += '						<tbody id="orgSelectedList_people">';
				html += '						</tbody>';
				html += ' 					</table>';
				html += '				</div>';
				html += ' 			</div>';
			} else if ($this.config.type.charAt(0) === 'C') {
				html += ' 			<div class="appSel">';
				html += '				<div class="selTop" style="height: 100% !important;">';
				html += '					<table class="tableStyle t_center hover infoTableBot">';
				html += '						<colgroup>';
				html += '							<col style="width:50px">';
				html += '							<col style="width:*">';
				html += '						</colgroup>';
				html += '						<thead>';
				html += '							<tr>';
				html += '								<td colspan="2"><h3 class="titIcn">'+orgDic["lbl_dept"]+'</h3></td>'; //부서
				html += '							</tr>';
				html += '						</thead>';
				html += '						<tbody id="orgSelectedList_dept">';
				html += '						</tbody>';
				html += '     				</table>';
				html += '				</div>';
				html += ' 			</div>';
			} else {
				html += ' 			<div class="appSel" style="'+($this.config.type == 'A1'?'display:none"':'')+'">';
				html += '  				 <div class="selTop">';
				html += '    				<table class="tableStyle t_center hover infoTableBot">';
				html += '      					<colgroup>';
				html += '     						<col style="width:50px">';
				html += '      						<col style="width:*">';
				html += '						</colgroup>';
				html += '						<thead>';
				html += '							<tr>';
				html += '								<td colspan="2">';
				html += '								<input type="checkbox" id="allchk" name="allchk" onchange="coviOrg.allCheck(this, true)" style="  float: left;    margin: 8px;    height: 14px;	">';
				html += '								<h3 class="titIcn">'+orgDic["lbl_officer"]+'</h3></td>'; //임직원
				html += '							</tr>';
				html += '						</thead>';
				html += '						<tbody id="orgSelectedList_people">';
				html += '						</tbody>';
				html += ' 					</table>';
				html += '				</div>';
				html += '				<div class="selBot">';
				html += '					<table class="tableStyle t_center hover infoTableBot">';
				html += '						<colgroup>';
				html += '							<col style="width:50px">';
				html += '							<col style="width:*">';
				html += '						</colgroup>';
				html += '						<thead>';
				html += '							<tr>';
				html += '								<td colspan="2">';
				html += '								<input type="checkbox" id="allchk" name="allchk" onchange="coviOrg.allCheck(this, true)" style="  float: left;    margin: 8px;    height: 14px;	">';
				html += '								<h3 class="titIcn">'+orgDic["lbl_dept"]+'</h3></td>'; //부서
				html += '							</tr>';
				html += '						</thead>';
				html += '						<tbody id="orgSelectedList_dept">';
				html += '						</tbody>';
				html += '     				</table>';
				html += '				</div>';
				html += ' 			</div>';
			}
		}
		
		if($this.config.drawOpt.charAt(4) === 'B'){
			btnHtml += '<div class="popBtn">';
			if($this.config.type != "A0"){
				btnHtml += '	<input type="button" class="ooBtn ooBtnChk" onclick="coviOrg.returnData();" value="'+orgDic["btn_Confirm"]+'"/>'; /*확인*/ 
			}
			btnHtml += ' 	<input type="button" class="owBtn mr30" onclick="coviOrg.closeLayer();" value="'+orgDic["btn_Close"]+'"/>'; /*닫기*/ 
			btnHtml += '</div>';
		}
		
		
		if($this.config.targetID != ''){
			$("#"+$this.config.targetID).addClass("appBox");
			$("#"+$this.config.targetID).prepend(html);
			$("#"+$this.config.targetID).after(btnHtml);
		}
		
		
		
		var btnHeight = 0
		if($(".popBtn").length > 0){
			btnHeight = $(".popBtn").outerHeight();
		}
		$(".appBox").css("height", "calc(100% - " + btnHeight + "px)");
		
		var tabHeight = 0;
		if($(".tblFilterTop").length > 0){
			tabHeight = $(".tblFilterTop").outerHeight();
		}
		
		var contHeight = '100%';
		if (tabHeight > 0) contHeight += ' - ' + tabHeight + 'px';
		$(".appTree").css("height", "calc(" + contHeight + ")");
		$(".appTreeTop").css("height", "auto");
		if ($this.config.allCompany == 'Y'){
			$("#companySelect").show();
		}
		else {
			$("appTreeTop div").hide();
		}
		if($this.config.treeKind.toUpperCase() == "GROUP"){
			$("#groupTypeSelect").show();
		}
		$(".appTreeBot").css({
			"height": "calc(100% - " + $(".appTreeTop").outerHeight() + "px)",
			"margin-top": $(".appTreeTop").outerHeight() + (($(".appTreeTop").outerHeight() > 0) ? 5 : 0)
		});
		
		var listHeight = contHeight;
		if ($(".appList_top_b").length > 0) {
			listHeight += ' - ' + $(".appList_top_b").outerHeight() + 'px - ' + $(".appList_top_b").css("margin-bottom");
		}
		$(".appList").css({
			"min-height": "calc(" + listHeight + ")",
			"max-height": "calc(" + listHeight + ")"
		});
		$(".appListBot").attr("style", "height: calc(100% - " + $(".appListTop").outerHeight() + "px) !important; margin-top:" + $(".appListTop").outerHeight() + "px !important;");
		
		if($("#searchType option").length < 2){
			$("#searchType").hide();
			$("#searchWord").css("width", "276px");
		}
		
		$(".appSel").css({
			"margin-bottom": 0,
			"height": "calc(" + contHeight + ")",
			"width": "calc(100% - 560px)"
		});
		var selBotHeight = '100%';
		if ($(".selTop").length > 0){
			selBotHeight +=  ' - ' + $(".selTop").outerHeight() + 'px - ' + $(".selBot").css("margin-top");
		}
		$(".selBot").css({
			"height": "calc(" + selBotHeight + ")"
		});
	}
	
	//Select 박스 바인딩 (회사 목록 및 검색 조건)
	function setSelect(){
		if($this.config.drawOpt.charAt(0) === "L"){
			var isAdmin = CFN_GetQueryString("CLMD");
			if(isAdmin == "undefined") {
				if(opener != null) {
					if(opener.name == "IframeForm"){
						isAdmin = opener.parent.parent.CFN_GetQueryString("CLMD");
					}else{
						typeof opener.parent.CFN_GetQueryString === "undefined" && (opener.parent.CFN_GetQueryString = CFN_GetQueryString);
						isAdmin = opener.parent.CFN_GetQueryString("CLMD");
					}
				}else {
					isAdmin = window.parent.CFN_GetQueryString("CLMD");
				}
			}
			
			$.ajax({
				type:"POST",
				url : "/covicore/control/getCompanyList.do",
				data:{
					allCompany: $this.config.allCompany,
					companyCode: companyCode,
					isAdmin: isAdmin
				},
				async: false, 
				success : function(data){
					var arrCom = new Array();
					
					$.each(data.list,function(idx, obj){
						arrCom.push({optionValue: obj.GroupCode, optionText: obj.DisplayName});
					});
					
					$("#companySelect").bindSelect({
						options: arrCom,
						setValue: companyCode,
						onchange:function () {
							setInitGroupTreeData("N"); //loadMyDept = "N"
						}
					});
					
					if ($this.config.allCompany == 'N' || $this.config.allCompany == ''){
						$("#AXselect_AX_companySelect").hide();
					}
				}
			});
			
			if($this.config.treeKind.toUpperCase() == "GROUP"){
				var arrOptions = [];
				arrOptions.push({"optionValue":"dept","optionText":orgDic["OrgTreeKind_Dept"]});
				arrOptions.push({"optionValue":"group","optionText":orgDic["OrgTreeKind_Group"]});				
				
				$("#groupTypeSelect").bindSelect({
					options: arrOptions, //▣ 조직도, ▣ 그룹
					onchange:function () {
						setInitGroupTreeData("N"); //loadMyDept = "N"
					}
				});
			}
			/*
			if($this.config.allCompany == "N" && isAdmin != "admin") { 
				//사간 검색 불가일 경우 select box 숨김 처리
				$("#divCompany").hide();
				$("#AXselect_AX_companySelect").hide();
				$(".appTreeBot").css("margin-top", "0px");
				if($this.config.treeKind.toUpperCase() == "GROUP") {
					$("#AXselect_AX_groupTypeSelect").css("top", "0px");
					$(".appTreeBot").css("margin-top", "40px");
				}
			}
			*/
		}
		
		if($this.config.drawOpt.charAt(1) === "M"){
			$("#searchWord").bindSelector({
				reserveKeys: {
					optionValue: "value",
					optionText: "text"
				},
				minHeight:1000,
				ajaxAsync:false,
				appendable:false,
				onsearch:function(objID, objVal, callBack) {                            // {Function} - 값 변경 이벤트 콜백함수 (optional)
					// 유저 검색일 경우만
					if($("#searchType option:selected").val() == "dept"){
				        return {options:[]}
					}
				
					var word = $("#searchWord").val();
					setTimeout(function(){
						callBack({
							options:[
								{value:"name;"+word, text:"<b>"+orgDic["lbl_name"]+": <font color='#409CE5'>"+word+"</font></b>", desc: "-"+orgDic["lbl_com_searchByName"]}, //이름,  이름으로 찾기
								{value:"dept;"+word, text:"<b>"+orgDic["lbl_dept"]+": <font color='#409CE5'>"+word+"</font></b>", desc: "-"+orgDic["lbl_com_searchByDept"]},//부서,  부서로 찾기
								{value:"phone;"+word, text:"<b>"+orgDic["lbl_MobilePhone"]+": <font color='#409CE5'>"+word+"</font></b>", desc: "-"+orgDic["lbl_com_searchByPhone"]},//핸드폰,  핸드폰으로 찾기
								{value:"charge;"+word, text:"<b>"+orgDic["lbl_Role"]+": <font color='#409CE5'>"+word+"</font></b>", desc: "-"+orgDic["lbl_com_searchByRole"]},//담당업무, 담당업무로 찾기
								{value:"jobposition;"+word, text:"<b>"+orgDic["lbl_JobPosition"]+": <font color='#409CE5'>"+word+"</font></b>", desc: "-"+orgDic["lbl_com_searchByJobPosition"]},//직위, 직위로 찾기
								{value:"joblevel;"+word, text:"<b>"+orgDic["lbl_JobLevel"]+": <font color='#409CE5'>"+word+"</font></b>", desc: "-"+orgDic["lbl_com_searchByJobLevel"]} //직급, 직급으로 찾기
							]
						});
					}, 000);
				},
				onChange:function(){
					if(this.selectedOption != null){
						search(this.selectedOption);
					} else {
						search(this.options[0]);
					}
					$("#searchWord").val(tmpSearchWord);
				}
			});
	
			$('#searchWord').keydown(function(e) {
			    if (e.keyCode == 13) {
			    	if ($("#searchType option:selected").val() == "dept") {
			    		search("deptName;"+$("#searchWord").val());
			    	} else {
				    	search("name;"+$("#searchWord").val());       
			    	}
			    	
			    	$("#inputBasic_AX_searchWord_AX_Handle").attr("class","bindSelectorNodes AXanchorSelectorHandle");
			    }
			});

			$('#searchWord_BizCard').keydown(function(e) {
			    if (e.keyCode == 13) {
		    		search_BizCard($("#searchWord_BizCard").val());
			    }
			});
		}
	}
	
	//추가
	function addSelectedRow(type,dataObj)
	{
		var html = '';
		var TL = "";
		var PO = "";
		var LV = "";

		if(searchList == "bizCard"){
			html += "<tr>";
			html += "	<td><input type='checkbox' id='orgSelectedList_people"+ dataObj.BizCardType + "-" + dataObj.ShareType + "-" + dataObj.ID +"' name='"+CFN_GetDicInfo(dataObj.Name,lang)+"' value='"+ jsonToString(dataObj) +"'/></td>";
			html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.Name,lang) + '</td>';
			html += "</tr>";
		}else{
			if(type=="people"){
	  			html += '<tr>';
	    		html += "	<td><input type='checkbox' id='orgSelectedList_people" + dataObj.UserID + "' name='" + CFN_GetDicInfo(dataObj.DN,lang) + "' value='" + jsonToString(dataObj) + "' "+(dataObj.Dis?"disabled":"")+"></td>";
	    		//html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.DN,lang) + ' <span class="lGry">(' + CFN_GetDicInfo(dataObj.ETNM,lang) +')</span></td>';
	    
	    		if (dataObj.TL != undefined && dataObj.TL != ""){
	    			TL = isEmptyDefault(CFN_GetDicInfo(dataObj.TL.split("|")[1],lang), "");
		   			if(CFN_GetDicInfo(dataObj.TL.split("|")[1],lang).charAt(0) == " "){
		    			TL = CFN_GetDicInfo(dataObj.TL.split("|")[1],lang).replace(/ /gi, "");
		   			}
	    		}	
	    		
	    		if (dataObj.PO != undefined && dataObj.PO != ""){
		   			PO = isEmptyDefault(CFN_GetDicInfo(dataObj.PO.split("|")[1],lang), "");
		   			if(CFN_GetDicInfo(dataObj.PO.split("|")[1],lang).charAt(0) == " "){
		   				PO = CFN_GetDicInfo(dataObj.PO.split("|")[1],lang).replace(/ /gi, "");
		   			}
	    		}

				if (dataObj.LV != undefined && dataObj.LV != ""){
		   			LV = isEmptyDefault(CFN_GetDicInfo(dataObj.LV.split("|")[1],lang), "");
		   			if(CFN_GetDicInfo(dataObj.LV.split("|")[1],lang).charAt(0) == " "){
		   				LV = CFN_GetDicInfo(dataObj.LV.split("|")[1],lang).replace(/ /gi, "");
		   			}
	    		}

				var sMultiRepJobTypeConfig = Common.getBaseConfig("MultiRepJobType");
			        var sMultiRepJobType = "";
					if(sMultiRepJobTypeConfig != null && sMultiRepJobTypeConfig != ""){
						sMultiRepJobTypeConfig.split(";").forEach(function(e){
							if(e == "PN"){
							    if(PO == "-" || PO != ""){
									if(sMultiRepJobType != ""){
										sMultiRepJobType += "/";
									}
									sMultiRepJobType += PO;
								}
					        } 
							else if(e == "LN"){
								if(LV == "-" || LV != ""){
									if(sMultiRepJobType != ""){
										sMultiRepJobType += "/";
									}
									sMultiRepJobType += LV;
								}
					        }
							else if(e == "TN"){
								if(TL == "-" || TL != ""){
									if(sMultiRepJobType != ""){
										sMultiRepJobType += "/";
									}
									sMultiRepJobType += TL;
								}
					        }
						});
					} else {
						if(TL == "-" || TL != ""){
							sMultiRepJobType += TL;
						}
						if(PO == "-" || PO != ""){
							if(sMultiRepJobType != ""){
								sMultiRepJobType += "/";
							}
							sMultiRepJobType += PO;
						}
					}
	     
	   			html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.DN,lang) + " (" + sMultiRepJobType + ' ) <span class="lGry">'+CFN_GetDicInfo(dataObj.RGNM,lang)+' (' + CFN_GetDicInfo(dataObj.ETNM,lang) +')</span></td>';
	    
	  			html += '</tr>';
	  		}else if(type=="dept"){
	  			html += '<tr>';
	    		html += "	<td><input type='checkbox' id='orgSelectedList_dept" + dataObj.GroupID + "' value='" + jsonToString(dataObj) + "'></td>";
	    		html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.DN,lang) + '<span class="lGry">(' + CFN_GetDicInfo(dataObj.ETNM,lang) + ')</span></td>';
	    		html += '</tr>';
	 		}
		}
		
	  if( html != '' && (type == "people" || type=="dept") ){
	  	$("#orgSelectedList_"+type).append(html); //type: people or dept
	  }
	  	
	}
	
	function setGroupTreeConfig(){
		var pid = "groupTree" //treeTargetID
		var treeHeight = $(".appTreeBot").height() + 'px';
			
		var func = { 		// 내부에서 필요한 함수 정의
				covi_setCheckBox : function(item){		// checkbox button
					if($this.config.targetID == "orgTargetDiv" && item.Receivable == "0") { // 전자결재 receivable 값에 따라 수신(선택)불가 하도록 처리.
						return "<input type='checkbox' id='"+pid+"_treeCheckbox_"+item.no+"' name='treeCheckbox_"+item.no+"' value='"+jsonToString(item)+"' disabled='true' />";
					}else if(item.chk == "Y"){
						var checked = $("#"+pid+"_treeCheckbox_"+item.no).prop("checked") == true ? "checked" : "";
						return "<input type='checkbox' id='"+pid+"_treeCheckbox_"+item.no+"' name='treeCheckbox_"+item.no+"' value='"+jsonToString(item)+"' "+checked+" />";
					}else if(item.chk == "N"){
						return "";
					}else{
						return "";
					}
				},
				covi_setRadio : function(item){			// radio button
					if(item.rdo == "Y"){
						return "<input type='radio' id='"+pid+"_treeRadio_"+item.no+"' name='treeRadio' value='"+jsonToString(item)+"' />";
					}else if(item.rdo == "N"){
						return "";
					}else{
						return "";
					}
				}
		};
		
		var bodyConfig = {};
		
		if($(":input:radio[name=groupTypeRadio]:checked").val() == "group"){
			bodyConfig = {
					onclick:function(idx, item){
						if(item.GroupType.toUpperCase() != "COMPANY"){							
							changeIndex=0;						
							$this.getUserOfGroupList(item.GroupCode);	
						}else{							
							changeIndex=0;
							$this.groupTree.clearFocus();
						}
					},
					onexpand:function(idx, item){ //[Function] 트리 아이템 확장 이벤트 콜백함수
						if(item.isLoad == "N" && item.haveChild == "Y"){ //하위 항목이 로드가 안된 상태
							$this.groupTree.updateTree(idx, item, {isLoad: "Y"});
							getChildrenData(idx, item);
						}
			        }
			};
		}else{
			bodyConfig = {
					onclick:function(idx, item){
						changeIndex=0;
						$this.getUserOfGroupList(item.GroupCode);	
					},
					onexpand:function(idx, item){ //[Function] 트리 아이템 확장 이벤트 콜백함수
						if(item.isLoad == "N" && item.haveChild == "Y"){ //하위 항목이 로드가 안된 상태
							$this.groupTree.updateTree(idx, item, {isLoad: "Y"});
							getChildrenData(idx, item);
						}
			        }
			};
		}
		
		$this.groupTree.setConfig({
			targetID : "groupTree",					// HTML element target ID
			theme: "AXTree_none",		// css style name (AXTree or AXTree_none)
			height: treeHeight,
			width:"auto",				// 가로스크롤 추가(contentScrollResize 에서 auto일때만 가로스크롤 추가됨)
			checkboxRelationFixed : $this.config.checkboxRelationFixed || false,
			xscroll:true,
			showConnectionLine:true,		// 점선 여부
			relation:{
				parentKey: "pno",		// 부모 아이디 키
				childKey: "no"			// 자식 아이디 키
			},
			persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: false,			// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colGroup:[{
				key: "nodeName",			// 컬럼에 매치될 item 의 키
				//label:"TREE",				// 컬럼에 표시할 라벨
				//width: "400",				// 부서명 말줌임하지 않고 전체 표시시킬 경우 주석해제(긴 부서가 없을때도 스크롤 생기는 문제 있음)
				align: "left",	
				indent: true,					// 들여쓰기 여부
				getIconClass: function(){		// indent 속성 정의된 대상에 아이콘을 지정 가능
					var iconNames = "folder, AXfolder, movie, img, zip, file, fileTxt, company".split(/, /g);
					var iconName = "";
					if(typeof this.item.type == "number") {
						iconName = iconNames[this.item.type];
					} else if(typeof this.item.type == "string"){
						iconName = this.item.type.toLowerCase(); 
					} 
					return iconName;
				},
				formatter:function(){
					var anchorName = $('<a />').attr('id', 'folder_item_'+this.item.no);
					anchorName.text(this.item.nodeName);
					
					if(this.item.url != "" && this.item.url != undefined){
						anchorName.attr('href', this.item.url);
					}
					if(this.item.onclick != "" && this.item.onclick != undefined){
						anchorName = $('<div />').attr('onclick', this.item.onclick).append(anchorName);
					}
					
					var str = anchorName.prop('outerHTML');
					if($this.config.type != "B1"&& $this.config.type!="B9" && $this.config.type!="A0"){
						str = func.covi_setCheckBox(this.item) + str;
					}
					
					return str;
				}
			}],						// tree 헤드 정의 값
			body:bodyConfig									// 이벤트 콜벡함수 정의 값
		});
		
	}
	
	//그룹 트리 바인딩
	function setAllGroupTreeData(){
		var domain = $("#companySelect").val();
		var groupType = $("#groupTypeSelect").val();
		
		setGroupTreeConfig();		
		
		$.ajax({
			url:"/covicore/control/getDeptList.do",
			type:"POST",
			data:{
				"companyCode" : domain,
				"groupType" : groupType,
				"treeKind":$this.config.treeKind,
				"groupDivision":$this.config.groupDivision,
				"communityId":$this.config.communityId
			},
			async:false,
			success:function (data) {
				$this.groupTree.setList(data.list);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getDeptList.do", response, status, error);
			}
		});
		
		$this.groupTree.displayIcon(false); //Icon에 checkbox 가려지는 현상 제거
	}
	
	//그룹 트리 바인딩
	function setInitGroupTreeData(isloadMyDept){
		var domain = $("#companySelect").val();
		var groupType = $("#groupTypeSelect").val();

		if(groupType != 'mail') {
			
			setGroupTreeConfig();
			$.ajax({
				url:"/covicore/control/getInitOrgTreeList.do",
				type:"POST",
				data:{
					"loadMyDept" : isloadMyDept,
					"companyCode" : domain,
					"groupType" : groupType,
					"groupDivision":$this.config.groupDivision,
					"communityId":$this.config.communityId,
					"onlyMyDept":$this.config.onlyMyDept,
					"defaultValue":$this.config.defaultValue,
				},
				async:false,
				success:function (data) {
					$this.groupTree.setList( data.list );
					if($this.config.defaultValue!=undefined&&$this.config.defaultValue!=''){
						setDefalutDept();
					}
					else if(isloadMyDept == "Y"){
						loadMyDept();
					}else{
						$this.groupTree.expandAll(1)
					}
					
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/control/getInitOrgTreeList.do", response, status, error);
				},
			});
	
			$this.groupTree.displayIcon(false); //Icon에 checkbox 가려지는 현상 제거
		
		} else {
			// 기존 부서, 그룹 표시 초기화
			$("#groupTree").empty();
			$("#orgSearchList").empty();
			
			setMailTreeConfig();
			initMailAddrGroupArea();
		}
	}
	
	//하위 항목 조회
	function getChildrenData(idx, item){
		var domain = $("#companySelect").val();
		var groupType = $("#groupTypeSelect").val();
		
		$.ajax({
			url:"/covicore/control/getChildrenData.do",
			type:"POST",
			data:{
				"memberOf" : item.AN,
				"companyCode" : domain,
				"groupType" : groupType,
				"groupDivision":$this.config.groupDivision,
				"communityId":$this.config.communityId
			},
			async:false,
			success:function (data) {
				$this.groupTree.appendTree(idx, item, data.list);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getChildrenData.do", response, status, error);
			},
		});
	}
	
	
	//검색버튼 클릭
	function search(searchTextAndType){
		if(searchTextAndType==null || searchTextAndType=='undefined'){
			return;
		}
		
		var val =searchTextAndType.value;
		
		if(val=="null" || val =="undefined" || val == undefined){
			val = searchTextAndType;
		}
		
		var searchType = val.split(";")[0];
		var searchText = val.split(";")[1];
		
		if(searchText == ""){
			return;
		}

		tmpSearchWord = searchText;
		
		var url;
		var params = new Object();
		
		params.searchText = searchText;
		
		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);
		
		params.groupType = 'dept'; //검색 시 고정
		params.companyCode = $("#companySelect").val();
		
		if (searchType == "deptName") {
			url = "/covicore/control/getDeptList.do";
		} else {
			url = "/covicore/control/getUserList.do";
			params.searchType = searchType;
			//params.groupType =  $("#groupTypeSelect").val();
		}
		
		$.ajax({
			url: url,
			type:"post",
			data: params,
			success:function (data) {
				if (searchType == "deptName") {
					setMemberList(data,"schDept");
				} else {
					setMemberList(data,"search");
				}
				
				$("#selDeptTxt").text("");			// 조회된 후 선택부서TEXT 초기화		
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}

	//검색버튼 클릭
	function search_BizCard(searchText){
		tmpSearchWord = searchText;
		
		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);

		$("#spanBizCardCurPage_UR").text("1");
		$("#hidBizCardCurPage_UR").val("1");
		
		$.ajax({
			type:"POST",
			data:{
				pageNo : "1",
				pageSize : "100",
				itemType: "UR",
				publicUserCode : Common.getSession("UR_Code"),
				searchText: tmpSearchWord,
				shareType : BizCardShareType,
				hasEmail : "N"
			},
			url:"/groupware/bizcard/getBizCardOrgMapList.do",
			success:function (data) {
				setMemberList_BizCard(data, "UR");
			}
		});

		if($this.config.bizcardKind == "ALL"){
			$("#spanBizCardCurPage_GR").text("1");
			$("#hidBizCardCurPage_GR").val("1");
			
			$.ajax({
				type:"POST",
				data:{
					pageNo : "1",
					pageSize : "100",
					itemType: "GR",
					publicUserCode : Common.getSession("UR_Code"),
					searchText: tmpSearchWord,
					shareType : BizCardShareType,
					hasEmail : "N"
				},
				url:"/groupware/bizcard/getBizCardOrgMapList.do",
				success:function (data) {
					setMemberList_BizCard(data, "GR");
				}
			});
		}
	}
		
	
	// 각 부서에 해당하는 사원들 리스트 HTML 바인딩
	function setMemberList(data,pMode){
		if($this.config.drawOpt.charAt(1)!="M")
			return;
		
		var strData = "";
		var strMsg;

		if(data.list.length == 0 || data.list.length == null)
			strMsg = orgDic["msg_NoDataList"] //조회할 목록이 없습니다.
		else{
			strMsg = "";

			$(data.list).each(function(){
				 var PO = "";
				 var TL = "";
				 var LV = "";
				
				 if (pMode != "schDept") {
					TL = isEmptyDefault(CFN_GetDicInfo(this.TL.split("|")[1],lang), "");
					PO = isEmptyDefault(CFN_GetDicInfo(this.PO.split("|")[1],lang), "");
					LV = isEmptyDefault(CFN_GetDicInfo(this.LV.split("|")[1],lang), "");
					
					if(CFN_GetDicInfo(this.TL.split("|")[1],lang).charAt(0) == " "){
						TL = CFN_GetDicInfo(this.TL.split("|")[1],lang).replace(/ /gi, "");
					}
					
					if(CFN_GetDicInfo(this.PO.split("|")[1],lang).charAt(0) == " "){
						PO = CFN_GetDicInfo(this.PO.split("|")[1],lang).replace(/ /gi, "");
					}
					
					if(CFN_GetDicInfo(this.LV.split("|")[1],lang).charAt(0) == " "){
						LV = CFN_GetDicInfo(this.LV.split("|")[1],lang).replace(/ /gi, "");
					}
				 }else{
					 PO = "-";
					 TL = "-";
					 LV = "-";
				 }
				 
				 if (pMode == "schDept") {
					strData += "<tr type='dept' ondblclick='coviOrg.contentDoubleClick(this)' draggable='true' ondragstart='coviOrg.void_ListItem_ondragstart(event);' ondragend='coviOrg.void_ListItem_ondragend(event);'>";
					if($this.config.type=="A0"){
						strData += "";
					}else if ($this.config.type == "B1" || $this.config.type == "B9") {
						strData += "<td></td>";
					}else if($this.config.targetID == "orgTargetDiv" && this.RCV == "0"){
						strData += "<td><input type='checkbox' id='orgSearchList_dept"+this.GroupID +"' name='"+CFN_GetDicInfo(this.DN,lang) +"' value='"+ jsonToString(this) +"' disabled='true'/></td>";
					}else {
						strData += "<td><input type='checkbox' id='orgSearchList_dept"+this.GroupID +"' name='"+CFN_GetDicInfo(this.DN,lang) +"' value='"+ jsonToString(this) +"'/></td>";
					}
					
					strData += "<td colspan=\"2\" class='subject'><dl class='listBotTit'><dt>"+CFN_GetDicInfo(this.DN,lang) + " (" + CFN_GetDicInfo(this.ETNM,lang) + ") </dt><dd class='lGry'>"+this.GroupFullPath +"</dd></dl></td>";
					
					if($this.config.type=="A0"){
						strData += "<td></td>";
						strData += "<td></td>";
					}
					strData += "</tr>";
				} else { //pMode == 'search' or 'undefined'
					strData += "<tr type='people' ondblclick='coviOrg.contentDoubleClick(this)' draggable='true' ondragstart='coviOrg.void_ListItem_ondragstart(event);' ondragend='coviOrg.void_ListItem_ondragend(event);'>";
					var sMultiRepJobTypeConfig = Common.getBaseConfig("MultiRepJobType");
			        var sMultiRepJobType = "";
					if(sMultiRepJobTypeConfig != null && sMultiRepJobTypeConfig != ""){
						sMultiRepJobTypeConfig.split(";").forEach(function(e){
							if(e == "PN"){
							    if(PO == "-" || PO != ""){
									if(sMultiRepJobType != ""){
										sMultiRepJobType += "/";
									}
									sMultiRepJobType += PO;
								}
					        } 
							else if(e == "LN"){
								if(LV == "-" || LV != ""){
									if(sMultiRepJobType != ""){
										sMultiRepJobType += "/";
									}
									sMultiRepJobType += LV;
								}
					        }
							else if(e == "TN"){
								if(TL == "-" || TL != ""){
									if(sMultiRepJobType != ""){
										sMultiRepJobType += "/";
									}
									sMultiRepJobType += TL;
								}
					        }
						});
					} else {
						if(TL == "-" || TL != ""){
							sMultiRepJobType += TL;
						}
						if(PO == "-" || PO != ""){
							if(sMultiRepJobType != ""){
								sMultiRepJobType += "/";
							}
							sMultiRepJobType += PO;
						}
					}
					
					if($this.config.type=="A0"){
						strData += "<td><a href='#none' class='cirPro'><img src='"+ coviCmn.loadImage(this.PhotoPath) +"' alt='' onerror='coviOrg.imgError(this);'></a></td>"
						strData += "<td class='subject'><dl class='listBotTit'><dt onclick='coviOrg.goUserInfoPopup(\""+this.AN +"\")'>"+CFN_GetDicInfo(this.DN,lang) + (sMultiRepJobType == "" ? "" : " (" + sMultiRepJobType + ")") + "</dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+" (" +CFN_GetDicInfo(this.ETNM,lang) + ")" +"</dd></dl></td>";											
						strData += "<td class='subject'><dl class='listBotTit'><dt class='lGry'>"+ orgDic["lbl_MobilePhone"] +": "+isEmptyDefault(this.MT,'') +"</dt><dd class='lGry'>"+ orgDic["lbl_CompanyNumber"] +": "+isEmptyDefault(this.OT,'')+"</dd></dl></td>" //핸드폰, 회사번호
						strData += "<td class='subject'><dl class='listBotTit'><dt class='lGry'>"+ orgDic["lbl_apv_appMail"] +": "+isEmptyDefault(this.EM,'') +"</dt><dd class='lGry'>"+ orgDic["lbl_Role"] +": "+CFN_GetDicInfo(isEmptyDefault(this.ChargeBusiness,''), lang)+"</dd></dl></td>" //메일, 담당업무
						
					}else{
						if($this.config.type=="A1") 
							strData += "<td><input type='radio' id='orgSearchList_people"+this.UserID +"' name='orgSearchList_people' value='"+ jsonToString(this) +"'/></td>";
						else
							strData += "<td><input type='checkbox' id='orgSearchList_people"+this.UserID +"' name='"+CFN_GetDicInfo(this.DN,lang)+"' value='"+ jsonToString(this) +"'/></td>";
						if(pMode != "mail") {
							strData += "<td><a href='#none' class='cirPro'><img src='"+ coviCmn.loadImage(this.PhotoPath) +"' alt='' onerror='coviOrg.imgError(this);'></a></td>";
							
							if($this.config.targetID == "orgTargetDiv") { // 전자결재 결재선 팝업, 회람 팝업
							strData += "<td class='subject'><dl class='listBotTit'><dt onClick='coviOrg.changeBackgroundColor(this)'>"+CFN_GetDicInfo(this.DN,lang)+ (sMultiRepJobType == "" ? "" : " (" + sMultiRepJobType + ")") + "</dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+" (" +CFN_GetDicInfo(this.ETNM,lang) + ")" +"</dd></dl></td>";
							}
							else {
								strData += "<td class='subject'><dl class='listBotTit'><dt onclick='coviOrg.goUserInfoPopup(\""+this.AN +"\")'>"+CFN_GetDicInfo(this.DN,lang)+ (sMultiRepJobType == "" ? "" : " (" + sMultiRepJobType + ")") + "</dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+" (" +CFN_GetDicInfo(this.ETNM,lang) + ")" +"</dd></dl></td>";
							}
						} else {
							strData += "<td>" + CFN_GetDicInfo(this.DN,lang) + "</td>";
							strData += "<td class='subject'><dl class='listBotTit'><dd class='lGry'><span style='color: #000; width: 40px; display: inline-block; margin-right: 5px;'>메일</span>";
							strData += "<span style='width: 85px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: inline-block; float: right;'>" + this.EM + "</span></dd>";
							strData += "<dd class='lGry'><span style='color: #000; width: 40px; display: inline-block; margin-right: 5px;'>휴대폰</span>";
							strData += "<span style='width: 85px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: inline-block; float: right;'>" + this.Mobile + "</span></dd></dl></td>";
						}
						
					}
					strData += "</tr>";
				}
			});
		}
		document.getElementById("orgSearchListMessage").innerHTML = strMsg;
		document.getElementById("orgSearchList").innerHTML = strData;
	}

	// 각 부서에 해당하는 사원들 리스트 HTML 바인딩
	function setMemberList_BizCard(data,pType){
		if($this.config.drawOpt.charAt(1)!="M")
			return;
		var strData = "";
		var strMsg;

		if(data.page != null && data.page.pageCount > 1){
			$("#spanBizCardTotalPage_" + pType).text(data.page.pageCount);
			$("#divBizCardPaging_" + pType).show();
		}else{
			$("#divBizCardPaging_" + pType).hide();
			$("#spanBizCardTotalPage_" + pType).text("1");
		}
		
		if(data.list == null || data.list.length == 0 || data.list.length == null){
			strMsg = orgDic["msg_NoDataList"] //조회할 목록이 없습니다.
		}else{
			strMsg = "";
			if(pType == "GR"){
				$(data.list).each(function(nIdx, oElm){
					oElm.DN = oElm.Name;
					oElm.EM = oElm.Email;
					
					var oListMember = $(data.listMember).filter(function() { return this.GroupID == oElm.ID });
					if(oListMember.length > 0){
						oElm.Member = jsonToString(oListMember);
					}else{
						oElm.Member = "";
					}
					
					strData += "<tr type='bizcard' ondblclick='coviOrg.contentDoubleClick(this)'>";
					strData += "<td style='height:20px !important;'><input type='checkbox' id='orgSearchList_bizcard_" + pType + "_" + oElm.ID +"' name='"+ oElm.Name.replace(/'/g, "＇") +"' value='"+ jsonToString(oElm).replace(/'/g, "＇") +"'/></td>";
					strData += "<td style='height:20px !important;' class='subject'>" + $("<div />").text(oElm.Name).html() + "</td>";
					strData += "</tr>";
				});
			}else{
				$(data.list).each(function(){
					this.DN = this.Name;
					this.EM = this.Email;
					strData += "<tr type='bizcard' ondblclick='coviOrg.contentDoubleClick(this)'>";
					strData += "<td style='height:20px !important;'><input type='checkbox' id='orgSearchList_bizcard_" + pType + "_" + this.ID +"' name='"+ this.Name.replace(/'/g, "＇") +"' value='"+ jsonToString(this).replace(/'/g, "＇") +"'/></td>";
					strData += "<td style='height:20px !important;' class='subject'>" + $("<div />").text(this.Name).html() + "</td>";
					strData += "</tr>";
				});
			}
			
		}

		document.getElementById("orgSearchListMessage_BizCard_" + pType).innerHTML = strMsg;
		document.getElementById("orgSearchList_BizCard_" + pType).innerHTML = strData;
	}
	
	// 연락처/그룹 페이지 이동
	coviOrgObj.BizCardPageMove_onclick = function(pMode,pType){
		var bMovePage = false;
		if(pMode == "PREV"){
			var nTargetPage = parseInt($("#hidBizCardCurPage_" + pType).val(), 10) - 1;
			if (nTargetPage > 0) {
				bMovePage = true;
				
				$("#spanBizCardCurPage_" + pType).text(nTargetPage);
				$("#hidBizCardCurPage_" + pType).val(nTargetPage);
			}
		}else{
			var nTotalPage = parseInt($("#spanBizCardTotalPage_" + pType).text(), 10);
			var nTargetPage = parseInt($("#hidBizCardCurPage_" + pType).val(), 10) + 1;
			if (nTargetPage <= nTotalPage) {
				bMovePage = true;
				
				$("#spanBizCardCurPage_" + pType).text(nTargetPage);
				$("#hidBizCardCurPage_" + pType).val(nTargetPage);
			}
		}
		
		if(bMovePage){
			$.ajax({
				type:"POST",
				data:{
					pageNo : $("#hidBizCardCurPage_" + pType).val(),
					pageSize : "100",
					itemType: pType,
					publicUserCode : Common.getSession("UR_Code"),
					searchText: tmpSearchWord,
					shareType : BizCardShareType,
					hasEmail : "N"
				},
				url:"/groupware/bizcard/getBizCardOrgMapList.do",
				success:function (data) {
					setMemberList_BizCard(data, pType);
				}
			});
		}
	}
	
	
	//화면 로드 시 사용자의 부서 로드
	function loadMyDept(){
		var companyCode = sessionObj["DN_Code"];		//companyCode로 명칭 변경
		var deptID = sessionObj["DEPTID"];
		
		if($this.config.drawOpt.charAt(0)=="L"){
			$this.groupTree.expandAll(1)	// tree의 depth 1만 open
		
			$($this.groupTree.list).each(function(i,obj){
				if(deptID == obj.GroupCode){
					$this.groupTree.click(obj.__index,'open');	
					$this.getUserOfGroupList(obj.GroupCode);
				}
			});
			
		}
	}
	//화면 로드 시 사용자의 부서 로드
	function setDefalutDept(){
		var companyCode = sessionObj["DN_Code"];		//companyCode로 명칭 변경
		var deptID = $this.config.defaultValue;
		
		if($this.config.drawOpt.charAt(0)=="L"){
			$this.groupTree.expandAll(1)	// tree의 depth 1만 open
		
			$($this.groupTree.list).each(function(i,obj){
				if(deptID == obj.GroupCode){
					$this.groupTree.click(obj.__index,'open');	
					$this.getUserOfGroupList(obj.GroupCode);
				}
			});
			
		}
	}
	
	function getGroupName(deptCode){
		var groupName = '';
		
		$($this.groupTree.list).each(function(i,obj){
			if(deptCode == obj.GroupCode){
				groupName = CFN_GetDicInfo(obj.GroupName,lang);
				return false;
			}
		});
		
		return groupName;
	}
	
	
	// 선택한 데이터 가져옴
	function getSelectedData(type) {
		var rtnArr = new Array();
		
		if($this.config.drawOpt.charAt(3)!="R")
			return rtnArr;
		
		if (type == "people") {
			// 선택한 임직원 테이블
			$("[id^='orgSelectedList_people']").each(function(){
				rtnArr.push($(this)[0].id);
			});
		} else {
			// 선택한 부서 테이블
			$("#orgSelectedList_dept input:checkbox").each(function(){
				rtnArr.push($(this)[0].id);
			});
		}

		return rtnArr;
	}
	
	
	// 선택목록에 있는 데이터를 리턴할 JSON 형태로 변경
	function makeOrgJsonData(){
			var returnvalue = {};
			var orgData = new Array;
	
			$("#orgSelectedList_people input:checkbox").each(function(){
				orgData.push($.parseJSON($(this)[0].value));
			});
	
			$("#orgSelectedList_dept input:checkbox").each(function(){
				var deptData = $.parseJSON($(this)[0].value);
				
				// 트리를 그리기 위한 데이터를 모두 지움
				$$(deptData).concat().eq(0).remove("SortPath");
				$$(deptData).concat().eq(0).remove("GroupID");
				$$(deptData).concat().eq(0).remove("nodeName");
				$$(deptData).concat().eq(0).remove("nodeValue");
				$$(deptData).concat().eq(0).remove("groupID");
				$$(deptData).concat().eq(0).remove("pno");
				$$(deptData).concat().eq(0).remove("chk");
				$$(deptData).concat().eq(0).remove("rdo");
				$$(deptData).concat().eq(0).remove("url");
				$$(deptData).concat().eq(0).remove("__index");
				$$(deptData).concat().eq(0).remove("open");
				$$(deptData).concat().eq(0).remove("display");
				$$(deptData).concat().eq(0).remove("pHash");
				$$(deptData).concat().eq(0).remove("hash");
				$$(deptData).concat().eq(0).remove("__isLastChild");
				$$(deptData).concat().eq(0).remove("__subTreeLength");
				
				orgData.push($$(deptData).concat().eq(0).json());
			});
	
			$$(returnvalue).attr("item", orgData);
			$$(returnvalue).attr("userParams", $this.config.userParams);
	
			return JSON.stringify(returnvalue);
	}

	//초기 설정 값 셋팅 시 빈값 확인
	function isEmpty(value){
		  return (value == undefined || value == 'undefined');
	}
	
	
	//초기 설정 값 셋팅 시 빈값 확인
	function isEmptyDefault(value, defaultVal){
		  if(value == undefined || value == 'undefined'){
			  return defaultVal;
		  }
		  return value;
	}
	

	//메뉴 변경
	function changeMenu(param){
		tmpSearchWord = "";
		$("a[class^='bizCardGroup']").removeClass("selected");
		$('tr[class*=selected]').removeClass("selected");
		$('#selDeptTxt').empty();
		$('#selGroupTxt').empty();
		$('#orgSearchList').empty();
		$('#orgSearchList_BizCard').empty();
		$('#groupMailSearchList').empty();
		var appTree = $('#orgChart').find('div[class=appTree]');
		for(var i=0 ; i<appTree.length ; i++){
			if($(appTree[i]).attr('id') == param){
				$(appTree[i]).show();
			}else{                     
				$(appTree[i]).hide();
			}
		}
		
		if(param == "BizCardDiv"){
			$("#divSearchList_Main").hide();
			$("#divSearchList_BizCard").show();
			$("#searchdiv").hide();
			$("#searchdiv_BizCard").show();
		}else{
			$("#divSearchList_Main").show();
			$("#divSearchList_BizCard").hide();
			$("#searchdiv").show();
			$("#searchdiv_BizCard").hide();
		}
	}

	//연락처 그룹 상세조회
	function ClickLeft(pObj){
		$("a[class^='bizCardGroup']").removeClass("selected");
		$(pObj).addClass("selected");
		tmpSearchWord = "";
		BizCardShareType = $(pObj).attr("value");
		
		$("#spanBizCardCurPage_UR").text("1");
		$("#hidBizCardCurPage_UR").val("1");
		
		$.ajax({
			type:"POST",
			data:{
				pageNo : "1",
				pageSize : "100",
				itemType: "UR",
				publicUserCode : Common.getSession("UR_Code"),
				searchText: tmpSearchWord,
				shareType : BizCardShareType,
				hasEmail : "N"
			},
			url:"/groupware/bizcard/getBizCardOrgMapList.do",
			success:function (data) {
				setMemberList_BizCard(data, "UR");
			}
		});

		if($this.config.bizcardKind == "ALL"){
			$("#spanBizCardCurPage_GR").text("1");
			$("#hidBizCardCurPage_GR").val("1");
			
			$.ajax({
				type:"POST",
				data:{
					pageNo : "1",
					pageSize : "100",
					itemType: "GR",
					publicUserCode : Common.getSession("UR_Code"),
					searchText: tmpSearchWord,
					shareType : BizCardShareType,
					hasEmail : "N"
				},
				url:"/groupware/bizcard/getBizCardOrgMapList.do",
				success:function (data) {
					setMemberList_BizCard(data, "GR");
				}
			});
		}
	}
	
	// 탭 변경
	function clickTab(pObj){
		$("#divTabTray").find("a").parent().removeClass("active");
		$(pObj).parent().addClass("active");
		$("#searchInput").val("");
		if($("#divTabTray .active").find("a").attr('value') == 'Group'){
			if($('#bizcard_btn_group').css("display") != "none") {
				$('#bizcard_btn_group').css("display", "none");
				$('#group_btn_group').css("display", "block");
			}
			$('#btnDelete').removeAttr('onclick');
			$("#btnDelete").attr("onclick", "DeleteCheck(bizCardGrid, bizCardViewType, 'Group')");
		}else{
			if($('#group_btn_group').css("display") != "none") {
				$('#bizcard_btn_group').css("display", "block");
				$('#group_btn_group').css("display", "none");
			}
			$('#btnDelete').removeAttr('onclick');
			$("#btnDelete").attr("onclick", "DeleteCheck(bizCardGrid, bizCardViewType, 'Person')");
		}
	}
	
	//JSON Object to String 
	function jsonToString(jsonObj){
		if(jsonObj != undefined && jsonObj != ''){
			var jsonStr = Object.toJSON(jsonObj);
			
			//특수 문자 처리
			jsonStr = jsonStr.replaceAll("'", "&#39;");
			
			return jsonStr;
		}
	}

	function setSelectedData(){
		var selected = '';
		try {
			var userParams = JSON.parse(decodeURIComponent($this.config.userParams));
			selected = userParams.selected;
		}
		catch(ex) {
			coviCmn.traceLog(ex);
		}
		
		if (selected == ''){
			return;
		}

		getUserData(selected);
		getDeptData(selected);
	}
	
	function getUserData(users){
		$.ajax({
			type: "POST",
			data:{
				"selections" : users
			},
			async: true,
			url: "/covicore/control/getSelectedUserList.do",
			success: function (data) {
				if (data.status == 'SUCCESS'){
					$.each(data.list, function(idx, el){
						el.itemType = 'user';
						addSelectedRow('people', el);
					});
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getSelectedUserList.do", response, status, error);
			}
		});
	}
	
	function getDeptData(depts){
		$.ajax({
			type: "POST",
			data:{
				"selections" : depts
			},
			async: true,
			url: "/covicore/control/getSelectedDeptList.do",
			success: function (data) {
				if (data.status == 'SUCCESS'){
					$.each(data.list, function(idx, el){
						addSelectedRow('dept', el);
					});
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getSelectedDeptList.do", response, status, error);
			}
		});
	}
	
	return coviOrgObj;
	
}());
