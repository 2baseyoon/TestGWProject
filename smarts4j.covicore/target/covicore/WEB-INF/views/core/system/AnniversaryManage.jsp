<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_261"/></span> <!-- 기념일 관리 -->
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addAnniversary();"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="delAnniversary();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.lbl_n_att_googleAPILink"/>" onclick="getHolidayGoogleData();"/> <!-- google api 연동 -->
		</div>
		<div id="topitembar02" class="topbar_grid">

			<%-- 21.12.29, 도메인 관리자는 도메인 선택 화면을 안보여줍니다(CoreInclude.jsp를 통한 class domain 처리). --%>
			<span class="domain">
				<spring:message code="Cache.lbl_Domain"/>&nbsp; <!-- 도메인  -->
				<select name="" class="AXSelect" id="selectDomain"></select>&nbsp;&nbsp;
			</span>
			
			<spring:message code="Cache.lbl_anniversarytype"/>&nbsp;<!-- 기념일 유형  -->
			<select name="" class="AXSelect" id="selectAnniversaryType"></select>&nbsp;&nbsp;
			
			<spring:message code="Cache.lbl_Start"/>&nbsp; <!-- 년도  -->
			 <input type="text" class="AXInput W60" id="startYear" kind="date" date_selectType="y" onkeypress="return false;">
			 
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="bindGrid();" class="AXButton"/>
		</div>
		<div id=anniversaryGridDiv></div>
	</div>
