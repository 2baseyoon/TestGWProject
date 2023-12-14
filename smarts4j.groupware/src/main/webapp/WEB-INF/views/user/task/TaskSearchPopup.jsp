<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/task.js"></script>

<style>
	.taskName { text-decoration: underline; cursor: pointer; }
	.bottom { text-align: center; }
</style>

<div class="divpop_contents" style="height:100%;">
	<div class="divpop_body" style="overflow:hidden; padding:0;">
		<div class="popContent popShare">
			<div class="middle">
				<div class="tblList tblCont">
					<div id="grid"></div>
				</div>
			</div>
			<div class="bottom">
				<a href="#" id="btnConfirm" class="btnTypeChk btnTypeDefault"><spring:message code="Cache.btn_Confirm"/></a> <!-- 확인 -->
				<a href="#" id="btnCancel" class="btnTypeDefault"><spring:message code="Cache.btn_Cancel"/></a> <!-- 취소 -->
			</div>
		</div>
	</div>
</div>

<script>
	var grid  = new coviGrid();
	var searchWord = CFN_GetQueryString("searchWord") == "undefined" ? "" : decodeURIComponent(CFN_GetQueryString("searchWord"));
	
	function init(){
		setEvent();
		setGrid();
	}
	
	function setEvent(){
		$("#btnCancel").click(function(){
			Common.Close();
		});
		
		$("#btnConfirm").click(function(){
			callBackPopup();
		});
	}
	
	function setGrid(){
		var headerData = [
			{key: 'chk', label:'chk', width:'5', align:'center', formatter: 'checkbox'},
			{key: 'TaskID', label:'TaskID', width:'5', align:'center', display: false},
			{key: 'FolderID', label:'FolderID', width:'5', align:'center', display: false},
			{key: 'Subject', label: '<spring:message code="Cache.lbl_workname" />', width:'50', align:'center' // 업무명
				, formatter: function(){
					var userCode = sessionObj["USERID"];
					var isOwner = (this.item.RegisterCode == userCode || this.item.OwnerCode == userCode)? "Y" : "N";
					
					return "<span class='taskName' onclick='openTaskPopup(\"" + this.item.FolderID + "\", \"" + this.item.TaskID + "\", \"" + isOwner + "\")'>" + this.item.Subject + "</span>";
				}
			}, 
			{key: 'TaskState', label: '<spring:message code="Cache.lbl_Status" />', width:'40', align:'center'}, // 상태
			{key: 'RegistDate', label: '<spring:message code="Cache.lbl_RegistDateHour" />', width:'50', align:'center'
				, formatter: function(){
					return new Date(CFN_TransLocalTime(this.item.RegistDate)).format("yyyy.MM.dd HH:mm:ss");
				}
			} // 등록일시
		];
		
		grid.setGridHeader(headerData);
		setGridConfig();
		selectGridList(searchWord);
	}
	
	function setGridConfig(){
		var configObj = {
			targetID: "grid",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height: "auto",
			page: {
				pageNo: 1,
				pageSize: 10,
			},
			paging: true,
			colHead: {},
			body: {}
		};
		
		grid.setGridConfig(configObj);
	}
	
	function selectGridList(pSearchWord){
		var params = {
			searchWord: pSearchWord
		};
		
		grid.page.pageNo = 1;
		
		grid.bindGrid({
			ajaxPars: params,
			ajaxUrl: "/groupware/task/selectTaskSearchList.do"
		});
	}
	
	function openTaskPopup(folderID, taskID, isOwner){
		parent.Common.open("", "TaskSet", "<spring:message code='Cache.lbl_task_taskManage' />", "/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner="+isOwner+"&taskID="+taskID+"&folderID="+folderID+"&isSearch=N", "950px", "650px", "iframe", true, null, null, true); // 업무관리
	}
	
	function callBackPopup(){
		var callBackFunc = CFN_GetQueryString("callBackFunc") == "undefined" ? "" : CFN_GetQueryString("callBackFunc");
		var checkedList = grid.getCheckedList(0);
		var returnVal = {};
		
		if(checkedList.length > 1){
			Common.Inform('<spring:message code="Cache.msg_SelectOne" />'); // 한개만 선택되어야 합니다
			return false;
		}else if(checkedList.length == 0){
			Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
			return false;
		}else{
			returnVal = {
				"TaskID": checkedList[0].TaskID,
				"FolderID": checkedList[0].FolderID
			}
		}
		
		if(callBackFunc != ""){
			try{
				callBackFunc = "parent.window."+callBackFunc+"("+JSON.stringify(returnVal)+")";
				new Function (callBackFunc).apply();
				Common.Close();
			}catch(e){
				console.error(e);
			}
		}
	}
	
	init();
</script>