<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramBizDocID =  param[1].split('=')[1];
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
		
		if($("#tableBizDocMemberBody tr").length==1){
			Common.Warning(Common.getDic("msg_181"));	//담당자를 지정하십시요.		
			return;
		}
	
		var BizDocMemberArray = new Array();		
		jQuery.ajaxSettings.traditional = true;
		$("#tableBizDocMemberBody tr:not(:first)").each(function(i){			
			var BizDocMemberObj = new Object();				
			BizDocMemberObj.BizDocID = paramBizDocID;
			BizDocMemberObj.UserCode = $("#UR_Code"+i).text();
			BizDocMemberObj.SortKey = $("#iptSortKey"+i).val();
			BizDocMemberArray.push(BizDocMemberObj);			
		});	
		
		//jsavaScript 객체를 JSON 객체로 변환
		BizDocMemberArray = JSON.stringify(BizDocMemberArray);		
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{				
				"BizDocMember" : BizDocMemberArray
			},
			url:"insertBizDocMember.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Warning(Common.getDic("msg_apv_137"));
				parent._CallBackMethod1();
				closeLayer();
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertBizDocMember.do", response, status, error);
			}
		});
	}
	
	//조직도띄우기
	function OrgMap_Open(mapflag){
		flag = mapflag;
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>",""/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9","1060px","580px","iframe",true,null,null,true);
	}
	//조직도선택후처리관련
	var peopleObj = {};
	parent._CallBackMethod2 = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){		
		var dataObj = $.parseJSON(peopleValue);		
		if(dataObj.item.length > 0){				
			$(dataObj.item).each(function(i){					
				$("#tableBizDocMemberBody").append("<tr>");
				$("#tableBizDocMemberBody").append("<td id='UR_Name"+i+"'>"+dataObj.item[i].DN+"</td>");
				$("#tableBizDocMemberBody").append("<td id='UR_Code"+i+"'>"+dataObj.item[i].AN+"</td>");
				$("#tableBizDocMemberBody").append("<td id='DN_Name"+i+"'>"+dataObj.item[i].DN_Name+"</td>");
				$("#tableBizDocMemberBody").append("<td id='SortKey"+i+"'><input id='iptSortKey"+i+"' name='iptSortKey"+i+"' type='text' mode='numberint'  num_max='32767' class='AXInput'  onkeydown='CFN_NumberOnly(event);'  style='width:40px; height:17px; line-height:17px;'/></td>");
				$("#tableBizDocMemberBody").append("</tr>");
			})				
		}else{
		}
	}	
</script>
<form id="BizDocMemberSetPopup" name="BizDocMemberSetPopup">
	<div class="pop_body1">
		<p><input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="OrgMap_Open();" class="AXButton" /></p> 		
	    <div class="ztable_list">
            <table class="AXFormTable" id="tableBizDocMember"  border="0" cellpadding="0" cellspacing="0" style="width:95%; font-size:12px;">
            	<tbody id="tableBizDocMemberBody">
                <tr >
                    <th width="100"><span style="text-align: center;"><spring:message code="Cache.lbl_apv_ChargerName"/></span></th>
                    <th width="100"><span  style="text-align: center;"><spring:message code="Cache.lbl_apv_ChargerCode"/></span></th>
                    <th width="100"><span  style="text-align: center;"><spring:message code="Cache.lbl_apv_AdminDept"/></span></th>                    
                    <th width="50"><span  style="text-align: center;"><spring:message code="Cache.lbl_apv_SortKey"/></span></th>                                        
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