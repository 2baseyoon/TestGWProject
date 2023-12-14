<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript">
	var equipmentID = CFN_GetQueryString("equipmentID")=='undefined'? "": CFN_GetQueryString("equipmentID");
	var callbackFunc = CFN_GetQueryString("callback");
	var domainID = CFN_GetQueryString("domainID") == 'undefined' ? "" : CFN_GetQueryString("domainID");
 	var lang = Common.getSession("lang");
	var equipmentGrid = new coviGrid();

	$(document).ready(function (){
		setGrid();			// 그리드 세팅			
	});
	
	
	// 헤더 설정
	var headerData =[	            
	                  {key:'chk', label:'chk', width:'5', align:'center', formatter: 'checkbox'},
	                  {key:'IconPath',  label:'<spring:message code="Cache.lbl_SmartIcon"/>', width:'25', align:'center',  									/*아이콘*/
	                	  formatter:function(){
							  var iconPath = this.item.IconPath;
	                		  return '<img src="' + coviCmn.loadImage(Common.getBaseConfig("BackStorage").replace("{0}", this.item.CompanyCode) + this.item.IconPath) + '" width="16px" height="16px" onerror="coviCmn.imgError(this, false);">';
	                	  }
	                  },	  
	                  {key:'MultiEquipmentName',  label:'<spring:message code="Cache.lbl_EquipmentName"/>', width:'70', align:'center', 		   /*장비명*/
	                	  formatter:function(){
	                		  return  CFN_GetDicInfo(this.item.MultiEquipmentName, lang); 
	                	  }
	                  }
		      		];
	
	
	//그리드 세팅
	function setGrid(){
		equipmentGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		equipmentGrid.setGridConfig({targetID : "equipmentGrid", height:"260", resizeable: false, paging: false, page:{paging:false}});
	}
	

	//그리드 바인딩
	function searchConfig(){		
		equipmentGrid.bindGrid({
				ajaxUrl:"/groupware/resource/manage/getEquipmentList.do",
				ajaxPars : {"domainID": domainID, "isPaging":"N"},
				onLoad:function(){
					var equipmentIDs = equipmentID.split("@")
					$.each(equipmentGrid.list, function(idx,obj){
						if(obj.EquipmentID!='' && equipmentIDs.includes(obj.EquipmentID) ){
							equipmentGrid.checkedColSeq(0, true, idx)
						}
					});
				}
 		});
		
		$("#equipmentGrid").find("table").css("font-size", "13px");
	}	
	
	function returnEquipment(){
 		var selectedList = equipmentGrid.getCheckedList(0);
 		
		XFN_CallBackMethod_Call("divResourceInfo",callbackFunc, JSON.stringify(selectedList));
 		parent.Common.close('addEquipment');
 	}
	
</script>
<form id="form1">
    <div class="sadmin_pop">
		<div class="fixLine" id="equipmentGrid"></div>
		<div class="bottomBtnWrap">
			<a class="btnTypeDefault btnTypeBg" onclick="returnEquipment()"><spring:message code='Cache.btn_apv_save'/></a><!-- 저장 -->
			<a class="btnTypeDefault" onclick="Common.Close()"><spring:message code='Cache.btn_Close'/></a><!-- 닫기 -->
		</div>
	</div>
</form>