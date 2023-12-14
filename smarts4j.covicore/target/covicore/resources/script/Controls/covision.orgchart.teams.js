$(window).load(function () {
    try {
        // teams 로딩 표시기 종료
        if (typeof XFN_TeamsLoadComplete == 'function') {
            XFN_TeamsLoadComplete();
        }

        // Teams 테마 처리
        if (typeof XFN_TeamsSetTheme == "function") {
            XFN_TeamsSetTheme();
        }
        if (typeof XFN_TeamsRegThemeChangeHandler == "function") {
            XFN_TeamsRegThemeChangeHandler();
        }
    } catch (e) {coviCmn.traceLog(e)}

    if (navigator.userAgent.toLowerCase().indexOf("edge/") > -1) { // [16-03-11] kimhs, Edge 팝업 사이즈 조정
        if (screen.availHeight - 50 > 691)
            window.resizeTo(975, 691);
        else // 작은 화면의 경우
            window.resizeTo(975, screen.availHeight - 50);
    }
});

var coviOrgTeams = (function () {
	var coviOrgObj={};
	
	var orgDic =  Common.getDicAll(["lbl_officer", "lbl_apv_deptsearch", "btn_Confirm","btn_Close", "lbl_apv_person","btn_apv_search",
	                                ,"msg_OrgMap03","msg_OrgMap04","msg_OrgMap05","msg_OrgMap06","lbl_name","lbl_dept" , "msg_EnterSearchword"
	                                ,"lbl_MobilePhone", "lbl_apv_InPhone", "lbl_Role", "lbl_JobPosition","lbl_JobLevel","msg_NoDataList", "lbl_CompanyNumber"
	                                ,"OrgTreeKind_Dept","OrgTreeKind_Group", "lbl_UserProfile", "lbl_DeptOrgMap" , "lbl_group","lbl_OpenAll","lbl_CloseAll", "lbl_apv_recinfo_td2"
									,"lbl_com_exportAddress", "lbl_apv_appMail", "lbl_com_Absense", "lbl_com_searchByName", "lbl_com_searchByDept", "lbl_com_searchByPhone"
									, "lbl_com_searchByRole", "lbl_com_searchByJobPosition", "lbl_com_searchByJobLevel", "lbl_Mail_Contact"
									,"CPMail_Dept","CPMail_Contact", "CPMail_Personal", "CPMail_Company", "btn_Add", "btn_Delete", "lbl_AllList", "lbl_SelectedList", "CPMail_SelectAll"
									, "lbl_Teams_Message", "lbl_Teams_Schedule", "lbl_Teams_TeamManagement", "lbl_Teams_ChannelManagement", "lbl_Teams_TeamMemberManagement"
									, "lbl_Teams_GroupChatName", "btn_Teams_Send", "lbl_subject", "lbl_Contents", "btn_Teams_ScheduleCreate", "lbl_Teams_TeamName", "lbl_explanation"
									, "lbl_Creation", "lbl_Edit", "lbl_Teams_ChannelName", "lbl_Teams_TeamMember", "lbl_selectall", "lbl_button"]);
	
	var sessionObj = Common.getSession();
	var lang = sessionObj["lang"];
	var ProfileImagePath = Common.getBaseConfig("ProfileImagePath").replace("/{0}", ""); //프로필 이미지 경로
	var companyCode = CFN_GetQueryString("companyCode") == "undefined" ? sessionObj["DN_Code"] : CFN_GetQueryString("companyCode");
	var useAffiliateSearch = Common.getBaseConfig("useAffiliateSearch");
	
	var $this = coviOrgObj;
	var tmpSearchWord = "";
	var BizCardShareType = "";
	var searchList = "groupTree";
	
    var g_ChannelList = new Object();
    var g_TeamMemberList = new Object();
    
	coviOrgObj.groupTree = new AXTree();
	
	if (Common.getBaseConfig("orgchartTreeCheckAll") == 'N'){
		coviOrgObj.groupTree.gridCheckClick = function(){}
	}
	
	coviOrgObj.config = {
			targetID: '',
			type:'D9',
			treeKind:'Group',
			drawOpt:'LMARB', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
			callbackFunc: '', 
			openerID:'',
			allCompany: useAffiliateSearch,     /// 타 계열사 검색 허용 여부
			groupDivision: '',
			communityId: '',
			bizcardKind:'',
			onlyMyDept:'N',
			userParams:'',
			dragEndFunc:'' // dragend event name
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
			setInitGroupTreeData("Y"); //loadMyDept = "Y"
		}
		
		$(".btn_tslide").click(function(){
			if($(this).parents(".teams_orgchart #divSelectedList").is(":hidden")==false){
				$(this).toggleClass("active");
				$(this).parents(".teams_orgchart #divSelectedList").toggleClass("active");
			}
		});
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
					//var temFunc = new Function('param', coviCmn.getParentFrame( $this.config.openerID )+$this.config.callbackFunc+"(param)");
					//temFunc(makeOrgJsonData());
					let oFrame = coviCmn.getParentFrameObj($this.config.openerID);
					if(jQuery.isFunction(oFrame[$this.config.callbackFunc])){
						oFrame[$this.config.callbackFunc].apply(this, [makeOrgJsonData()]);
					}
				}

    		}else if(window[$this.config.callbackFunc] != undefined){
				window[$this.config.callbackFunc](makeOrgJsonData());
			} else if(parent[$this.config.callbackFunc] != undefined){
				parent[$this.config.callbackFunc](makeOrgJsonData());
			} else if(opener[$this.config.callbackFunc] != undefined){
				opener[$this.config.callbackFunc](makeOrgJsonData());
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
		//$("#selDeptTxt").text((deptCode=="GENERAL" ? "" : getGroupName(deptCode)));
		$("#selDeptTxt").text(getGroupName(deptCode));
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
	
	coviOrgObj.allCheck = function(obj){
		var table= $("#orgSearchList").closest('table');
		$('tbody tr td input[type="checkbox"]',table).prop('checked', $(obj).prop('checked'));
	}
	coviOrgObj.allCheck_BizCard = function(obj, pType){
		var table= $("#orgSearchList_BizCard_" + pType).closest('table');
		$('tbody tr td input[type="checkbox"]',table).prop('checked', $(obj).prop('checked'));
	}
	
	coviOrgObj.sendRight = function(){
		if($this.config.drawOpt.charAt(3)!="R")
			return;
		
		var dupStr=""; //중복된 데이터
		var dataobj = "";
		
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
					//dataobj =  new Function ("return ("+this.value+")").apply();
					dataobj =  jQuery.parseJSON(this.value);
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
			SetTeamsPresence();
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
				//보안취약 조치(eval, Function)
				//let ptFunc = new Function('a', tmpFuncName+"(a)");
				//ptFunc(pObjEvent);
				window[tmpFuncName].apply(this, [pObjEvent]);
			}

		}catch(ex){
			coviCmn.traceLog("void_ListItem_ondragend error:" + ex.message);
		}
	}
	
	coviOrgObj.goUserInfoPopup = function(userID){
		parent.Common.open("","MyInfo",orgDic["lbl_UserProfile"],"/covicore/control/callMyInfo.do?userID="+userID,"810px","500px","iframe",true,null,null,true); //사용자 프로필
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
	
	//teams 함수
	coviOrgObj.TeamsTab = function(pTabName) {
		$("div[id^='divTeams']").hide();
		$("li[id^='liTeams']").attr("class", "tabmenu_off");
		$("#div" + pTabName).show();
		$("#li" + pTabName).attr("class", "tabmenu_on");

		if (pTabName == "TeamsTeam" || pTabName == "TeamsChannel" || pTabName == "TeamsMember") {
		    SetTeamsTeamList(pTabName);
		}
    }

    coviOrgObj.TeamsMessage = function() {
		try {
			if ($("#divSelectedAllUser").css("display") != "none") {
				var oSelectedUser = $("input[id^='orgSelectedList_people']");
				if(oSelectedUser.length > 0){
					var sUsers = "";
					oSelectedUser.each(function() {
						if (($(this).attr("id") != "chkSelectedAllUserAll")) {
				    		var oItemInfo = JSON.parse($(this).val());
	            			sUsers += "," + oItemInfo.UserCode + "@" + Common.getBaseConfig("M365Domain");
						}
					});
					XFN_TeamsDeppLink_Chat(sUsers.substring(1), $("#txtTeamsMessageTitle").val(), $("#txtTeamsMessageBody").val());
				} else {
	          		Common.Warning(Common.getDic("msg_Teams_SelectUser"), "Warning Dialog", null); //
	        	}
			}
	      } catch (e) {
	        alert(e.stack);
		}
    }

    coviOrgObj.TeamsCalendar = function() {
    	try {
			if ($("#divSelectedAllUser").css("display") != "none") {
				var oSelectedUser = $("input[id^='orgSelectedList_people']");
				if(oSelectedUser.length > 0){
					var sUsers = "";
					oSelectedUser.each(function() {
						if (($(this).attr("id") != "chkSelectedAllUserAll")) {
				    		var oItemInfo = JSON.parse($(this).val());
	            			sUsers += "," + oItemInfo.UserCode + "@" + Common.getBaseConfig("M365Domain");
						}
					});
          			XFN_TeamsDeppLink_Calendar(sUsers.substring(1), $("#txtTeamsCalendarTitle").val(), $("#txtTeamsCalendarBody").val(), "", "");
				} else {
          			Common.Warning(Common.getDic("msg_Teams_SelectUser"), "Warning Dialog", null); //
				}
      		}
		}
		catch (e) {
			alert(e.stack);
		}
	}


	// 선택된 임직원의 항목을 마우스 오버 시 삭제 버튼이 표시됩니다.
    coviOrgObj.liSelected_OnMouseOver = function(pObj) {
      if ($(pObj).find("img").length == 0)
        $(pObj).append("<div style=\"float:right;\" ><img src=\"/HtmlSite/smarts4j_n/teams/resources/images/btn_trash.png\" onclick=\"coviOrgTeams.liOrgDelete(this);\"/></div>");
    }

    // 선택된 임직원의 항목을 마우스 오버 시 삭제 버튼이 표시됩니다.
    coviOrgObj.liSelected_OnMouseLeave = function(pObj){
      if ($(pObj).find("img").length > 0)
        $(pObj).find("img").parent().remove();
    }
	
	coviOrgObj.liOrgDelete = function(pObj){
      $(pObj).parent().parent().remove();
	}
	
	// 선택 목록 전체 항목의 임직원 전체 선택 체크박스의 선택 변경시 해당 컨트롤들의 선택을 변경합니다.
    // 추가/기존 항목 체크박스의 선택도 변경합니다.
    coviOrgObj.chkSelectedAllUserAll_OnChange = function() {
      $("input[id^='orgSelectedList_people']").prop("checked", $("#chkSelectedAllUserAll").is(":checked"));
    }

    // 선택 목록에서 화면이 표시중인 목록의 선택된 항목을 제거 합니다.
    // 선택 목록의 전체 항목에서 제거시, 추가/기존 항목의 같은 내용은 같이 지워줍니다.
    // 선택 목록의 추가/기존 항목에서 제거시, 전체 항목의 같은 내용은 같이 지워줍니다.
    coviOrgObj.aContentDel_OnClick = function() {
      if ($("#divSelectedAllUser").css("display") != "none") {
        $("input[id^='orgSelectedList_people']").each(function() {
          if (($(this).attr("id") != "chkSelectedAllUserAll") && ($(this).is(":checked"))) {
            $(this).parent().remove();
          }
        });
      }
      $("#chkSelectedAllUserAll").prop("checked", false);
    }
	
	// Teams 팀 목록 설정 
    function SetTeamsTeamList(pTabName) {

        if ((pTabName == "TeamsTeam" && $("#selTeamsTeamListByTeam").text().replace(/ /g, "") == "")
            || (pTabName == "TeamsChannel" && $("#selTeamsTeamListByChannel").text().replace(/ /g, "") == "")
            || (pTabName == "TeamsMember" && $("#selTeamsTeamListByMember").text().replace(/ /g, "") == "")) {
            XFN_TeamsGetTeamList(pTabName, SetTeamsTeamList_Callback);
        } else {
            if (pTabName == "TeamsTeam") {
            	coviOrgObj.selTeamsTeamListByTeam_OnChange($("#hidTeamsTeamId").val());
            } else if (pTabName == "TeamsChannel") {
            	coviOrgObj.selTeamsTeamListByChannel_OnChange($("#hidTeamsTeamId").val());
            } else if (pTabName == "TeamsMember") {
            	coviOrgObj.selTeamsTeamListByMember_OnChange($("#hidTeamsTeamId").val());
            }
        }
    }

    function SetTeamsTeamList_Callback(pResponse, pTabName) {
        try {
            var sOptionHTML = GetTeamsOptionListHTML(pResponse.list);

            $("#selTeamsTeamListByTeam").html("<option value=\"\" data=\"\" selected=\"selected\">" + Common.getDic("lbl_Teams_NewTeam") + "</option>" + sOptionHTML);  // 신규팀
            $("#selTeamsTeamListByChannel").html(sOptionHTML);
            $("#selTeamsTeamListByMember").html(sOptionHTML);

            if (pTabName == "TeamsTeam") {
            	coviOrgObj.selTeamsTeamListByTeam_OnChange($("#hidTeamsTeamId").val());
            } else if (pTabName == "TeamsChannel") {
            	coviOrgObj.selTeamsTeamListByChannel_OnChange($("#hidTeamsTeamId").val());
            } else if (pTabName == "TeamsMember") {
            	coviOrgObj.selTeamsTeamListByMember_OnChange($("#hidTeamsTeamId").val());
            }
        } catch (e) {
            alert(e.stack);
        }
    }

    // Teams 팀 목록 HTML 조회
    function GetTeamsOptionListHTML(pData) {
        var sHTML = "";
        var nLength = pData.length;
        for (var nIdx = 0; nIdx < nLength; nIdx++) {
            sHTML += "<option value=\"" + pData[nIdx].id + "\" data=\"" + encodeURIComponent(JSON.stringify(pData[nIdx])) + "\">" + $("<div />").text(pData[nIdx].displayName).html() + "</option>";
        }
        return sHTML;
    }
    
    coviOrgObj.selTeamsTeamListByTeam_OnChange = function(pTeamId){
        if (typeof pTeamId != undefined && pTeamId != null && pTeamId != "") {
            $("#selTeamsTeamListByTeam").val(pTeamId);
        }
        
        if ($("#selTeamsTeamListByTeam").val() == "") {
            $("#hidTeamsTeamId").val("");
            $("#txtTeamsTeamDisplayName").val("");
            $("#txtTeamsTeamDesc").val("");
            $("#aTeamsTeamCreate").show();
            $("#aTeamsTeamUpdate").hide();
        } else {
            var sData = decodeURIComponent($("#selTeamsTeamListByTeam > option:selected").attr("data"));
            var oData = JSON.parse(sData);

            $("#hidTeamsTeamId").val(oData.id);
            $("#txtTeamsTeamDisplayName").val(oData.displayName);
            $("#txtTeamsTeamDesc").val(oData.description);
            $("#aTeamsTeamCreate").hide();
            $("#aTeamsTeamUpdate").show();
        }
    }
    
    // Teams 팀 생성/수정
    coviOrgObj.SetTeamsTeam_Save = function(pMode) {
        if ($("#txtTeamsTeamDisplayName").val().replace(/ /g, "") == "") {
            // 팀이름을 입력하세요.
            Common.Warning(Common.getDic("msg_Teams_EnterTeamName"), "Warning Dialog", function () {
                $("#txtTeamsTeamDisplayName").focus();
            });
        } else {
            XFN_TeamsSetTeam(pMode, $("#hidTeamsTeamId").val(), $("#txtTeamsTeamDisplayName").val(), $("#txtTeamsTeamDesc").val(), SetTeamsTeam_Save_Callback);
        }
    }
    
    function SetTeamsTeam_Save_Callback(pResponse) {
        setTimeout(function () {
            try {
                Common.AlertClose();

                $("#txtTeamsTeamDisplayName").val("");
                $("#txtTeamsTeamDesc").val("");
                $("#selTeamsTeamListByTeam").html("");

                SetTeamsTeamList("TeamsTeam");
            } catch (e) {
                Common.AlertClose();
                alert(e.stack);
            }
        }, 5000);
    }

    // Teams 팀 변경시(채널관리)
    coviOrgObj.selTeamsTeamListByChannel_OnChange = function(pTeamId) {
        var bChanged = false;
        if (typeof pTeamId == undefined || pTeamId == null || pTeamId == "") {
            bChanged = true;
        } else if (pTeamId != $("#selTeamsTeamListByChannel").val()) {
            $("#selTeamsTeamListByChannel").val(pTeamId);
            bChanged = true;
        }
        if ($("#selTeamsTeamListByChannel > option").length > 0 && (bChanged || $("#selTeamsChannelList > option").length == 0)) {
            var sData = decodeURIComponent($("#selTeamsTeamListByChannel > option:selected").attr("data"));
            var oData = JSON.parse(sData);

            $("#hidTeamsTeamId").val(oData.id);

            if (g_ChannelList[oData.id] != undefined && g_ChannelList[oData.id] != null) {
                var sOptionHTML = GetTeamsOptionListHTML(g_ChannelList[oData.id].Data);

                $("#selTeamsChannelList").html("<option value=\"\" data=\"\" selected=\"selected\">" + Common.GetDic("lbl_Teams_NewChannel") + "</option>" + sOptionHTML);  // 신규채널
                coviOrgObj.selTeamsChannelList_OnChange(true);
            } else {
                SetTeamsChannelList(oData);
            }
        }
    }

    // Teams 채널 목록 설정 
    function SetTeamsChannelList(pData) {
        XFN_TeamsGetChannelList(pData.id, SetTeamsChannelList_Callback);
    }
    function SetTeamsChannelList_Callback(pResponse, pTeamId) {
        try {
            var sOptionHTML = GetTeamsOptionListHTML(pResponse.list);

            $("#selTeamsChannelList").html("<option value=\"\" data=\"\" selected=\"selected\">" + Common.getDic("lbl_Teams_NewChannel") + "</option>" + sOptionHTML);  // 신규채널
            g_ChannelList[pTeamId] = pResponse;
            coviOrgObj.selTeamsChannelList_OnChange(true);

            Common.AlertClose();
        } catch (e) {
            Common.AlertClose();
            alert(e.stack);
        }
    }

    // Teams 채널 변경시
    coviOrgObj.selTeamsChannelList_OnChange = function(pInit) {
        if (pInit) {
            if ($("#selTeamsChannelList > option[value='" + $("#hidTeamsChannelId").val() + "']").length > 0) {
                $("#selTeamsChannelList").val($("#hidTeamsChannelId").val());
            } else {
                $("#hidTeamsChannelId").val("");
            }
        }

        if ($("#selTeamsChannelList").val() == "") {
            $("#hidTeamsChannelId").val("");
            $("#txtTeamsChannelDisplayName").val("");
            $("#txtTeamsChannelDesc").val("");
            $("#aTeamsChannelCreate").show();
            $("#aTeamsChannelUpdate").hide();
        } else {
            var sData = decodeURIComponent($("#selTeamsChannelList > option:selected").attr("data"));
            var oData = JSON.parse(sData);

            $("#hidTeamsChannelId").val(oData.id);
            $("#txtTeamsChannelDisplayName").val(oData.displayName);
            $("#txtTeamsChannelDesc").val(oData.description);
            $("#aTeamsChannelCreate").hide();
            $("#aTeamsChannelUpdate").show();
        }
    }

    // Teams 채널 생성/수정
    coviOrgObj.SetTeamsChannel_Save = function(pMode) {
        if ($("#txtTeamsChannelDisplayName").val().replace(/ /g, "") == "") {
            // 채널이름을 입력하세요.
            Common.Warning(Common.getDic("msg_Teams_EnterChannelName"), "Warning Dialog", function () {
                $("#txtTeamsChannelDisplayName").focus();
            });
        } else {
            XFN_TeamsSetChannel(pMode, $("#hidTeamsTeamId").val(), $("#hidTeamsChannelId").val(), $("#txtTeamsChannelDisplayName").val(), $("#txtTeamsChannelDesc").val(), SetTeamsChannel_Save_Callback);
        }
    }
    function SetTeamsChannel_Save_Callback(pResponse, pTeamId) {
        setTimeout(function () {
            try {
                Common.AlertClose();

                $("#txtTeamsChannelDisplayName").val("");
                $("#txtTeamsChannelDesc").val("");
                $("#selTeamsChannelList").html("");
                g_ChannelList[pTeamId] = null;

                coviOrgObj.selTeamsTeamListByChannel_OnChange("");
            } catch (e) {
                Common.AlertClose();
                alert(e.stack);
            }
        }, 5000);
    }
    
    // Teams 팀 변경시(팀원관리)
    coviOrgObj.selTeamsTeamListByMember_OnChange = function(pTeamId) {
        var bChanged = false;
        if (typeof pTeamId == undefined || pTeamId == null || pTeamId == "") {
            bChanged = true;
        } else if (pTeamId != $("#selTeamsTeamListByMember").val()) {
            $("#selTeamsTeamListByMember").val(pTeamId);
            bChanged = true;
        }

        if ($("#selTeamsTeamListByMember > option").length > 0 && (bChanged || $("#ulTeamsMemberList > li").length == 0)) {
            var sData = decodeURIComponent($("#selTeamsTeamListByMember > option:selected").attr("data"));
            var oData = JSON.parse(sData);

            $("#hidTeamsTeamId").val(oData.id);
            
            if (g_TeamMemberList[oData.id] != undefined && g_TeamMemberList[oData.id] != null) {
                var sListHTML = GetTeamsTeamMemberListHTML(g_TeamMemberList[oData.id].Data);

                $("#ulTeamsMemberList").html(sListHTML);
            } else {
                SetTeamsTeamMemberList(oData);
            }
        }
    }
    
    // Teams 팀원 목록 설정 
    function SetTeamsTeamMemberList(pData) {
        XFN_TeamsGetTeamMember(pData.id, SetTeamsTeamMemberList_Callback);
    }
    function SetTeamsTeamMemberList_Callback(pResponse, pTeamId) {
        try {
            var sListHTML = GetTeamsTeamMemberListHTML(pResponse.list);

            $("#ulTeamsMemberList").html(sListHTML);
            g_TeamMemberList[pTeamId] = pResponse;

            Common.AlertClose();
        } catch (e) {
            Common.AlertClose();
            alert(e.stack);
        }
    }
    
    // Teams 팀원 전체 선택 클릭시
    coviOrgObj.chkTeamsMemberAll_OnClick = function() {
        $("input[id^='chkTeamsMember']").prop("checked", $("#chkTeamsMemberAll").is(":checked"));
    }
    

    // Teams 팀원 추가
    coviOrgObj.SetTeamsTeamMember_Add = function() {
        try {
            if ($("#selTeamsTeamListByMember > option").length > 0) {
				var oSelectedUser = $("input[id^='orgSelectedList_people']");
				if(oSelectedUser.length > 0){
					var sUR_Codes = "";
					oSelectedUser.each(function() {
						if (($(this).attr("id") != "chkSelectedAllUserAll")) {
				    		var oItemInfo = JSON.parse($(this).val());
				    		sUR_Codes += "," + oItemInfo.UserCode;
						}
					});
                    sUR_Codes = sUR_Codes.substring(1);

                    XFN_TeamsSetTeamMemberAdd($("#hidTeamsTeamId").val(), sUR_Codes, SetTeamsTeamMember_Add_Callback);
                } else {
                    Common.Warning(Common.getDic("msg_Teams_SelectUser"), "Warning Dialog", null);    // 사용자를 선택하세요.
                }
            }
        } catch (e) {
            Common.AlertClose();
            alert(e.stack);
        }
    }
    function SetTeamsTeamMember_Add_Callback(pResponse, pTeamId) {
		var sUsers = "";
		pResponse.failList.forEach(function(element){
			var oSelectedUser = $("input[id^='orgSelectedList_people']");
			if(oSelectedUser.length > 0){
				oSelectedUser.each(function() {
		    		var oItemInfo = JSON.parse($(this).val());
					if(element == oItemInfo.UserCode){
						sUsers +=  CFN_GetDicInfo(oItemInfo.DN,lang) + " ";
					}	
				});
			}
		});
		alert("Fail to add team member : " + sUsers);
        setTimeout(function (sTeamId) {
            try {
                Common.AlertClose();
				
                g_TeamMemberList[sTeamId] = null;

				
                coviOrgObj.selTeamsTeamListByMember_OnChange("");
            } catch (e) {
                Common.AlertClose();
                alert(e.stack);
            }
        }, 5000, pTeamId);
    }

    // Teams 팀원 삭제
    coviOrgObj.SetTeamsTeamMember_Delete = function() {
        try {
            if ($("#selTeamsTeamListByMember > option").length > 0) {
                var oCheckedUser = $("input[name='chkTeamsMember']:checked");
                if (oCheckedUser.length > 0) {
                    var sMembershipIds = "";
                    oCheckedUser.each(function () {
                        var sData = decodeURIComponent($(this).val());
                        var oData = JSON.parse(sData);
                        var sMembershipId = oData.id;
                        var sDisplayName = oData.displayName;
                        sMembershipIds += ";" + sMembershipId;
                    });
                    sMembershipIds = sMembershipIds.substring(1);

                    XFN_TeamsSetTeamMemberDelete($("#hidTeamsTeamId").val(), sMembershipIds, SetTeamsTeamMember_Delete_Callback);
                } else {
                    Common.Warning(Common.getDic("msg_Teams_SelectUser"), "Warning Dialog", null);    // 사용자를 선택하세요.
                }
            }
        } catch (e) {
            Common.AlertClose();
            alert(e.stack);
        }
    }
    function SetTeamsTeamMember_Delete_Callback(pResponse, pTeamId) {
        setTimeout(function () {
            try {
                Common.AlertClose();

                g_TeamMemberList[pTeamId] = null;

                coviOrgObj.selTeamsTeamListByMember_OnChange("");
            } catch (e) {
                Common.AlertClose();
                alert(e.stack);
            }
        }, 5000);
    }
    // Teams 팀원 클릭시
    coviOrgObj.chkTeamsMember_OnClick = function() {
        if ($("input[name='chkTeamsMember']").length == $("input[name='chkTeamsMember']:checked").length) {
            $("#chkTeamsMemberAll").prop("checked", true);
        } else {
            $("#chkTeamsMemberAll").prop("checked", false);
        }
    }
    
    // Teams 팀원 목록 HTML 조회
    function GetTeamsTeamMemberListHTML(pData) {
        var sHTML = "";
        var sAadObjectIds = "";
        var sJobTypeUses = Common.getBaseConfig("JobTypeUses");
        var arrJobTypeUses = sJobTypeUses.split(";");
        var nLength = pData.length;
        for (var nIdx = 0; nIdx < nLength; nIdx++) {
            var sJobString = "";
            if (pData[nIdx].GroupName != null && pData[nIdx].GroupName != "") {
                sJobString += pData[nIdx].GroupName;
            }
            for (var nIdx2 = 0; nIdx2 < arrJobTypeUses.length; nIdx2++) {
                if (arrJobTypeUses[nIdx2].toUpperCase() == "PN") {
                    if (pData[nIdx].jobPositionName != null && pData[nIdx].jobPositionName != "") {
                        if (sJobString != "") {
                            sJobString += ", ";
                        }
                        sJobString += pData[nIdx].jobPositionName;
                    }
                } else if (arrJobTypeUses[nIdx2].toUpperCase() == "LN") {
                    if (pData[nIdx].jobLevelName != null && pData[nIdx].jobLevelName != "") {
                        if (sJobString != "") {
                            sJobString += ", ";
                        }
                        sJobString += pData[nIdx].jobLevelName;
                    }
                } else if (arrJobTypeUses[nIdx2].toUpperCase() == "TN") {
                    if (pData[nIdx].jobTitleName != null && pData[nIdx].jobTitleName != "") {
                        if (sJobString != "") {
                            sJobString += ", ";
                        }
                        sJobString += pData[nIdx].jobTitleName;
                    }
                }
            }

            sHTML += "<li >";
            sHTML += "<input id=\"chkTeamsMember_" + pData[nIdx].userId + "\" ur_code=\"" + pData[nIdx].usercode + "\" name=\"chkTeamsMember\" type=\"checkbox\" class=\"input_check\" style=\"cursor: pointer;\" value=\"" + encodeURIComponent(JSON.stringify(pData[nIdx])) + "\" onclick=\"coviOrgObj.chkTeamsMember_OnClick();\" /> ";
            sHTML += "<label for=\"chkTeamsMember_" + pData[nIdx].userId + "\" style=\"cursor: pointer;\">";
            sHTML += "<span id=\"spanTeamsPresenceMember_" + pData[nIdx].userId + "\" class=\"pState pState06\" title=\"" + Common.getDic("lbl_Teams_PresenceUnknown") + "\"></span>"; // 알 수 없음
            sHTML += "<span class=\"txt_gn12\" title=\"" + $("<div />").text(pData[nIdx].email).html() + "\">" + $("<div />").text(pData[nIdx].displayName).html() + "</span><span class=\"txt_gn11_blur3\" title=\"" + $("<div />").text(pData[nIdx].email).html() + "\">" + (sJobString == "" ? "" : "(" + $("<div />").text(sJobString).html() + ")") + "</span>";
            sHTML += "</label>";
            sHTML += "</li>";

            sAadObjectIds += "," + pData[nIdx].userId;
        }

        if (sAadObjectIds != "") {
            GetTeamsPresence("", sAadObjectIds.substring(1), "spanTeamsPresenceMember_");
        }
        return sHTML;
    }
    
    // Teams Presence 조회
    function GetTeamsPresence(pUR_Codes, pAadObjectIds, pSpanID) {
        XFN_TeamsGetPresence(pUR_Codes, pAadObjectIds, pSpanID, GetTeamsPresence_Callback);
    }
    function GetTeamsPresence_Callback(pResponse, pSpanID) {
        try {
            if (pResponse.list != undefined && pResponse.list != null) {
                var sTitle = "";
                var nLength = pResponse.list.length;
                for (var nIdx = 0; nIdx < nLength; nIdx++) {
                    switch (pResponse.list[nIdx].availability.toUpperCase()) {
                        case "AVAILABLE":
                            sTitle = Common.getDic("lbl_Teams_PresenceAvailable");  // 대화 가능
                            sPresenceClass = "pState pState01";
                            break;
                        case "BUSY":
                            sTitle = Common.getDic("lbl_Teams_PresenceBusy");  // 다른 용무 중
                            sPresenceClass = "pState pState02";
                            break;
                        case "DONOTDISTURB":
                            sTitle = Common.getDic("lbl_Teams_PresenceDoNotDisturb");  // 방해 금지
                            sPresenceClass = "pState pState03";
                            break;
                        case "BERIGHTBACK":
                            sTitle = Common.getDic("lbl_Teams_PresenceBeRightBack");  // 곧 돌아오겠음
                            sPresenceClass = "pState pState04";
                            break;
                        case "AWAY":
                            sTitle = Common.getDic("lbl_Teams_PresenceAway");  // 자리 비움
                            sPresenceClass = "pState pState05";
                            break;
                        case "OFFLINE":
                            sTitle = Common.getDic("lbl_Teams_PresenceOffline");  // 오프라인
                            sPresenceClass = "pState pState06";
                            break;
                        default:
                            sTitle = Common.getDic("lbl_Teams_PresenceUnknown");  // 알 수 없음
                            sPresenceClass = "pState pState06";
                            break;
                    }

                    if (pSpanID.indexOf("Member") > -1) {
                        $("#" + pSpanID + pResponse.list[nIdx].id).attr("class", sPresenceClass);
                        $("#" + pSpanID + pResponse.list[nIdx].id).attr("title", sTitle);
                    } else {
 						/*
                        $("#spanTeamsPresence_" + pResponse.list[nIdx].usercode.toLowerCase()).attr("class", sPresenceClass);
                        $("#spanTeamsPresence_" + pResponse.list[nIdx].usercode.toLowerCase()).attr("title", sTitle);
                        $("#spanTeamsPresenceSelected_" + pResponse.list[nIdx].usercode.toLowerCase()).attr("class", sPresenceClass);
                        $("#spanTeamsPresenceSelected_" + pResponse.list[nIdx].usercode.toLowerCase()).attr("title", sTitle);
                        */
                        $("span[id='spanTeamsPresence_" + pResponse.list[nIdx].usercode.toLowerCase() + "']").attr("class", sPresenceClass);
                        $("span[id='spanTeamsPresence_" + pResponse.list[nIdx].usercode.toLowerCase() + "']").attr("title", sTitle);
                        $("span[id='spanTeamsPresenceSelected_" + pResponse.list[nIdx].usercode.toLowerCase() + "']").attr("class", sPresenceClass);
                        $("span[id='spanTeamsPresenceSelected_" + pResponse.list[nIdx].usercode.toLowerCase() + "']").attr("title", sTitle);
                    }
                }
            }
        } catch (e) {
            alert(e.stack);
        }
     }
    
    function SetTeamsPresence(){
        var sUR_Codes = "";
        var arrUserSummary = $("input[id^='orgSearchList_people']");
        var arrUserList = $("input[id^='orgSelectedList_people']");

        arrUserSummary.each(function () {
        	var oItemInfo = JSON.parse($(this).val());
            sUR_Codes += "," + oItemInfo.UserCode;;
        });
        arrUserList.each(function () {
        	var oItemInfo = JSON.parse($(this).val());
            sUR_Codes += "," + oItemInfo.UserCode;;
        });

        if (sUR_Codes != "") {
            GetTeamsPresence(sUR_Codes.substring(1), "", "");
        }
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
	}	
	
	//기본 HTML 바인딩
	function insertBasicHTML(){
		var html = '', btnHtml = '';
		html += '	<section id="orgChart" class="teams_orgchart">';
		//부서 및 그룹 트리 test
		if($this.config.drawOpt.charAt(0) === 'L'){
			if($this.config.bizcardKind != ""){
				html += ' 		<div class="tblList tblCont tblBizcardList" style="margin-top:0px;"> ';
				html += '			<div id ="changeType" class="tblFilterTop">';
				html += '				<ul class="filterList">';
				html += '					<li class="active"><a id = "changeGroupTree">'+orgDic["CPMail_Dept"]+'</a></li>';
				html += '					<li><a id = "changeBizCard">'+orgDic["CPMail_Contact"]+'</a></li>';
				html += ' 				</ul>';
				html += '			</div>';
				html += '		</div>';
			}
			html += '			<div class="appTree" id="groupTreeDiv">';
			html += '				<div class="appTreeTop">';
			html += '					<select id="companySelect" class="treeSelect" data-axbind="select"></select>';
			if($this.config.treeKind.toUpperCase() == "GROUP"){
				html += '		 			<div style="height:3px; width:100%;"></div>';
				html += '		 			<div class="org_tree_top_radio_wrap">';
				html += '						<input id="deptRadio" type="radio" class="org_tree_top_radio" value="dept" name="groupTypeRadio" checked="">';
				html += '							<label for="deptRadio">' + orgDic["lbl_DeptOrgMap"]+ '</label>';
				html += '						<input id="groupRadio" type="radio"class="org_tree_top_radio" value="group" name="groupTypeRadio">';
				html += '							<label for="groupRadio">' + orgDic["lbl_group"]+ '</label>';
				html += '					</div>';
			}
			html += '				</div>';
			html += '				<div class="appTreeBot">';
			html += '					<div id="groupTree" class = "treeList radio radioType02 org tree mailTree" style="height: 390px;"></div>';
			html += '				</div>';
			html += '			</div>';
			html += '			<div class="appTree" id="BizCardDiv" style="display: none;">';
			html += '				<ul id="leftmenu" class="contLnbMenu bizcardMenu">';
			html += '					<li class="menuAllContact" data-menu-id="" data-menu-alias="undefined" data-menu-url="/mail/layout/bizcard_BizCardPersonList.do?CLSYS=bizcard&amp;CLMD=user&amp;CLBIZ=Bizcard">';
			html += '						<div class="selOnOffBoxChk type02 boxList active">';
			html += '							<div class="menuAllContact01"> <a class="bizCardGroup" value="P"> <span uid="개인">개인</span></a> </div>';
			html += '			            	<div class="menuAllContact02" data-menu-id="" data-menu-alias="undefined" data-menu-url="%2Fmail%2Flayout%2Fbizcard_BizCardPersonListForD.do%3FCLSYS%3Dbizcard%26CLMD%3Duser%26CLBIZ%3DBizcard"> <a class="bizCardGroup" value="D"> <span uid="부서">부서</span></a> </div>';
			html += '			            	<div class="menuAllContact03" data-menu-id="" data-menu-alias="undefined" data-menu-url="%2Fmail%2Flayout%2Fbizcard_BizCardPersonListForU.do%3FCLSYS%3Dbizcard%26CLMD%3Duser%26CLBIZ%3DBizcard"> <a class="bizCardGroup" value="U"> <span uid="회사">회사</span></a> </div>';
			html += '						</div>';
			html += '					</li>';
			html += '				</ul>';
			html += '				<table class="tableStyle t_center hover">';
			html += '					<tbody id="groupMailSearchList"></tbody>';
			html += '				</table>';
			html += '			</div>';

		}
		
		
		if($this.config.drawOpt.charAt(1) === 'M'){
			html += '			<div class="appList_top_b searchBox02">'
			html += '				<div id="searchdiv">';
			/*html += '					<select id="searchType" class="j_appSelect">';
			html += '						<option value="person">'+orgDic["lbl_apv_person"]+'</option>';
			html += '						<option value="dept">'+orgDic["lbl_dept"]+'</option>';
			html += '					</select>';*/
			html += '					<input style="width: 274px;" type="text" autocomplete="off" placeholder="'+orgDic["msg_EnterSearchword"]+'" id="searchWord" name="inputSelector_onsearch"  data-axbind="selector"  ><a class="btnSearchType01" >'+orgDic["btn_apv_search"]+'</a>';
			html += '				</div>';
			html += '				<div id="searchdiv_BizCard" style="display:none;" class="appList_top_b searchBox02">';
			html += '					<input style="width: 274px;" type="text" autocomplete="off" placeholder="'+orgDic["msg_EnterSearchword"]+'" id="searchWord_BizCard" name="inputSelector_onsearch_BizCard"  data-axbind="selector"  ><a class="btnSearchType01" onclick="var e = $.Event( \'keydown\', { keyCode: 13 } ); $(\'#searchWord_BizCard\').trigger( e );">'+orgDic["btn_apv_search"]+'</a>';
			html += '				</div>';
			html += '			</div>';
			html += '			<div id="divSearchList_Main" class="appList" style="overflow:hidden; display: block;">';
			html += '				<table class="tableStyle t_center hover appListTop" style="width:276px;">';
			html += '					<thead  id="infoList">';
			html += '						<tr>';
			html += '							<th>';
			if($this.config.type != "C1" &&  $this.config.type != "C9"  && $this.config.type != "A0" && $this.config.type != "A1"){
				html += '								<input type="checkbox" id="allchk" name="allchk" onchange="coviOrg.allCheck(this)" style="  float: left;    margin: 8px;    height: 14px;	">';
				html += '								<label for="allchk"><span id="selDeptTxt" style="float: left;font-weight: normal;margin-top: 8px;margin-right: 8px;max-width: 236px;text-align: left;margin-bottom: 8px;"></span></label>';
			}
			html += ' 			          			<ul class="layer_searchlist_info_r" style="margin: 0px;">';
		    html += ' 			            			<li>';
			html += '										<a href="#" onclick="coviOrgTeams.contentDoubleClick(this);"><em class="btn_iws_l" style="margin-bottom: 0px;"><span class="btn_iws_r"><strong class="txt_btn_ws">' + orgDic["btn_Add"] + '</strong></span></em></a>';
			html += '									</li>';
			html += '								</ul>';
			html += '							</th>';
			html += '						</tr>';            
			html += '					</thead>';
			html += '				</table>';
			html += '				<div class="appListBot" style="height: 393px;	">';
			html += '					<table class="tableStyle t_center hover">';
			html += '						<colgroup>';
			html += '							<col style="width:30px">';
			html += '							<col style="width:80px">';
			html += '							<col style="width:*">';
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
			html += '									<input type="checkbox" id="allchk_BizCard_UR" name="allchk_BizCard_UR" onchange="coviOrgTeams.allCheck_BizCard(this, \'UR\')" style="  float: left;    margin: 8px;    height: 14px;	">';
			html += '								</div>';
			html += '								<label for="allchk_BizCard_UR"><span style="font-weight: normal; margin-top: 8px; margin-right: 20px; float: left;">'+orgDic["lbl_Mail_Contact"]+'</span></label>';
			html += '								<div id="divBizCardPaging_UR" class="org_paging" style="display:none;">';
			html += '									<table cellspacing="0" cellpadding="0">';
			html += '										<tbody>';
			html += '											<tr>';
			html += '												<td width="25" align="left" valign="middle">';
			html += '													<a style="cursor: pointer;" onclick="coviOrgTeams.BizCardPageMove_onclick(\'PREV\', \'UR\');">&lt;</a>';
			html += '												</td>';
			html += '												<td align="left" valign="middle">';
			html += '													<input id="hidBizCardCurPage_UR" type="hidden" value="1">';
			html += '													<span class="gray"><span id="spanBizCardCurPage_UR">1</span>&nbsp;/&nbsp;<span id="spanBizCardTotalPage_UR">1</span></span>';
			html += '												</td>';
			html += '												<td align="right" valign="middle" style="padding-left: 10px;">';
			html += '													<a style="cursor: pointer;" onclick="coviOrgTeams.BizCardPageMove_onclick(\'NEXT\', \'UR\');">&gt;</a>';
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
				html += '					<div id="orgSearchListMessage_BizCard_GR"></div>';
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
		    html += ' 			<div id="divSelectedList" class="" style="float:left;">';
      		html += ' 			  <a href="#" class="btn_tslide">' + orgDic["lbl_button"] + '</a>';
		    html += ' 			  <div class="layer_selectlist layer_selectlist_wrap" style="height:270px; width:400px; margin-left:14px;">';
		    html += ' 			    <div class="layer_searchlist_title">';
		    html += ' 			      <p class="layer_searchlist_title_txt"><img src="/Images/Images/Controls/Popup/popup_bul.gif" alt="" class="popup_bul">' + orgDic["lbl_SelectedList"] + '</p>';
		    html += ' 			      <div class="layer_searchlist_style">';
		    html += ' 			        <p class="view_sum2"></p>';
		    html += ' 			      </div>';
		    html += ' 			    </div>';
		    html += ' 			    <ul class="layer_searchlist_tab">';
		    html += ' 			      <li><a id="aSelectedAll" class="t_on" style="cursor: pointer;" onclick="btnListViewType_OnClick(\'ALL\');">' + orgDic["lbl_AllList"] + '<img src="/Images/Images/common/Icon/ico_tab.gif" alt="" class="ico_tab"></a></li>';
		    html += ' 			    </ul>';
		    html += ' 			    <div id="divSelectedAll">';
		    html += ' 			      <div class="layer_selectlist_info_list1">';
		    html += ' 			        <div class="layer_searchlist_info2" style="width:380px;">';
		    html += ' 			          <ul class="layer_searchlist_info_l">';
		    html += ' 			            <li><input name="chkSelectedAllUserAll" type="checkbox" id="chkSelectedAllUserAll" class="input_check" style="cursor: pointer;" onclick="coviOrgTeams.chkSelectedAllUserAll_OnChange();"> <label for="chkSelectedAllUserAll"';
		    html += ' 			                style="cursor: pointer;">' + orgDic["lbl_selectall"] + '</label></li>';
		    html += ' 			          </ul>';
		    html += ' 			          <ul class="layer_searchlist_info_r" style="margin-top: -5px;">';
		    html += ' 			            <li>';
		    html += ' 			              <a href="#" onclick="coviOrgTeams.aContentDel_OnClick();"><em class="btn_iws_l"><span class="btn_iws_r"><strong class="txt_btn_ws">' + orgDic["btn_Delete"] + '</strong></span></em></a>';
		    html += ' 			            </li>';
		    html += ' 			          </ul>';
		    html += ' 			        </div>';
		    html += ' 			        <div id="divSelectedAllUser" class="layer_selectlist_info_list1_cont" style="width: 380px; height: 155px;">';
		    html += ' 			          <ul id="ulSelectedAllUser" style="margin-right:0px;"></ul>';
		    html += ' 			        </div>';
		    html += ' 			      </div>';
		    html += ' 			    </div>';
		    html += ' 			    <div class="layer_selectlist layer_selectTab" style="height:277px; width:400px; margin-top:3px;">';
		    html += ' 			      <ul class="r_tabmenu">';
		    html += ' 			        <li class="tabmenu_on" id="liTeamsMessage"><a href="javascript:coviOrgTeams.TeamsTab(\'TeamsMessage\')">' + orgDic["lbl_Teams_Message"] + '</a></li>';
		    html += ' 			        <li class="tabmenu_off" id="liTeamsCalendar"><a href="javascript:coviOrgTeams.TeamsTab(\'TeamsCalendar\')">' + orgDic["lbl_Teams_Schedule"] + '</a></li>';
		    html += ' 			        <li class="tabmenu_off" id="liTeamsTeam"><a href="javascript:coviOrgTeams.TeamsTab(\'TeamsTeam\')">' + orgDic["lbl_Teams_TeamManagement"] + '</a></li>';
		    html += ' 			        <li class="tabmenu_off" id="liTeamsChannel"><a href="javascript:coviOrgTeams.TeamsTab(\'TeamsChannel\')">' + orgDic["lbl_Teams_ChannelManagement"] + '</a></li>';
		    html += ' 			        <li class="tabmenu_off" id="liTeamsMember"><a href="javascript:coviOrgTeams.TeamsTab(\'TeamsMember\')">' + orgDic["lbl_Teams_TeamMemberManagement"] + '</a></li>';
		    html += ' 			      </ul>';
		    html += ' 			      <div id="divTeamsMessage">';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_Teams_GroupChatName"] + '</p>';
		    html += ' 			        <p class="mtxt"><input id="txtTeamsMessageTitle" type="text" maxlength="50"></p>';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_Teams_Message"] + '</p>';
		    html += ' 			        <p class="mtxt"><textarea name="txtTeamsMessageBody" id="txtTeamsMessageBody"></textarea></p>';
		    html += ' 			        <div class="mbtn_area">';
		    html += ' 			          <a style="cursor: pointer;" onclick="coviOrgTeams.TeamsMessage();"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2">' + orgDic["btn_Teams_Send"] + '</strong></span></em></a>';
		    html += ' 			        </div>';
		    html += ' 			      </div>';
		    html += ' 			      <div id="divTeamsCalendar" style="display:none;">';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_subject"] + '</p>';
		    html += ' 			        <p class="mtxt"><input id="txtTeamsCalendarTitle" type="text" maxlength="50"></p>';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_Contents"] + '</p>';
		    html += ' 			        <p class="mtxt"><textarea name="txtTeamsCalendarBody" id="txtTeamsCalendarBody"></textarea></p>';
		    html += ' 			        <div class="mbtn_area">';
		    html += ' 			          <a style="cursor: pointer;" onclick="coviOrgTeams.TeamsCalendar();"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2">' + orgDic["btn_Teams_ScheduleCreate"] + '</strong></span></em></a>';
		    html += ' 			        </div>';
		    html += ' 			      </div>';
		    html += ' 			      <div id="divTeamsTeam" style="display:none;">';
		    html += ' 			        <p class="mtxt"><select id="selTeamsTeamListByTeam" onchange="coviOrgTeams.selTeamsTeamListByTeam_OnChange()"></select></p>';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_Teams_TeamName"] + '</p>';
		    html += ' 			        <p class="mtxt"><input id="txtTeamsTeamDisplayName" type="text" maxlength="50"></p>';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_explanation"] + '</p>';
		    html += ' 			        <p class="mtxt"><input id="txtTeamsTeamDesc" type="text" maxlength="50"></p>';
		    html += ' 			        <div class="mbtn_area" >';
		    html += ' 			          <a id="aTeamsTeamCreate" style="cursor: pointer;" onclick="coviOrgTeams.SetTeamsTeam_Save(\'CREATE\');"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2">' + orgDic["lbl_Creation"] + '</strong></span></em></a>';
		    html += ' 			          <a id="aTeamsTeamUpdate" style="cursor: pointer;" onclick="coviOrgTeams.SetTeamsTeam_Save(\'UPDATE\');"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2">' + orgDic["lbl_Edit"] + '</strong></span></em></a>';
		    html += ' 			        </div>';
		    html += ' 			      </div>';
		    html += ' 			      <div id="divTeamsChannel" style="display:none;">';
		    html += ' 			        <div class="mtxtarea">';
		    html += ' 			          <p class="mtxt"><select id="selTeamsTeamListByChannel" onchange="coviOrgTeams.selTeamsTeamListByChannel_OnChange()"></select></p>';
		    html += ' 			          <p class="mtxt"><select id="selTeamsChannelList" onchange="coviOrgTeams.selTeamsChannelList_OnChange(false)"></select></p>';
		    html += ' 			        </div>';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_Teams_ChannelName"] + '</p>';
		    html += ' 			        <p class="mtxt"><input id="txtTeamsChannelDisplayName" type="text" maxlength="50"></p>';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_explanation"] + '</p>';
		    html += ' 			        <p class="mtxt"><input id="txtTeamsChannelDesc" type="text" maxlength="50"></p>';
		    html += ' 			        <div class="mbtn_area">';
		    html += ' 			          <a id="aTeamsChannelCreate" style="cursor: pointer;" onclick="coviOrgTeams.SetTeamsChannel_Save(\'CREATE\');"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2">' + orgDic["lbl_Creation"] + '</strong></span></em></a>';
		    html += ' 			          <a id="aTeamsChannelUpdate" style="cursor: pointer;" onclick="coviOrgTeams.SetTeamsChannel_Save(\'UPDATE\');"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2">' + orgDic["lbl_Edit"] + '</strong></span></em></a>';
		    html += ' 			        </div>';
		    html += ' 			      </div>';
		    html += ' 			      <div id="divTeamsMember" style="display:none;">';
		    html += ' 			        <p class="mtxt"><select id="selTeamsTeamListByMember" onchange="coviOrgTeams.selTeamsTeamListByMember_OnChange()"></select></p>';
		    html += ' 			        <p class="mtit">' + orgDic["lbl_Teams_TeamMember"] + '</p>';
		    html += ' 			        <div class="mtxt mselbox">';
		    html += ' 			          <div class="layer_searchlist_info2">';
		    html += ' 			            <ul class="layer_searchlist_info_l">';
		    html += ' 			              <li><input name="chkTeamsMemberAll" type="checkbox" id="chkTeamsMemberAll" class="input_check" style="cursor: pointer;" onclick="coviOrgTeams.chkTeamsMemberAll_OnClick();"> <label for="chkTeamsMemberAll" style="cursor: pointer;">' + orgDic["lbl_selectall"] + '</label></li>';
		    html += ' 			            </ul>';
		    html += ' 			          </div>';
		    html += ' 			          <div class="mbtn">';
		    html += ' 			            <a id="A1" style="cursor: pointer;" onclick="coviOrgTeams.SetTeamsTeamMember_Add()"><em class="btn_bs2_l"><span class="btn_bs2_r"><strong class="txt_btn2_bs">' + orgDic["btn_Add"] + '</strong></span></em></a>';
		    html += ' 			            <a id="A2" style="cursor: pointer;" onclick="coviOrgTeams.SetTeamsTeamMember_Delete()"><em class="btn_bs2_l"><span class="btn_bs2_r"><strong class="txt_btn2_bs">' + orgDic["btn_Delete"] + '</strong></span></em></a>';
		    html += ' 			          </div>';
		    html += ' 			          <div class="layer_selectlist_info_list1_cont layer_list">';
		    html += ' 			            <ul id="ulTeamsMemberList" style="margin-right:0px;"></ul>';
		    html += ' 			          </div>';
		    html += ' 			        </div>';
		    html += ' 			      </div>';
		    html += ' 			      <div style="height: 0px; overflow: hidden; display:none;">';
		    html += ' 			      	<input id="hidTeamsTeamId" type="hidden" />';
		    html += ' 			      	<input id="hidTeamsChannelId" type="hidden" />';
		    html += ' 			      </div>';
		    html += ' 			  </div>';
		}
		
		if($this.config.drawOpt.charAt(4) === 'B'){
			btnHtml += '<div class="popBtn">';
			if($this.config.type != "A0"){
				btnHtml += '	<input type="button" class="ooBtn ooBtnChk" onclick="coviOrg.returnData();" value="'+orgDic["btn_Confirm"]+'"/>'; /*확인*/ 
			}
			btnHtml += ' 	<input type="button" class="owBtn mr30" onclick="coviOrg.closeLayer();" value="'+orgDic["btn_Close"]+'"/>'; /*닫기*/ 
			btnHtml += '</div>';
		}
		html += '	</section>';
		
		if($this.config.targetID != ''){
			$("#"+$this.config.targetID).prepend(html);
			$("#"+$this.config.targetID).after(btnHtml);
		}
				
		
		var btnHeight = 0
		if($(".popBtn").length > 0){
			btnHeight = $(".popBtn").outerHeight();
		}
		
		var contHeight = '100%';
		//$(".appTree").css("height", "100%");
		//$(".appTreeTop").css("height", "auto");
		if ($this.config.allCompany == 'Y'){
			$("#companySelect").show();
		}
		else {
			$("appTreeTop div").hide();
		}
		if($this.config.treeKind.toUpperCase() == "GROUP"){
			$("#groupTypeSelect").show();
		}
		//$(".appTreeBot").css({
			//"height": "calc(100% - " + $(".appTreeTop").outerHeight() + "px)",
			//"margin-top": $(".appTreeTop").outerHeight() + (($(".appTreeTop").outerHeight() > 0) ? 5 : 0)
		//});
		
		//var listHeight = contHeight;
		//if ($(".appList_top_b").length > 0) {
		//	listHeight += ' - ' + $(".appList_top_b").outerHeight() + 'px - ' + $(".appList_top_b").css("margin-bottom");
		//}
		//$(".appList").css({
		//	"min-height": "calc(" + listHeight + ")",
		//	"max-height": "calc(" + listHeight + ")"
		//});
		//$(".appListBot").attr("style", "height: calc(100% - " + $(".appListTop").outerHeight() + "px) !important; margin-top:" + $(".appListTop").outerHeight() + "px !important;");
		
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
					typeof opener.parent.CFN_GetQueryString === "undefined" && (opener.parent.CFN_GetQueryString = CFN_GetQueryString);
					isAdmin = opener.parent.CFN_GetQueryString("CLMD");
				} else {
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
		}
	}
	
	//추가
	function addSelectedRow(type,dataObj)
	{
		var html = '';
		var TL = "";
		var PO = "";

		if(searchList == "bizCard"){
			html += "<tr>";
			html += "	<td><input type='checkbox' id='orgSelectedList_people"+ dataObj.BizCardType + "-" + dataObj.ShareType + "-" + dataObj.ID +"' name='"+CFN_GetDicInfo(dataObj.Name,lang)+"' value='"+ jsonToString(dataObj) +"'/></td>";
			html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.Name,lang) + '</td>';
			html += "</tr>";
		}else{
			if(type=="people"){
	  			html += '<li onmouseleave="coviOrgTeams.liSelected_OnMouseLeave(this);" onmouseover="coviOrgTeams.liSelected_OnMouseOver(this);" style="" class="">';
	    		html += "	<input type='checkbox' id='orgSelectedList_people" + dataObj.UserID + "' name='" + CFN_GetDicInfo(dataObj.DN,lang) + "' value='" + jsonToString(dataObj) + "' "+(dataObj.Dis?"disabled":"")+">";
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
	     
	   			if((PO=="-" && TL=="-") || (PO=="" && TL=="")){	 // 둘 다 없을 때
					html += '	<label style="cursor: pointer;" for="orgSelectedList_people'+ dataObj.UserID +'"><span id="spanTeamsPresenceSelected_' + dataObj.UserCode.toLowerCase() + '" class="pState pState06" title="' + Common.getDic("lbl_Teams_PresenceUnknown") + '" ></span><span class="txt_gn12">' + CFN_GetDicInfo(dataObj.DN,lang) + ' </span><span class="txt_gn11_blur3">(' + CFN_GetDicInfo(dataObj.RGNM,lang) +')</span></label></td>';
				}else if(PO=="-" || PO==""){	// 직급 없을 때 
					html += '	<label style="cursor: pointer;" for="orgSelectedList_people'+ dataObj.UserID +'"><span id="spanTeamsPresenceSelected_' + dataObj.UserCode.toLowerCase() + '" class="pState pState06" title="' + Common.getDic("lbl_Teams_PresenceUnknown") + '" ></span><span class="txt_gn12">' + CFN_GetDicInfo(dataObj.DN,lang) + " (" + TL + ') </span><span class="txt_gn11_blur3">(' + CFN_GetDicInfo(dataObj.RGNM,lang) +')</span></label></td>';
				}else if(TL=="-" || TL==""){	// 직책 없을 때
	    			html += '	<label style="cursor: pointer;" for="orgSelectedList_people'+ dataObj.UserID +'"><span id="spanTeamsPresenceSelected_' + dataObj.UserCode.toLowerCase() + '" class="pState pState06" title="' + Common.getDic("lbl_Teams_PresenceUnknown") + '" ></span><span class="txt_gn12">' + CFN_GetDicInfo(dataObj.DN,lang) + " (" + PO + ') </span><span class="txt_gn11_blur3">(' + CFN_GetDicInfo(dataObj.RGNM,lang) +')</span></label>';
				}else{
					html += '	<label style="cursor: pointer;" for="orgSelectedList_people'+ dataObj.UserID +'"><span id="spanTeamsPresenceSelected_' + dataObj.UserCode.toLowerCase() + '" class="pState pState06" title="' + Common.getDic("lbl_Teams_PresenceUnknown") + '" ></span><span class="txt_gn12">' + CFN_GetDicInfo(dataObj.DN,lang) + " (" + TL +", " + PO + ') </span><span class="txt_gn11_blur3">(' + CFN_GetDicInfo(dataObj.RGNM,lang) +')</span></label></td>';
				}
	    
	  			html += '</li>';
	  		}else if(type=="dept"){
	  			html += '<tr>';
	    		html += "	<td><input style='margin-right:3px;' type='checkbox' id='orgSelectedList_dept" + dataObj.GroupID + "' value='" + jsonToString(dataObj) + "'></td>";
	    		html += '	<td class="subject"><label for="orgSelectedList_dept'+ dataObj.UserID +'"><span class="txt_gn12">' + CFN_GetDicInfo(dataObj.DN,lang) + '</span><span class="txt_gn11_blur3">(' + CFN_GetDicInfo(dataObj.ETNM,lang) + ')</span></label></td>';
	    		html += '</tr>';
	 		}
		}
		
	  if( html != '' && (type == "people" || type=="dept") ){
	  	$("#ulSelectedAllUser").append(html); //type: people or dept
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
						return "";
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
					"onlyMyDept":$this.config.onlyMyDept
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
				
				 if (pMode != "schDept") {
					TL = isEmptyDefault(CFN_GetDicInfo(this.TL.split("|")[1],lang), "");
					PO = isEmptyDefault(CFN_GetDicInfo(this.PO.split("|")[1],lang), "");
					
					if(CFN_GetDicInfo(this.TL.split("|")[1],lang).charAt(0) == " "){
						TL = CFN_GetDicInfo(this.TL.split("|")[1],lang).replace(/ /gi, "");
					}
					
					if(CFN_GetDicInfo(this.PO.split("|")[1],lang).charAt(0) == " "){
						PO = CFN_GetDicInfo(this.PO.split("|")[1],lang).replace(/ /gi, "");
					}
				 }else{
					 PO = "-";
					 TL = "-";
				 }
				 
				 if (pMode == "schDept") {
					strData += "<tr type='dept' ondblclick='coviOrgTeams.contentDoubleClick(this)' draggable='true' ondragstart='coviOrg.void_ListItem_ondragstart(event);' ondragend='coviOrg.void_ListItem_ondragend(event);'>";
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
					strData += "<tr type='people' ondblclick='coviOrgTeams.contentDoubleClick(this)'>";
					
					if($this.config.type=="A0"){
						strData += "<td><a href='#none' class='cirPro'><img src='"+ coviCmn.loadImage(this.PhotoPath) +"' alt='' onerror='coviOrg.imgError(this);'></a></td>"
												
						if((TL=="-" && PO=="-") || (TL=="" && PO=="")){
							strData += "<td class='subject'><dl class='listBotTit'><dt onclick='coviOrg.goUserInfoPopup(\""+this.AN +"\")'>"+CFN_GetDicInfo(this.DN,lang) + " </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>"
						}else if(PO=="-" || PO==""){	// 직급 없을 때 
							strData += "<td class='subject'><dl class='listBotTit'><dt onclick='coviOrg.goUserInfoPopup(\""+this.AN +"\")'>"+CFN_GetDicInfo(this.DN,lang) + " ("+ TL + ")</dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>"
						}else if(TL=="-" || TL==""){	// 직책 없을 때 
							strData += "<td class='subject'><dl class='listBotTit'><dt onclick='coviOrg.goUserInfoPopup(\""+this.AN +"\")'>"+CFN_GetDicInfo(this.DN,lang) + " ("+ PO +") </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>"
						}else{
							strData += "<td class='subject'><dl class='listBotTit'><dt onclick='coviOrg.goUserInfoPopup(\""+this.AN +"\")'>"+CFN_GetDicInfo(this.DN,lang)+" ("+ TL +", " + PO +") </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
						}
						
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
								if((TL=="-" && PO=="-") || (TL=="" && PO=="")){
									strData += "<td class='subject'><dl class='listBotTit'><dt onClick='coviOrg.changeBackgroundColor(this)'>"+CFN_GetDicInfo(this.DN,lang)+ " </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
								}else if(PO=="-" || PO==""){	// 직급 없을 때
									strData += "<td class='subject'><dl class='listBotTit'><dt onClick='coviOrg.changeBackgroundColor(this)'>"+CFN_GetDicInfo(this.DN,lang)+ " (" + TL + ") </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
								}else if(TL=="-" || TL==""){	// 직책 없을 때
									strData += "<td class='subject'><dl class='listBotTit'><dt onClick='coviOrg.changeBackgroundColor(this)'>"+CFN_GetDicInfo(this.DN,lang)+ " (" + PO  +") </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
								}else{
									strData += "<td class='subject'><dl class='listBotTit'><dt onClick='coviOrg.changeBackgroundColor(this)'>"+CFN_GetDicInfo(this.DN,lang)+ " (" + TL +", " + PO  +") </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
								}
							}
							else {
								if((TL=="-" && PO=="-") || (TL=="" && PO=="")){
									strData += "<td class='subject'><dl class='listBotTit'><dt onclick='XFN_TeamsShowContextMenu(event, \""+this.UserCode +"\", \""+ this.UserCode + "@" + Common.getBaseConfig("M365Domain") +"\", \""+ this.EM +"\", \"\")'> <span id='spanTeamsPresence_" + this.UserCode.toLowerCase() + "' class='pState pState06' title=\"" + Common.getDic("lbl_Teams_PresenceUnknown") + "\" ></span>"+CFN_GetDicInfo(this.DN,lang)+ " </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
								}else if(PO=="-" || PO==""){	// 직급 없을 때
									strData += "<td class='subject'><dl class='listBotTit'><dt onclick='XFN_TeamsShowContextMenu(event, \""+this.UserCode +"\", \""+ this.UserCode + "@" + Common.getBaseConfig("M365Domain") +"\", \""+ this.EM +"\", \"\")'> <span id='spanTeamsPresence_" + this.UserCode.toLowerCase() + "' class='pState pState06' title=\"" + Common.getDic("lbl_Teams_PresenceUnknown") + "\" ></span>"+CFN_GetDicInfo(this.DN,lang)+ " (" + TL + ") </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
								}else if(TL=="-" || TL==""){	// 직책 없을 때
									strData += "<td class='subject'><dl class='listBotTit'><dt onclick='XFN_TeamsShowContextMenu(event, \""+this.UserCode +"\", \""+ this.UserCode + "@" + Common.getBaseConfig("M365Domain") +"\", \""+ this.EM +"\", \"\")'> <span id='spanTeamsPresence_" + this.UserCode.toLowerCase() + "' class='pState pState06' title=\"" + Common.getDic("lbl_Teams_PresenceUnknown") + "\" ></span>"+CFN_GetDicInfo(this.DN,lang)+ " (" + PO  +") </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
								}else{
									strData += "<td class='subject'><dl class='listBotTit'><dt onclick='XFN_TeamsShowContextMenu(event, \""+this.UserCode +"\", \""+ this.UserCode + "@" + Common.getBaseConfig("M365Domain") +"\", \""+ this.EM +"\", \"\")'> <span id='spanTeamsPresence_" + this.UserCode.toLowerCase() + "' class='pState pState06' title=\"" + Common.getDic("lbl_Teams_PresenceUnknown") + "\" ></span>"+CFN_GetDicInfo(this.DN,lang)+ " (" + TL +", " + PO  +") </dt><dd class='lGry'>"+CFN_GetDicInfo(this.RGNM,lang)+"</dd></dl></td>";
								}
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
		
		SetTeamsPresence();
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
					
					strData += "<tr type='bizcard' ondblclick='coviOrgTeams.contentDoubleClick(this)'>";
					strData += "<td style='height:20px !important;'><input type='checkbox' id='orgSearchList_bizcard_" + pType + "_" + oElm.ID +"' name='"+ oElm.Name.replace(/'/g, "＇") +"' value='"+ jsonToString(oElm).replace(/'/g, "＇") +"'/></td>";
					strData += "<td style='height:20px !important;' class='subject'>" + $("<div />").text(oElm.Name).html() + "</td>";
					strData += "</tr>";
				});
			}else{
				$(data.list).each(function(){
					this.DN = this.Name;
					this.EM = this.Email;
					strData += "<tr type='bizcard' ondblclick='coviOrgTeams.contentDoubleClick(this)'>";
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
			($('#changeGroupTree').parent()).attr("class", "");
			($('#changeBizCard').parent()).attr("class", "active");
		}else{
			$("#divSearchList_Main").show();
			$("#divSearchList_BizCard").hide();
			$("#searchdiv").show();
			$("#searchdiv_BizCard").hide();
			($('#changeGroupTree').parent()).attr("class", "active");
			($('#changeBizCard').parent()).attr("class", "");
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
	
	return coviOrgObj;
	
}());