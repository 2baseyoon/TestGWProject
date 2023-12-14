<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%
	String strdomainID = StringUtil.replaceNull(request.getParameter("domainID"),"");
%>
	
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	/*var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramJobFunctionID =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가
*/
	var _strdomainID = "<%=strdomainID%>";
	$(document).ready(function(){
		getDocclass();
				
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	
	var myTree01 = new coviTree();
	var Treebody = {
			onclick:function(){
				//onclickTree();				
			},
			ondblclick:function(){
			},
			oncheck:function(idx, item){ //[Function] 트리 체크박스클릭시 함수연결
				saveSubmit();
			}
	};
	
	function getDocclass(){
    	var EntCode = _strdomainID;
		//호출
		$.ajax({
			type:"POST",
			async:false,
			data:{
				"EntCode" : EntCode
			},
			url:"/approval/admin/getFolderPopup.do",
			success:function (data) {			
				if(data.result == "ok"){
					if(data.list.length > 0){
						myTree01.setTreeList("coviTreeTarget01", data.list, "nodeName", "220", "left", false, true, Treebody);					
						//myTree01.setTreeList("coviTreeTarget01", data.list, "nodeName", "220", "left", false, true);
						/* if(Object.keys(data.list).length > 0){
							//$("#hidExistRootFolder").val("true");//루트폴더가있을경우
						}else{
							//$("#hidExistRootFolder").val("false");//루트폴더가없을경우
						} */

						//트리 모두확장
						myTree01.expandAll();
						
						$(".AXTreeScrollBody").css("border", "none");
					}else{
						$("#coviTreeTarget01").html("<p style='text-align: center;margin: 10px;margin-top: 50px;'><spring:message code='Cache.msg_EmptyData'/></p>");
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("admin/getTopFolder.do", response, status, error);
			}
		});
    }
	
	function saveSubmit(){
		var treeObj= myTree01.getCheckedTreeList("radio");			
		var id = treeObj[0].no;
		var name =treeObj[0].nodeName;
		opener.document.getElementById("DocClassID").value  = id;
		opener.document.getElementById("DocClassName").value = name;
	}
	
</script>
<form id="DocTreePop" name="DocTreePop">
	<div>
		<div style="height: 375px; overflow: auto; margin: 20px; border: 1px solid #b1b1b1;">
			<div id="coviTreeTarget01"></div>
		</div>
		<div align="center">
			<input type="button" value="<spring:message code='Cache.msg_Confirmation_Dialog'/>" onclick="closeLayer();" class="AXButton" />			
			<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
	<input type="hidden" id="SeqHiddenValue" value="" />
	<input type="hidden" id="EntCode" value="" />
</form>