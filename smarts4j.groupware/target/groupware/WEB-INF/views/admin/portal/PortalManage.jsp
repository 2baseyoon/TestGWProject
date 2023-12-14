<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.CN_126'/></span>	<!--포탈 관리-->
</h3>
<form id="form1">
    <div style="width:100%; min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridRefresh();"/><!--새로고침-->
			<input id="add" type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addPortal(false);"/><!--추가-->
			<input id="del" type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="delPortal()"/><!--삭제-->
			<input id="copy" type="button" class="AXButton"  value="<spring:message code="Cache.btn_Copy"/>" onclick="copyPortal()"/><!--복사-->
		</div>	
		<div id="topitembar02" class="topbar_grid">
			<!--소유회사-->
			<spring:message code="Cache.lbl_OwnedCompany"/>:
			<select id="companySelectBox" class="AXSelect W100"></select>
			&nbsp;&nbsp;&nbsp;
			<!--포탈유형-->
			<spring:message code="Cache.lbl_PortalManage_01"/>: 
			<select id="portalTypeSelectBox" class="AXSelect W80"></select>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			
			<select id="searchTypeSelectBox" class="AXSelect W80"></select>			
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig();" class="AXButton"/><!--검색 -->
		</div>	
		<div id="portalGrid"></div>
	</div>
</form>

 
<form name="webpartSetting">
	<input type="hidden" name="portalID">
</form>


