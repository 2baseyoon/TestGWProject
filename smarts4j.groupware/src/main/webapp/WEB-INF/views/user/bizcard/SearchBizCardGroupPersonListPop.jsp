<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	#gridDiv_AX_tbody tr td:first-child div{ text-overflow: unset; }
</style>
<div class="layer_divpop ui-draggable popBizGroupAdd" id="testpopup_p" style="width:550px; overflow-x: hidden;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div style="padding: 13px 24px 24px;">
			<span id="spnGroupName" style="font-weight: bold;"></span>
			<div class="tblList">
				<div id="gridDiv">
				</div>
			</div>
			
			<div class="popBtnWrap">
			  <a onclick="sendGroupMail('A');" href="#" id="btnSendMailWhole" class="btnTypeDefault btnThemeBg"><spring:message code='Cache.btn_Mail_whole' /></a>
			  <a onclick="sendGroupMail('S');" href="#" id="btnSendMailSelected" class="btnTypeDefault btnThemeBg"><spring:message code='Cache.btn_Mail_selected' /></a>
			  <a onclick="modifyGroupPop();" href="#" id="btnModify" class="btnTypeDefault"><spring:message code='Cache.btn_Edit' /></a>
			  <a onclick="closeLayer();" id="btnClose" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /></a>
			</div>
		</div>
	</div>
</div>

