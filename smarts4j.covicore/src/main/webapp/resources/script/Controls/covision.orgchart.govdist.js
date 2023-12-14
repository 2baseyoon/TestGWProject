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
/// [G9: 문서유통 공공기관 - 그룹 선택(3열-여러개)]

/// Tree 종류[TreeKind]
/// [Dept - 부서(부서 조직도만 필요시)]
/// [Group - 그룹(권한 설정, 사용자 검색 등) : 부서, 그룹(배포그룹 제외)]

/// </summary>
//# sourceURL=covision.orgchart.js
var coviOrgDist = (function () {
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
	var useAffiliateSearch = Common.getBaseConfig("useAffiliateSearch");
	
	var $this = coviOrgObj;
	var tmpSearchWord = "";
	var searchList = "groupTree";
	
	coviOrgObj.groupTree = new AXTree();
	
	coviOrgObj.config = {
			targetID: '',
			type:'G9',
			treeKind:'gov',
			drawOpt:'LM___', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
			callbackFunc: '', 
			openerID:'',
			allCompany: useAffiliateSearch,     /// 타 계열사 검색 허용 여부
			groupDivision: '',
			communityId: ''
	}; 
	
	
	coviOrgObj.imgError = function(image) {
	    image.onerror = "";
	    image.src = "/covicore/resources/images/no_profile.png";
//	    image.src = ProfileImagePath+"noimg.png";
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

		$(document).on("click", "a[id='changeGroupTree']", function(){
			searchList = "groupTree";
			changeMenu("groupTreeDiv");
		});		
	};

	coviOrgObj.returnData = function(){
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
    			//eval(  coviCmn.getParentFrame( $this.config.openerID )+$this.config.callbackFunc+"(makeOrgJsonData())"   );
				let oFrame = coviCmn.getParentFrameObj($this.config.openerID);
				if(jQuery.isFunction(oFrame[$this.config.callbackFunc])){
					oFrame[$this.config.callbackFunc].apply(this, [makeOrgJsonData()]);
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
		
		if($this.config.type=="C1"||$this.config.type=="C9"||$this.config.type=="G9"||$this.config.drawOpt.charAt(1)!="M")
			return ;
		
		var deptCode = nodeValue;
		var groupType = $("#groupTypeSelect").val()
		//DeptCode 가 최상위 GENERAL 이면 가운데 목록에 표시하지 않는다,.
		$("#selDeptTxt").text((deptCode=="GENERAL" ? "" : getGroupName(deptCode)));
		$("#allchk").attr("checked", false);

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
	
	coviOrgObj.sendRight = function(){
		if($this.config.drawOpt.charAt(3)!="R")
			return;
		
		var dupStr=""; //중복된 데이터
		var dataobj = "";
		
		var type = $("#orgSearchList tr:first-child").attr("type"); 
		var diffStr = (type == "dept" ? "orgSelectedList_dept" : "orgSelectedList_people") ;
		
		// 사원
		$("#orgSearchList input:checkbox").each(function() {
			if ($(this).is(":checked")) {
				var isOld = false;
				//dataobj =  eval("("+this.value+")");
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

		// 선택목록으로 이동후 체크박스 모두 해제
		$("#orgSearchList input:checkbox").each(function(){
			$(this).attr("checked", false);
		});
		
		$.each($this.groupTree.list,function(idx,obj){
			if(obj.__checked){
				$this.groupTree.updateTree(idx, obj, {__checked: false});
			}
		});
		
		$("input:checkbox[id^=groupTree]").each(function(idx,obj){
			$(obj).prop("checked",false)
		});

		$("#allchk").attr("checked", false);
		
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
	
	coviOrgObj.contentDoubleClick = function(){
		coviOrgObj.sendRight();
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
	}	
	
	//기본 HTML 바인딩
	function insertBasicHTML(){
		var html = '', btnHtml = '';

		//부서 및 그룹 트리 
		if($this.config.drawOpt.charAt(0) === 'L'){
			html += '			<div class="appTree" id="groupTreeDiv">';
			html += '				<div class="appTreeTop">';
			html += '					<select id="govReceiveGubun" class="treeSelect"></select>';
			html += '				</div>';			
			html += '				<div class="appTreeBot">';
			html += '					<div id="groupTree" style="height:100%;"></div>';
			html += '				</div>';
			html += '			</div>';
		}
		
		if($this.config.drawOpt.charAt(1) === 'M'){
				html += '			<div id="searchdiv" class="appList_top_b searchBox02">';
				html += '			<select id="searchType" class="j_appSelect">';
				html += '				<option value="govdept">' + orgDic["lbl_dept"] + '</option>';
				html += '			</select>';
				html += '			<input style="width: 192px;" type="text" autocomplete="off" placeholder="'+orgDic["msg_EnterSearchword"]+'" id="searchWorddist" name="inputSelector_onsearch"  data-axbind="selector"  ><a class="btnSearchType01" >'+orgDic["btn_apv_search"]+'</a>';
				html += '			</div>';
				html += '			<div id="divSearchList_Main" class="appList" style="overflow:hidden;">';
				html += '				<table class="tableStyle t_center hover appListTop" style="width:276px;">';
				html += '					<thead>';
				html += '						<tr>';
				html += '							<th>';
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
				html += ' 			<div class="appSel" style="margin-top:-40px">';
				html += '  				 <div class="selTop" style="height:475px!important;">';
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
				html += ' 			<div class="appSel" style="margin-top:-40px">';
				html += '				<div class="selTop" style="height:475px!important;">';
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
				html += ' 			<div class="appSel" style="margin-top:-40px">';
				html += '  				 <div class="selTop">';
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
				html += '				<div class="selBot">';
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
			}
		}
		
		if($this.config.drawOpt.charAt(4) === 'B'){
			btnHtml += '<div class="popBtn">';
			if($this.config.type != "A0"){
				btnHtml += '	<input type="button" class="ooBtn ooBtnChk" onclick="coviOrg.returnData();" value="'+orgDic["btn_Confirm"]+'"/>'; /*확인*/ 
			}
			btnHtml += ' 	<input type="button" class="owBtn mr20" onclick="coviOrg.closeLayer();" value="'+orgDic["btn_Close"]+'"/>'; /*닫기*/ 
			btnHtml += '</div>';
		}
		
		
		if($this.config.targetID != ''){
			$("#"+$this.config.targetID).addClass("appBox");
			$("#"+$this.config.targetID).prepend(html);
			$("#"+$this.config.targetID).after(btnHtml);
		}
		
		// TODO 디자인상 하드 코딩 향후 퍼블리싱 받은 후 지울것.
		if($this.config.treeKind.toUpperCase() == "GROUP"){
			$("#groupTree").css("height","390px");
			$(".appTreeBot").css("height","395px");
			$(".appTreeBot").css("margin-top","65px");
		}		
	}
	
	//Select 박스 바인딩 (회사 목록 및 검색 조건)
	function setSelect(){
		if($this.config.drawOpt.charAt(0) === "L"){
			var arrCom = new Array();
			arrCom.push({optionValue: "gov", optionText: "문서유통 수신처"});
			arrCom.push({optionValue: "gov24", optionText: "문서24 수신처"});
			
			//var receiveInfo = opener.document.getElementById("RECEIVEGOV_NAMES").value;
			if(CFN_GetQueryString("mode") == "OutreceviePopup"){
				var receiveInfo = window.parent.opener.document.getElementById("RECEIVEGOV_NAMES").value;
			}
			else{
				var receiveInfo = opener.document.getElementById("RECEIVEGOV_NAMES").value;
			}
			
			$("#govReceiveGubun").bindSelect({
				options: arrCom,
				setValue: receiveInfo.split(':')[0] == "1" ? 'gov24' :'gov',
				onchange:function () {
					setInitGroupTreeData("N"); //loadMyDept = "N"
				}
			});
		}
		if($this.config.drawOpt.charAt(1) === "M"){
			$("#searchWorddist").bindSelector({
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
				
					var word = $("#searchWorddist").val();
					setTimeout(function(){
						callBack({
							options:[
								{value:"name;"+word, text:"<b>"+orgDic["lbl_name"]+": <font color='#409CE5'>"+word+"</font></b>", desc: "-"+orgDic["lbl_com_searchByName"]}, //이름,  이름으로 찾기
							]
						});
					}, 000);
				},
				onChange:function(){
					search(this.selectedOption);
					$("#searchWorddist").val(tmpSearchWord);
				}
			});
	
			$('#searchWorddist').keydown(function(e) {
			    if (e.keyCode == 13) {
			    	search("govdeptName;"+$("#searchWorddist").val());
			    	
			    	$("#inputBasic_AX_searchWord_AX_Handle").attr("class","bindSelectorNodes AXanchorSelectorHandle");
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

		html += '<tr>';
		html += "	<td><input type='checkbox' id='orgSelectedList_dept" + dataObj.GroupID + "' value='" + jsonToString(dataObj) + "'></td>";
		html += '	<td class="subject">' + CFN_GetDicInfo(dataObj.DN,lang) + '<span class="lGry">(' + CFN_GetDicInfo(dataObj.ETNM,lang) + ')</span></td>';
		html += '</tr>';
		
		if( html != '' && (type == "people" || type=="dept") ){
			$("#orgSelectedList_"+type).append(html); //type: people or dept
		}
	}
	
	function setGroupTreeConfig(){
		var pid = "groupTree" //treeTargetID
		var treeHeight = ($this.config.treeKind.toUpperCase() == "GROUP" ? "395px" : "420px");	
			
		var func = { 		// 내부에서 필요한 함수 정의
				covi_setCheckBox : function(item){		// checkbox button
					if(item.chk == "Y") {
						return "<input type='checkbox' id='"+pid+"_treeCheckbox_"+item.no+"' name='treeCheckbox_"+item.no+"' value='"+jsonToString(item)+"' />";
					}else {
						return "<input type='checkbox' id='"+pid+"_treeCheckbox_"+item.no+"' name='treeCheckbox_"+item.no+"' value='"+jsonToString(item)+"' disabled='true' />";
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
		
		$this.groupTree.setConfig({
			targetID : "groupTree",					// HTML element target ID
			theme: "AXTree_none",		// css style name (AXTree or AXTree_none)
			height:treeHeight,
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
					var govReceiveGubun = $("#govReceiveGubun").val();
					if($this.config.type != "B1"&& $this.config.type!="B9" && $this.config.type!="A0"){
						str = govReceiveGubun == 'gov' ? func.covi_setCheckBox(this.item) + str : func.covi_setRadio(this.item) + str;
					}
					
					return str;
				}
			}],						// tree 헤드 정의 값
			body:bodyConfig									// 이벤트 콜벡함수 정의 값
		});
		
	}
	
	//그룹 트리 바인딩
	function setInitGroupTreeData(isloadMyDept){
		var domain = $("#companySelect").val();
		var groupType = $("#groupTypeSelect").val();
		var govReceiveGubun = $("#govReceiveGubun").val();

		setGroupTreeConfig();
		
		var sUrl = "/covicore/control/getGovOrgTreeList.do";
		
		$.ajax({
			url:sUrl,
			type:"POST",
			data:{
				"loadMyDept" : isloadMyDept,
				"companyCode" : domain,
				"groupType" : groupType,
				"groupDivision":$this.config.groupDivision,
				"communityId":$this.config.communityId,
				"govReceiveGubun" : govReceiveGubun
			},
			async:false,
			success:function (data) {
				$this.groupTree.setList( data.list );
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
		var groupType = $("#groupTypeSelect").val();
		var govReceiveGubun = $("#govReceiveGubun").val();
		
		var sUrl = "/covicore/control/getGovOrgTreeList.do";
		
		$.ajax({
			url:sUrl,
			type:"POST",
			data:{
				"memberOf" : item.AN,
				"companyCode" : domain,
				"groupType" : groupType,
				"groupDivision":$this.config.groupDivision,
				"communityId":$this.config.communityId,
				"govReceiveGubun" : govReceiveGubun
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
		params.govReceiveGubun = $("#govReceiveGubun").val();
		
		$("#allchk").attr("checked", false);
		
		url = "/covicore/control/getGovOrgTreeList.do";
		
		Common.Progress();
		$.ajax({
			url: url,
			type:"post",
			data: params,
			success:function (data) {
				setMemberList(data,"schDept");
				$("#selDeptTxt").text("");			// 조회된 후 선택부서TEXT 초기화
				
				Common.AlertClose();
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}		
	
	// 각 부서에 해당하는 사원들 리스트 HTML 바인딩
	function setMemberList(data,pMode){
		if($this.config.drawOpt.charAt(1)!="M")
			return;
		
		var strData = "";
		var strMsg;
		var govReceiveGubun = $("#govReceiveGubun").val();

		if(data.list.length == 0 || data.list.length == null)
			strMsg = orgDic["msg_NoDataList"] //조회할 목록이 없습니다.
		else{
			strMsg = "";

			$(data.list).each(function(){
				 var PO = "-";
				 var TL = "-";
				 
				 strData += "<tr type='dept' ondblclick='coviOrgDist.contentDoubleClick(this)'>";
				 if(govReceiveGubun == 'gov'){
					 strData += "<td style='height: 40px !important;'><input type='checkbox' id='orgSearchList_dept"+this.GroupID +"' name='"+this.DN +"' value='"+ Object.toJSON(this) +"'/></td>";
				 }else{
					 strData += "<td style='height: 40px !important;'><input type='radio' id='orgSearchList_dept"+this.GroupID +"' name='treeRadio' value='"+ Object.toJSON(this) +"'/></td>";
				 }				
				 strData += "<td colspan=\"2\" class='subject' style='height: 40px !important;'><dl class='listBotTit' style='margin: 0px;'><dt>"+this.DISPLAY_UCCHIEFTITLE + "</dt></dl></td>";
				
				 if($this.config.type=="A0"){
					 strData += "<td></td>";
					 strData += "<td></td>";
				 }
				 strData += "</tr>";
			});
		}
		document.getElementById("orgSearchListMessage").innerHTML = strMsg;
		document.getElementById("orgSearchList").innerHTML = strData;
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
		$('tr[class*=selected]').removeClass("selected");
		$('#selDeptTxt').empty();
		$('#selGroupTxt').empty();
		$('#orgSearchList').empty();
		$('#groupMailSearchList').empty();
		var appTree = $('#orgChart').find('div[class=appTree]');
		for(var i=0 ; i<appTree.length ; i++){
			if($(appTree[i]).attr('id') == param){
				$(appTree[i]).show();
			}else{                     
				$(appTree[i]).hide();
			}
		}
		
		$("#divSearchList_Main").show();
		$("#searchdiv").show();
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