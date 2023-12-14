<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	pageContext.setAttribute("isUseAccount", PropertiesUtil.getExtensionProperties().getProperty("isUse.account")); 
%>

<c:if test="${isUseAccount eq 'N'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/eaccounting/resources/css/eaccounting.css"></c:if>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>

<style>
	.btn_search03 {background-color: white;}
	.name_box{font-size: 13px;}
</style>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_unitTaskManage'/></h2> <!-- 단위업무 관리 -->
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			<button id="simpleSearchBtn" type="button" onclick="onClickSearchButton();" class="btnSearchType01"><spring:message code="Cache.btn_search"/></button> <!-- 검색 -->
		</span>
		<a id="detailSchBtn" onclick="detailDisplay(this);" class="btnDetails">
			<spring:message code="Cache.lbl_apv_detail"/> <!-- 상세 -->
		</a>
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02 appSearch" id="DetailSearch" >
		<div style="width:520px;">
			<div class="selectCalView">
				<!--<span>* 제목+: 제목+기안자명+기안부서명 검색</span><br/>  todo: 다국어처리 필요 -->
				<span><spring:message code='Cache.lbl_Contents'/></span>	<!-- 내용 -->
				<div class="selBox" style="width: 120px;" id="selectsearchType"></div>
				<input type="text" id="titleNm" style="width: 202px;" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}" >
				<a id="detailSearchBtn"  onclick="onClickSearchButton()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
		<div style="width:520px; margin-bottom: 0;">
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_selection'/></span>	<!-- 선택 -->			
				<select id="selBaseYear" class="selectType02"></select>	
				<select id="subDeptList" class="selectType02"></select>	
				
				<select id="selKeepPeriod" class="selectType02" style="width: 120px;"></select>
				<select id="selRevokeStatus" class="selectType02" style="width: 120px;">
					<option value=""><spring:message code='Cache.lbl_all'/></option> <!-- 전체 -->
					<option value="1"><spring:message code='Cache.lbl_establishment'/></option> <!-- 신설 -->
					<option value="2"><spring:message code='Cache.lbl_abolition'/></option> <!-- 폐지 -->
					<option value="3"><spring:message code='Cache.lbl_apv_change' /></option> <!-- 변경 -->
				</select>
			</div>
		</div>
	</div>
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="excelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a> <!-- 엑셀저장 -->
				<a id="uploadExlBtn" class="btnTypeDefault btnExcel" onclick="openModifyPopup('Excel');"><spring:message code='Cache.btn_ExcelUpload' /></a> <!-- 엑셀 업로드 -->
				<a id="establishBtn" class="btnTypeDefault" onclick="openAddPopup('I');"><spring:message code='Cache.lbl_establishment'/></a><!-- 신설 -->
				<a id="revokeBtn" class="btnTypeDefault" onclick="chkModifySeries('Revoke');"><spring:message code='Cache.lbl_abolition'/></a><!-- 폐지 -->
				<a id="restoreBtn" class="btnTypeDefault" onclick="chkModifySeries('Restore');"><spring:message code='Cache.lbl_abolitionRestore'/></a><!-- 폐지복원 -->
				<a id="syncSeriesBtn" class="btnTypeDefault" onclick="syncSeries();" style="display:none"><spring:message code='Cache.lbl_Synchronization'/></a><!-- 동기화 : 커스텀 버튼(사용시 별도 open)-->
				<a id="createNextYearSeriesDataBtn" class="btnTypeDefault" onclick="CreateNextYearSeriesData();" style="display:none;"><spring:message code='Cache.lbl_CreateNextYearSeriesData' /></a><!-- 차년도 단위업무 데이터 복사 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount" onchange="setGrid();">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="apprvalBottomCont">
			<div class="appRelBox">
				<div class="contbox">
					<div class="conin_list" style="width:100%;">
						<div id="seriesListGrid"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<script>
	var ListGrid = new coviGrid();
	var seriesHeaderData;
	var isAdmin = "";
	let isRecordDeptAdmin = 'N';
	var baseYear = "";
	var UseRecordDataCreateNextYear = Common.getBaseConfig('UseRecordDataCreateNextYear');	// 기록물철/단위업무 차년도 데이터 생성 사용 여부
	
	//일괄 호출 처리
	initApprovalListComm(init, setGrid);
	
	function init(){
		setDeptList();
		setYearList();
		selectInit();
		setCombo();
		setGrid();
		initActive();
		
		$("#selBaseYear, #subDeptList, #selKeepPeriod, #selRevokeStatus").on("change", onClickSearchButton);
		// 차년도 데이터 생성여부 체크
		if(UseRecordDataCreateNextYear == "Y") {
			$("#createNextYearSeriesDataBtn").show();
		}
		setRecordDeptAdmin();
		setDeptAdmin();
	}
	
	function setCombo(){
		var lang = Common.getSession("lang");
		
		var initInfos = [
			{
				target: "selKeepPeriod",
				codeGroup: "KeepPeriod"
			}
		];
		
		coviCtrl.renderAjaxSelect(initInfos, '', lang);
		$('#selKeepPeriod').prepend("<option value='' selected><spring:message code='Cache.lbl_all'/></option>");
	}
	
	function setYearList(){
		$.ajax({
			url: "/approval/user/getSeriesBaseYearList.do",
			type: "POST",
			dataType: "json",
			async: false,
			success: function(data){
				baseYear = new Date().getFullYear();
				var list = data.list;
				var baseYearHtml = "";
				if(isAdmin == "Y"){
					list.unshift({"BaseYear" : "<spring:message code='Cache.lbl_all'/>"});
				}
				
				$.each(list, function(idx, item){
					baseYearHtml += "<option value='"+item.BaseYear+"'>"+item.BaseYear+"</option>";
				});
				
				$("#selBaseYear").html(baseYearHtml);
				$("#selBaseYear").val(baseYear);
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
			}
		});
	}
	
	function setDeptList(){
		$.ajax({
			url: "/approval/user/getDeptSchList.do",
			type: "POST",
			dataType: "json",
			async: false,
			success: function(data){
				isAdmin = data.isAdmin;
				var subDeptList = data.list;
				var subDeptOption = "";
				var selDept = "";
				
				if(isAdmin == "Y"){
					subDeptOption += "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
				}else{
					selDept = Common.getSession("DEPTID");
				}
				
				$.each(subDeptList, function(idx, item){
					subDeptOption += "<option value='"+item.GroupCode+"'>"+item.TransMultiDisplayName+"</option>";
				});
				
				$("#subDeptList").html(subDeptOption);
				$("#subDeptList").val(selDept);
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
			}
		});
	}
	
	function selectInit(){
		$.ajax({
			url: "/approval/user/selectRecordDocComboData.do",
			type: "POST",
			dataType: "json",
			async: false,
			success: function(data){
				$(".selBox").each(function(i, obj) {
					var id = $(obj).attr("id");
					var width = "width: " + $(obj).css("width");
					var listName = id.replace("select", "") + "List";
					var list = data[listName];
					
					list.push({"optionValue" : "SeriesCode", "optionText" : "<spring:message code='Cache.lbl_unitTaskCode'/>"});							
					
					list = list.filter(function(item){ return item.optionValue != "RecordSubject";});
					
					searchHtml = "<span class=\"selTit\" ><a id=\"seSearchID_"+id.replace("select", "")+"\" target=\""+id+"\" onclick=\"clickSelectBox(this);\" value=\""+list[0].optionValue+"\" class=\"up\">"+list[0].optionText+"</a></span>"
					searchHtml += "<div class=\"selList\" style=\""+width+";display: none;\">";
					$(list).each(function(index){
						searchHtml += "<a class=\"listTxt\" value=\""+this.optionValue+"\" target=\""+id+"\" onclick=\"clickSelectBox(this); \" id=\""+"sch_"+this.optionValue+"\">"+this.optionText+"</a>"
					});
					searchHtml += "</div>";
					
					$("#"+id).html(searchHtml);
				});
			}
		});
	}
	
	function setRecordDeptAdmin(){
		$.ajax({
			url: '/approval/user/getRecordDeptAdmin.do',
			type: 'POST',
			data: {'UserId': sessionObj.USERID},
			async: false,
			success: function(data){
				if(data.Cnt >0){
					isRecordDeptAdmin = 'Y';
				}
			},
			error: function(response, status, error){
				Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
			},
		});
	}
	
	function setDeptAdmin(){
		if(isAdmin != "Y" && isRecordDeptAdmin != "Y"){
				document.getElementById('uploadExlBtn').style.display = "none";
				document.getElementById('revokeBtn').style.display = "none";
				document.getElementById('establishBtn').style.display = "none";	
				document.getElementById('restoreBtn').style.display = "none";
				document.getElementById('createNextYearSeriesDataBtn').style.display = "none";		
		}
	}
	
	//새로고침
	function Refresh(){
		setSeriesListData();
	}
	
	function setGrid(){
		setGridConfig();
		setSeriesListData();
	}

	function setGridConfig(){
		var headerData = [
							{key:'chk', label:'chk', width:'10', align:'center', formatter:'checkbox', sort:false},
							{key:'SeriesCode', label:'<spring:message code="Cache.lbl_unitTaskCode"/>', width:'20', align:'center'}, // 단위업무 코드
							{key:'SeriesName', label:'<spring:message code="Cache.lbl_unitTaskName"/>', width:'50', align:'center'}, // 단위업무명
							{key:'SeriesDescription', label:'<spring:message code="Cache.lbl_unitTaskDescription"/>', width:'30', align:'center', display: false}, // 단위업무 설명
							{key:'DeptName', label:'<spring:message code="Cache.lbl_apv_ManageDept"/>', width:'30', align:'center'}, // 처리과
							{key:'KeepPeriodTxt', label:'<spring:message code="Cache.lbl_preservationPeriod"/>', width:'15', align:'center'}, // 보존기간
							{key:'KeepPeriodReason', label:'<spring:message code="Cache.lbl_preservationPeriodReason"/>', width:'30', align:'center', display: false}, // 보존기간 책정사유
							{key:'KeepMethodTxt', label:'<spring:message code="Cache.lbl_preservationMethod"/>', width:'30', align:'center', display: false}, // 보존방법
							{key:'KeepPlaceTxt', label:'<spring:message code="Cache.lbl_preservationPlace"/>', width:'30', align:'center', display: false}, // 보존장소
							{key:'JobTypeTxt', label:'<spring:message code="Cache.lbl_JobKind"/>', width:'15', align:'center'}, // 작업유형
							{key:'ApplyDate', label:'<spring:message code="Cache.lbl_applyBaseDate"/>', width:'30', align:'center'} // 적용기준일
						];
		
		seriesHeaderData = headerData;
		ListGrid.setGridHeader(headerData);
	
		var configObj = {
			targetID: "seriesListGrid",
			height: "auto",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", // 개
			body: {
				onclick: function(){
					if(this.item.JobType == "2" || (isAdmin != "Y" && isRecordDeptAdmin != "Y")){
						openAddPopup("R", this.item.SeriesCode, this.item.DeptCode, this.item.BaseYear);
					}else{
						openAddPopup("M", this.item.SeriesCode, this.item.DeptCode, this.item.BaseYear);
					}
					
				}
			},
			page: {
				pageNo: 1,
				pageSize: $("#selectPageSize").val()
			},
			paging: true,
		};
		
		ListGrid.setGridConfig(configObj);
	}
	
	function setSelectParam(){
		var params = {};
		var deptCode = $("#subDeptList").val();
		var keepPeriod = $("#selKeepPeriod").val() == "KeepPeriod" ? "" : $("#selKeepPeriod").val();
		var sfCode = $("#sfNm").attr("sfcode") == undefined ? "" : $("#sfNm").attr("sfcode");
		var searchType = $("#searchType").val();
		var searchWord = $("#searchInput").val();
		var revokeStatus = $("#selRevokeStatus").val();
		var baseYear = $("#selBaseYear").val();
		if (baseYear == "전체") baseYear = "";
		
		$(".selBox").each(function(i, obj) {
			var key = $(obj).attr("id").replace("select", "");
			var value = $("#seSearchID_" + key).attr("value");
			params[key] = value;
		});
		
		if ($('#DetailSearch').css('display') == "none") { // all
			params.searchType = "all";
			params.searchWord = $("#searchInput").val();
		} else if ($('#DetailSearch').css('display') == "block"){ // 상세검색
			params.searchWord = $("#titleNm").val();
		}
		params.deptCode = deptCode; 
		params.keepPeriod = keepPeriod;
		params.sfCode = sfCode;
		params.revokeStatus = revokeStatus;
		params.baseYear = baseYear;
		return params;
	}
	
	function setSeriesListData(){
		var selectParams = setSelectParam();
		
		ListGrid.bindGrid({
			ajaxUrl: "/approval/user/getSeriesListData.do",
			ajaxPars: selectParams,
			onLoad: function(){
				$(".gridBodyTable > tbody > tr").css("cursor", "pointer");
				coviInput.init();
			}
		});
	}
	
	function onClickSearchButton(){
		ListGrid.page.pageNo = 1;
		setSeriesListData();
	}
	
	function openAddPopup(mode, seriesCode, deptCode, BaseYear){
		var url = "/approval/user/SeriesAddPopup.do?mode="+mode;
		var popupName = "<spring:message code='Cache.lbl_newUnitTask' />"; // 단위업무 신설
		
		if(mode == "M"){
			url += "&seriesCode="+seriesCode+"&deptCode="+deptCode+"&baseYear="+BaseYear;
			popupName = "<spring:message code='Cache.lbl_modifyUnitTask' />"; // 단위업무 수정
		}else if(mode == "R"){
			url += "&seriesCode="+seriesCode+"&deptCode="+deptCode;
			popupName = "<spring:message code='Cache.lbl_unitTaskCheck' />"; // 단위업무 조회
		}
		
		Common.open("", "addSeries", popupName, url, "400px", "530px", "iframe", true, null, null, true);
	}
	
	function openModifyPopup(mode, seriesCode, deptCode, baseYear){
		var url = "/approval/user/SeriesModifyPopup.do?mode="+mode;
		var popupName = "";
		var width = "", height = "";
		
		switch(mode){
			case "Excel": 
				width = "500px";
				height = "180px";
				popupName = "<spring:message code='Cache.btn_ExcelUpload' />"; // 엑셀 업로드
				break;
			case "Revoke": 
				width = "500px";
				height = "240px";
				url += "&seriesCode=" + seriesCode
					+  "&deptCode="   + deptCode
					+  "&baseYear="   + baseYear					
				popupName = "<spring:message code='Cache.lbl_abolition' />"; // 폐지
				break;
		}
		
		Common.open("", "modifySeries", popupName, url, width, height, "iframe", true, null, null, true);
	}
	
	function chkModifySeries(mode){
		var checkList = ListGrid.getCheckedList(0);

		if(checkList != null && checkList != ""){
			if(checkList.length > 1){
				Common.Inform('<spring:message code="Cache.msg_SelectOne" />'); // 한개만 선택되어야 합니다
			}else if(checkList.length == 0){
				Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
			}else{
				if(mode == "Revoke" && checkList[0].JobType == "2"){
					Common.Inform('<spring:message code="Cache.msg_alreadyAbolitionUnitTask" />'); // 이미 폐지된 단위업무입니다.
				}else if(mode == "Restore" && checkList[0].JobType != "2"){
					Common.Inform('<spring:message code="Cache.msg_notAbolitionUnitTask" />'); // 폐지되지 않은 단위업무입니다.
				}else if(mode == "Restore" && checkList[0].JobType == "2"){
					restoreSeries(checkList[0].SeriesCode, checkList[0].DeptCode, checkList[0].BaseYear);
				}else{
					openModifyPopup(mode, checkList[0].SeriesCode, checkList[0].DeptCode, checkList[0].BaseYear);
				}
			}
		}else{
			Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
		}
	}
	
	// 상세검색 열고닫기
	function detailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			$("#DetailSearch").removeClass("active");
		}else{
			$(pObj).addClass("active");
			$("#DetailSearch").addClass("active");
		}
		
		$(".contbox").css("top", $(".content").height());
		coviInput.setDate();
	}
	
	function initActive(){
		$("#detailSchBtn").addClass("active");
		$("#DetailSearch").addClass("active");
		
		$(".contbox").css("top", $(".content").height());
		coviInput.setDate();
	}
	
	function syncSeries(){
		var pBaseYear = $("#selBaseYear").val();
		
		Common.Confirm("<spring:message code='Cache.msg_DoYouSync'/>", "<spring:message code='Cache.lbl_Synchronization'/>", function(result){
			if(result){
				$.ajax({
					url : "/approval/user/syncSeries.do",
					type: "POST",
					data: {
						"BaseYear": pBaseYear
					},
					success: function(data){
						if(data.status == "SUCCESS"){
							Common.Inform(data.message, "Information", function(result){
								if(result && data.result != "0"){
									Refresh();
								}
							});
						}else{
							Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.msg_apv_030' />");   // 오류가 발생했습니다.
					}				
				});
			}
		});
	}
	
	function excelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirm Dialog", function(result) {
			if(result){
				var params = setSelectParam();
				params.sortBy = ListGrid.getSortParam("one").split("=").pop();
				var headerJson = getHeaderNameForExcel();
				var headerName = headerJson.headerName;
				var headerCode = headerJson.headerCode.substr(0, headerJson.headerCode.length - 1);
				
				location.href = "/approval/user/seriesExcelDownload.do?"
							  + "selectParams=" + encodeURIComponent(JSON.stringify(params))
							  + "&headername="  + encodeURIComponent(encodeURIComponent(headerName))
							  + "&headercode="  + encodeURIComponent(encodeURIComponent(headerCode));
			}
		});
	}
	
	function getHeaderNameForExcel(){
		var returnJson = new Object();
		returnJson.headerName = "";
		returnJson.headerCode = "";
		
		for(var i = 0; i < seriesHeaderData.length; i++){
			if(seriesHeaderData[i].label != "chk"){
				returnJson.headerName += seriesHeaderData[i].label + ";";
				returnJson.headerCode += seriesHeaderData[i].key + ",";
			}
		}

		return returnJson;
	}
	
	function delColumn(thisObj){
		var delObj = $(thisObj).closest(".name_box_wrap").find(".name_box");
		delObj.text("");
		delObj.removeAttr("sfcode");
	}
	
	// 단위업무 팝업 호출
	function seriesSearchPopup(){
		Common.open("","seriesSearch_pop","<spring:message code='Cache.lbl_unitTask'/>","/approval/user/getSeriesSearchPopup.do?l&callBackFunc=series_CallBack","500px","500px","iframe",true,null,null,true);
	}
	
	function series_CallBack(sData){
		$("#seriesNm").text(sData[0].Name);
		$("#seriesNm").attr("seriescode", sData[0].Code);
	}
	
	function seriesModifyPopup_CallBack(sData){
		$("#modifySeries_if").contents().find("#seriesName").val(sData[0].Name);
		$("#modifySeries_if").contents().find("#seriesName").attr("seriescode", sData[0].Code);
	}
	
	//조직도 팝업 호출
	function orgChartPopup(){
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />","/covicore/control/goOrgChart.do?type=C1&callBackFunc=deptOrg_CallBack","1000px","580px","iframe",true,null,null,true);
	}
	
	function deptOrg_CallBack(orgData){
		var deptJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var groupName = CFN_GetDicInfo(deptJSON.GroupName, lang);
		
		$("#deptNm").text(groupName);
		$("#deptNm").attr("deptcode", deptJSON.no);
	}

	function seriesAddOrgPopup_CallBack(orgData){
		var deptJSON =  $.parseJSON(orgData).item;
		var lang = Common.getSession("lang");
		var groupName = '';
		var groupCode = '';
		
		deptJSON.forEach((dept) => {
			groupName += CFN_GetDicInfo(dept.GroupName, lang) + ', ';
			groupCode += dept.GroupCode + ';';
		});
		
		groupName = groupName.substring(0, groupName.length - 2);
		groupCode = groupCode.substring(0, groupCode.length - 1);
		
		$("#addSeries_if").contents().find("#deptName").val(groupName);
		$("#addSeries_if").contents().find("#deptName").attr("deptcode", groupCode);
	}

	function seriesModifyOrgPopup_CallBack(orgData){
		var deptJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var groupName = CFN_GetDicInfo(deptJSON.GroupName, lang);
		
		$("#modifySeries_if").contents().find("#deptName").val(groupName);
		$("#modifySeries_if").contents().find("#deptName").attr("deptcode", deptJSON.no);
	}

	function seriesModifyOrgPopup_before_CallBack(orgData){
		var deptJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var groupName = CFN_GetDicInfo(deptJSON.GroupName, lang);
		
		$("#modifySeries_if").contents().find("#beforeDeptName").val(groupName);
		$("#modifySeries_if").contents().find("#beforeDeptName").attr("deptcode", deptJSON.no);
	}

	function seriesModifyOrgPopup_after_CallBack(orgData){
		var deptJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var groupName = CFN_GetDicInfo(deptJSON.GroupName, lang);
		
		$("#modifySeries_if").contents().find("#afterDeptName").val(groupName);
		$("#modifySeries_if").contents().find("#afterDeptName").attr("deptcode", deptJSON.no);
	}
	
	//단위업무 기능 팝업 호출
	function seriesFunctionPopup(){
		parent.Common.open("","seriesFunction_pop","<spring:message code='Cache.lbl_selectPath' />","/approval/user/getSeriesFunctionPopup.do?callBackFunc=seriesFunctionPopup_CallBack","500px","700px","iframe",true,null,null,true);
	}

	function seriesFunctionPopup_CallBack(jsonData){
		var item = jsonData[0];
		
		$("#sfNm").text(item.Path);
		$("#sfNm").attr("sfcode", item.Code);
	}

	function seriesFunction_AddPopup_CallBack(jsonData){
		var item = jsonData[0];
		
		$("#addSeries_if").contents().find("#seriesPath").val(item.Path);
		$("#addSeries_if").contents().find("#seriesPath").attr("sfcode", item.Code);
	}
	
	// 단위업무 차년도 데이터 생성
	function CreateNextYearSeriesData(){
		var url = "/approval/user/CreateNextYearSeriesDataPopup.do";
		var popupName = "";
		var height = "200px";
		var width = "500px";
		popupName = "단위업무 데이터 복사(년도선택)"; // 기록물철 데이터 복사(년도선택)
				
		Common.open("", "CreateNextYearSeriesData", popupName, url, width, height, "iframe", true, null, null, true);
	}
	
	// 폐지복원
	function restoreSeries(seriesCode, deptCode, baseYear){
		Common.Confirm("<spring:message code='Cache.msg_DoYouResoreAbolition'/>", "Confirm", function(result){ // 폐지복원하시겠습니까?
			if(result){
				$.ajax({
					url : "/approval/user/setRestoreSeries.do",
					type: "POST",
					data: {
						"SeriesCode": seriesCode,
						"DeptCode": deptCode,
						"BaseYear": baseYear
					},
					success: function(data){
						if(data.status == "SUCCESS"){
							Common.Inform(data.message, "Information", function(){
								Refresh();
							});
						}else{
							Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.msg_apv_030' />");   // 오류가 발생했습니다.
					}				
				});
			}
		});
	}
</script>