<script>
	//# sourceURL=SearchBizCardGroupPersonListPop.jsp
	var shareType = CFN_GetQueryString("ShareType");
	var groupID = CFN_GetQueryString("GroupID");
	var groupName = decodeURIComponent(CFN_GetQueryString("GroupName"));
	var parentPopupId = CFN_GetQueryString("PopupId");
	var bizCardGrid = new coviGrid();
	var headerData = new Array();
	
	initContent();

	// 설문 대상
	function initContent() {
	    $("body").css("overflow-x", "hidden");
		
		setLabel();
		setGrid();	// 그리드 세팅
		searchData();	// 검색
	}
	
	function setLabel() {
		$("#spnGroupName").text(groupName);
	}
	
	// 그리드 세팅
	function setGrid() {
		headerData =  headerData.concat([
   			         	{key:'chk', label:'<input type="checkbox" onclick="javascript: checkAll(this);">', width:'1', align:'center', sort : false, formatter:function(idx,obj){
				         		if(obj.EMAIL != ''){
				         			return '<input type="checkbox" name="checkbox" onclick="javascript: checkValue(this);" value="'+idx+'">';
				         		}else{
				         			return '<input type="checkbox" disabled="disabled" name="checkbox" style="background-color: #d9d9d9;">';
				         		}
				         }},
   			        	{key:'BizCardType', label:'BizCardType', align:'center', display:false, hideFilter:'Y'},
   			        	{key:'Name', label:'<spring:message code="Cache.lbl_Mail_Contact" />', width:'8', align:'left'},
   			        	{key:'EMAIL', label:'<spring:message code="Cache.lbl_memMail" />', width:'9', align:'left'},
		      		]);
		bizCardGrid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "gridDiv",
			height: "auto",
			page : {
				pageNo: 1,
				pageSize: 1000000
			},
			colHeadTool : false
		};
		
		bizCardGrid.setGridConfig(configObj);
	}

	// 검색
	function searchData() {
		var params = {
				 groupID : groupID,
				 hasEmail : 'F'
				};
		
		bizCardGrid.bindGrid({
			ajaxUrl : "/groupware/bizcard/getBizCardGroupMemberList.do",
			ajaxPars : params
		});
	}
	
	function sendGroupMail(pType) {
		if(Common.getBaseConfig("isUseExchMail") == "Y" && Common.getBaseConfig("isUseMail") == "Y"){
			var checkCheckList = "";
			
			if(pType == "A") {
				var checkCheckList = [{
					    "BizCardType": "Group",
					    "ShareType": "P",
					    "GroupID": groupID
					}]
			} else if(pType == "S") {
				// 그리드 선택된 사용자 메일 정보.
				var checkCheckList = bizCardGrid.getCheckedList(0);
				if(checkCheckList == 0){
					Common.Inform("수신인을 선택해주세요.", Common.getDic("CPMail_info_msg")); // 수신인을 선택해주세요.
					return;
				}
			}


			var isMail = false;		
			for(var i=0; i<checkCheckList.length; i++){
				var user = checkCheckList[i];
				if(user.EMAIL != "") {
					isMail = true;
				}
			}
			/*
			var popupId = "BizCard_MailWrite";

			// 팝업		
			window.open("/mail/bizcard/goMailWritePopup.do?"
					+ "callBackFunc=mailWritePopupCallback"
					+ "&callMenu="+"BizCard"
					+ "&userMail="+Common.getSession("UR_Mail")
					+ "&inputUserId="+Common.getSession().DN_Code + "_" + Common.getSession().UR_Code
					+ "&popup=Y"
					+ "&popupId="+popupId
					+ "&parentPopupId="+parentPopupId
					+ "&bizCardSendType="+pType
					+ "&bizCardGroupId="+groupID,
					popupId, "height=800, width=1000, resizable=yes");
			*/

			// 전송 데이터 세팅
				MailJsonData = {
				  "Token": GetEncryptToken(), // 인증용 JWT 토큰
				  "Subject": "", // 메일 제목
				  "Body": "", // 메일 본문
				  "To": excMailSet(checkCheckList), // 받는 사람
				  "Cc": [], // 참조
				  "Bcc": [], // 숨은 참조
				  "Attachment": [] // 첨부 파일
				};
				
				exch_mailSend(MailJsonData);
		} else {
			if(pType == "A") {
				
			} else if(pType == "S") {
				// 그리드 선택된 사용자 메일 정보.
	 			var checkCheckList = $('input:checkbox[name="checkbox"]:checked');
				if(checkCheckList == 0){
					Common.Inform("수신인을 선택해주세요.", Common.getDic("CPMail_info_msg")); // 수신인을 선택해주세요.
					return;
				}
			}
			
			var popupId = "BizCard_MailWrite";
			
			// 팝업		
			window.open("/mail/bizcard/goMailWritePopup.do?"
					+ "callBackFunc=mailWritePopupCallback"
					+ "&callMenu="+"BizCard"
					+ "&userMail="+Common.getSession("UR_Mail")
					+ "&inputUserId="+Common.getSession().DN_Code + "_" + Common.getSession().UR_Code
					+ "&popup=Y"
					+ "&popupId="+popupId
					+ "&parentPopupId="+parentPopupId
					+ "&bizCardSendType="+pType
					+ "&bizCardGroupId="+groupID,
					popupId, "height=800, width=1000, resizable=yes");
		}
	}
	
	function modifyGroupPop() {
		parent.modifyGroupPop(shareType, groupID);
		closeLayer();
	}
	
	function closeLayer() {
		Common.Close();
	}
	
	function checkAll(chkAll){
		var boxes = $("#gridDiv_AX_tbody input:enabled");
		for (var x = 0; x < boxes.length; x++) {
		    var obj = boxes[x];
		    if (obj.type == "checkbox") {
		      if (!obj.disabled){
		        obj.checked = chkAll.checked;
		      	checkValue(obj);
		      }
		    }
		}
	}
	
	//formatter:'checkbox' 미사용으로 getCheckedList 라이브러리에 있는 ___checked 속성과 동일하게 맞추기 위해 속성 추가
 	function checkValue(chk){
		var idx = parseInt(chk.value);
 		if(chk.checked == true){
 			return bizCardGrid.list[idx].___checked = {0:true};
 		}else{
 			return bizCardGrid.list[idx].___checked = {};
 		}
 	}
</script>
