<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>     
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
 
	<div class="layer_divpop ui-draggable" id="testpopup_p" style="width:99%; z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
 		<!-- 팝업 Contents 시작 -->
	  <div class="divpop_contents lineNone wd02">
			<div class="pop_header" id="testpopup_ph">
 				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico"><spring:message code="Cache.lbl_selectRecordFile"/></span></h4><!--기록물철 선택 -->
			</div>
			<div class="popContent portalOrgPopContent">
				<!--recordSelBox 시작 -->
				<div id="" class="recordSelBox recordSelBox02">
					<div class="recordList" >
						<select id="selBaseYear" class="selectType02" style="width:100px" onChange="setListData('S');"></select>	
						<select id="subDeptList" class="selectType02" onChange="setListData('S');"></select>
						<select id="subFunctionLevel1" class="selectType02" style="width:100px"  onChange="setFunctionLevel('1');"></select>
						<select id="subFunctionLevel2" class="selectType02" style="width:100px"  onChange="setFunctionLevel('2');"></select>
						<select id="subFunctionLevel3" class="selectType02" style="width:130px"  onChange="setFunctionLevel('3');"></select>
						
						<div id="SeriesListGrid" style="height: auto"></div>
					</div>

				<!-- 탭영역 시작 -->
					<div class="recordTab" id="">
					<ul class="rtabList" style="margin-bottom:0px">
						<li onclick="toggleTab(this)" class="rtab-link current" data-tab="rtab-1" data-type="R"><a href="#n"><spring:message code="Cache.lbl_recordFile"/></a></li><%--기록물철 --%>
						<li onclick="toggleTab(this)" class="rtab-link" data-tab="rtab-2" data-type="F"><a href="#n"><spring:message code="Cache.lbl_Favorite"/></a></li><%--즐겨찾기 --%>
					</ul>

					<div id="rtab-1" class="rtabCont current">
						<!-- 검색영역 시작 -->
						<div class="searchBoxArea">
							<div class="sLeft">
								<strong class="sTit"><spring:message code="Cache.lbl_recordFile"/> <spring:message code="Cache.btn_search"/></strong><!--  기록물철 검색-->
								<div class="searchBox02">
									<span>
										<input type="text"  placeholder="<spring:message code='Cache.msg_apv_001'/>" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
										<button id="simpleSearchBtn" type="button" onclick="onClickSearchButton();" class="btnSearchType01"><spring:message code="Cache.btn_search"/></button> <!-- 검색 -->																			
									</span>											
								</div>
							</div>
							<div class="sRight">
								<!-- <a href="#" class="btnTypeDefault">편철</a> -->
							</div>
						</div>
						<!-- 검색영역 끝 -->
						<a onclick="toggleRecordFav('I')" class="btnTypeDefault btnTypeChk"><spring:message code="Cache.btn_addFavorite"/></a><!--  즐겨찾기 추가-->
						<div class="tblList tblCont boradBottomCont recordTb">
							<div id="ListGrid" style="height: auto;"></div>
						</div>
					</div>
					<div id="rtab-2" class="rtabCont">
						<a onclick="toggleRecordFav('D')" class="btnTypeDefault btnTypeChk"><spring:message code="Cache.ACC_btn_deleteFavorite"/></a><!--  즐겨찾기 삭제-->
						<div class="tblList tblCont boradBottomCont recordTb">
							<div id="FavListGrid" style="height: auto;"></div>
						</div>
					</div>
				</div>
				<!-- 탭영역  끝 -->
					
               <!-- 기목물 기본정보 영역 시작 -->			
	        <div class="recordInfo">		       	
				<div  name="default_info" id="dvHeader" style="display:none" >
				   <strong class="Public_title"><spring:message code='Cache.lbl_BasicInfo'/></strong>
				</div>
				<table class="table_3 tableStyle linePlus" cellpadding="0" cellspacing="0" name="default_info" id="tbHeader" style="display:none">
					<colgroup>
						<col style="width: 30%">
						<col style="width: 70%">
					</colgroup>
					<tbody>
					<tr>
						<th><spring:message code='Cache.lbl_Title'/></th>
						<td><input type="text" class="input-required w100" style="width: 98%;" id="TITLE" name="returnDataField" ></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_DocNo'/></th>
						<td><input type="text" class="w100" style="width: 98%;" id="DOC_NO" disabled="disabled"></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_Address'/></th>
						<td><select id="ADDRESS" class="w100" name="returnDataField" cdgrp="GovAddress"></select></td>
					</tr>
					</tbody>
				</table>
			</div>
						
			<div  class="recordInfo" id="dvRecordDoc" style="padding-top: 10px">
			    <strong class="Public_title"><spring:message code='Cache.lbl_recordInfo'/></strong>

				<table class="table_3 tableStyle linePlus" cellpadding="0" cellspacing="0">
					<colgroup>
						<col style="width: 30%">
						<col style="width: 70%">
					</colgroup>
					<tbody>
					<tr>
						<th><spring:message code='Cache.lbl_recordFile'/></th>
						<td>
							<input type="text" class="input-required" id="RECORD_SUBJECT" name="returnDataField" style="width: 99%;" disabled="disabled">
							<input type="hidden" id="RECORD_CLASS_NUM" name="returnDataField">
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_recordRegistType'/></th>
						<td><select id="REGIST_CHECK" class="input-required mw150p" name="returnDataField" cdgrp="RegistCheck"></select></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_specialRecord'/></th>
						<td><select id="SPECIAL_RECORD" class="input-required mw150p" name="returnDataField" cdgrp="SpecialRecord"></select></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_preservationPeriod2'/></th>
						<td><select id="KEEP_PERIOD" class="input-required mw150p" name="returnDataField" cdgrp="KeepPeriod"></select></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_apv_Publication'/></th>
						<td>
							<select id="RELEASE_CHECK" class="input-required mw150p" name="returnDataField" cdgrp="ReleaseCheck" onchange="toggleCheckDiv();"></select>
							<div id="RELEASE_CHECK_DIV" style="display: none;"></div>
						</td>
					</tr>
					<tr id="trReleaseRestriction" style="display: none;">
						<th><spring:message code='Cache.lbl_publicationPartDisplay'/></th>
						<td><input type="text" id="RELEASE_RESTRICTION" class="input-required mw150p" name="returnDataField" style="width: 98%;"></select></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_viewRange'/><br>(<spring:message code='Cache.lbl_SecurityLevel'/>)</th>
						<td><select id="SECURE_LEVEL" class="input-required mw150p" name="returnDataField" cdgrp="SecureLevel"></select></td>
					</tr>
					<tbody>
				</table>
			   </div>
			 </div>					
               <!-- 기목물 기본정보 영역 끝 -->												
		    </div>
		    <!--recordSelBox 끝 -->	    
			<div class="popBtn tCenter btNone pd0">
				<a class="blBtn" href="javascript:doSave();"><spring:message code='Cache.btn_save'/></a>
				<a class="btnTypeDefault" href="javascript:Common.Close();"><spring:message code='Cache.btn_apv_close'/></a>
			</div>					
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

