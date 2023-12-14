<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.lbl_DictionaryManage'/></span>
	<a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code='Cache.lbl_SettingFirstPage'/></p></span>
	</a>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" value="<spring:message code='Cache.lbl_Refresh'/>" onclick="Refresh();" class="AXButton BtnRefresh" />
			<input type="button" value="<spring:message code='Cache.btn_Add'/>" onclick="addDictionary(false);" class="AXButton BtnAdd" />
			<input type="button" value="<spring:message code='Cache.btn_delete'/>" onclick="deleteDictionary();" class="AXButton BtnDelete" />
			<input type="button" value="<spring:message code='Cache.btn_ExcelDownload'/>" onclick="ExcelDownload(); return false;" class="AXButton BtnExcel" />
			<input type="button" class="AXButton" value="<spring:message code="Cache.btn_CacheApply"/>" onclick="applyCache();"/>
<%-- 	<input type="button" value="<spring:message code='Cache.btn_ExcelUpload'/>" onclick="ExcelUpload(); return false;" class="AXButton" /> --%>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<span class=domain1>
				<spring:message code="Cache.lbl_Domain"/>&nbsp;
				<select name="" class="AXSelect" id="selectDomain"></select>
			</span>
			<spring:message code='Cache.lbl_Section'/>&nbsp;
			<select id="selectArea" class="AXSelect">
			</select>
			<spring:message code='Cache.lbl_SearchCondition'/>&nbsp;
			<select id="selectSearch" class="AXSelect">
			</select>
			<input type="text" id="searchtext" class="AXInput"  onkeypress="if (event.keyCode==13){ searchDictionary(); return false;}"/>&nbsp;
			<spring:message code='Cache.lblSearchScope'/>&nbsp;<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput"  />
			<input type="button" value="<spring:message code='Cache.btn_search'/>" onclick="searchDictionary();" class="AXButton" />
		</div>
		<div id="dictionarygrid"></div>
	</div>
</form>


