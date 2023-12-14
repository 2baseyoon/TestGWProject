<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript">
	var placeOfBusiness =  ${placeOfBusinessData}
	var placeOfBusinessCode = CFN_GetQueryString("placeOfBusinessCode");
	var callbackFunc = CFN_GetQueryString("callback");
	var lang = Common.getSession("lang");
	
 	var placeGrid = new coviGrid(); 
 	
 	$(document).ready(function(){
 		setGridData();
 		
 	});
 	
 	
 	function setGridData(){
 		
 		placeGrid.setGridHeader([	            
 		 		                  {key:'chk', label:'chk', width:'10', align:'center', formatter: 'checkbox'},
 		 		                  {key:'Code',  label:'Code', width:'15', align:'center'},	  
 		 		                  {key:'MultiCodeName',  label:'<spring:message code="Cache.lbl_PlaceOfBusiness"/>', width:'15', align:'center', 		   /*사업장*/
 		 		                	  formatter:function(){
 		 		                		  return CFN_GetDicInfo(this.item.MultiCodeName, lang); 
 		 		                	  }
 		 		                  },   
 		 		                  {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', width:'40',},      /*설명*/
 		 		                  {key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'15', align:'center', sort:"asc"}   			   /*우선순위*/
 		 			      		]
 		 );
 		
		placeGrid.setGridConfig({		targetID : "placeGrid", height:"260px"	, paging: false});
		
		placeGrid.bindGrid(placeOfBusiness);
		
		placeGrid.setPaging()
		
		var placeCodes = placeOfBusinessCode.split(";")
		$.each(placeGrid.list, function(idx,obj){
			if(obj.Code!='' && placeCodes.includes(obj.Code) ){
				placeGrid.checkedColSeq(0, true, idx)
			}
		});
		
		$("#placeGrid").find("table").css("font-size", "13px");
 	}
 	
 	function returnPlaceOfBusiness(){
 		var codeList = "";
 		var codeNameList = "";
 		var selectedList = placeGrid.getCheckedList(0);
 		
 		$.each(selectedList, function(idx,obj){
 			codeList += (obj.Code +";");
 			codeNameList +=(CFN_GetDicInfo(obj.MultiCodeName, lang) +";"); 
 		});
 		
 		var retVal = codeList + "|" + codeNameList;
		XFN_CallBackMethod_Call("divResourceInfo",callbackFunc,  retVal);
 		parent.Common.close('findPlaceOfBusiness');
 	}
</script>

<body>
<form id="form1">
  <div class="sadmin_pop">
         <div id="placeGrid" class="fixLine"></div>
		<div class="bottomBtnWrap">
			<a class="btnTypeDefault btnTypeBg" onclick="returnPlaceOfBusiness()"><spring:message code='Cache.Cache.Cache.btn_apv_save'/></a><!-- 저장 -->
			<a class="btnTypeDefault" onclick="Common.Close();" ><spring:message code='Cache.Cache.Cache.btn_Close'/></a><!-- 닫기 -->
		</div>
  </div>
  <input type="hidden" ID="hidFolderInfo" />
</form>
</body>