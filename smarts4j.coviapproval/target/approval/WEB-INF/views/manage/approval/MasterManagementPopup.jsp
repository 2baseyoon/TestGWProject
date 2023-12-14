<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode = param[0].split('=')[1];
	var data = decodeURIComponent((param[1].split('=')[1]+'').replace(/\+/g, '%20'));
	var entCode = param[2].split('=')[1];
	var selectPopupType = "B1";			// 선택 팝업 타입
	var mappingCode = "";
	var ruleId = "";
	var ruleType = "";
	var dnId = "";  
	
	$(document).ready(function() {
		init();	 // 초기화
	});
	
	// 초기화
	function init() {
		// 넘어온 데이터 처리, 버튼
		if (mode == "") {
			$("#updBtn").css("display", "none");
			$("#delBtn").css("display", "none");
			$('input:radio[name="ruleType"]').filter('[value="0"]').attr('checked', true);
			$("#tableDiv1").css("display", "");
		} else if (mode == "RuleName") {
			var dataArr = data.split(',');
			ruleId = dataArr[0];
			$("#ruleName").val(dataArr[1]);
			ruleType = dataArr[2];
			$('input:radio[name="ruleType"]').filter('[value=' + ruleType + ']').attr('checked', true);
			
			if (ruleType == 1 || ruleType == 2 || ruleType == 3 || ruleType == 4 || ruleType == 5 || ruleType == 6) {
				
				$("#mappingCodeTr").css("display", "");
				if(ruleType == 1 || ruleType == 2){
					$("#mappingCodeName").hide();
	        		$("#mappingCodeBtn").hide();
	        		$("#mappingText").html("목록 화면의 mapping 을 통해 추가해주시기 바랍니다.");
				}else{
					mappingCode = dataArr[3];
					$("#mappingCodeName").val(CFN_GetDicInfo(dataArr[4]));
					$("#hidMaapingCodeName").val(dataArr[4]);			
				}
				if (ruleType == 4 || ruleType == 5) {selectPopupType = "C1";}
			}
			
			$("#addBtn").css("display", "none");
			$("#tableDiv1").css("display", "");
		} else if (mode == "MappingNames") {
			var dataArr = data.split(',');
			ruleId = dataArr[0];
			ruleType = dataArr[1];
			dnId = dataArr[2];
			
			makeHtml();		// mapping 팝업 html 생성
			
			$("#updBtn").css("display", "none");
			$("#tableDiv2").css("display", "");
		}
		
		// 라디오 버튼 체크 이벤트
		$('input:radio[name="ruleType"]').change(function() {
			// 선택 값 초기화
			mappingCode = "";
			$("#mappingCodeName").val("");
			$("#hidMaapingCodeName").val("");
			
	        if (this.value == '0' ) {
	        	$("#mappingCodeTr").css("display", "none");
	        } else {
	        	$("#mappingCodeTr").css("display", "");
	        	
	        	if(this.value == '1' || this.value == '2'){
	        		$("#mappingCodeName").hide();
	        		$("#mappingCodeBtn").hide();
	        		$("#mappingText").html("목록 화면의 mapping 을 통해 추가해주시기 바랍니다.");
	        	}else{
	        		$("#mappingCodeName").show();
	        		$("#mappingCodeBtn").show();
	        		$("#mappingText").html("");
	        	}
	        	
	        	// 선택 팝업 타입
	        	if (this.value == '3') {
	        		selectPopupType = "B1";
	        	} else if (this.value == '4' || this.value == '5') {
	        		selectPopupType = "C1";
	        	}
	        }
		});
	}
	
	// mapping 팝업 html 생성
	function makeHtml() {
		$.ajax({
			type:"POST",
			data:{
			  "ruleId" : ruleId
			},
			url:"getMappingList.do",
			success:function (data) {
				if(data.result == "ok") {
					var list = data.list;
					
					$("#tableDiv2").empty();
					
					var html = "<table class=\"sadmin_table sa_menuBasicSetting mb20\" >";
					html += "<tbody>";
					html += "<tr style='height:35px;'>";
					if (ruleType == 2) {
						html += "<th style=\"width:35px;\"></th><th style=\"text-align:center;\"><spring:message code='Cache.lbl_apv_jobposition_name'/></th><th style=\"text-align:center;\"><spring:message code='Cache.lbl_apv_jobposition_code'/></th>";
					} else {
						html += "<th style=\"width:35px;\"></th><th style=\"text-align:center;\"><spring:message code='Cache.lbl_apv_AdminName'/></th><th style=\"text-align:center;\"><spring:message code='Cache.lbl_apv_AdminID'/></th>";
					}
					html += "</tr>";
					var len = list.length; 
					if (len == 0) {
						html += "<tr>";
						html += "<td colspan=\"3\" style=\"text-align:center;\">"+"<spring:message code='Cache.msg_apv_101'/>"+"</td>";
						html += "</tr>";			
					} else {
						for (var i=0; i<len; i++) {
							html += "<tr>";
							html += "<td style=\"text-align:center;\">";
							html += "<input type=\"checkbox\" name=\"mappingCheckbox\" value=\""+list[i].MappingID+"\"/>";
							html += "</td>";
							html += "<td>"+CFN_GetDicInfo(list[i].MappingName)+"</td>";
							html += "<td>"+list[i].MappingCode+"</td>";
							html += "</tr>";
						}
					}
					html += "</tbody>";
					html += "</table>";
					
					$("#tableDiv2").append(html);					
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getMappingList.do", response, status, error);
			}
		});
	}
	
	// 선택 팝업
	function selectBtnPopup() {
		var selItem = $(':radio[name="ruleType"]:checked').val();
		
		if (selItem == 6) {
    		parent.Common.open("", "JFListSelect", "<spring:message code='Cache.lbl_apv_jfselect_title'/>", "/approval/manage/goJFListSelect.do?functionName=JFlistSchema&selType=rule", "500px", "350px", "iframe", true, null, null, true);
		} else {
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type="+selectPopupType,"1060px","580px","iframe",true,null,null,true);
		}
	}
	// 선택 팝업 콜백
	parent._CallBackMethod2 = setOrgMapData;
	function setOrgMapData(data) {
		if (mode == "MappingNames") {
			var obj = $.parseJSON(data);
			var len = obj.item.length;
			var paramArr = new Array();
			
			if (len > 0) {
				for (var i=0; i<len; i++) {
					paramArr.push(ruleId + "|" + obj.item[i].AN + "|" + obj.item[i].DN);
				}
				
				addMapping(paramArr);		// mapping 추가
			}
		} else {
	 		var dataObj = $.parseJSON(data);
	 		mappingCode = dataObj.item[0].AN;
	 		$("#hidMaapingCodeName").val(dataObj.item[0].DN);
	 		$("#mappingCodeName").val(CFN_GetDicInfo(dataObj.item[0].DN));
		}
	}
	// 선택 팝업(담당업무) 콜백
	parent.JFlistSchema = setobjTxtSelect;
 	function setobjTxtSelect(data) {
 		if(data == "") {
 			mappingCode = "";
 			$("#hidMaapingCodeName").val("");
 			$("#mappingCodeName").val("");
 		}else{
			var dataArr = data.split("@");
			mappingCode = dataArr[0];
			$("#hidMaapingCodeName").val(dataArr[1]);
			$("#mappingCodeName").val(CFN_GetDicInfo(dataArr[1]));
 		}
 	}
 	
	// mapping 추가
	function addMapping(paramArr) {
		$.ajax({
			type:"POST",
			data:{
				"paramArr" : paramArr
			},
			url:"insertMapping.do",
			success:function (data) {
				if (data.result == "ok") {
					makeHtml();		// mapping 팝업 html 생성
					parent.searchList();
					if ($("#rankPopup_if", parent.document).length > 0) {
						$("#rankPopup_if", parent.document)[0].contentWindow.closeLayer();
				    }
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertMapping.do", response, status, error);
			}
		});	
	}
	
	// 추가 버튼
	function addClick() {
		if (mode == "MappingNames") {
			if (ruleType == 2) {
				parent.Common.open("","rankPopup","<spring:message code='Cache.lbl_CateMng'/>|||<spring:message code='Cache.lbl_apv_jobposition'/>","/approval/manage/getRankPopup.do?dnId="+dnId+"&ruleId="+ruleId,"550px","325px","iframe",true,null,null,true);
			} else {
				parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=C9","1060px","580px","iframe",true,null,null,true);
			}
		} else {
			if (axf.isEmpty($("#ruleName").val())) {
	            Common.Warning("<spring:message code='Cache.msg_apv_016' />"); // "명칭을 입력하여 주십시오."
	            return false;
        	}
			
			Common.Confirm("<spring:message code='Cache.msg_RURegist'/>", "Confirmation Dialog", function (confirmResult) {
 				if (confirmResult) {
					$.ajax({
						type : "POST",
						data : {
							"entCode" : entCode,
							"ruleName" : $("#ruleName").val(),
							"ruleType" : $('input:radio[name="ruleType"]:checked').val(),
							"mappingCode" : mappingCode
						},
						url : 'insertMasterManagement.do',
						success:function (data) {
							if(data.result == "ok") {
								Common.Close();
								parent.searchList();
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("insertMasterManagement.do", response, status, error);
						}
					});
				} else {
 					return false;
				}
			});
		}
	}

	// 수정 버튼
	function updClick() {
		if (axf.isEmpty($("#ruleName").val())) {
            Common.Warning("<spring:message code='Cache.msg_apv_016' />"); // "명칭을 입력하여 주십시오."
            return false;
    	}
		
		Common.Confirm("<spring:message code='Cache.msg_apv_294'/>", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : {
						"ruleId" : ruleId,
						"ruleName" : $("#ruleName").val(),
						"ruleType" : $('input:radio[name="ruleType"]:checked').val(),
						"mappingCode" : mappingCode
					},
					url : 'updateMasterManagement.do',
					success:function (data) {
						if(data.result == "ok") {
							Common.Close();
							parent.searchList();
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("updateMasterManagement.do", response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
	
	// 삭제 버튼
	function delClick() {
		var url = "";
		var params = new Object();
		if (mode == "RuleName") {
			url = 'deleteMasterManagement.do';
			params.ruleId = ruleId;
		} else {
			url = 'deleteMapping.do';
			
			var paramArr = new Array();
			$("input[name='mappingCheckbox']:checked").each(function () {
				paramArr.push(parseInt($(this).val()));
			});
			if(paramArr.length == 0){
				Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); // 선택된 항목이 없습니다
				return false;
			}
			params.paramArr = paramArr;
		}
		
		Common.Confirm("<spring:message code='Cache.msg_apv_093'/>", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : url,
					success:function (data) {
						if(data.result == "ok") {
							if (mode == "RuleName") {
								Common.Close();
								parent.searchList();
							} else {
								makeHtml();		// mapping 팝업 html 생성
								parent.searchList();
							}					
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
	
	// 팝업 닫기
	function closeLayer() {
		Common.Close();
		//parent.searchList();
	}
</script>
<form>
	<div class="sadmin_pop">
		<div id="tableDiv1" style="display:none;">
			<table class="sadmin_table sa_menuBasicSetting mb20" >
			  <tbody>		  
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.lbl_apv_Name'/></th>
				  <td><input id="ruleName" name="ruleName" class="" type="text" maxlength="64" style="width:200px;"/></td>
			    </tr>			    
			    <tr>
			      <th style="width:150px;"><spring:message code='Cache.lbl_apv_gubun'/></th>
				  <td>
				  	  <span class="radioStyle04 size" style="display:block;height:20px;">
				  	  	<input type="radio" id="ruleType0" name="ruleType" value="0"><label for="ruleType0"><span><span></span></span><spring:message code='Cache.lbl_apv_teamleader'/></label>
				  	  </span>
				  	  <span class="radioStyle04 size" style="display:block;height:20px;">
				  	  	<input type="radio" id="ruleType1" name="ruleType" value="1"><label for="ruleType1"><span><span></span></span><spring:message code='Cache.lbl_apv_headdepartment'/></label>
				  	  </span>
				  	  <span class="radioStyle04 size" style="display:block;height:20px;">
				  	  	<input type="radio" id="ruleType2" name="ruleType" value="2"><label for="ruleType2"><span><span></span></span><spring:message code='Cache.lbl_apv_jobposition'/></label>
				  	  </span>
				  	  <span class="radioStyle04 size" style="display:block;height:20px;">
				  	  	<input type="radio" id="ruleType3" name="ruleType" value="3"><label for="ruleType3"><span><span></span></span><spring:message code='Cache.lbl_apv_people'/></label>
				  	  </span>
				  	  <span class="radioStyle04 size" style="display:block;height:20px;">
				  	  	<input type="radio" id="ruleType4" name="ruleType" value="4"><label for="ruleType4"><span><span></span></span><spring:message code='Cache.lbl_apv_dept'/></label>
				  	  </span>
				  	  <span class="radioStyle04 size" style="display:block;height:20px;">
				  	  	<input type="radio" id="ruleType5" name="ruleType" value="5"><label for="ruleType5"><span><span></span></span><spring:message code='Cache.lbl_apv_rule03'/></label>
				  	  </span>
				  	  <span class="radioStyle04 size" style="display:block;height:20px;">
				  	  	<input type="radio" id="ruleType6" name="ruleType" value="6"><label for="ruleType6"><span><span></span></span><spring:message code='Cache.btn_apv_chargebiz'/></label>
				  	  </span>
				  </td>
			    </tr>
				<tr id="mappingCodeTr" style="display:none;">
			      <th style="width:150px;"><spring:message code='Cache.mapping'/></th>
				  <td id="mappingCodeTd">
				  	<input id="mappingCodeName" name="mappingCodeName" readonly="readonly" type="text" class="" maxlength="64" style="width:200px;"/>
				  	<a href="#" id="mappingCodeBtn" class="btnTypeDefault" onclick="selectBtnPopup(); return false;"><spring:message code='Cache.lbl_apv_selection'/></a>
				  	<input id="hidMaapingCodeName" name="hidMaapingCodeName" type="hidden" class="" maxlength="64" />
				  	<span id="mappingText"></span>
				  </td>
			    </tr>
		      </tbody>
			</table>
		</div>
		<div class="" id="tableDiv2" style="display:none;height:235px;overflow-y:auto">
		</div>
		<div class="bottomBtnWrap">
			<a id="addBtn" href="#" class="btnTypeDefault btnTypeBg" onclick="addClick();" ><spring:message code="Cache.btn_apv_add"/></a>
			<a id="updBtn" href="#" class="btnTypeDefault btnTypeBg" onclick="updClick();" ><spring:message code="Cache.btn_apv_update"/></a>
			<a id="delBtn" href="#" class="btnTypeDefault" onclick="delClick();"><spring:message code="Cache.btn_apv_delete"/></a>
			<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
		</div>
	</div>
</form>