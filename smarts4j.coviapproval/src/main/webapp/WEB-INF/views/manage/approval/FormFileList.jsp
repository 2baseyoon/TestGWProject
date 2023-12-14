<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script>
	var mode = CFN_GetQueryString("mode");
	var SCHEMA_ID = CFN_GetQueryString("id");
	var isSaaS = CFN_GetQueryString("isSaaS");
	var setEntCode = CFN_GetQueryString("setEntCode");

	var objSchemaList = new Object();
	var setFormDomainurl = "/approval/common/getEntInfoListAssignData.do";
	
	$(document).ready(function(){
		if (isSaaS== "Y" && Common.getSession("DN_Code") == "ORGROOT"){
			$("#tr_domainCode").show(); //$("#domainCode").show();
			setFormDomainurl = "/approval/common/getEntInfoListDefaultData.do";
		}
		setFormFileList(setEntCode);
		setFormDomainList();
	});
	
	function setFormDomainList(){
		$("#domainCode").coviCtrl("setSelectOption", setFormDomainurl);
		$("#domainCode").val(setEntCode).prop("selected", true);
	}
	
	//양식 관리 -  원본양식파일 선택 리스트
	function setFormFileList(code){
		//data 조회		
		$.ajax({
			type:"POST",
			data:{
				"domainCode" : code
			},
			url:"getFormFileList.do",
			success:function (data) {
				$("#ltrFormFileList").empty();
				for(var i=0; i<data.list.length; i++){	
					// 공공데모 불필요항목 가리기
					if(1!=1 && location.href.indexOf("gov.covismart.com") > -1) {
						if(data.list[i] == "WF_FORM_DRAFT_V0.html"
							|| data.list[i] == "NEW_WF_OFFICEITEM_V0.html"
							|| data.list[i] == "WF_FORM_DRAFT_HWP_V0.html") {					
							$("#ltrFormFileList").append("<a href=\"javascript:SelFormFile('"+data.list[i]+"')\">"+data.list[i]+"</a><br/>");
						}
					} else {
						$("#ltrFormFileList").append("<a href=\"javascript:SelFormFile('"+data.list[i]+"')\">"+data.list[i]+"</a><br/>");
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getFormFileList.do", response, status, error);
			}
		});	
		
	}
	
	function SelFormFile(FormFile){
		parent._domainCode($("#domainCode").val());
		parent._CallBackMethod3(FormFile);
		Common.Close();
	}
</script>
<form id="form1">
    <div class="sadmin_pop" style="padding:5px;">
        <table class="sadmin_table" style="border:0px;">
        	<tr style="border:0px;display:none;" id="tr_domainCode">
        		<td>
        			<select id="domainCode" name="domainCode" class="selectType02" style="width:100%;" onChange="setFormFileList(this.value)"/>
        		</td>
        	</tr>
        	<tr style="border:0px;">
                <td ID="ltrFormFileList" style="">                  
                </td>
            </tr>
        </table>
    </div>
    </form>
