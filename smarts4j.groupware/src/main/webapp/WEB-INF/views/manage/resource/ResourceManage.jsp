<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code="Cache.lbl_Resources"/></h3> <!-- 자원 -->
	<div class="searchBox02">
		<span><input type="text" id="searchText"><button type="button" class="btnSearchType01"  id="icoSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
	</div>
</div>
<form id="form1">
<div class="cRContBottom mScrollVH">
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="addFolderPopup('', '');"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->	
				<a class="btnTypeDefault" onclick="confResource.resourceTree.expandAll();"><spring:message code="Cache.lbl_OpenAll"/></a>
				<a class="btnTypeDefault" onclick="confResource.resourceTree.collapseAll();"><spring:message code="Cache.lbl_CloseAll"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_IsAll" value="Y" ><label for="chk_IsAll"><span class="s_check"></span><spring:message code='Cache.btn_All' /></label> </div>
				<button class="btnRefresh" id="folderRefresh" type="button" href="#"></button>
			</div>
		</div>
		<div id="resourceTree" class="tblList tblCont"></div>						
	</div>
</div>
</form>
<script type="text/javascript">
	var confResource = {
		resourceTree:'',
		headerData:	[
			{
				key: "FolderName",			// 컬럼에 매치될 item 의 키
				indent: true,				// 들여쓰기 여부
				label:'<spring:message code="Cache.lbl_CategoryResourceName"/>',
				width: "170",
				align: "left",
				getIconClass: function(){	// indent 속성 정의된 대상에 아이콘을 지정 가능
					var sRetIcon= this.item.FolderType.indexOf("Resource") == 0?"ic_file ":"ic_folder ";
					if (this.item.IsUse == "N" || this.item.IsDisplay == "N") sRetIcon += "icon02";
					return sRetIcon;
				},
				formatter:function(){
					var html = "<a href='#' onclick='modifyFolderPopup(\""+this.item.FolderID+"\", \""+this.item.MemberOf+"\", \""+this.item.FolderType+"\")'>" + this.item.FolderName + "</a>";
					return html;
				}
			},
			{key:'FolderID', label:'ID', width:'50', align:'center'},
			{key:'FolderType', label:'<spring:message code="Cache.lbl_Res_Div"/>', width:'100', align:'center', formatter:function(){ // 자원분류
				if(this.item.FolderType.indexOf("Resource") == 0){
					return "<spring:message code='Cache.lbl_Resources'/>"; // 자원
				}else{
					return "<spring:message code='Cache.lbl_Division'/>"; // 분류
				}
			 }},
			{key:'PlaceOfBusiness', label:'<spring:message code="Cache.lbl_PlaceOfBusiness"/>', width:'100', align:'center'}, // 사업장
			{key:'BookingType', label:'<spring:message code="Cache.lbl_ReservationProc"/>', width:'100', align:'center', formatter:function(){ // 예약절차
				 var BookingType = Common.getBaseCode("BookingType").CacheData;
				 var len = BookingType.length;
				 for (var i = 0; i < len; i++) {
			    	if(this.item.BookingType == BookingType[i].Code){
						return CFN_GetDicInfo(BookingType[i].MultiCodeName);
			    	}
			     }				
			}}, 
			{key:'ReturnType', label:'<spring:message code="Cache.lbl_ReturnProc"/>', width:'100', align:'center', formatter:function(){ // 반납절차
				var ReturnType = Common.getBaseCode("ReturnType").CacheData;
				 var len = ReturnType.length;
				 for (var i = 0; i < len; i++) {
			    	if(this.item.ReturnType == ReturnType[i].Code){
						return CFN_GetDicInfo(ReturnType[i].MultiCodeName);
			    	}
			     }
			}}, 
			{key:'SortKey', label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'80', align:'center'}, // 우선순위
			{key:'IsDisplay', label:'<spring:message code="Cache.lbl_DisplayYN"/>', width:'60', align:'center',			//표시여부
        		formatter: function() { return confResource.formatUpdateFlag(this); }
        	},   
			{key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'60', align:'center', 
        		formatter: function() { return confResource.formatUpdateFlag(this); }
			},
			{key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'100', align:'center'}, // 등록자
			{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDateHour"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', formatter:function(){ // 등록일시
				return CFN_TransLocalTime(this.item.RegistDate);
			}},
			{key:'', label:"<spring:message code='Cache.lbl_action'/>", width:'300', align:'left', display:true, sort:false, formatter:function(){
				var html = '<div class="btnActionWrap">';
				
				if (this.item.FolderType !== "Root") {
					html += '<a href="javascript:;" class="btnTypeDefault btnMoveUp" onclick="moveFolder(\'up\', this);"><spring:message code="Cache.lbl_apv_up"/></a>'; // 위로
					html += '<a href="javascript:;" class="btnTypeDefault btnMoveDown" onclick="moveFolder(\'down\', this);"><spring:message code="Cache.lbl_apv_down"/></a>'; // 아래로
				}
				
				html += '<a href="javascript:;" class="btnTypeDefault btnSaRemove" onclick="delFolder(this);"><spring:message code="Cache.lbl_delete"/></a>'; // 삭제
				if (["Root", "Folder"].includes(this.item.FolderType)) {
					var folderDepth = this.item.FolderPath.split(">").length;
					
					html += '<a href="javascript:;" class="btnTypeDefault btnPlusAdd" onclick="addFolderPopup(\'' + this.item.FolderID + '\', \'' + folderDepth + '\');"><spring:message code="Cache.btn_apv_Person"/></a>'; // 추가
				}
				
				html += '</div>';
				return html;
			}}
		],
		initContent: function(){
			// 사업장 사용 여부
			if((Common.getBaseConfig("IsUsePlaceOfBusinessSel") === "N")){
				this.headerData[3].display = false;
			}else{
				this.headerData[3].display = true;
			}
			
			this.resourceTree = new coviTree();
			this.resourceTree.setConfig({
				targetID: "resourceTree",	// HTML element target ID
				theme: "AXTree_none",
				colGroup: this.headerData,	// tree 헤드 정의 값
				showConnectionLine: true,	// 점선 여부
				relation: {
					parentKey: "MemberOf",	// 부모 아이디 키
					childKey: "FolderID"	// 자식 아이디 키
				},
				persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
				persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				colHead: {
					display:true
				},
				height: "auto",
				fitToWidth: true			// 너비에 자동 맞춤
			});
			
			//검색
			$("#searchText").on('keydown', function(){
				if(event.keyCode == "13"){
					$('#icoSearch').trigger('click');
				}
			});
			
			// 상단바 검색 버튼
			$("#icoSearch").on('click', function(){
				var keyword = $("#searchText").val();
				if (keyword =="") return;
				
				/* 엔터나 클릭을 이용해 검색조건에 맞는 폴더나 자원 조회 */ 
				var curIdx = Number(confResource.resourceTree.selectedRow)+1;
				confResource.resourceTree.findKeywordData("FolderName", keyword, true, true, curIdx);
			});
			
			confResource.setTreeData();
		},
		setTreeData:function(){
			$.ajax({
				url:"/groupware/resource/manage/getFolderResourceTreeList.do",
				type:"POST",
				data:{
					"domainID" :confMenu.domainId,
					"isAll":$("#chk_IsAll").prop("checked")?"Y":"N"
				},
				async:false,
				success:function (data) {
					var List = data.list;
					
					confResource.resourceTree.setList(List);
					confResource.resourceTree.expandAll(1);
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/manage/getFolderResourceTreeList.do", response, status, error);
				}
			});
		},
		formatUpdateFlag: function( pObj ){
			var param = pObj.item;
			param.on = 'Y'; param.off = 'N';
			param.defVal = param[pObj.key];
			param.retVal = { folderID: param.FolderID, columnName: pObj.key };
			return coviCmn.getCoviSwitch('switch_'+param.FolderID+'_'+pObj.key, param, 'changeIsSwitch');
		}
	}
	
	$(document).ready(function(){
		confResource.initContent();
		// 폴더 새로고침
		$("#folderRefresh, #chk_IsAll").click(function(){
			refresh();
		});
	});
	
	var refresh = function(){
		confResource.setTreeData();
	}
	
	//폴더 버튼에 대한 레이어 팝업
	var addFolderPopup = function(folderID, folderDepth){
		var url = "/groupware/resource/manage/goResourceManagePopup.do";
			url += "?domainID=" + confMenu.domainId;

			if (folderID === "" && (confResource.resourceTree.list.length == 0 || confResource.resourceTree.list[0].FolderType === "Root")) {
				url += "&parentFolderID=" + (confResource.resourceTree.list.length == 0 ? 0:confResource.resourceTree.list[0].FolderID);
				url += "&folderID=";
				url += "&folderType=Root";
			} else {
				url += "&parentFolderID=" + folderID;
			}
			
			if (folderDepth === "") {
				folderDepth = "1";
			}
			
			url += "&folderDepth=" + folderDepth;
			url += "&mode=create";
			
		
		Common.open("","divResourceInfo","<spring:message code='Cache.lbl_ResourceManage_08'/>|||<spring:message code='Cache.msg_ResourceManage_08'/>",url,"670px","630px","iframe",true,null,null,true);
	}
	
	// 폴더 수정 레이어 팝업
	var modifyFolderPopup = function(folderID, parentFolderID, folderType){
		var url = "/groupware/resource/manage/goResourceManagePopup.do";
			url += "?domainID=" + confMenu.domainId;
			url += "&parentFolderID=" + parentFolderID;
			url += "&folderID=" + folderID;
			url += "&folderType=" + folderType;
			url += "&mode=edit";
		
		Common.open("","divResourceInfo","<spring:message code='Cache.lbl_ResourceManage_09'/>|||<spring:message code='Cache.msg_ResourceManage_09'/>",url,"670px","630px","iframe",true,null,null,true);
	}
	
	//자원 위치 변경
	var moveFolder = function(mode, ele){
		var idx = $("#resourceTree .gridBodyTr").index($(ele).parents('tr:first'));
		var selectedItem = confResource.resourceTree.list[idx];
		
		$.ajax({
			type:"POST",
			url: "/groupware/resource/manage/moveFolderResource.do",
			dataType: 'json',
			data: {
				"domainID": confMenu.domainId,
				"folderID": selectedItem.FolderID,
				"memberOf": selectedItem.MemberOf,
				"sortKey": selectedItem.SortKey,
				"mode": mode
			},
			success: function(data){
				if(data.status=='SUCCESS'){
					if (data.message) {	//최상위, 최하위 항목의 경우에는 변경 불가 메시지 표시
						Common.Warning(data.message); //변경했습니다.
					} else {
						Common.Warning("<spring:message code='Cache.msg_Changed'/>"); // 변경했습니다.
					}
					
					refresh();
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/manage/moveFolderResource.do", response, status, error);
			}
		});
	}
	
	// 삭제
	var delFolder = function(ele){
		Common.Confirm("<spring:message code='Cache.apv_msg_rule02'/>", 'Confirmation Dialog', function(result){ // 하위 노드가 존재하면 같이 삭제 됩니다. 선택한 항목을 삭제 하시겠습니까?
			if(result){
				var idx = $("#resourceTree .gridBodyTr").index($(ele).parents('tr:first'));
				var selectedItem = confResource.resourceTree.list[idx];
				
				$.ajax({
					type: "POST",
					url: "/groupware/resource/manage/deleteFolderData.do",
					data: {
						"folderID": selectedItem.FolderID
					},
					success: function(data){
						if(data.status=='SUCCESS'){
							Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
							refresh();
						}else{
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
						}
					},
					error:function(response, status, error){
						 CFN_ErrorAjax("/groupware/resource/manage/deleteFolderData.do", response, status, error);
					}
				});
			}
		});
	}
	
	
	
/*	//# sourceURL=ResourceManage.jsp
	var folderID = CFN_GetQueryString("folderID") == 'undefined' ? (resourceFolderTree.list[0]==undefined ? 0 : resourceFolderTree.list[0].FolderID) :  CFN_GetQueryString("folderID");
	var folderType = CFN_GetQueryString("folderType") == 'undefined' ? "" :  CFN_GetQueryString("folderType");
	var memberOf = folderID;
	var folderDepth = null;
	
	var folderGrid = new coviGrid();
	
	var lang = Common.getSession("lang");
	
	//ready
	resourceManageInit();
	*/
	function resourceManageInit(){
		
		$.ajax({
			url: "/groupware/resource/manage/getFolderInfo.do",
			type:"POST",
			data: {
				"folderID": folderID
			},
			success:function(obj){
				if(obj.status=="SUCCESS"){
					if(obj.data.FolderType != "Root") {
						folderDepth = obj.data.FolderPath.split(">").length;
						$("#folderTitle").text(obj.data.FolderPath);
					}
					setControls(obj.data);
				}
			},
			error:function(response, status, error){
	 		 	CFN_ErrorAjax("/groupware/resource/manage/getFolderInfo.do", response, status, error);
	 		}
			
		});	
	}
	
	function setControls(data){
		
		if(data.FolderType == null){
			$("#folderItemDiv").css("display","inline");
			setGrid("Root");	
		}else if(data.FolderType.indexOf("Resource") == 0){
			$("#resourceItemDiv").css("display","inline");
			$("#resourceSearchDiv").css("display","block")
			setSelectBox();	// 자원 선택시만 selectbox가 보이도록
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
				""
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
									{key:'EventID',  label:'Event ID', width:'6', align:'center'},	 /*Event ID*/
									{key:'DateID',  label:'Date ID', width:'6', align:'center'},	 /*Date ID*/
									{key:'Subject',  label:'<spring:message code="Cache.lbl_Purpose"/>', width:'30', align:'center'},	 /*용도*/
									{key:'StartDateTime',  label:'<spring:message code="Cache.lbl_BookingStartDate"/>', width:'12', align:'center'},	 /*예약시작일시*/
									{key:'EndDateTime',  label:'<spring:message code="Cache.lbl_BookingEndDate"/>', width:'12', align:'left' },		 /*예약종료일시	 */
									{key:'ApprovalState', label:'<spring:message code="Cache.lbl_Res_Status"/>', width:'7', align:'center'},	 			 /*예약상태*/
									{key:'RegisterName',  label:'<spring:message code="Cache.lbl_Applicator"/>', width:'7', align:'center'},	 /*신청자*/
									{key:'RegistDate', label:'<spring:message code="Cache.lbl_Application_Day"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', 
											formatter: function(){
												return CFN_TransLocalTime(this.item.RegistDate);
											}
									}	/*신청일*/
									]);
		}else{
			folderGrid.setGridHeader([				
									{key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
									{key:'FolderID',  label:'ID', width:'4', align:'center'},	 /*ID*/
									{key:'FolderType',  label:'<spring:message code="Cache.lbl_Res_Div"/>', width:'7', align:'center'  , formatter: function(){
												if(this.item.FolderType.indexOf("Resource") == 0 ){
													return "<spring:message code='Cache.lbl_Resources'/>"; //자원
												}else{ 
													return "<spring:message code='Cache.lbl_Division'/>"; //분류
												}
										}
									},	 /*자원분류*/
									{key:'PlaceOfBusiness',  label:'<spring:message code="Cache.lbl_PlaceOfBusiness"/>', width:'7', align:'center', formatter:function(){
										return this.item.PlaceOfBusiness;
/* 										if(typeof(this.item.PlaceOfBusiness) == 'undefined'){
											 return '';
										}else if(typeof(this.item.PlaceOfBusiness.codeName) !=''){
											var places = this.item.PlaceOfBusiness.codeName.split(";");
											if(places.length <= 2){
												return places[0];
											}else{
												return String.format("<spring:message code='Cache.lbl_Mail_AndOthers'/>",places[0] , places.length - 2);  //{0} 외 {1}
											}
										}
 */									}},	 /*사업장*/
									{key:'FolderName',  label:'<spring:message code="Cache.lbl_CategoryResourceName"/>', width:'20', align:'left',
										formatter:function(){
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
										}
									},		 /*분류/자원 명 */
									{key:'BookingType', label:'<spring:message code="Cache.lbl_ReservationProc"/>', width:'7', align:'center' },	 			 /*예약절차*/
									{key:'ReturnType',  label:'<spring:message code="Cache.lbl_ReturnProc"/>', width:'7', align:'center'},	 /*반납절차*/
									{key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'7', align:'center', sort:"asc"},	 /*우선순위*/
									{key:'IsDisplay', label:'<spring:message code="Cache.lbl_DisplayYN"/>', width:'7', align:'center',
										formatter:function () {
												return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsDisplaySwitch"+this.item.FolderID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsDisplay+"' onchange='changeIsSwitch(\""+this.item.FolderID+"\",\"IsDisplay\");' />";
										}
									},	/*표시유무*/
									{key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'7', align:'center',
										formatter:function () {
												return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUseSwitch"+this.item.FolderID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='changeIsSwitch(\""+this.item.FolderID+"\",\"IsUse\");' />";
										}
									},	/*사용유무*/
									{key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'9', align:'center'},		/*등록자*/ 
									{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDateHour"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'9', align:'center', 
											formatter: function(){
												return CFN_TransLocalTime(this.item.RegistDate);
											}
									}		/*등록일시*/ 
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
			url = "/groupware/resource/manage/getBookingOfResourceList.do";
			data = {
					"folderID": folderID,
					"bookingState": $("#bookingStateSelect").val(),
					"searchType" :  $("#searchTypeSelect").val(),
					"searchWord" :  $("#search").val(),
					"startDate":  $("#startDate").val(),
					"endDate" : $("#endDate").val()
			};
		}else{
			url = "/groupware/resource/manage/getResourceOfFolderList.do";
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
		$("#bookingStateSelect").bindSelectSetValue('');	
		$("#searchTypeSelect").bindSelectSetValue('');
		$("#search").val('');
		$("#startDate").val('');
		$("#endDate").val('');
		folderGrid.reloadList();
	}
	
	// 사용여부 변경
	function changeIsSwitch(pParam, pFlagValue, pTarget){
		let param = JSON.parse(pParam);
		let folderID = param.folderID;
		let flagKey = param.columnName;
	
		$.ajax({
			type: "POST",
			url: "/groupware/resource/manage/changeIsSwitch.do",
			data: {
				"folderID": folderID,
				"columnName": flagKey
			},
			success: function(data){
				if(data.status === 'SUCCESS'){
					Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); 	// 오류가 발생헸습니다.
					
					if (pFlagValue == 'Y') {
						$("#switch_"+folderID+"_"+flagKey).val($("#switch_"+folderID+"_"+flagKey).attr("off_value"));
						$(pTarget).removeClass("on");
					} else {
						$("#switch_"+folderID+"_"+flagKey).val($("#switch_"+folderID+"_"+flagKey).attr("on_value"));
						$(pTarget).addClass("on");
					}
				}
			},
			error: function(response, status, error){
				 CFN_ErrorAjax("/groupware/resource/manage/changeIsSwitch.do", response, status, error);
			}
		});
	}
	
	// 승인/거부/승인취소/반납확인 버튼 클릭시 실행되며, 선택한 항목에 대하여 처리를 합니다.
	function setApprovalState(dateIDs, state, comment) {
		//사용자 단의 API 사용
		$.ajax({
			url:"/groupware/resource/manage/modifyBookingState.do",
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
	 		 CFN_ErrorAjax("/groupware/resource/manage/modifyBookingState.do", response, status, error);
		 	}
		});
	}
	
	function modifyCurrentFolderPopup(){
		/* modifyFolderPopup(folderID); */
		
		var url = "/groupware/resource/manage/goResourceManageSetPopup.do";
		url += "?domainID="+confMenu.domainId;
		url += "&parentFolderID="+folderID;
		url += "&menuID="+menuID;
		url += "&folderID="+folderID;
		url += "&folderType="+ folderType;
		
		Common.open("","divResourceInfo","<spring:message code='Cache.lbl_ResourceManage_09'/>|||<spring:message code='Cache.msg_ResourceManage_09'/>",url,"620px","680px","iframe",true,null,null,true);
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
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_14'/>";	//승인요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_14'/>";	//승인요청 상태가 아닌 항목은 제외됩니다.
			
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
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_14'/>";	//승인요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_14'/>";	//승인요청 상태가 아닌 항목은 제외됩니다.
			
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
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_16'/>";	//승인 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_16'/>";	//승인 상태가 아닌 항목은 제외됩니다.
			
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
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_17'/>";	//반납요청 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_17'/>";	//반납요청 상태가 아닌 항목은 제외됩니다.
			
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

		Common.PromptArea(msgConfirm, "", "<spring:message code='Cache.lbl_Confirm'/>", function(result){ 
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
			msgConfirm += "<spring:message code='Cache.msg_ResourceManage_13'/>";	//거부/반납완료/자동취소 상태가 아닌 항목은 제외됩니다.
			msgWarning +="<spring:message code='Cache.msg_ResourceManage_13'/>";	//거부/반납완료/자동취소 상태가 아닌 항목은 제외됩니다.
			
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
					url:"/groupware/resource/manage/deleteBookingData.do",
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
			 			 CFN_ErrorAjax("/groupware/resource/manage/deleteBookingData.do", response, status, error);
			 		}
					
				});
			}
		});
	}
	
</script>