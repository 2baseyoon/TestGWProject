<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var functionName = CFN_GetQueryString("functionName");
	var _selType = CFN_GetQueryString("selType");
	
	$(document).ready(function(){	
		if(_selType == "rule") $("#div_multi").hide();
		setJobFunctionList();	
	});
	
	//양식 관리 -  원본양식파일 선택 리스트
	function setJobFunctionList(){
		var domainID = CFN_GetQueryString("domainID");
		if(domainID === "undefined") domainID = "";
		
		//data 조회
		$.ajax({
			type:"POST",
			data:{		
				sortBy : "InsertDate desc",
				pageNo : "1",
				pageSize : "99999",
				EntCode : domainID
			},
			url:"/approval/manage/getJobFunctionList.do",
			success:function (data) {
				for(var i=0; i<data.list.length; i++){
					var html = "";
					html = "<tr style='cursor:pointer;' onclick=\"javascript:setValue('"+data.list[i].JobFunctionCode+"', '"+data.list[i].JobFunctionName+"')\">"
                    	 + "<td class=\"t_back01_line\" width=\"35%\"><a hef=\"#\">"+CFN_GetDicInfo(data.list[i].JobFunctionName)+"</a></td>"
                    	 + "<td class=\"t_back01_line\" style=\"PADDING-LEFT: 10px\">"+data.list[i].Description+"</td>"
                    	 + "</tr>";                    
                    $("#GetRootGroup").append(html);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/getJobFunctionList.do", response, status, error);
			}
		});	
		
	}
 
	function setValue(szValue, szName) {
        if (document.getElementById("multi").checked) {
            var szCode = "^" + $(parent.objTxtSelect).val();

            if (szCode.indexOf("^" + szValue + "@") > -1) {
            } else {
                if ($(parent.objTxtSelect).val() != "") {
                	$(parent.objTxtSelect).val($(parent.objTxtSelect).val() + "^" + szValue + '@' + szName);
                } else {
                	$(parent.objTxtSelect).val(szValue + '@' + szName);
                }
            }
        } else {
        	var paramData = szValue + '@' + szName;
        	parent[functionName](paramData);
        	
            //parent.objTxtSelect.value = szValue + '@' + szName;
        }

		Common.Close();
        //parent.Common.Close("divSchema");
    }

	function delValue() {
		if(_selType == "rule"){
			parent[functionName]("");
		}else{
			$(parent.objTxtSelect).val("");
		}
		//parent.Common.Close("divSchema");
	}
	
</script>
<form id="JFListSelect" name="JFListSelect">
    <div class="sadmin_pop">
        <div class="">
        	<div style="margin-bottom:5px;">
        		<a href="#" class="btnTypeDefault" onclick="javascript:delValue();"><spring:message code='Cache.btn_JFdelete' /></a>
        	</div>
        	<div style="margin-bottom:5px;" id="div_multi">
        		<span class="chkStyle01"><input type="checkbox" id="multi" name="multi"><label for="multi"><span></span><font color="#992300"><spring:message code='Cache.lbl_apv_ifselect_dscr' /></font></label></span>
        	</div>
            <!-- 일반 div 시작 -->
            <div style="height:255px;width:100%;overflow-y:auto;">
                <table id="GetRootGroup" class="sadmin_table sa_menuBasicSetting mb20">
                </table>
            </div>
        </div>
    </div>
</form>