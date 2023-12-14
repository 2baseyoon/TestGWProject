<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	$(document).ready(function(){
		setEntList();
	});
	
	function setOldData(){
		var orgData = Base64.b64_to_utf8("${param.EntDocObj}");
		if(!axf.isEmpty(orgData)){
			$(JSON.parse(orgData)).each(function(i, item){
				$("#"+item.EntCode).val(item.docClassName)
				$("#"+item.EntCode).attr("data",JSON.stringify(item));
			});
		}
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
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
						+ "<td><input type='checkbox' value='"+data.list[i].optionValue+"'></td>"
						+ "<td class='t_back01_line'>"+data.list[i].optionText+"</td>"
						+ "<td class='t_back01_line'><input name='"+data.list[i].optionValue+"' id='"+data.list[i].optionValue+"' type='text' json-value='true' readOnly></td>"
						+ "<td class='t_back01_line'><input type='button' class='AXButton' onclick=\"OpenDocClass('"+data.list[i].optionValue+"', '"+data.list[i].optionText+"');\" value=\"<spring:message code='Cache.lbl_selection' />\"/></td>"
						+ "</tr>";
					$("#tblList").append(html);
				}
				
				setOldData();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/common/getEntInfoListDefaultData.do", response, status, error);
			}
		});	
		
	}

	function OpenDocClass(domainCode, domainName) {
        var sUrl = "/approval/manage/goDocTreePop.do?domainCode="+domainCode+"&openType=manager&EntName="+Base64.utf8_to_b64(domainName);
        var iWidth = 670; var iHeight = 562; var sSize = "fix";
        parent.Common.open("","DocClassTreePop", domainName+" <spring:message code='Cache.lbl_apv_DocboxFolderMgr' />",sUrl,iWidth,iHeight,"iframe",true,null,null,true); //문서분류관리
	}
	
	parent._CallBackMethod = fnRtnDocClass;
	function fnRtnDocClass(rObj){
	    if(rObj && !axf.isEmpty(rObj)){
		    $("#"+rObj.EntCode).val(rObj.docClassName);
		    $("#"+rObj.EntCode).attr("data",JSON.stringify(rObj));
	    }
	}
	
	function saveSubmit(){
    	var tblListObj = new Array();
    	$("#tblList tr:not(:first)").each(function(i){
    		if(!axf.isEmpty($(this).find("input[type='text']").val()))
    			{  
					var objName = $(this).find("input[type='text']").attr('id');
					tblListObj.push(JSON.parse($(this).find("input[type='text']").attr("data")));
    			}    		
		});
    	
    	parent._CallBackDocClassMethod(tblListObj);
    	Common.Close();
	}
	function deleteData(){
	    $("input[type='checkbox']:checked").each(function(i, item){
			$("#"+item.value).val("");
	    });
	}
</script>
<form id="FormDocClassSet" name="FormDocClassSet">
	<div id="divFormBasicInfo" class="sadmin_pop">
		<div>
			<div class="t_back" style="height:310px;overflow-y:auto;">
				<table id="tblList" class="sadmin_table sa_menuBasicSetting mb20">
					<colgroup>
						<col width="8%">
						<col width="38%">
						<col width="38%">
						<col width="16%">
					</colgroup>
					<tr style="height:35px;">
						<th style='text-align:center;'></th>
						<th style='text-align:center;'><spring:message code='Cache.lbl_CompanyName' /></th><!--회사명-->
						<th style='text-align:center;'><spring:message code='Cache.lbl_SelectedList' /></th><!--선택목록-->
						<th style='text-align:center;'></th>
					</tr>
				</table>
			</div>
			<div class="bottomBtnWrap" >
				<a id="btnSave" class="btnTypeDefault btnTypeBg" onclick="saveSubmit();"><spring:message code='Cache.Cache.btn_Confirm'/></a><!-- 확인 -->
				<a id="btnDelete" style="" class="btnTypeDefault" onclick="deleteData();"><spring:message code='Cache.btn_apv_delete'/></a><!-- 삭제 -->
				<a id="btnClose" class="btnTypeDefault" onclick="closeLayer();"><spring:message code='Cache.btn_apv_close'/></a><!-- 닫기 -->
			</div>
		</div>
	</div>
</form>