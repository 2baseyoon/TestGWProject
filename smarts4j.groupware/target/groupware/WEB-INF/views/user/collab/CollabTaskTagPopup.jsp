<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	
	<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104;">
		<div class="" style="overflow:hidden; padding:0;">
			<div class="ATMgt_popup_wrap">
				<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<td class="ATMgt_T_th" >
								<spring:message code='Cache.lbl_Tag'/> <!-- 태그 -->
							</td>
							<td>
								<div class="ATMgt_T"><div class="ATMgt_T_l">
									<input type="text" class="w100 HtmlCheckXSS ScriptCheckXSS Required SpecialCheck MaxSizeCheck" max="50" title="<spring:message code='Cache.lbl_Tag'/> " id="tagName" value=""/>
								</div></div>
							</td>
						</tr>	
					</tbody>	
				</table>
			</div>
			<div class="bottom">
					<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.btn_save'/></a>
					<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
			</div>
		</div>				
	</div>
</body>
<script type="text/javascript">
var collabTaskTag = {
		callbackFunc:CFN_GetQueryString("callBackFunc"),
		objectInit : function(){			
			this.addEvent();
		},
		addEvent : function(){
			
			//태그등록
			$("#btnAdd").on("click", function(e){
				if (!coviUtil.checkValidation("", true, true)) { return false; }			
				
				window.parent.postMessage(
						{ functionName : collabTaskTag.callbackFunc
					    		,params:{"tagid": 0, "TagName": $("#tagName").val()}
					    }
						, '*' 
					);
				Common.Close();	
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
		}	
}

$(document).ready(function(){
	collabTaskTag.objectInit();
});

</script>