var idx = CFN_GetQueryString("idx");
var type = CFN_GetQueryString("type") ;// rc:단건 rcm:다안 
var multiIdx = CFN_GetQueryString("idx"); // 안 num 

var SeriesListGrid = new coviGrid();
var ListGrid = new coviGrid();
var FavListGrid = new coviGrid();

$(document).ready(function(){
	if(type !="rc"){
		$("#dvHeader").show();
		$("#tbHeader").show();
	}else if(type =="rc"){
		$("#dvRecordDoc").css("padding-top", 0);
	}
});

$(window).load(function () {
	setGrid('S');		
	setSelectBox();//기록물철 정보
	
	if(type !="rc"){
		setSavedInfo();
	}
	else{
		if(opener.$("#RECORD_DocInfo").val() !=""){//기록물철 단건
			setSavedSingleInfo();
		}
	}
	
});

function setGrid(type){
	setYearList();
	setDeptList();
	setGridHeader(type);
	setGridConfig(type);
	setListData(type);
	
	if(type=="S"){
		setFunctionLevel('1');
	}
}

function onClickSearchButton(){//검색
	setListData('R');
}

function setGridHeader(type){
	var headerData = [];
	
	if(type == "S") { // 단위업무
		headerData =[
			{key:'functionlevel1', label:'Level1', width:'70', align:'center'}, //Level1
			{key:'functionlevel2', label:'Level2', width:'70', align:'center'}, //Level2
			{key:'functionlevel3', label:'Level3', width:'100', align:'center'}, //Level3
			{key:'SeriesCode', label:'<spring:message code="Cache.lbl_unitTaskCode"/>', width:'100', align:'center'}, //단위업무 코드
			{key:'SeriesName',  label:'<spring:message code="Cache.lbl_unitTaskName"/>', width:'100', align:'center',  //단위업무명
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
			{key:'RecordClassNum', label:'<spring:message code="Cache.lbl_recordFile"/>', width:'100', align:'left', //<spring:message code="Cache.lbl_apv_DocBinder"/>
				formatter:function (){
					var sHtml = "";
					sHtml += "<div>";
					sHtml += "	<a onclick='clickRecordClass(\""+this.item.RecordClassNum+"\", \""+this.item.RecordSubject+"\", \""+targetID+"\", \""+this.item.KeepPeriod+"\"); return false;'>"+this.item.RecordSubject+"</a>";
					sHtml += "	<span style='cursor:pointer;' class='newWindowPop' onclick='openRecordInfoPopup(\""+this.item.RecordClassNum+"\"); return false;'></span>";
					sHtml += "</div>";
					
					return sHtml;
		   		}
			},
			{key:'KeepPeriodName',  label:'<spring:message code="Cache.lbl_preservationPeriod"/>', width:'55', align:'center'}, //보존기간
			{key:'WorkCharger',  label:'<spring:message code="Cache.lbl_apv_charge_person"/>', width:'55', align:'center'} //담당자
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
			height:"500",
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
    				params.DeptID = $("#subDeptList").val(); //단위업무 부서코드
    				params.DeptCode = deptID; // 세션 부서코드
    				params.baseYear = $("#selBaseYear").val();
    				params.pageNo = SeriesListGrid.page.pageNo;
    				params.pageSize = SeriesListGrid.page.pageSize;
    				params.functioncode = "";
    				
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
        						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
    						}
    					},
    					error:function (error){
    						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
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
	var searchWord = $("#searchInput").val();
	var selFucntionLevel = "";
	var functionLevel = ""; //레벨 선택

	if(type !="S" && type !="L"){
		if($("#subFunctionLevel3").val()=="000000"){
			selFucntionLevel = $("#subFunctionLevel2").val();
		}
		else{
			selFucntionLevel = $("#subFunctionLevel3").val();
		}
	}
	
	if(type =="L"){
		//Level1 선택
		$("#subFunctionLevel1").val() == "000000" ? selFucntionLevel = "" : ( selFucntionLevel =  $("#subFunctionLevel1").val(), functionLevel = "1");
		//Level2 선택
		(selFucntionLevel == "" || $("#subFunctionLevel2").val() == "000000") ?  "" : ( selFucntionLevel = $("#subFunctionLevel2").val(), functionLevel = "2");
		//Level3 선택
		(selFucntionLevel == "" || $("#subFunctionLevel3").val() == "000000") ? "" : ( selFucntionLevel = $("#subFunctionLevel3").val(), functionLevel = "3");	
	}
	
	if(selFucntionLevel==null){
		selFucntionLevel = "";
	}
	
	var params = {
		"DeptID" : $("#subDeptList").val(),
		"baseYear" : $("#selBaseYear").val(),
		"functioncode" : selFucntionLevel,
		"searchWord" : searchWord,
		"existsGFile":"true",	//기록물철이 있는것만
		"functionlevel" : functionLevel, //레벨
		"DeptCode" : deptID // 세션 부서코드

		}
	
	if(type == "S" || type == "L"){
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

	setRecord(returnData);
	
}

function openRecordInfoPopup(pRecordClassNum) {
	var url = "/approval/user/getRecordGFileAddPopup.do?mode=R&recordClassNum="+pRecordClassNum;
	
	Common.open("", "addRecord", "<spring:message code='Cache.lbl_inquiryRecordFile' />", url, "420px", "460px", "iframe", true, null, null, true);
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
				Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
			}
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
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
			var selDept = $("#subDeptList").val() == null ? deptID : $("#subDeptList").val();
							
			$.each(subDeptList, function(idx, item){
				//부서 선택
				if(selDept == item.GroupCode){
					subDeptOption += "<option value='"+item.GroupCode+"' selected>"+item.TransMultiDisplayName+"</option>";
				}else{
					subDeptOption += "<option value='"+item.GroupCode+"'>"+item.TransMultiDisplayName+"</option>";
				}
			});
			
			$("#subDeptList").html(subDeptOption);
			$("#subDeptList").val(selDept);
		},
		error: function(error){
			Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
		}
	});
}

