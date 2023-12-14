<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span id="folderTitle" class="con_tit"> <spring:message code='Cache.lbl_Resources'/></span>
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div style="margin-bottom: 20px;">
			<span id="folderPath" style="font-size: 20px; font-weight: bold; display: none; padding-top: 20px"></span>
		</div>
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridRefresh();"/><!--새로고침-->
			<input id="add" type="button" class="AXButton"  value="<spring:message code="Cache.lbl_Property"/>" onclick="modifyCurrentFolderPopup();"/><!--속성-->
			
			<span id="folderItemDiv" style="display:none;">
				<input id="add" type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addFolderPopup(false)"/><!--추가-->
				<input id="del" type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="delFolder()"/><!--삭제-->
				<input type="button" value="<spring:message code='Cache.btn_UP'/>" onclick="javascript:moveFolderGrid('up');" class="AXButton BtnUp" /><!--위로-->
				<input type="button" value="<spring:message code='Cache.btn_Down'/>" onclick="javascript:moveFolderGrid('down');" class="AXButton BtnDown" /><!--아래로-->
			</span>
			
			<span id="resourceItemDiv"  style="display:none;">
				<input id="approval" type="button" class="AXButton"  value="<spring:message code="Cache.lbl_Approval"/>" onclick="approvalBooking()"/><!--승인-->
				<input id="reject" type="button" class="AXButton"  value="<spring:message code="Cache.lbl_Reject"/>" onclick="rejectBooking()"/><!--거부-->
				<input id="cancelApproval" type="button" class="AXButton"  value="<spring:message code="Cache.lbl_CancelApproval"/>" onclick="cancelBooking()"/><!--승인취소-->
				<input id="confirmReturn" type="button" class="AXButton"  value="<spring:message code="Cache.lbl_CheckReturn"/>" onclick="returnBooking()"/><!--반납확인-->
				<input id="del" type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteBooking()"/><!--삭제-->
			</span>
		</div>	
	
		<div id="resourceSearchDiv" class="topbar_grid" style="display:none;">
			<!--예약상태-->
			<spring:message code="Cache.lbl_Res_Status"/>
			<select id="bookingStateSelect" class="AXSelect W100"></select> &nbsp;&nbsp;&nbsp;
			
			<select id="searchTypeSelect" class="AXSelect W80"></select>			
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="AXInput" /> &nbsp;&nbsp;&nbsp;
			<spring:message code="Cache.lbl_Booking_Date"/><!-- 예약일시  -->
			<input class="AXInput" id="startDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate">
			 ~ 				   	   
			<input class="AXInput" id="endDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate">

			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig('Resource');" class="AXButton"/><!--검색 -->
		</div>	
		
		<div id="folderGrid"></div>
	</div>
</form>

