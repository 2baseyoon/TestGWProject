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
	<h2 class="title"><spring:message code='Cache.lbl_archiveRegister'/></h2> <!-- 기록물철 등록부 -->
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			<button id="simpleSearchBtn" type="button" onclick="onClickSearchButton();" class="btnSearchType01"><spring:message code="Cache.btn_search"/></button> <!-- 검색 -->
		</span>
		<a id="detailSchBtn" onclick="detailDisplay(this);" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 appSearch" id="DetailSearch" >
		<div style="width:500px;">
			<div class="selectCalView">
				<!--<span>* 제목+: 제목+기안자명+기안부서명 검색</span><br/>  todo: 다국어처리 필요 -->
				<span><spring:message code='Cache.lbl_Contents'/></span>	<!-- 내용 -->
				<div class="selBox" style="width: 100px;" id="selectsearchType"></div>
				<input type="text" id="titleNm" style="width: 222px;" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}" >
				<a id="detailSearchBtn"  onclick="onClickSearchButton()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
		<div style="width:520px; margin-bottom: 0;">
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_selection'/></span>	<!-- 선택 -->
				<select id="selBaseYear" class="selectType02 listCount"></select>
				<select id="subDeptList" class="selectType02"></select>
				
				<select id="selRecordStatus" class="selectType02" style="width: 120px;">
					<option value=""><spring:message code='Cache.lbl_all'/></option> <!-- 선택 -->
					<option value="0"><spring:message code='Cache.lbl_blankRecordFile'/></option> <!-- 공철 -->
					<option value="1"><spring:message code='Cache.lbl_filingOngoing'/></option> <!-- 편철진행중 -->
					<option value="5"><spring:message code="Cache.lbl_abolition"/></option> <!-- 폐지 -->
				</select>
			
				<select id="selTakeover" class="selectType02" style="width: 120px;">
					<option value=""><spring:message code='Cache.lbl_all'/></option> <!-- 선택 -->
					<option value="0"><spring:message code='Cache.lbl_notApplicable'/></option> <!-- 해당없음 -->
					<option value="1"><spring:message code='Cache.lbl_takeover'/></option> <!-- 인수 -->
					<option value="2"><spring:message code='Cache.lbl_handover'/></option> <!-- 인계 -->
				</select>
			</div>
		</div>
	</div>
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="excelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a> <!-- 엑셀저장 -->
				<a id="uploadExlBtn" class="btnTypeDefault btnExcel" onclick="openInfoPopup('Excel');"><spring:message code='Cache.btn_ExcelUpload' /></a> <!-- 엑셀 업로드 -->
				<a id="establishBtn" class="btnTypeDefault" onclick="openAddPopup('I');"><spring:message code='Cache.btn_apv_add' /></a><!-- 추가 -->
				<a id="chgDeptBtn" class="btnTypeDefault" onclick="chkRecordInfo('Takeover');"><spring:message code='Cache.lbl_handover' /></a><!-- 인계 -->
				<a id="deleteBtn" class="btnTypeDefault" onclick="setRecordStatus('Revoke');"><spring:message code='Cache.lbl_abolition'/></a><!-- 폐지 -->
				<a id="restoreBtn" class="btnTypeDefault" onclick="setRecordStatus('Restore');"><spring:message code='Cache.lbl_abolitionRestore'/></a><!-- 폐지복원 -->
				<a id="setExtendWorkBtn" class="btnTypeDefault" onclick="setExtendWork();"><spring:message code='Cache.lbl_extendedWork' /></a> <!-- 업무 연장 -->
				<a id="setFileBtn" class="btnTypeDefault" onclick="setRecordStatus('File');" style="display: none;"><spring:message code='Cache.lbl_finalizeFiling' /></a> <!-- 편철 확정 -->
				<a id="showHistoryBtn" class="btnTypeDefault" onclick="chkRecordInfo('History');"><spring:message code='Cache.lbl_apv_chglogsearch' /></a><!-- 변경이력조회 -->
				<a id="createNextYearRecordDataBtn" class="btnTypeDefault" onclick="CreateNextYearRecordData();" style="display:none;"><spring:message code='Cache.lbl_CreateNextYearRecordData' /></a><!-- 차년도 기록물철 데이터 복사 -->
				<a id="integrationBtn" class="btnTypeDefault" onclick="openIntegrationPopup();"><spring:message code='Cache.Approval_Integration' /></a><!-- 통합 -->				
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
						<div id="recordListGrid"></div>
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

	var ajax = function(pUrl, param, bAsync){
		var deferred = $.Deferred();
		$.ajax({
			url: pUrl,
			type:"POST",
			data: param,
			async: bAsync,
			success:function (data) { deferred.resolve(data);},
			error:function(response, status, error){ deferred.reject(status); }
		});				
	 	return deferred.promise();	
	}
	
	var selectInit = function(){
		ajax("/approval/user/selectRecordDocComboData.do", {}, false)
			.done(function(data){
				$(".selBox").each(function(i, obj) {
					var id = $(obj).attr("id");
					var width = "width: " + $(obj).css("width");
					var listName = id.replace("select", "") + "List";
					var list = data[listName];
					
					searchHtml = "<span class=\"selTit\" ><a id=\"seSearchID_"+id.replace("select", "")+"\" target=\""+id+"\" onclick=\"clickSelectBox(this);\" value=\""+list[0].optionValue+"\" class=\"up\">"+list[0].optionText+"</a></span>"
					searchHtml += "<div class=\"selList\" style=\""+width+";display: none;\">";
					$(list).each(function(index){
						searchHtml += "<a class=\"listTxt\" value=\""+this.optionValue+"\" target=\""+id+"\" onclick=\"clickSelectBox(this);\" id=\""+"sch_"+this.optionValue+"\">"+this.optionText+"</a>"
					});
					searchHtml += "</div>";
					
					$("#"+id).html(searchHtml);
				});
			})
			.fail(function(e){
				//console.log(e);
			});
	}
	
	init();
	
	function init(){
		selectInit();
		setDeptList()
		setYearList();
		setGrid();
		initActive();
		
		$("#selBaseYear, #subDeptList, #selRecordStatus, #selTakeover").on("change", onClickSearchButton);
		
		// 차년도 데이터 생성여부 체크
		if(UseRecordDataCreateNextYear == "Y") {
			$("#createNextYearRecordDataBtn").show();
		}
		setRecordDeptAdmin();
		setDeptAdmin();
	}
	
	function setYearList(){
		$.ajax({
			url: "/approval/user/getRecordBaseYearList.do",
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
					$("#setFileBtn").show();
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
	
	//새로고침
	function Refresh(){
		setYearList();
		setRecordGFileListData();
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
	
	function setGrid(){
		setGridConfig();
		setRecordGFileListData();
	}

	function setGridConfig(){
		var headerData = [
							{key:'chk', label:'chk', width:'10', align:'center', formatter:'checkbox', sort:false},
							{key:'RecordSubject', label:'<spring:message code="Cache.lbl_recordFileTitle"/>', width:'30', align:'center'}, // 기록물철 제목
							{key:'RecordStatusTxt', label:'<spring:message code="Cache.lbl_recordState"/>', width:'20', align:'center'}, // 기록물철 상태
							{key:'RCnt', label:'<spring:message code="Cache.lbl_recordNumber"/>', width:'20', align:'center'}, // 기록물 건수
							{key:'RecordProductName', label:'<spring:message code="Cache.lbl_oldRecordProductName"/>', width:'30', align:'center'}, // 기록물생산기관명
							{key:'SeriesName', label:'<spring:message code="Cache.lbl_unitTaskName"/>', width:'30', align:'center'}, // 단위업무명
							{key:'EndYear', label:'<spring:message code="Cache.lbl_endYear"/>', width:'15', align:'center'}, // 종료연도
							{key:'KeepPeriodTxt', label:'<spring:message code="Cache.lbl_preservationPeriod"/>', width:'15', align:'center'}, // 보존기간
							{key:'TakeoverCheckTxt', label:'<spring:message code="Cache.lbl_handoverClass"/>', width:'20', align:'center'}, // 인수인계 구분
							{key:'RecordSeq', label:'<spring:message code="Cache.lbl_apv_SerialNo"/>', width:'20', align:'center'} // 일련번호
						];
		
		seriesHeaderData = headerData;
		ListGrid.setGridHeader(headerData);
		
		var configObj = {
			targetID: "recordListGrid",
			height: "auto",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", // 개
			body: {
				onclick: function(){
					if(this.item.TakeoverCheck == "2" || this.item.RecordStatus != "1" || (isAdmin != "Y" && isRecordDeptAdmin != "Y")){
						openAddPopup("R", this.item.RecordClassNum);
					}else{
						openAddPopup("M", this.item.RecordClassNum);
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
		var seriesCode = $("#seriesNm").attr("seriescode") == undefined ? "" : $("#seriesNm").attr("seriescode");
		var takeOverCheck = $("#selTakeover").val();
		var recordStatus = $("#selRecordStatus").val();
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
		params.searchMode = "NotFile";
		params.takeOverCheck = takeOverCheck;
		params.recordStatus = recordStatus;
		params.baseYear = baseYear;
		params.deptCode = $("#subDeptList").val();
		
		return params;
	}
	
	function setRecordGFileListData(){
		var selectParams = setSelectParam();
		
		ListGrid.bindGrid({
			ajaxUrl: "/approval/user/getRecordGFileListData.do",
			ajaxPars: selectParams,
			onLoad: function(){
				$(".gridBodyTable > tbody > tr").css("cursor", "pointer");
				coviInput.init();
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
				document.getElementById('establishBtn').style.display = "none";		
				document.getElementById('chgDeptBtn').style.display = "none";		
				document.getElementById('deleteBtn').style.display = "none";		
				document.getElementById('restoreBtn').style.display = "none";						
				document.getElementById('setExtendWorkBtn').style.display = "none";		
				document.getElementById('setFileBtn').style.display = "none";		
				document.getElementById('showHistoryBtn').style.display = "none";		
				document.getElementById('createNextYearRecordDataBtn').style.display = "none";		
				document.getElementById('integrationBtn').style.display = "none";		
		}
	}
	
	function onClickSearchButton(){
		ListGrid.page.pageNo = 1;
		setRecordGFileListData();
	}
	
	function openAddPopup(mode, recordClassNum){
		var url = "/approval/user/getRecordGFileAddPopup.do?mode="+mode;
		var popupName = "<spring:message code='Cache.lbl_addRecordFile' />"; // 기록물철 추가
		var height = "570px";
		
		if(mode == "M"){
			url += "&recordClassNum="+recordClassNum;
			popupName = "<spring:message code='Cache.lbl_modifyRecordFile' />"; // 기록물철 수정
			height = "640px";
		}else if(mode == "R"){
			url += "&recordClassNum="+recordClassNum;
			popupName = "<spring:message code='Cache.lbl_inquiryRecordFile' />"; // 기록물철 조회
			height = "500px";
		}
		
		Common.open("", "addRecord", popupName, url, "400px", height, "iframe", true, null, null, true);
	}
	
	function openInfoPopup(mode, recordClassNum){
		var checkList = ListGrid.getCheckedList(0);
		var url = "/approval/user/getRecordGFileInfoPopup.do?mode="+mode;
		var popupName = "";
		var height = "";
		
		switch(mode){
			case "Excel": 
				height = "200px";
				popupName = "<spring:message code='Cache.btn_ExcelUpload' />"; // 엑셀 업로드
				break;
			case "Takeover": 
				height = "260px";
				url += "&recordClassNum=" + recordClassNum
					+  "&deptName=" + checkList[0].RecordProductName
					+  "&deptCode=" + checkList[0].RecordDeptCode;
				popupName = "<spring:message code='Cache.lbl_Transition' />"; // 인수인계
				break;
			case "History": 
				height = "500px";
				url += "&recordClassNum=" + recordClassNum;
				popupName = "<spring:message code='Cache.lbl_changeHistory' />"; // 변경 이력
				break;
		}
		
		Common.open("", "recordInfo", popupName, url, "500px", height, "iframe", true, null, null, true);
	}
	
	// 통합
	function openIntegrationPopup(){
		const checkList = ListGrid.getCheckedList(0);
		let isRevoke = false;
		let recordClassNum = '';
		let recordSubject = '';
		
		// 체크한 기록물철 => 팝업 열때 대상기록물철로 세팅해줌 (체크 안하면 빈 값으로 셋팅)
		$(checkList).each(function(idx, item){
			recordClassNum += item.RecordClassNum + ",";
			recordSubject += item.RecordSubject + ";||;";
			if(item.RecordStatus == "5")
				isRevoke = true;
		});
		
		if(isRevoke){
			Common.Inform('<spring:message code="Cache.msg_alreadyAbolishRecordFile" />'); // 이미 폐지된 기록물철입니다.
			return false;
		}
		
		recordClassNum = recordClassNum.substr(0, recordClassNum.length - 1);
		recordSubject = recordSubject.substr(0, recordSubject.length - 4);
		
		let url = "/approval/user/getRecordGFileIntegrationPopup.do?recordClassNum=" + recordClassNum + "&recordSubject=" + encodeURIComponent(recordSubject);
		let popupName = "<spring:message code='Cache.Approval_Integration' />"; // 통합
		let popupId = 'integrationRecordGFile';
		
		Common.open("", popupId, popupName, url, "600px", "160px", "iframe", true, null, null, true);
	}
	
	function chkRecordInfo(mode){
		var checkList = ListGrid.getCheckedList(0);
		
		if(checkList != null && checkList != ""){
			if(checkList.length > 1){
				Common.Inform('<spring:message code="Cache.msg_SelectOne" />'); // 한개만 선택되어야 합니다
			}else if(mode == "Takeover" && checkList[0].TakeoverCheck == "2"){
				Common.Inform('<spring:message code="Cache.msg_alreadyHandoverRecordFile" />'); // 이미 인계된 기록물철입니다.
			}else if(mode == "Takeover" && checkList[0].RecordStatus == "5"){
				Common.Inform('<spring:message code="Cache.msg_alreadyAbolishRecordFile" />'); // 이미 폐지된 기록물철입니다.
			}
// 			else if(mode == "Takeover" && checkList[0].SeriesCode.substring(0,2) != "ZA"){
// 				Common.Inform('<spring:message code="Cache.msg_notTakeoverRecordFile" />'); // 고유업무 및 처리과 공통업무는 인계할수 없습니다.
// 			}
			else{
				openInfoPopup(mode, checkList[0].RecordClassNum);
			}
		}else{
			Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
		}
	}
	
	function initActive(){
		$("#detailSchBtn").addClass("active");
		$("#DetailSearch").addClass("active");
		
		$(".contbox").css("top", $(".content").height());
		coviInput.setDate();
	}	
	
	function setRecordStatus(mode){
		var checkList = ListGrid.getCheckedList(0);
		var params = new Object();
		var recordClassNum = "";
		var isRevoke = false;
		var isTakeover = false;
		var isRestore = false;
		
		if(checkList.length == 0){
			Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
			return false;
		}
		
		$(checkList).each(function(idx, item){
			recordClassNum += item.RecordClassNum + ";";
			if(item.RecordStatus == "5")
				isRevoke = true;
			
			if(item.TakeoverCheck == "2")
				isTakeover = true;
			
			if(mode == 'Restore' && item.RecordStatus != "5")
				isRestore = true;
		});
		
		if(mode != 'Restore' && isRevoke){
			Common.Inform('<spring:message code="Cache.msg_alreadyAbolishRecordFile" />'); // 이미 폐지된 기록물철입니다.
			return false;
		} else if(mode != 'Restore' && isTakeover){
			Common.Inform('<spring:message code="Cache.msg_alreadyHandoverRecordFile" />'); // 이미 인계된 기록물철입니다.
			return false;
		} else if(isRestore){
			Common.Inform('<spring:message code="Cache.msg_notRecordGFile" />'); // 폐지되지 않은 기록물철입니다.
			return false;
		}
		
		params.RecordClassNum = recordClassNum.substr(0, recordClassNum.length - 1);
		var confirmMsg = "<spring:message code='Cache.msg_apv_127' />"; //처리하시겠습니까?
		switch(mode){
			case "File":
				params.RecordStatus = "2";
				confirmMsg = "<spring:message code='Cache.msg_filingConfirm' />"; //편철확정 하시겠습니까?
				break;
			case "Report":
				params.RecordStatus = "3";
				break;
			case "Transfer":
				params.RecordStatus = "4";
				break;
			case "Revoke":
				params.RecordStatus = "5";
				confirmMsg = "<spring:message code='Cache.msg_abolition' />"; //폐지하시겠습니까?
				break;
			case "Restore":
				params.RecordStatus = "1";
				confirmMsg = "<spring:message code='Cache.msg_DoYouResoreAbolition' />"; //폐지복원하시겠습니까?
				break;
		}
		
		Common.Confirm(confirmMsg, "Information", function(result){
			if(result){
				$.ajax({
					url: "/approval/user/setRecordStatus.do",
					type: "POST",
					data: params,
					success: function(data){
						if(data.status == "SUCCESS"){
							Common.Inform(data.message, "Information", function(result){
								if(result){
									Common.Close();
									parent.Refresh();
								}
							});
						}else{
							Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
						}
					},
					error: function(error){
						Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
					}
				});
			}
		});
	}
	
	function setExtendWork(){
		var checkList = ListGrid.getCheckedList(0);
		var recordClassNum = "";
		var isRevoke = false;
		var isTakeover = false;
		
		if(checkList.length == 0){
			Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
			return false;
		}
		
		$(checkList).each(function(idx, item){
			recordClassNum += item.RecordClassNum + ";";
			
			if(item.RecordStatus == "5")
				isRevoke = true;
			
			if(item.TakeoverCheck == "2")
				isTakeover = true;
		});
		
		if(isRevoke){
			Common.Inform('<spring:message code="Cache.msg_alreadyAbolishRecordFile" />'); // 이미 폐지된 기록물철입니다.
			return false;
		}else if(isTakeover){
			Common.Inform('<spring:message code="Cache.msg_alreadyHandoverRecordFile" />'); // 이미 인계된 기록물철입니다.
			return false;
		}
		
		Common.Confirm("<spring:message code='Cache.msg_extendWork' />", "Information", function(result){ //업무연장 하시겠습니까?
			if(result){
				$.ajax({
					url: "/approval/user/setExtendWork.do",
					type: "POST",
					data: {
						"RecordClassNum": recordClassNum
					},
					success: function(data){
						if(data.status == "SUCCESS"){
							Common.Inform(data.message, "Information", function(result){
								if(result){
									Common.Close();
									parent.Refresh();
								}
							});
						}else{
							Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
						}
					},
					error: function(error){
						Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
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
				
				location.href = "/approval/user/recordExcelDownload.do?"
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
	
	function series_CallBack(sData){
		$("#seriesNm").text(sData[0].Name);
		$("#seriesNm").attr("seriescode", sData[0].Code);
	}
	
	function seriesSearchPopup_CallBack(sData){
		$("#recordInfo_if").contents().find("#seriesName").val(sData[0].Name);
		$("#recordInfo_if").contents().find("#seriesName").attr("seriescode", sData[0].Code);
		$("#recordInfo_if").contents().find("#seriesName").attr("baseyear", sData[0].BaseYear);
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
	
	function recordAddOrgPopup_seriesCallBack(sData){
		$("#addRecord_if").contents().find("#seriesName").val(sData[0].Name);
		$("#addRecord_if").contents().find("#seriesName").attr("seriescode", sData[0].Code);
		var sCode = sData[0].Code;
		
		if(sCode.indexOf('ZA')> -1){
			$("#addRecord_if").contents().find("#deptName").val("공통");
			$("#addRecord_if").contents().find("#deptName").attr("deptcode", 'Total');
		}else if(sCode.indexOf('ZZ')> -1){
			$("#addRecord_if").contents().find("#deptName").val("처리과 공통");
			$("#addRecord_if").contents().find("#deptName").attr("deptcode", '001');
		}else{
			$("#addRecord_if").contents().find("#deptName").val(sData[0].DeptName);
			$("#addRecord_if").contents().find("#deptName").attr("deptcode", sData[0].DeptCode);
		}
		
	}
	
	function recordAddOrgPopup_Dept_CallBack(orgData){
		var deptJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var groupName = CFN_GetDicInfo(deptJSON.GroupName, lang);
		
		$("#addRecord_if").contents().find("#deptName").val(groupName);
		$("#addRecord_if").contents().find("#deptName").attr("deptcode", deptJSON.no);
	}
	
	function recordAddOrgPopup_User_CallBack(orgData){
		var orgJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var userName = CFN_GetDicInfo(orgJSON.DN, lang);
		
		$("#addRecord_if").contents().find("#workCharger").val(userName);
	}

	function recordInfoOrgPopup_user_CallBack(orgData){
		var orgJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var userName = CFN_GetDicInfo(orgJSON.DN, lang);
		var groupName = CFN_GetDicInfo(orgJSON.RGNM, lang);
		
		$("#recordInfo_if").contents().find("#workCharger").val(userName);
		$("#recordInfo_if").contents().find("#afterDeptName").val(groupName);
		$("#recordInfo_if").contents().find("#afterDeptName").attr("deptcode", orgJSON.RG);
	}

	function searchPopupOrg_CallBack(orgData){
		var deptJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var groupName = CFN_GetDicInfo(deptJSON.GroupName, lang);
		
		$("#seriesSearch_pop_if").contents().find("#deptNm").text(groupName);
		$("#seriesSearch_pop_if").contents().find("#deptNm").attr("deptcode", deptJSON.no);
	}
	
	// 기록물철 차년도 데이터 생성
	function CreateNextYearRecordData(){
		var url = "/approval/user/CreateNextYearRecordDataPopup.do";
		var popupName = "";
		var height = "200px";
		var width = "500px";
		popupName = "기록물철 데이터 복사(년도선택)"; // 기록물철 데이터 복사(년도선택)
				
		Common.open("", "CreateNextYearRecordData", popupName, url, width, height, "iframe", true, null, null, true);
	}
</script>