//업무구분
function setFunctionLevel(level){
	var functioncode = "";
	
	if(level=="1"){
		functioncode ="";
	}
	else if(level=="2"){
		functioncode =  $("#subFunctionLevel1").val();
	}	
	else if(level=="3"){
		functioncode = $("#subFunctionLevel2").val();
	}	
	
	$.ajax({
		url: "/approval/user/getFunctionLevel.do",
		type: "POST",
		dataType: "json",
		data: {
			"level" : level,
			"deptid" : $("#subDeptList").val(),
			"functioncode" : functioncode,
			"baseyear": $("#selBaseYear").val()
		},		
		async: false,
		success: function(data){
			isAdmin = data.isAdmin;
			var levelList = data.list;
			var subLevelOptionTmp = "";
			var subLevelOption = "";
			var selLevel = "";
							
			subLevelOption += "<option value='000000'>"+Common.getDic('ACC_lbl_choice')+"</option>";
			subLevelOptionTmp = "<option value='000000'>"+Common.getDic('ACC_lbl_choice')+"</option>";
			
			$.each(levelList, function(idx, item){
				subLevelOption += "<option value='"+item.functioncode+"'>"+item.functionname+"</option>";
			});
			
			if(level=="1"){
				selLevel = $("#subFunctionLevel1").val() == null ? "000000" : $("#subFunctionLevel1").val();			
				$("#subFunctionLevel1").html(subLevelOption);
				$("#subFunctionLevel1").val(selLevel);
				
				$("#subFunctionLevel2").html(subLevelOptionTmp);
				$("#subFunctionLevel2").val("000000");			
				$("#subFunctionLevel3").html(subLevelOptionTmp);
				$("#subFunctionLevel3").val("000000");
							
				setFunctionLevel('2');
			}
			else if(level=="2"){
				selLevel = $("#subFunctionLevel2").val() == null ? "000000" : $("#subFunctionLevel2").val();
				$("#subFunctionLevel2").html(subLevelOption);
				$("#subFunctionLevel2").val(selLevel);			

				$("#subFunctionLevel3").html(subLevelOptionTmp);
				$("#subFunctionLevel3").val("000000");
							
				setFunctionLevel('3');
			}
			else if(level=="3"){
				selLevel = $("#subFunctionLevel3").val() == null ? "000000" : $("#subFunctionLevel3").val();
				$("#subFunctionLevel3").html(subLevelOption);
				$("#subFunctionLevel3").val(selLevel);
				//레벨 선택
				setListData('L');
			}
		 
		},
		error: function(error){
			Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
		}
	});
}

