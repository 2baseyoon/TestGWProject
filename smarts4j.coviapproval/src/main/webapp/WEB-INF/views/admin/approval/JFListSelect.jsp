<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var functionName = CFN_GetQueryString("functionName");
	
	$(document).ready(function(){	;	
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
			url:"/approval/admin/getJobFunctionList.do",
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
				CFN_ErrorAjax("/approval/admin/getJobFunctionList.do", response, status, error);
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
		$(parent.objTxtSelect).val("");
		//parent.Common.Close("divSchema");
	}
	
</script>
<form id="JFListSelect" name="JFListSelect">
    <div class="pop_body_c">
        <div class="write">
            <!-- 일반 div 시작 -->
            <div>
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
		                <td>
                            <input type="button" class="AXButton" onclick="javascript:delValue();" value="<spring:message code='Cache.btn_JFdelete' />"/>
                        </td>
                    </tr>
					<tr>
                        <td style="PADDING-TOP: 10px">
                            <img align="absMiddle" alt="" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif" />
                            <input id="multi" name="multi" type="checkbox" /><font color="#992300"><spring:message code='Cache.lbl_apv_ifselect_dscr' /></font>
                        </td>
                    </tr>
                </table>               
                <table class="AXFormTable" border="0" cellpadding="0" cellspacing="0" width="100%" >
                    <tr>
                        <td id="JFList" height="100%" valign="top" width="100%">
                            <table id="GetRootGroup" border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" class="t_back_table3">
                            
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</form>