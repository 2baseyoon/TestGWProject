<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<!-- 계열사별 집계정보 -->
	<span class="con_tit"><spring:message code='Cache.CN_104' /></span>
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input type="radio" id="Dept" name="radio" value="GetDept" style="border:0;" onclick="ChageView(this);" checked="checked" /><label for="Dept">&nbsp;<spring:message code="Cache.lbl_apv_DocCNT_total"/></label>&nbsp;&nbsp; 
			<input type="radio" id="Form" name="radio" value="GetForm" style="border:0;" onclick="ChageView(this);" /><label for="Form">&nbsp;<spring:message code="Cache.lbl_apv_ByForm"/> <spring:message code="Cache.lbl_apv_month_total"/></label>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<spring:message code="Cache.lbl_apv_select_period"/>(<spring:message code="Cache.lbl_Standard"/>:<spring:message code="Cache.lbl_apv_standard_enddate"/>)&nbsp;
			<input class="AXInput" id="startDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate">
		   	    ~
			<input class="AXInput" id="endDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate">
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchSTAT();" class="AXButton"/>
			<input type="button" value="엑셀저장" onclick="ExcelDownload();" class="AXButton BtnExcel"/>
		</div>
		<div id="topitembar03" class="topbar_grid" style="display: none">
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
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">
	var headerData1 = null;
	var headerData2 = null;

	var myGrid1 = new coviGrid();
	var myGrid2 = new coviGrid();

	initAffiliatesInform();

	function initAffiliatesInform() {
		setGrid();			// 그리드 세팅	
		SetddlView();
		searchSTAT();
	}

	//그리드 세팅
	function setGrid() {
		// 헤더 설정
		headerData1 =[	            
	                  {key:'DN_Name', label:'<spring:message code="Cache.lbl_CorpName"/>', width:'500', align:'center',sort:"asc"},
	                  {key:'A_Count',  label:'<spring:message code="Cache.lbl_apv_approval_count"/>', width:'250', align:'center'},
	                  {key:'REQCMP_count',  label:'<spring:message code="Cache.lbl_apv_receive_count"/>', width:'250', align:'center'},
	                  {key:'document_leadtime', label:'<spring:message code="Cache.lbl_apv_average_time"/>', width:'200', align:'center'}
		      		];
		
		headerData2 =[	            
	                  {key:'DN_Name', label:'<spring:message code="Cache.lbl_CorpName"/>', width:'200', align:'center',sort:"asc"},
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
		
		setGridConfig1();
		setGridConfig2();
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
	
	// GetDeptgrid 검색
	function searchConfig1(flag){
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		myGrid1.page.pageNo = 1;
		myGrid1.bindGrid({
			ajaxUrl:"/approval/admin/getEntCountList.do",
			ajaxPars: {
				"startDate":startDate,
				"endDate":endDate
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
		var CompareItem = $("#selectCompareItem").val();
		var Year = $("#selectYear").val();
		myGrid2.page.pageNo = 1;
		myGrid2.bindGrid({
			ajaxUrl:"/approval/admin/getEntMonthlyCountList.do",
			ajaxPars: {
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
			{optionValue:"A", optionText:Common.getDic('lbl_apv_approval_count')},
			{optionValue:"B", optionText:Common.getDic('lbl_apv_receive_count')},
		]);
	}
	
	function ChageView(value) {
		$("#GetDeptgrid").hide();
    	$("#GetFormgrid").hide();
    	
    	if(value.value=="GetDept") {
    		$("#topitembar02").show();
    		$("#topitembar03").hide(); 
    	}else if (value.value == "GetForm") {
    		$("#topitembar02").hide();
    		$("#topitembar03").show();
    		SetddlView();
    		SetYear();
        }
    	
    	searchSTAT();
    }
	
	function SetYear() {
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
        } else if (radioval == "GetForm") {
    		searchConfig2();
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").show();
        }
	}
	
	// 엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage' />", "Confirmation Dialog", function(result) {
			if(result){
				var radioval = $("input[type=radio]:checked").val();
				var startDate = $("#startDate").val();
				var endDate = $("#endDate").val();
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
		        }
				
				var sURL = "/approval/admin/affiliatesAggregateInformationExcelDownload.do";
				sURL += "?radioval=" + radioval;
				sURL += "&startDate=" + startDate;
				sURL += "&endDate=" + endDate;
				sURL += "&CompareItem=" + CompareItem;
				sURL += "&Year=" + Year;
				sURL += "&sortKey=" + sortKey;
				sURL += "&sortWay=" + sortWay;
				sURL += "&headerName=" + encodeURIComponent(encodeURIComponent(headerName));
				
				location.href = sURL;
			}
		});
	}
	
	function getHeaderNameForExcel() {
		var returnStr = "";
		
		var radioval = $("input[type=radio]:checked").val();
		if (radioval == "GetDept") {
			for(var i=0;i<headerData1.length; i++){
				returnStr += headerData1[i].label + ";";
			}
        } else if (radioval == "GetForm") {
        	for(var i=0;i<headerData2.length; i++){
    			returnStr += headerData2[i].label + ";";
    		}
        } 
		
		return returnStr;
	}
</script>