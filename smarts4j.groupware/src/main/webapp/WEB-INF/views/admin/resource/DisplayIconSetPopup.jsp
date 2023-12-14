<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<script type="text/javascript">
	var displayIcon =  ${displayIcon}
	var callbackFunc = CFN_GetQueryString("callback");
	var lang = Common.getSession("lang");
	
 	var iconGrid = new coviGrid(); 
 	
 	$(document).ready(function(){
 		setGridData();
 		
 	});
 	
 	
 	function setGridData(){
 		
 		iconGrid.setGridHeader([	            
 		 		                  {key:'Reserved1', label:'ICON', width:'20', align:'center', formatter: function(){
 		 		                	  if(this.item.Reserved1==undefined){
 		 		                		  return '<img  width="16px" height="16px" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif" />';
 		 		                	  }else{
	 		 		                	  return '<img width="16px" height="16px" src="'+this.item.Reserved1+'" onerror="this.src=\'/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif\'">';
 		 		                	  }
 		 		                  }},
 		 		                  {key:'MultiCodeName', label:'<spring:message code="Cache.lbl_Description"/>', width:'80', formatter:function(){
 		 		                		  return CFN_GetDicInfo(this.item.MultiCodeName, lang); 
 		 		               	  }}      /*설명*/
 		 			      		]
 		 );
 		
 		iconGrid.setGridConfig({		
 			targetID : "placeGrid",
 			height:"400"	, 
 			paging: false,
 			body:{
				onclick : function(idx,obj){
					returnIcon(obj);
				}
			}
 		});
		
 		iconGrid.bindGrid(displayIcon);
		
 		iconGrid.setPaging()
 	}
 	
 	function returnIcon(obj){
 		var retVal = obj.Code + "|" + CFN_GetDicInfo(obj.MultiCodeName,lang) + "|" +obj.Reserved1 ;
		XFN_CallBackMethod_Call("divResourceInfo",callbackFunc,  retVal);
 		parent.Common.close('findDisplayIcon');
 	}
</script>

<body>
<form id="form1">
  <div>
         <div id="placeGrid"></div>
	     <div class="pop_btn2" align="center" >
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />                    
	    </div>     
  </div>
  <input type="hidden" ID="hidFolderInfo" />
</form>
</body>