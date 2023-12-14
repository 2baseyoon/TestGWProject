<!--  
 양식 계약 품의, 수주보고에서 고객사 선택을 위해 사용되는 페이지.
 코비젼 운영서버  커스텀으로 개발
-->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script>

var customerTree = new coviTree();

$(document).ready(function(){
	setTreeData();
});
function treeNode_Click(strParam) {
    document.getElementById("txtPath").value = strParam;
    if (parent.opener != undefined) {
        parent.opener.document.getElementById("Client_NAME").value = strParam; //고객명

    }

    return false;

}

function fnSelect() {

    var strResult = "";


    if (document.getElementById("txtPath").value != "") {
        strResult = document.getElementById("txtPath").value + "|" + document.getElementById("hidFolderID").value;
        window.returnValue = strResult;
        self.close();
        return false;
    }
    else {
        alert('고객명이 선택되지 않았습니다.');
        return false;
    }
}

function fnClose() {

    document.getElementById("txtPath").value = "";
    document.getElementById("hidFolderID").value = "";
    self.close();
}


function setTreeData(){
	$.ajax({
		url:"/approval/legacy/getCustomerData.do",
		type:"POST",
		async:false,
		success:function (data) {
			var List = data.Table;
			customerTree.setTreeList("CustomerNameTree", List, "nodeName", "170", "left", false, false);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("legacy/getCustomerData.do", response, status, error);
		}
	});
	
	customerTree.setConfig({
		body: {
			onclick:function(idx, item){
				treeNode_Click(item.CustomName);
			}
		}
	})
	//openAllTree();			// 트리를 모두 연 상태로 보여줌
}

</script>
<body>
<form id="form1">
<div style="width: 320px;">
  <div>
      <div >
	      <!-- 트리 테두리 테이블 시작 -->
	      <ul style="list-style:none; margin-left: 2px; margin-bottom: 10px;">
	          <li>
	              <div style="overflow: auto;border: 1px solid #d0cece;padding: 10px;width: 220px;height: 250px;">
	                  <div id="CustomerNameTree" style="height:100%;"></div>
	              </div>
	          </li>
	          <li>
	              <p class="pop_tit">
	                  <span class="txt_gn12_t" style="margin-left: 4px;">선택한 고객명</span>
	                  <input type="text" readonly="readonly" ID="txtPath" Width="70%"/></p>
	          </li>
	      </ul>
	      <!-- 트리 테두리 테이블 끝 -->
	       <div align="center">
	           <table>
	               <tr>
	                   <td>
	                       <a href="javascript:fnSelect();"><em><span class="btn_bs2_r"><strong
	                           class="smButton"><spring:message code='Cache.btn_apv_confirm'/></strong></span></em></a> <a href="javascript:fnClose();"><em>
	                           <span><strong class="smButton"><spring:message code='Cache.btn_apv_close'/></strong></span></em></a>
	                   </td>
	               </tr>
	           </table>
	       </div>
       </div>
     </div>
  </div>
  <input type="hidden" ID="hidFolderID" />
  </form>
</body>