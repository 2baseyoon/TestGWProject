<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>

<script>
	var m_oInfoSrc = opener;
	//var myDeptTree = new coviTree();
	var ListGrid = new coviGrid();
	
	var lang = Common.getSession("lang");
	
	var FormInstID = getInfo("FormInstanceInfo.FormInstID");
	var ProcessID = getInfo("ProcessInfo.ProcessID");
	var WorkItemID = getInfo("Request.workitemID");
	var usid = getInfo("AppInfo.usid");
	var usnm = getInfo("AppInfo.usnm");
	var dpid = getInfo("AppInfo.dpid");
	var dpdn = getInfo("AppInfo.dpdn");
	var FormName = getInfo("FormInfo.FormName");
	var FormPrefix = getInfo("FormInfo.FormPrefix");
	var Subject = getInfo("FormInstanceInfo.Subject");
	var InitiatorID = getInfo("FormInstanceInfo.InitiatorID");
	var ApvLineObj = getInfo("ApprovalLine");
	
	//JWF_CirculationBoxDescription
	var FormID = getInfo("ProcessInfo.ProcessDescription.FormID");
	var FormName = getInfo("ProcessInfo.ProcessDescription.FormName");
	var FormSubject = getInfo("ProcessInfo.ProcessDescription.FormSubject");
	var IsSecureDoc = getInfo("ProcessInfo.ProcessDescription.IsSecureDoc");
	var IsFile = getInfo("ProcessInfo.ProcessDescription.IsFile");
	var FileExt = getInfo("ProcessInfo.ProcessDescription.FileExt");
	var IsComment = getInfo("ProcessInfo.ProcessDescription.IsComment");
	var ApproverCode = getInfo("ProcessInfo.ProcessDescription.ApproverCode");
	var ApproverName = getInfo("ProcessInfo.ProcessDescription.ApproverName");
	var ApprovalStep = getInfo("ProcessInfo.ProcessDescription.ApprovalStep");
	var ApproverSIPAddress = getInfo("ProcessInfo.ProcessDescription.ApproverSIPAddress");
	var IsReserved = getInfo("ProcessInfo.ProcessDescription.IsReserved");
	var ReservedGubun = getInfo("ProcessInfo.ProcessDescription.ReservedGubun");
	//var ReservedTime = getInfo("ProcessInfo.ProcessDescription.ReservedTime")
	var Priority = getInfo("ProcessInfo.ProcessDescription.Priority");
	var IsModify = getInfo("ProcessInfo.ProcessDescription.IsModify");
	var Reserved1 = getInfo("ProcessInfo.ProcessDescription.Reserved1");
	var Reserved2 = getInfo("ProcessInfo.ProcessDescription.Reserved2");

	//JWF_CirculationBox
	var ReceiptID; //부서혹은사람ID
	var ReceiptType //부서면U 사람지정이면P( 클릭할 때 구분)
	var ReceiptName //부서혹은사람이름
	var Kind = "C";
	
	
	$(document).ready(function(){
		//setSelect();
		//setSearchSelect();
		//setTreeData();
		setOrgChart();
		
		setGrid();
	});
	
	function setOrgChart(){
		var config ={
				targetID: 'orgTargetDiv',
				drawOpt:'LMA__'
		};
		
		coviOrg.sendRight = setOrgSelectList;
		coviOrg.sendLeft = deleteOrgSelectList;
		
		coviOrg.render(config);
	}
	
	
    function setGrid(){
    	setGridHeader();
    	setListData();
    	setGridConfig();
    }
    
	function setGridHeader(){
		 var headerData =[{key:'chk', label:'chk', width: '5', align: 'center', formatter: 'checkbox', disabled:function(){
			 					var receiptDate = this.item.ReceiptDate;
			 					if(receiptDate != "" && receiptDate != null && receiptDate != undefined){
			 						return true;
			 					}else{
			 						return false;
			 					}
		 				   }},
		                  {key:'DeptName', label:"<spring:message code='Cache.lbl_dept'/>", width:'14', align:'center', formatter:function(){
		              		return CFN_GetDicInfo(this.item.DeptName);
		                  }}, //부서
					      {key:'ReceiptName', label:"<spring:message code='Cache.lbl_name'/>", width:'13', align:'center', formatter:function(){ //이름
					    	  if(this.item.ReceiptType == 'U'){
					    		  return '';
					    	  }else{
					    		  return CFN_GetDicInfo(this.item.ReceiptName);
					    	  }
					      }},						
		                  {key:'SenderName', label:"<spring:message code='Cache.lbl_apv_Distributer'/>",  width:'13', align:'center'}, //회람자
					      {key:'ReceiptDate', label:"<spring:message code='Cache.lbl_apv_senddate'/>",  width:'13', align:'center'}, //지정일자
					      {key:'ReadDate', label:"<spring:message code='Cache.lbl_ReceiptDate'/>",  width:'13', align:'center'}]; 	// 접수일자
		 
			
		 ListGrid.setGridHeader(headerData);		 
	}
	
	function setListData(){
		// 20210126 이관함에서 호출 기능 추가
		var fiid = FormInstID;
		if(CFN_GetQueryString("callType") == "List"){
			bstored = CFN_GetQueryString("bstored") == "true" ? "true" : "false";
		}else{
			bstored = opener.CFN_GetQueryString("bstored") == "true" ? "true" : "false";
		}
		if (bstored == "true") {
			fiid = opener.g_CirculationFiid.split(';').length == 2 ? opener.g_CirculationFiid.split(';')[0] : "";
		}
		
		ListGrid.bindGrid({
			ajaxUrl: "getExistingCirculationList.do",//조회 컨트롤러
			ajaxPars: {"FormIstID" : fiid,
				"Kind" : "C",
				"bstored" : bstored}
		});
	} 
	
	function setGridConfig(){
		var configObj = {
				targetID : "ListGrid",
				height:"245",
				listCountMSG:"<b>{listCount}</b> 개",
                page: {
                	display: false,
					paging: false
                },
                body:{
                	onclick:function(){
                		if(this.c == 1)
                			openFormDraft(this.list[this.index].FormID);
                	}
                }
		}
		
		ListGrid.setGridConfig(configObj);
	}
	
	var Comment="";
	function sendCirculation(){				
		Comment = $('#ideas').val();
		
		if(Comment.trim().length == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_161'/>"); //의견을 입력하세요.
			return;
		};
		
		if(ListGrid.getList("C,U").length == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_exitRol'/>"); //회람대상이 없습니다
			return;
		}	
		
		// 20210126 이관함에서 호출 기능 추가
		var fiid = FormInstID;
		var piid = ProcessID;
		if(CFN_GetQueryString("callType") == "List"){
			bstored = CFN_GetQueryString("bstored") == "true" ? "true" : "false";
		}else{
			bstored = opener.CFN_GetQueryString("bstored") == "true" ? "true" : "false";
		}
		
		
		if (bstored == "true") {
			if(CFN_GetQueryString("callType") == "List"){
				fiid = opener.g_CirculationFiid;
				piid = opener.g_CirculationPiid;
			}else{
				fiid = opener.g_CirculationFiid.split(';').length == 2 ? opener.g_CirculationFiid.split(';')[0] : "";
				piid = opener.g_CirculationPiid.split(';').length == 2 ? opener.g_CirculationPiid.split(';')[0] : "";
			}
		}
		
		$.ajax({
			type:"POST",
			data:
			{ 
				ListData : JSON.stringify(ListGrid.getList("C,U")),
				FormInstID : fiid,
				ProcessID : piid,
				usid : usid,
				usnm : usnm,
				dpid : dpid,
				dpdn : dpdn,
				FormName : FormName,
				Subject : Subject,
				FormID : FormID,
				FormPrefix : FormPrefix,
				FormName : FormName,
				FormSubject : FormSubject,
				IsSecureDoc : IsSecureDoc,
				IsFile : IsFile,
				FileExt : FileExt,
				IsComment : IsComment,
				ApproverCode : ApproverCode,
				ApproverName : ApproverName,
				ApprovalStep : ApprovalStep,
				ApproverSIPAddress : ApproverSIPAddress,
				IsReserved : IsReserved,
				ReservedGubun : ReservedGubun,
				Priority : Priority,
				IsModify : IsModify,
				Reserved1 : Reserved1,
				Reserved2 : Reserved2,
				Kind : Kind,
				Comment : Comment,
				bstored : bstored
			},
			async:true,
			url:"setCirculation.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					setListData();
					// 20210126 관리자 문서함에서 연 경우는 알림 발송 금지
					if (CFN_GetQueryString("callType") == "List") {
						Common.Inform("<spring:message code='Cache.msg_apv_alert_007'/>", "Information", function(){ //성공적으로 처리 되었습니다. 일괄회람시 알림은 가지 않습니다.
							Common.Close();
						});
					} else {
						sendCirculationMessage(data);
						Common.Inform("<spring:message code='Cache.msg_apv_alert_006'/>", "Information", function(){ //성공적으로 처리 되었습니다.
							Common.Close();
						});
					}
				} else {
					Common.Error(data.message);
					setListData();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("setCirculation.do", response, status, error);
			}
		});
	}
	
	function sendCirculationMessage(pData) {
		var MessageInfo = new Array();
		var sendList = ListGrid.getList("C,U");
		
		// 20210126 이관함에서 호출 기능 추가
		if(CFN_GetQueryString("callType") == "List"){
			bstored = CFN_GetQueryString("bstored") == "true" ? "true" : "false";
		}else{
			bstored = opener.CFN_GetQueryString("bstored") == "true" ? "true" : "false";
		}
		if (bstored == "true") {
			for (var idx = 0; idx < pData.list.length; idx++) {
				$(sendList).each(function(i, elm){
					var messageInfoObj = {};
					
					$$(messageInfoObj).attr("UserId", elm.ReceiptID);
					$$(messageInfoObj).attr("Subject", pData.list[idx].FormSubject);
					$$(messageInfoObj).attr("Initiator", pData.list[idx].InitiatorID);
					$$(messageInfoObj).attr("Status", "CIRCULATION");
					$$(messageInfoObj).attr("ProcessId", pData.list[idx].ProcessID);
					$$(messageInfoObj).attr("WorkitemId", "");
					$$(messageInfoObj).attr("FormInstId", pData.list[idx].FormInstID);
					$$(messageInfoObj).attr("FormName", pData.list[idx].FormName); 
					$$(messageInfoObj).attr("Type", (elm.ReceiptType == "P" ? "UR" : "GR"));
					$$(messageInfoObj).attr("ApvLineObj", null);
					
					$$(messageInfoObj).attr("ApproveCode", Common.getSession("UR_Code"));
					
					$$(messageInfoObj).attr("Comment", $('#ideas').val());
					$$(messageInfoObj).attr("Bstored", "true");
					
					MessageInfo.push(messageInfoObj);
				});
			}
		} else {
			$(sendList).each(function(i, elm){
				var messageInfoObj = {};
				
				$$(messageInfoObj).attr("UserId", elm.ReceiptID);
				$$(messageInfoObj).attr("Subject", Subject);
				$$(messageInfoObj).attr("Initiator", InitiatorID);
				$$(messageInfoObj).attr("Status", "CIRCULATION");
				$$(messageInfoObj).attr("ProcessId", ProcessID);
				$$(messageInfoObj).attr("WorkitemId", WorkItemID);
				$$(messageInfoObj).attr("FormInstId", FormInstID);
				$$(messageInfoObj).attr("FormName", FormName); 
				$$(messageInfoObj).attr("Type", (elm.ReceiptType == "P" ? "UR" : "GR"));
				$$(messageInfoObj).attr("ApvLineObj", ApvLineObj);
				$$(messageInfoObj).attr("ApproveCode", usid);
				$$(messageInfoObj).attr("SenderID", usid);
				$$(messageInfoObj).attr("Comment", Comment);
				
				MessageInfo.push(messageInfoObj);
			});
		}
		
		$.ajax({
    		url:"/approval/legacy/setmessage.do",
    		data: {
    			"MessageInfo" : JSON.stringify(MessageInfo)
    		},
    		type:"post",
    		dataType : "json",
    		async: false,
    		success:function (res) {
    		},
    		error:function(response, status, error){
				CFN_ErrorAjax("legacy/setmessage.do", response, status, error);
			}	
    	});
	}
	
	
	function addGridRow(DeptID, DeptName, URID, URName){		
		var dup = false ;
		 
		$(ListGrid.list).each(function(idx,obj){
			if(URID == undefined && obj.ReceiptID == DeptID && obj.ReceiptType == 'U'){
				dup = true;
				return false; //break;
			}else if(URID == obj.ReceiptID && obj.ReceiptType=='P'){
				dup = true;
				return false;  //break;
			}
		});
		
		if(dup){				
			var msgStr = DeptName;
			
			if(URName)
				msgStr = URName;
			
			Common.Warning(CFN_GetDicInfo(msgStr) + "<spring:message code='Cache.msg_AlreadyAdd'/>");	//은(는) 이미 추가 되었습니다		
		}
		else {
			var type = URID == undefined? 'U' : 'P';  
			if(type =='U'){
				ListGrid.pushList({DeptID : DeptID, DeptName : DeptName, ReceiptID : DeptID, ReceiptName : DeptName, SenderName : usnm, ReceiptType:type});
			}else{
				ListGrid.pushList({DeptID : DeptID, DeptName : DeptName, ReceiptID : URID, ReceiptName : URName, SenderName : usnm, ReceiptType:type});
			}
		}
	}
	
	function setOrgSelectList(){
		var chkList = coviOrg.groupTree.getCheckedTreeList('checkbox');

		$.each(chkList, function(i, item){
			addGridRow(item.AN, item.DN);
		});
		
		$('#orgSearchList input[type=checkbox]:checked').each(function(){
			var item = JSON.parse($(this).val());
			
			if (item.itemType == "user") {
				addGridRow(item.RG, item.RGNM, item.AN, item.DN);			
			} else {
				addGridRow(item.AN, item.DN);
			}
		});
		
		$('#orgSearchList input[type=checkbox]').prop('checked',false);
		$("input:checkbox[id^=groupTree]").prop('checked',false); 
		$("#allchk").attr("checked", false);
	}
	
	function deleteOrgSelectList(){
		ListGrid.removeListIndex(ListGrid.getCheckedListWithIndex(0));
	}
	
	function removeCheckedList(){
		 var checkedList = ListGrid.getCheckedList(0);// colSeq
         
		 if(checkedList.length == 0){
             Common.Warning("<spring:message code='Cache.msg_Common_03'/>");    //삭제할 항목을 선택하여 주십시요.
             return;
         }
		         
         var removeList = [];
         $.each(checkedList, function(){
	             removeList.push({ReceiptID:this.ReceiptID});
         });
         
         ListGrid.removeList(removeList);
	}
	
	function removeAll(){
		var v = getInfo("ProcessInfo.ProcessDescription.ApproverCode");		
		
		ListGrid.reloadList();
	}
	
	function getCheckedAll(){} //전체선택 함수 미구현 오류방지
