<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_ThemeManage"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
<%-- 		<input id="refreshBtn"  type="button"  class="AXButton" value="<spring:message code="Cache.btn_Refresh"/>" onclick="refreshGrid();" name="refresh"/> --%>
			<input id="addBtn" type="button"  class="AXButton BtnAdd" value="<spring:message code="Cache.btn_Add"/>"  onclick="addTheme(false);" name="add"/>
			<input id="deleteBtn" type="button"  class="AXButton BtnDelete" value="<spring:message code="Cache.btn_delete"/>"  onclick="deleteTheme(false);" name="delete"/>
<%-- 		<input id="upBtn"  type="button"  class="AXButton" value="<spring:message code="Cache.btn_UP"/>" onclick="upRow();" name="up"/>&nbsp; --%>
<%-- 		<input id="downBtn"  type="button"  class="AXButton" value="<spring:message code="Cache.btn_Down"/>" onclick="downRow();" name="down"/>&nbsp; --%>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<label>
				<spring:message code="Cache.lbl_Domain"/>&nbsp;
				<select name="" class="AXSelect" id="domainID"></select>
			</label>
		</div>
		<div id="themeGrid"></div>
	</div>
</form>
<script type="text/javascript">
	//# sourceURL=DomainManage.jsp
	var myGrid = new coviGrid();
	var headerData;
	
	//ready
	initContent();
	
	function initContent(){
		
		var l_AssignedDomain = "¶"+Common.getSession("AssignedDomain")
		
		// 그룹사 시스템 관리자라면 전체를 표시하기 위해
		if(l_AssignedDomain.indexOf("¶0¶") > -1){
			coviCtrl.renderDomainAXSelect('domainID', Common.getSession("lang"), 'setGrid', '', '', true);
		} else {
			coviCtrl.renderDomainAXSelect('domainID', Common.getSession("lang"), 'setGrid', '', Common.getSession("DN_ID"), false);
		}	
		
		setGrid();
	};
	
	function setGrid(){
		myGrid.setGridHeader([
				              { key:'chk', label:'chk', width:'30', align:'center', formatter:'checkbox'},
				              { key:'DisplayName',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'80', align:'center'},
				              { key:'ThemeName',  label:'<spring:message code="Cache.lbl_DisplayName"/>', width:'110', align:'center',
					              formatter : function () {
					              	return "<a href='#' onclick='updateTheme(false, \""+ this.item.ThemeID +"\"); return false;'>"+this.item.ThemeName+"</a>";
					          }},
			                  { key:'Theme',  label:'<spring:message code="Cache.lbl_ThemeCode"/>', width:'50', align:'center'},
			                  { key:'ModDate',  label:'<spring:message code="Cache.lbl_RegDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', sort:"desc", 
					              formatter: function(){
			                	  	return CFN_TransLocalTime(this.item.ModDate);
			  				  }},
			                  { key:'IsUse', display:false, hideFilter : 'Y', label:'<spring:message code="Cache.lbl_Use"/>', width:'80', align:'center',
					              formatter : function () {
				                	  	return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.ThemeID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.ThemeID+"\",\""+this.item.ThemeCode+"\");' />";
						  	  }},
			                  { key:'DomainID', label:'', display:false, hideFilter : 'Y'}
							 ]);
		
		myGrid.setGridConfig({
			targetID : "themeGrid",
			height:"auto"
		});
		
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/theme/getList.do",
 			ajaxPars: {
 				"domainID":$("#domainID").val(),
 			},
		});
	}
	
	function search(){		
		myGrid.page.pageNo = 1;
		
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/theme/getList.do",
 			ajaxPars: {
 				"domainID":$("#domainID").val(),
 			},
		});
	}
	
	function refreshGrid(){
		myGrid.reloadList();
	}
	
	function addTheme(pModal){
		parent.Common.open("","setTheme","<spring:message code='Cache.lbl_ThemeLayerPopupTitle_Add'/>","/covicore/theme/goThemePopup.do?mode=add","700px","300x","iframe",pModal,null,null,true);
	}
	
	function updateTheme(pModal, configkey){
		parent.Common.open("","setTheme","<spring:message code='Cache.lbl_ThemeLayerPopupTitle_Modify'/>","/covicore/theme/goThemePopup.do?mode=modify&themeID="+configkey,"700px","300x","iframe",pModal,null,null,true);
	}
	
	// 사용 스위치 버튼에 대한 값 변경
	function updateIsUse(themeID, themeCode){
		$.ajax({
			type:"POST",
			data:{
				"ThemeID" : themeID,
				"ThemeCode" : themeCode,
				"IsUse" :  $("#AXInputSwitch"+themeID).val()
			},
			url:"/covicore/theme/modifyUse.do",
			success:function (data) {
				if(data.status != "SUCCESS"){
					Common.Warning("오류가 발생하였습니다.");
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/modifyUse.do", response, status, error);
			}
		});
	}
	
	//게시판 삭제
	function deleteTheme(){
		var themeIDs = '';
		
		$.each(myGrid.getCheckedList(0), function(i,obj){
			themeIDs += obj.ThemeID + ';'
		});
		
		if(themeIDs == ''){
			 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
	       return;
		}
		
		 Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
	       if (result) {
	          $.ajax({
	          	type:"POST",
	          	url:"/covicore/theme/delete.do",
	          	data:{
	          		"themeIDs": themeIDs
	          	},
	          	success:function(data){
	          		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
	          			Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
	          			search();
	          		}else{
	          			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
	          		}
	          	},
	          	error:function(response, status, error){
	          	     //TODO 추가 오류 처리
	          	     CFN_ErrorAjax("/covicore/theme/delete.do", response, status, error);
	          	}
	          });
	       }
	   });
	}
</script>
