<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var paramEntCode =param[0].split('=')[1];
	var paramParentDocClassID =  param[1].split('=')[1];
	var paramClassName =  param[2].split('=')[1];
	paramClassName = decodeURIComponent(paramClassName);
	paramParentDocClassID = decodeURIComponent(paramParentDocClassID);
	var doublecheck = false;
	
	var flag = 2;  //falg 0=권한사용자선택 falg 1=피권한사용자추가

	$(document).ready(function(){		
		$("#ParentDocClassID").val(paramParentDocClassID);
		$("#EntCode").val(paramEntCode);
		$("#upperFolder").val(paramClassName);
		
		$(document).on("keyup", "input:text[InputMode]", function() {
			if($(this).attr('InputMode')=="Numberic"){
				$(this).val( $(this).val().replace(/[^0-9]/gi,"") );
				var max = parseInt($(this).attr('num_max'));
			    var min = parseInt($(this).attr('num_min'));
			    if ($(this).val() > max)
			    {
			        $(this).val(max);
			    }
			    else if ($(this).val() < min)
			    {
			        $(this).val(min);
			    }   
			}			
		});
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	
	
	
	//저장
	function saveSubmit(){		
		
		var DocClassID = $("#txtFolderID").val();		
		var ParentDocClassID = $("#ParentDocClassID").val();		
		var EntCode = $("#EntCode").val();		
		var ClassName = $("#txtFolderName").val();
		var SortKey = $("#txtFolderOrderBy").val();		
		var KeepYear = $("#ddlKeepYear").val();
		
		if (axf.isEmpty(ClassName)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_295' />"); //폴더명을 입력하세요 
            return false;
        }
        else if (axf.isEmpty(DocClassID)) {
        	parent.Common.Warning("<spring:message code='Cache.msg_apv_folderid' />"); //폴더아이디을 입력하세요 
            return false;
        }
        else if (axf.isEmpty(SortKey)) {
        	parent.Common.Warning("<spring:message code='Cache.msg_apv_297' />"); //정렬순서를 입력하세요  
                return false;
    	}
		
	
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"DocClassID" : DocClassID,
				"ParentDocClassID" : ParentDocClassID,	
				"EntCode" : EntCode,	
				"ClassName" : ClassName,	
				"SortKey" : SortKey,	
				"KeepYear" : KeepYear	
			},
			url:"insertDocFolder.do",
			success:function (data) {
				if(data.result == "ok"){
					parent.Common.Inform(data.message);
					parent.setUseAuthority();
					closeLayer();
				}				
				if(data.result == "overlap"){ //중복					
					parent.Common.Warning("<spring:message code='Cache.msg_apv_335' />");
				}
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertDocFolder.do", response, status, error);
			}
		});
		
	}
	
</script>
<form id="DocFolderManagerSetPopup" name="DocFolderManagerSetPopup">
	<div class="sadmin_pop">
            <table class="sadmin_table sa_menuBasicSetting mb20">
                <colgroup>
                    <col id="t_tit4" width="120px;">
                    <col id="" width="*">
                </colgroup>
                <tbody>
                    <tr>
                        <th style=""><spring:message code="Cache.lbl_apv_Docbox_FolderName"/></th>
                        <td>
                            <span>
                                <input type="text" id="upperFolder" name="upperFolder" disabled="disabled" class="" style="width: 330px;" />
                                <input name="txtFolderName" type="text" maxlength="250" id="txtFolderName" class="" style="width: 330px;" />
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <th><spring:message code="Cache.lbl_apv_Docbox_FolderID"/></th>
                        <td>
                            <input name="txtFolderID" type="text" maxlength="16" id="txtFolderID"  class="" style="width: 330px;" />
                        </td>
                    </tr>
                    <tr>
                        <th><spring:message code="Cache.lbl_apv_Docbox_keepyear"/></th>
                        <td>
                            <select name="ddlKeepYear" id="ddlKeepYear" class="selectType02" style="width: 130px;">
								<option value=""><spring:message code='Cache.lbl_apv_Docbox_keepyear'/></option>
								<option value="<spring:message code='Cache.lbl_apv_year_1'/>"><spring:message code='Cache.lbl_apv_year_1'/></option>
								<option value="<spring:message code='Cache.lbl_apv_year_3'/>"><spring:message code='Cache.lbl_apv_year_3'/></option>
								<option value="<spring:message code='Cache.lbl_apv_year_5'/>"><spring:message code='Cache.lbl_apv_year_5'/></option>
								<option value="<spring:message code='Cache.lbl_apv_year_7'/>"><spring:message code='Cache.lbl_apv_year_7'/></option>
								<option value="<spring:message code='Cache.lbl_apv_year_10'/>"><spring:message code='Cache.lbl_apv_year_10'/></option>
								<option value="<spring:message code='Cache.lbl_apv_permanence'/>"><spring:message code='Cache.lbl_apv_permanence'/></option>
							</select>
                        </td>
                    </tr>
                    <tr>
                        <th><spring:message code="Cache.lbl_apv_Docbox_SortOrder"/></th>
                        <td>
                            <input name="txtFolderOrderBy" type="text" maxlength="9" num_min="1" id="txtFolderOrderBy"  InputMode="Numberic" class="" style="width: 330px;" />
                        </td>
                    </tr>
                </tbody>
            </table>        
            <div class="bottomBtnWrap">
				<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveSubmit();" ><spring:message code="Cache.btn_apv_save"/></a>
				<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.lbl_apv_close"/></a>
			</div>
				        
        </div>

        <input type="hidden" name="EntCode" id="EntCode" />        
        <input type="hidden" name="ParentDocClassID" id="ParentDocClassID" />
     
</form>