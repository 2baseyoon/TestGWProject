<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/forms/WebEditor_Approval_HWP.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpToolbars.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpCtrl.js<%=resourceVersion%>"></script>

<head>
<title></title>
</head>
<body>
	<!-- 윈도우팝업내용 크기 800px -->
	<div class="layer_divpop ui-draggable" id="testpopup_p" style="width:100%; z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
 		<!-- 팝업 Contents 시작 -->
		<div class="divpop_contents lineNone wd">
			<div class="pop_header" id="testpopup_ph">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">기록물철 선택</span></h4>
			</div>
			<div class="popContent portalOrgPopContent">
				<!--recordSelBox 시작 -->
				<div id="" class="recordSelBox">
					<div class="recordList">
						<select id="selBaseYear" class="selectType02" style="width:40%" onChange="setListData('S');"></select>	
						<select id="subDeptList" class="selectType02" onChange="setListData('S');"></select>
						
						<div id="SeriesListGrid" style="height: 600px;"></div>
					</div>

					<!-- 탭영역 시작 -->
					<div class="recordTab" id="">
						<ul class="rtabList">
							<li onclick="toggleTab(this)" class="rtab-link current" data-tab="rtab-1" data-type="R"><a href="#n">기록물철</a></li>
							<li onclick="toggleTab(this)" class="rtab-link" data-tab="rtab-2" data-type="F"><a href="#n">즐겨찾기</a></li>
						</ul>
	
						<div id="rtab-1" class="rtabCont current">
							<!-- 검색영역 시작 -->
							<div class="searchBoxArea">
								<div class="sLeft">
									<strong class="sTit">기록물철 검색</strong>
									<div class="searchBox02">
										<span>
											<input type="text" placeholder="검색어를 입력하세요" />
											<button type="button" class="btnSearchType01">검색</button>
										</span>
									</div>
								</div>
								<div class="sRight">
									<!-- <a href="#" class="btnTypeDefault">편철</a> -->
								</div>
							</div>
							<!-- 검색영역 끝 -->
							<a onclick="toggleRecordFav('I')" class="btnTypeDefault btnTypeChk">즐겨찾기 추가</a>
							<div class="tblList tblCont boradBottomCont recordTb">
								<div id="ListGrid"></div>
							</div>
						</div>
						<div id="rtab-2" class="rtabCont">
							<a onclick="toggleRecordFav('D')" class="btnTypeDefault btnTypeChk">즐겨찾기 삭제</a>
							<div class="tblList tblCont boradBottomCont recordTb">
								<div id="FavListGrid"></div>
							</div>
						</div>
					</div>
					<!-- 탭영역  끝 -->
			    </div>
				<!--recordSelBox 끝 -->
			</div>
		</div>
		<!--팝업 Contents 끝-->
	</div>
</body>

<script>
var sessionObj = Common.getSession();
var deptID = sessionObj["DEPTID"];
var targetID = CFN_GetQueryString("targetID");
if(targetID == "undefined") targetID = "";

var SeriesListGrid = new coviGrid();
var ListGrid = new coviGrid();
var FavListGrid = new coviGrid();

$(window).load(function () {
	setGrid('S');
});

function setGrid(type){
	setYearList();
	setDeptList();
	setGridHeader(type);
	setGridConfig(type);
	setListData(type);
}