function setSelectBox() {
	var codeList = [];
	$("select").each(function(i, obj) {
		if($(obj).attr("cdgrp") != undefined){
		  codeList.push($(obj).attr("cdgrp"));
		}
	});
	
	Common.getBaseCodeList(codeList);
	
	for(var i = 0; i < codeList.length; i++) {
		var codeGroup = codeList[i];
		var codeMap = coviCmn.codeMap[codeGroup];
		
		var optHtml = "";
		if(codeMap[0].Code != "") { // 코드그룹 내 첫번째 코드가 빈값인 경우는 선택 option 필요 X
				optHtml += "<option value=''>" + Common.getDic("lbl_selection") + "</option>";
		}
		
		for(var j = 0; j < codeMap.length; j++) {
			optHtml += "<option value='"+codeMap[j].Code+"'>"+CFN_GetDicInfo(codeMap[j].MultiCodeName)+"</option>";
		}
		$("select[cdgrp="+codeGroup+"]").append(optHtml);
	}
	
	var checkHtml = "";
	for(var i = 1; i <= 8; i++) {
		checkHtml += "<input type='checkbox' name='ReleaseCheckField' id='RELEASE_CHECK_HO"+i+"'><label for='RELEASE_CHECK_HO"+i+"'> "+i+"호</label>&nbsp;&nbsp;";
		if(i == 4) {
			checkHtml += "<br/>";
		}
	}
	$("#RELEASE_CHECK_DIV").html(checkHtml);
}


