<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">문서분류관리</span>	
</h3>
<form id="form1">
<input type="hidden" id="hidExistRootFolder" name="hidExistRootFolder" value="false"/>
<div style="width:100%;min-height: 800px">
    <div id="topitembar02" class="topbar_grid">
		<input type="button" class="AXButton BtnRefresh" value="<spring:message code='Cache.btn_apv_refresh'/>" onclick="Refresh();"/>				
		<select  name="selectDdlCompany" class="AXSelect" id="selectDdlCompany"></select>			
		<input type="button" class="AXButton"  value="<spring:message code='Cache.btn_apv_Docbox_AddFolder'/>" onclick="addDocclass(true);"/>				
	</div>
    <!-- 문서분류코드 CRUD 시작 -->
    <div id="DocboxFolderEdit" style="float: left; width: 100% ;min-height: 800px">
    	<table>
			<tr>
				<td style="width:45% ;"> 
					<div>
						<div id="coviTreeTarget01" style="height:500px;"></div>					
					</div>
				</td>
				<td style="width: 5% ;">
					
				</td>
				<td style="width: 50% ;vertical-align: top;">
					<div>
						<div>
							<div align="center">
	            				<table class="AXFormTable" style="width:100%; margin-bottom: 10px;">               
	                				<tbody>
	                    				<tr>
	                        				<th style="width:100px"><spring:message code="Cache.lbl_apv_Docbox_FolderName"/></th>
	                        				<td>
	                            				<span>
	                                				<input type="text" id="upperFolder" name="upperFolder" disabled="disabled"  style="display:none; width:330px;" />
	                                				<input name="txtFolderName" type="text" maxlength="250" id="txtFolderName" style="width:99%;" />
	                            				</span>
	                        				</td>
	                    				</tr>
	                    				<tr>
	                        				<th><spring:message code="Cache.lbl_apv_Docbox_FolderID"/></th>
		                        			<td>
	                            				<input name="txtFolderID" type="text" maxlength="16" id="txtFolderID"   disabled="disabled"  style="width:99%;" />
	                        				</td>
	                    				</tr>
	                    				<tr>
	                        				<th><spring:message code="Cache.lbl_apv_Docbox_keepyear"/></th>
	                        				<td>
	                            				<select name="ddlKeepYear" id="ddlKeepYear" style="width: 130px; height: 26px;">
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
					                            <input name="txtFolderOrderBy" type="text" maxlength="9" num_min="1" id="txtFolderOrderBy" InputMode="Numberic" style="width:99%;" />                                                       
					                        </td>
					                    </tr>
					                </tbody>
					            </table>   
                			</div>
                			<div class="pop_btn2" align="center">
	                           	<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton" />							
								<input type="button" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();"  class="AXButton" />
                			</div>
                		</div>           
        			</div>
       			</td>
    		</tr>
 		</table>
  	</div>
</div>
        <!-- 컨텐츠 끝 -->	
</form>

