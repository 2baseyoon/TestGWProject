<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_deptdocmove"/></span> <!-- 부서 문서 이관 -->
	</h2>
</div>
<div class="cRContBottom mScrollVH">
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="btnFormAdd" class="btnTypeDefault" href="#" onclick="docMove();" style=""><spring:message code="Cache.lbl_rundocmgr"/></a>
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div style="" class="tblList tblCont">
			<div>
				<table>
					<colgroup>
						<col style="width:50%"/>
						<col/>
						<col style="width:50%"/>
					</colgroup> 
			        <tr>
			            <td valign="top">
			                <h3 style="font-size:16px;"><spring:message code="Cache.lbl_selectfromdeptdocmgr"/></h3> <!-- 이관 부서 선택 -->
			                <div style="height:150px; padding: 20px 20px; border: 1px solid #d9d9d9; margin-top:10px; line-height: 30px;">
			                    <a href="#" class="btnTypeDefault" onclick="OrgMap_Open(1);"><spring:message code="Cache.lbl_fromdeptdocmgr"/></a>
			                    &nbsp;
			                    <span id="SOURCE_DEPT_ROW"></span>
			                    &nbsp;&nbsp;&nbsp;&nbsp;
			                    <span class="chkStyle01"><input type="checkbox" id="checkNotFoundCase" onclick="checkNotFoundCase_click(event);"><label for="checkNotFoundCase"><span></span><spring:message code="Cache.lbl_apv_deleted_dept"/></label></span>
			                    <div id="divInputDivision"  style="display:none;margin-top:10px;">
			                    	<span class="thstar">* <spring:message code="Cache.msg_apv_273"/></span> <!--부서가 삭제되어 검색이 되지 않을 경우 해당 부서의 코드를 직접 입력하십시오.-->
			                    	<br/>
			                    	<spring:message code="Cache.lbl_apv_DeptCode"/> <!-- 부서코드 -->
									&nbsp;:&nbsp;
									<input type="text" id="SOURCE_DEPT_CODE" class=""/>
								</div>
			                </div>
			            </td>
			            <td style="padding: 30px 10px 0;">
			            	<div style="background: url('/HtmlSite/smarts4j_n/covicore/resources/images/covision/zadmin/ico_collection.gif') -3px -393px; width: 18px;height: 40px;"></div>
			            </td>
			            <td valign="top">
			                <h3 style="font-size:16px;"><spring:message code="Cache.lbl_apv_SelectToDeptDocMgr"/></h3>
			                <div style=" height:150px; padding: 20px 20px; border: 1px solid #d9d9d9; margin-top:10px;line-height: 30px;">
			                    <a href="#" class="btnTypeDefault" onclick="OrgMap_Open(2);"><spring:message code="Cache.lbl_apv_ToDeptDocMgr"/></a>
			                    &nbsp;
			                    <span id="DEST_DEPT"></span>
			                </div>
			            </td>
			        </tr>
			    </table>
			</div>
		    <div class="collabo_help">
				<p><spring:message code='Cache.msg_apv_274'/></p>
				<!--'이관될 부서'의 부서함에서 완료된 문서에 한해서 모든 문서가 '이관 부서'의 부서함으로 이동이 됩니다.<br />
		              이관을 실행하면 복구는 되지 않으므로 주의를 요하며 '이관될 부서'에서 진행중인 문서는 모두 완료 시킨 후 실행하여 주십시오.-->
			</div>
		</div>
		<input type="hidden" id="DEST_DEPT_CODE" value="" />
    	<input type="hidden" id="DEST_DEPT_NAME" value="" />   
    	<input type="hidden" id="hidden_useAuthority_val" value=""/>
	</div>