<script type="text/javascript">
	//# sourceURL=ResourceManage.jsp
	var folderID = CFN_GetQueryString("folderID") == 'undefined' ? (resourceFolderTree.list[0]==undefined ? 0 : resourceFolderTree.list[0].FolderID) :  CFN_GetQueryString("folderID");
	var folderType = CFN_GetQueryString("folderType") == 'undefined' ? "" :  CFN_GetQueryString("folderType");
	var memberOf = folderID;
	var folderDepth = null;
	var g_isRoot;
	
	var folderGrid = new coviGrid();
	
	var lang = Common.getSession("lang");
	
	var queryStr;
	
	$(function(){
		queryStr = initQueryStr();
		
		if (queryStr.folderID && queryStr.domainID && queryStr.folderType) {
			selectResourceFolder(queryStr.folderID, queryStr.domainID, queryStr.folderType, queryStr.folderIdx)
			if($(".admin-menu-active").length == 1) $(".con_tit").text($(".admin-menu-active").text());
		}
		else {
			resourceManageInit();
		}
	})
	
	function initQueryStr(){
		return JSON.parse('{"' + decodeURI(location.search.substring(1)).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}');
	}
	
	function resourceManageInit(){
		$.ajax({
			url: "/groupware/resource/getFolderInfo.do",
			type:"POST",
			data: {
				"folderID": folderID
			},
			success:function(obj){
				if(obj.status=="SUCCESS"){
					g_isRoot = obj.data.FolderType == 'Root'? true : false;
					// sys_object_folder의 folderPath 값이 null인 경우 경로가 조회되지 않음.
					// sys_object_folder의 folderPath 값이 ''인 경우 multipleDisplayName으로 표시됨.
					$("#folderPath").text(obj.data.FolderPath).show();
					setControls(obj.data);
				}
			},
			error:function(response, status, error){
       	     	CFN_ErrorAjax("/groupware/resource/getFolderInfo.do", response, status, error);
       		}	
			
		});	
	}
	
	function setControls(data){
		$("#folderItemDiv, #resourceItemDiv, #resourceSearchDiv").css("display","none");
		
		if(data.FolderType == null){
			$("#folderItemDiv").css("display","inline");
			setGrid("Root");	
		}else if(data.FolderType.indexOf("Resource") == 0){
			$("#resourceItemDiv").css("display","inline");
			$("#resourceSearchDiv").css("display","block")
			setSelectBox();  	// 자원 선택시만 selectbox가 보이도록
			setGrid(data.FolderType);			// 그리드 세팅			
		}else{
			$("#folderItemDiv").css("display","inline");
			setGrid(data.FolderType);			// 그리드 세팅			
		}
	}
	
	function setSelectBox(){
		coviCtrl.renderAXSelect(
				"ApprovalState",
				"bookingStateSelect",
				lang,
				"searchConfig",
				"",
				"",
				true
			);
		
		$("#searchTypeSelect").bindSelect({
				options: [
					{optionValue:'', optionText:"<spring:message code='Cache.lbl_selection'/>"}, /*선택*/
					{optionValue:'Description', optionText:"<spring:message code='Cache.lbl_Purpose'/>"}, /*용도*/
					{optionValue:'RegisterName', optionText:"<spring:message code='Cache.lbl_Applicator'/>"} /*신청자 */
				]
		});
	}
	
	
	//그리드 세팅
	function setGrid(folderType){
		if(folderType.indexOf("Resource") == 0 ){ //folderType이 Resource로 시작하는 경우
			folderGrid.setGridHeader([	
				{key:'chk', label:'chk', width:'3', align:'center', formatter: 'checkbox'},
				{key:'EventID',  label:'Event ID', width:'6', align:'center'},	   /*Event ID*/
				{key:'DateID',  label:'Date ID', width:'6', align:'center'},	   /*Date ID*/
				{key:'Subject',  label:'<spring:message code="Cache.lbl_Purpose"/>', width:'30', align:'center'},     /*용도*/
				{key:'StartDateTime',  label:'<spring:message code="Cache.lbl_BookingStartDate"/>', width:'12', align:'center'},     /*예약시작일시*/
				{key:'EndDateTime',  label:'<spring:message code="Cache.lbl_BookingEndDate"/>', width:'12', align:'left' },	     /*예약종료일시	 */
				{key:'ApprovalState', label:'<spring:message code="Cache.lbl_Res_Status"/>', width:'7', align:'center'},     			   /*예약상태*/
				{key:'RegisterName',  label:'<spring:message code="Cache.lbl_Applicator"/>', width:'7', align:'center'},     /*신청자*/
				{key:'RegistDate', label:'<spring:message code="Cache.lbl_Application_Day"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', 
					formatter: function(){ return CFN_TransLocalTime(this.item.RegistDate); }
				}      /*신청일*/
			]);
		}
		else{
			// 사업장 사용 여부
			var placeOfBusinessDisplay = true;
			if((Common.getBaseConfig("IsUsePlaceOfBusinessSel") === "N")){
				placeOfBusinessDisplay = false;
			}
			folderGrid.setGridHeader([	            
				{key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
				{key:'FolderID',  label:'ID', width:'4', align:'center'},	   /*ID*/
				{key:'FolderType',  label:'<spring:message code="Cache.lbl_Res_Div"/>', width:'7', align:'center', formatter: function(){
					if(this.item.FolderType == "Folder" ){
						return "<spring:message code='Cache.lbl_Division'/>"; //분류
					}else{ 
						return "<spring:message code='Cache.lbl_Resources'/>"; //자원			    	                				
					}
				}},     /*자원분류*/
				{key:'PlaceOfBusiness',  label:'<spring:message code="Cache.lbl_PlaceOfBusiness"/>', width:'7', align:'center', display: placeOfBusinessDisplay, formatter: function(){
					return this.item.PlaceOfBusiness;
/* 			    	                	  if(typeof(this.item.PlaceOfBusiness) == 'undefined'){
			    	                		 return '';
			    	                	  }else if(typeof(this.item.PlaceOfBusiness.codeName) !=''){
			    	                		  var places = this.item.PlaceOfBusiness.codeName.split(";");
			    	                		  if(places.length <= 2){
			    	                			  return places[0];
			    	                		  }else{
			    	                			  return String.format("<spring:message code='Cache.lbl_Mail_AndOthers'/>",places[0] , places.length - 2);  //{0} 외 {1}
			    	                		  }
			    	                	  }
 */			    }},     /*사업장*/
				{key:'FolderName',  label:'<spring:message code="Cache.lbl_CategoryResourceName"/>', width:'20', align:'left', formatter: function(){
					var html = "";
			    	                		/*   if(this.item.FolderType.indexOf("Resource") == 0){
			    	                			  if(this.item.IconPath == undefined){
			    	                				  html +="<img width='16px' height='16px' src='/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif' style='vertical-align: text-top;margin-right: 4px;' >";
			    	                			  }else{
			    	                				  html +="<img width='16px' height='16px' src='"+this.item.IconPath +"'  style='vertical-align: text-top;margin-right: 4px;' >";
			    	                			  }
			    	                		  }else{
			    	                			  html +="<img width='16px' height='16px' src='/HtmlSite/smarts4j_n/covicore/resources/images/covision/FOLDER_close.gif'  style='vertical-align: text-top;margin-right: 4px;' />"
			    	                		  } */
					html += "<a href='#' onclick='modifyFolderPopup(\""+this.item.FolderID+"\")'>" + this.item.FolderName + "</a>";
					
					return html;
				}},	     /*분류/자원 명 */
				{key:'BookingType', label:'<spring:message code="Cache.lbl_ReservationProc"/>', width:'7', align:'center' },     			   /*예약절차*/
				{key:'ReturnType',  label:'<spring:message code="Cache.lbl_ReturnProc"/>', width:'7', align:'center'},     /*반납절차*/
				{key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'7', align:'center', sort:"asc"},     /*우선순위*/
				{key:'IsDisplay', label:'<spring:message code="Cache.lbl_DisplayYN"/>', width:'7', align:'center', formatter:function () {
					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsDisplaySwitch"+this.item.FolderID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsDisplay+"' onchange='changeIsSwitch(\""+this.item.FolderID+"\",\"IsDisplay\");' />";
				}},      /*표시유무*/
				{key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'7', align:'center', formatter:function () {
					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUseSwitch"+this.item.FolderID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='changeIsSwitch(\""+this.item.FolderID+"\",\"IsUse\");' />";
				}},      /*사용유무*/
				{key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'9', align:'center'},          /*등록자*/ 
				{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDateHour"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'9', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}}          /*등록일시*/ 
			]);
		}
		setGridConfig();
		searchConfig(folderType);				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "folderGrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		folderGrid.setGridConfig(configObj);
	}
	

	//그리드 바인딩
	function searchConfig(folderType){	
		if(typeof folderType =="object"){
			folderType =  "Resource";
		}
		
		var url ="";
		var date = {};

		if(folderType.indexOf("Resource") == 0 ){
			url = "/groupware/resource/getBookingOfResourceList.do";
			data = {
					"folderID": folderID,
					"bookingState": $("#bookingStateSelect").val(),
					"searchType" :  $("#searchTypeSelect").val(),
					"searchWord" :  $("#search").val(),
					"startDate":  $("#startDate").val(),
					"endDate" : $("#endDate").val()
			};
		}else{
			url = "/groupware/resource/getResourceOfFolderList.do";
			data = {
					"folderID" : folderID
			};
		}
		folderGrid.bindGrid({
				ajaxUrl:url,
				ajaxPars: data
		});
	}	
	
	
	// 새로고침
	function gridRefresh(){
		
		var pFolderType = CFN_GetQueryString("folderType");
		
		if (pFolderType === "Folder") {
			var pathname = '/groupware/layout/resource_ResourceManage.do';
			var url = pathname + '?CLSYS=resource&CLMD=admin&CLBIZ=Resource';
			
			var pfolderID = CFN_GetQueryString("folderID");
			var pDomainID = CFN_GetQueryString("domainID");
			var pFolderIdx = CFN_GetQueryString("folderIdx");
			
			selectResourceFolder(pfolderID, pDomainID, pFolderType, pFolderIdx);
			
		} else {
			$("#bookingStateSelect").bindSelectSetValue('');	
			$("#searchTypeSelect").bindSelectSetValue('');
			$("#search").val('');
			$("#startDate").val('');
			$("#endDate").val('');
			folderGrid.reloadList();	
		}
	}
	
	//폴더 버튼에 대한 레이어 팝업
	function addFolderPopup(pModal){		 
		var url = "/groupware/resource/goResourceManageSetPopup.do";
		url += "?domainID="+$("#leftDomainSelectBox").val();
		url += "&parentFolderID="+folderID;
		url += "&folderDepth="+folderDepth;
		url += "&mode=create";
		
		if (g_isRoot === true) { 	// Root 여부 전달.
			url += "&folderType=Root";
		}
		
		// 분류/자원 추가;분류/자원 정보를 추가합니다.
		Common.open("","divResourceInfo","<spring:message code='Cache.lbl_ResourceManage_08'/>|||<spring:message code='Cache.msg_ResourceManage_08'/>",url,"620px","740px","iframe",pModal,null,null,true);
	}
	
	// 폴더 수정 레이어 팝업
	function modifyFolderPopup(sfolderID){
		// 분류/자원 수정;분류/자원 정보를 수정합니다.
		var url = "/groupware/resource/goResourceManageSetPopup.do";
		url += "?domainID="+$("#leftDomainSelectBox").val();
		url += "&parentFolderID="+folderID;
		url += "&folderID="+sfolderID;
		url += "&folderType="+folderType;
		url += "&mode=edit";
		// url += "&g_isRoot="+g_isRoot;
		
		Common.open("","divResourceInfo","<spring:message code='Cache.lbl_ResourceManage_09'/>|||<spring:message code='Cache.msg_ResourceManage_09'/>",url,"620px","740px","iframe",true,null,null,true);
	}
	
	
	
	// 사용여부 변경
	function changeIsSwitch(folderID, columnName){
		$.ajax({
        	type:"POST",
        	url:"/groupware/resource/changeIsSwitch.do",
        	data:{
        		"folderID":folderID,
        		"columnName": columnName
        	},
        	success:function(data){
        		if(data.status!='SUCCESS'){
        			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
        		}
        	},
        	error:function(response, status, error){
        	     //TODO 추가 오류 처리
        	     CFN_ErrorAjax("/groupware/resource/changeIsSwitch.do", response, status, error);
        	}
        });
	}
	
	//삭제
	function delFolder(){
		var folderIDInfos = '';
		
		$.each(folderGrid.getCheckedList(0), function(i,obj){
			folderIDInfos += obj.FolderID + ';'
		});
		
		if(folderIDInfos == ''){
			 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
             return;
		}
		
		 Common.Confirm("<spring:message code='Cache.apv_msg_rule02'/>", 'Confirmation Dialog', function (result) {       // 하위 노드가 존재하면 같이 삭제 됩니다. 선택한 항목을 삭제 하시겠습니까?
             if (result) {
                $.ajax({
                	type:"POST",
                	url:"/groupware/resource/deleteFolderData.do",
                	data:{
                		"folderID":folderIDInfos
                	},
                	success:function(data){
                		if(data.status=='SUCCESS'){
                			Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
                			folderGrid.reloadList();
                			setTreeData();
                		}else{
                			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
                		}
                	},
                	error:function(response, status, error){
                	     CFN_ErrorAjax("/groupware/resource/deleteFolderData.do", response, status, error);
                	}
                });
             }
         });
	}
	
	//자원 위치 변경
	function moveFolderGrid(pMode){
		if(folderGrid.getCheckedList(0).length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_09'/>", "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
			return;
		} else if(folderGrid.getCheckedList(0).length > 1){
			Common.Warning("<spring:message code='Cache.msg_SelectOne'/>", "Warning Dialog", function () { });          // 이동할 필드는 한개만 선택되어야 합니다
			return;
		}
		
		var param = folderGrid.getCheckedList(0)[0];	//체크된 Grid 데이터로 이동

		$.ajax({
	    	type:"POST",
	    	url: "/groupware/admin/moveFolderResource.do",
	    	dataType : 'json',
	    	data: {
	        	"domainID": $("#leftDomainSelectBox").val(),
	        	"folderID": param.FolderID,
	        	"memberOf": memberOf,
	        	"sortKey": param.SortKey,
	        	"mode": pMode
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			
	        		if(data.message != undefined && data.message != ""){	//최상위, 최하위 항목의 경우에는 변경 불가 메시지 표시
	        			Common.Warning(data.message); //변경했습니다.
	            	} else {
	            		Common.Warning("<spring:message code='Cache.msg_Changed'/>"); //변경했습니다.
	                }
	        		setTreeData();
	      			folderGrid.reloadList();
	      		}else{
	      			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");		//오류가 발생헸습니다.
	      		}
	    	}, 
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/admin/moveFolder.do", response, status, error);
	    	}
	    });
	}

	// 위로 버튼 클릭시 실행되며, 해당 항목을 위로 이동합니다.
    function upRow() {
        var checkedList = folderGrid.getCheckedListWithIndex(0);
		
        if(checkedList.length <= 0){
            Common.Warning("<spring:message code='Cache.msg_Common_09'/>", "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
            return;
        }

        var oPreview = null;
        var oNow = null;


	    $.each(checkedList, function(idx, obj){
            // 현재 행: 위에서부터 선택 되어 있는 행 찾기
            // oNow = aObjectTR.filter(":eq(" + i.toString() + ")"); obj로 대체
			oNow = obj.item;
            
            // 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
            oPreview = null;
            for (var j = obj.index - 1; j >= 0; j--) {
                if (folderGrid.list[j].FolderID == undefined) {
                    break;
                }
                if (folderGrid.list[j].___checked[0] == true) {
                    continue;
                }
                oPreview = folderGrid.list[j];
                break;
            }
            
            if (oPreview == null) {
            	 return true; //continue;
            }

            $.ajax({
            	url: "/groupware/resource/changeFolderSortKey.do",
            	type:"POST",
            	data:{
            		"folderID1": oPreview.FolderID,
            		"sortKey1": oPreview.SortKey,
            		"folderID2": oNow.FolderID,
            		"sortKey2": oNow.SortKey
            	},
            	success:function(data){
            		if(data.status =='SUCCESS'){
						folderGrid.reloadList();
						setTreeData();
            		}else{
            			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
            		}
            		
            	},
            	error:function(response, status, error){
            	     CFN_ErrorAjax("/groupware/resource/changeFolderSortKey.do", response, status, error);
            	}
            });
            
	    });
    }

    // 아래로 버튼 클릭시 실행되며, 해당 항목을 아래로 이동합니다.
    function downRow() {
    	var checkedList = folderGrid.getCheckedListWithIndex(0);
  		
        if(checkedList.length <= 0){
            Common.Warning("<spring:message code='Cache.msg_Common_09'/>", "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
            return;
        }
        
        var oNext = null;
        var oNow = null;

        $.each(checkedList, function(idx, obj){

            // 현재 행: 아래에서부터 선택되어 있는 행 찾기
            // oNowTR = aObjectTR.filter(":eq(" + i.toString() + ")"); obj로 대체
			oNow = obj.item;
            
            // 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
            oNext = null;
            for (var j = obj.index + 1; j < folderGrid.list.length; j++) {
                if (folderGrid.list[j].FolderID == undefined) {
                    break;
                }
                if (folderGrid.list[j].___checked[0] == true) {
                    continue;
                }
                oNext = folderGrid.list[j];
                break;
            }
            if (oNext == null) {
            	 return true; //continue;
            }

            
            $.ajax({
            	url: "/groupware/resource/changeFolderSortKey.do",
            	type:"POST",
            	data:{
            		"folderID1": oNext.FolderID,
            		"sortKey1": oNext.SortKey,
            		"folderID2": oNow.FolderID,
            		"sortKey2": oNow.SortKey
            	},
            	success:function(data){
            		if(data.status=='SUCCESS'){
						folderGrid.reloadList();
						setTreeData();
            		}else{
            			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
            		}
            		
            	},
            	error:function(response, status, error){
            	     CFN_ErrorAjax("/groupware/resource/changeResourceSortKey.do", response, status, error);
            	}
            });
        });
    }
    
    // 승인/거부/승인취소/반납확인 버튼 클릭시 실행되며, 선택한 항목에 대하여 처리를 합니다.
    function setApprovalState(dateIDs, state, comment) {
    	//사용자 단의 API 사용
    	$.ajax({
    		url:"/groupware/resource/modifyBookingState.do",
    		type:"post",
    		data:{
    			DateID : dateIDs,
				ResourceID: folderID,
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
    				if(warMsg != ''){
    					Common.Warning(warMsg+"\n<spring:message code='Cache.msg_noProcessList'/>","Warning", function(){ //위 항목은 제외하고 처리되었습니다.
    						folderGrid.reloadList();
    					}); 
    				}else{
		    			Common.Inform("<spring:message code='Cache.msg_Processed'/>","Information",function(){
	    					folderGrid.reloadList();
	    				})
    				}
    				
    			}else{
        			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
        		}
    		},
        	error:function(response, status, error){
       	     CFN_ErrorAjax("/groupware/resource/modifyBookingState.do", response, status, error);
      	 	}
    	});
    }

    
    function modifyCurrentFolderPopup(){
    	/* modifyFolderPopup(folderID); */
    	
    	var url = "/groupware/resource/goResourceManageSetPopup.do";
		url += "?domainID="+$("#leftDomainSelectBox").val();
		url += "&parentFolderID="+folderID;
		url += "&folderID="+folderID;
		url += "&folderType="+ folderType;
		url += "&g_isRoot="+g_isRoot;
		
		Common.open("","divResourceInfo","<spring:message code='Cache.lbl_ResourceManage_09'/>|||<spring:message code='Cache.msg_ResourceManage_09'/>",url,"620px","720px","iframe",true,null,null,true);
    	
    }
	
    function approvalBooking(){
    	var dateIDs = "";
		var excludeItem = false; //제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(folderGrid.getCheckedListWithIndex(0), function(idx,obj){
			if(obj.item.ApprovalStateCode.toUpperCase() !='APPROVALREQUEST'){
				excludeItem = true;
				folderGrid.checkedColSeq(0,false,obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';

		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_14'/>";  	//승인요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_14'/>";  	//승인요청 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		msgConfirm += "<spring:message code='Cache.msg_127'/>";  // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; //선택된 항목이 없습니다.
		
		$.each(folderGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
        if (dateIDs == "") {
            Common.Warning(msgWarning, "Warning Dialog", function () { });         
            return;
        }

        Common.PromptArea(msgConfirm ,"","<spring:message code='Cache.lbl_Confirm'/>", function (result) { 
        	if (result != null) {
        		setApprovalState(dateIDs, "Approval", result);
        	}
        });
    }
    
    function rejectBooking(){
    	var dateIDs = "";
		var excludeItem = false; //제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(folderGrid.getCheckedListWithIndex(0), function(idx,obj){
			if(obj.item.ApprovalStateCode.toUpperCase() !='APPROVALREQUEST'){
				excludeItem = true;
				folderGrid.checkedColSeq(0,false,obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';

		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_14'/>";  	//승인요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_14'/>";  	//승인요청 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		msgConfirm += "<spring:message code='Cache.msg_127'/>";  // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; //선택된 항목이 없습니다.
		
		$.each(folderGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
        if (dateIDs == "") {
            Common.Warning(msgWarning, "Warning Dialog", function () { });         
            return;
        }

        Common.PromptArea(msgConfirm ,"","<spring:message code='Cache.lbl_Confirm'/>", function (result) { 
        	if (result != null) {
        		setApprovalState(dateIDs, "Reject", result);
        	}
        });
    }
    
    function cancelBooking(){
    	var dateIDs = "";
		var excludeItem = false; //제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(folderGrid.getCheckedListWithIndex(0), function(idx,obj){
			if(obj.item.ApprovalStateCode.toUpperCase() !='APPROVAL'){
				excludeItem = true;
				folderGrid.checkedColSeq(0,false,obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';

		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_16'/>";  	//승인 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_16'/>";  	//승인 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		msgConfirm += "<spring:message code='Cache.msg_127'/>";  // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; //선택된 항목이 없습니다.
		
		$.each(folderGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
        if (dateIDs == "") {
            Common.Warning(msgWarning, "Warning Dialog", function () { });         
            return;
        }

        Common.PromptArea(msgConfirm ,"","<spring:message code='Cache.lbl_Confirm'/>", function (result) { 
        	if (result != null) {
        		setApprovalState(dateIDs, "ApprovalDeny", result);
        	}
        });
    }
    
    function returnBooking(){
    	var dateIDs = "";
		var excludeItem = false; //제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(folderGrid.getCheckedListWithIndex(0), function(idx,obj){
			if(obj.item.ApprovalStateCode.toUpperCase() !='RETURNREQUEST'){
				excludeItem = true;
				folderGrid.checkedColSeq(0,false,obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';

		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_17'/>";  	//반납요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_17'/>";  	//반납요청 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		msgConfirm += "<spring:message code='Cache.msg_127'/>";  // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; //선택된 항목이 없습니다.
		
		$.each(folderGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
        if (dateIDs == "") {
            Common.Warning(msgWarning, "Warning Dialog", function () { });         
            return;
        }

        Common.PromptArea(msgConfirm ,"","<spring:message code='Cache.lbl_Confirm'/>", function (result) { 
        	if (result != null) {
        		setApprovalState(dateIDs, "ReturnComplete", result);
        	}
        });
    }
    
    function deleteBooking(){
    	var dateIDs = "";
		var excludeItem = false; //제외할 항목(승인 요청 상태가 아닌 것)
		
		$.each(folderGrid.getCheckedListWithIndex(0), function(idx,obj){
			if(obj.item.ApprovalStateCode.toUpperCase() !='REJECT' && obj.item.ApprovalStateCode.toUpperCase() !='RETURNCOMPLETE' && obj.item.ApprovalStateCode.toUpperCase() !='AUTOCANCEL'){
				excludeItem = true;
				folderGrid.checkedColSeq(0,false,obj.index);
			}
		});
		
		var msgConfirm = '';
		var msgWarning = '';

		if(excludeItem){
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_13'/>";  	//거부/반납완료/자동취소 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_13'/>";  	//거부/반납완료/자동취소 상태가 아닌 항목은 제외됩니다.
			
			msgConfirm += "\n";
			msgWarning += "\n";
		}
		msgConfirm += "<spring:message code='Cache.msg_127'/>";  // 처리 하시겠습니까?
		msgWarning += "<spring:message code='Cache.msg_apv_003'/>"; //선택된 항목이 없습니다.
		
		$.each(folderGrid.getCheckedList(0), function(i,obj){
			dateIDs += obj.DateID + ';'
		});
		
        if (dateIDs == "") {
            Common.Warning(msgWarning, "Warning Dialog", function () { });         
            return;
        }

        Common.Confirm(msgConfirm ,"<spring:message code='Cache.lbl_Confirm'/>", function (result) { 
        	if (result) {
        		$.ajax({
        			url:"/groupware/resource/deleteBookingData.do",
        			type:"POST",
        			data:{
        				"DateID": dateIDs
        			}, 
            		success: function(data){
            			if(data.status =='SUCCESS'){
       		    			Common.Inform("<spring:message code='Cache.msg_Processed'/>","Information",function(){
       	    					folderGrid.reloadList();
       	    				})
            				
            			}else{
                			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
                		}
            		},
                	error:function(response, status, error){
               	    	 CFN_ErrorAjax("/groupware/resource/deleteBookingData.do", response, status, error);
               		}
        			
        		});
        	}
        });
    }
    
</script>