<script type="text/javascript">
	//# sourceURL=PortalManage.jsp
	var portalGrid = new coviGrid();
	var lang = Common.getSession("lang");

	//ready
	init();
	
	function init(){
		setSelectBox();  	// 검색 조건 select box 바인딩
		setGrid();			// 그리드 세팅			
	}
	
	function setSelectBox(){
		coviCtrl.renderCompanyAXSelect("companySelectBox",lang,true,"","",'')
		coviCtrl.renderAXSelect("PortalType","portalTypeSelectBox",lang,"", 	"", "");
		$("#searchTypeSelectBox").bindSelect({ //검색 조건
			options: [{'optionValue':'','optionText':'선택'},{'optionValue':'DisplayName','optionText':'포탈명칭'},{'optionValue':'LayoutName','optionText':'레이아웃'},{'optionValue':'RegisterName','optionText':'등록자'}]
		});
		
	}
	
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		portalGrid.setGridHeader([	            
		    	                  {key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
		    	                  {key:'PortalID',  label:'ID', width:'4', align:'center'},	   /*ID*/
		    	                  {key:'PortalTypeName',  label:'<spring:message code="Cache.lbl_PortalManage_01"/>', width:'7', align:'center'},     /*포탈유형*/
		    	                  {key:'BizSectionName',  label:'<spring:message code="Cache.lbl_businessDivision"/>', width:'7', align:'center'},     /*업무구분*/
		    	                  {key:'SortKey', label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'7', align:'center', sort:"asc"},     			   /*우선순위*/
		    	                  {key:'DisplayName',  label:'<spring:message code="Cache.lbl_PortalManage_03"/>', width:'20', align:'left',
		    	                	  formatter:function(){
		    	                		  return "<a href='#' onclick='modifyPortalPopup(\""+this.item.PortalID+"\")'>" + this.item.DisplayName + "</a>";
		    	                	  }
		    	                  },	     /*포탈명칭*/
		    	                  {key:'LayoutName', label:'<spring:message code="Cache.lbl_PortalManage_02"/>', width:'18', align:'left',
		    	                	  formatter:function(){
		    	                		  return "<a href='#' onclick=\"webpartSettingPopup(\'" +this.item.PortalID+ "\')\">" + this.item.LayoutName + "</a>";
		    	                	  }
		    	                  },	     /*레이아웃*/
		    	                  {key:'alcDisplay', label:'<spring:message code="Cache.lbl_Permissions"/>', width:'12', align:'center', sort:false,
		    	                	  formatter:function(){
		    	                		  if(this.item.aclDisplayCount > 0){
		    	                			  //{0}외 {1}명
		    	                			  return String.format("<spring:message code='Cache.msg_BesidesCount'/>",CFN_GetDicInfo(this.item.aclDisplayName),this.item.aclDisplayCount);
		    	                		  }else{
		    	                			  return CFN_GetDicInfo(this.item.aclDisplayName);
		    	                		  }
		    	                	  }
		    	                  },     /*사용권한*/
		    	                  {key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register"/>', width:'7', align:'center'},     /*등록자*/
		    	                  {key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'7', align:'center',
		    	                	  formatter:function () {
		    		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.PortalID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='ChangePortalIsUse(\""+this.item.PortalID+"\");' />";
		    		      			  }
		    	                  },      /*사용유무*/
		    	                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + " " + Common.getSession("UR_TimeZoneDisplay"), width:'9', align:'center', formatter: function(){
		    	  					return CFN_TransLocalTime(this.item.RegistDate, "yyyy-MM-dd");
		    	  				  }}       /*등록일*/ 
		    	                  
		    		      		]);
		
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "portalGrid",
			height:"auto"
		};
		
		portalGrid.setGridConfig(configObj);
	}
	

	//그리드 바인딩
	function searchConfig(){		
		var companyCode = $("#companySelectBox").val();	
		var portalType = $("#portalTypeSelectBox").val();
		var searchType = $("#searchTypeSelectBox").val();
		var searchWord = $("#search").val();
		portalGrid.bindGrid({
				ajaxUrl:"/groupware/portal/getPortalList.do",
				ajaxPars: {
					"companyCode":companyCode,
					"portalType":portalType,
					"searchType":searchType,
					"searchWord":searchWord
				}
		});
	}	
	
	
	// 새로고침
	function gridRefresh(){
		$("#companySelectBox").bindSelectSetValue('');	
		$("#portalTypeSelectBox").bindSelectSetValue('');
		$("#searchTypeSelectBox").bindSelectSetValue('');
		$("#search").val('');
		searchConfig();
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addPortal(pModal){		 
		//포탈 추가 | 포탈 정보를 추가합니다.
		parent.Common.open("","setPortal","<spring:message code='Cache.lbl_PortalManage_04'/>|||<spring:message code='Cache.msg_PortalManage_01'/>","/groupware/portal/goPortalManageSetPopup.do?mode=add","620px","520px","iframe",pModal,null,null,true);
	}
	
	// 포탈 수정 레이어 팝업
	function modifyPortalPopup(portalID){
		//포탈 수정 | 포탈 정보를 수정합니다.
		parent.Common.open("","setPortal","<spring:message code='Cache.lbl_PortalManage_05'/>|||<spring:message code='Cache.msg_PortalManage_02'/>","/groupware/portal/goPortalManageSetPopup.do?portalID="+portalID+"&mode=modify","620px","520px","iframe",true,null,null,true);
	}
	
	//포탈 복사
	function copyPortal(){
		var portalID;
		if(portalGrid.getCheckedList(0).length>1){
			Common.Warning("<spring:message code='Cache.lbl_Mail_SelectOneItem'/>","Warning",function(){ //1개의 항목만 선택해 주세요.
				return false;
			});
		}else if(portalGrid.getCheckedList(0).length < 1){
			Common.Warning("<spring:message code='Cache.msg_SelItemCopy'/>","Warning",function(){ //복사할 항목을 선택하세요
				return false;
			});
		}else{
			portalID = portalGrid.getCheckedList(0)[0].PortalID;			
			//포탈 복사, 포탈 정보를 복사합니다.
			//mode=copy로 호출
			Common.open("","setPortal","<spring:message code='Cache.lbl_PortalManage_07'/>|||<spring:message code='Cache.msg_PortalManage_09'/>","/groupware/portal/goPortalManageSetPopup.do?portalID="+portalID+"&mode=copy","620px","500px","iframe",true,null,null,true);
		}
	}
	
	
	//포탈 사용여부 변경
	function ChangePortalIsUse(portalID){
		$.ajax({
        	type:"POST",
        	url:"/groupware/portal/chnagePortalIsUse.do",
        	data:{
        		"portalID":portalID
        	},
        	success:function(data){
        		if(data.status!='SUCCESS'){
        			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
        		}
        	},
        	error:function(response, status, error){
        	     //TODO 추가 오류 처리
        	     CFN_ErrorAjax("/groupware/portal/chnagePortalIsUse.do", response, status, error);
        	}
        });
	}
	
	//포탈 삭제
	function delPortal(){
		var portalIDInfos = '';
		
		$.each(portalGrid.getCheckedList(0), function(i,obj){
			portalIDInfos += obj.PortalID + ';'
		});
		
		if(portalIDInfos == ''){
			 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
             return;
		}
		
		 Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
             if (result) {
                $.ajax({
                	type:"POST",
                	url:"/groupware/portal/deletePortalData.do",
                	data:{
                		"portalID":portalIDInfos
                	},
                	success:function(data){
                		if(data.status=='SUCCESS'){
                			Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
                			portalGrid.reloadList();
                		}else{
                			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
                		}
                	},
                	error:function(response, status, error){
                	     //TODO 추가 오류 처리
                	     CFN_ErrorAjax("/groupware/portal/deletePortalData.do", response, status, error);
                	}
                });
             }
         });
	}
	
	function webpartSettingPopup(portalID){
		window.open('','webpartSettingPopup');
		
		var webpartSettingForm = document.webpartSetting;
		webpartSettingForm.action = "/groupware/portal/goWebpartSetting.do";
		webpartSettingForm.method = "POST";
		webpartSettingForm.target = "webpartSettingPopup";
		webpartSettingForm.portalID.value = portalID;
		
		webpartSettingForm.submit();
	}
	
</script>


