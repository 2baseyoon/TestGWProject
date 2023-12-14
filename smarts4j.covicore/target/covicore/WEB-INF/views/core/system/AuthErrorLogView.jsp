<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_manage_AuthErrorLog"/></span>
</h3>

<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" value="<spring:message code="Cache.btn_Refresh"/>" onclick="Refresh();" class="AXButton BtnRefresh" />
			<select class="AXSelect" id="selectDomain"></select>
			<select id="searchDateType" class="AXSelect" onchange="setDate();"></select>
			<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
			<spring:message code="Cache.lbl_DepUser"/>&nbsp;<input type="text" id="deptusername" style="width:120px" class="AXInput"  onkeypress="if (event.keyCode==13){ searchLog(); return false;}" />
			<input type="button" value="<spring:message code="Cache.btn_OrgManage"/>" onclick="OrgMapLayerPopup();" class="AXButton"/>		
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchLog();" class="AXButton" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_SaveToExcel"/>" onclick="ExcelSave();" class="AXButton BtnExcel" />
		</div>
		<div id="autherrorgrid"></div>
	</div>
</form>
<script type="text/javascript">
	
	var myGrid;
	var headerData;
	window.onload = initContent();
	
	function initContent(){
		headerData = [
		      		  {key:'ErrorDate',  label:'<spring:message code="Cache.lbl_EventDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', sort:'desc', 
		      			formatter: function(){
		      				return CFN_TransLocalTime(this.item.ErrorDate);
		      			}, dataType:'DateTime'
					  },
		             {key:'CompanyCode',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'70', align:'center'},
		              {key:'PageURL',  label:'<spring:message code="Cache.lbl_PageEN"/>', width:'100', align:'left'},
		              //{key:'IPAddress',  label:'<spring:message code="Cache.lbl_IPAddress"/>', width:'80', align:'center'},
		              {key:'AuthErrorUserName', label:'<spring:message code="Cache.lbl_User_DisplayName"/>',  width:'80', align:'center'},
	                  {key:'DeptName', label:'<spring:message code="Cache.lbl_DeptName"/>',  width:'80', align:'center'},
	                  {key:'AuditClass',  label:'<spring:message code="Cache.lbl_AuditClass"/>', width:'100', align:'center'},
		              {key:'AuditMethod',  label:'<spring:message code="Cache.lbl_AuditMethod"/>', width:'80', align:'center'},
		              {key:'ErrorType',  label:'<spring:message code="Cache.lbl_ErrorType"/>', width:'80', align:'center',
		            	  formatter: function(){
		            		  var ErrorType;
			                  	switch(this.item.ErrorType){
			                  	case "NOAUTH":
			                  		ErrorType = Common.getDic("lbl_NoAuth");
			                  		break;
			                  	case "NOAUDIT":
			                  		ErrorType = Common.getDic("lbl_NoAudit");
			                  		break;
			                  	default:
			                  		ErrorType = this.item.authType;
			                  	}
			                  	return ErrorType; 
		            	  }
		              },  
	                  {key:'ErrorMessage', label:'<spring:message code="Cache.lbl_ErrorMessage"/>',  width:'200', align:'center'}
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
			targetID : "autherrorgrid",
			height: "auto",
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function setDate(){
		//debugger;
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
		
		// 검색기간 2년 이하로 제한
		var dateVali = true;
		//debugger;
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		var text = $("#deptusername").val();

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
			Common.Inform("<spring:message code='Cache.msg_CanSelectTwoYearAgo'/>", "Information Dialog", function(result) {
				$("#startdate").val(XFN_getCurrDate("-", "dash"));
				$("#enddate").val(XFN_getCurrDate("-", "dash"));
				
				strdate = $("#startdate").val();
				enddate = $("#enddate").val();
			});			
			
			return false;
		}
		
		myGrid.page.pageNo = 1;
		
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/log/getautherrorloglist.do",
 			ajaxPars: {
 				"startdate":strdate,
 				"enddate":enddate,
 				"searchtext":text,
 				"companyCode":$("#selectDomain").val(),
 			},
 			onLoad:function(){
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			}
			,objectName: 'myGrid'
			,callbackName: 'searchLog'
		});
	}
	
	function ExcelSave(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var strdate = document.getElementById("startdate").value;
    			var enddate = document.getElementById("enddate").value;
    			var text = document.getElementById("deptusername").value;
    			var domain = $("#selectDomain").val();
    			
    			var headername = getHeaderNameForExcel();
    			var headerType = getHeaderTypeForExcel();
    			var sortKey = myGrid.getSortParam("one").split("=")[1].split(" ")[0];
    			var sortWay = myGrid.getSortParam("one").split("=")[1].split(" ")[1];
    			
    			if(strdate == ""){
    				strdate = $("#enddate").attr("minDate");
    			}
    			if(enddate == ""){
    				enddate = $("#enddate").attr("maxDate");
    			}
    			
    			location.href = "/covicore/autherrorlogexceldownload.do?startdate=" + strdate + "&enddate="+ enddate + "&searchText="+ text +"&companyCode="+domain+"&sortKey="+sortKey+"&sortWay="+sortWay+"&headername="+encodeURI(headername)+"&headerType="+encodeURI(headerType);
       		}
		});
	}
	
	function Refresh(){
		location.reload();
	}
	
	function OrgMapLayerPopup(){
		Common.open("","orgchart_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=D1","1040px", "580px", "iframe", true, null, null,true);
	}
	
	// 조직도 데이터	
	
	function _CallBackMethod2(data){
		var dataObj = $.parseJSON(data);
		if(dataObj.item.length > 0){
			var searchData = CFN_GetDicInfo(dataObj.item[0].DN);
			$("#deptusername").val(searchData);
		}
		
		searchLog();
	}
	
	function setDateTypeSelect(){
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
		coviCtrl.renderCompanyAXSelect('selectDomain', 'ko', true, 'searchLog', '', '');

	}
	
	function getHeaderNameForExcel(){
		var returnStr = "";
		for(var i=0;i<headerData.length; i++){
			returnStr += headerData[i].label + ";";
		}
		
		return returnStr;
	}
	function getHeaderTypeForExcel(){
		var returnStr = "";

	   	for(var i=0;i<headerData.length; i++){
			returnStr += (headerData[i].dataType != undefined ? headerData[i].dataType:"Text") + "|";
		}
		return returnStr;
	}
	
</script>

