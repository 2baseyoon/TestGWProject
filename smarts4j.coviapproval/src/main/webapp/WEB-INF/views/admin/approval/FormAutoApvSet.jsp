<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var type = CFN_GetQueryString("type");
	var sKind = CFN_GetQueryString("kind");
 
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
			}
		}else if(type == "R"){
			if(sKind == "Chgr"){
				setDataInputID = "scChgrReg";
			}else if(sKind == "ChgrOU"){
				setDataInputID = "scChgrOUReg";
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
	//양식 관리 -  원본양식파일 선택 리스트
	function setAutoApprovalLineRegionlist(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{		
				sortBy : "InsertDate desc",
				pageNo : "1",
				pageSize : "99999"
			},
			url:"/approval/admin/getAutoApprovalLineRegionlist.do",
			success:function (data) {				
				for(var i=0; i<data.list.length; i++){
					var html = "";
					html = "<tr>"
                    	 + "<td class='t_back01_line'>"+data.list[i].nodeName+"</td>"
                    	 + "<td class='t_back01_line'><input name='REG_"+data.list[i].nodeValue+"' id='REG_"+data.list[i].nodeValue+"' type='text' style='width:200px'></td>"
                    	 + "<td class='t_back01_line'><input type='button' id='btApvLine' class='AXButton' onclick=\"setAutoApvLine('REG_"+data.list[i].nodeValue+"');\" value=\"<spring:message code='Cache.lbl_selection' />\"/></td>"
                    	 + "</tr>";                    
                    $("#tblList").append(html);
				}
				
				// 기존 데이터 테스트
				setOldData();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approvaladmin/getAutoApprovalLineRegionlist.do", response, status, error);
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
                    	 + "<td class='t_back01_line'><input name='ENT_"+data.list[i].optionValue+"' id='ENT_"+data.list[i].optionValue+"' type='text' style='width:200px' json-value='true'></td>"
                    	 + "<td class='t_back01_line'><input type='button' id='btApvLine' class='AXButton' onclick=\"setAutoApvLine('ENT_"+data.list[i].optionValue+"');\" value=\"<spring:message code='Cache.lbl_selection' />\"/></td>"
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
             parent.Common.open("","JFListSelect",sLayerTitle,"/approval/admin/goJFListSelect.do?functionName=JFlistFAAS","500px","350px","iframe",true,null,null,true);          
         } else {        	 
             var orgType = "B9";
             if (sKind == "ChgrOU") orgType = "C9";
             if (sKind == "CC") orgType = "D9";
             if (sKind == "CCBefore") orgType = "D9";             
             parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=formAASBack&szObject="+szObject+"&type="+orgType+"&setParamData=_setParamdataApv","1060px","580px","iframe",true,null,null,true);
             
             //parent.XFN_OrgMapShow("btApvLine", "DivAutoApvLine", szObject, "btn_FormAutoSet", "OrgMap_CallBack", orgType, "Y", "Y", "U", "APPROVAL", "", "");
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
    	var callBack = "";
    	if(type=="E"&&sKind=="Chgr")
    		callBack = "scChgrEnt";
    	else if(type=="R"&&sKind=="Chgr")
    		callBack = "scChgrReg";
    	else if(type=="E"&&sKind=="ChgrOU")
    		callBack = "scChgrOUEnt";
    	else if(type=="R"&&sKind=="ChgrOU")
    		callBack = "scChgrOUReg";	    	
    	var paramData= JSON.stringify(tblListbj);
    	parent._setNomalValue(callBack,paramData);
    	Common.Close();		
    }
</script>
<form id="FormAutoApvSet" name="FormAutoApvSet">
	<div id="divFormBasicInfo">
		<div style="padding-bottom:10px; padding-left:10px; padding-right:10px; padding-top:10px;"> 
			<div>
				<div class="t_back" style="margin-right:0px; height:330px;overflow-y:scroll">
					<table id="tblList" class="AXFormTable"  cellpadding="0" cellspacing="0">
						<tr>
							<th style='text-align:center; width:100px;'><spring:message code='Cache.lbl_PlaceOfBusiness' /></th><!--결재구분-->
							<th style='text-align:center; width:200px;'><spring:message code='Cache.lbl_SelectedList' /></th><!--결재자-->
							<th style='text-align:center;'></th>
						</tr>
					</table>
				</div>
			</div>
		</div>
	</div>
	<div align="center" style="padding-top: 10px">
		<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton" />
		<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
		<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />
	</div>
</form>