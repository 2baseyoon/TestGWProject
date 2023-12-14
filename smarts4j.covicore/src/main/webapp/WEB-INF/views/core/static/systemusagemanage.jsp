<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script type="text/javascript">
	$(document).ready(function (){
		setGrid();
		
		var monthData = new Array();
		for(var i=1; i<=12; i++){
			monthData.push({"name":i, "value":i});
		}
		
		var yearData = new Date();
		
		setSelect("#select_year", [{"name":(yearData.getFullYear()-1), "value":(yearData.getFullYear()-1)}, {"name":yearData.getFullYear(), "value":yearData.getFullYear()}]);
		setSelect("#select_month", monthData);

		searchStatistics();
	});
	
	function setSelect(id, data){
		$(id).bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options:data
        });
	}

	var headerData = [{key:'DN_ID',  label:'<spring:message code="Cache.lbl_Number"/>', width:'30', align:'center'},
	                  {key:'YEAR',  label:'<spring:message code="Cache.lbl_year"/>', width:'30', align:'center'},
	                  {key:'MONTH',  label:'<spring:message code="Cache.lbl_month"/>', width:'20', align:'center'},
	                  {key:'DN_Name', label:'<spring:message code="Cache.lbl_company"/>',  width:'80', align:'left'},
	                  {key:'UserCount', label:'<spring:message code="Cache.lbl_UserCount"/>', width:'50', align:'center'},
	                  {key:'UseDayCount', label:'<spring:message code="Cache.lbl_UseDayCount"/>',  width:'40', align:'center'},
	                  {key:'NoConUserCount', label:'<spring:message code="Cache.lbl_noconusercount"/>', width:'40', align:'center'},
	                  {key:'NewUserCount', label:'<spring:message code="Cache.lbl_newusercount"/>',  width:'40', align:'center'},
	                  {key:'UseRate', label:'<spring:message code="Cache.lbl_userate"/>(%)',  width:'40', align:'center'},
	                  {key:'RegisterName', label:'<spring:message code="Cache.lbl_aggregatorname"/>',  width:'50', align:'center'},
	                  {key:'RegDate', label:'<spring:message code="Cache.lbl_AggregateDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', 
	                	formatter: function(){
	                		return CFN_TransLocalTime(this.item.RegistDate);
	                	}
	                }];
	
	var myGrid = new coviGrid();
	
	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "AXGridTarget",
 			//listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
 			height : "auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			sort : false
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function searchStatistics(){
		var syear = $("#select_year option:selected").val();
		var smonth = $("#select_month option:selected").val();
		
		myGrid.page.pageNo = 1;
		
		myGrid.bindGrid({
 			ajaxUrl:"static/getstaticusagemanagelist.do",
 			ajaxPars: {
 				"selectYear":syear,
 				"selectMonth":smonth
 			},
 			onLoad:function(){
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			}
		});
	}
	
	function ExcelSaveAll(){
		var obj = myGrid.getExcelFormat('html');
	}
	
	function ExcelSaveDetail(){
		/* var obj = myGrid.getExcelFormat('html'); */		
	}
	
</script>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.tte_SystemUsageManage"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar_1" class="topbar_grid">
			<label>
				<select id="select_year" onchange="searchStatistics();" class="AXSelect"></select>
				<select id="select_month" onchange="searchStatistics();"  class="AXSelect"></select>
				<input type="button" value="<spring:message code="Cache.btn_Aggregator"/>" onclick="ExcelSaveAll();" class="AXButton" />
				<input type="button" value="<spring:message code="Cache.btn_UserDetails"/>"  onclick="ExcelSaveDetail();" class="AXButton" />
			</label>
		</div>
		<div>
			<div id="AXGridTarget" style="height: 347px;"></div>
		</div>
	</div>
</form>