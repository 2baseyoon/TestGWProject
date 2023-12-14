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
//# sourceURL=covision.orgchart.mail.js
var coviOrgMail = (function () {
	var coviOrgObj={};
	//lbl_to
	var orgDic =  Common.getDicAll(["lbl_officer", "lbl_apv_deptsearch", "btn_Confirm","btn_Close", "lbl_apv_person","btn_apv_search",
	                                ,"msg_OrgMap03","msg_OrgMap04","msg_OrgMap05","msg_OrgMap06","lbl_name","lbl_dept" , "msg_EnterSearchword"
	                                ,"lbl_MobilePhone", "lbl_apv_InPhone", "lbl_Role", "lbl_JobPosition","lbl_JobLevel","msg_NoDataList", "lbl_CompanyNumber"
	                                ,"OrgTreeKind_Dept","OrgTreeKind_Group", "lbl_UserProfile", "lbl_DeptOrgMap" , "lbl_group","lbl_OpenAll","lbl_CloseAll", "lbl_apv_recinfo_td2"
									,"lbl_com_exportAddress", "lbl_apv_appMail", "lbl_com_Absense", "lbl_com_searchByName", "lbl_com_searchByDept", "lbl_com_searchByPhone"
									, "lbl_com_searchByRole", "lbl_com_searchByJobPosition", "lbl_com_searchByJobLevel" ,"lbl_Mail_Cc" , "lbl_Mail_Bcc" , "lbl_Mail_To"
									, "lbl_Mail_Contact","CPMail_Dept","CPMail_Contact", "CPMail_Personal", "CPMail_Company","CPMail_mail_itemSel", "CPMail_To"
									, "CPMail_mail_cc", "CPMail_mail_bcc", "CPMail_Delete", "lbl_Mail_CardView", "lbl_Mail_AddressType_G"]);
	
	var sessionObj = Common.getSession();
	var lang = sessionObj["lang"]; 
	var ProfileImagePath = Common.getBaseConfig("ProfileImagePath").replace("/{0}", ""); //프로필 이미지 경로
	
	var $this = coviOrgObj;
	var allGroupBind = "N";
	var tmpSearchWord = "";
	var BizCardShareType = "";
	var searchList = "groupTree"; 
	var selectedList = "";
	
	coviOrgObj.groupTree = new AXTree();
	
	if (Common.getBaseConfig("orgchartTreeCheckAll") == 'N'){
		coviOrgObj.groupTree.gridCheckClick = function(){}
	}
	
	coviOrgObj.config = {
			targetID: '',
			type:'D9',
			//treeKind:'Dept',
			treeKind:'Group',
			drawOpt:'LMARB', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
			callbackFunc: '', 
			openerID:'',
			allCompany: 'Y',     /// 타 계열사 검색 허용 여부
			groupDivision: '',
			communityId: '',
			bizcardKind:''
	}; 
	
	
	coviOrgObj.imgError = function(image) {
	    image.onerror = "";
	    image.src = "/covicore/resources/images/common/noimg.png";
	    return true;
	}
	
	//public 함수 
	coviOrgObj.render = function(orgOpt){
		if(CFN_GetQueryString("type") == "OUTLOOK") {
			$this.config.drawOpt = 'LMAR_';
		}
		
		setConfig(orgOpt);
		insertBasicHTML();
		setSelect();
		
		if($this.config.drawOpt.charAt(0)=="L"){
			setInitGroupTreeData("Y");
			//setGroupTreeData();
			//loadMyDept();
		}
		//수신인에 추가된 사용자d 조직도에 바인딩
		var allList;
		
		if(CFN_GetQueryString("type") == "OUTLOOK") {
			try {
				if(window.external && ('GetRecipientXml' in window.external)) {
					selectedList = window.external.GetRecipientXml();
				}
			} catch (e) {
				coviCmn.traceLog(e);
			}
			
			allList = setOrgXmlData();
		} else {
			allList = parent.setOrgbind();
		}
		
		for(var i = 0; i < allList.length; i++){
			var type = "";
			var target = "";
			
			if(i == 0){
				type = "P_TO";
				target = "orgAutoCon";
			}else if(i == 1){
				type = "P_CC";
				target = "orgAutoConCC";
			}else if(i == 2){
				type = "P_BCC";
				target = "orgAutoConBCC";
			}
			
			for(var j = 0; j < allList[i][type].length; j++){
				var user = allList[i][type][j];
				user.DN = CFN_GetDicInfo(user.UserName,lang)+";";
				user.EM = CFN_GetDicInfo(user.MailAddress,lang);
				user.TYPE = type;
				user.TARGET = target;
				var strTemp = "<tr>";

				if(user.BizCardType != null && user.BizCardType != ""){
					strTemp += "	<td><input type='checkbox' id='orgSelectedList_"+ user.BizCardType + "-" + user.ShareType + "-" + user.ID +"' name='"+CFN_GetDicInfo(user.UserName,lang)+"' value='"+ jsonToString(user) +"'/></td>";
					strTemp += '	<td class="subject">' + CFN_GetDicInfo(user.UserName,lang) + ' ' + CFN_GetDicInfo(user.MailAddress,lang) + '</td>';
					strTemp += "</tr>";
				}else{
					strTemp += "	<td><input type='checkbox' id='orgSelectedList_"+CFN_GetDicInfo(user.MailAddress,lang)+"' name='"+CFN_GetDicInfo(user.UserName,lang)+"' value='"+ jsonToString(user) +"'/></td>";
					strTemp += '	<td class="subject">' + CFN_GetDicInfo(user.UserName,lang) + ' ' + CFN_GetDicInfo(user.MailAddress,lang) + '</td>';
					strTemp += "</tr>";
				}
				$("#orgSelectedList_"+type).append(strTemp); //type: people or dept
			}
		}
		
		/*if($this.config.drawOpt.charAt(3)=="R"){
		}
		*/
		
		//메뉴 탭 클릭시
		$(document).on("click", "a[id='changeGroupTree']", function(){
			searchList = "groupTree";
			changeMenu("groupTreeDiv");
		});
		$(document).on("click", "a[id='changeBizCard']", function(){
			$("#divTabTray").find("a").parent().removeClass("active");
			$("#bizCardListAll").parent().addClass("active");
			searchList = "bizCard";
			changeMenu("BizCardDiv");

			try{
				ClickLeft($("a[class='bizCardGroup'][value='P']").get(0));
			}catch(ex){
				coviCmn.traceLog(ex);
			}
		});
		// 주소록 탭 변경시
		$(document).on("click", "#divMailBizTabTray a[id^='bizCardList']" , function(){
			$("#allchk").attr("checked", false);
			$("#allchk_BizCard").attr("checked", false);
			clickTab(this);
		});
		
		// 그룹트리 변경시
		$(document).on("change", "#companySelect" , function(){
			$('#orgSearchList').empty();
			$('#orgSearchList_BizCard').empty();
			$('#orgSearchList_BizCard_GroupMail').empty();
			$("#selDeptTxt").empty();
		});
		
		// 연락처 그룹 변경시
		$(document).on("click", "a[class^='bizCardGroup']" , function(){
			$("#allchk").attr("checked", false);
			$("#allchk_BizCard").attr("checked", false);
			ClickLeft(this);
		});
		
		//그룹메일 탭으로 변경시
		$(document).on("click", "a[id='changeGroupMail']", function(){
			$("#divTabTray").find("a").parent().removeClass("active");
			$("#bizCardListAll").parent().addClass("active");
			searchList = "autoCompleteGroupMail";
			changeMenu("GroupMailDiv");
			
			var companyCode = $("#companySelectForGroup").val();
			var searchWord = $("#searchWord_GroupMail").val()
			orgGroupMailData(companyCode, searchWord);
		});

		if(CFN_GetQueryString("priority") == "bizcard"){
			$("#allchk").attr("checked", false);
			$("#allchk_BizCard").attr("checked", false);
			clickTab("#divMailBizTabTray a[id^='bizCardList']");
			ClickLeft("a[class^='bizCardGroup'][value='P']");			
		}
	};

	coviOrgObj.returnData = function(){
		 if(CFN_GetQueryString("type") == "OUTLOOK") {
			 var rtnVal = makeOrgXmlData();
			 return rtnVal;
		 } else {
			if($this.config.type=="A0"){
				$this.closeLayer();
				return;
			}
			
			if($this.config.type=="B1"){
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
					//var temFunc = new Function('param', coviCmn.getParentFrame( $this.config.openerID )+$this.config.callbackFunc+"(param)");
					//temFunc(makeOrgJsonData());
					let oFrame = coviCmn.getParentFrameObj($this.config.openerID);
					if(jQuery.isFunction(oFrame[$this.config.callbackFunc])){
						oFrame[$this.config.callbackFunc].apply(this, [makeOrgJsonData()]);
					}
				} else if(parent[$this.config.callbackFunc] != undefined){
					parent[$this.config.callbackFunc](makeOrgJsonData());
				} else if(opener[$this.config.callbackFunc] != undefined){
					opener[$this.config.callbackFunc](makeOrgJsonData());
	    		} else if(window[$this.config.callbackFunc] != undefined){
					window[$this.config.callbackFunc](makeOrgJsonData());
				}
			}
			$this.closeLayer();
		}
	}
	
	coviOrgObj.closeLayer = function(){
		Common.Close();
	}
	
	coviOrgObj.getUserOfGroupList = function(nodeValue){
		if($this.config.type=="C1"||$this.config.type=="C9"||$this.config.drawOpt.charAt(1)!="M")
			return ;
		
		var deptCode = nodeValue;
		var groupType = $(":input:radio[name=groupTypeRadio]:checked").val();	//var groupType = "Dept";
		
		$("#selDeptTxt").text(getGroupName(deptCode));
		
		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);
		$("#allchk_GroupMail").attr("checked", false);

		setGroupInfo(deptCode);

		$.ajax({
			type:"POST",
			data:{
				"deptCode" : deptCode,
				"groupType" : groupType,
				"isMailChk" : "Y",
				//"hasChildGroup": "Y", //($("#hasChildGroup").prop("checked") ? "Y": "N"),
				"useAttendStatus": Common.getBaseConfig('useAttendStatusInOrgChart')
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
	
	coviOrgObj.allCheck = function(obj){
		var table= $("#orgSearchList").closest('table');
		$('tbody tr td input[type="checkbox"]',table).prop('checked', $(obj).prop('checked'));
	}
	coviOrgObj.allCheck_BizCard = function(obj, pType){
		var table= $("#orgSearchList_BizCard_" + pType).closest('table');
		$('tbody tr td input[type="checkbox"]',table).prop('checked', $(obj).prop('checked'));
	}
	
	coviOrgObj.sendTo = function(){
		
		if($this.config.drawOpt.charAt(3)!="R")
			return;
		var dupStr=""; //중복된 데이터
		var newStr=""; //새로운 데이터
		var dataobj = "";
		var noEmStr = ""; //메일 정보 없는 대상
		
		//타입 구분
		var	type = searchList;
		
		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);
		$("#allchk_GroupMail").attr("checked", false);
		var diffStr = "orgSelectedList_";
		
		// 받는사람
		if(type != "groupMail"){
			if(!$("input:checkbox").is(":checked")){
				//$('tr[class*=selected]').find('input').prop("checked" , true);
			}
			$("div[id^=divSearchList_] input:checkbox, div[id=groupTreeDiv] input:checkbox").each(function() { // 그룹트리
				if ($(this).is(":checked") && $(this).attr("id") != "allchk_BizCard_UR" && $(this).attr("id") != "allchk_BizCard_GR" && $(this).attr("id") != "allchk_GroupMail" ) {
					var isOld = false;
					dataobj =  JSON.parse(this.value);
					dataobj.TYPE = "P_TO";
					dataobj.TARGET = "orgAutoCon";
					var itemType = dataobj.itemType;
					if(dataobj.EM.length != 0){
						if(itemType == "user"){	//사용자
							var oldSelectList_people = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_people.length != 0) {
								for(var i=0; i<oldSelectList_people.length; i++){
			 						if(oldSelectList_people[i] == (diffStr + dataobj.EM)){
										dupStr += $(this)[0].name +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_TO",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else if(itemType =="group"){ // 부서
							var oldSelectList_group = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_group.length != 0) {
								for(var i=0; i<oldSelectList_group.length; i++){
			 						if(oldSelectList_group[i] == (diffStr + dataobj.EM)){
										dupStr += dataobj.DN.split(";")[0] +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_TO",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else if(itemType =="GroupMail"){ // 그룹메일
							var oldSelectList_groupMail = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_groupMail.length != 0) {
								for(var i=0; i<oldSelectList_groupMail.length; i++){
			 						if(oldSelectList_groupMail[i] == (diffStr + dataobj.EM)){
										dupStr += dataobj.DN.split(";")[0] +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_TO",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else{	//주소록
							var oldSelectList_bizcard = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_bizcard.length != 0) {
								for(var i=0; i<oldSelectList_bizcard.length; i++){
									if(oldSelectList_bizcard[i] == (diffStr + dataobj.BizCardType + "-" + dataobj.ShareType + "-" + dataobj.ID)){
										dupStr += $(this)[0].name +", "
										isOld = true;
										break;
									}
								}
							}
							if(!isOld){
								addSelectedRow("P_TO",dataobj);
								newStr += dataobj.Name +", ";
							}
						}
					}else{
						noEmStr += $(this)[0].name +", "
					}

				}
			
			});		
		}else{	//연락처 그룹
			$("#orgSearchList").find($($("input:checkbox"))).prop("checked" , true);
			$("div[id^=divSearchList_] input:checkbox, div[id=groupTreeDiv] input:checkbox").each(function() {
				if ($(this).is(":checked")) {
					var isOld = false;
					dataobj =  JSON.parse(this.value);
					dataobj.TYPE = "P_TO";
					dataobj.TARGET = "orgAutoCon";
					var oldSelectList_groupmail = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
					if (oldSelectList_groupmail.length != 0) {
						for(var i=0; i<oldSelectList_groupmail.length; i++){
							if(oldSelectList_groupmail[i] == (diffStr + dataobj.EMAIL)){
							dupStr += $(this)[0].name +", "
							isOld = true;
							break;
							}
						}
					}
					if(!isOld){
						addSelectedRow("P_TO",dataobj);
						newStr += dataobj.Name +", ";
					}
				}
			});
		}
		// 선택목록으로 이동후 체크박스 모두 해제
		$("#orgSearchList input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		$("#orgSearchList_BizCard_UR input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		$("#orgSearchList_BizCard_GR input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("#orgSearchList_BizCard_GroupMail input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("#groupMailSearchList input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("input:checkbox[id^=groupTree]").each(function(idx,obj){
			$(obj).prop("checked",false)
		});
		
		var wMsg = "";
		// 20230508 메일 정보 없는 사용자 경고창 추가

		if(dupStr != ""){
			dupStr = dupStr.substr(0, dupStr.length-2);
			wMsg = dupStr +orgDic["msg_OrgMap06"];//은(는) 이미 선택목록에 추가되어 있습니다.
			
			if(noEmStr != ""){
				noEmStr = noEmStr.substr(0, noEmStr.length-2);
				wMsg += "\n" +noEmStr + Common.getDic("msg_OrgMap07");//은(는) 메일 정보가 없습니다.
			}
			
			Common.Warning(wMsg); 
		}else if(noEmStr != ""){
			noEmStr = noEmStr.substr(0, noEmStr.length-2);
			Common.Warning(noEmStr + Common.getDic("msg_OrgMap07")); 
		}
		if(dataobj == ""){
			Common.Inform(orgDic["CPMail_mail_itemSel"]+"("+orgDic["CPMail_To"]+")");
		}
	}
	
	coviOrgObj.sendCc = function(){
		if($this.config.drawOpt.charAt(3)!="R")
			return;
		var dupStr=""; //중복된 데이터
		var newStr=""; //새로운 데이터
		var dataobj = "";
		var noEmStr = ""; //메일 정보 없는 대상
		
		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);
		$("#allchk_GroupMail").attr("checked", false);
		
		//타입구분
		var type = searchList;
			
		var diffStr = "orgSelectedList_";
		
		// 참조
		if(type != "groupMail"){
			if(!$("input:checkbox").is(":checked")){
				//$('tr[class*=selected]').find('input').prop("checked" , true);
			}
			$("div[id^=divSearchList_] input:checkbox, div[id=groupTreeDiv] input:checkbox").each(function() {
				if ($(this).is(":checked")) {
					var isOld = false;
					dataobj =  JSON.parse(this.value);
					dataobj.TYPE = "P_CC";
					dataobj.TARGET = "orgAutoConCC";
					var itemType = dataobj.itemType;
					if(dataobj.EM.length != 0){
						if(itemType == "user"){	//사용자
							var oldSelectList_people = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_people.length != 0) {
								for(var i=0; i<oldSelectList_people.length; i++){
			 						if(oldSelectList_people[i] == (diffStr + dataobj.EM)){
										dupStr += $(this)[0].name +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_CC",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else if(itemType =="group"){ //부서
							var oldSelectList_group = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_group.length != 0) {
								for(var i=0; i<oldSelectList_group.length; i++){
			 						if(oldSelectList_group[i] == (diffStr + dataobj.EM)){
										dupStr += dataobj.DN.split(";")[0] +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_CC",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else if(itemType =="GroupMail"){ // 그룹메일
							var oldSelectList_groupMail = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_groupMail.length != 0) {
								for(var i=0; i<oldSelectList_groupMail.length; i++){
			 						if(oldSelectList_groupMail[i] == (diffStr + dataobj.EM)){
										dupStr += dataobj.DN.split(";")[0] +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_CC",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else {	//주소록
							var oldSelectList_bizcard = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_bizcard.length != 0) {
								for(var i=0; i<oldSelectList_bizcard.length; i++){
									if(oldSelectList_bizcard[i] == (diffStr + dataobj.BizCardType + "-" + dataobj.ShareType + "-" + dataobj.ID)){
										dupStr += $(this)[0].name +", "
										isOld = true;
										break;
									}
								}
							}
							if(!isOld){
								addSelectedRow("P_CC",dataobj);
								newStr += dataobj.Name +", ";
							}
						}
					}else{
						noEmStr += $(this)[0].name +", "
					}

				}
			
			});		
		}else{	//연락처 그룹
			$("#orgSearchList").find($($("input:checkbox"))).prop("checked" , true);
			$("div[id^=divSearchList_] input:checkbox, div[id=groupTreeDiv] input:checkbox").each(function() {
				if ($(this).is(":checked")) {
					var isOld = false;
					dataobj =  JSON.parse(this.value);
					dataobj.TYPE = "P_CC";
					dataobj.TARGET = "orgAutoConCC";
					var oldSelectList_groupmail = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
					if (oldSelectList_groupmail.length != 0) {
						for(var i=0; i<oldSelectList_groupmail.length; i++){
							if(oldSelectList_groupmail[i] == (diffStr + dataobj.EMAIL)){
								dupStr += $(this)[0].name +", "
								isOld = true;
								break;
							}
						}
					}
					if(!isOld){
						addSelectedRow("P_CC",dataobj);
						newStr += dataobj.Name +", ";
					}
				}
			});
		}
		// 선택목록으로 이동후 체크박스 모두 해제
		$("#orgSearchList input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		$("#orgSearchList_BizCard_UR input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		$("#orgSearchList_BizCard_GR input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("#orgSearchList_BizCard_GroupMail input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("#groupMailSearchList input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("input:checkbox[id^=groupTree]").each(function(idx,obj){
			$(obj).prop("checked",false)
		});

		var wMsg = "";
		if(dupStr != ""){
			dupStr = dupStr.substr(0, dupStr.length-2);
			wMsg = dupStr +orgDic["msg_OrgMap06"];//은(는) 이미 선택목록에 추가되어 있습니다.
			
			if(noEmStr != ""){
				noEmStr = noEmStr.substr(0, noEmStr.length-2);
				wMsg += "\n" +noEmStr + Common.getDic("msg_OrgMap07");//은(는) 메일 정보가 없습니다.
			}
			
			Common.Warning(wMsg); 
		}else if(noEmStr != ""){
			noEmStr = noEmStr.substr(0, noEmStr.length-2);
			Common.Warning(noEmStr + Common.getDic("msg_OrgMap07")); 
		}
		if(dataobj == ""){
			Common.Inform(orgDic["CPMail_mail_itemSel"]+"("+orgDic["CPMail_mail_cc"]+")");
		}
	}
	
	coviOrgObj.sendBcc = function(){
		if($this.config.drawOpt.charAt(3)!="R")
			return;
		var dupStr=""; //중복된 데이터
		var newStr=""; //새로운 데이터
		var dataobj = "";
		var noEmStr = ""; //메일 정보 없는 대상
		
		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);
		$("#allchk_GroupMail").attr("checked", false);
		
		var	type = searchList;
	
		
		var diffStr = "orgSelectedList_";
		
		// 숨은참조
		if(type != "groupMail"){
			if(!$("input:checkbox").is(":checked")){
				//$('tr[class*=selected]').find('input').prop("checked" , true);
			}
			$("div[id^=divSearchList_] input:checkbox, div[id=groupTreeDiv] input:checkbox").each(function() {
				if ($(this).is(":checked")) {
					var isOld = false;
					dataobj =  JSON.parse(this.value);
					dataobj.TYPE = "P_BCC";
					dataobj.TARGET = "orgAutoConBCC";
					var itemType = dataobj.itemType;
					if(dataobj.EM.length != 0){
						if(itemType == "user"){	//유저
							var oldSelectList_people = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_people.length != 0) {
								for(var i=0; i<oldSelectList_people.length; i++){
			 						if(oldSelectList_people[i] == (diffStr + dataobj.EM)){
										dupStr += $(this)[0].name +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_BCC",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else if(itemType =="group"){ //부서
							var oldSelectList_group = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_group.length != 0) {
								for(var i=0; i<oldSelectList_group.length; i++){
			 						if(oldSelectList_group[i] == (diffStr + dataobj.EM)){
										dupStr += dataobj.DN.split(";")[0] +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_BCC",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else if(itemType =="GroupMail"){ // 그룹메일
							var oldSelectList_groupMail = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_groupMail.length != 0) {
								for(var i=0; i<oldSelectList_groupMail.length; i++){
			 						if(oldSelectList_groupMail[i] == (diffStr + dataobj.EM)){
										dupStr += dataobj.DN.split(";")[0] +", "
										isOld = true;
										break;
									}
								}
							}
						
							if (!isOld) {		// 이미 추가된 목록이 아닐 때만
								addSelectedRow("P_BCC",dataobj);
								newStr += dataobj.DN.split(";")[0]+", ";
							}
						}else {	//주소록
							var oldSelectList_bizcard = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
							if (oldSelectList_bizcard.length != 0) {
								for(var i=0; i<oldSelectList_bizcard.length; i++){
									if(oldSelectList_bizcard[i] == (diffStr + dataobj.BizCardType + "-" + dataobj.ShareType + "-" + dataobj.ID)){
										dupStr += $(this)[0].name +", "
										isOld = true;
										break;
									}
								}
							}
							if(!isOld){
								addSelectedRow("P_BCC",dataobj);
								newStr += dataobj.Name +", ";
							}
						}
					}else{
						noEmStr += $(this)[0].name +", "
					}

				}
			
			});		
		}else{	//연락처 그룹
			$("#orgSearchList").find($($("input:checkbox"))).prop("checked" , true);
			$("div[id^=divSearchList_] input:checkbox, div[id=groupTreeDiv] input:checkbox").each(function() {
				if ($(this).is(":checked")) {
					var isOld = false;
					dataobj =  JSON.parse(this.value);
					dataobj.TYPE = "P_BCC";
					dataobj.TARGET = "orgAutoConBCC";
					var oldSelectList_groupmail = getSelectedData(dataobj.TYPE);	// 선택한 데이터 가져옴
					if (oldSelectList_groupmail.length != 0) {
						for(var i=0; i<oldSelectList_groupmail.length; i++){
							if(oldSelectList_groupmail[i] == (diffStr + dataobj.EMAIL)){
							dupStr += $(this)[0].name +", "
							isOld = true;
							break;
							}
						}
					}
					if(!isOld){
						addSelectedRow("P_BCC",dataobj);
						newStr += dataobj.Name +", ";
					}
				}
			});
		}
		// 선택목록으로 이동후 체크박스 모두 해제
		$("#orgSearchList input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		$("#orgSearchList_BizCard_UR input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		$("#orgSearchList_BizCard_GR input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("#orgSearchList_BizCard_GroupMail input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("#groupMailSearchList input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$("input:checkbox[id^=groupTree]").each(function(idx,obj){
			$(obj).prop("checked",false)
		});
		
		if(dupStr != ""){
			dupStr = dupStr.substr(0, dupStr.length-2);
			wMsg = dupStr +orgDic["msg_OrgMap06"];//은(는) 이미 선택목록에 추가되어 있습니다.
			
			if(noEmStr != ""){
				noEmStr = noEmStr.substr(0, noEmStr.length-2);
				wMsg += "\n" +noEmStr + Common.getDic("msg_OrgMap07");//은(는) 메일 정보가 없습니다.
			}
			
			Common.Warning(wMsg); 
		}else if(noEmStr != ""){
			noEmStr = noEmStr.substr(0, noEmStr.length-2);
			Common.Warning(noEmStr + Common.getDic("msg_OrgMap07")); 
		}
		if(dataobj == ""){
			Common.Inform(orgDic["CPMail_mail_itemSel"]+"("+orgDic["CPMail_mail_bcc"]+")");
		}
		
	}
	
	//삭제
	coviOrgObj.sendLeft = function(type){
		if($this.config.drawOpt.charAt(3)!="R")
			return;
		
		var newStr = "";
		
		if(type == "TO"){
			$("#orgSelectedList_P_TO input:checkbox").each(function(){
				if($(this).is(":checked")){
					newStr += orgDic["CPMail_To"]+" : "  +$(this)[0].name+"//";
					$(this).parent().parent().remove();
				}
			});
		}else if(type == "CC"){
			$("#orgSelectedList_P_CC input:checkbox").each(function(){
				if($(this).is(":checked")){
					newStr += orgDic["CPMail_mail_cc"]+" : " + $(this)[0].name+"//";
					$(this).parent().parent().remove();
				}
			});
		}else if(type == "BCC"){
			$("#orgSelectedList_P_BCC input:checkbox").each(function(){
				if($(this).is(":checked")){
					newStr += orgDic["CPMail_mail_bcc"]+" : " + $(this)[0].name +"//";
					$(this).parent().parent().remove();
				}
			});
		}
		
		if(newStr == ""){
			Common.Inform(orgDic["CPMail_mail_itemSel"]+"("+orgDic["CPMail_Delete"]+")");
		}
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
	
	coviOrgObj.contentDoubleClick = function(){
		coviOrgObj.sendTo();
	}
	
	coviOrgObj.pContentDoubleClick = function(obj){
		$(obj).find("input[type='checkbox']").prop("checked", "checked");
		
		coviOrgObj.sendTo();
	}
	
	coviOrgObj.goUserInfoPopup = function(userID){
		parent.Common.open("","MyInfo",orgDic["lbl_UserProfile"],"/covicore/control/callMyInfo.do?userID="+userID,"810px","500px","iframe",true,null,null,true); //사용자 프로필
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
	
	//주소록 정보보기
	coviOrgObj.viewBizCardPop = function(bizCardID){
		Common.open("", "ViewBizCardPerson", orgDic["lbl_Mail_CardView"], "/groupware/bizcard/ViewBizCardPerson.do?BizCardID=" + encodeURIComponent(bizCardID) + "&ShareType=" + "A", "500px", "530px", "iframe", true, null, null, true);
	}
	
	//그룹메일 그룹 정보
	coviOrgObj.groupInfo = function(groupID, groupName){
		$.ajax({
			type:"POST",
			url:"/mail/groupMail/selectGroupMailUserList.do",
			data:{
				"groupMailGroupId" : groupID
			},
			success:function (data){
				setMemberList(data);
			}
		})
		$("#selDeptTxt").text(groupName);
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
		}
		/*if(!isEmpty(orgOpt.treeKind)){
			$this.config.treeKind = orgOpt.treeKind;	
		}*/
		
		$this.config.treeKind = isEmptyDefault(orgOpt.treeKind , $this.config.treeKind );
		$this.config.drawOpt = isEmptyDefault(orgOpt.drawOpt , $this.config.drawOpt );
		$this.config.callbackFunc = isEmptyDefault(orgOpt.callbackFunc , $this.config.callbackFunc);
		$this.config.openerID = isEmptyDefault(orgOpt.openerID , $this.config.openerID);
		$this.config.allCompany = isEmptyDefault(orgOpt.allCompany , $this.config.allCompany);
		$this.config.groupDivision = isEmptyDefault(orgOpt.groupDivision , $this.config.groupDivision);
		$this.config.communityId = isEmptyDefault(orgOpt.communityId , $this.config.communityId);
		$this.config.bizcardKind = isEmptyDefault(orgOpt.bizcardKind , $this.config.bizcardKind);
		if($this.config.bizcardKind != undefined && $this.config.bizcardKind != null){
			$this.config.bizcardKind = $this.config.bizcardKind.toUpperCase();
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
				html += '					<li '+((CFN_GetQueryString("priority") == "bizcard")?'':'class = "active"')+'><a id = "changeGroupTree">'+orgDic["CPMail_Dept"]+'</a></li>';
				html += '					<li '+((CFN_GetQueryString("priority") == "bizcard")?'class = "active"':'')+'><a id = "changeBizCard">'+orgDic["CPMail_Contact"]+'</a></li>';
				html += '					<li><a id = "changeGroupMail">'+orgDic["lbl_Mail_AddressType_G"]+'</a></li>';
				html += ' 				</ul>';
				html += '			</div>';
				html += '		</div>';
			}
			html += '			<div class="appTree" id="BizCardDiv" '+((CFN_GetQueryString("priority") == "bizcard")?'':'style = "display:none"')+'>';
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
			html += '			<div class="appTree" id="groupTreeDiv" '+((CFN_GetQueryString("priority") == "bizcard")?'style = "display:none"':'')+' >';
			html += '				<div class="appTreeTop">';
			html += '					<select id="companySelect" class="treeSelect"></select>';
			if($this.config.treeKind.toUpperCase() == "GROUP"){
				html += '				<div class="org_tree_top_radio_wrap">';
				html += '					<input id="deptRadio" type="radio" class="org_tree_top_radio" value="dept"  name="groupTypeRadio"  checked><label for="deptRadio">' + orgDic["lbl_DeptOrgMap"]+ '</label>'; //조직도
				html += '					<input id="groupRadio" type="radio" class="org_tree_top_radio" value="group"  name="groupTypeRadio"><label for="groupRadio">' + orgDic["lbl_group"]+ '</label>'; // 그룹
				html += '				</div>';
				//html += '		 			<div style="height:3px; width:100%;"></div>'
				//html += '		 			<select id="groupTypeSelect" class="treeSelect"></select>';
			}
			html += '				</div>';
			html += '				<div class="appTreeBot">';
			html += '					<div id="groupTree" class = "treeList radio radioType02 org tree mailTree"></div>';
			html += '				</div>';
			html += '			</div>';
			html += '			<div class="appTree" id="GroupMailDiv" style="display : none">';
			html += '				<div class="appTreeTop">';
			html += '					<select id="companySelectForGroup" class="treeSelect"></select>';
			html += '				</div>';
			html += '				<div class="appTreeBot">';
			html += '					<div id="groupTree" class = "treeList radio radioType02 org tree mailTree"></div>';
			html += '				</div>';
			html += '			</div>';
		}
		
		
		if($this.config.drawOpt.charAt(1) === 'M'){
			html += '			<div class="appList_top_b searchBox02">'
			/*html += '					<select id="searchType" class="j_appSelect">';
			html += '						<option value="person">'+orgDic["lbl_apv_person"]+'</option>';
			html += '						<option value="dept">'+orgDic["lbl_dept"]+'</option>';
			html += '					</select>';*/
			html += ' 				<div id="searchdiv" '+((CFN_GetQueryString("priority") == "bizcard")?'style="display:none"':'')+'">';
			html += '					<input style="width: 274px;" type="text" autocomplete="off" placeholder="'+orgDic["msg_EnterSearchword"]+'" id="searchWord" name="inputSelector_onsearch"  data-axbind="selector"  ><a class="btnSearchType01" >'+orgDic["btn_apv_search"]+'</a>';
			html += ' 				</div>'
			html += ' 				<div id="searchdiv_BizCard" '+((CFN_GetQueryString("priority") == "bizcard")?'':'style="display:none;"')+'>';	
			html += '					<input style="width: 274px;" type="text" autocomplete="off" placeholder="'+orgDic["msg_EnterSearchword"]+'" id="searchWord_BizCard" name="inputSelector_onsearch_BizCard"  data-axbind="selector"  ><a class="btnSearchType01" >'+orgDic["btn_apv_search"]+'</a>';
			html += ' 				</div>'
			html += ' 				<div id="searchdiv_GroupMail" style="display:none;">';	
			html += '					<input style="width: 274px;" type="text" autocomplete="off" placeholder="'+orgDic["msg_EnterSearchword"]+'" id="searchWord_GroupMail" name="inputSelector_onsearch_GoupMail"  data-axbind="selector"  ><a class="btnSearchType01" >'+orgDic["btn_apv_search"]+'</a>';
			html += ' 				</div>'
			html += '			</div>';
			html += '			<div id="divSearchList_Main" class="appList" style="overflow:hidden;'+((CFN_GetQueryString("priority") == "bizcard")?' display:none;':'')+'">';
			html += '					<table class="tableStyle t_center hover appListTop" style="width:276px;">';
			html += '						<thead id="infoList">';
			html += '							<tr>';
			html += '								<th>';
			if($this.config.type != "C1" &&  $this.config.type != "C9"  && $this.config.type != "A0"){
				html += '							<div id="allchkdiv">';
				html += '								<input type="checkbox" id="allchk" name="allchk" onchange="coviOrgMail.allCheck(this)" style="  float: left;    margin: 8px;    height: 14px;	">';
				html += '							</div>';
				html += '								<label for="allchk"><span id="selDeptTxt" style=" float: left;    font-weight: normal;    margin-top: 8px;   margin-right: 20px;"></span><span id="selGroupTxt" style=" float: left;    font-weight: normal; "></span></label>';
			}
			html += '								</th>';
			html += '							</tr>';            
			html += '						</thead>';	
			html += '					</table>';
			html += '				<div class="appListBot" style="height: 393px;	">';
			html += '					<table class="tableStyle t_center hover">';
			html += '						<colgroup>';
			if($this.config.type != "A0"){
				html += '							<col style="width:30px">';
				html += '							<col style="width:80px">';
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
			
			html += '			<div id="divSearchList_BizCard" class="appList" style="overflow:hidden;'+((CFN_GetQueryString("priority") == "bizcard")?'':' display:none;')+'">';
			html += '				<table class="tableStyle t_center hover appListTop" style="width:276px;">';
			html += '					<thead>';
			html += '						<tr>';
			html += '							<th>';
			html += '								<div>';
			html += '									<input type="checkbox" id="allchk_BizCard_UR" name="allchk_BizCard_UR" onchange="coviOrgMail.allCheck_BizCard(this, \'UR\')" style="  float: left;    margin: 8px;    height: 14px;	">';
			html += '								</div>';
			html += '								<label for="allchk_BizCard_UR"><span style="font-weight: normal; margin-top: 8px; margin-right: 20px; float: left;">'+orgDic["lbl_Mail_Contact"]+'</span></label>';
			html += '								<div id="divBizCardPaging_UR" class="org_paging" style="display:none;">';
			html += '									<table cellspacing="0" cellpadding="0">';
			html += '										<tbody>';
			html += '											<tr>';
			html += '												<td width="25" align="left" valign="middle">';
			html += '													<a style="cursor: pointer;" onclick="coviOrgMail.BizCardPageMove_onclick(\'PREV\', \'UR\');">&lt;</a>';
			html += '												</td>';
			html += '												<td align="left" valign="middle">';
			html += '													<input id="hidBizCardCurPage_UR" type="hidden" value="1">';
			html += '													<span class="gray"><span id="spanBizCardCurPage_UR">1</span>&nbsp;/&nbsp;<span id="spanBizCardTotalPage_UR">1</span></span>';
			html += '												</td>';
			html += '												<td align="right" valign="middle" style="padding-left: 10px;">';
			html += '													<a style="cursor: pointer;" onclick="coviOrgMail.BizCardPageMove_onclick(\'NEXT\', \'UR\');">&gt;</a>';
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
				html += '									<input type="checkbox" id="allchk_BizCard_GR" name="allchk_BizCard_GR" onchange="coviOrgMail.allCheck_BizCard(this, \'GR\')" style="  float: left;    margin: 8px;    height: 14px;	">';
				html += '								</div>';
				html += '								<label for="allchk_BizCard_GR"><span style="font-weight: normal; margin-top: 8px; margin-right: 20px; float: left;">'+orgDic["lbl_group"]+'</span></label>';
				html += '								<div id="divBizCardPaging_GR" class="org_paging" style="display:none;">';
				html += '									<table cellspacing="0" cellpadding="0">';
				html += '										<tbody>';
				html += '											<tr>';
				html += '												<td width="25" align="left" valign="middle">';
				html += '													<a style="cursor: pointer;" onclick="coviOrgMail.BizCardPageMove_onclick(\'PREV\', \'GR\');">&lt;</a>';
				html += '												</td>';
				html += '												<td align="left" valign="middle">';
				html += '													<input id="hidBizCardCurPage_GR" type="hidden" value="1">';
				html += '													<span class="gray"><span id="spanBizCardCurPage_GR">1</span>&nbsp;/&nbsp;<span id="spanBizCardTotalPage_GR">1</span></span>';
				html += '												</td>';
				html += '												<td align="right" valign="middle" style="padding-left: 10px;">';
				html += '													<a style="cursor: pointer;" onclick="coviOrgMail.BizCardPageMove_onclick(\'NEXT\', \'GR\');">&gt;</a>';
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
				html += '							<col style="width:20px">';
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
		
			html += '			<div id="divSearchList_GroupMail" class="appList" style="overflow:hidden; display:none;">';
			html += '				<table class="tableStyle t_center hover appListTop" style="width:276px;">';
			html += '					<thead>';
			html += '						<tr>';
			html += '							<th>';
			html += '								<div>';
			html += '									<input type="checkbox" id="allchk_GroupMail" name="allchk_GroupMail" onchange="coviOrgMail.allCheck_BizCard(this, \'GroupMail\')" style="  float: left;    margin: 8px;    height: 14px;	">';
			html += '								</div>';
			html += '								<label for="allchk_GroupMail"><span style="font-weight: normal; margin-top: 8px; margin-right: 20px; float: left;">'+orgDic["lbl_Mail_AddressType_G"]+'</span></label>';
			html += '							</th>';
			html += '						</tr>';            
			html += '					</thead>';	
			html += '				</table>';			
			html += '				<div class="appListBot">';
			html += '					<table class="tableStyle t_center hover">';
			html += '						<colgroup>';
			html += '							<col style="width:30px">';
			html += '							<col style="width:*">';
			html += '						</colgroup>';
			html += '						<tbody id="orgSearchList_BizCard_GroupMail">';
			html += '						</tbody>';		
			html += '					</table>';
			html += '					<div id="orgSearchListMessage_BizCard_GroupMail" style="position: absolute; top: 210px; left: 295px;"></div>';
			html += '				</div>';
			html += '			</div>';
		
		if($this.config.drawOpt.charAt(2) === 'A'){
			html += ' 			<div class="arrowBtn mail">';
			html += ' 				<div class="arrowBtn01">';
			html += '					<input class="btnRight" onclick="coviOrgMail.sendTo()" type="button" value="&gt;">';
			html += '					<input class="btnLeft" onclick="coviOrgMail.sendLeft('+"'TO'"+')" type="button" value="&lt;">';
			html += '				</div>';
			html += ' 				<div class="arrowBtn02">';
			html += '					<input class="btnRight" onclick="coviOrgMail.sendCc()" type="button" value="&gt;">';
			html += '					<input class="btnLeft" onclick="coviOrgMail.sendLeft('+"'CC'"+')" type="button" value="&lt;">';
			html += '				</div>';
			html += ' 				<div class="arrowBtn03">';
			html += '					<input class="btnRight" onclick="coviOrgMail.sendBcc()" type="button" value="&gt;">';
			html += '					<input class="btnLeft" onclick="coviOrgMail.sendLeft('+"'BCC'"+')" type="button" value="&lt;">';
			html += '				</div>';
			html += '			</div>';
		}
		
		if($this.config.drawOpt.charAt(3) === 'R'){
			html += ' 			<div class="appSel" style="margin-top:-40px">';
			html += '  				 <div class="selTop mail">';
			html += '    				<table class="tableStyle t_center hover infoTableBot">';
			html += '      					<colgroup>';
			html += '     						<col style="width:50px">';
			html += '      						<col style="width:*">';
			html += '						</colgroup>';
			html += '						<thead>';
			html += '							<tr>';
			html += '								<td colspan="2"><h3 class="titIcn">'+orgDic["lbl_Mail_To"]+'</h3></td>'; //받는사람
			html += '							</tr>';
			html += '						</thead>';
			html += '						<tbody id="orgSelectedList_P_TO">';
			html += '						</tbody>';
			html += ' 					</table>';
			html += '				</div>';
			html += '				<div class="selBot mail">';
			html += '					<table class="tableStyle t_center hover infoTableBot">';
			html += '						<colgroup>';
			html += '							<col style="width:50px">';
			html += '							<col style="width:*">';
			html += '						</colgroup>';
			html += '						<thead>';
			html += '							<tr>';
			html += '								<td colspan="2"><h3 class="titIcn">'+orgDic["lbl_Mail_Cc"]+'</h3></td>'; //참조
			html += '							</tr>';
			html += '						</thead>';
			html += '						<tbody id="orgSelectedList_P_CC">';
			html += '						</tbody>';
			html += '     				</table>';
			html += '				</div>';
			html += '				<div class="selBot mail">';
			html += '					<table class="tableStyle t_center hover infoTableBot">';
			html += '						<colgroup>';
			html += '							<col style="width:50px">';
			html += '							<col style="width:*">';
			html += '						</colgroup>';
			html += '						<thead>';
			html += '							<tr>';
			html += '								<td colspan="2"><h3 class="titIcn">'+orgDic["lbl_Mail_Bcc"]+'</h3></td>'; //숨은참조
			html += '							</tr>';
			html += '						</thead>';
			html += '						<tbody id="orgSelectedList_P_BCC">';
			html += '						</tbody>';
			html += '     				</table>';
			html += '				</div>';
			html += ' 			</div>';
		}
		
		if($this.config.drawOpt.charAt(4) === 'B'){
			btnHtml += '<div class="popBtn">';
			if($this.config.type != "A0"){
				btnHtml += '	<input type="button" class="ooBtn ooBtnChk" onclick="coviOrgMail.returnData();" value="'+orgDic["btn_Confirm"]+'"/>'; /*확인*/ 
			}
			btnHtml += ' 	<input type="button" class="owBtn mr30" onclick="coviOrgMail.closeLayer();" value="'+orgDic["btn_Close"]+'"/>'; /*닫기*/ 
			btnHtml += '</div>';
		}
		
		if($this.config.targetID != ''){
			$("#"+$this.config.targetID).addClass("appBox");
			$("#"+$this.config.targetID).prepend(html);
			$("#"+$this.config.targetID).after(btnHtml);
		}
		
		// TODO 디자인상 하드 코딩 향후 퍼블리싱 받은 후 지울것.
		if($this.config.treeKind.toUpperCase() == "GROUP"){
			$("#groupTree").css("height","380px");
			$(".appTreeBot").css("height","390px");
			$(".appTreeBot").css("margin-top","65px");
		}		
	}
	
	//Select 박스 바인딩 (회사 목록 및 검색 조건)
	function setSelect(){
		if($this.config.drawOpt.charAt(0) === "L"){
			
			$.ajax({
				type:"POST",
				url : "/covicore/control/getCompanyList.do",
				data:{
					allCompany: $this.config.allCompany
				},
				async: false, 
				success : function(data){
					var arrCom = new Array();
					
					$.each(data.list,function(idx, obj){
						arrCom.push({optionValue: obj.GroupCode, optionText: obj.DisplayName});
					});
					
					$("#companySelect").bindSelect({
						options: arrCom,
						setValue:sessionObj["DN_Code"],
						onchange:function () {
							setInitGroupTreeData("N"); //loadMyDept = "N"
						}
					});
					
					$("#companySelectForGroup").bindSelect({
						options: arrCom,
						setValue:sessionObj["DN_Code"],
						onchange:function () {
							var companyCode = $("#companySelectForGroup").val();
							var searchWord = $("#searchWord_GroupMail").val()
							orgGroupMailData(companyCode, searchWord);
						}
					});					
				}
			});
			
			if($this.config.treeKind.toUpperCase() == "GROUP"){
				var arrOptions = [];
				arrOptions.push({"optionValue":"dept","optionText":orgDic["OrgTreeKind_Dept"]});
				arrOptions.push({"optionValue":"group","optionText":orgDic["OrgTreeKind_Group"]});				
				
				$("#groupTypeSelect").bindSelect({
					//reserveKeys: {optionValue: "optionValue",optionText: "optionText"},
					options: arrOptions, //▣ 조직도, ▣ 그룹
					onchange:function () {
						setInitGroupTreeData("N"); //loadMyDept = "N"
						
						$(".appList_top_b").show();
						$(".appList").css("height", "435px");
						$(".appListBot").css("height", "393px");
						$(".appSel").css("margin-top", "-40px");
					}
				});
				
				$(":input:radio[name=groupTypeRadio]").click(function (){
					allGroupBind = "N";
					setInitGroupTreeData("N"); //loadMyDept = "N"
					$("#groupPathList").empty();
				});
				
			}
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
				onsearch     : function(objID, objVal, callBack) {                            // {Function} - 값 변경 이벤트 콜백함수 (optional)
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
					search(this.selectedOption);
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
			
			$('#searchWord_GroupMail').keydown(function(e) {
			    if (e.keyCode == 13) {
					var companyCode = $("#companySelectForGroup").val();
					var searchWord = $("#searchWord_GroupMail").val()
		    		orgGroupMailData(companyCode, searchWord);
			    }
			});
		}
	}
	
	//추가
	function addSelectedRow(type,dataObj){
		var html = '';
			if(searchList == "groupTree"){
				html += '<tr>';
				html += "	<td><input type='checkbox' id='orgSelectedList_" + CFN_GetDicInfo(dataObj.EM,lang) + "' name='" + CFN_GetDicInfo(dataObj.DN,lang) + "' value='" + jsonToString(dataObj) + "'></td>";
				html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.DN,lang) + ' ' + CFN_GetDicInfo(dataObj.EM,lang) + '</td>';
				html += '</tr>';
			}else if(searchList == "bizCard"){
				if(dataObj.itemType == "user" || dataObj.itemType =="group"){
					html += '<tr>';
					html += "	<td><input type='checkbox' id='orgSelectedList_" + CFN_GetDicInfo(dataObj.EM,lang) + "' name='" + CFN_GetDicInfo(dataObj.DN,lang) + "' value='" + jsonToString(dataObj) + "'></td>";
					html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.DN,lang) + ' ' + CFN_GetDicInfo(dataObj.EM,lang) + '</td>';
					html += '</tr>';
				} else {
					html += "<tr>";
					html += "	<td><input type='checkbox' id='orgSelectedList_"+ dataObj.BizCardType + "-" + dataObj.ShareType + "-" + dataObj.ID +"' name='"+CFN_GetDicInfo(dataObj.Name,lang)+"' value='"+ jsonToString(dataObj) +"'/></td>";
					
					if(dataObj.BizCardType == "GR") {
						html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.Name,lang) + '</td>';
					} else {
						html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.Name,lang) + ' ' + CFN_GetDicInfo(dataObj.EM,lang) + '</td>';
					}
					
					html += "</tr>";
				}
			}else if(searchList == "groupMail"){
				html += "<tr>";
				html += "	<td><input type='checkbox' id='orgSelectedList_"+CFN_GetDicInfo(dataObj.EMAIL,lang) +"' name='"+CFN_GetDicInfo(dataObj.Name,lang)+"' value='"+ jsonToString(dataObj) +"'/></td>";
				html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.Name,lang) + ' ' + CFN_GetDicInfo(dataObj.JobTitle,lang) + '</td>';
				html += "</tr>";
			}else if(searchList == "autoCompleteGroupMail"){
				html += "<tr>";
				html += "	<td><input type='checkbox' id='orgSelectedList_"+CFN_GetDicInfo(dataObj.Email,lang) +"' name='"+CFN_GetDicInfo(dataObj.Name,lang)+"' value='"+ jsonToString(dataObj) +"'/></td>";
				html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.Name,lang) + ' ' + CFN_GetDicInfo(dataObj.Email,lang) + '</td>';
				html += "</tr>";
			}
	  if( html != '' && (type == "P_TO" || type=="P_CC" || type=="P_BCC") ){
	  	$("#orgSelectedList_"+type).append(html); //type: people or dept
	  }
	}
	

	
	function setGroupTreeConfig(){
		var pid = "groupTree"; //treeTargetID
		var IsCheck = true;
		var IsRadio = false;
		
		var func = { 		// 내부에서 필요한 함수 정의
				covi_setCheckBox : function(item){		// checkbox button
					if(item.IsMail == "Y"){
						return "<input type='checkbox' id='"+pid+"_treeCheckbox_"+item.no+"' name='treeCheckbox_"+item.no+"' value='"+jsonToString(item)+"' />";
					}else if(item.IsMail == "N"){
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
			//height:"auto", // auto에서 부서 클릭시 스크로 이동됨. 
			height:"380px",
			width:"auto",
			//checkboxRelationFixed : false,
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
				width: "*",
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
					if(IsCheck){
						str = func.covi_setCheckBox(this.item) + str;
					}
					if(IsRadio){
						str = func.covi_setRadio(this.item) + str;
					}
					
					return str;
				}
			}],						// tree 헤드 정의 값
			body:bodyConfig									// 이벤트 콜벡함수 정의 값
		});
		
	}
	
	//전체 트리 바인딩
	function setAllGroupTreeData(){
		var domain = $("#companySelect").val();
		var groupType = $(":input:radio[name=groupTypeRadio]:checked").val();	//var groupType = "Dept";

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
				allGroupBind = "Y";
				$this.groupTree.setList(data.list);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getDeptList.do", response, status, error);
			}
		});
		
		$this.groupTree.displayIcon(false); //Icon에 checkbox 가려지는 현상 제거
	}
	
	//초기 그룹 트리 바인딩
	function setInitGroupTreeData(isloadMyDept){
		var domain = $("#companySelect").val();
		var groupType = $(":input:radio[name=groupTypeRadio]:checked").val();	//var groupType = "Dept";
		
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
				"mailYn" : "Y"	// 메일에서 권한, 커뮤니티 제외여부
			},
			async:false,
			success:function (data) {
				$this.groupTree.setList( data.list );
				if(isloadMyDept == "Y"){
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
	}
	
	//하위 항목 조회
	function getChildrenData(idx, item){
		var domain = $("#companySelect").val();
		var groupType = $(":input:radio[name=groupTypeRadio]:checked").val();	//var groupType = "Dept";
		
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
				var checkid = "";
				$("div[id^=divSearchList_] input:checkbox, div[id=groupTreeDiv] input:checkbox").each(function() {
					if ($(this).is(":checked")) checkid = checkid + this.id + ",";
				});
				checkid = checkid.slice(0,-1);
				
				$this.groupTree.appendTree(idx, item, data.list);
				
				var checkidArr = checkid.split(",");
				for(var i=0; i<=checkidArr.length; i++)
					$("#"+checkidArr[i]).prop("checked" , true);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getChildrenData.do", response, status, error);
			},
		});
	}
	
	//그룹 트리 바인딩
	/*function setGroupTreeData(){
		var domain = $("#companySelect").val();
		var groupType = $("#groupTypeSelect").val();
		var bodyConfig; 
		if(groupType=="group"){
			bodyConfig = {
					onclick:function(idx, item){
						if(item.GroupType.toUpperCase() != "COMPANY"){
							$this.getUserOfGroupList(item.GroupCode);
						}
					}
			};
		}else{
			bodyConfig = {
					onclick:function(idx, item){
						$this.getUserOfGroupList(item.GroupCode);
					}
			};
		}
		
		$.ajax({
			url:"/covicore/control/getDeptList.do",
			type:"POST",
			data:{
				"companyCode" : domain,
				"groupType" : groupType,
				"treeKind":$this.config.treeKind
			},
			async:false,
			success:function (data) {
				var List = data.list;
				if($this.config.type=="B1"||$this.config.type=="B9" || $this.config.type=="A0"){
					$this.groupTree.setTreeList("groupTree", List, "nodeName", "170", "left", false, false, bodyConfig);
				}else{
					$this.groupTree.setTreeList("groupTree", List, "nodeName", "170", "left", true, false, bodyConfig);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getDeptList.do", response, status, error);
			}
		});

		$this.groupTree.displayIcon(false); //Icon에 checkbox 가려지는 현상 제거
	}*/
	
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

		tmpSearchWord = searchText;
		
		var url;
		var params = new Object();
		
		params.searchText = searchText;
		
		$("#allchk").attr("checked", false);
		$("#allchk_BizCard_UR").attr("checked", false);
		$("#allchk_BizCard_GR").attr("checked", false);
		$("#allchk_GroupMail").attr("checked", false);
		
		/*if (searchType == "deptName") {
			url = "/covicore/control/getDeptList.do";
			params.companyCode = $("#companySelect").val();
			params.groupType = 'dept' //부서 검색 (고정값)
		} else */if(searchList == "groupTree"){
			url = "/covicore/control/getUserList.do";
			params.companyCode = $("#companySelect").val();
			params.searchType = searchType;
			params.groupType =  "Dept";
			params.isMailChk =  "Y";
		} else if(searchList == "bizCard"){
			url = "/groupware/bizcard/getBizCardSearchList.do"
			params.companyCode = $("CompanySelect").val();
			params.searchType = searchType;
			params.groupType = "Dept";
		}
		
		$.ajax({
			url: url,
			type:"post",
			data: params,
			success:function (data) {/*
				if (searchType == "deptName") {
					setMemberList(data,"schDept");
				} else {*/
					setMemberList(data,"search");
			//	}
				
				$("#selDeptTxt").text("");			// 조회된 후 선택부서TEXT 초기화
				$("#searchWord").val('');
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
		$("#allchk_GroupMail").attr("checked", false);

		$("#spanBizCardCurPage_UR").text("1");
		$("#hidBizCardCurPage_UR").val("1");
		
		$.ajax({
			type:"POST",
			data:{
				pageNo : "1",
				pageSize : "100",
				itemType: "UR",
				publicUserCode : Common.getSession().UR_Code,
				searchText: tmpSearchWord,
				shareType : BizCardShareType,
				hasEmail : "Y"
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
					publicUserCode : Common.getSession().UR_Code,
					searchText: tmpSearchWord,
					shareType : BizCardShareType,
					hasEmail : "Y"
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
		var gmData = ""; //그룹메일
		var strData = "";
		var strMsg;
		if(data.list == null || data.list.length == 0 || data.list.length == null)
			strMsg = orgDic["msg_NoDataList"] //조회할 목록이 없습니다.
		else{
			strMsg = "";
		if(searchList == "bizCard"){
			$(data.list).each(function(){
				this.DN = this.Name;
				this.EM = this.EMAIL;
				strData += "<tr type='bizcard' ondblclick='coviOrgMail.contentDoubleClick(this)'>";
				strData += "<td style='height:20px !important;'><input type='checkbox' id='orgSearchList_bizcard"+this.BizCardID +"' name='"+CFN_GetDicInfo(this.Name,lang)+"' value='"+ jsonToString(this) +"'/></td>";
				strData += "<td style='height:20px !important;' class='subject'>"+CFN_GetDicInfo(this.Name,lang)+' '+CFN_GetDicInfo(this.JobTitle,lang)+"</td>";
				strData += "</tr>";
			});
		}else if (searchList == "groupTree"){
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
					strData += "<tr type='dept' ondblclick='coviOrgMail.contentDoubleClick(this)'>";
					if($this.config.type=="A0"){
						strData += "";
					}else if ($this.config.type == "B1" || $this.config.type == "B9") {
						strData += "<td></td>";
					} else {
						strData += "<td><input type='checkbox' id='orgSearchList_dept"+this.GroupID +"' name='"+CFN_GetDicInfo(this.DN,lang) +"' value='"+ jsonToString(this) +"'/></td>";
					}
					
					strData += "<td colspan=\"2\" class='subject'><dl class='listBotTit'><dt>"+CFN_GetDicInfo(this.DN,lang) + " (" + CFN_GetDicInfo(this.ETNM,lang) + ") </dt><dd class='lGry'>"+this.GroupFullPath +"</dd></dl></td>";
					
					if($this.config.type=="A0"){
						strData += "<td></td>";
						strData += "<td></td>";
					}
					strData += "</tr>";
				} else { //pMode == 'search' or 'undefined'
					strData += "<tr type='people' ondblclick='coviOrgMail.pContentDoubleClick(this)'>";
                    //strData += "<tr type='people'>";
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
						strData += "<td><a href='#none' class='cirPro'><img src='"+ coviCmn.loadImage(this.PhotoPath) +"' alt='' onerror='coviOrg.imgError(this);'></a></td>";												
						strData += "<td class='subject'><dl class='listBotTit'><dt onclick='coviOrgMail.goUserInfoPopup(\""+this.AN +"\")'>"+CFN_GetDicInfo(this.DN,lang)+ (sMultiRepJobType == "" ? "" : " (" + sMultiRepJobType + ")") + "</dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+" (" +CFN_GetDicInfo(this.ETNM,lang) + ")" +"</dd></dl></td>";
						strData += "<td class='subject'><dl class='listBotTit'><dt class='lGry'>"+ orgDic["lbl_MobilePhone"] +": "+isEmptyDefault(this.MT,'') +"</dt><dd class='lGry'>"+ orgDic["lbl_CompanyNumber"] +": "+isEmptyDefault(this.OT,'')+"</dd></dl></td>" //핸드폰, 회사번호
						strData += "<td class='subject'><dl class='listBotTit'><dt class='lGry'>"+ orgDic["lbl_apv_appMail"] +": "+isEmptyDefault(this.EM,'') +"</dt><dd class='lGry'>"+ orgDic["lbl_Role"] +": "+CFN_GetDicInfo(isEmptyDefault(this.ChargeBusiness,''), lang)+"</dd></dl></td>" //메일, 담당업무
						
					}else{
						strData += "<td><input type='checkbox' id='orgSearchList_people"+this.UserID +"' name='"+CFN_GetDicInfo(this.DN,lang)+"' value='"+ jsonToString(this) +"'/></td>";
						strData += "<td><a href='#none' class='cirPro'><img src='"+ coviCmn.loadImage(this.PhotoPath) +"' alt='' onerror='coviOrg.imgError(this);'></a></td>";
					    strData += "<td class='subject'><dl class='listBotTit'><dt onclick='coviOrgMail.goUserInfoPopup(\""+this.AN +"\")'>"+CFN_GetDicInfo(this.DN,lang)+ (sMultiRepJobType == "" ? "" : " (" + sMultiRepJobType + ")") + "</dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+" (" +CFN_GetDicInfo(this.ETNM,lang) + ")" +"</dd></dl></td>";	
					}
					strData += "</tr>";
				}
			});
		}else if(searchList == "groupMail"){
			if($('#groupMailSearchList').text().trim() == ""){
				$(data.list).each(function(){
					this.DN = this.Name;
					this.EM = this.EMAIL;
					strData += "<tr type='groupmail'>";
					strData += "<td><div width=0 height=0 style='visibility:hidden'><input type='checkbox' id='orgSearchList_groupMail"+this.BizCardID +"' name='"+CFN_GetDicInfo(this.Name,lang)+"' value='"+ jsonToString(this) +"'/></div></td>";
					strData += "<td><a href='#none' class='cirPro'><img src='"+this.ImagePath+"' alt='' onerror='coviCmn.imgError(this, true);'></a></td>";
					strData += "<td class='subject' colspan='2'><dl class='listBotTit'>"+CFN_GetDicInfo(this.Name,lang)+' '+CFN_GetDicInfo(this.JobTitle,lang)+"<dd class='lGry'>"+CFN_GetDicInfo(this.EMAIL,lang)+"</dd></dl></td>";
					strData += "</tr>";
				});
			}else{
				$(data.list).each(function(){
					this.DN = this.Name;
					this.EM = this.EMAIL;
					strData += "<tr>";
					strData += "<td colspan='2'><dl class='listBotTit'>"+CFN_GetDicInfo(this.UserName,lang)+' '+CFN_GetDicInfo(this.JobTitle,lang)+"</dl></td>"
					strData += "<td class='subject' colspan='2'><dl class='lGry'>"+CFN_GetDicInfo(this.UserMailAddress,lang)+"</dl></td>";
					strData += "</tr>";
				});
			}
		}
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
					
					strData += "<tr type='bizcard' ondblclick='coviOrgMail.contentDoubleClick(this);'>";
					strData += "<td style='height:20px !important;'>";
					strData += "<a href='#' id='orgSearchList_bizcard_anchor_" + pType + "_" + oElm.ID + "' onclick='coviOrgMail.displayGroupMember(this);'";
					strData += " style='display: inline-block; background: url(/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_arrow_02.png) no-repeat center; width: 25px; height: 21px; padding: 0px !important; font-size: 13px; margin-left: -3px;'></a>";
					strData += "</td>";
					strData += "<td style='height:20px !important;'><input type='checkbox' id='orgSearchList_bizcard_" + pType + "_" + oElm.ID +"' name='"+ oElm.Name.replace(/'/g, "＇") +"' value='"+ jsonToString(oElm).replace(/'/g, "＇") +"'/></td>";
					strData += "<td style='height:20px !important;' class='subject'>" + $("<div />").text(oElm.Name).html() + "</td>";
					strData += "</tr>";
					
					$(oListMember).each(function(idx) {
						this.DN = this.Name;
						this.EM = this.Email;
						this.ShareType = oElm.ShareType;
						this.itemType = this.Type;
						
						if(this.Type == "bizcard") {
							this.ID = this.UserID;
							this.BizCardType = "UR";
						} else {
							this.ID = this.Email;
							this.BizCardType = "";
						}
						
						strData += "<tr type='bizcard' id='orgSearchList_bizcard_anchor_" + oElm.BizCardType + "_" + oElm.ID + "_" + idx + "' ondblclick='coviOrgMail.contentDoubleClick(this);' style='display: none;'>";
						strData += "<td style='height:20px !important;'></td>";
						strData += "<td style='height:20px !important;'><input type='checkbox' id='orgSearchList_bizcard_sub_" + oElm.BizCardType + "_" + this.ID + "' name='"+ this.Name.replace(/'/g, "＇") +"' value='"+ jsonToString(this).replace(/'/g, "＇") +"'/></td>";
						strData += "<td style='height:20px !important;' class='subject'>" + $("<div />").text(this.Name + " " + "[" + this.Email + "]").html() + "</td>";
						strData += "</tr>";
					});
				});
			}else{
				$(data.list).each(function(){
					this.DN = this.Name;
					this.EM = this.Email;
					strData += "<tr type='bizcard' ondblclick='coviOrgMail.contentDoubleClick(this);'>";
					strData += "<td style='height:20px !important;'><input type='checkbox' id='orgSearchList_bizcard_" + pType + "_" + (pType == "GROUP" ? this.Email : this.ID) +"' name='"+ this.Name.replace(/'/g, "＇") +"' value='"+ jsonToString(this).replace(/'/g, "＇") +"'/></td>";
					strData += "<td style='height:20px !important;' class='subject'>" + $("<div />").text(this.Name + " " + "[" + this.Email + "]").html() + "</td>";
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
					publicUserCode : Common.getSession().UR_Code,
					searchText: tmpSearchWord,
					shareType : BizCardShareType,
					hasEmail : "Y"
				},
				url:"/groupware/bizcard/getBizCardOrgMapList.do",
				success:function (data) {
					setMemberList_BizCard(data, pType);
				}
			});
		}
	}
	
	coviOrgObj.displayGroupMember = function(pObj) {
		var id = $(pObj).attr("id");
		
		if($("#" + id).hasClass("active")) {
			// 접기
			$("#" + id).removeClass("active");
			$("#" + id).css({"background": "url(/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_arrow_02.png)", "background-repeat": "no-repeat", "background-position": "center"});
			$("#orgSearchList_BizCard_GR tr[id^='" + id + "_'").hide();
		} else {
			// 펼치기
			$("#" + id).addClass("active");
			$("#" + id).css({"background": "url(/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_arrow_03.png)", "background-repeat": "no-repeat", "background-position": "center"});
			$("#orgSearchList_BizCard_GR tr[id^='" + id + "_'").show();			
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
	function getSelectedData(sendCheck) {
		var rtnArr = new Array();
		if($this.config.drawOpt.charAt(3)!="R")
			return rtnArr;
		$("[id^='orgSelectedList_"+sendCheck+"'] [id^='orgSelectedList_']").each(function(){
			rtnArr.push($(this)[0].id);
		});

		return rtnArr;
	}
	
	function setOrgXmlData() {
		var returnData = new Array();
		
		if(selectedList != "") {
			var toList = new Object();
			var ccList = new Object();
			var bccList = new Object();

			var toAryList = new Array();
			var ccAryList = new Array();
			var bccAryList = new Array();
			
			var xmlData = $.parseXML(selectedList);
			
			$(xmlData).find("Items").find("ItemInfo").each(function() {
				var jsonData = null;
				var objectType = $(this).attr("objectType");
				var target = $(this).attr("target");
				var name = "";
				var mail = "";
				var mobile = "";
				
				if(objectType == "UR") {
					name = $(this).find("ExDisplayName").text();
					mail = $(this).find("EX_PrimaryMail").text();
					code = $(this).find("UR_Code").text();
					mobile = $(this).find("AD_Mobile").text();
					
					jsonData = {
							DN: name + ";",
							MailAddress: mail,
							UserCode: mail,
							UserName: name,
							label: name + "<" + mail + ">",
							value: mail,
							itemType: "user",
							TYPE: "P_" + target,
							AN: code,
							EM: mail,
							MT: mobile
					}
				} else if(objectType == "GR") {
					name = $(this).find("GroupName").text();
					mail = $(this).find("PrimaryMail").text();
					code = $(this).find("GR_Code").text();
					
					jsonData = {
							DN: name + ";",
							MailAddress: mail,
							UserCode: mail,
							UserName: name,
							label: name + "<" + mail + ">",
							value: mail,
							itemType: "group",
							TYPE: "P_" + target,
							AN: code,
							EM: mail
					}
				}
				
				if(jsonData != null) {
					if(target == "TO") {
						toAryList.push(jsonData);
					} else if(target == "CC") {
						ccAryList.push(jsonData);
					} else if(target == "BCC") {
						bccAryList.push(jsonData);
					}
				}
			});
			
			toList.P_TO = toAryList;
			ccList.P_CC = ccAryList;
			bccList.P_BCC = bccAryList;
			
			returnData.push(toList);
			returnData.push(ccList);
			returnData.push(bccList);
		}
		
		return returnData; 
	}
	
	// 선택목록에 있는 데이터를 리턴할 JSON 형태로 변경
	function makeOrgJsonData(){
		var returnvalue = {};
		var orgData = new Array;
		$("#orgSelectedList_P_TO input:checkbox").each(function(){
			orgData.push($.parseJSON($(this)[0].value));
		});
		$("#orgSelectedList_P_CC input:checkbox").each(function(){
			orgData.push($.parseJSON($(this)[0].value));
		});
		$("#orgSelectedList_P_BCC input:checkbox").each(function(){
			orgData.push($.parseJSON($(this)[0].value));
		});

		$$(returnvalue).attr("item", orgData);
		
		return JSON.stringify(returnvalue);
	}
	
	// 선택목록에 있는 데이터를 리턴할 XML 형태로 변경 (아웃룩 연동)
	function makeOrgXmlData(){
		var returnvalue = '';
		returnvalue += '<Items>';
		
		$("#orgSelectedList_P_TO input:checkbox, #orgSelectedList_P_CC input:checkbox, #orgSelectedList_P_BCC input:checkbox").each(function(){
			var jsonItem = $.parseJSON($(this)[0].value);
			var type = jsonItem.itemType;
			var objectType = '';
			var target = (jsonItem.TYPE == 'P_TO') ? 'TO' : (jsonItem.TYPE == 'P_CC') ? 'CC' : 'BCC';
			var code = jsonItem.AN;
			var name = CFN_GetDicInfo(jsonItem.DN, lang);
			var mail = jsonItem.EM;
			var mobile = '';
			
			// 조직도
			if(type == 'user') {
				type = 'User';
				objectType = 'UR';
				mobile = jsonItem.MT;
				
				returnvalue += '<ItemInfo type="' + type + '" objectType="' + objectType + '" target="' + target + '">';
				returnvalue += '<UR_Code>' + '<![CDATA[' + code + ']]>' + '</UR_Code>';
				returnvalue += '<ExDisplayName>' + '<![CDATA[' + name + ']]>' + '</ExDisplayName>';
				returnvalue += '<EX_PrimaryMail>' + '<![CDATA[' + mail + ']]>' + '</EX_PrimaryMail>';
				returnvalue += '<AD_Mobile>' + '<![CDATA[' + mobile + ']]>' + '</AD_Mobile>';
				returnvalue += '</ItemInfo>';
			} else if(type == 'group') {
				type = 'Group';
				objectType = 'GR';
				
				returnvalue += '<ItemInfo type="' + type + '" objectType="' + objectType + '" target="' + target + '">';
				returnvalue += '<GR_Code>' + '<![CDATA[' + code + ']]>' + '</GR_Code>';
				returnvalue += '<GroupName>' + '<![CDATA[' + name + ']]>' + '</GroupName>';
				returnvalue += '<PrimaryMail>' + '<![CDATA[' + mail + ']]>' + '</PrimaryMail>';
				returnvalue += '</ItemInfo>';
			} else {
				// 주소록
				objectType = jsonItem.BizCardType;
				type = 'User';
				code = '';
				
				if(objectType == "UR") {
					returnvalue += '<ItemInfo type="' + type + '" objectType="' + objectType + '" target="' + target + '">';
					returnvalue += '<UR_Code>' + '<![CDATA[' + code + ']]>' + '</UR_Code>';
					returnvalue += '<ExDisplayName>' + '<![CDATA[' + name + ']]>' + '</ExDisplayName>';
					returnvalue += '<EX_PrimaryMail>' + '<![CDATA[' + mail + ']]>' + '</EX_PrimaryMail>';
					returnvalue += '<AD_Mobile>' + '<![CDATA[' + mobile + ']]>' + '</AD_Mobile>';
					returnvalue += '</ItemInfo>';
				} else if(objectType == "GR") {
					var listMember = $.parseJSON(jsonItem.Member);
					
					$(listMember).each(function() {
						objectType = 'UR';
						name = $(this)[0].Name;
						mail = $(this)[0].Email;
						
						returnvalue += '<ItemInfo type="' + type + '" objectType="' + objectType + '" target="' + target + '">';
						returnvalue += '<UR_Code>' + '<![CDATA[' + code + ']]>' + '</UR_Code>';
						returnvalue += '<ExDisplayName>' + '<![CDATA[' + name + ']]>' + '</ExDisplayName>';
						returnvalue += '<EX_PrimaryMail>' + '<![CDATA[' + mail + ']]>' + '</EX_PrimaryMail>';
						returnvalue += '<AD_Mobile>' + '<![CDATA[' + mobile + ']]>' + '</AD_Mobile>';
						returnvalue += '</ItemInfo>';
					});
				}
			}
		});
		
		returnvalue += '</Items>';
		
		return returnvalue;
	}
	
	function setGroupInfo(deptCode){
		
		var groupPath = new Array();
		var groupNamePath = new Array();
		var startIndex = 0 
		var strHtml = '';
		
		$("#groupPathList").empty();
		
		$($this.groupTree.list).each(function(i,obj){
			if(deptCode == obj.GroupCode){
				groupPath = obj.GroupPath.split(";");
				groupNamePath = obj.GroupFullPath.split(">");
				return false;
			}
		});
	
		startIndex =  (  groupPath.indexOf($("#companySelect").val()) < 0 ? 0 : groupPath.indexOf($("#companySelect").val()) );
		
		groupPath = groupPath.slice(startIndex, groupPath.length);
		groupNamePath = groupNamePath.slice(startIndex, groupNamePath.length);
		
		$.each(groupNamePath,function(idx,obj){
			strHtml += '<li code="' + groupPath[idx] + '"><a>' + obj + '</a></li>';
		});
		
		$("#groupPathList").html(strHtml);
		
		$("#groupPathList>li").click(function(e){
			var code = $(e.currentTarget).attr("code")
			$($this.groupTree.list).each(function(i,obj){
				if(code == obj.GroupCode){
					$this.groupTree.click(obj.__index,'open');	
					//$this.getUserOfGroupList(obj.GroupCode);
				}
			});
		});

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
		$('#orgSearchList_BizCard_GroupMail').empty();
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
			$("#divSearchList_GroupMail").hide();
			$("#searchdiv").hide();
			$("#searchdiv_BizCard").show();
			$("#searchdiv_GroupMail").hide();
			($('#changeGroupTree').parent()).attr("class", "");
			($('#changeGroupMail').parent()).attr("class", "");
			($('#changeBizCard').parent()).attr("class", "active");
		}else if (param == "GroupMailDiv"){			
			$("#divSearchList_Main").hide();
			$("#divSearchList_BizCard").hide();
			$("#divSearchList_GroupMail").show();
			$("#searchdiv").hide();
			$("#searchdiv_BizCard").hide();
			$("#searchdiv_GroupMail").show();
			($('#changeBizCard').parent()).attr("class", "");
			($('#changeGroupTree').parent()).attr("class", "");
			($('#changeGroupMail').parent()).attr("class", "active");
		}else{
			$("#divSearchList_Main").show();
			$("#divSearchList_BizCard").hide();
			$("#divSearchList_GroupMail").hide();
			$("#searchdiv").show();
			$("#searchdiv_BizCard").hide();
			$("#searchdiv_GroupMail").hide();
			($('#changeBizCard').parent()).attr("class", "");
			($('#changeGroupMail').parent()).attr("class", "");
			($('#changeGroupTree').parent()).attr("class", "active");
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
				publicUserCode : Common.getSession().UR_Code,
				searchText: tmpSearchWord,
				shareType : BizCardShareType,
				hasEmail : "Y"
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
					publicUserCode : Common.getSession().UR_Code,
					searchText: tmpSearchWord,
					shareType : BizCardShareType,
					hasEmail : "Y"
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
	
	//그룹메일 탭에서 회사 선택 시, 해당하는 리스트 출력
	function orgGroupMailData(companyCode, searchWord){
		$.ajax({
				type:"POST",
				data:{
					companyCode : companyCode,
					searchText: searchWord
				},
				url:"/mail/manage/groupMail/selectOrgGroupMailList.do",
				success:function (data) {
					setMemberList_BizCard(data, "GroupMail");
				}
			});
	}
	
	window.GetSelectedValue = function() {
		return coviOrgObj.returnData();
	};
	
	return coviOrgObj;
	
}());