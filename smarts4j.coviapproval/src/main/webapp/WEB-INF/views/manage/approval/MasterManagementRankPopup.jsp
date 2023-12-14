<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var dnId = param[0].split('=')[1];
	var ruleId = param[1].split('=')[1];
	
	$(document).ready(function() {
		init();		// 초기화
	});

	// 초기화
	function init() {
		makeHtml();		// mapping 팝업 html 생성
	}
	
	// mapping 팝업 html 생성
	function makeHtml() {
		$.ajax({
			type:"POST",
			data:{
				"dnId" : dnId
			},
			url:"getRankList.do",
			success:function (data) {
				if(data.result == "ok") {
					var list = data.list;
					
					$("#tableDiv").empty();
					
					var html = "<table class=\"sadmin_table sa_menuBasicSetting mb20\" >";
					html += "<tbody>";
					html += "<tr>";
					html += "<th style=\"width:35px;height:35px;\"></th><th style=\"text-align:center;\"><spring:message code='Cache.lbl_apv_jobposition_name'/></th><th style=\"text-align:center;\"><spring:message code='Cache.lbl_apv_jobposition_code'/></th>";
					html += "</tr>";
					var len = list.length; 
					if (len == 0) {
						html += "<tr>";
						html += "<td colspan=\"3\" style=\"text-align:center;\"><spring:message code='Cache.msg_apv_101'/></td>";
						html += "</tr>";			
					} else {
						for (var i=0; i<len; i++) {
							html += "<tr>";
							html += "<td style=\"text-align:center;\"><input type=\"checkbox\" name=\"mappingCheckbox\" value=\""+list[i].JobPositionID+"\"/></td>";
							html += "<td>"+list[i].JobPositionName+"</td>";
							html += "<td>"+list[i].JobPositionCode+"</td>";
							html += "</tr>";
						}
					}
					html += "</tbody>";
					html += "</table>";
					
					$("#tableDiv").append(html);					
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getRankList.do", response, status, error);
			}
		});
	}
	
	// 추가 버튼
	function addClick() {
		parent.Common.Confirm("<spring:message code='Cache.msg_RUAdd'/>", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var paramArr = new Array();
				
				$("input[name='mappingCheckbox']:checked").each(function () {
					paramArr.push(ruleId + "|" + $(this).parent().parent().find('td:eq(2)').html() + "|" + $(this).parent().parent().find('td:eq(1)').html());
				});
		
				$("#addPopup_if", parent.document)[0].contentWindow.addMapping(paramArr);		// mapping 추가
			} else {
				return false;
			}
		});
	}

	// 팝업 닫기
	function closeLayer() {
		Common.Close();
	}
</script>
<form>
	<div class="sadmin_pop">
		<div id="tableDiv" style="height:235px;overflow-y:auto;">
		</div>
		<div class="bottomBtnWrap">
			<a href="#" id="addBtn" class="btnTypeDefault btnTypeBg" onclick="addClick();" ><spring:message code="Cache.btn_apv_add"/></a>
			<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
		</div>
	</div>
</form>