<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.CN_103"/></span> <!-- 월별 비교 -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa03 active" id="DetailSearch">
		<div>
			<!--<spring:message code="Cache.lbl_secAtt1" />
			<select  name="selectDdlCompany" class="AXSelect" id="selectDdlCompany"></select>-->
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_apv_compareItem"/></span>				
				<select class="selectType02" name="selectCompareItem" id="selectCompareItem" ></select>
				
				<span style="margin-left:10px;"><spring:message code="Cache.lbl_Start"/>&nbsp;<spring:message code="Cache.lbl_apv_year"/>/<spring:message code="Cache.lbl_apv_month"/></span>
				<select class="selectType02 w70p" name="selectYear" id="selectYear"></select>
				<span><spring:message code="Cache.lbl_apv_year"/></span>
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchSTAT();"><spring:message code="Cache.btn_search"/></a>
			<div id="topitembar01" class="selectCalView ml15">
				<div class="radioStyle05"><input type="radio" id="Dept" name="radio" value="GetDept" onclick="ChageView(this);" checked="checked"><label for="Dept"><spring:message code="Cache.lbl_apv_ByDept" /></label></div>
				<div class="radioStyle05"><input type="radio" id="Form" name="radio" value="GetForm" onclick="ChageView(this);"><label for="Form"><spring:message code="Cache.lbl_apv_ByForm" /></label></div>
				<div class="radioStyle05"><input type="radio" id="Person" name="radio" value="GetPerson" onclick="ChageView(this);"><label for="Person"><spring:message code="Cache.lbl_apv_ByPerson" /></label></div>
			</div>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnExcel" href="#" onclick="ExcelDownload();"><spring:message code="Cache.lbl_apv_SaveToExcel"/></a>
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize" onchange="searchSTAT(true);">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="GetDeptgrid" style=""></div>
			<div id="GetFormgrid" style=""></div>
			<div id="GetUsergrid" style=""></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
		<input type="hidden" id="hidden_worktype_val" value=""/>
	</div>
</div>

