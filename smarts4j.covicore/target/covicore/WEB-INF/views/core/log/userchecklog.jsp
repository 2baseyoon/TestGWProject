<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit">본인확인 로그</span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" value="<spring:message code="Cache.btn_Refresh"/>" onclick="Refresh();" class="AXButton BtnRefresh"/>
			<select id="searchDateType" class="AXSelect" onchange="setDate();"></select>
			<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" maxDate="" minDate="" style="width: 85px" class="AXInput" />
			<select id="authType" class="AXSelect" onchange="searchLog()"></select>
			<spring:message code="Cache.lbl_LoginID"/>&nbsp;<input type="text" id="searchWord" style="width:120px" class="AXInput"  onkeypress="if (event.keyCode==13){ searchLog(); return false;}" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchLog();" class="AXButton"/>
		</div>
		<div id="usercheckgrid"></div>
	</div>
</form>
<script type="text/javascript">

	var myGrid;
	var headerData;
	
	//개별호출 일괄처리
	var sessionObj = Common.getSession();
	
	initContent();
	
	function initContent(){
		var codeGroupDic = new Object();
		
		$(Common.getBaseCode("FidoAuthType").CacheData).each(function(idx, obj){
			codeGroupDic[obj.Code] = obj.CodeName;
		});
		
		//검색기간 제한
		 headerData =[{key:'AuthKey', label:'<spring:message code="Cache.lbl_Number"/>', width:'30', align:'center', sort:'desc'}, //순번
		                  {key:'AuthType',  label:'<spring:message code="Cache.lbl_type"/>', width:'70', align:'center', formatter: function(){
		                	  return codeGroupDic[this.item.AuthType];
		                  } },	//유형
		                  {key:'LogonID',  label:'<spring:message code="Cache.lbl_LoginID"/>', width:'70', align:'center'},	//아이디
		                  {key:'AuthStatus', label:'<spring:message code="Cache.lbl_Status"/>', width:'60', align:'center', formatter: function(){
		                	  switch(this.item.AuthStatus){
			                	  case 'Before': 
			                		  return "<spring:message code='Cache.lbl_authStatus_before'/>"; //요청생성
			                		  break;
			                	  case 'Req': 
			                		  return "<spring:message code='Cache.lbl_authStatus_req'/>";  //인증요청
			                		  break;
			                	  case 'Succ': 
			                		  return "<spring:message code='Cache.lbl_authStatus_succ'/>";  //인증성공
			                		  break;
			                	  case 'Check': 
			                		  return "<spring:message code='Cache.lbl_authStatus_check'/>";  //인증검증
			                		  break;
			                	  case 'Fail': 
			                		  return "<spring:message code='Cache.lbl_authStatus_fail'/>";  //인증실패
			                		  break;
		                	  }
		                  }},	//상태
		                  {key:'AuthEQ_Info',  label:'<spring:message code="Cache.lbl_authDevice"/>', width:'80', align:'center'}, 	//인증기기
		               	  {key:'EQ_AuthKind', label:'<spring:message code="Cache.lbl_authKind"/>', width:'70', align:'center'},	//인증방식
		                  {key:'ReqTime', label:'<spring:message code="Cache.lbl_reqTime"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'50', align:'center', 
	                 		formatter: function(){
	                 			return CFN_TransLocalTime(this.item.ReqTime, "HH:mm:ss");
	                 		}
	                 	  }, 	//요청시간
		                  {key:'SuccessTime', label:'<spring:message code="Cache.lbl_authTime"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'50', align:'center', 
	                 		formatter: function(){
	                 			return CFN_TransLocalTime(this.item.SuccessTime, "HH:mm:ss");
	                 		}
		                  },		//인증시간
		                  {key:'CheckTime', label:'<spring:message code="Cache.lbl_confirmTime"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'50', align:'center', 
	                 		formatter: function(){
	                 			return CFN_TransLocalTime(this.item.CheckTime, "HH:mm:ss");
	                 		}
			              }, 		// 확인시간
		                  {key:'ReqDay', label:'<spring:message code="Cache.lbl_RequestDay"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'65', align:'center', 
	                 		formatter: function(){
	                 			return CFN_TransLocalTime(this.item.ReqDay, "yyyy-MM-dd");
	                 		}
				          }]; //요청일
		
		myGrid = new coviGrid();
		
		setGrid();
		setControls();
		setTimeout(function(){setDate();}, 10);
	};

	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "usercheckgrid",
			height:"auto"
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
		// 검색기간 2년 이하로 제한
		var dateVali = true;
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		var authType = $("#authType").val();
		var searchWord = $("#searchWord").val();
		
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
			Common.Warning("<spring:message code='Cache.msg_CanSelectTwoYearAgo'/>");
			$("#startdate").val(XFN_getCurrDate("-", "dash"));
			$("#enddate").val(XFN_getCurrDate("-", "dash"));
			
			strdate = $("#startdate").val();
			enddate = $("#enddate").val();
		}
		
		myGrid.page.pageNo = 1;
		
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/log/usercheckloglist.do",
 			ajaxPars: {
 				"startdate":strdate,
 				"enddate":enddate,
 				"searchType":"LogonID",
 				"searchWord":searchWord,
 				"authType":authType
 				
 			}
		});
	}
	

	function setControls(){
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
		
		
		coviCtrl.renderAXSelect("FidoAuthType","authType",sessionObj["lang"],"searchLog", "", "");
		
	}
	
	function Refresh(){
		location.reload();
	}
	
	
</script>