//기록물철 정보
function setSavedInfo() {
	$("[name=returnDataField]").each(function(i, obj){
		var id = $(obj).attr("id");
			var savedVal = "";
		
		if(id == "RELEASE_CHECK") {
				savedVal = opener.document.getElementsByName("MULTI_"+id)[idx].value;

			var hoArr = savedVal.substring(1).split('');
			for(var h = 1; h <= 8; h++) {
				if(hoArr[h-1] == "Y") {
					$("#RELEASE_CHECK_HO"+h).prop("checked", "checked");
				} else {
					$("#RELEASE_CHECK_HO"+h).prop("checked", false);
				}
			}
			
			toggleCheckDiv();
				
				$(obj).val(savedVal.charAt(0));
			} else if(id == "TITLE" && opener.isUseHWPEditor()) {
	    		var oMultiCtrl = opener.getMultiCtrlEditor();
	    		
	    		savedVal = oMultiCtrl.GetFieldText("SUBJECT");
	    		
				$(obj).val(savedVal);
		} else {
				savedVal = opener.document.getElementsByName("MULTI_"+id)[idx].value;
				
			$(obj).val(savedVal);
		}
	});	
	
	$("#DOC_NO").val(opener.document.getElementById("DocNo").value);
}

function setSavedSingleInfo() {
	var oRecordDocInfo = $.parseJSON(opener.$("#RECORD_DocInfo").val());
	
	$("#RECORD_SUBJECT").val(oRecordDocInfo.RECORD_SUBJECT)  //기록물철명
	$("#RECORD_CLASS_NUM").val(oRecordDocInfo.RECORD_CLASS_NUM)  //기록물철코드
	$("#REGIST_CHECK").val(oRecordDocInfo.REGIST_CHECK)  //등록구분
	$("#SPECIAL_RECORD").val(oRecordDocInfo.SPECIAL_RECORD)  //특수기록물
	$("#KEEP_PERIOD").val(oRecordDocInfo.KEEP_PERIOD)  //보존기간
	$("#SECURE_LEVEL").val(oRecordDocInfo.SECURE_LEVEL)  //열람범위 
	//$("#RELEASE_CHECK").val(oRecordDocInfo.RELEASE_CHECK)  //공개여부
	var strRELEASE_CHECK = oRecordDocInfo.RELEASE_CHECK;
	var strVal = "";
	var strCheck = "";
	if(strRELEASE_CHECK){
		strVal = strRELEASE_CHECK.substring(0,1);
		strCheck = strRELEASE_CHECK.substring(1);
		$("#RELEASE_CHECK").val(strVal);
		if(strVal == "" || strVal == "1") {
			$("#RELEASE_CHECK_DIV").hide();
		} else {
			$("#RELEASE_CHECK_DIV").show();
			$("[name=ReleaseCheckField]").each(function(i, obj){
				var strCheckVal = strCheck.substring(i,i+1);
				if(strCheckVal == "Y") $(obj).prop("checked",true);
			});
		}
	}
}

