<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%-- <c:set var="mnid" value="485"/> --%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.CN_107"/></span> <!-- 부서 문서보기 -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02 active" id="DetailSearch">
		<div>
			<a href="#" class="btnTypeDefault nonHover" onclick="OrgMap_Open(0);"><spring:message code="Cache.btn_apv_deptselect"/></a> <!-- 부서선택 -->
			<span id="deptNm" class="ml10"></span>
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
		<input type="hidden" id="deptId" value="" />
	</div>
</div>

<script>
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var gridCount = 0;					// gridCount 라는 변수는 각 함에서 동일하게 사용
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var g_listMode  = "";				// 메뉴구분
	var approvalListType = "dept";					// 공통 사용 변수 - 결재함 종류 표현 - 개인결재함
	var g_mode  = "dept";
	var popmode  = "";
	var gloct 	= "";
	var subkind = "";
	var userID  = Common.getSession("USERID");
	var bstored = "false";
	
	initAdminDeptList();
	
	function initAdminDeptList(){
		setSelectAdmin(ListGrid, g_mode);
	}

	function setGrid(){
		setGridConfig();
		setApprovalListData();
	}

	function setGridConfig(){
		if(g_listMode == "DeptComplete" || g_listMode == "SenderComplete" || g_listMode == "ReceiveComplete"){ //완료함 || 발신함 || 수신처리함
			 headerData =[
			                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},					// 구분
			                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100', align:'center',						    // 제목
							   	  formatter:function () {
							   		return "<a onclick='onClickPopButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
									}
			                  },
			                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center'},				        // 기안부서
			                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center'},						// 기안자
			                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center', sort:false},							// 파일
			                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'
			                	  , formatter:function () { return CFN_GetDicInfo(this.item.FormName); } },							        					// 양식명
			                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center'},							        	// 문서번호
			                  {key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center', sort:'desc'}					// 일시
			             ];			    
		}else if(g_listMode == "Receive"){ //수신함
			 headerData =[
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},					   	// 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150', align:'center',						       	// 제목
						   	  formatter:function () {
						   		return "<a onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center'},				           	// 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center'},						   	// 기안자
		                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center', sort:false},							   	// 파일
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'
		                	  , formatter:function () { return CFN_GetDicInfo(this.item.FormName); } },								 	   						// 양식명
		                  {key:'Created', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center', sort:'desc'}				   		// 일시
		               	];
		}else if(g_listMode == "DeptTCInfo"){ //참조회람함
			 headerData =[
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},					    // 구분
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'
		                	  , formatter:function () { return CFN_GetDicInfo(this.item.FormName); } },							            					// 양식명
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150', align:'center',						        // 제목
						   	  formatter:function () {
						   		return "<a onclick='onClickPopButton(\""+this.item.ProcessID+"\",\"\",\"\",\"\",\"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center'},				            // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center'
		                	  , formatter:function () { return CFN_GetDicInfo(this.item.InitiatorName); } },						    						// 기안자
		                  {key:'InitiatedDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center', sort:'desc'}			    // 일시
		                ];
		}else{ //진행함
			 headerData =[
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false},					   	// 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150', align:'center',						       	// 제목
						   	  formatter:function () {
						   		return "<a onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.Mode+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center'},				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center'},						   // 기안자
		                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center', sort:false},							   // 파일
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'								 	   // 양식명
		                	  , formatter:function () { return CFN_GetDicInfo(this.item.FormName); } 
		                  },
		                  {key:'Created', label:'<spring:message code="Cache.lbl_RepeateDate"/>',  width:'60', align:'center', sort:'desc'},				   // 일시
		                  {key:'UserName', label:'<spring:message code="Cache.lbl_Res_Admin"/>',  width:'60', align:'center', sort:'desc'}
		                 ];
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
			
			setSelectParams(ListGrid);// 공통 함수
			selectParams.startDate = $("#startdate").val();
			selectParams.endDate = $("#enddate").val();
			ListGrid.page.pageNo = 1;
			ListGrid.bindGrid({
				//ajaxUrl:"user/getApprovalListData.do?&mn_id="+${mnid}+"",
				ajaxUrl:"/approval/user/getDeptApprovalListData.do?&mode="+g_listMode+"",
				ajaxPars: selectParams,
				onLoad: function(){
					//setGridCount();
				}
			});
		}
	}

// 	function setGridCount(){
// 		gridCount = ListGrid.page.listCount;
// 		$("#approvalCnt").html(gridCount);
// 	}


	function setSearchGroupWord(id){														// 공통함수에서 호출
		$("#hiddenGroupWord").val(id);
		setApprovalListData();
	}

	function onClickSearchButton(bChangeConfig){
		if($("#deptId").val() == ""){
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_deptselect' />");		//부서를 선택해주십시오.
			return false;
		}
		if(bChangeConfig) setGridConfig();
		//setGroupType(ListGrid,"user/getApprovalGroupListData.do?&mn_id=${mnid}");			// 공통함수. 그룹별 보기 목록 다시 조회함.
		setApprovalListData();
	}
	function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,Mode,SubKind,UserCode,FormPrefix,FormID,BusinessData1,BusinessData2){
		var width;
		var archived = "true";
		switch (g_listMode){
			case "DeptComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="A"; userID = UserCode; break;
			case "SenderComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="S"; userID = UserCode; break;
			case "Receive" : mode =  Mode; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = UserCode; break;
			case "ReceiveComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="REQCMP"; userID = UserCode; break;
			case "DeptTCInfo" : mode = "COMPLETE"; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = ""; break;
			case "DeptProcess" : mode =  Mode; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = UserCode; break;
		}
		
		if(IsWideOpenFormCheck(FormPrefix, FormID) == true){
			width = 1070;
		}else{
			width = 790;
		}
		
		// 관리자에서 사용자 문서볼때 읽음확인 이력이 남아서 수정함.
		CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="
				+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&admintype=&archived="
				+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+""
				+"&ExpAppID="+((typeof BusinessData2!="undefined"&&BusinessData2!="undefined")?BusinessData2:"")
				, "", width, (window.screen.height - 100), "resize");
		
	}
	//부서선택 버튼 클릭시 호출될 조직도 팝업.
	function OrgMap_Open(mapflag){
		flag = mapflag;
		//다국어: 조직도
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=C1","1060px","580px","iframe",true,null,null,true);		  
	}
	// 조직도 데이터
	parent._CallBackMethod2 = setOrgMapData;
	function setOrgMapData(data){
		var dataObj = $.parseJSON(data);
		$("#deptId").val(dataObj.item[0].AN);
		$("#deptNm").html(CFN_GetDicInfo(dataObj.item[0].DN));
		g_listMode = $("#selectSearchTypeAdmin").val();
		$("#approvalListGrid").show();
		setGrid();
		coviInput.setDate();
	}
</script>