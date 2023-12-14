<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var type = CFN_GetQueryString("type");
	var sKind = CFN_GetQueryString("kind");
	var targetID = CFN_GetQueryString("targetID");
 
	$(document).ready(function(){
		if(type=="E"){
			setEntList();
		}else{
			setAutoApprovalLineRegionlist();	
		}
	});
	
	function setOldData(){
		var oldData;
		var setDataInputID = "";
		if(type == "E"){
			if(sKind == "Chgr"){
				setDataInputID = "scChgrEnt";
			}else if(sKind == "ChgrOU"){
				setDataInputID = "scChgrOUEnt";
			}else if(sKind == "PRec"){
				setDataInputID = "scPRecEnt";
			}else if(sKind == "PRecA"){
				setDataInputID = "scPRecAEnt";
			}else if(sKind == "DRec"){
				setDataInputID = "scDRecEnt";
			}
		}else if(type == "R"){
			if(sKind == "Chgr"){
				setDataInputID = "scChgrReg";
			}else if(sKind == "ChgrOU"){
				setDataInputID = "scChgrOUReg";
			}else if(sKind == "PRec"){
				setDataInputID = "scPRecReg";
			}else if(sKind == "PRecA"){
				setDataInputID = "scPRecAReg";
			}else if(sKind == "DRec"){
				setDataInputID = "scDRecReg";
			}
		}
		
		var oldData = parent.$("#schemaDetailPopup_if").contents().find("input[type=text][name="+setDataInputID+"]").val();
		if(oldData != ""){
			oldData = JSON.parse(oldData);
			
			$("#FormAutoApvSet").find("input[type=text]").each(function(){
				var data = $$(oldData).attr($(this).attr("id"));
				
				if(typeof data == "object")
					data = JSON.stringify(data);
					
				$(this).val(data);
			});
		}
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	// 사업장리스트 셋팅
	function setAutoApprovalLineRegionlist(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{		
				sortBy : "InsertDate desc",
				pageNo : "1",
				pageSize : "99999"
			},
			url:"/approval/manage/getAutoApprovalLineRegionlist.do",
			success:function (data) {				
				for(var i=0; i<data.list.length; i++){
					var html = "";
					html = "<tr>"
                    	 + "<td class='t_back01_line'>"+data.list[i].nodeName+"</td>"
                    	 + "<td class='t_back01_line'><input name='REG_"+data.list[i].nodeValue+"' id='REG_"+data.list[i].nodeValue+"' type='text' style=''></td>"
                    	 + "<td class='t_back01_line' style='text-align:center;'>" 
                    	 + "<a href='#' id='btApvLine' onclick=\"setAutoApvLine('REG_"+data.list[i].nodeValue+"');\" class='btnTypeDefault'><spring:message code='Cache.lbl_selection' /></a>"
                    	 + "</td>"
                    	 + "</tr>";                    
                    $("#tblList").append(html);
				}
				
				// 기존 데이터 테스트
				setOldData();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approvalmanage/getAutoApprovalLineRegionlist.do", response, status, error);
			}
		});	
		
	}
	
	// 회사리스트 셋팅
	function setEntList(){
		//data 조회
		
		$.ajax({
			type:"POST",
			data:{				
			},
			url:"/approval/common/getEntInfoListAssignData.do",
			async:false,
			success:function (data) {
				for(var i=0; i<data.list.length; i++){
					var html = "";
					html = "<tr>"
                    	 + "<td class='t_back01_line'>"+data.list[i].optionText+"</td>"
                    	 + "<td class='t_back01_line'><input name='ENT_"+data.list[i].optionValue+"' id='ENT_"+data.list[i].optionValue+"' type='text' style='' json-value='true'></td>"
                    	 + "<td class='t_back01_line' style='text-align:center;'>"
                    	 + "<a href='#' id='btApvLine' onclick=\"setAutoApvLine('ENT_"+data.list[i].optionValue+"');\" class='btnTypeDefault'><spring:message code='Cache.lbl_selection' /></a>"
                    	 + "</td>"
                    	 + "</tr>";                    
                    $("#tblList").append(html);
				}
				
				// 기존 데이터 테스트
				setOldData();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/common/getEntInfoListDefaultData.do", response, status, error);
			}
		});	
		
	}

	
	 parent.objTxtSelect = null;
     function setAutoApvLine(szObject) {
    	 
         if (szObject != null) {
        	 parent.objTxtSelect  = document.getElementsByName(szObject)[0];
         }
         if (sKind == "Chgr") {        	 
             var szURL = "/approval/JFMgr/JFListSelect.aspx";
             var nWidth = 400;
             var nHeight = 300 - 33;
             var sLayerTitle = "<spring:message code='Cache.lbl_SelChargeTask' />";            
             parent.Common.open("","JFListSelect",sLayerTitle,"/approval/manage/goJFListSelect.do?functionName=JFlistFAAS","500px","350px","iframe",true,null,null,true);          
         } else if(sKind == "ChgrOU") {        	 
             var orgType = "B9";
             if (sKind == "ChgrOU") orgType = "C9";
             if (sKind == "CC") orgType = "D9";
             if (sKind == "CCBefore") orgType = "D9";             
             parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=formAASBack&szObject="+szObject+"&type="+orgType+"&setParamData=_setParamdataApv","1060px","580px","iframe",true,null,null,true);
             
             //parent.XFN_OrgMapShow("btApvLine", "DivAutoApvLine", szObject, "btn_FormAutoSet", "OrgMap_CallBack", orgType, "Y", "Y", "U", "APPROVAL", "", "");
         } else if(sKind == "PRec") {        	 
             var orgType = "B9";
             parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=formAASBack&szObject="+szObject+"&type="+orgType+"&setParamData=_setParamdataApv","1060px","580px","iframe",true,null,null,true);
         } else if(sKind == "PRecA") {        	 
             parent.Common.open("", "FormAutoRecApvSet",
					"<spring:message code='Cache.lbl_receiver_apv' />",
					"/approval/manage/goFormAutoRecApvSet.do?type="+type + "&kind=" + sKind + "&targetID=" + szObject +"&openID="+ CFN_GetQueryString("CFN_OpenLayerName") + "&OpenFrom=FormAutoRecApvSet", "500px", "400px",
					"iframe", true, null, null, true); // // 수신결재자 셋팅
         } else if(sKind == "DRec") {        	 
             var orgType = "C9";
             parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=formAASBack&szObject="+szObject+"&type="+orgType+"&setParamData=_setParamdataApv","1060px","580px","iframe",true,null,null,true);
         }
     }
     
     
    parent._setParamdataApv = setParamdataApv;
 	function setParamdataApv(paramszObject){
 		return setszObjApv[paramszObject];
 	}
 	
 	
    parent.JFlistFAAS = setobjTxtSelect;
 	function setobjTxtSelect(data){ 		
 		$( parent.objTxtSelect ).val(data);	 			
 	}	
     
 	parent._setPRecAValue = setPRecAValue;
 	function setPRecAValue(data){ 		
 		$( parent.objTxtSelect ).val(data);	 			
 	}
 	
 	var setszObjApv = new Object();
	//조직도선택후처리관련
	var peopleObj = {};
	parent.formAASBack = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){		
		var dataObj = $.parseJSON(peopleValue);	
		if(dataObj.item.length > 0){    
		    $( parent.objTxtSelect ).val(peopleValue);
		    setszObjApv[$( parent.objTxtSelect ).attr("name")]=peopleValue;
		}			
	}	
	
	
	 function saveSubmit(){
		var tblListArray = new Array();	 
    	var tblListbj = new Object();
    	$("#tblList tr:not(:first)").each(function(i){
    		if(!axf.isEmpty($(this).find("input[type='text']").val()))
    			{  
					var objName = $(this).find("input[type='text']").attr('id');		
					if(sKind=="Chgr"){
						tblListbj[objName] = $(this).find("input[type='text']").val();
					}else{
						tblListbj[objName] = jQuery.parseJSON($(this).find("input[type='text']").val());
					}
    			}    		
		});
    		    	
    	var paramData= JSON.stringify(tblListbj);
    	parent._setNomalValue(targetID,paramData);
    	Common.Close();		
    }
</script>
<form id="FormAutoApvSet" name="FormAutoApvSet">
	<div id="divFormBasicInfo" class="sadmin_pop">
		<div style=""> 
			<div>
				<div class="" style="height:310px;overflow-y:auto">
					<table id="tblList" class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col width="40%">
							<col width="40%">
							<col width="20%">
						</colgroup>
						<tr style="height:35px;">
							<th style='text-align:center; width:100px;'><spring:message code='Cache.lbl_PlaceOfBusiness' /></th><!--결재구분-->
							<th style='text-align:center; width:200px;'><spring:message code='Cache.lbl_SelectedList' /></th><!--결재자-->
							<th style='text-align:center;'></th>
						</tr>
					</table>
				</div>
				<div class="bottomBtnWrap">
					<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveSubmit();" ><spring:message code="Cache.btn_apv_save"/></a>
					<a id="btn_delete" href="#" class="btnTypeDefault" onclick="deleteSubmit();" style="display:none"><spring:message code="Cache.btn_apv_delete"/></a>
					<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
				</div>
			</div>
		</div>
	</div>
</form>