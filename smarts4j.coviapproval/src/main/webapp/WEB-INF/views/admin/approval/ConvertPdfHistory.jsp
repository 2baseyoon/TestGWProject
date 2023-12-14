<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<h3 class="con_tit_box">
	<span class="con_tit">결재문서 내보내기 이력조회</span>
</h3>
<div style="width:100%;min-height: 500px">
	<div id="topitembar02" class="topbar_grid">
		<input type="button" class="AXButton BtnRefresh" onclick="Refresh();" value="<spring:message code="Cache.lbl_Refresh"/>"/>
		<select name="selectDomain" id="selectDomain" class="AXSelect"></select>
		<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
		<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
		<select class="AXSelect" id="SearchType" name="SearchType" >
				<option selected="selected" value=""><spring:message code="Cache.msg_Select"/></option>
				<option value="FormPrefix"><spring:message code='Cache.lbl_FormID'/></option>
				<option value="Subject"><spring:message code='Cache.lbl_subject'/></option>
				<option value="TaskID">Task ID</option>
				<option value="FormInstID">FormInstID</option>
		</select>
		<input type="text" id="srch_Text" class="AXInput" />
		<input id="btnSearch" type="button" name="btnSearch" class="AXButton" onclick="searchHistory()" value='<spring:message code="Cache.btn_search"/>'/> <!-- 검색 -->
	</div>
	<div id="GridView" class="tblList" style="overflow:hidden;"></div>
</div>
<script type="text/javascript">
	var myGrid = new coviGrid();
	var headerData;
	var companys = document.querySelector("#Companys");
	
	initPage();
	
	function initPage(){
		headerData = [
    		  	{key:'HistoryID',  label:'', align:'center',display:false, hideFilter : 'Y', sort : "desc"},
    		  	{key:'State',  label:'<spring:message code="Cache.lbl_apv_state"/>', width:'100', align:'center'},
    		  	{key:'TaskID',  label:'TaskID', width:'150', align:'center'},
            	{key:'Subject',  label:'<spring:message code="Cache.lbl_subject"/>', width:'300', align:'left', sort:false, formatter: function(){
            		return "<a href='#' onclick='viewPopupApproval(\""+this.item.ProcessID+"\", \""+this.item.FormInstID+"\");'>"+ this.item.Subject +"</a>"
            	}},
            	{key:'ErrorStackTrace', label:'<spring:message code="Cache.lbl_apv_error_message"/>', width:'200', align:'left', formatter : function() {
            		return this.item.ErrorStackTrace ? "<a href='#'>"+ this.item.ErrorStackTrace +"</a>" : "";
            	}},
            	{key:'FormPrefix', label:'<spring:message code="Cache.lbl_FormID"/>', width:'170', align:'center'},
            	{key:'FormInstID', label:'FormInstID',  width:'100', align:'center'},
            	{key:'UserCode', display:false, label:'<spring:message code="Cache.lbl_apv_writer"/>',  width:'1', align:'center'}, // 기안자
            	{key:'UserName', label:'<spring:message code="Cache.lbl_apv_writer"/>',  width:'120', align:'center', formatter: function(){
            		return CFN_GetDicInfo(this.item.UserName);
            	}}, // 기안자
            	{key:'ConvertStartTime', label:'<spring:message code="Cache.lbl_StartTime"/>',  width:'150', align:'center', formatter: function(){
            		return "<span>"+CFN_TransLocalTime(this.item.ConvertStartTime)+"</span>";
            	}},
            	{key:'ConvertEndTime', label:'<spring:message code="Cache.lbl_EndTime"/>',  width:'150', align:'center', formatter: function(){
            		return this.item.ConvertEndTime ? "<span>"+CFN_TransLocalTime(this.item.ConvertEndTime)+"</span>" : "";
            	}},
            	{key:'RegistName', label:'<spring:message code="Cache.btn_apv_register"/>',  width:'150', align:'center', formatter : function() {
            		return CFN_GetDicInfo(this.item.RegisterName);
            	}}
		];
		
		
		myGrid = new coviGrid();
		setGrid();
		searchHistory();
	}
	
	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
		
		coviCtrl.renderCompanyAXSelect('selectDomain', 'ko', true, 'searchLog', '', '');
		$("#SearchType").bindSelect();
		
		var curDate = new Date();
		var curDateStr = curDate.getFullYear() + "-" + (curDate.getMonth()+1 < 10 ? "0" + curDate.getMonth()+1 : curDate.getMonth()+1) + "-" + curDate.getDate();
		$("#startdate").val(curDateStr);
		$("#enddate").val(curDateStr);
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "GridView",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			body: {
				onclick: function(){
					var idx = Number(this.c);
					var colInfo = myGrid.config.colGroup[idx];
					if(["ErrorStackTrace"].indexOf(colInfo.key) > -1) {
						showDetailPop(event.target, this);
					}
				}
			},
			xscroll : true,
			fitToWidth : false
		};
		myGrid.setGridConfig(configObj);
	}
	
	function searchHistory(){
		// 검색기간 2년 이하로 제한
		var companyCode = $("#selectDomain").val();
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		var SearchText = $("#srch_Text").val();
		var SearchType = $("#SearchType").val();
				
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
 			ajaxUrl : "/approval/common/convert/getConvertHistory.do",
 			ajaxPars: {
 				"CompanyCode":companyCode,
 				"StartDate":strdate,
 				"EndDate":enddate,
 				"SearchText":SearchText,
 				"SearchType":SearchType
 			},
 			onLoad:function(){
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			},
 			objectName: 'myGrid',
 			callbackName: 'searchHistory'
		});
	}
	
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	// 데이터 상세보기 팝업
	function showDetailPop(oTarget, oThis){
		var oHeader = myGrid.config.colGroup[oThis.c];
   		//var strData = myGrid.list[oThis.index][oHeader.key];
   		var strData = $(oTarget).text();
   		Common.open("",oHeader.key, oHeader.label, "<textarea style='font-family:Consolas;resize:none;width:100%;height:100%;line-height:130%; text-align:left' readonly>"+strData+"</textarea>", "900px","530px","html",true,null,null,true);
	}
	
	//엔터검색
	function cmdSearch(){
		searchHistory();
	}
	
	function viewPopupApproval(ProcessID, forminstanceID) {
		CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&forminstanceID="+forminstanceID, "", 790, (window.screen.height - 100), "resize");
	}
	
</script>