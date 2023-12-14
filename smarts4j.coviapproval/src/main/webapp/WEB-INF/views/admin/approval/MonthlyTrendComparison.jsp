<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<!-- 월별 비교 -->
	<span class="con_tit"><spring:message code='Cache.CN_103' /></span>
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input type="radio" id="Dept" name="radio" value="GetDept" style="border:0;" onclick="ChageView(this);" checked="checked" /><label for="Dept">&nbsp;<spring:message code="Cache.lbl_apv_ByDept"/></label>&nbsp;&nbsp;
			<input type="radio" id="Form" name="radio" value="GetForm" style="border:0;" onclick="ChageView(this);" /><label for="Form">&nbsp;<spring:message code="Cache.lbl_apv_ByForm"/></label>&nbsp;&nbsp;
			<input type="radio" id="Person" name="radio" value="GetPerson" style="border:0;" onclick="ChageView(this);" /><label for="Person">&nbsp;<spring:message code="Cache.lbl_apv_ByPerson"/></label>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<spring:message code="Cache.lbl_secAtt1"/>
			<select  name="selectDdlCompany" class="AXSelect" id="selectDdlCompany"></select>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<spring:message code="Cache.lbl_apv_compareItem"/>
			<select  name="selectCompareItem" class="AXSelect" id="selectCompareItem"></select>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<spring:message code="Cache.lbl_Start"/>&nbsp;<spring:message code="Cache.lbl_apv_year"/>/<spring:message code="Cache.lbl_apv_month"/>&nbsp;
			<select  name="selectYear" class="AXSelect" id="selectYear"></select>
			<spring:message code="Cache.lbl_apv_year"/>&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="button" value="<spring:message code="Cache.lbl_apv_SaveToExcel"/>" onclick="ExcelDownload();" class="AXButton BtnExcel"/>
		</div>	
		<div id="GetDeptgrid" ></div>
		<div id="GetFormgrid" ></div>
		<div id="GetUsergrid" ></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">
	var headerData1 = null;
	var headerData2 = null;
	var headerData3 = null;

	var myGrid1 = new coviGrid();
	var myGrid2 = new coviGrid();
	var myGrid3 = new coviGrid();

	initMonthlyTrendCpn();

	function initMonthlyTrendCpn(){
		setSelect();
		setGrid();			// 그리드 세팅
		SetddlView();
		SetYear();
		searchSTAT();
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
				pageSize:10
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
				pageSize:10
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
				pageSize:10
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		myGrid3.setGridConfig(configObj);
	}
	
	// GetDeptgrid 검색
	function searchConfig1(flag){		
		var EntCode = $("#selectDdlCompany").val();
		var CompareItem = $("#selectCompareItem").val();
		var Year = $("#selectYear").val();
		myGrid1.page.pageNo = 1;
		myGrid1.bindGrid({
			ajaxUrl:"/approval/admin/getMonthlyDeptList.do",
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
		var EntCode = $("#selectDdlCompany").val();
		var CompareItem = $("#selectCompareItem").val();
		var Year = $("#selectYear").val();
		myGrid2.page.pageNo = 1;
		myGrid2.bindGrid({
			ajaxUrl:"/approval/admin/getMonthlyFormList.do",
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
		var EntCode = $("#selectDdlCompany").val();
		var CompareItem = $("#selectCompareItem").val();
		var Year = $("#selectYear").val();
		myGrid3.page.pageNo = 1;
		myGrid3.bindGrid({
			ajaxUrl:"/approval/admin/getMonthlyPersonList.do",
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
	
	// Select box 바인드
	function setSelect(){
		$("#selectDdlCompany").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			}
			,ajaxUrl: "/approval/common/getEntInfoListAssignData.do"
			,ajaxAsync:false
			,onchange: function() {
				searchSTAT();
			}
		});
	}
	
	// select setting
	function SetddlView(){
		$("#selectCompareItem").bindSelect({
            reserveKeys: {optionValue: "value", optionText: "name"},
            options:[],
            onchange: function(){
				searchSTAT();
			}
        });
		$("#selectCompareItem").bindSelectUpdateOptions([
   			{optionValue:"A", optionText:"<spring:message code='Cache.lbl_apv_draftDoc_cnt'/>"},
   			{optionValue:"B", optionText:"<spring:message code='Cache.lbl_apv_receiptDoc_cnt'/>"},
   			{optionValue:"C", optionText:"<spring:message code='Cache.lbl_ProcessingTime'/>(<spring:message code='Cache.lbl_Minutes'/>)"}
   		]);
	}
	
	function ChageView(value) {
		//$("#selectDdlCompany").bindSelectSetValue("ORGROOT");
		
    	if(value.value=="GetDept"){
    		$("#selectCompareItem").bindSelectUpdateOptions([
       			{optionValue:"A", optionText:"<spring:message code='Cache.lbl_apv_draftDoc_cnt'/>"},
    			{optionValue:"B", optionText:"<spring:message code='Cache.lbl_apv_receiptDoc_cnt'/>"},
    			{optionValue:"C", optionText:"<spring:message code='Cache.lbl_ProcessingTime'/>(<spring:message code='Cache.lbl_Minutes'/>)"}
       		]);
    	}else if (value.value == "GetForm") {
    		$("#selectCompareItem").bindSelectUpdateOptions([
      			{optionValue:"A", optionText:"<spring:message code='Cache.lbl_apv_completed_cnt'/>"},
      			{optionValue:"B", optionText:"<spring:message code='Cache.lbl_ProcessingTime'/>(<spring:message code='Cache.lbl_Minutes'/>)"}
      		]);
        } else {
        	$("#selectCompareItem").bindSelectUpdateOptions([
       			{optionValue:"A", optionText:"<spring:message code='Cache.lbl_apv_draft_cnt'/>(<spring:message code='Cache.lbl_apv_accepted'/>)"},
       			{optionValue:"B", optionText:"<spring:message code='Cache.lbl_apv_complete_counts'/>"},
       			{optionValue:"C", optionText:"<spring:message code='Cache.WM_2'/>(<spring:message code='Cache.lbl_Minutes'/>)"}
       		]);
        }
    	SetYear();
    	searchSTAT();
    }
	
	function SetYear(){
		var Today = new Date();

		var Year = Today.getFullYear();
		
		$("#selectYear").bindSelect({
            reserveKeys: {optionValue: "value", optionText: "name"},
            options:[],
            onchange: function(){
				searchSTAT();
			}
        });
		
		for (var i = 0; i < 10; i++)
        {
			$("#selectYear").bindSelectAddOptions([
             	{optionValue:Year, optionText:Year}
             ]);
			Year--;
        }
		$("#selectYear").bindSelectSetValue(Today.getFullYear());
	}
	
	function searchSTAT(){
		//검색
		var radioval = $("input[type=radio]:checked").val();
		if (radioval == "GetDept") {
			searchConfig1();
    		$("#GetDeptgrid").show();
    		$("#GetFormgrid").hide();
    		$("#GetUsergrid").hide();
        } else if (radioval == "GetForm") {
    		searchConfig2();
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").show();
    		$("#GetUsergrid").hide();
        } else {
    		searchConfig3();
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").hide();
    		$("#GetUsergrid").show();
        }
	}
	
	// 엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage' />", "Confirmation Dialog", function(result){
			if(result){
				var radioval = $("input[type=radio]:checked").val();
				var EntCode = $("#selectDdlCompany").val();
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
				
				var sURL = "/approval/admin/monthlyTrendComparisonExcelDownload.do";
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
		
		var radioval = $("input[type=radio]:checked").val();
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