<script type="text/javascript">
	//# sourceURL=DictionaryManage.jsp
	var myGrid;
	var headerData;
	var langCode = Common.getSession("lang");
	
	//ready
	initContent();
	
	function initContent(){ 
		myGrid = new coviGrid();
		
		headerData =[
			             {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', sort:false },
			             {key:'DicSection',  label:'<spring:message code="Cache.lbl_Section"/>', display:false, align:'center'},
			             {key:'DisplayName',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'70', align:'center', sort:false },
			             {key:'DicCode', label:'<spring:message code="Cache.lbl_DicID"/>', width:'100', align:'center',
			            	 formatter : function () {
			            		return "<a href='#' onclick='updateDictionary(false, \""+ this.item.DicID +"\"); return false;'>"+this.item.DicCode+"</a>";
			             }},
			             {key:'KoFull',  label:'<spring:message code="Cache.LanguageCode_ko"/>', width:'100', align:'center'}, //한국어
			             {key:'EnFull',  label:'<spring:message code="Cache.LanguageCode_en"/>', width:'100', align:'center'},  // English
			             {key:'JaFull', label:'<spring:message code="Cache.LanguageCode_ja"/>', width:'100', align:'center'}, //日本語
			             {key:'ZhFull',  label:'<spring:message code="Cache.LanguageCode_zh"/>', width:'100', align:'center'}, //中国語
			             {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>',  width:'70', align:'center', sort:false },
			             {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>',   width:'70', align:'center', sort:false ,
			            	 formatter : function () {
			      				return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.DicID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(this,\"" + this.item.DicID + "\");'/>";
		      			 }},
			             {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', sort:'desc', 
		      				 formatter: function(){
								return CFN_TransLocalTime(this.item.ModifyDate);
							}
			             , dataType:'DateTime'}
      				];
		
		setSelect();
		setGrid();
		searchDictionary();
	};
	
	function setGrid(){
		setGridConfig();
	}
	
	function setGridConfig(){
		myGrid.setGridHeader(headerData); 
		
		myGrid.setGridConfig( {
			targetID : "dictionarygrid",
			height:"auto",
		});
	}
	
	function searchDictionary(){
		var domain = $("#selectDomain").val();
		var section = $("#selectArea").val();
		var search = $("#selectSearch").val();
		var text = $("#searchtext").val();
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		
		myGrid.page.pageNo = 1;		
		
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/dic/getList.do",
 			ajaxPars: {
 				"domain":domain,
 				"dicsection":section,
 				"selectsearch":search,
 				"searchtext":text,
 				"startdate":strdate,
 				"enddate":enddate
 			}
			,objectName: 'myGrid'
			,callbackName: 'searchDictionary'
		});
	}
	
	function addDictionary(pModal){
		Common.open("","adddictionary","<spring:message code='Cache.lbl_DictionaryCreation'/>","/covicore/dic/goDicPopup.do?mode=add","600px","420px","iframe",pModal,null,null,true);
	}
	
	function updateDictionary(pModal, configkey){
		Common.open("","updatedictionary","<spring:message code='Cache.lbl_DictionaryModify'/>","/covicore/dic/goDicPopup.do?mode=modify&key="+configkey,"600px","420px","iframe",pModal,null,null,true);
	}
	
	function deleteDictionary(){
		var deleteobj = myGrid.getCheckedList(0);
		var deleteDIC_IDs = "";
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>"); //삭제할 항목을 선택하여 주십시요.
			return;
		}else{
			Common.Confirm(Common.getDic("msg_Common_08"), "Confirmation Dialog", function(result){
				if(result){								
					for(var d=0;d<deleteobj.length;d++){
						deleteDIC_IDs += deleteobj[d].DicID;
						
						if(d != deleteobj.length - 1)
							deleteDIC_IDs += ",";
					}
					
					$.ajax({
						url:"/covicore/dic/remove.do",
						data:{"DeleteData" : deleteDIC_IDs},
						type:"post",
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform("<spring:message code='Cache.msg_138'/>"); //성공적으로 삭제되었습니다.
								Refresh();
							}
						},
						error:function(response, status, error){
			        	     CFN_ErrorAjax("/covicore/dic/remove.do", response, status, error);
			        	}
					});
				}
			});
		}
	}
	
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var domain = $("#selectDomain").val();
    			var dicsection = $("#selectArea").val();
    			var search = $("#selectSearch").val();
    			var text = $("#searchtext").val();
    			var strdate = $("#startdate").val();
    			var enddate = $("#enddate").val();
    			
    			var headername = getHeaderNameForExcel();
    			var headerType = getHeaderTypeForExcel();
    			
    			var sortKey = myGrid.getSortParam("one").split("=")[1].split(" ")[0];
    			var sortWay = myGrid.getSortParam("one").split("=")[1].split(" ")[1];
    			
    			location.href = "/covicore/dic/downloadExcel.do?domain="+domain+"&dicsection="+dicsection+"&selectsearch="+search+"&searchtext="+text+"&startdate="+strdate
    					+"&enddate="+enddate+"&sortKey="+sortKey+"&sortWay="+sortWay+"&headername="+encodeURI(headername)+"&headerType="+encodeURI(headerType);
       		}
		});
	}
	
	function ExcelUpload(pModal){
		Common.Inform("<spring:message code='Cache.msg_apv_037'/>"); //준비중입니다.
		//Common.open("","excelupload","엑셀 업로드","dictionaryexcelupload.do","300px","150px","iframe",pModal,null,null,true);
	}
	
	function Refresh(){
		$("#selectDomain").bindSelectSetValue('');	
		$("#selectArea").bindSelectSetValue('DicSection');	
		$("#selectSearch").bindSelectSetValue('');	
		$("#searchtext").val('');
		$("#startdate").val('');
		$("#enddate").val('');
		
		searchDictionary();
	}
	
	// Select box 바인드
	function setSelect(){
		var l_AssignedDomain = "¶"+Common.getSession("AssignedDomain")		
		// 그룹사 시스템 관리자라면 전체를 표시하기 위해
		if(l_AssignedDomain.indexOf("¶0¶") > -1){
			coviCtrl.renderDomainAXSelect('selectDomain', langCode, 'searchDictionary', '', "", true);
		} else {
			coviCtrl.renderDomainAXSelect('selectDomain', langCode, 'searchDictionary', '', Common.getSession("DN_ID"), false);
		}
		
		coviCtrl.renderAXSelect('DicSection', 'selectArea', langCode, 'searchDictionary', '', '');
		$("#selectSearch").bindSelect({ //검색 조건
			options: [
			          {'optionValue':'DicCode','optionText':'<spring:message code="Cache.lbl_DicID"/>'} //다국어키
			          ,{'optionValue':'KoFull','optionText':'<spring:message code="Cache.LanguageCode_ko"/>'} //한국어
			          ,{'optionValue':'EnFull','optionText':'<spring:message code="Cache.LanguageCode_en"/>'} // English
			          ,{'optionValue':'JaFull','optionText':'<spring:message code="Cache.LanguageCode_ja"/>'} //日本語
			          ,{'optionValue':'ZhFull','optionText':'<spring:message code="Cache.LanguageCode_zh"/>'}] //中国語
		});
		
		//coviCtrl.renderAXSelect('Search', 'selectSearch', 'ko', '', '', 'ORGROOT');
	}
	
	function updateIsUse(pObj,pDIC_ID) {
		$.ajax({
			url:"/covicore/dic/modifyUse.do",
			type:"post",
			data:{
				"dicID":pDIC_ID
				,"isUse":$(pObj).val()
			},
			success:function (data) {
				if(data.result != "ok"){
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");	 //오류가 발생하였습니다.
				}
			},
			error:function(response, status, error){
        	     CFN_ErrorAjax("/covicore/dic/modifyUse.do", response, status, error);
        	}
		});
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
		coviCmn.reloadCache("DIC", $("#selectDomain").val());
	}
</script>

