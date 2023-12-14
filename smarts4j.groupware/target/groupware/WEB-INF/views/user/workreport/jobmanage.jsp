<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">업무 관리</span>
	</h3>
	
	<!-- 상단 필터 및 메뉴 -->
	<div style="width:100%; height:40px; margin-bottom: 10px;">
		<div style="display:inline-block;">
			<button type="button" id="btnRefresh" class="AXButton" onclick="refresh()"><spring:message code="Cache.btn_Refresh"></spring:message></button>
			<button type="button" id="btnRegist" class="AXButton" onclick="jobRegistOpen()">등록</button>
			<button type="button" id="btnDelete" class="AXButton" onclick="jobDelete()">삭제</button> <!-- 권한, 참조횟수 등 로직 적용해야함 -->
		</div>
		<div style="display:inline-block; text-align:right; float:right;">
			<button type="button" id="btnCateManage" onclick="cateManageOpen()" class="AXButton">업무구분/분류 관리</button>
		</div>
	</div>
	
	<!-- 검색 바 -->
	<div>
		<select id="selDivisionFilter" onchange="bindGridData()"></select>
		<select id="selUseYNFilter" onchange="bindGridData()">
			<option value="A">사용여부</option>
			<option value="Y">사용</option>
			<option value="N">사용안함</option>
		</select>
		<span style="margin-left : 5px;">업무명</span> 
		<input type="text" id="txtJobName" class="AXInput W200" />
		<button type="button" id="btnSearch" class="AXButton" onclick="bindGridData()">검색</button>
	</div>
	
	<!-- Grid -->
	<div id="resultBoxWrap" style="margin-top : 15px;">
		<div id="AXGridTarget"></div>
	</div>
</div>
<script>
$("#txtJobName").keypress(function (e) {
    if (e.keyCode == 13) bindGridData();
});

var workJobGrid = new coviGrid();

//Grid 관련 사항 추가 -
//Grid 생성 관련
function setGrid(){
	//myGrid.setGridHeader(headerData);
	workJobGrid.setGridHeader([
		                  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
		                  {key:'JobName',  label:'업무명', width:'150', align:'center', formatter: function() {
		                	  return "<a href='#' onclick='jobUpdateOpen(" + this.item.JobID + ")'>" + this.item.JobName + "</a>";
		                  }},
		                  {key:'JobDivisionName',  label:'업무구분', width:'100', align:'center'},
		                  {key:'ManagerName', label:'담당자', width:'70', align:'center'},
		                  {key:'CreateDate',  label:'생성일' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', 
		                   formatter : function() {
		                	   var dateStr = this.item.CreateDate;
		                	   if(dateStr != ""){
			                	   return CFN_TransLocalTime(dateStr, "yyyy-MM-dd");
		                	   }else{
		                		   return "-";
		                	   }
		                   }},
		                  {key:'IsUse', label:'사용여부', width:'100', align:'center', formatter: function(){
		                	  var returnObj = "<div style='inline-block; margin:0px auto; width:60px;'>"
		                	  			    + "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.JobID+"' style='width:50px;height:21px;border:0px none;' value='" + this.item.IsUse + "' onchange='updateUseYN(" + this.item.JobID + ")'/>"
		                	  				+ "</div>";
		                	  return returnObj;
		                  }}
			      		]);
	setGridConfig();
	bindGridData();
}


function bindGridData() {
	var strDivision = $("#selDivisionFilter").val();
	var strUseYn = $("#selUseYNFilter").val();
	var strSearchText = $("#txtJobName").val();
	
	strUseYn = strUseYn == "A" ? "" : strUseYn;
	
	workJobGrid.bindGrid({
		ajaxUrl:"getworkjoblist.do",
		ajaxPars: {
			division : strDivision,
			useyn : strUseYn,
			searchtext : strSearchText
		},
		onLoad:function () {
			workJobGrid.fnMakeNavi("workJobGrid");
		}
	});
}

//Grid 설정 관련
function setGridConfig(){
	var configObj = {
		targetID : "AXGridTarget",		// grid target 지정
		sort : true,		// 정렬
		colHeadTool : false,	// 컬럼 툴박스 사용여부
		fitToWidth : true,		// 자동 너비 조정 사용여부
		colHeadAlign : 'center',
		height:"auto",
		
		page : {
			pageNo:1,
			pageSize:10
		},
		paging : true
	};
	
	// Grid Config 적용
	workJobGrid.setGridConfig(configObj);
}



var cateManageOpen = function() {
	Common.open("btnCateManage", "cateManagePop", "업무구분/분류관리", "workreportcatepop.do?system=workreport", "700px", "500px", "iframe", true, null, null, true);
};

var jobRegistOpen = function() {

	Common.open("btnRegist", "JobEditPop", "업무등록", "addJob.do?mode=Reg", "530px", "280px", "iframe", true, null, null, true);
};


var bindOption = function() {
	var jQObj = $("#selDivisionFilter");
	$(jQObj).append("<option value=''>업무구분</option>");
	$.getJSON("getWorkReportDiv.do", {}, function(d){		
		var listData = d.list;
		$(listData).each(function(idx, data) {
			jQObj.append("<option value='" + data.code + "'>" + data.name + "</option>");
		});		
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getWorkReportDiv.do", response, status, error);
	});
};


var refresh = function() {
	var strDivision = $("#selDivisionFilter").find("option").eq(0).prop("selected", true);
	var strUseYn = $("#selUseYNFilter").find("option").eq(0).prop("selected", true);
	var strSearchText = $("#txtJobName").val("");
	
	workJobGrid.clearSort();
	bindGridData();
};

var updateUseYN = function(pJobId) {
	var strUseYN = $("#AXInputSwitch" + pJobId).val();
	$.get('workreportjobchangeuse.do', {
		jobId : pJobId,
		useYN : strUseYN
	}, function(d) {
		// grid reload
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("workreportjobchangeuse.do", response, status, error);
	});	
};

var jobDelete = function() {
	var chkList = workJobGrid.getCheckedList(0);
	var strChkList= "";
	chkList.forEach(function(data) {		
		strChkList += data.JobID + ",";
	});
	
	// 삭제
	Common.Confirm("삭제하시겠습니까?", "알림", function(result) {
		if(result) {
			$.post('workreportjobdelete.do', {
				deleteIds : strChkList
			}, function(d) {
				// 최신목록을 보여주기위해 전체 Data Rebind
				bindGridData();
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("workreportjobdelete.do", response, status, error);
			});	
		}
	});
};

var jobUpdateOpen = function(pJobId) {
	
	Common.open("", "JobEditPop", "업무수정", "addJob.do?mode=Edit&jobID=" + pJobId, "530px", "280px", "iframe", true, null, null, true);
};

$(function() {

	setGrid();
	bindOption();
});

</script>