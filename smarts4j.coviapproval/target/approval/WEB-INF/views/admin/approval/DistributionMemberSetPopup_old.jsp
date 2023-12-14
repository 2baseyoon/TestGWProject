<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramGroupID =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){	
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
			//$("#SeqHiddenValue").val(key);					
		}
	});
	
	// 숫자만 입력 (사용법 : onkeydown="CFN_NumberOnly(event);" )
	function CFN_NumberOnly(event) {
		if (
	        event.keyCode == 8       // backspace
	        || event.keyCode == 9       // tab
	        || event.keyCode == 13      // enter
	        || event.keyCode == 27      // escape
	        || event.keyCode == 46      // delete
	        || (event.keyCode == 65 && event.ctrlKey === true)  // Ctrl+A    
	        || (event.keyCode >= 35 && event.keyCode <= 39)     // end(35), home(36), left(37), up(38), right(39)
	        ) {
			return; // 해당 특수 문자만 허용
		} else {
			if (
	                event.shiftKey                              // shift 이거나
	            || (event.keyCode < 48 || event.keyCode > 57)   // 0 ~ 9 이외
	            && (event.keyCode < 96 || event.keyCode > 105)  // 0(Ins) ~ 9(PgUp) 이외
	            ) {
				CFN_CancelEvent(event); // 금지
			} else {
				return; // 숫자키만 허용
			}
		}
	}
	
	// 이벤트 취소
	function CFN_CancelEvent(event) {
		if ('cancelable' in event) {
			if (event.cancelable) {
				event.preventDefault();
			}
		} else {
			event.returnValue = false;
		}
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
		
		
	
	//저장
	function saveSubmit(){
		//data셋팅			
		
		if($("#tableDistributionMemberBody tr").length==1){
			Common.Warning(Common.getDic("msg_apv_ValidationDistributionAdd"));		//배포대상 추가 후 저장 가능합니다.			
			return;
		}
	
		var DistributionMemberArray = new Array();		
		jQuery.ajaxSettings.traditional = true;
		
		$("#tableDistributionMemberBody tr:not(:first)").each(function(i){			
			var DistributionMemberObj = new Object();	
			DistributionMemberObj.GroupID = paramGroupID;
			DistributionMemberObj.SortKey = $("#iptSortKey"+i).val();			
			DistributionMemberObj.UserCode = $("#UserCode"+i).text();			
			DistributionMemberArray.push(DistributionMemberObj);			
		});	
		
		//jsavaScript 객체를 JSON 객체로 변환
		DistributionMemberArray = JSON.stringify(DistributionMemberArray);		
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{				
				"DistributionMember" : DistributionMemberArray
			},
			url:"insertDistributionMember.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Warning(Common.getDic("msg_apv_137"));
				parent.searchConfig2();
				closeLayer();
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertDistributionMember.do", response, status, error);
			}
		});
	}
	
	//조직도띄우기
	function OrgMap_Open(mapflag){
		flag = mapflag;		
		if(mapflag=="0"){
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9","1060px","580px","iframe",true,null,null,true);
		}else{
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=C9","1060px","580px","iframe",true,null,null,true);
		}
	}
	//조직도선택후처리관련
	var peopleObj = {};
	parent._CallBackMethod2 = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){		
		var dataObj = $.parseJSON(peopleValue);		
		if(dataObj.item.length > 0){				
			$(dataObj.item).each(function(i){
				
				if(dataObj.item[i].itemType=="user"){
				var number = $("#tableDistributionMemberBody tr:not(:first)").length;
				$("#tableDistributionMemberBody").append("<tr>");
				$("#tableDistributionMemberBody").append("<td id='UR_Name"+number+"'>"+dataObj.item[i].DN+"</td>");
				$("#tableDistributionMemberBody").append("<td id='UserCode"+number+"'>"+dataObj.item[i].AN+"</td>");
				$("#tableDistributionMemberBody").append("<td id='DEPT_Name"+number+"'>"+dataObj.item[i].GroupName+"</td>");
				$("#tableDistributionMemberBody").append("<td id='SortKey"+number+"'><input id='iptSortKey"+number+"' name='iptSortKey"+number+"' type='text' mode='numberint'  num_max='32767' class='AXInput'  onkeydown='CFN_NumberOnly(event);'  style='width:40px; height:17px; line-height:17px;'/></td>");
				$("#tableDistributionMemberBody").append("</tr>");					
				}
		
				if(dataObj.item[i].itemType=="group"){
				var number = $("#tableDistributionMemberBody tr:not(:first)").length;
				$("#tableDistributionMemberBody").append("<tr>");
				$("#tableDistributionMemberBody").append("<td id='UR_Name"+number+"'>"+dataObj.item[i].DN+"</td>");
				$("#tableDistributionMemberBody").append("<td id='UserCode"+number+"'>"+dataObj.item[i].AN+"</td>");
				$("#tableDistributionMemberBody").append("<td id='DEPT_Name"+number+"'></td>");
				$("#tableDistributionMemberBody").append("<td id='SortKey"+number+"'><input id='iptSortKey"+number+"' name='iptSortKey"+number+"' type='text' mode='numberint'  num_max='32767' class='AXInput'  onkeydown='CFN_NumberOnly(event);'  style='width:40px; height:17px; line-height:17px;'/></td>");
				$("#tableDistributionMemberBody").append("</tr>");
				}
			})
		}else{
		}
}	
</script>
<form id="DistributionMemberSetPopup" name="DistributionMemberSetPopup">
	<div class="pop_body1">
		<p>
			<input type="button" value="<spring:message code="Cache.btn_apv_add"/>-<spring:message code="Cache.lbl_apv_person"/>" onclick="OrgMap_Open(0);" class="AXButton" />
			<input type="button" value="<spring:message code="Cache.btn_apv_add"/>-<spring:message code="Cache.lbl_apv_dept"/>" onclick="OrgMap_Open(1);" class="AXButton" />
		</p> 		
	    <div class="ztable_list">
            <table class="AXFormTable" id="tableDistributionMember"  border="0" cellpadding="0" cellspacing="0" style="width:95%; font-size:12px;">
            	<tbody id="tableDistributionMemberBody">
                <tr >
                    <th width="100"><span style="text-align: center;"><spring:message code='Cache.lbl_DistributionTarget'/></span></th>
                    <th width="100"><span style="text-align: center;"><spring:message code='Cache.lbl_ID'/></span></th>
                    <th width="100"><span style="text-align: center;"><spring:message code='Cache.lbl_DeptName'/></span></th>                    
                    <th width="50"><span  style="text-align: center;"><spring:message code='Cache.lbl_apv_SortKey'/></span></th>                                        
                </tr>  
                </tbody>                              
            </table>
        </div>        
	   <div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton" />
			<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
			<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />
		</div>	    
        </div>
	<input type="hidden" id="SeqHiddenValue" value="" />
	<input type="hidden" id="EntCode" value="" />
	<div id="divSelOrginFormFile">	
	</div>
</form>