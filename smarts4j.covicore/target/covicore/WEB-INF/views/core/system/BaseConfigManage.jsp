<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>

<style>
#divDate { display:inline-block; vertical-align:middle; margin-left: 5px; }
#divDate .dateTip { position:relative; display:inline-block; margin-left:10px; padding-left:20px; color:#4abde1; font-size:13px; vertical-align:middle; }
#divDate .dateTip:before { position:absolute; left:0; top:50%; margin-top:-8px; background:url("<%=cssPath%>/AttendanceManagement/resources/images/ic_tip.png") no-repeat center; content:""; width:16px; height:16px; }
</style>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.tte_BaseConfigManage"/></span>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(false);"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteConfig();"/>
			<input type="button" class="AXButton BtnExcel"  value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="ExcelDownload();"/>
			<input type="button" class="AXButton BtnExcel"  value="<spring:message code="Cache.btn_ExcelUpload"/>" onclick="ExcelUpload();"/>
			<input type="button" class="AXButton" value="<spring:message code="Cache.btn_CacheApply"/>" onclick="applyCache()"/>
			<div id='divDate' style="float: right;">
				<span class="dateTip">
					<spring:message code="Cache.msg_configTypeManage"/>
				</span>
			</div>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<div>
				<span class=domain>
					<spring:message code="Cache.lbl_Domain"/>&nbsp;
					<select name="" class="AXSelect" id="selectDomain"></select>
				</span>
				
				<spring:message code="Cache.lbl_BizSection"/>&nbsp;
				<select name="" class="AXSelect" id="selectBizSection"></select>
				
				<spring:message code="Cache.lbl_ConfigType"/>&nbsp;		<!-- 설정타입 -->
				<select name="" class="AXSelect" id="configtype"></select>
				
				<spring:message code="Cache.lbl_selUse"/>&nbsp;		<!-- 사용유무 -->
				<select name="" class="AXSelect" id="selectUse"></select>
			</div>
			<div>
				<spring:message code="Cache.lblSearchScope"/>&nbsp;<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
				<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />&nbsp;
				
				<spring:message code="Cache.lbl_SearchCondition"/>&nbsp;
				<select name="" class="AXSelect" id="selectSearch"></select>
				<input type="text" id="searchInput"  class="AXInput" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}"/>
				
				<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig();" class="AXButton"/>
			</div>
		</div>
		<div id="baseconfiggrid"></div>
	</div>