function setGridHeader(type){
	var headerData = [];
	
	if(type == "S") { // 단위업무
		headerData =[
			{key:'SeriesCode', label:'단위업무 코드', width:'100', align:'center'}, //<spring:message code="Cache.lbl_unitTaskCode"/>
			{key:'SeriesName',  label:'단위업무명', width:'100', align:'center',  //<spring:message code="Cache.lbl_unitTaskName"/>
				formatter:function() {
					var funcPath = this.item.LFName + " > " + this.item.MFName + " > " + this.item.SFName
					return "<div><span title='"+funcPath+"'>"+this.item.SeriesName+"</span></div>";
				}
			}
		];

		SeriesListGrid.setGridHeader(headerData);
	}
	else if(type == "R" || type == "F") { // 기록물철 or 즐겨찾기
		headerData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
			{key:'RecordClassNum', label:'기록물철', width:'100', align:'left', //<spring:message code="Cache.lbl_apv_DocBinder"/>
				formatter:function (){
					var sHtml = "";
					sHtml += "<div>";
					sHtml += "	<a onclick='clickRecordClass(\""+this.item.RecordClassNum+"\", \""+this.item.RecordSubject+"\", \""+targetID+"\", \""+this.item.KeepPeriod+"\"); return false;'>"+this.item.RecordSubject+"</a>";
					sHtml += "	<span style='cursor:pointer;' class='newWindowPop' onclick='openRecordInfoPopup(\""+this.item.RecordClassNum+"\"); return false;'></span>";
					sHtml += "</div>";
					
					return sHtml;
		   		}
			},
			{key:'KeepPeriodName',  label:'보존기간', width:'55', align:'center'}, //<spring:message code="Cache.lbl_preservationPeriod"/>
			{key:'WorkCharger',  label:'담당자', width:'55', align:'center'} //<spring:message code="Cache.lbl_apv_charge_person"/>
		];
		
		if(type == "R") {
			ListGrid.setGridHeader(headerData);
		} else {
			FavListGrid.setGridHeader(headerData);
		}
	}
}

function setGridConfig(type){
	var configObj = {};
	
	if(type == "S") {
		configObj = {
			targetID : "SeriesListGrid",
			height:"600",
			page : {
				pageNo:1,
				pageSize:50
			},
			paging : false,
            body: {
            	onclick:function() {
            		clickSeriesCode(this.list[this.index].SeriesCode);
            	},
            	onscrollend : function() {
    				var me = this;
    				
    				if(SeriesListGrid.page.listCount < SeriesListGrid.page.pageNo * SeriesListGrid.page.pageSize) {
    					return;
    				}
    				
    				SeriesListGrid.page.pageNo = SeriesListGrid.page.pageNo+1;
    						
    				var params = {};
    				params.DeptID = $("#subDeptList").val();
    				params.baseYear = $("#selBaseYear").val();
    				params.pageNo = SeriesListGrid.page.pageNo;
    				params.pageSize = SeriesListGrid.page.pageSize;
    				
    				$.ajax({
    					url	: "/approval/getSeriesListData.do",
    					type: "POST",
    					data: params,
    					success:function (data) {
    						if(data.status == "SUCCESS"){
    							if(data.list != undefined && data.list.length > 0) {
    								var index = (SeriesListGrid.page.pageNo - 1) * SeriesListGrid.page.pageSize;
    								SeriesListGrid.pushList(data.list, index);
    							}
    						}else{
        						Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
    						}
    					},
    					error:function (error){
    						Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
    					}
    				});
    			}
            }
		}
		SeriesListGrid.setGridConfig(configObj);
	}
	else if(type == "R" || type == "F") {
		var trgID = "ListGrid";
		if(type == "F") {
			trgID = "FavListGrid"
		}
		configObj = {
			targetID : trgID,
			height:"auto",
			listCountMSG:"<b>{listCount}</b> 건",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
            body:{
            }
		}
		window[trgID].setGridConfig(configObj);
	}
}

function setListData(type){	
	var params = {
		"DeptID" : $("#subDeptList").val(),
		"baseYear" : $("#selBaseYear").val(),
		"DeptCode" : $("#subDeptList").val(),
		"existsGFile":"true"	//기록물철이 있는것만
	}
	
	if(type == "S"){
		SeriesListGrid.bindGrid({
			ajaxUrl: "/approval/getSeriesListData.do",
			ajaxPars: params,
			onLoad: function(){
			}
		});
	}
	else if(type == "R" || type == "F"){
		var gridName = (type == "F" ? "FavListGrid" : "ListGrid");
		
		params.SeriesCode = g_SeriesCode;
		params.isFav = (type == "F" ? "Y" : "N");

		window[gridName].bindGrid({
			ajaxUrl: "/approval/getRecordListData.do",
			ajaxPars: params,
			onLoad: function(){
			}
		});
	}
}

