<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String searchWord = request.getParameter("searchWord");
	String searchType = request.getParameter("searchType");
	String searchWordStatus = request.getParameter("searchWordStatus");
	String searchTypeStatus = request.getParameter("searchTypeStatus");
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
%>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_myActivity'/></h2>						
	<div class="searchBox02" style="display:none;">
		<span>
			<input id="subjectSearchText" type="text">
			<button type="button" class="btnSearchType01" onclick="javascript:subjectSearch($('#subjectSearchText').val())"><spring:message code='Cache.btn_search'/></button>	<!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>	<!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Contents'/></span>	<!-- 내용 -->
				<select id="searchType" class="selectType02">
					<option value="Subject"><spring:message code='Cache.lbl_Title'/></option>	<!-- 제목 -->
					<option value="BodyText"><spring:message code='Cache.lbl_Contents'/></option><!-- 내용 -->
					<option value="CreatorName"><spring:message code='Cache.lbl_writer'/></option><!-- 작성자 -->
					<option value="Total"><spring:message code='Cache.lbl_Title'/> + <spring:message code='Cache.lbl_Contents'/></option>
				</select>
				<div class="dateSel type02">
					<input id="searchText" type="text">
				</div>											
			</div>
			<div>
				<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a> <!-- 검색 -->
			</div>
			<div class="chkGrade">									
				<div class="chkStyle01">
					<input type="checkbox" id="chkRead"><label for="chkRead"><span></span><spring:message code='Cache.lbl_Mail_Unread'/></label><!-- 읽지않음 -->
				</div>
			</div>
		</div>
		<div>
			<div class="selectCalView">
			<span><spring:message code='Cache.lbl_Period'/></span>	<!-- 기간 -->
				<select id="selectSearch" class="selectType02">
				</select>
				<div id="divCalendar" class="dateSel type02">
					<input class="adDate" type="text" id="startDate" date_separator="." readonly=""> - <input id="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" class="adDate" type="text" readonly="">
				</div>											
			</div>
		</div>
	</div>
	<div id="switchAllCont">	<!-- class: boardCommCnt, docAllCont -->
		<!-- #tabList -->
		<ul id="tabList" class="tabType2 clearFloat" style="display:none;">
		</ul>
		<div id="switchTopCnt" class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a href="#" id="btnWrite" class="btnTypeDefault btnThemeBg" onclick="javascript:addActivity();"><spring:message code='Cache.lbl_Write'/></a>	<!-- 작성 -->
				<a href="#" id="btnDelete" class="btnTypeDefault left" onclick="javascript:deleteActivity();"><spring:message code='Cache.lbl_delete'/></a>	<!-- 삭제 -->
				<a href="#" id="btnExcel" class="btnTypeDefault btnExcel" onclick="ExcelDownload();"><spring:message code='Cache.btn_SaveToExcel'/></a>	<!-- 엑셀저장 -->
				<a href="#" id="btnExcelSave" class="btnTypeDefault btnExcel" onclick="ExcelUpload();"><spring:message code='Cache.btn_ExcelUpload'/></a>	<!-- 엑셀저장 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button id="btnRefresh" class="btnRefresh" type="button"></button>
			</div>
		</div>
		<!-- 목록보기-->
		<div id="divListView" class="tblList tblCont">
			<div id="gridDiv"></div>
<!-- 			<div class="goPage"> -->
<!-- 				<input type="text"> <span> / 총 </span><span>1</span><span>페이지</span><a href="#" class="btnGo">go</a> -->
<!-- 			</div>							 -->
		</div>
	</div>												
</div>

<input type="hidden" id="hiddenMenuID" value=""/>
<input type="hidden" id="hiddenCU_ID" value=""/>
<input type="hidden" id="hiddenAT_ID" value=""/>
<input type="hidden" id="hiddenComment" value="" />