</form>
<script type="text/javascript">
	//# sourceURL=BaseConfigManage.jsp
	
	var baseConfigGrid;
	var headerData;
	
	initContent();
	
	function initContent(){ 

		baseConfigGrid = new coviGrid();
		headerData =[
		             {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		             /* {key:'ConfigID', label:'<spring:message code="Cache.lbl_Order"/>', width:'50', align:'center'}, */
		             {key:'DisplayName',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'70', align:'center'},
		             {key:'BizSectionName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'70', align:'center'},
		             {key:'SettingKey', label:'<spring:message code="Cache.lbl_SettingKey"/>', width:'100', align:'center',
		            	 formatter:function () {
		            		 	return "<a href='#' onclick='updateConfig(false, \""+ this.item.ConfigID +"\"); return false;'>"+this.item.SettingKey+"</a>";
		            		 }},
            		 {key:'SettingValue',  label:'<spring:message code="Cache.lbl_SettingValue"/>', width:'90', align:'left'},
            		 {key:'ConfigType',  label:'<spring:message code="Cache.lbl_ConfigType"/>', display:false},
            		 {key:'ConfigName',  label:'<spring:message code="Cache.lbl_ConfigName"/>', width:'90', align:'left'},
		             {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'100', align:'left'},
				     {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>',  width:'50', align:'center'},
		             {key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>',   width:'50', align:'center',
		              	  formatter:function () {
			            		return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.ConfigID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.ConfigID+"\");' />";
			      			}},
				     {key:'IsCheck', label:'<spring:message code="Cache.lbl_Confirm"/>',  width:'50', align:'center'},
		             {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', sort:"desc", 
	      				formatter: function(){
	      					return CFN_TransLocalTime(this.item.ModifyDate);
      					}, dataType:'DateTime'
     				 }
			      	];
		setGrid();			// 그리드 세팅
		setSelect();		// Select Box 세팅
		searchConfig();
	};
	//그리드 세팅
	function setGrid(){
		baseConfigGrid.setGridHeader(headerData);
		baseConfigGrid.setGridConfig({
			targetID : "baseconfiggrid",
			height:"auto"
		});
	}
	
	// baseconfig 검색
	function searchConfig(){
		var bizSection = document.getElementById("selectBizSection").value=="BizSection"?"":  document.getElementById("selectBizSection").value;
		var domain = document.getElementById("selectDomain").value;
		var configtype = document.getElementById("configtype").value=="ConfigType" ? "":  document.getElementById("configtype").value;
		var isuse = document.getElementById("selectUse").value=="IsUse" ? "":  document.getElementById("selectUse").value;
		var search = document.getElementById("selectSearch").value;
		var text = document.getElementById("searchInput").value;
		var strdate = document.getElementById("startdate").value;
		var enddate = document.getElementById("enddate").value;
		
		baseConfigGrid.page.pageNo = 1;
		
		baseConfigGrid.bindGrid({
 			ajaxUrl:"/covicore/baseconfig/getList.do",
 			ajaxPars: {
 				"domain":domain,
 				"bizsection":bizSection,
 				"configtype":configtype,
 				"isuse":isuse,
 				"selectsearch":search,
 				"searchtext":text,
 				"startdate":strdate,
 				"enddate":enddate
 			},
 			objectName: 'baseConfigGrid',
 			callbackName: 'searchConfig'
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){
		parent.Common.open("","addbaseconfiglayerpopup","<spring:message code='Cache.lbl_ConfigCreation'/>","/covicore/baseconfig/goBaseConfigPopup.do?mode=add&key=","600px","310px","iframe",null,null,null,true)
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configID){
		parent.Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_ConfigModify'/>","/covicore/baseconfig/goBaseConfigPopup.do?mode=modify&configID="+configID,"600px","310px","iframe",pModal,null,null,true);
	}
	
	// 삭제
	function deleteConfig(){
		var deleteobj = baseConfigGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_CheckDeleteObject'/>");
			return;
		}else{
			Common.Confirm(Common.getDic("msg_Common_08"), "Confirmation Dialog", function(result){
				if(result){								
					var deleteSeq = "";
					for(var i=0; i<deleteobj.length; i++){
						if(i==0){
							deleteSeq = deleteobj[i].ConfigID;
						}else{
							deleteSeq = deleteSeq + "," + deleteobj[i].ConfigID;
						}
					}
					$.ajax({
						type:"POST",
						data:{
							"DeleteData" : deleteSeq
						},
						url:"/covicore/baseconfig/remove.do",
						success:function (data) {
							if(data.result == "ok")
								Common.Inform("<spring:message code='Cache.msg_DeleteResult'/>");
							baseConfigGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/baseconfig/remove.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	// 엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var domain = document.getElementById("selectDomain").value;
    			var bizSection = document.getElementById("selectBizSection").value;
    			var configtype = document.getElementById("configtype").value;
    			var isuse = document.getElementById("selectUse").value;
    			var search = document.getElementById("selectSearch").value;
    			var text = document.getElementById("searchInput").value;
    			var strdate = document.getElementById("startdate").value;
    			var enddate = document.getElementById("enddate").value;
    			
    			var headername = getHeaderNameForExcel();
    			var headerType = getHeaderTypeForExcel();
    			var sortKey = baseConfigGrid.getSortParam("one").split("=")[1].split(" ")[0];
    			var sortWay = baseConfigGrid.getSortParam("one").split("=")[1].split(" ")[1];
    			
    			location.href = "/covicore/baseconfig/downloadExcel.do?domain="+domain+"&bizsection="+bizSection+"&selectsearch="+search+"&startdate="+strdate+"&enddate="+enddate
    					+"&configtype="+configtype+"&isuse="+isuse+"&searchtext="+text+"&sortKey="+sortKey+"&sortWay="+sortWay+"&headername="+encodeURI(headername)+"&headerType="+encodeURI(headerType);
       		}
		});
	}
	
	//엑셀 업로드
	function ExcelUpload(){
		parent.Common.open("","excelupload","<spring:message code='Cache.lbl_ExcelUpload'/>","/covicore/baseconfig/uploadExcelPopup.do","400px","250px","iframe",false,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		$("#selectDomain").bindSelectSetValue('');	
		$("#selectBizSection").bindSelectSetValue('BizSection');
		$("#configtype").bindSelectSetValue('ConfigType');	
		$("#selectUse").bindSelectSetValue('IsUse');
		$("#selectSearch").bindSelectSetValue('');	
		$("#searchInput").val('');
		$("#startdate").val('');
		$("#enddate").val('');
		
		searchConfig();
	}
	
	// 사용 스위치 버튼에 대한 값 변경
	function updateIsUse(seqValue){
		var isUseValue = $("#AXInputSwitch"+seqValue).val();
		$.ajax({
			type:"POST",
			data:{
				"Seq" : seqValue,
				"IsUse" : isUseValue,
				"ModID" : ""
			},
			url:"/covicore/baseconfig/modifyUse.do",
			success:function (data) {
				if(data.status != "SUCCESS"){
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/baseconfig/modifyUse.do", response, status, error);
			}
		});
	}
	
	// Select box 바인드
	function setSelect(){
		var l_lang = Common.getSession("lang");
		var l_AssignedDomain = "¶"+Common.getSession("AssignedDomain")
		
		// 그룹사 시스템 관리자라면 전체를 표시하기 위해
		if(l_AssignedDomain.indexOf("¶0¶") > -1){
			coviCtrl.renderDomainAXSelect('selectDomain', l_lang, 'searchConfig', '', "", true);
		} else {
			coviCtrl.renderDomainAXSelect('selectDomain', l_lang, 'searchConfig', '', Common.getSession("DN_ID"), false);
		}		
		coviCtrl.renderAXSelect('BizSection', 'selectBizSection', l_lang, 'searchConfig', '');
		coviCtrl.renderAXSelect('ConfigType', 'configtype', l_lang, 'searchConfig', '');
		coviCtrl.renderAXSelect('IsUse', 'selectUse', l_lang, 'searchConfig', '', 'Y');
		coviCtrl.renderAXSelect('SelectType', 'selectSearch', l_lang, '', '');
	}
	
	function getHeaderNameForExcel(){
		var returnStr = "";
		for(var i=1;i<headerData.length; i++){
			returnStr += headerData[i].label + ";";
		}
		
		return returnStr;
	}
	function getHeaderTypeForExcel(){
		var returnStr = "";

	   	for(var i=1;i<headerData.length; i++){
			returnStr += (headerData[i].dataType != undefined ? headerData[i].dataType:"Text") + "|";
		}
		return returnStr;
	}
	
	//캐쉬적용
	function applyCache(){
		coviCmn.reloadCache("BASECONFIG", $("#selectDomain").val());
	}
	
</script>