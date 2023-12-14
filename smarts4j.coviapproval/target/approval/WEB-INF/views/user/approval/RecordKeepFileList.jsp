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
	<h2 class="title"><spring:message code="Cache.lbl_filingConfirmManage"/></h2> <!-- 편철확정 관리 -->
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}"><button id="simpleSearchBtn" type="button" onclick="onClickSearchButton();" class="btnSearchType01"><spring:message code="Cache.btn_search"/></button> <!-- 검색 -->
		</span>
		<a id="detailSchBtn" onclick="detailDisplay(this);" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 appSearch" id="DetailSearch" >
		<div style="width:470px;">
			<div class="selectCalView">
				<!--<span>* 제목+: 제목+기안자명+기안부서명 검색</span><br/>  todo: 다국어처리 필요 -->
				<span><spring:message code='Cache.lbl_Contents'/></span>	<!-- 내용 -->
				<div class="selBox" style="width: 100px;" id="selectsearchType"></div>
				<input type="text" id="titleNm" style="width: 222px;" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}" >
				<a id="detailSearchBtn"  onclick="onClickSearchButton()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
		<div style="width:470px; margin-bottom: 0;">
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_selection'/></span>	<!-- 선택 -->
				<select id="selBaseYear" class="selectType02"></select>
				<select id="subDeptList" class="selectType02"></select>
				
				<select id="selRecordStatus" class="selectType02" style="width: 120px;display:none;">
					<option value=""><spring:message code='Cache.lbl_all'/></option> <!-- 선택 -->
					<option value="2"><spring:message code='Cache.lbl_filing'/></option> <!-- 편철 -->
					<option value="3" style='display:none'><spring:message code='Cache.lbl_statusReportComplete'/></option> <!-- 현황보고완료 -->
					<option value="4" style='display:none'><spring:message code='Cache.lbl_transferComplete'/></option> <!-- 이관완료 -->
				</select>
			</div>
		</div>
	</div>
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="excelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a> <!-- 엑셀저장 -->
				<a id="chgDeptBtn" class="btnTypeDefault" onclick="setRecordStatus('Cancel');"><spring:message code='Cache.lbl_cancelFiling' /></a><!-- 편철 취소 -->
				<!--a id="statusReport" class="btnTypeDefault" onclick="doStatusReport('PRODUCT');"><spring:message code='Cache.lbl_statusReport' /></a---><!-- 현황 보고 -->
				<a id="transferRecord" class="btnTypeDefault" style="display:none;"onclick="doTransRecord('TRANSFER');"><spring:message code='Cache.lbl_transfer' /></a><!-- 이관 -->
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
	let RecordAdmin = 'N';
	let isRecordDeptAdmin = 'N';
	var baseYear = "";
	
	//일괄 호출 처리
	initApprovalListComm(init, setGrid);
	
	function init(){
		setYearList();
		setDeptList();
		selectInit();
		setGrid();
		
		$("#selBaseYear, #subDeptList").on("change", onClickSearchButton);
		setRecordDeptAdmin();
		setDeptAdmin();
	}
	
	function setYearList(){
		$.ajax({
			url: "/approval/user/getRecordBaseYearList.do",
			type: "POST",
			data: {"selBaseYear" : $("#selBaseYear").val()},   
			dataType: "json",
			async: false,
			success: function(data){
				baseYear = $("#selBaseYear").val() == null ? new Date().getFullYear() : $("#selBaseYear").val();
				var list = data.list;
				var baseYearHtml = "";
				if(isAdmin == "Y"){
					baseYearHtml += "<option value=''><spring:message code='Cache.lbl_all'/></option>";
				}
				
				$.each(list, function(idx, item){
					baseYearHtml += "<option value='"+item.BaseYear+"'>"+item.BaseYear+"</option>";
				});
				
				$("#selBaseYear").html(baseYearHtml);
				$("#selBaseYear").val(baseYear);
			},
			error: function (error){
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
				var selDept = ""
				
				if(isAdmin == "Y"){
					subDeptOption += "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
				}else{
					selDept = Common.getSession("DEPTID");
				}
					
				$.each(subDeptList, function(idx, item){
					subDeptOption += "<option value='"+item.GroupCode+"'>";
					var SortDepth = item.SortDepth;
					
					for(var i = 1; i < SortDepth; i++) {
						subDeptOption += " ";
					}
					
					subDeptOption += item.TransMultiDisplayName+"</option>";
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
							{key:'RecordProductName', label:'<spring:message code="Cache.lbl_oldRecordProductName"/>', width:'30', align:'center'}, // 구기록물생산기관명
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
					if(this.item.TakeoverCheck == "2" || this.item.RecordStatus != "1" || isAdmin != "Y"){
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
		var recordStatus = $("#selRecordStatus").val();
		var baseYear = $("#selBaseYear").val();
		var searchType = $("#searchType").val();
		var searchWord = $("#searchInput").val();
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
		params.searchMode = "File";
		params.recordStatus = recordStatus;
		params.baseYear = baseYear;
		params.deptCode = $("#subDeptList").val();;
		
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
	
	function onClickSearchButton(){
		ListGrid.page.pageNo = 1;
		setYearList();
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
	
	function setRecordStatus(mode){
		var checkList = ListGrid.getCheckedList(0);
		var params = new Object();
		var recordClassNum = "";
		var isRevoke = false;
		var isFile = false;
		var isTakeover = false;
		
		if(checkList.length == 0){
			Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
			return false;
		}

		$(checkList).each(function(idx, item){
			recordClassNum += item.RecordClassNum + ";";
		});
		
		params.RecordClassNum = recordClassNum.substr(0, recordClassNum.length - 1);
		params.RecordStatus = "1";
		
		Common.Confirm("<spring:message code='Cache.msg_att_cancel' />", "Information", function(result){ //취소하시겠습니까?
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
	
	function doStatusReport(){
		var checkAll = $("input[name=checkAll]").is(":checked");
		var checkList = ListGrid.getCheckedList(0);
		var params = new Object();
		var recordClassNum = "";
		var isRevoke = false;
		var isFile = false;
		var isTakeover = false;
		
		if(checkAll){
			
			if($("#subDeptList").val() == ''){
				Common.Inform('<spring:message code="Cache.msg_apv_238" />'); // 부서를 선택해주세요.
				return false;
			}
			
			params.mode = "ALL";
			params.BaseYear = $("#selBaseYear").val();
			params.RecordDeptCode = 'I'+$("#subDeptList").val();	
		} else {
			if(checkList.length == 0){
				Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
				return false;
			}
			
			$(checkList).each(function(idx, item){
				recordClassNum += item.RecordClassNum + ";";
			});
			
			params.mode = "ITEM";
			
		}
		params.BaseYear = $("#selBaseYear").val();
		params.RecordStatus = "2";
		params.RecordClassNum = recordClassNum.substr(0, recordClassNum.length - 1);
		
		
		$.ajax({
			url: "/approval/govDocs/getRecordStatus.do",
			type: "POST",
			data: params,
			async: false,
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Confirm(data.message, "<spring:message code='Cache.lbl_statusReport' />", function(result){
						
						if(result){
							$.ajax({
			 					url: "/approval/govDocs/doStatusReport.do",
			 					type: "POST",
			 					data: params,
			 					success: function(data){
			 						if(data.status == "SUCCESS"){
			 							Common.Inform(data.message, "Information", function(result){
			 								if(result){
			 									Common.Close();
			 									ListGrid.reloadList();
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
				}else{
					Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
				}
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
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
			document.getElementById('chgDeptBtn').style.display = "none";
		}
	}
	
	function doTransRecord(){
		var checkAll = $("input[name=checkAll]").is(":checked");
		var checkList = ListGrid.getCheckedList(0);
		var params = new Object();
		var recordClassNum = "";
		var isRevoke = false;
		var isFile = false;
		var isTakeover = false;
		
		if(checkList.length == 0){
			Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
			return false;
		} else {
			// 기록관리 시스템 상태 확인 Confirm 팝업
			Common.Confirm("<spring:message code='Cache.msg_transRecordConfirm' />", "Information", function(result){
				if(result){
					
					if(checkAll){
						if($("#subDeptList").val() == ''){
							Common.Inform('<spring:message code="Cache.msg_apv_238" />'); // 부서를 선택해주세요.
							return false;
						}
						
						params.mode = "ALL";
						params.RecordDeptCode = $("#subDeptList").val();	
					} else {
						$(checkList).each(function(idx, item){
							recordClassNum += item.RecordClassNum + ";";
						});
						
						params.mode = "ITEM";
						
					}
					params.BaseYear = $("#selBaseYear").val();
					params.RecordStatus = "3";
					params.RecordClassNum = recordClassNum.substr(0, recordClassNum.length - 1);
					
					$.ajax({
						url: "/approval/govDocs/getRecordStatus.do",
						type: "POST",
						data: params,
						async: false,
						success: function(data){
							if(data.status == "SUCCESS"){
								Common.Confirm(data.message, "<spring:message code='Cache.lbl_transfer' />", function(result){
									
									if(result){
										$.ajax({
						 					url: "/approval/govDocs/doTransRecord.do",
						 					type: "POST",
						 					data: params,
						 					success: function(data){
						 						if(data.status == "SUCCESS"){
						 							Common.Inform(data.message, "Information", function(result){
						 								if(result){
						 									Common.Close();
						 									ListGrid.reloadList();
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
	
	function delColumn(thisObj){
		var delObj = $(thisObj).closest(".name_box_wrap").find(".name_box");
		delObj.text("");
		delObj.removeAttr("seriescode");
	}
	
	// 단위업무 팝업 호출
	function seriesSearchPopup(){
		Common.open("","seriesSearch_pop","<spring:message code='Cache.lbl_unitTask'/>","/approval/user/getSeriesSearchPopup.do?l&callBackFunc=series_CallBack","800px","500px","iframe",true,null,null,true);
	}
	
	function series_CallBack(sData){
		$("#seriesNm").text(sData[0].Name);
		$("#seriesNm").attr("seriescode", sData[0].Code);
	}
	
	function seriesSearchPopup_CallBack(sData){
		$("#recordInfo_if").contents().find("#seriesName").val(sData[0].Name);
		$("#recordInfo_if").contents().find("#seriesName").attr("seriescode", sData[0].Code);
	}
	
	//조직도 팝업 호출
	function orgChartPopup(){
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />","/covicore/control/goOrgChart.do?type=C1&callBackFunc=deptOrg_CallBack","1000px","580px","iframe",true,null,null,true);
	}

	function searchPopupOrg_CallBack(orgData){
		var deptJSON =  $.parseJSON(orgData).item[0];
		var lang = Common.getSession("lang");
		var groupName = CFN_GetDicInfo(deptJSON.GroupName, lang);
		
		$("#seriesSearch_pop_if").contents().find("#deptNm").text(groupName);
		$("#seriesSearch_pop_if").contents().find("#deptNm").attr("deptcode", deptJSON.no);
	}
</script>