<script>
	//# sourceURL=ActivityList.jsp
	var communityId = typeof(cID) == 'undefined' ? 0 : cID;	// 커뮤니티ID
	var activeKey = typeof(mActiveKey) == 'undefined' ? 1 : mActiveKey;	// 커뮤니티 메뉴 Key
	
	//개별호출-일괄호출
	var sessionObj = Common.getSession(); //전체호출
	
	var lang = sessionObj["lang"];
	var userID = sessionObj["USERID"];
	
	var grid = new coviGrid();
	
	initContent();

	function initContent(){
		init();		// 초기화
		setGrid();	// 그리드 세팅
		search();	// 검색
	}
	
	// 초기화
	function init() {
		grid.page.pageSize =100;
		
		// 그리드 카운트
		$('#listCntSel').on('change', function(e) {
			grid.page.pageSize = $(this).val();
			grid.reloadList();
		});

		// 달력 옵션
		var timeInfos = {
			H : "", // 날짜 단위기 때문에 H는 없음.
			W : "1,2,3", //주 선택
			M : "1,2,3", //달 선택
			Y : "1" //년도 선택
		};
		var initInfos = {
			useCalendarPicker : 'Y',
			useTimePicker : 'N',
			useBar : 'Y',
			useSeparation : 'N',
		};
		
		coviCtrl.renderDateSelect('searchDate', timeInfos, initInfos);	 //검색 기간
		$("#searchDate_StartDate").val("");
		$("#searchDate_EndDate").val("");
	}
	
	var msgHeaderData;
	// 그리드 세팅
	function setGrid() {
		// header
		var headerData;
		var overflowCell =[];

		headerData = [
        	{key:'AT_ID',		label:'chk', width:'20', align:'center', formatter: 'checkbox'},
        	{key:'num',	label:'<spring:message code="Cache.lbl_Number"/>', width:'30', align:'center', sort: false, 
         		formatter:function(){
         			return formatRowNum(this);
         		}
        	},		//번호
			{key:'ATName', label:'Activity', width:'100', align:'left',
				formatter:function () {
					var isOwner = this.item.RegisterCode === userID ? "Y" : "N";
					var html = "<div class='tblLink'>";
					html += "<a onclick='openPop(\"" + communityId + "\", \"" + this.item.AT_ID + "\", \"" + isOwner + "\"); return false;'>";
					html += this.item.ATName;
					html += "</a>";
					html += "</div>";
					return html;
				}
			},
			{key:'Progress', label:'<spring:message code="Cache.lbl_ProgressRate" />', width:'40', align:'center', 
				formatter: function(){	return (this.item.Progress + '%');}
			},
			{key:'StartDate', label:'<spring:message code="Cache.lbl_startdate" />', width:'60', align:'center', 
				formatter: function(){	return this.item.StartDate;}
			},
			{key:'EndDate', label:'<spring:message code="Cache.lbl_EndDate" />', width:'60', align:'center', 
				formatter: function(){ return this.item.EndDate;}
			},
			{key:'RegistDate',	label:Common.getDic("lbl_RegistDate")+Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center', 
				formatter: function(){ return CFN_TransLocalTime(this.item.RegistDate,_ServerDateFullFormat );}
			}
		];
		overflowCell = [2];
	
		grid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			height:"auto",
			paging : false,			
			colHeadTool: false,
			overflowCell: overflowCell
		};
		grid.setGridConfig(configObj);
		
		msgHeaderData = headerData;
	}
	
	function formatRowNum(pObj){
		return pObj.index+1;
	}
	
	// 검색
	function search() {
		grid.page.pageSize =500;
		var searchDate = coviCtrl.getDataByParentId('searchDate');
		var params = {reqType : "A",
					  schContentType : $('#schContentType').val(),
					  schTxt : $('#schTxt').val(),
					  simpleSchTxt : $('#simpleSchTxt').val(), /* 상단 간편검색 제목 기준 */
					  CU_ID : communityId,
					  startDate : searchDate.startDate,
					  endDate : searchDate.endDate
					  };
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/tf/getMyActivityList.do",
			ajaxPars : params
		});
	}
	
	// 제목 클릭 
	function openPop(pcommunityId, ActivityId, isOwner) {
		Common.open("","ActivitySet","<spring:message code='Cache.btn_Modify' />","/groupware/tf/goActivitySetPopup.do?mode=MODIFY&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+pcommunityId+"&ActivityId="+ActivityId+"&isOwner="+isOwner, "950px", "650px","iframe", true,null,null,true);
	}

	//추가
	function addActivity(){
		Common.open("","ActivitySet","<spring:message code='Cache.lbl_Write' />","/groupware/tf/goActivitySetPopup.do?mode=ADD&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+communityId ,"950px", "650px","iframe", true,null,null,true);
	}
	// 삭제
	function deleteActivity() {
		var params = new Object();
		var AT_IDs = "";
		var checkedObj = Activitygrid.getCheckedList(0);
		var isAdmin = Common.getSession("isAdmin");
		var userCode = Common.getSession("UR_Code");
		var chkLen = checkedObj.filter(function(obj){
			return obj.RegisterCode == userCode;
		}).length;
		
		if(checkedObj.length > 0 
			&& isAdmin != "Y"
			&& chkLen == 0){
			if(chkDelAuth(checkedObj[0].CU_ID)){
				Common.Warning("<spring:message code='Cache.msg_noDeleteACL' />"); // 삭제 권한이 없습니다.
				return false;
			}
		}
		
	    $('#gridDiv_AX_gridBodyTable tr').find('input[type="checkbox"]:checked').each(function () {
	    	AT_IDs += this.value+";";
	    });
		params.AT_ID = AT_IDs;
		params.communityId = communityId;
		
      	Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/tf/deleteTask.do",
					success:function (data) {
						if(data.status == 'SUCCESS') {
							Common.Inform("<spring:message code='Cache.msg_50' />", "Inform", function() {
								search();	// 검색
							});
	          		} else {
		          			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
	          		}
					},
					error:function(response, status, error) {
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
	
	//TaskExcelUpload
	function ExcelUpload(){
		var url = String.format("/groupware/tf/goTFTaskExcelUploadPopup.do?bizSection=TF&mode=C&CU_ID={0}",cID );
		var titlemessage = Common.getDic("btn_ExcelUpload");
		
		Common.open("","target_pop", titlemessage,url,"499px","250px","iframe",true,null,null,true);
	}
	
	// 템플릿 파일 다운로드
	function ExcelDownload() {
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var headerName = getHeaderNameForExcel();
    			var headerKey = getHeaderKeyForExcel();
    			var sortInfo = grid.getSortParam("one").split("=");
    			var	sortBy = sortInfo.length > 1 ? sortInfo[1] : "";
    			var url = String.format("/groupware/tf/ExcelDownload.do?bizSection={0}&headerName={1}&headerKey={2}&CU_ID={3}&sortBy={4}", 
    				"TF", 
    				encodeURI(headerName),
    				headerKey, 
    				communityId,
    				sortBy);
    			location.href = url;
       		}
		});
	}
	
	//엑셀용 Grid 헤더정보 설정
	function getHeaderNameForExcel(){
		var returnStr = "";
		
		for(var i=0;i<msgHeaderData.length; i++){
			if(msgHeaderData[i].display != false &&
				msgHeaderData[i].label != '' && 
				msgHeaderData[i].key != 'FileCnt' &&
				msgHeaderData[i].key != 'chk' && 
				msgHeaderData[i].label != 'chk' && 
				msgHeaderData[i].key != 'CreatorCode' && 
				msgHeaderData[i].key != 'Depth' && 
				msgHeaderData[i].key != 'Step' &&
				msgHeaderData[i].key != 'Seq' &&  
				msgHeaderData[i].key != 'num' &&  
				msgHeaderData[i].key != 'FolderID'){
				returnStr += msgHeaderData[i].label + "|";
			}
		}
	   	
		returnStr = returnStr.substring(0, returnStr.length-1);
		return returnStr;
	}
	
	function getHeaderKeyForExcel(){
		var returnStr = "";
		
		for(var i=0;i<msgHeaderData.length; i++){
			if(msgHeaderData[i].display != false && 
				msgHeaderData[i].label != '' && 
				msgHeaderData[i].key != 'chk' && 
				msgHeaderData[i].label != 'chk' && 
				msgHeaderData[i].key != 'FileCnt' &&
				msgHeaderData[i].key != 'CreatorCode' && 
				msgHeaderData[i].key != 'Depth' && 
				msgHeaderData[i].key != 'Step' &&
				msgHeaderData[i].key != 'Seq' &&  
				msgHeaderData[i].key != 'num' &&  
				msgHeaderData[i].key != 'FolderID'){
					returnStr += msgHeaderData[i].key.replace("a.","") + ",";
			}
		}
	   	
		returnStr = returnStr.substring(0, returnStr.length-1);
		return returnStr;
	}
	
	function chkDelAuth(cID){
		var result = true;
		var userCode = Common.getSession("UR_Code");
		
		$.ajax({
			url: "/groupware/layout/selectTFDetailInfo.do",
			type: "POST",
			data: {
				"CU_ID" : cID
			},
			async: false,
			success: function(data){
				if(data.status == "SUCCESS"){
					var tfInfo = data.TFInfo[0];
					var pmCodes = tfInfo.TF_PM.split("@");
					var adminCodes = tfInfo.TF_Admin.split("@");
					var pmLen = pmCodes.map(function(code){
						return code.split("|")[0];
					}).filter(function(code){
						return code == userCode;
					}).length;
					var adminLen = adminCodes.map(function(code){
						return code.split("|")[0];
					}).filter(function(code){
						return code == userCode;
					}).length;
					
					if(pmLen + adminLen > 0) result = false;
				}
			},
			error: function(error){
				CFN_ErrorAjax("/groupware/project/getProjectInfoOne.do", response, status, error);
			}
		});
		
		return result;
	}
</script>			