<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<spring:message code="Cache.lbl_ResourceApvStatus"/> <!-- 자원승인현황 -->
		<span id="resourceName"></span>
	</h2> 
	<div class="searchBox02">
		<span><input type="text" id="searchText"><button type="button" class="btnSearchType01" id="icoSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div id="topitembar03" class="inPerView type02 sa04">
		<div>
			<div class="selectCalView">
				<spring:message code="Cache.lbl_Res_Status"/> <!--예약상태-->
				<span id="bookingStateSelectList"></span>
			</div>	
			<div class="selectCalView">
				<select id="searchTypeSelect" class="selectType02">
					<option value="Description"><spring:message code="Cache.lbl_Purpose"/></option> <!-- 용도 -->
					<option value="RegisterName"><spring:message code="Cache.lbl_Applicator"/></option> <!-- 신청자 -->
				</select>
				<input name="search" type="text" id="search"/> 
			</div> 
			<div class="selectCalView">
				<spring:message code="Cache.lbl_Booking_Date"/> <!-- 예약일시  -->
				<input id="startDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate">
				 ~ 
				<input id="endDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate">
			</div>
			<div class="selectCalView">
				<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
	</div>
	<form id="form1">
		<div class="sadminTreeContent">
			<div class="AXTreeWrap">
				<div class="searchBox02" style="margin: 10px 0px -20px 30px;">
					<span>
						<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_IsAll" value="Y" ><label for="chk_IsAll"><span class="s_check"></span><spring:message code='Cache.btn_All' /></label> </div>
						<input type="text" id="treeSearchText" class="w80">
						<button type="button" class="btnSearchType01" id="treeSearchBtn"><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
					</span>
				</div>
				<div id="resourceTree" class="tblList tblCont" style="width:300px;"></div>
			</div>
			<div>
				<div class="sadminContent">
					<div class="sadminMTopCont">
						<div class="pagingType02 buttonStyleBoxLeft" style="min-height: 33px;">
							<a id="approval" class="btnTypeDefault" onclick="approvalBooking()"><spring:message code="Cache.lbl_Approval"/></a> <!--승인-->
							<a id="reject" class="btnTypeDefault" onclick="rejectBooking()"><spring:message code="Cache.lbl_Reject"/></a> <!--거부-->
							<a id="cancelApproval" class="btnTypeDefault" onclick="cancelBooking()"><spring:message code="Cache.lbl_CancelApproval"/></a> <!--승인취소-->
							<a id="confirmReturn" class="btnTypeDefault" onclick="returnBooking()"><spring:message code="Cache.lbl_CheckReturn"/></a> <!--반납확인-->
							<a id="del" class="btnTypeDefault" onclick="deleteBooking()"><spring:message code="Cache.btn_delete"/></a> <!--삭제-->
						</div>
						<div class="buttonStyleBoxRight">
							<select id="selectPageSize" class="selectType02 listCount">
								<option value="10">10</option>
								<option value="20">20</option>
								<option value="30">30</option>
							</select>
							<button id="btnRefresh" class="btnRefresh" type="button" href="#"></button>
						</div>
						<div id="bookingGrid" class="tblList tblCont"></div>
					</div>
				</div>
			</div>
		</div>
	</form>
</div>

