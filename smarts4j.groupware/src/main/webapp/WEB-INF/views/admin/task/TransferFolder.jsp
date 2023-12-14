<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.lbl_TransTask'/></span>	 <!-- 업무이관 -->
</h3>
<div class="topbar_grid"> <!--  style="float:right; padding-top: 15px;" -->
   <input type="button" class="AXButton" value="<spring:message code="Cache.lbl_rundocmgr"/>" onclick="taskMove();"/>
</div>    
<div>
	<table>
		<colgroup>
			<col style="width:50%"/>
			<col/>
			<col style="width:50%"/>
		</colgroup>
        <tr>
            <td valign="top">
                <h3><spring:message code='Cache.lbl_trans_sourceUser'/></h3><!--이관 사용자 -->
                <div style="height:180px; padding: 30px 20px; border: 1px solid #d9d9d9; margin-top:10px; line-height: 30px;">
                	<spring:message code='Cache.lbl_User'/>: 
	                <input type="text" class="AXInput" readonly="readonly" id="sourceUserName" />
	                <input type="hidden" id="sourceUserID"/>  <!--이관 사용자 ID  -->
	                <input type="button" id="sourceUserOrgBtn" class="AXButton" value="<spring:message code="Cache.lbl_apv_org"/>" onclick="openOrgChart('sourceUser');"/>
	                &nbsp;&nbsp;&nbsp;
	                <input type="checkbox" id="checkNotFoundCase" onclick="checkNotFoundCase_click();" /><label for="checkNotFoundCase"><spring:message code='Cache.lbl_deleted_user'/></label> <!-- 퇴사자인 경우 -->
	                <br><br><br><br>
	                <div id="divRetiree" style="visibility:hidden;">
	            	   <font color="red">※ <spring:message code='Cache.msg_delete_user'/></font> <!-- 사용자가 퇴사하여 검색이 되지 않을 경우 해당 사용자의 ID를 직접 입력하십시오. -->
	             	   <br>
		               <span><spring:message code="Cache.lbl_apv_user_code"/>&nbsp;:&nbsp;<input type="text" id="deleteUserID" /></span>
	                </div>
                </div>
            </td>
            <td style="padding: 30px 10px 0;"> <!-- padding: 0px 20px; -->
            	<input type="button" class="AXButton" value=">"/>
            </td>
            <td valign="top">
                <h3><spring:message code='Cache.lbl_trans_targetUser'/></h3><!-- 이관받을 사용자 -->
                <div style=" height:180px; padding: 30px 20px; border: 1px solid #d9d9d9; margin-top:10px;line-height: 30px;">
                	<spring:message code='Cache.lbl_User'/>: 
	                <input type="text" class="AXInput" readonly="readonly" id="targetUserName"  />
	                <input type="hidden" id="targetUserID"/> <!--이관받을 사용자 ID  -->
	                <input type="button" class="AXButton" value="<spring:message code="Cache.lbl_apv_org"/>" onclick="openOrgChart('targetUser');"/>
	            </div>
            </td>
        </tr>
    </table>
</div>


<script type="text/javascript">
	//# sourceURL=TransferFolder.jsp
	var objID ='';
	
	//조직도띄우기
	function openOrgChart(pObjID){
		objID = pObjID;
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=callbackFunc&type=A1","540px","580px","iframe",true,null,null,true); //조직도
	}
	
	//조직도선택후처리관련
	function callbackFunc(data){		
		var item =$.parseJSON(data).item; 
		
		if(objID != '' && item.length >=1){
		 	$("#"+objID+"ID").val(item[0].AN);
		 	$("#"+objID+"Name").val(CFN_GetDicInfo(item[0].DN));
		}
	}

	
    //보이기 안보이기 
    function checkNotFoundCase_click() {
        if (event.srcElement.checked == true) {
            $('#divRetiree').attr('style', "visibility:visible");
            $("#sourceUserOrgBtn").attr("disabled",true);
            $("#sourceUserID").val("");
            $("#sourceUserName").val("");
        }
        else {
            $('#divRetiree').attr('style', "visibility:hidden");
            $("#sourceUserOrgBtn").attr("disabled",false);
        }

    }
    
   
    function taskMove(){
    	var sourceUserID;
    	
    	if($("#checkNotFoundCase").prop("checked")){
    		sourceUserID = $("#deleteUserID").val();
    	}else{
    		sourceUserID = $("#sourceUserID").val();
    	}
    	
    	 if (sourceUserID == "") {
             Common.Warning("<spring:message code='Cache.msg_select_sourceUser'/>"); //이관 사용자를 지정하세요
             return;
         }


         if (document.getElementById("targetUserID").value == "") {
        	 Common.Warning("<spring:message code='Cache.msg_select_targetUser'/>"); //이관받을 사용자를 지정하세요.
             return;
         }
         
         Common.Confirm("<spring:message code='Cache.msg_240'/>", "Confirmation Dialog", function(result){	//이관을 실행하면 복구는 불가능 합니다. \r 그래도 실행 하시겠습니까?
        		if(result){
        			$.ajax({
        				type:"POST",
        				data:{
        					"sourceUserID" : sourceUserID,
        					"targetUserID" :  $("#targetUserID").val()
        				},
        				url:"/groupware/task/transferTask.do",
        				success:function (data) {
        					if(data.status=='SUCCESS'){		//정상처리
        						Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information", function(){
	        						location.reload();
        						});
        					}else{
                    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
                    		}
        				},
        				error:function(response, status, error){
        					CFN_ErrorAjax("/groupware/task/transferTask.do", response, status, error);
        				}
        			});
        		}
        	});
    }
    
</script>
