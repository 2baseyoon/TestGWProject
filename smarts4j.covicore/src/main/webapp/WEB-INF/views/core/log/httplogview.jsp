<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit">HTTP 프로토콜 로그</span>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" value="<spring:message code="Cache.btn_Refresh"/>" onclick="Refresh();" class="AXButton BtnRefresh"/>
			<select id="searchLogType" class="AXSelect" onchange="searchLog();"></select>
			<select id="searchDateType" class="AXSelect" onchange="setDate();"></select>
			<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchLog();" class="AXButton"/>
		</div>
		<div id="errorgrid"></div>
	</div>
</form>

<script type="text/javascript">
	var myGrid;
	var headerData;
	
	window.onload = initContent();
	
	function initContent(){
		headerData = [
		      		  {key:'LogID',  label:'', display:false, hideFilter : 'Y', sort:'desc'},
	                  {key:'LogType',  label:'<spring:message code="Cache.lbl_CommunicationType"/>', width:'30', align:'center'},
	                  {key:'Method',  label:'<spring:message code="Cache.lbl_Way"/>', width:'20', align:'center'},
	                  {key:'ConnectURL', label:'<spring:message code="Cache.lbl_Address"/>', width:'120', align:'center', sort:false},
	                  {key:'ResultState', label:'<spring:message code="Cache.lbl_ServerCode"/>', width:'30', align:'center'},
	                  {key:'ResultType', label:'<spring:message code="Cache.lbl_StatusCode"/>',  width:'40', align:'center'},
	                  {key:'ResponseMsg', label:'<spring:message code="Cache.lbl_ReturnMessage"/>',   width:'100', align:'center', sort:false,formatter:function () {
	      		  			var html = this.item.ResponseMsg;
      		        		return XFN_ChangeInputValue(html);
      		        	}}, 
    		          {key:'ResponseDate', label:'<spring:message code="Cache.lbl_date"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center', formatter: function(){
    		        	  	var returnDate = new Date(CFN_TransLocalTime(this.item.ResponseDate));
	  						return returnDate.format("yyyy-MM-dd HH:mm:ss");
	  				  }},
 	                  ];
	
		myGrid = new coviGrid();
		
		setGrid();
		setDateTypeSelect();
		setTimeout(function(){setDate();}, 10);
	};
	
	
	
	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "errorgrid",
 			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height: "auto", //"490px",
			body : {
			}
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function setDate(){
		var date_str = $("#searchDateType option:selected").val();
		
		var thisyear = new Date();
		var startdate = "";
		var enddate = "";
		
		if(date_str == "Today"){
			startdate = XFN_getCurrDate("-", "dash");
		} else if(date_str == "Yesterday"){
			startdate = XFN_addMinusDateByCurrDate(-1, "-", "dash");
		} else if(date_str == "BeforeYesterday"){
			startdate = XFN_addMinusDateByCurrDate(-2, "-", "dash");
		} else if(date_str == "AWeek"){
			startdate = XFN_addMinusDateByCurrDate(-6, "-", "dash");
		} else if(date_str == "AMonth"){
			startdate = XFN_addMinusDateByCurrDate(-30, "-", "dash");
		} else if(date_str == "TwoMonth") {
			startdate = XFN_addMinusDateByCurrDate(-61, "-", "dash");
		} else if(date_str == "ThisYear"){
			thisyear.setMonth(0);	
			thisyear.setDate(1);
			startdate = thisyear.getFullYear() + "-" + (thisyear.getMonth()+1 < 10 ? "0"+(thisyear.getMonth()+1) : thisyear.getMonth()+1) + "-" +(thisyear.getDate() < 10 ? "0"+thisyear.getDate() : thisyear.getDate());					// XFN_TransDateLocalFormat(< % = _strThisYear % > + ".01.01");
			enddate = thisyear.getFullYear() + "-12-31"; 
		}
		
		if(enddate == ""){
			enddate = XFN_getCurrDate("-", "dash");
		}
		
		document.getElementById("startdate").value = startdate;
		document.getElementById("enddate").value = enddate;
		
		searchLog();
	}
	
	function searchLog(){
		//var minDate = $("#enddate").attr("minDate");

		// 검색기간 2년 이하로 제한
		var dateVali = true;
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
	

		if((enddate.split("-")[0] - strdate.split("-")[0]) > 2){
			dateVali = false;
		}else if((enddate.split("-")[0] - strdate.split("-")[0]) == 2){
			if(enddate.split("-")[1] > strdate.split("-")[1]){
				dateVali = false;
			}else if(enddate.split("-")[1] == strdate.split("-")[1] && enddate.split("-")[2] > strdate.split("-")[2]){
				dateVali = false;
			}
		}
		
		if(!dateVali){
			$("#startdate").val(XFN_getCurrDate("-", "dash"));
			$("#enddate").val(XFN_getCurrDate("-", "dash"));
			
			strdate = $("#startdate").val();
			enddate = $("#enddate").val();
		}
		
		myGrid.page.pageNo = 1;
		
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/log/gethttploglist.do",
 			ajaxPars: {
 				"startdate":strdate,
 				"enddate":enddate,
 				"logType":$("#searchLogType").val()
 			},
 			onLoad:function(){
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			},
 			objectName: 'myGrid',
 			callbackName: 'searchLog'
		});
		
	}
	
	function Refresh(){
		location.reload();
	}
	
	
	function setDateTypeSelect(){
		$("#searchLogType").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options : [{"name":"HTTPS", "value":"HTTPS"},
                       {"name":"CLIENT", "value":"CLIENT"},
                       {"name":"URL", "value":"URL"}]
        });
		
		$("#searchDateType").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options : [{"name":"<spring:message code='Cache.btn_Today'/>", "value":"Today"},
                       {"name":"<spring:message code='Cache.btn_Yesterday'/>", "value":"Yesterday"},
                       {"name":"<spring:message code='Cache.btn_BeforeYesterday'/>", "value":"BeforeYesterday"},
                       {"name":"<spring:message code='Cache.btn_AWeek'/>", "value":"AWeek"},
                       {"name":"<spring:message code='Cache.btn_AMonth'/>", "value":"AMonth"},
                       {"name":"<spring:message code='Cache.btn_TwoMonth'/>", "value":"TwoMonth"},
                       {"name":"<spring:message code='Cache.btn_AYear'/>", "value":"ThisYear"}]
        });
		
	}
	
	
</script>