<script type="text/javascript">
	var confResource = {
		resourceTree: '',
		bookingGrid: new coviGrid(),
		lang: Common.getSession("lang"),
		headerData:	[{
			key: "FolderName",			// 컬럼에 매치될 item 의 키
 			indent: true,				// 들여쓰기 여부
 			label: '<spring:message code="Cache.lbl_CategoryResourceName"/>',
 			width: "170",
			align: "left",		
 			getIconClass: function(){	// indent 속성 정의된 대상에 아이콘을 지정 가능
				var sRetIcon= this.item.FolderType.indexOf("Resource") == 0?"ic_file ":"ic_folder ";
				if (this.item.IsUse == "N" || this.item.IsDisplay == "N") sRetIcon += "icon02";
				return sRetIcon;
 			},
 			formatter: function(){
				var html = "<a ";
				
				if (this.item.FolderType.indexOf("Resource") > -1) {
					html+=" class='alink'";
				}
				
				html += ">" + this.item.FolderName + "</a>";
				html += "<a href='#' class='newWindowPop' onclick='modifyFolderPopup(\""+this.item.FolderID+"\",\""+this.item.MemberOf+"\", \""+this.item.FolderType+"\")'></a>";
				
				return html;
			}
		}],
		setEvent: function(){
			$("#chk_IsAll").click(function(){
				confResource.setTreeData();
			});

			//검색
			$("#treeSearchText").on('keydown', function(){
				if(event.keyCode == "13"){
					event.preventDefault();
					$('#treeSearchBtn').trigger('click');
				}
			});
			
			$("#treeSearchBtn").on('click', function(){
				var keyword = $("#treeSearchText").val();
				if (keyword =="") {
					confResource.setTreeData();
					return;
				}
				
				/* 엔터나 클릭을 이용해 검색조건에 맞는 폴더나 자원을 탐색하면서 해당 폴더, 자원에 대한 승인현황들을 조회 */ 
				var curIdx = Number(confResource.resourceTree.selectedRow)+1;
				confResource.resourceTree.findKeywordData("FolderName", keyword, true, false, curIdx);
				
				coviInput.setSwitch();
			});

			// 검색
			$("#searchText, #search").on('keydown', function(){
				if(event.keyCode == "13"){
					$('#icoSearch').trigger('click');
				}
			});
			
			$("#icoSearch, #btnSearch").on('click', function(){
				if (confResource.resourceTree.selectedRow[0]) {
					var selItem = confResource.resourceTree.list[confResource.resourceTree.selectedRow[0]];
					
					confResource.setBookingGridList(selItem.FolderID, selItem.FolderName);
				}
			});
			
			$("#bookingStateSelect").on('change', function(){
				if (confResource.resourceTree.selectedRow[0]) {
					var selItem = confResource.resourceTree.list[confResource.resourceTree.selectedRow[0]];
					
					confResource.setBookingGridList(selItem.FolderID, selItem.FolderName);
				}
			});
			
			// 상세 검색
			$('.btnDetails').off('click').on('click', function(){
				var mParent = $('.inPerView');
				if(mParent.hasClass('active')){
					mParent.removeClass('active');
					$(this).removeClass('active');
				}else {
					mParent.addClass('active');
					$(this).addClass('active');
				}
				coviInput.setDate();
			});
			
			// 새로고침
			$("#btnRefresh").on('click', function(){
				if (confResource.resourceTree.selectedRow[0]) {
					var selItem = confResource.resourceTree.list[confResource.resourceTree.selectedRow[0]];
					
					confResource.setBookingGridList(selItem.FolderID, selItem.FolderName);
				}
			});
			
			$("#selectPageSize").on('change', function(){
				confResource.setBookingGridConfig();
				$("#btnRefresh").trigger("click");
			});
		},
		initContent: function(){
			this.setBookingGridConfig();
			this.resourceTree = new coviTree();
			this.resourceTree.setConfig({
				targetID : "resourceTree",	// HTML element target ID
				theme: "AXTree_none",
				colGroup:this.headerData,	// tree 헤드 정의 값
				relation:{
					parentKey: "MemberOf",	// 부모 아이디 키
					childKey: "FolderID"	// 자식 아이디 키
				},
				persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
				persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				colHead: {
					display: false
				},
				showConnectionLine: true,	// 점선 여부
				body:{
			        onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
			        	if (item.FolderType.indexOf("Resource") > -1) {
							confResource.setBookingGridList(item.FolderID,item.FolderName);
						}
			        }}
			});
			
			$("#bookingStateSelectList").html(coviCtrl.makeSelectData(Common.getBaseCode("ApprovalState")["CacheData"], {hasAll:true,id:"bookingStateSelect",defaultVal:""}, this.lang));
			this.setEvent();
			
			confResource.setTreeData();
		},
		setTreeData: function(){
			$.ajax({
				url: "/groupware/resource/manage/getFolderResourceTreeList.do",
				type: "POST",
				data: {
					"domainID": confMenu.domainId,
					"isAll":$("#chk_IsAll").prop("checked")?"Y":"N"
				},
				async: false,
				success: function(data){
					var List = data.list;
					confResource.resourceTree.setList(List);
					confResource.resourceTree.expandAll(1);	
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/manage/getFolderResourceTreeList.do", response, status, error);
				}
			});
		},
		setBookingGridConfig: function(){
			this.bookingGrid.setGridHeader([
				{key:'chk', label:'chk', width:'3', align:'center', formatter: 'checkbox'},
				{key:'Subject', label:'<spring:message code="Cache.lbl_Purpose"/>', width:'30'}, // 용도
				{key:'StartDateTime', label:'<spring:message code="Cache.lbl_BookingStartDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'12', align:'center'}, // 예약시작일시
				{key:'EndDateTime', label:'<spring:message code="Cache.lbl_BookingEndDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'12', align:'left' }, // 예약종료일시
				{key:'ApprovalState', label:'<spring:message code="Cache.lbl_Res_Status"/>', width:'7', align:'center'}, // 예약상태
				{key:'RegisterName', label:'<spring:message code="Cache.lbl_Applicator"/>', width:'7', align:'center'}, // 신청자
				{key:'RegistDate', label:'<spring:message code="Cache.lbl_Application_Day"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', // 신청일
					formatter: function(){
						return CFN_TransLocalTime(this.item.RegistDate);
					}
				}

			]);
			
			this.bookingGrid.setGridConfig({
				targetID: "bookingGrid",
				listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
				height: "auto",
				page: {
					pageNo: 1,
					pageSize: $("#selectPageSize").val()
				},
				paging: true,
				colHead: {},
				body: {}
			});
		},
		setBookingGridList: function(pFolderID, pFolderName){
			var searchWord = $("#search").val() ? $("#search").val() : $("#searchText").val();
			
			$("#resourceName").text("- " + pFolderName);
			
			this.bookingGrid.bindGrid({
				ajaxUrl:"/groupware/resource/manage/getBookingOfResourceList.do",
				ajaxPars: {
					"folderID": pFolderID,
					"bookingState": $("#bookingStateSelect").val(),
					"searchType": $("#searchTypeSelect").val(),
					"searchWord": searchWord,
					"startDate": ($("#startDate").val() != '') ? CFN_TransServerTime($("#startDate").val() + ' 00:00') : '',
					"endDate": ($("#endDate").val() != '') ? CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays($("#endDate").val(), 1),'-') + ' 00:00') : ''
				},
			});
		}
	}
	
	$(document).ready(function(){
		confResource.initContent();
	});
	
	function refresh(){
		confResource.setTreeData();
		if (confResource.resourceTree.selectedRow[0]) {
			var selItem = confResource.resourceTree.list[confResource.resourceTree.selectedRow[0]];
			
			confResource.setBookingGridList(selItem.FolderID, selItem.FolderName);
		}
	}
	
	// 폴더 수정 레이어 팝업
	function modifyFolderPopup(folderID, parentFolderID, folderType){
		var url = "/groupware/resource/manage/goResourceManagePopup.do";
		url += "?domainID=" + confMenu.domainId;
		url += "&parentFolderID=" + parentFolderID;
		url += "&folderID=" + folderID;
		url += "&folderType=" + folderType;
		
		Common.open("","divResourceInfo","<spring:message code='Cache.lbl_ResourceManage_09'/>|||<spring:message code='Cache.msg_ResourceManage_09'/>",url,"600px","600px","iframe",true,null,null,true);
	}
	
	// 승인/거부/승인취소/반납확인 버튼 클릭시 실행되며, 선택한 항목에 대하여 처리를 합니다.
	function setApprovalState(dateIDs, state, comment){
		var idx = $("#resourceTree .gridBodyTr").index($("#resourceTree .gridBodyTr.selected"));
		var selectedItem = confResource.resourceTree.list[idx];
		
		$.ajax({
			url: "/groupware/resource/manage/modifyBookingState.do",
			type: "post",
			data: {
				DateID : dateIDs,
				ResourceID: selectedItem.FolderID,
				ApprovalState: state,
				comment: comment
			},
			success: function(data){
				if(data.status =='SUCCESS'){
					var warMsg = '';
					
					$.each(data.result,function(idx,obj){
						if(obj.retType != 'SUCCESS'){
							warMsg += obj.DateID + ": " + obj.retMsg +"\n";
						}
					});
					if(warMsg){
						Common.Warning(warMsg + "\n<spring:message code='Cache.msg_noProcessList'/>", "Warning", function(){ // 위 항목은 제외하고 처리되었습니다.
							confResource.bookingGrid.reloadList();
						});
					}else{
						Common.Inform("<spring:message code='Cache.msg_Processed'/>", "Information", function(){
							confResource.bookingGrid.reloadList();
						})
					}
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/manage/modifyBookingState.do", response, status, error);
			}
		});
	}
	
	function approvalBooking(){
		var dateIDs = "";
		var excludeItem = false; // 제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(confResource.bookingGrid.getCheckedListWithIndex(0), function(idx, obj){
			if(obj.item.ApprovalStateCode.toUpperCase() != 'APPROVALREQUEST'){
				excludeItem = true;
				confResource.bookingGrid.checkedColSeq(0, false, obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';
		
		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_14'/>"; // 승인요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_14'/>"; // 승인요청 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		
		msgConfirm += "<spring:message code='Cache.msg_127'/>"; // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; // 선택된 항목이 없습니다.
		
		$.each(confResource.bookingGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
		if (dateIDs == "") {
			Common.Warning(msgWarning);
			return;
		}
		
		Common.PromptArea(msgConfirm, "", "<spring:message code='Cache.lbl_Confirm'/>", function(result){
			if (result != null) {
				setApprovalState(dateIDs, "Approval", result);
			}
		});
	}
	
	function rejectBooking(){
		var dateIDs = "";
		var excludeItem = false; // 제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(confResource.bookingGrid.getCheckedListWithIndex(0), function(idx, obj){
			if(obj.item.ApprovalStateCode.toUpperCase() != 'APPROVALREQUEST'){
				excludeItem = true;
				confResource.bookingGrid.checkedColSeq(0,false,obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';
		
		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_14'/>"; // 승인요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_14'/>"; // 승인요청 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		
		msgConfirm += "<spring:message code='Cache.msg_127'/>"; // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; // 선택된 항목이 없습니다.
		
		$.each(confResource.bookingGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
		if (dateIDs == "") {
			Common.Warning(msgWarning);
			return;
		}
		
		Common.PromptArea(msgConfirm, "", "<spring:message code='Cache.lbl_Confirm'/>", function(result){
			if (result != null) {
				setApprovalState(dateIDs, "Reject", result);
			}
		});
	}
	
	function cancelBooking(){
		var dateIDs = "";
		var excludeItem = false; // 제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(confResource.bookingGrid.getCheckedListWithIndex(0), function(idx, obj){
			if(obj.item.ApprovalStateCode.toUpperCase() != 'APPROVAL'){
				excludeItem = true;
				confResource.bookingGrid.checkedColSeq(0, false, obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';
		
		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_16'/>"; // 승인 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_16'/>"; // 승인 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		
		msgConfirm += "<spring:message code='Cache.msg_127'/>"; // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; // 선택된 항목이 없습니다.
		
		$.each(confResource.bookingGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
		if (dateIDs == "") {
			Common.Warning(msgWarning);
			return;
		}
		
		Common.PromptArea(msgConfirm , "", "<spring:message code='Cache.lbl_Confirm'/>", function(result){
			if (result != null) {
				setApprovalState(dateIDs, "ApprovalDeny", result);
			}
		});
	}
	
	function returnBooking(){
		var dateIDs = "";
		var excludeItem = false; // 제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(confResource.bookingGrid.getCheckedListWithIndex(0), function(idx,obj){
			if(obj.item.ApprovalStateCode.toUpperCase() != 'RETURNREQUEST'){
				excludeItem = true;
				confResource.bookingGrid.checkedColSeq(0, false, obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';
		
		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_17'/>"; // 반납요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_17'/>"; // 반납요청 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		
		msgConfirm += "<spring:message code='Cache.msg_127'/>"; // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; // 선택된 항목이 없습니다.
		
		$.each(confResource.bookingGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
		if (dateIDs == "") {
			Common.Warning(msgWarning);
			return;
		}
		
		Common.PromptArea(msgConfirm , "", "<spring:message code='Cache.lbl_Confirm'/>", function(result){ 
			if (result != null) {
				setApprovalState(dateIDs, "ReturnComplete", result);
			}
		});
	}
	
	function deleteBooking(){
		var dateIDs = "";
		var excludeItem = false; //제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(confResource.bookingGrid.getCheckedListWithIndex(0), function(idx, obj){
			if(!["REJECT", "RETURNCOMPLETE", "AUTOCANCEL"].includes(obj.item.ApprovalStateCode.toUpperCase())){
				excludeItem = true;
				confResource.bookingGrid.checkedColSeq(0, false, obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';
		
		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_13'/>"; // 거부/반납완료/자동취소 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_13'/>"; // 거부/반납완료/자동취소 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		
		msgConfirm += "<spring:message code='Cache.msg_127'/>"; // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; // 선택된 항목이 없습니다.
		
		$.each(confResource.bookingGrid.getCheckedList(0), function(i, obj){
			dateIDs += obj.DateID + ';'
		});
		
		if (dateIDs == "") {
			Common.Warning(msgWarning);
			return;
		}
		
		Common.Confirm(msgConfirm ,"<spring:message code='Cache.lbl_Confirm'/>", function(result){
			if (result) {
				$.ajax({
					url: "/groupware/resource/manage/deleteBookingData.do",
					type: "POST",
					data: {
						"DateID": dateIDs
					}, 
					success: function(data){
						if(data.status == 'SUCCESS'){
							Common.Inform("<spring:message code='Cache.msg_Processed'/>", "Information", function(){
								confResource.bookingGrid.reloadList();
							});
						}else{
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
						}
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/groupware/resource/manage/deleteBookingData.do", response, status, error);
					}
				});
			}
		});
	}
</script>