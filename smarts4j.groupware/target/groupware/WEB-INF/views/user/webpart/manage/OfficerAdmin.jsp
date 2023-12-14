<%@page import="java.lang.ProcessBuilder.Redirect"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<form>
	<div id="content" style="padding:20px;">
		<h3 class="con_tit_box">
			<span class="con_tit"><spring:message code="Cache.lbl_executive_inform"/></span>
		</h3>
	
		<div style="width:100%;min-height: 500px">
			<div class="topbar_grid" style="display: flex;justify-content: space-between;">
				<div>
					<input type="button" value="<spring:message code="Cache.btn_UP"/>" onclick="moveUpOfficer(orgGrid);"class="AXButton BtnUp"/>	
					<input type="button" value="<spring:message code="Cache.btn_Down"/>" onclick="moveDownOfficer(orgGrid);"class="AXButton BtnDown"/>				
				</div>			
				<div>
					<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="AddOfficerPop('P', '', 'add',''); return false;" class="AXButton BtnAdd" />
					<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="DeleteOfficer(orgGrid);"class="AXButton BtnDelete"/>
				</div>
			</div>
				
			<!-- Grid -->
			<div id="resultBoxWrap">
				<div id="orgGrid"></div>
			</div>
		</div>
	</div>
</form>

<style>
	.con_tit_box{height:40px; padding-left:0px;}
	.con_tit_box .con_tit{font:normal 22px '맑은 고딕', Malgun Gothic,Apple-Gothic,dotum,돋움,sans-serif; color:#222; line-height:20px; padding-left:20px; background:url(/HtmlSite/smarts4j_n/covicore/resources/images/covision/zadmin/ico_collection.gif) no-repeat 0 -88px; }
</style>

<script>
	var orgGrid = new coviGrid();
	var isMailDisplay = true;

	window.onload = initContent();

	function initContent(){		
		
		$.ajaxSetup({
			cache : false
		});
		
		setGrid(); 
	}
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		orgGrid.setGridHeader([
							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
							  {key:'Sort',  label:"<spring:message code='Cache.lbl_Number'/>", width:'30', align:'center'}, //우선순위
			                  {key:'DisplayName',  label:"<spring:message code='Cache.lbl_DisplayName'/>", width:'70', align:'center'}, //표시이름
			                  {key:'JobTitleName',  label:"<spring:message code='Cache.lbl_JobTitle'/>", width:'70', align:'center'}, //직책
			                  {key:'Secretarys',  label:"<spring:message code='Cache.btn_charge'/>", width:'150', align:'center', formatter : function() { //사용여부
			                	    //var str =  '<span style="width:50px;height:20px;border:0px none;" id="Secretarys_';
			                	    var str = '<a href="#" style="text-decoration:underline;" onclick="EditOfficerPop(\''+ this.item.UserCode +'\'); return false;">'
			                  	    	str += getArrangement(this.item.Secretarys) + '</a>';
			                		return  str;
			                  }},
			                  {key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'70', align:'center', formatter : function() { //사용여부
			                	    var str =  '<input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;" id="AXInputSwitch_IsUse_';
			                  	    str += this.item.UserCode;
			                  	    str += '"  onchange="updateUseYN(\'' + this.item.UserCode +  '\');" value="' +  this.item.IsUse + '"/>';
			                		return  str;
			                  }},
			                  {key:'StateName', label:"<spring:message code='Cache.lbl_prj_taskStatus'/>", width:'70', align:'center', formatter : function() { //사용여부
			                	    var str =  '<span name=""  style="width:50px;height:20px;border:0px none;" >';
			                	    str += this.item.StateName;
			                	    str += '</span>';
			                		return  str;
			                  }},
			                  {key:'RegistDate',  label:'<spring:message code='Cache.lbl_RegDate'/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', formatter : function() {
			                	   var dateStr = this.item.RegistDate;
			                	   if(dateStr != ""){
				                	   return CFN_TransLocalTime(dateStr, "yyyy-MM-dd");
			                	   }else{
			                		   return "-";
			                	   }
			                   }}
				      		]);
		setGridConfig();
		bindGridData();
	}
	
	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "orgGrid",
			height:"auto",
			xscroll:true,
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			sort : false
		};
		
		// Grid Config 적용
		orgGrid.setGridConfig(configObj);
	}	

	function bindGridData() {	
		
		orgGrid.page.pageNo = 1;

		orgGrid.bindGrid({
			ajaxUrl:"/groupware/webpart/getOfficerListAdmin.do"
 		});
	}
		
	function onClickSearchButton(){
		bindGridData();
	}
	
	// 담당자 다국어 처리
	function getArrangement(pNames){
		var vResult = "";
		
		if (pNames.startsWith(';'))
			vResult = pNames.substring(1);
		
		if (pNames.endsWith(';'))
			vResult = vResult.substring(0, pNames.length - 2);
		
		return vResult.replace(/;/g ,',')
	}
	
	
	//임원 추가	
	function AddOfficerPop(){
		
		var title = "<spring:message code='Cache.btn_apv_RegDirector'/>";		
		
		Common.open("", "AddOfficerPop", title, "/groupware/webpart/goAddOfficerPopup.do?mode=add", "530px", "180px", "iframe", true, null, null, true);
		return;
	}
	
	//임원 추가	
	function EditOfficerPop(pUserCode){		
		var title = "<spring:message code='Cache.lbl_FixingIt'/>";	
		
		Common.open("", "AddOfficerPop", title, "/groupware/webpart/goAddOfficerPopup.do?mode=edit&code=" + pUserCode, "530px", "180px", "iframe", true, null, null, true);
		return;
	}
	
	
	
	//사용유무 변경 이벤트
	function updateUseYN(UserCode)
	{	
		$.ajax({
			type : "POST"
			, url : "/groupware/webpart/updateOfficerUse.do"
			, data : { "UserCode":UserCode , "IsUse":  $("#AXInputSwitch_IsUse_" + UserCode).val()}
			, success : function(data){
				if(data.status == "SUCCESS"){
					parent.Common.Inform("<spring:message code='Cache.msg_Edited'/>")	//수정되었습니다.
					parent.ExecutiveOffice.getOfficerList();					// 웹파트 새로고침
				} else { Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); }      //오류가 발생헸습니다.
			}
			, error : function(response, status, error){
	            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
	      	}
		});
	}
	

	//삭제
	function DeleteOfficer(uridObj) {

		var checkCheckList = uridObj.getCheckedList(0);// 체크된 리스트 객체
		var TargetIDTemp = []; // 체크된 항목 저장용 배열
		var TargetIDs = ""; // 체크된 항목을 문장으로 나열 (A;B; . . ;)

		if (checkCheckList.length == 0) {
			alert(Common.getDic("msg_apv_003")); // 선택된 항목이 없습니다.
		} else if (checkCheckList.length > 0) {

			for (var i = 0; i < checkCheckList.length; i++) {
				TargetIDTemp.push(checkCheckList[i].UserCode);
			}

			TargetIDs = TargetIDTemp.join(",");

			Common.Confirm( Common.getDic("msg_apv_093"), "Inform",
							function(result) {
								if (result) {
									$.ajax({
										url : "/groupware/webpart/deleteOfficer.do",
										type : "post",
										data : {
													"TargetIDs" : TargetIDs
												},
										async : false,
										success : function(res) {
											if(res.status == "FAIL") {
												Common.Warning(Common.getDic("msg_existGroupmember").replace("{0}",res.message));
											} else {
												parent.Common.Inform("<spring:message code='Cache.msg_50'/>")	//삭제되었습니다.
												uridObj.reloadList();
												parent.ExecutiveOffice.getOfficerList();												
											}
										},
										error : function(response, status, error) {
											CFN_ErrorAjax("/groupware/webpart/updateOfficerUse.do", response, status, error);
										}
									});
								}
							});
		} else {
			alert(Common.getDic("msg_ScriptApprovalError")); // 오류 발생
		}
	}
	
	
	// 위로 버튼 클릭시 실행되며, 해당 항목을 위로 이동합니다.
	function moveUpOfficer(uridObj) {

		var checkCheckList = uridObj.getCheckedList(0);// 체크된 리스트 객체
		if (checkCheckList.length == 0) {
			alert(Common.getDic("msg_apv_003")); // 선택된 항목이 없습니다.
		} else if (checkCheckList.length > 0) {

			var UserCode_A = 0;			
			var UserCode_B = 0;

			var oPrevTR = null;
			var oNowTR = null;

			var oResult = null;
			var bSucces = true;
			var sResult = "";
			var sErrorMessage = "";

			var nLength = uridObj.list.length;
			for (var i = 0; i < nLength; i++) {
				if (!uridObj.list[i].___checked[0]) {
					continue;
				}

				// 현재 행: 위에서부터 선택 되어 있는 행 찾기
				oNowTR = uridObj.list[i];

				// 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
				oPrevTR = null;
				for (var j = i - 1; j >= 0; j--) {
					if (uridObj.list[j].UserCode == undefined) {
						break;
					}
					if (uridObj.list[j].___checked[0]) {
						continue;
					}
					oPrevTR = uridObj.list[j];
					break;
				}
				if (oPrevTR == null) {
					continue;
				}

				UserCode_A = oNowTR.UserCode;
				UserCode_B = oPrevTR.UserCode;

				$.ajax({
					url : "/groupware/webpart/moveofficersort.do",
					type : "post",
					data : {
						"UserCode_A" : UserCode_A,
						"UserCode_B" : UserCode_B
					},
					async : false,
					success : function(res) {
						/* 방법 1 : 그리드 로드 */
						uridObj.reloadList();
					},
					error : function(response, status, error) {
						CFN_ErrorAjax("/groupware/webpart/moveofficersort.do",
								response, status, error);
						alert(Common.getDic("msg_ScriptApprovalError")); // 오류 발생
					}
				});// ajax
			}// for
		}// if
	}// func

	// 아래로 버튼 클릭시 실행되며, 해당 항목을 아래로 이동합니다.
	function moveDownOfficer(uridObj) {

		var checkCheckList = uridObj.getCheckedList(0);// 체크된 리스트 객체
		if (checkCheckList.length == 0) {
			alert(Common.getDic("msg_apv_003")); // 선택된 항목이 없습니다.
		} else if (checkCheckList.length > 0) {

			var UserCode_A = 0;			
			var UserCode_B = 0;

			var oNextTR = null;
			var oNowTR = null;

			var oResult = null;
			var bSucces = true;
			var sResult = "";
			var sTemp = "";
			var sErrorMessage = "";

			var nLength = uridObj.list.length;
			for (var i = nLength - 1; i >= 0; i--) {
				if (!uridObj.list[i].___checked[0]) {
					continue;
				}

				// 현재 행: 아래에서부터 선택되어 있는 행 찾기
				oNowTR = uridObj.list[i];

				// 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
				oNextTR = null;
				for (var j = i + 1; j < nLength; j++) {
					if (uridObj.list[j].UserCode == undefined) {
						break;
					}
					if (uridObj.list[j].___checked[0]) {
						continue;
					}
					oNextTR = uridObj.list[j];
					break;
				}
				if (oNextTR == null) {
					continue;
				}

				let UserCode_A = oNowTR.UserCode;
				let UserCode_B = oNextTR.UserCode;

				$.ajax({
					url : "/groupware/webpart/moveofficersort.do",
					type : "post",
					data : {
						"UserCode_A" : UserCode_A,
						"UserCode_B" : UserCode_B
					},
					async : false,
					success : function(res) {
						/* 방법 1 : 그리드 로드 */
						uridObj.reloadList();
					},
					error : function(response, status, error) {
						CFN_ErrorAjax("/groupware/webpart/moveofficersort.do",
								response, status, error);
						alert(Common.getDic("msg_ScriptApprovalError")); // 오류 발생
					}
				});// ajax
			}// for
		}// if
	}// func
	
</script>