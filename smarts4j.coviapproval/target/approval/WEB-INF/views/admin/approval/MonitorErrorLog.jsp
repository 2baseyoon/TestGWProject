<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">엔진 오류 로그</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>	
			&nbsp;&nbsp;
			<spring:message code='Cache.lbl_UseAuthority'/> :&nbsp;				
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>
			&nbsp;
			<spring:message code="Cache.lbl_apv_error_date"/> :&nbsp;
			<input type="text" kind="date" id="txtSDate" data-axbind="date" date_valign="middle" date_align="left" style="width: 85px" class="AXInput" />
			&nbsp;
			<spring:message code="Cache.lbl_apv_error_message"/> :&nbsp;
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>			
		</div>	
		<div id="CoviGridView"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">

	var myGrid = new coviGrid();
	setGrid();			// 그리드 세팅
	setSelect();		// Select Box 세팅 (회사)
	searchConfig();
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
                          {key:'Icon', label:' ', width:'30', align:'center', sort:false,
                        	  formatter:function () {
							   		return "<a onclick='ViewProcessListPop(\""+this.item.FormInstID+"\", \""+this.item.ProcessInsID+"\", "+"false"+", \"" + "" + "\"); return false;'><img src=\"/approval/resources/images/Approval/ico_approval.gif\" class=\"ico_btn\" /></a>";
							   }},
		                  {key:'ErrorTime', label:'<spring:message code="Cache.lbl_apv_error_time"/>', width:'100', align:'center', sort:"desc"
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.ErrorTime, "yyyy-MM-dd HH:mm:ss")} },	                	                  
		                  {key:'ServerIP',  label:'<spring:message code="Cache.lbl_apv_server_id"/>', width:'70', align:'center'},
		                  {key:'ProcessInsID', label:'ProcessID', width:'50', align:'center'},
		                  {key:'ErrorMessage',  label:'<spring:message code="Cache.lbl_apv_error_message"/>', width:'500', align:'center', sort:false}                  ,
		                  {key:'Delete',  label:'<spring:message code="Cache.lbl_apv_delete"/>', width:'70', align:'center', sort:false,
                        	  formatter:function () {
							   		return "<input class=\"smButton\" type=\"button\" value=\"<spring:message code='Cache.lbl_apv_delete'/>\" onclick=\"deleteErrorLog(" + this.item.ErrorID + "); return false;\">";
							   }}
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
		
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "CoviGridView",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			body:{
            	onclick:function(){
            		if(this.c == "4") { // ErrorMessage 선택 시
		           		// 길이가 길면 닫기 버튼 보이지 않아 임의로 2500자로 제한
		           		Common.Error("ErrorStackTrace : " + this.item.ErrorStackTrace.substr(0, 2500));
            		}
            		else if(this.c == "0"){ // ProcessInsID
            			// 양식 모니터링 툴 띄우기
            			CFN_OpenWindow("/approval/admin/monitoring.do?FormInstID="+this.item.FormInstID+"&ProcessID="+this.item.ProcessInsID, "", 1360, (window.screen.height - 100), "both");
            		}
            	}
            }
		};
		
		myGrid.setGridConfig(configObj);
	}
	

	
	// baseconfig 검색
	function searchConfig(flag){		
			
		var txtSDate = $("#txtSDate").val();	
		var search = $("#search").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getMonitorErrorLog.do",
				ajaxPars: {
					"txtSDate":txtSDate,
					"search":search,
					"EntCode":$("#selectUseAuthority").val()
				},
				onLoad:function(){
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
				}
		});
	}	
	// Select box 바인드 (회사)
	function setSelect(){
		$("#selectUseAuthority").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListData.do",			
			ajaxAsync:false,
			onchange: function(){
				searchConfig();
			}
		});
		
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	
	function deleteErrorLog(errorID) {
		Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
            if (!result) return; // 삭제하시겠습니까??
		
			$.ajax({
				url:"/approval/admin/deleteErrorLog.do",
				type:"post",
				data: {
					"errorID": errorID
				},
				async:false,
				success:function (data) {
					if(data.status == 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){ //성공적으로 처리 되었습니다.
							location.reload();
						});
	    			} else {
	    				Common.Error(data.message);
	    			}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("deleteErrorLog.do", response, status, error);
				}
			});
		});
	}
	
</script>