var g_SeriesCode = "";
function clickSeriesCode(pSeriesCode) {
	g_SeriesCode = pSeriesCode;
	
	var isSetGrid = toggleTab($("li[data-type='R']"));
	
	if(!isSetGrid) {
		setGrid("R");
	}
}

function clickRecordClass(pRecordClassNum, pRecordSubject, pTargetID, pKeepPeriod) {
	var returnData = {};
	
	returnData.RecordClassNum = pRecordClassNum;
	returnData.RecordSubject = pRecordSubject;
	returnData.TargetID = pTargetID;
	returnData.KeepPeriod = pKeepPeriod;

	opener.setRecord(returnData);
	
	Common.Close();
}

function openRecordInfoPopup(pRecordClassNum) {
	var url = "/approval/user/getRecordGFileAddPopup.do?mode=R&recordClassNum="+pRecordClassNum;
	
	Common.open("", "addRecord", "<spring:message code='Cache.lbl_inquiryRecordFile' />", url, "400px", "460px", "iframe", true, null, null, true);
}

function toggleTab(obj) {
	var clickedTab = $(obj);
	var clickedStr = $(clickedTab).attr("data-tab");
	var clickedType = $(clickedTab).attr("data-type");
	
	var currentTab = $(".rtab-link.current");
	var currentStr = $(currentTab).attr("data-tab");
	
	if(clickedStr == currentStr)
		return false;
	
	$(clickedTab).addClass("current");
	$("#"+clickedStr).addClass("current");
	$(currentTab).removeClass("current");
	$("#"+currentStr).removeClass("current");
	
	setGrid(clickedType);
}


function toggleRecordFav(action) {
	var grid = (action == "I" ? "ListGrid" : "FavListGrid");
	var type = (action == "I" ? "R" : "F");
	var checkedList =  window[grid].getCheckedList(0);
	
	if(checkedList.length == 0) {
		Common.Inform(Common.getDic(check_msg));	//추가/삭제할 항목을 선택해주세요
		return;
	}
	
	var recordClassNum = "";
	for(var i = 0; i < checkedList.length; i++) {
		recordClassNum += checkedList[i].RecordClassNum + ",";
	}
	recordClassNum = recordClassNum.substring(0, recordClassNum.length -1);
	
	$.ajax({
		url	: "/approval/toggleRecordFav.do",
		type: "POST",
		data: {
			"action" : action,
			"RecordClassNum" : recordClassNum
		},
		success:function (data) {
			if(data.status == "SUCCESS" && data.data != 0){
				Common.Inform(data.message); 
				
				setListData(type);
			}else{
				Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
			}
		},
		error:function (error){
			Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
		}
	});
}

function setYearList(){
	$.ajax({
		url: "/approval/user/getSeriesBaseYearList.do",
		type: "POST",
		dataType: "json",
		async: false,
		success: function(data){
			var list = data.list;
			var baseYearHtml = "";
			var listCnt = list.length-1;
			//단위업무 년도
			baseYear = listCnt != -1 ? list[listCnt].BaseYear : new Date().getFullYear();
			//년도 값 없으면 최신년도, 있으면 그값으로 세팅
			var selYear = $("#selBaseYear").val() == null ? baseYear : $("#selBaseYear").val();
			
			$.each(list, function(idx, item){
				//최신년도 선택
				if(selYear == item.BaseYear){
					baseYearHtml += "<option value='"+item.BaseYear+"' selected>"+item.BaseYear+"</option>";
				}else{
					baseYearHtml += "<option value='"+item.BaseYear+"'>"+item.BaseYear+"</option>";
				}
			});
			
			$("#selBaseYear").html(baseYearHtml);
			$("#selBaseYear").val(selYear);
		},
		error: function(error){
			Common.Error("오류가 발생했습니다."); // 오류가 발생했습니다.
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
			var selDept = $("#subDeptList").val() == null ? deptID : $("#subDeptList").val();
							
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
</script>