</form>
<script type="text/javascript">
	//# sourceURL=AnniversaryManage.jsp

	var anniversaryGrid = new coviGrid();
	
	//개별호출 일괄처리
	var langCode = Common.getSession("lang");
	Common.getBaseCodeList(["AnniversaryType"]);
	
	initContent();
	
	function initContent(){ 
		setControls();		// 컨트롤 초기화

		setGrid();			// 그리드 설정 초기화
		bindGrid();			// 그리드 데이터 바인딩
	}
	
	//그리드 설정 초기화
	function setGrid(){
		var anniversaryTypeDic = new Object(); 
		var anniversaryType = coviCmn.codeMap["AnniversaryType"];
		
		$.each(anniversaryType, function(idx, type){
			anniversaryTypeDic[type.Code] = CFN_GetDicInfo(type.MultiCodeName);
		});
		
		
		anniversaryGrid.setGridHeader([
		 		             {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', sort: false},
				             {key:'MultiDisplayName', label:'<spring:message code="Cache.lbl_Domain"/>', width:'50', align:'center', formatter:function(){
				            	 return  CFN_GetDicInfo(this.item.MultiDisplayName);
				             }},
				             {key:'Anniversary',  label:'<spring:message code="Cache.lbl_AnniversaryName"/>', width:'*', align:'center', formatter:function(){
				            	 return "<a style=\"cursor:pointer;\" onclick=\"modiAnniversary(\'" +this.item.CalendarID+ "\')\">" + CFN_GetDicInfo(this.item.Anniversary) + "</a>";
				             }},
				             {key:'SolarDate',  label:'<spring:message code="Cache.lbl_Solar"/>', width:'50', align:'center', sort: "asc"},
				             {key:'LunarDate',  label:'<spring:message code="Cache.lbl_Lunar"/>', width:'50', align:'center'},
				             {key:'AnniversaryType',  label:'<spring:message code="Cache.lbl_anniversarytype"/>', width:'50', align:'center', formatter:function(){
				            	 return anniversaryTypeDic[this.item.AnniversaryType];
				             }}
					      	]);
		
		anniversaryGrid.setGridConfig({
			targetID : "anniversaryGridDiv", 
			height: "auto"
		});
	}
	
	// 그리드 데이터 바인딩
	function bindGrid(){
		var domainID = $("#selectDomain").val();
		var anniversaryType = $("#selectAnniversaryType").val();
		var startYear = $("#startYear").val();
		
		anniversaryGrid.page.pageNo = 1;
		
		anniversaryGrid.bindGrid({
 			ajaxUrl:"/covicore/anniversary/getAnniversaryList.do",
 			ajaxPars: {
 				"domainID":domainID,
 				"anniversaryType":anniversaryType,
 				"startYear":startYear
 			}
 			,objectName: 'anniversaryGrid'
 			,callbackName: 'bindGrid'
		});
	}
	
	// 추가
	function addAnniversary(){
		Common.open("","setAnniversary","<spring:message code='Cache.lbl_AnniversaryAdd'/>","/covicore/anniversary/goAnniversarySetPopup.do?mode=add","600px","250px","iframe",false,null,null,true);
	}
	
	// 수정
	function modiAnniversary(calendarID){
		Common.open("","setAnniversary","<spring:message code='Cache.lbl_AnniversaryModify'/>","/covicore/anniversary/goAnniversarySetPopup.do?mode=modify&calendarID="+calendarID,"600px","210px","iframe",false,null,null,true);
	}
	
	// 삭제
	function delAnniversary(){
		var delObj = anniversaryGrid.getCheckedList(0);
		
		if(delObj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>"); /* 삭제할 항목을 선택하여 주십시요. */
			return;
		}
		
		var delSeq = "";
		for(var i=0; i<delObj.length; i++){
			if(i==0){
				delSeq = delObj[i].CalendarID+'|'+ delObj[i].DN_ID ;
			}else{
				delSeq = delSeq + "," + delObj[i].CalendarID+'|'+ delObj[i].DN_ID ;
			}
		}
		
		$.ajax({
			type:"POST",
			data:{
				"deleteData" : delSeq
			},
			url:"/covicore/anniversary/deleteAnniversaryData.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_138'/>"); /*성공적으로 삭제되었습니다. */
					anniversaryGrid.reloadList();
				}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
	    	     //TODO 추가 오류 처리
	    	     CFN_ErrorAjax("/covicore/anniversary/deleteAnniversaryData.do", response, status, error);
	    	}
		});
	}
	
	// 새로고침
	function refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
		coviInput.setDate();
	}
	
	// 컨트롤 초기화
	function setControls(){
		$("#startYear").val(new Date().getFullYear()) //현재 연도로 지정
		
		var l_AssignedDomain = "¶"+Common.getSession("AssignedDomain")
		// 그룹사 시스템 관리자라면 전체를 표시하기 위해
		if(l_AssignedDomain.indexOf("¶0¶") > -1){
			coviCtrl.renderDomainAXSelect('selectDomain', langCode, 'bindGrid', '', '', true);
		} else {
			coviCtrl.renderDomainAXSelect('selectDomain', langCode, 'bindGrid', '', Common.getSession("DN_ID"), false);
		}
		
		coviCtrl.renderAXSelect('AnniversaryType', 'selectAnniversaryType',  langCode, 'bindGrid', '', 'AnniversaryType');
	}
	
	
	function setFirstPageURL(){
		SaveFirstPageURL("/covicore/systemadmin_dictionarymanage.do");
	}
	
	function getHolidayGoogleData(){
		var url = "/groupware/calendar/eventlist.do";
		var domainId = $("#selectDomain option:selected").val();
		
		if(domainId == "") {
			Common.Warning(Common.getDic("msg_MngSelectCompany"));
			return false;
		} else {
			var msg = String.format(Common.getDic("msg_n_att_googleCalAlert"), $("#selectDomain option:selected").text(), $("#startYear").val());			
			Common.Confirm(msg,"Confirm", function(result) {
				if(result){
					$.ajax({
						type:"GET",
						url:url,
						data: { "domainID" : domainId },
						success:function (data) {
							if(data != null) {
								var items = data.items;		
								var holidayList = new Array();
								
								for(var i=0;i<items.length;i++){
									var holiObj = items[i];
									var DomainID = $("#selectDomain").val();
									var AnniversaryType =  holiObj.description == "공휴일"? "National" : "General";
									var Anniversary = holiObj.summary;
									var SolarDate = holiObj.start.date;
									var SolarYear = SolarDate.substring(0,4);
									var IsRepeat = "N";
									
									if($("#startYear").val() == SolarYear){
										var returnObj = {'DomainID' : DomainID, 'AnniversaryType' : AnniversaryType, 'Anniversary' : Anniversary, 'SolarDate' : SolarDate, 'SolarYear' : SolarYear, 'IsRepeat' : IsRepeat };
										holidayList.push(returnObj);
									}
								}
								
								if(holidayList.length > 0) {
									var params = { "holi":JSON.stringify(holidayList) };
									
									$.ajax({
										type:"POST",
										dataType : "json",
										data: params,
										url:"/covicore/anniversary/setGoogleHoliday.do",
										success:function (data) {
											if(data.status =="SUCCESS"){
												Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
													parent.anniversaryGrid.reloadList();			
									    		});
											}else{
												Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
											}
										},
										error:function(){
											Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
										}
									});
								} else {
									Common.Warning("<spring:message code='Cache.msg_n_att_googleCalAlert2'/>");
								}
							} else {
								Common.Warning("<spring:message code='Cache.msg_n_att_googleCalAlert2'/>");
							}
						},
						error:function(data){
							//TODO 추가 오류 처리
				    	     CFN_ErrorAjax("/covicore/anniversary/setGoogleHoliday.do", response, status, error);
						}
					});
				}
			});
		}
	}
</script>