function toggleCheckDiv() {
	if($("#RELEASE_CHECK").val() == "" || $("#RELEASE_CHECK").val() == "1") {
		$("#RELEASE_CHECK_DIV").hide();
	} else {
		$("#RELEASE_CHECK_DIV").show();
	}
}

function setRecord(returnObj) {
	$("#RECORD_CLASS_NUM").val(returnObj.RecordClassNum);
	$("#RECORD_SUBJECT").val(returnObj.RecordSubject);
}

function doSave() {
	if(!validationCheck()) return;
	
	var returnData = {};
	
	var ho = "";
	$("[name=ReleaseCheckField]").each(function(i, obj){
		ho += ($(obj)[0].checked ? "Y" : "N");
	});
	
	$("[name=returnDataField]").each(function(i, obj){
		var id = $(obj).attr("id");
		
		returnData[id] = $(obj).val();
		
		if(id == "RELEASE_CHECK" && $(obj).val() != "") {
			if($(obj).val() == "1") {
				returnData[id] += "NNNNNNNN";
			} else {
				returnData[id] += ho;
			}
		}
	});
	
	if(type =="rc"){ // 다안기안x
		var recordSubject = $("#RECORD_SUBJECT").val();
		var recordClassNum = $("#RECORD_CLASS_NUM").val();
						
		var recordDocData = new Object();
		recordDocData.RECORD_SUBJECT = $("#RECORD_SUBJECT").val();  //기록물철명
		recordDocData.RECORD_CLASS_NUM = $("#RECORD_CLASS_NUM").val();  //기록물철코드
		recordDocData.REGIST_CHECK = $("#REGIST_CHECK").val();  //등록구분
		recordDocData.SPECIAL_RECORD = $("#SPECIAL_RECORD").val();  //특수기록물
		recordDocData.KEEP_PERIOD = $("#KEEP_PERIOD").val();  //보존기간
		//recordDocData.RELEASE_CHECK = $("#RELEASE_CHECK").val();  //공개여부
		recordDocData.RELEASE_CHECK = $("#RELEASE_CHECK").val() + ho;
		recordDocData.SECURE_LEVEL = $("#SECURE_LEVEL").val();  //열람범위
				
		var jsonData = JSON.stringify(recordDocData);
		
		opener.$("#RecordDocInfo").show();
		opener.$("#recordSubject").val(recordSubject);
		opener.$("#RECORD_SUBJECT").val(recordSubject);
		opener.$("#RECORD_CLASS_NUM").val(recordClassNum);
		opener.$("#RECORD_DocInfo").val(jsonData);
 
		Common.Close();
	}else if(type =="rcm"){ // 다안기안
		var recordSubject = $("#RECORD_SUBJECT").val();
		var recordClassNum = $("#RECORD_CLASS_NUM").val();
		var title = $("#TITLE").val();
						
		var recordDocData = new Object();
		//기록물철명
		recordDocData.RECORD_SUBJECT = $("#RECORD_SUBJECT").val();
		opener.document.getElementsByName('MULTI_RECORD_SUBJECT')[multiIdx].value = $("#RECORD_SUBJECT").val();
		//기록물철코드
		recordDocData.RECORD_CLASS_NUM = $("#RECORD_CLASS_NUM").val();
		opener.document.getElementsByName('MULTI_RECORD_CLASS_NUM')[multiIdx].value = $("#RECORD_CLASS_NUM").val();
		// 등록구분
		recordDocData.REGIST_CHECK = $("#REGIST_CHECK").val();
		opener.document.getElementsByName('MULTI_REGIST_CHECK')[multiIdx].value = $("#REGIST_CHECK").val();
		//특수기록물
		recordDocData.SPECIAL_RECORD = $("#SPECIAL_RECORD").val();
		opener.document.getElementsByName('MULTI_SPECIAL_RECORD')[multiIdx].value = $("#SPECIAL_RECORD").val();
		// 보존기간
		recordDocData.KEEP_PERIOD = $("#KEEP_PERIOD").val();
		opener.document.getElementsByName('MULTI_KEEP_PERIOD')[multiIdx].value = $("#KEEP_PERIOD").val();
		// 열람범위
		recordDocData.SECURE_LEVEL = $("#SECURE_LEVEL").val();
		opener.document.getElementsByName('MULTI_SECURE_LEVEL')[multiIdx].value = $("#SECURE_LEVEL").val();
		//공개여부
		recordDocData.RELEASE_CHECK = $("#RELEASE_CHECK").val();
		//opener.document.getElementsByName('MULTI_RELEASE_CHECK')[multiIdx].value = $("#RELEASE_CHECK").val();
		opener.document.getElementsByName('MULTI_RELEASE_CHECK')[multiIdx].value = $("#RELEASE_CHECK").val() + ho;
				
		var jsonData = JSON.stringify(recordDocData);
		
		// 제목
		$("#"+"Subject"+multiIdx,top.opener.document).children().val(title);
		if(multiIdx == "1") $("#Subject").val(title);
		// 기록물철
		top.opener.document.getElementById("RecordInfo"+multiIdx).innerHTML = recordSubject;
 		//opener.$("#RecordInfo"+multiIdx).innerHtml(recordSubject);
		
		Common.Close();
	}
	else if(idx != "dist") {
		opener.setGovDocInfo(returnData);
		
		Common.Close();
	} 
	else {
		$.ajax({
			url	: "/approval/user/saveDocTempInfo.do",
			type: "POST",
			data: {
				"DocInfoParam" : JSON.stringify(returnData),
				"FormInstID" : formInstID,
				"ProcessID" : processID,
				"DeptCode" : deptCode
			},
			success:function (data) {
				if(data.status == "SUCCESS"){
						opener.G_displaySpnRecordInfoMulti(idx, returnData);
						
					Common.Inform(data.message); 
					Common.Close();
				}else{
						Common.Error(Common.getDic("msg_apv_030"));
				}
			},
			error:function (error){
					Common.Error(Common.getDic("msg_apv_030"));
			}
		});
	}
}

function validationCheck() {
	//if(idx == "dist") {
		if(!$("#RECORD_CLASS_NUM").val()) {
			Common.Warning(Common.getDic("msg_selectRecordClass"));
			return false;
		}
		
		if(!$("#REGIST_CHECK").val()) {
			Common.Warning(Common.getDic("msg_selectRegistCheck"));
			return false;
		}
		
		if(!$("#SPECIAL_RECORD").val()) {
			Common.Warning(Common.getDic("msg_selectSpecialRecord"));
			return false;
		}
		
		if(!$("#KEEP_PERIOD").val()) {
			Common.Warning(Common.getDic("msg_selectKeepPeriod"));
			return false;
		}
		
		if(!$("#RELEASE_CHECK").val()) {
			Common.Warning(Common.getDic("msg_selectReleaseCheck"));
			return false;
		}
		
		if(!$("#SECURE_LEVEL").val()) {
			Common.Warning(Common.getDic("msg_selectSecureLevel"));
			return false;
		}
	//}

return true;
}



</script>