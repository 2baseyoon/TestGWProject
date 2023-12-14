<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.CN_106"/></span> <!-- 사용자 문서보기 -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02 active" id="DetailSearch">
		<div>
			<a href="#" class="btnTypeDefault nonHover" onclick="OrgMap_Open(0);"><spring:message code="Cache.btn_UserAdd"/></a> <!-- 사용자선택 -->
			<span id="userNm" class="ml10"></span>
		</div>
		<div>
			<div class="selectCalView" style="margin:0;">
				<select class="selectType02 w120p" id="selectSearchTypeAdmin" style="height:32px;"></select>
				<div class="dateSel type02">
					<input class="adDate" id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" />
						<span>~</span>
					<input class=" adDate" id="enddate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate" />
				</div>
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="onClickSearchButton();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize" onchange="onClickSearchButton(true);">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id='groupLiestArea' style='display: none;'></div>
			<div id="approvalListGrid" style="display: none;"></div>
		</div>
		<input type="hidden" id="hiddenGroupWord" value="" />
		<input type="hidden" id="userId" value="" />
		<input type="hidden" id="selectEntCode" value="" />	
	</div>
</div>

<script>
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var gridCount = 0;					// gridCoaunt 라는 변수는 각 함에서 동일하게 사용
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var approvalListType = "user";					// 공통 사용 변수 - 결재함 종류 표현 - 개인결재함
	var g_mode  = "user";
	var g_listMode  = "";				// 메뉴구분
	var gloct 	= "";
	var subkind = "";
	var popmode = "user";
	var userID  = "";
	var bstored = "false";

	initAdminUserList();
	
	function initAdminUserList(){
		setSelectAdmin(ListGrid, g_mode);
		setGrid();
	}

	function setGrid(){
		ListGrid = new coviGrid();
		
		setGridConfig();
		setApprovalListData();
	}

	function setGridConfig(){
		if(g_listMode == "PreApproval"){ //예고함
			 headerData =[
			              {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},									// 구분
			              {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150',						    								// 제목
						 	  	formatter:function () {
						 			return "<a onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.FormSubKind+"\",\"\",\"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
			              },
			              {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',},				        			// 기안부서
			              {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',},										// 기안자
			              {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center', sort:false},											// 파일
			              {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'													// 양식명
			              	  , formatter:function () { return CFN_GetDicInfo(this.item.FormName); } },
			              {key:'Created', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center'}];			    							// 일시
		}else if(g_listMode == "Approval" || g_listMode == "Process"){ // 미결함||진행함
			 headerData =[
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},								    // 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100',									     				  	// 제목
						   	  	formatter:function () {
						   			return "<a onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.FormSubKind+"\",\"\",\"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
							  	}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center'},				            			// 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center'},						    			// 기안자
		                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center', sort:false},											// 파일
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',
		                	  	formatter:function () { return CFN_GetDicInfo(this.item.FormName); } 
		                  },							            								// 양식명
		                  {key:'Created', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center'},			        							// 일시
		                  {key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center'},					            			// 의견
		                  {key:'IsModify', label:'<spring:message code="Cache.lbl_Modify"/>', width:'30', align:'center'}];								        			// 수정
		}else if(g_listMode == "Complete" || g_listMode == "Reject"){ //완료함 || 반려함
			 headerData =[
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},								   	// 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100',						       								// 제목
						   	  formatter:function () {
						   		return "<a onclick='onClickPopButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormSubKind+"\",\"\",\"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center'},				           				// 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center'},						   				// 기안자
		                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center', sort:false},										   	// 파일
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'
		                	  , formatter:function () { return CFN_GetDicInfo(this.item.FormName); } },								 	   									// 양식명
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center'},									   					// 문서번호
		                  {key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center', sort:'desc', sort:false},				   	// 일시
		                  {key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center', sort:false},							   	// 의견
		                  {key:'IsModify', label:'<spring:message code="Cache.lbl_Modify"/>', width:'30', align:'center'}];								       				// 수정
		}else if(g_listMode == "TempSave"){ //임시함
			 headerData =[
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},								    // 구분
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'},							            			// 양식명
		                  {key:'Subject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'300',						        								// 제목
						   	  	formatter:function () {
						   			return "<a onclick='onClickPopButton(\"\",\"\",\"\",\"\",\"\",\""+this.item.FormTempInstBoxID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormID+"\",\""+this.item.FormInstTableName+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\"); return false;'>"+this.item.Subject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
		                  },
		                  {key:'CreatedDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center', sort:'desc'}];			        		// 일시
		}else{ //참조/회람함
			 headerData =[
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},								   	// 구분
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'
		                	  , formatter:function () { return CFN_GetDicInfo(this.item.FormName); } },							            								// 양식명
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150',						        							// 제목
						   	  formatter:function () {
						   		return "<a onclick='onClickPopButton(\""+this.item.ProcessID+"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center'},				            			// 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center'},						    			// 기안자
		                  {key:'InitiatedDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center'}];			        					// 일시
		}
		
		ListGrid.setGridHeader(headerData);
		var configObj = {
			targetID : "approvalListGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true
		};
		
		ListGrid.setGridConfig(configObj);
	}

	function setApprovalListData(){
		if(searchValueValidationCheck()){		// 공통 함수
			
			// 참조/회람함 정렬 옵션 강제 추가
			if (g_listMode == "TCInfo") {
				var sortObj = new Object();
				sortObj.key = "RegDate";
				sortObj.isLastCell = false;
				sortObj.display = false;
				sortObj.sort = "desc";
				ListGrid.nowSortHeadObj = sortObj;
			} 
		
			setSelectParams(ListGrid);// 공통 함수
			selectParams.startDate = $("#startdate").val();
			selectParams.endDate = $("#enddate").val();
			ListGrid.page.pageNo = 1;
 			ListGrid.bindGrid({
				ajaxUrl:"/approval/user/getApprovalListData.do?&mode="+g_listMode+"",
				ajaxPars: selectParams,
			});
		}
	}

	function setGridCount(){
		gridCount = ListGrid.page.listCount;
		$("#approvalCnt").html(gridCount);
	}


	function setSearchGroupWord(id){														// 공통함수에서 호출
		$("#hiddenGroupWord").val(id);
		setApprovalListData();
	}

	function onClickSearchButton(bChangeConfig){
		if($("#userId").val() == ""){
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_userselect' />");		//사용자를 선택해주십시오.
			return false;
		}
		if(bChangeConfig) setGridConfig();
		//setGroupType(ListGrid,"user/getApprovalGroupListData.do?&mn_id=${mnid}");			// 공통함수. 그룹별 보기 목록 다시 조회함.
		setApprovalListData();
	}
	function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix,BusinessData1,BusinessData2,TaskID){
		var width;
		var archived = "false";
		switch (g_listMode){
			case "PreApproval" : mode="PREAPPROVAL"; gloct = "PREAPPROVAL"; subkind="T010"; userID=UserCode; break;
			case "Approval" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;
			case "Process" : mode="PROCESS"; gloct = "PROCESS"; subkind=SubKind; userID=UserCode; break;
			case "Complete" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;
			case "Reject" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;
			case "TempSave" : mode="TEMPSAVE"; gloct = "TEMPSAVE"; subkind="";  userID=""; break;
			case "TCInfo" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;
		}
		
		if(IsWideOpenFormCheck(FormPrefix, FormID) == true){
			width = 1070;
		}else{
			width = 790;
		}
		
		// 관리자에서 사용자 문서볼때 읽음확인 이력이 남아서 수정함.
		CFN_OpenWindow("/approval/approval_Form.do?mode="+(mode=="TEMPSAVE"?mode:"ADMIN")
				+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID
				+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="
				+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived
				+"&usisdocmanager=true&listpreview=N&subkind="+subkind+""
				+"&ExpAppID="+((typeof BusinessData2!="undefined"&&BusinessData2!="undefined")?BusinessData2:"")
				, "", width, (window.screen.height - 100), "resize");
	}
	//부서선택 버튼 클릭시 호출될 조직도 팝업.
	function OrgMap_Open(mapflag){
		flag = mapflag;
		//다국어: 조직도
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B1","1060px","580px","iframe",true,null,null,true);
	}
	// 조직도 데이터
	parent._CallBackMethod2 = setOrgMapData;
	function setOrgMapData(data){
		var dataObj = $.parseJSON(data);	
		$("#userId").val(dataObj.item[0].AN);
		$("#userNm").html(CFN_GetDicInfo(dataObj.item[0].DN));
		g_listMode = $("#selectSearchTypeAdmin").val();
		$("#approvalListGrid").show();
		setGrid();
		//
	}
</script>