</div>
<script type="text/javascript">
	var objPopup;
	var flag = 0;
	
	$('.collabo_help02 .help_ico').on('click', function(){
		if($(this).hasClass('active')){
			$(this).removeClass('active');
		}else {
			$(this).addClass('active')
		}
	});
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	//조직도띄우기
	function OrgMap_Open(mapflag){
		flag = mapflag;
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=C1","1060px","580px","iframe",true,null,null,true); 
	}
	
	//조직도선택후처리관련
	var peopleObj = {};
	parent._CallBackMethod2 = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){		
		var dataObj = $.parseJSON(peopleValue);			
		if(dataObj.item.length > 0){
			if(flag==1){					
				$("#SOURCE_DEPT_ROW").empty();
				$("#SOURCE_DEPT_CODE").val(dataObj.item[0].AN);					
				setSOURCE_DEPT(CFN_GetDicInfo(dataObj.item[0].DN));			
			}else if(flag==2){			
				$("#DEST_DEPT").html("<b>"+CFN_GetDicInfo(dataObj.item[0].DN)+"</b>"); 
				$("#DEST_DEPT_CODE").val(dataObj.item[0].AN);
				$("#DEST_DEPT_NAME").val(CFN_GetDicInfo(dataObj.item[0].DN));		
			}
		}else{
		}
	}

	
    //보이기 안보이기 
    function checkNotFoundCase_click(event) {
        if (event.srcElement.checked == true) {
            //$('#divInputDivision').attr('style', "visibility:visible");
            $('#divInputDivision').show();
        }
        else {
            //$('#divInputDivision').attr('style', "visibility:hidden");
            $('#divInputDivision').hide();
        }

    }
    
    function setSOURCE_DEPT(paramSOURCE_DEPT_NAME){
    	var SOURCE_DEPT_CODE = $("#SOURCE_DEPT_CODE").val();	 
		//호출
		$.ajax({
			type:"POST",
			data:{
				"SOURCE_DEPT_CODE" : SOURCE_DEPT_CODE
			},
			url:"/approval/manage/getDeptDocTransferCount.do",
			success:function (data) {
				if(data.result == "ok")					
					$("#SOURCE_DEPT_ROW").empty();					
					$("#SOURCE_DEPT_ROW").append("<b><span id='SOURCE_DEPT'>"+paramSOURCE_DEPT_NAME+"</span>&nbsp;(<spring:message code='Cache.lbl_apv_transferred_doc'/> : <span id='SOURCE_DEPT_COUNT'>"+data.cnt
							+"</span><spring:message code='Cache.lbl_DocCount'/>)</b>");
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/getDeptDocTransferCount.do", response, status, error);
			}
		});
    }
    
    function docMove(){
    	 if (document.getElementById("SOURCE_DEPT_CODE").value == "") {
             Common.Warning("<spring:message code='Cache.msg_241' />"); //이관부서를 선택하세요.
             return;
         }


         if (document.getElementById("DEST_DEPT_CODE").value == "") {
        	 Common.Warning("<spring:message code='Cache.msg_242' />"); //이관될 부서를 선택하세요.
             return;
         }
         
         Common.Confirm("<spring:message code='Cache.msg_240' />", "Confirmation Dialog", function(result){	//이관을 실행하면 복구는 불가능 합니다. \r 그래도 실행 하시겠습니까?
        		if(result){
        			var SOURCE_DEPT_CODE = $("#SOURCE_DEPT_CODE").val();
        			var DEST_DEPT_CODE   = $("#DEST_DEPT_CODE").val();
        			var DEST_DEPT_NAME   = $("#DEST_DEPT_NAME").val();
        			
        			$.ajax({
        				type:"POST",
        				data:{
        					"SOURCE_DEPT_CODE" : SOURCE_DEPT_CODE,
        					"DEST_DEPT_CODE" : DEST_DEPT_CODE,
        					"DEST_DEPT_NAME" : DEST_DEPT_NAME
        				},
        				url:"/approval/manage/transferDeptDoc.do",
        				success:function (data) {
        					if(data.result=="ok"){
        						//정상처리
        						Common.Inform("<spring:message code='Cache.msg_ProcessOk' />");
        						Refresh();
        					}
        				},
        				error:function(response, status, error){
        					CFN_ErrorAjax("/approval/manage/transferDeptDoc.do", response, status, error);
        				}
        			});
        		}
        	});
    }
    
</script>