</script>

<div class="divpop_contents">
   <!-- 팝업 Contents 시작 -->
   <div id="orgTargetDiv" class="appBox">
   
  	 <!-- 트리 및 사용자 리스트 버튼 영역은 공통 조직도에서 처리 -->
  	 
 	 <!-- 회람 지정 화면 우측 시작 -->
     <div class="appSel" style="margin-top: -40px;">
       <div class="selTop">
         <table class="tableStyle t_center hover infoTableBot">
           <colgroup>
           <col style="width:50px">
           <col style="width:*">
           </colgroup>
           <thead>
             <tr>
               <td colspan="2"><h3 class="titIcn"><spring:message code='Cache.lbl_apv_circulation_list'/></h3>
               <input type="button" value="<spring:message code='Cache.btn_delete'/>" class="smButton" onclick="removeCheckedList();" style="margin-left: 4px;float:right;"/>
               <input type="button" value="<spring:message code='Cache.btn_DelAll'/>" class="smButton" onclick="removeAll();" style="float:right"/>
               </td>
             </tr>
           </thead>
         </table>
         <div class="coviGrid">
         <div id="ListGrid"></div>
         </div>
       </div>
       <div class="selBot" style="overflow:hidden;">
         <table class="tableStyle t_center hover infoTableBot">
           <colgroup>
           <col style="width:50px">
           <col style="width:*">
           </colgroup>
           <thead>
             <tr>
               <td colspan="2"><h3 class="titIcn"><spring:message code='Cache.lbl_apv_comment'/></h3></td>
             </tr>
           </thead>
           <tbody id="orgSelectList_dept">
           </tbody>
         </table>
         <div class="cirTextDiv">
         	<textarea id="ideas" name="ideas" style="resize:none;"></textarea>
         </div>
       </div>
     </div>
     <!-- 회람 지정 화면 우측 끝 -->
   </div>
   <!-- 팝업 Contents 끝 -->
   
   <!-- 하단버튼 시작 -->
   <div class="popBtn"> 
	     <input type="button" class="ooBtn" onclick="sendCirculation();" value="<spring:message code='Cache.btn_Circulation_Confirm'/>"/> <!--회람지정-->
	     <input type="button" class="owBtn mr20" onclick="Common.Close();" value="<spring:message code='Cache.btn_Cancel'/>"/><!--취소--> 
	 </div>
   <!-- 하단버튼 끝 -->
</div>
</html>
