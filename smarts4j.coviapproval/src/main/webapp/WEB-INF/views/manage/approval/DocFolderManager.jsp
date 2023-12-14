<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_DocboxFolderMgr"/></span> <!-- 문서분류관리 -->
	</h2>
</div>
<div class="cRContBottom mScrollVH">
	<form id="form1">
		
		<div id="DocboxFolderEdit" class="sadminTreeContent">
			<div class="AXTreeWrap" style="width:40%;">
				<div class="searchBox02" style="margin: 10px 0px -20px 30px;">
					<span>
						<input type="text" id="treeSearchText">
						<button type="button" class="btnSearchType01" id="treeSearchBtn"><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
					</span>
				</div>
				<div id="coviTreeTarget01" class="tblList tblCont" style=""></div>
			</div>
			
			<div class="sadminContent" style="width:60%;">
				<div class="sadminMTopCont">
					<div class="pagingType02 buttonStyleBoxLeft">
						<a class="btnTypeDefault btnPlusAdd" href="#" onclick="addDocclass(true);"><spring:message code="Cache.btn_apv_Docbox_AddFolder"/></a> <!-- 하위폴더생성 -->
						<a style="visibility:hidden;"></a>
					</div>
					<div class="buttonStyleBoxRight">
						<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
					</div>
				</div>
				<div class="tblList tblCont" style="">
         			<table class="sadmin_table" style="margin-top: 0px;">          
          				<colgroup>
							<col width="200px;">
							<col width="*">
						</colgroup>     
              			<tbody>
                  			<tr>
                    			<th style=""><spring:message code="Cache.lbl_apv_Docbox_FolderName"/></th>
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
             		
             		<div class="bottomBtnWrap">
						<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveSubmit();" ><spring:message code="Cache.btn_apv_save"/></a>
						<a href="#" class="btnTypeDefault" onclick="deleteSubmit();"><spring:message code="Cache.btn_apv_delete"/></a>
					</div>             		
					
				</div>
			</div>
			
		</div>
			
	</form>
</div>
<input type="hidden" id="hidExistRootFolder" name="hidExistRootFolder" value="false"/>
<input type="hidden" id="hidden_domain_val" value=""/>



