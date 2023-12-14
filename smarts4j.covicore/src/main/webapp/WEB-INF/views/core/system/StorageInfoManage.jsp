<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.tte_StorageInfoManage"/></span>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input id="btnRefresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" />
			<input id="btnAdd" type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" />
			<input id="btnDelete" type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" />
		</div>
		<div id="topitembar02" class="topbar_grid">
			<span class="domain">
				<spring:message code="Cache.lbl_Domain"/>&nbsp;
				<select name="" class="AXSelect" id="selectDomain"></select>
			</span>
			<span id="diskTitle">Disk Size : </span>
			<span id="diskContents"></span>
		</div>
		<div id="storageInfoGrid"></div>
	</div>
</form>
<script type="text/javascript">	
	var grid;
	var headerData;
	var domain = document.getElementById("selectDomain");
	
	initContent();
	
	function initContent(){ 

		headerData =[
		             {key:'chk', label:'chk', width:'15', align:'center', formatter:'checkbox'},
		             {key:'DomainID',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'55', align:'center',
		            	 formatter:function(){
		            		 return CFN_GetDicInfo(this.item.MultiDisplayName); 
		            	 }},		            	 
		             {key:'ServiceType',  label:'<spring:message code="Cache.lbl_ServiceType"/>', width:'60', align:'center',
		            	 formatter:function () {
	            		 	return "<a href='#' onclick='update(\""+ this.item.StorageID +"\"); return false;'>"+this.item.ServiceType+"</a>";
            		 }},
		             {key:'LastSeq', label:'<spring:message code="Cache.lbl_FileCreateSeq"/>', width:'45', align:'center'},
            		 {key:'FilePath',  label:'<spring:message code="Cache.lbl_File"/> PATH', width:'100', align:'left'},
            		 {key:'InlinePath',  label:'<spring:message code="Cache.lbl_Inline"/> PATH', width:'110', align:'left'},
		             {key:'IsActive', label:'<spring:message code="Cache.lbl_isActive"/>',   width:'30', align:'center',
            			 formatter:function () {
			            		return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.StorageID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsActive+"' onchange='updateIsUse(\""+this.item.StorageID+"\");' />";
	      				}},
		             {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'100', align:'left'},	             
		             {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistrationDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'65', align:'center', sort:"desc", 
	      				formatter: function(){
	      					return CFN_TransLocalTime(this.item.RegistDate);
      					}, dataType:'DateTime'
     				 }
			      	];
		setGrid();			// 그리드 세팅
		setSelect();		// Select Box 세팅
		getDiskSize();		// disk 용량 셋팅
		getList();
		
		document.getElementById("btnRefresh").addEventListener("click", refresh);
		document.getElementById("btnAdd").addEventListener("click", add);
		document.getElementById("btnDelete").addEventListener("click", remove);
	};
	
	//그리드 세팅
	function setGrid(){
		grid = new coviGrid();
		grid.setGridHeader(headerData);
		grid.setGridConfig({
			targetID : "storageInfoGrid",
			height:"auto"
		});
	}
	
	function getList(){
		grid.page.pageNo = 1;		
		grid.bindGrid({
 			ajaxUrl:"/covicore/storage-info/list.do",
 			ajaxPars: {
 				"domain":domain.value
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function add(){
		openPopup("");
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function update(storageID){
		openPopup(storageID);
	}
	
	function openPopup(storageID){
		var popupWidth = "600px";
		var popupHeight = "410px";
		var mode = "add";
		var name = "";
		
		if(storageID){
			mode = "modify";
			name = Common.getDic("lbl_StorageInfoModify");
		} else {
			name = Common.getDic("lbl_StorageInfoCreation");
		}
		
		Common.open("","StorageInfoManagePopup", name,
				"/covicore/storage-info/popup.do?mode="+mode+"&storageID="+storageID,
				popupWidth,popupHeight,"iframe",false,null,null,true);
	}
	
	// 삭제
	function remove(){
		var deleteobj = grid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_CheckDeleteObject'/>");
			return;
		} else {
			var selStorageID = [];
			for(var i=0;i<deleteobj.length;i++){
				selStorageID.push(deleteobj[i].StorageID);
			}
			$.ajax({
				type:"DELETE",
				//data:JSON.stringify(deleteobj.map((x) => x.StorageID)), // ie지원불가
				data:JSON.stringify(selStorageID),
				contentType: 'application/json; charset=utf-8',
				url:"/covicore/storage-info/remove.do",
				success:function (data) {
					Common.Inform("<spring:message code='Cache.msg_DeleteResult'/>");
					grid.reloadList();
				},
				error:function(response){
					CFN_ErrorAjax("/covicore/storage-info/adremoved.do", response, response.status, response.statusText);
				}
			});
		}
	}
	
	// 새로고침
	function refresh(){
		$("#selectDomain").bindSelectSetValue('');	
		$("#selectBizSection").bindSelectSetValue('BizSection');
		$("#configtype").bindSelectSetValue('ConfigType');	
		
		getList();
		getDiskSize();	// disk 용량 셋팅
	}
	
	// 사용 스위치 버튼에 대한 값 변경
	function updateIsUse(storageID){
		var isUseValue = $("#AXInputSwitch"+storageID).val();
		$.ajax({
			type:"PATCH",
			url:"/covicore/storage-info/"+storageID+".do",
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/storage-info/"+storageID+".do", response, status, error);
			}
		});
	}
	
	// Select box 바인드
	function setSelect(){
		var lang = Common.getSession("lang");
		coviCtrl.renderDomainAXSelect('selectDomain', lang, 'getList', '', Common.getSession("DN_ID"), false);
	}
	
	//캐쉬적용
	function applyCache(){
		coviCmn.reloadCache("BASECONFIG", $("#selectDomain").val());
	}
	
	// disk 용량 가져오기
	function getDiskSize(){
		$.ajax({
			type:"GET",
			url:"/covicore/storage-info/getDiskSize.do",
	        dataType: 'json',
	        contentType: 'application/json; charset=utf-8',
			success:function (data) {
				if(data.info){
					var displaySize = "";
					var inUseSize = data.info.totalSize - data.info.freeSize;
					var inUseRatio = (inUseSize / data.info.totalSize).toFixed(3) * 100;
					displaySize = String.format(" {0} / {1} ({2}%)",ConvertFileSizeUnit(inUseSize), ConvertFileSizeUnit(data.info.totalSize), inUseRatio);
					$("#diskContents").text(displaySize);
				}
			},
			error:function(response){
				if(response.status === 400 && response.responseJSON){
					Common.Error(response.responseJSON);
				} else {
					CFN_ErrorAjax(url, response, response.status, response.statusText);
				}
			}
		});
	}
	
</script>