<script type="text/javascript">
	var headerData1 = null;
	var headerData2 = null;
	var headerData3 = null;

	var myGrid1 = new coviGrid();
	var myGrid2 = new coviGrid();
	var myGrid3 = new coviGrid();
	myGrid1.config.fitToWidthRightMargin = 0;
	myGrid2.config.fitToWidthRightMargin = 0;
	myGrid3.config.fitToWidthRightMargin = 0;

	initMonthlyTrendCpn();

	function initMonthlyTrendCpn(){
		setControl(); // 초기 셋팅
		setGrid();			// 그리드 세팅
		searchSTAT();
	}
	
	// 초기 셋팅
	function setControl(){ 
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
		
		SetddlView(); // 비교항목 셋팅
		$("#selectCompareItem").change(function(){
			searchSTAT();
	    });
		
		SetYear(); // 년도 셋팅
		$("#selectYear").change(function(){
			searchSTAT();
	    });
	}
	
	// 비교항목 셋팅
	function SetddlView(){
		var selValue = $("#DetailSearch input[name='radio']:checked").val();
		var objSelect = $("#selectCompareItem");
		
		$(objSelect).find("option").remove();
		
		if(selValue=="GetDept"){
			$(objSelect).css("width","130px");
			$(objSelect).append("<option value='A'>" + "<spring:message code='Cache.lbl_apv_draftDoc_cnt'/>" + "</option>")
			$(objSelect).append("<option value='B'>" + "<spring:message code='Cache.lbl_apv_receiptDoc_cnt'/>" + "</option>")
			$(objSelect).append("<option value='C'>" + "<spring:message code='Cache.lbl_ProcessingTime'/>(<spring:message code='Cache.lbl_Minutes'/>)" + "</option>")
    	}else if (selValue == "GetForm") {
    		$(objSelect).css("width","130px");
    		$(objSelect).append("<option value='A'>" + "<spring:message code='Cache.lbl_apv_completed_cnt'/>" + "</option>")
    		$(objSelect).append("<option value='B'>" + "<spring:message code='Cache.lbl_ProcessingTime'/>(<spring:message code='Cache.lbl_Minutes'/>)" + "</option>")
        } else {
        	$(objSelect).css("width","170px");
        	$(objSelect).append("<option value='A'>" + "<spring:message code='Cache.lbl_apv_draft_cnt'/>(<spring:message code='Cache.lbl_apv_accepted'/>)" + "</option>")
        	$(objSelect).append("<option value='B'>" + "<spring:message code='Cache.lbl_apv_complete_counts'/>" + "</option>")
        	$(objSelect).append("<option value='C'>" + "<spring:message code='Cache.WM_2'/>(<spring:message code='Cache.lbl_Minutes'/>)")
        }
	}
	
	// 시작 년/월 셋팅
	function SetYear(){
		var Today = new Date();
		var Year = Today.getFullYear();
		var objSelect = $("#selectYear");
		
		for (var i = 0; i < 10; i++)
        {
			var option = $("<option>");
			$(option).attr("value",Year);
			$(option).text(Year);
			$(objSelect).append(option);
			Year--;
        }
		$(objSelect).val(Today.getFullYear());
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		headerData1 =[
	                  {key:'GR_Name', label:'<spring:message code="Cache.lbl_apv_DeptName"/>', width:'200', align:'center',sort:"asc"},
	                  {key:'Month1',  label:'<spring:message code="Cache.lbl_apv_Month_1"/>', width:'50', align:'center'},
	                  {key:'Month2',  label:'<spring:message code="Cache.lbl_apv_Month_2"/>', width:'50', align:'center'},
	                  {key:'Month3',  label:'<spring:message code="Cache.lbl_apv_Month_3"/>', width:'50', align:'center'},
	                  {key:'Month4',  label:'<spring:message code="Cache.lbl_apv_Month_4"/>', width:'50', align:'center'},
	                  {key:'Month5',  label:'<spring:message code="Cache.lbl_apv_Month_5"/>', width:'50', align:'center'},
	                  {key:'Month6',  label:'<spring:message code="Cache.lbl_apv_Month_6"/>', width:'50', align:'center'},
	                  {key:'Month7',  label:'<spring:message code="Cache.lbl_apv_Month_7"/>', width:'50', align:'center'},
	                  {key:'Month8',  label:'<spring:message code="Cache.lbl_apv_Month_8"/>', width:'50', align:'center'},
	                  {key:'Month9',  label:'<spring:message code="Cache.lbl_apv_Month_9"/>', width:'50', align:'center'},
	                  {key:'Month10',  label:'<spring:message code="Cache.lbl_apv_Month_10"/>', width:'50', align:'center'},
	                  {key:'Month11',  label:'<spring:message code="Cache.lbl_apv_Month_11"/>', width:'50', align:'center'},
	                  {key:'Month12',  label:'<spring:message code="Cache.lbl_apv_Month_12"/>', width:'50', align:'center'}
		      		];
		headerData2 =[
	                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'200', align:'center',sort:"asc", formatter:function(){return CFN_GetDicInfo(this.item.FormName)}},
	                  {key:'Month1',  label:'<spring:message code="Cache.lbl_apv_Month_1"/>', width:'50', align:'center'},
	                  {key:'Month2',  label:'<spring:message code="Cache.lbl_apv_Month_2"/>', width:'50', align:'center'},
	                  {key:'Month3',  label:'<spring:message code="Cache.lbl_apv_Month_3"/>', width:'50', align:'center'},
	                  {key:'Month4',  label:'<spring:message code="Cache.lbl_apv_Month_4"/>', width:'50', align:'center'},
	                  {key:'Month5',  label:'<spring:message code="Cache.lbl_apv_Month_5"/>', width:'50', align:'center'},
	                  {key:'Month6',  label:'<spring:message code="Cache.lbl_apv_Month_6"/>', width:'50', align:'center'},
	                  {key:'Month7',  label:'<spring:message code="Cache.lbl_apv_Month_7"/>', width:'50', align:'center'},
	                  {key:'Month8',  label:'<spring:message code="Cache.lbl_apv_Month_8"/>', width:'50', align:'center'},
	                  {key:'Month9',  label:'<spring:message code="Cache.lbl_apv_Month_9"/>', width:'50', align:'center'},
	                  {key:'Month10',  label:'<spring:message code="Cache.lbl_apv_Month_10"/>', width:'50', align:'center'},
	                  {key:'Month11',  label:'<spring:message code="Cache.lbl_apv_Month_11"/>', width:'50', align:'center'},
	                  {key:'Month12',  label:'<spring:message code="Cache.lbl_apv_Month_12"/>', width:'50', align:'center'}
		      		];
		headerData3 =[
	                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_apv_person_code"/>', width:'200', align:'center',sort:"asc"},
	                  {key:'Month1',  label:'<spring:message code="Cache.lbl_apv_Month_1"/>', width:'50', align:'center'},
	                  {key:'Month2',  label:'<spring:message code="Cache.lbl_apv_Month_2"/>', width:'50', align:'center'},
	                  {key:'Month3',  label:'<spring:message code="Cache.lbl_apv_Month_3"/>', width:'50', align:'center'},
	                  {key:'Month4',  label:'<spring:message code="Cache.lbl_apv_Month_4"/>', width:'50', align:'center'},
	                  {key:'Month5',  label:'<spring:message code="Cache.lbl_apv_Month_5"/>', width:'50', align:'center'},
	                  {key:'Month6',  label:'<spring:message code="Cache.lbl_apv_Month_6"/>', width:'50', align:'center'},
	                  {key:'Month7',  label:'<spring:message code="Cache.lbl_apv_Month_7"/>', width:'50', align:'center'},
	                  {key:'Month8',  label:'<spring:message code="Cache.lbl_apv_Month_8"/>', width:'50', align:'center'},
	                  {key:'Month9',  label:'<spring:message code="Cache.lbl_apv_Month_9"/>', width:'50', align:'center'},
	                  {key:'Month10',  label:'<spring:message code="Cache.lbl_apv_Month_10"/>', width:'50', align:'center'},
	                  {key:'Month11',  label:'<spring:message code="Cache.lbl_apv_Month_11"/>', width:'50', align:'center'},
	                  {key:'Month12',  label:'<spring:message code="Cache.lbl_apv_Month_12"/>', width:'50', align:'center'}
		      		];
		
		myGrid1.setGridHeader(headerData1);
		myGrid2.setGridHeader(headerData2);
		myGrid3.setGridHeader(headerData3);

		setGridConfig1();
		setGridConfig2();
		setGridConfig3();
	}
	
	// 그리드 Config 설정
	function setGridConfig1(){
		var configObj = {
			targetID : "GetDeptgrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			colHead:{},
			body:{}	
		};
		
		myGrid1.setGridConfig(configObj);
	}
	
	// 그리드 Config 설정
	function setGridConfig2(){
		var configObj = {
			targetID : "GetFormgrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		myGrid2.setGridConfig(configObj);
	}
	
	// 그리드 Config 설정
	function setGridConfig3(){
		var configObj = {
			targetID : "GetUsergrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		myGrid3.setGridConfig(configObj);
	}
	
	// GetDeptgrid 검색
	function searchConfig1(flag){		
		var EntCode = $("#hidden_domain_val").val();
		var CompareItem = $("#selectCompareItem").val();
		var Year = $("#selectYear").val();
		myGrid1.page.pageNo = 1;
		myGrid1.bindGrid({
			ajaxUrl:"/approval/manage/getMonthlyDeptList.do",
			ajaxPars: {
				"EntCode":EntCode,
				"CompareItem":CompareItem,
				"Year":Year
			},
			onLoad:function(){
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid1.fnMakeNavi("myGrid1");
			}
		});
	}
	
	// GetFormgrid 검색
	function searchConfig2(flag){
		var EntCode = $("#hidden_domain_val").val();
		var CompareItem = $("#selectCompareItem").val();
		var Year = $("#selectYear").val();
		myGrid2.page.pageNo = 1;
		myGrid2.bindGrid({
			ajaxUrl:"/approval/manage/getMonthlyFormList.do",
			ajaxPars: {
				"EntCode":EntCode,
				"CompareItem":CompareItem,
				"Year":Year
			},
			onLoad:function(){
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid2.fnMakeNavi("myGrid2");
			}
		});
	}
	
	// GetUsergrid 검색
	function searchConfig3(flag){
		var EntCode = $("#hidden_domain_val").val();
		var CompareItem = $("#selectCompareItem").val();
		var Year = $("#selectYear").val();
		myGrid3.page.pageNo = 1;
		myGrid3.bindGrid({
			ajaxUrl:"/approval/manage/getMonthlyPersonList.do",
			ajaxPars: {
				"EntCode":EntCode,
				"CompareItem":CompareItem,
				"Year":Year
			},
			onLoad:function(){
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid3.fnMakeNavi("myGrid3");
			}
		});
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	
	
	function ChageView(value) {
		SetddlView();
    	//SetYear();
    	searchSTAT(true);
    }
	
	
	
	function searchSTAT(bChangeConfig){
		//검색
		var radioval = $("#DetailSearch input[name=radio]:checked").val();
		if (radioval == "GetDept") {
    		$("#GetDeptgrid").show();
    		$("#GetFormgrid").hide();
    		$("#GetUsergrid").hide();
    		if(bChangeConfig) setGridConfig1();
			searchConfig1();
        } else if (radioval == "GetForm") {
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").show();
    		$("#GetUsergrid").hide();
    		if(bChangeConfig) setGridConfig2();
    		searchConfig2();
        } else {
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").hide();
    		$("#GetUsergrid").show();
    		if(bChangeConfig) setGridConfig3();
    		searchConfig3();
        }
	}
	
	// 엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage' />", "Confirmation Dialog", function(result){
			if(result){
				var radioval = $("#DetailSearch input[name=radio]:checked").val();
				var EntCode = $("#hidden_domain_val").val();
				var CompareItem = $("#selectCompareItem").val();
				var Year = $("#selectYear").val();
				
				var headerName = getHeaderNameForExcel();
				
				var sortKey;
				var sortWay;
				
				if (radioval == "GetDept") {
					sortKey = myGrid1.getSortParam("one").split("=")[1].split(" ")[0];
					sortWay = myGrid1.getSortParam("one").split("=")[1].split(" ")[1];
		        } else if (radioval == "GetForm") {
		        	sortKey = myGrid2.getSortParam("one").split("=")[1].split(" ")[0];
		        	sortWay = myGrid2.getSortParam("one").split("=")[1].split(" ")[1];
		        } else {
		        	sortKey = myGrid3.getSortParam("one").split("=")[1].split(" ")[0];
		        	sortWay = myGrid3.getSortParam("one").split("=")[1].split(" ")[1];
		        }
				
				var sURL = "/approval/manage/monthlyTrendComparisonExcelDownload.do";
				sURL += "?radioval=" + radioval;
				sURL += "&EntCode=" + EntCode;
				sURL += "&CompareItem=" + CompareItem;
				sURL += "&Year=" + Year;
				sURL += "&sortKey=" + sortKey;
				sURL += "&sortWay=" + sortWay;
				sURL += "&headerName=" + encodeURIComponent(encodeURIComponent(headerName));
				
				location.href = sURL;
			}
		});
	}
	
	function getHeaderNameForExcel(){
		var returnStr = "";
		
		var radioval = $("#DetailSearch input[name=radio]:checked").val();
		if (radioval == "GetDept") {
			for(var i=0;i<headerData1.length; i++) {
				returnStr += headerData1[i].label + ";";
			}
        } else if (radioval == "GetForm") {
        	for(var i=0;i<headerData2.length; i++) {
    			returnStr += headerData2[i].label + ";";
    		}
        } else {
        	for(var i=0;i<headerData3.length; i++) {
    			returnStr += headerData3[i].label + ";";
    		}
        }
		
		return returnStr;
	}
</script>