<script type="text/javascript">

	var objPopup;
	var flag = 0;
	var obj = new Object();
	var myTree01 = new coviTree();
	
	initDocFolderManager();
	
	function initDocFolderManager(){
		setSelect();
		setUseAuthority();
		
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
	}
	
	// 트리클릭시
	function onclickTree(){
		var obj = myTree01.getSelectedList();
	
		var EntCode = $("#selectDdlCompany").val();
		var DocClassID = obj.item.no;
		
		//호출
		$.ajax({
			type:"POST",
			data:{
				"EntCode" : EntCode,
				"DocClassID" : DocClassID
			},
			url:"/approval/admin/getDocFolderData.do",
			success:function (data) {
				if(data.result == "ok"){
					$("#txtFolderName").val(data.map[0].nodeName);
					$("#txtFolderID").val(data.map[0].no);
					$("#ddlKeepYear").val(data.map[0].KeepYear).prop("selected", true);
					$("#txtFolderOrderBy").val(data.map[0].SortKey);
				}			
					
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/admin/getDocFolderData.do", response, status, error);
			}
		});
		
	} 
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	// Select box 바인드
	function setSelect(){
		$("#selectDdlCompany").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListAssignData.do",			
			ajaxAsync:false,
			onchange: function(){
				setUseAuthority();
			}
		});
		
		//보존년한selectbind
		$("#ddlKeepYear").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
	}
	// 문서분류root변경시
	function setUseAuthority(){		
		getDocclass();
		
		//상세초기화
		$("#txtFolderName").val("");
		$("#txtFolderID").val("");
		$("#ddlKeepYear").val("");		
		$("#txtFolderOrderBy").val("");
	}

	
	var Treebody = {

			onclick:function(){
				onclickTree();
			
			},
			ondblclick:function(){
			}

	};
	
    function getDocclass(){
    	var EntCode = $("#selectDdlCompany").val();	 
		//호출
		$.ajax({
			type:"POST",
			data:{
				"EntCode" : EntCode
			},
			url:"/approval/admin/getTopFolder.do",
			success:function (data) {			
				if(data.result == "ok"){					
					myTree01.setTreeList("coviTreeTarget01", data.list, "nodeName", "220", "left", false, false,Treebody);					
					if(Object.keys(data.list).length > 0){
						$("#hidExistRootFolder").val("true");//루트폴더가있을경우
						//트리 모두확장
						myTree01.expandAll();						
					}else{
						$("#hidExistRootFolder").val("false");//루트폴더가없을경우
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/admin/getTopFolder.do", response, status, error);
			}
		});
    }

 	// 하위폴더추가 버튼에 대한 레이어 팝업
	function addDocclass(pModal){
		//하위폴더 추가하기
		var obj = myTree01.getSelectedList();
		
	    var paramEntCode = $("#selectDdlCompany").val();
	   
	    if (paramEntCode == "") {
	        Common.Warning("<spring:message code='Cache.msg_Company_07' />");
	    } else {
	        var sPopTitle = "<spring:message code='Cache.btn_apv_Docbox_AddFolder'/>";	        
	        //최상위 폴더 없을때 check!!	      
	        if ($("#hidExistRootFolder").val() == "false") {	        	
	        	Common.Inform("<spring:message code='Cache.msg_apv_RootFolder' />");
	            sPopTitle = "<spring:message code='Cache.lbl_apv_createRootFolder'/>";
	        }else {
	            if ($("#txtFolderID").val() == "") {
	                Common.Warning("<spring:message code='Cache.msg_apv_299' />");  //상위폴더가 선택되지 않았습니다. 상위폴더를 선택후 추가해주세요  msg_apv_299
	                return;
	            }
	        }
	       
	        var paramDocClassID = "";
	        var paramClassName = "";
	      
	        
		    if(!obj.error){		    	
		    	if(!axf.isEmpty(obj.item)){
			    	paramDocClassID = obj.item.no;
			    	paramClassName = encodeURIComponent(obj.item.nodeName);
		    	}
			}	       	
			objPopup = parent.Common.open("","addDocclass",sPopTitle,"/approval/admin/goDocFolderManagerSetPopup.do?paramEntCode="+paramEntCode+"&paramDocClassID="+paramDocClassID+"&paramClassName="+paramClassName,"550px","250px","iframe",pModal,null,null,true);
			
	    }
	}
    
 	 //저장
	function saveSubmit(){
		var DocClassID = $("#txtFolderID").val();
		var EntCode = $("#selectDdlCompany").val();		
		var ClassName = $("#txtFolderName").val();
		var SortKey = $("#txtFolderOrderBy").val();		
		var KeepYear = $("#ddlKeepYear").val();	
		
		
		if(axf.isEmpty(DocClassID)){
			Common.Warning("<spring:message code='Cache.msg_325' />"); // 변경할 폴더를 선택하세요.
			return;
		}
		
		if (axf.isEmpty(ClassName)) {
			Common.Warning("<spring:message code='Cache.msg_apv_295' />"); //폴더명을 입력하세요 
			return false;
		}
		else if (axf.isEmpty(DocClassID)) {
			Common.Warning("<spring:message code='Cache.msg_apv_folderid' />"); //폴더아이디을 입력하세요 
			return false;
		}
		else if (axf.isEmpty(SortKey)) {
			Common.Warning("<spring:message code='Cache.msg_apv_297' />"); //정렬순서를 입력하세요  
			return false;
		}else{
			Common.Confirm("<spring:message code='Cache.msg_apv_294' />", "Confirmation Dialog", function(result){		//수정하시겠습니까? 
				if(result){
					//insert 호출
					$.ajax({
						type:"POST",
						data:{
							"DocClassID" : DocClassID,
							"EntCode" : EntCode,
							"ClassName" : ClassName,
							"SortKey" : SortKey,
							"KeepYear" : KeepYear
						},
						url:"/approval/admin/updateDocFolder.do",
						success:function (data) {
							if(data.result == "ok"){
								setUseAuthority();
								Common.Inform("<spring:message code='Cache.msg_apv_DeonModify' />");
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/approval/admin/updateDocFolder.do", response, status, error);
						}
					});
				}
			});
		}
	}
 	 
	 //삭제
	function deleteSubmit(){	
		if(axf.isEmpty($("#txtFolderID").val())){
			Common.Warning("<spring:message code='Cache.msg_apv_3003' />");
			return;
		}
		
		Common.Confirm($("#txtFolderID").val()+"<spring:message code='Cache.msg_apv_301' />", "Confirmation Dialog", function(result){
			if(!result){
				return;
			}else{
				var DocClassID = $("#txtFolderID").val();
				var EntCode = $("#selectDdlCompany").val();		
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"DocClassID" : DocClassID,				
						"EntCode" : EntCode
					},
					url:"/approval/admin/deleteDocFolder.do",
					success:function (data) {
						if(data.result == "ok"){
							setUseAuthority();
							Common.Inform("<spring:message code='Cache.msg_apv_138' />");
						}else if(data.result == "RetrieveFolder"){
							Common.Warning("<spring:message code='Cache.msg_apv_existFolder' />");								
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/admin/deleteDocFolder.do", response, status, error);
					}
				});
			}
		});
		
		
	}
	
</script>