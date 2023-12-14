<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_ExtDbSyncTargetMng"/></span>
</h3>
<form id="form_dbSyncTarget">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addSyncTarget(false);"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteSyncTarget();"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<span class=domain>
				<spring:message code="Cache.lbl_Domain"/>&nbsp;
				<select name="" class="AXSelect" id="selectDomain"></select>
			</span>
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchGrid();" class="AXButton"/>
		</div>
		<div id="gridarea"></div>
	</div>
</form>

<script type="text/javascript">
	var dbSyncTargetGrid;
	var headerData;

	initContent();
	
	function initContent(){ 
		dbSyncTargetGrid = new coviGrid();
		// 헤더 설정
		headerData =[
		             {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox'},
		             {key:'DomainName',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'70', align:'center'},
		             {key:'TargetSeq', label:'ID', width:'50', align:'center', display:false},
            		 {key:'TargetName',  label:'<spring:message code="Cache.lbl_name"/>', width:'100', align:'center',
							formatter:function () {
		            		 	return "<a href='#' onclick='updateSyncTarget(false, \""+ this.item.TargetSeq +"\"); return false;'>"+this.item.TargetName+"</a>";
		            		}},
		             {key:'ConnectionPoolName',  label:'Pool Name', width:'70', align:'center'},
		             {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'100', align:'center'},
		             {key:'SortSeq', label:'<spring:message code="Cache.lbl_Sort"/>',  width:'30', align:'center', sort:"asc"},
		             {key:'LastStatus', label:'Last Sync Status',  width:'60', align:'center'},
		             {key:'LastSyncTime', label:'Last Sync Time' + Common.getSession("UR_TimeZoneDisplay"),  width:'80', align:'center',
		            	  formatter:function(){
		            		  return CFN_TransLocalTime(this.item.LastSyncTime);
		            	  }	 
		             },
		             {key:'UseYn', label:'<spring:message code="Cache.lbl_Use"/>',   width:'55', align:'center',
		              	  formatter:function () {
			      				return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.TargetSeq+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.UseYn+"' onchange='updateIsUse(\""+this.item.TargetSeq+"\");' />";
			      			}},
		             {key:'Dummy', label:'Manual Execute.',   width:'55', align:'center',
		              	  formatter:function () {
			      				return "<button type='button' kind='' id='Button_Exe"+this.item.TargetSeq+"' style='width:50px;height:21px;' onclick='executeManual(\""+this.item.TargetSeq+"\");' ><spring:message code='Cache.btn_Execute'/></button>";
			      			}},
		             {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', 
				          formatter: function(){
			      			return CFN_TransLocalTime(this.item.ModifyDate);
			      		  }, dataType:'DateTime'
			      	  }
			      	];
		setGrid();			// 그리드 세팅
		setSelect();		// Select Box 세팅
		searchGrid();
	}
	//그리드 세팅
	function setGrid(){
		dbSyncTargetGrid.setGridHeader(headerData);
		
		dbSyncTargetGrid.setGridConfig({
			targetID : "gridarea",
			height:"auto"
		});
	}
	
	// baseconfig 검색
	function searchGrid(){
		var domain = document.getElementById("selectDomain").value;
		
		dbSyncTargetGrid.page.pageNo = 1;
		dbSyncTargetGrid.bindGrid({
			ajaxUrl:"/covicore/dbsync/getTargetList.do",
 			ajaxPars: {
 				"DomainID": domain
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addSyncTarget(pModal){
		parent.Common.open("","addbaseconfig","Add Target config","/covicore/dbsync/goExtDbTargetPopup.do?mode=add","600px","450px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateSyncTarget(pModal, TargetSeq){
		parent.Common.open("","updatebaseconfig","Modify Target config","/covicore/dbsync/goExtDbTargetPopup.do?mode=modify&TargetSeq="+TargetSeq,"600px","450px","iframe",pModal,null,null,true);
	}
	
	// 삭제
	function deleteSyncTarget(){
		var deleteobj = dbSyncTargetGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			var deleteSeq = "";
			for(var i=0; i<deleteobj.length; i++){
				if(i==0){
					deleteSeq = deleteobj[i].TargetSeq;
				}else{
					deleteSeq = deleteSeq + "," + deleteobj[i].TargetSeq;
				}
			}
			
			$.ajax({
				type:"POST",
				data:{
					"DeleteData" : deleteSeq
				},
				url:"/covicore/dbsync/delTarget.do",
				success:function (data) {
					if(data.result == "ok")
						Common.Inform("<spring:message code='Cache.msg_138'/>");
					dbSyncTargetGrid.reloadList();
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/dbsync/delTarget.do", response, status, error);
				}
			});
		}
	}
	
	// 새로고침
	function Refresh(){
		$("#selectDomain").bindSelectSetValue('');	
		searchGrid();
	}
	
	// 사용 스위치 버튼에 대한 값 변경
	function updateIsUse(TargetSeq){
		var isUseValue = $("#AXInputSwitch"+TargetSeq).val();
		
		$.ajax({
			type:"POST",
			data:{
				"TargetSeq" : TargetSeq,
				"UseYn" : isUseValue
			},
			url:"/covicore/dbsync/modifyUse.do",
			success:function (data) {
				if(data.status != "SUCCESS"){
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/dbsync/modifyUse.do", response, status, error);
			}
		});
	}
	
	function executeManual(TargetSeq) {
		if(!confirm("<spring:message code='Cache.msg_DbExeConfirm'/>")){//해당 테이블을 지금 동기화 하시겠습니까?
			return;
		}
		$.ajax({
			type:"POST",
			data:{
				"TargetSeq" : TargetSeq
			},
			url:"/covicore/dbsync/executeManual.do",
			success:function (data) {
				if(data.status != "SUCCESS"){
					if(data.message != null && data.message.length > 0) {
						Common.Warning(data.message);
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/dbsync/modifyUse.do", response, status, error);
			}
		});
	}
	
	// Select box 바인드
	function setSelect(){
		var lang = Common.getSession("lang");
		coviCtrl.renderDomainAXSelect('selectDomain', lang, 'searchGrid', '', '', true);
	}
	
</script>