<script type="text/javascript">

	var objPopup;
	var flag = 0;
	var obj = new Object();
	var myTree01 = new coviTree();
	
	initDocFolderManager();
	
	function initDocFolderManager(){
		setControl(); // 초기화
		setTreeConfig(); // 트리 config 셋팅
		setUseAuthority(); // 트리 조회
		
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
	
	function setControl(){ // 초기 셋팅
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
	
		// 트리검색
		$("#treeSearchText").on('keydown', function(event){
			if(event.keyCode === 13){
				event.preventDefault();
				$('#treeSearchBtn').trigger('click');
			}
		});
		$("#treeSearchBtn").on('click', function(){
			var keyword = $("#treeSearchText").val();
			if (keyword == "") return;
			myTree01.findKeyword("nodeName", keyword, true, false);
		});
	}
	
	// 트리클릭시
	function onclickTree(pObj){
		//var obj = myTree01.getSelectedList();
	
		var EntCode = $("#hidden_domain_val").val();
		var DocClassID = pObj.item.no;
		
		//호출
		$.ajax({
			type:"POST",
			data:{
				"EntCode" : EntCode,
				"DocClassID" : DocClassID
			},			
			async:false,
			url:"/approval/manage/getDocFolderData.do",
			success:function (data) {
				if(data.result == "ok"){
					$("#txtFolderName").val(data.map[0].nodeName);
					$("#txtFolderID").val(data.map[0].no);
					$("#ddlKeepYear").val(data.map[0].KeepYear).prop("selected", true);
					$("#txtFolderOrderBy").val(data.map[0].SortKey);
				}			
					
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/getDocFolderData.do", response, status, error);
			}
		});
		
	} 
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	// 트리 config 셋팅
	function setTreeConfig(){
		
    	myTree01.setConfig({
			targetID: "coviTreeTarget01",				// HTML element target ID
			theme: "AXTree_none",
			colGroup: [	{
					key: "nodeName",			// 컬럼에 매치될 item 의 키
					indent: true,				// 들여쓰기 여부
					label: '<spring:message code="Cache.lbl_apv_DocboxFolderMgr"/>',
					width: "220",
					align: "left",
					getIconClass: function(){	return "ic_folder";}
				}],							// tree 헤드 정의 값
			//showConnectionLine: false,	// 점선 여부
			relation: {
				parentKey: "pno",	// 부모 아이디 키
				childKey: "no"	// 자식 아이디 키
			},
			colHead: {display: false},
			body:{
				onclick:function(){
					onclickTree(this);
				},
				ondblclick:function(){
				}
			},
			fitToWidth: true			// 너비에 자동 맞춤
		});
    	
	}
	
	// 트리 조회
	function setUseAuthority(){		
		//상세초기화
		$("#txtFolderName").val("");
		$("#txtFolderID").val("");
		$("#ddlKeepYear").val("");		
		$("#txtFolderOrderBy").val("");
		
		getDocclass();
	}

    function getDocclass(){
    	
    	// get tree list
    	var EntCode = $("#hidden_domain_val").val();
		$.ajax({
			type:"POST",
			data:{
				"EntCode" : EntCode
			},
			url:"/approval/manage/getTopFolder.do",
			success:function (data) {			
				if(data.result == "ok"){					
					//myTree01.setTreeList("coviTreeTarget01", data.list, "nodeName", "220", "left", false, false,Treebody);
					myTree01.setList(data.list);
					if(Object.keys(data.list).length > 0){
						$("#hidExistRootFolder").val("true");//루트폴더가있을경우
						//트리 모두확장
						myTree01.expandAll();
						
						// 선택된 행이 있으면 활성화
						var obj = myTree01.getSelectedList();
						if(!obj.error && !axf.isEmpty(obj.item)) onclickTree(obj);		    	
					    
					}else{
						$("#hidExistRootFolder").val("false");//루트폴더가없을경우
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/getTopFolder.do", response, status, error);
			}
		});
    }

 	// 하위폴더추가 버튼에 대한 레이어 팝업
	function addDocclass(pModal){
		//하위폴더 추가하기
		var obj = myTree01.getSelectedList();
		
	    var paramEntCode = $("#hidden_domain_val").val();
	   
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
			objPopup = parent.Common.open("","addDocclass",sPopTitle,"/approval/manage/goDocFolderManagerSetPopup.do?paramEntCode="+paramEntCode+"&paramDocClassID="+paramDocClassID+"&paramClassName="+paramClassName,"550px","300px","iframe",pModal,null,null,true);
			
	    }
	}
    
 	 //저장
	function saveSubmit(){
		var DocClassID = $("#txtFolderID").val();
		var EntCode = $("#hidden_domain_val").val();		
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
						url:"/approval/manage/updateDocFolder.do",
						success:function (data) {
							if(data.result == "ok"){
								setUseAuthority();
								Common.Inform("<spring:message code='Cache.msg_apv_DeonModify' />");
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/approval/manage/updateDocFolder.do", response, status, error);
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
				var EntCode = $("#hidden_domain_val").val();		
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"DocClassID" : DocClassID,				
						"EntCode" : EntCode
					},
					url:"/approval/manage/deleteDocFolder.do",
					success:function (data) {
						if(data.result == "ok"){
							setUseAuthority();
							Common.Inform("<spring:message code='Cache.msg_apv_138' />");
						}else if(data.result == "RetrieveFolder"){
							Common.Warning("<spring:message code='Cache.msg_apv_existFolder' />");								
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/manage/deleteDocFolder.do", response, status, error);
					}
				});
			}
		});
		
		
	}
	
</script>