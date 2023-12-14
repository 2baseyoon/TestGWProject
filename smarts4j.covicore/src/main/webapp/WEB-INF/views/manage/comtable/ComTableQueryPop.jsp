<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!-- https://github.com/cdnjs/cdnjs/tree/master/ajax/libs/codemirror -->
<!-- https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.39.0/codemirror.min.js -->
<script type="text/javascript" src="/covicore/resources/script/codemirror/5.39.0/codemirror.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/codemirror/5.39.0/mode/xml/xml.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/codemirror/5.39.0/mode/javascript/javascript.min.js<%=resourceVersion%>"></script>
<link rel="stylesheet" type="text/css" href="/covicore/resources/script/codemirror/5.39.0/codemirror.min.css<%=resourceVersion%>">

<style type="text/css">
	.CodeMirror-wrap {
		border: 1px solid #444;
	}
	.txt-mphasis{
		color: red;
		font-weight: bold;
	}
</style>

<script  type="text/javascript">	
	const comTableID = CFN_GetQueryString("id")=="undefined"? "" : CFN_GetQueryString("id");
	const db_vendor = "${dbVendor}";
	var cm_editor;
	
	var companyCode = "";
	var oldNamespace = "";
	var oldQueryId = "";
	var oldQueryIdCnt = "";
	
	$(document).ready(function(){		
		setControl();
	});
	
	// Select box 및 이벤트 바인드 및 데이터로드
	function setControl(){
		
		// 기존쿼리 조회
		$.ajax({
			type:"POST",
			data:{
				"ComTableID" : comTableID				
			},
			url:"getComTableManageData.do",
			async : false,
			success:function (data) {			
				if(data.status == "SUCCESS"){
					if(Object.keys(data.list[0]).length > 0){
						$("#QueryText").val(data.list[0].QueryText);
						companyCode = data.list[0].CompanyCode;
						oldNamespace = data.list[0].QueryNamespace;
						oldQueryId = data.list[0].QueryId;
						oldQueryIdCnt = data.list[0].QueryIdCnt;
					}else{
						Common.Error("<spring:message code='Cache.msg_ComNoData' />","",function(){ // 조회된 데이터가 없습니다.
							closeLayer();
						}); 
					}
				}else {
                    Common.Error(data.message);
                }
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getComTableManageData.do", response, status, error);
			}
		});
		
		// 쿼리작성창 에디터 로드
		var objQuerytxt = document.getElementById("QueryText");
		cm_editor = CodeMirror.fromTextArea(objQuerytxt, {
		  	mode : "xml"
			,lineNumbers: true
		 	,lineWrapping: true
		 	,indentUnit: 4
		 	,indentWithTabs: true
		 	/*
		 	,extraKeys: {
	            "Ctrl-Space": function(){
	              var cursor = cm_editor.getCursor();
	              var token = cm_editor.getTokenTypeAt(cursor);
	                //console.log(token)  
	                if (token == "attribute"){
	                   cm_editor.replaceSelection("=" , "end");
	                }
	            }
	        }
			*/
		});
		cm_editor.setSize("100%","480px");
		cm_editor.on("keyup",function(){
			if(cm_editor.getValue().trim() == "") $("#btn_save").show(); // 빈값인경우 저장 가능
			else $("#btn_save").hide();
		});
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	// 쿼리 샘플 불러오기
	function setSampleQuery(){
		Common.Confirm("<spring:message code='Cache.msg_confirmSampleQuery' />", "", function(result){ // 기존 쿼리가 초기화됩니다. 샘플 쿼리를 로드 하시겠습니까?
			if(result){
				var strSampleQuery = "";	
				
				$.ajax({
					type:"POST",
					data:{},
					url:"getComTableQuerySample.do",
					async : false,
					success:function (data) {			
						if(data.status == "SUCCESS"){		
							strSampleQuery = data.query;
						}else {
		                    Common.Error(data.message);
		                }
					},
					error:function(response, status, error){
						CFN_ErrorAjax("getComTableQuerySample.do", response, status, error);
					}
				});
				
				cm_editor.setValue(strSampleQuery);
				if(strSampleQuery.trim() == "") $("#btn_save").show(); // 빈값인경우 저장 가능
				else $("#btn_save").hide();
			}
		});
	}
	
	// 쿼리확인
	function checkQuery(){
		cm_editor.save(); // Editor text to Textarea.
		
		$.ajax({
			type:"POST",
			data:{
				"xmldata" : cm_editor.getTextArea().value.trim(),	 // cm_editor.getValue().trim()
				"CompanyCode" : companyCode
			},
			url:"execComTableQueryCheck.do",
			//async : true,
			success:function (data) {			
				if(data.status == "SUCCESS"){
					var result = "";
					if(data.list && data.list.length > 0){
						$.each(data.list, function(i,v) { // data.list , data.page
						    result += JSON.stringify(v) + "\r\n";
						});
					}else{
						result = Common.getDic("msg_successNotResult"); // 정상 조회 되었지만, 조회 결과가 없습니다.
					}
					Common.open("","Result", "Result", 
						"<textarea style='font-family:Consolas;resize:none;width:100%;height:100%;line-height:130%;padding:20px; text-align:left' readonly>"+result+"</textarea>", 
						"900px","530px","html",true,null,null,true);
					$("#btn_save").show();
				}else {
                    Common.Error(data.message);
                }
			},
			error:function(response, status, error){
				CFN_ErrorAjax("execComTableQueryCheck.do", response, status, error);
			}
		});
	}
		
	// 저장
	function saveSubmit(){
		cm_editor.save(); // Editor text to Textarea.
		
		$.ajax({
			type:"POST",
			data:{
				"ComTableID" : comTableID,
				"xmldata" : cm_editor.getTextArea().value.trim(),	 // cm_editor.getValue().trim()
				"OldNamespace" : oldNamespace,
				"OldQueryId" : oldQueryId,
				"OldQueryIdCnt" : oldQueryIdCnt
			},
			url:"setComTableQuery.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					//if (popupType == 'Add' && data.object == 0) Common.Inform("<spring:message code='Cache._msg_CodeDuplicate' />");
					parent.Common.Inform("<spring:message code='Cache.msg_Processed' />","",function(){ // 처리 되었습니다
						parent.searchConfig();
						closeLayer();
					}); 
				} else {
					Common.Error(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("setComTableQuery.do", response, status, error);
			}
		});
	}
	
</script>
<div class="sadmin_pop">	
	<div style="margin-bottom:5px;">
		<a href="#" class="btnTypeDefault" onclick="checkQuery();"><spring:message code='Cache.lbl_CheckQuery'/></a> <!-- 쿼리확인 -->
		<a href="#" class="btnTypeDefault" onclick="setSampleQuery();"><spring:message code='Cache.lbl_LoadSample'/></a> <!-- 샘플 불러오기-->
	</div>	
	<table class="sadmin_table sa_menuBasicSetting" >
		<colgroup>
			<col width="*">
		</colgroup>
		<tbody>
			<tr>
		      	<td>
		      		<textarea id="QueryText" class="code_editor"></textarea>
		      	</td>
		    </tr>
    	</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a id="btn_save" onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" style=""><spring:message code='Cache.btn_save'/></a> <!-- 저장 -->
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
	</div>
	<div class="collabo_help" style="margin-top:20px;margin-top:20px;padding:10px 10px 10px 70px;">
		<p><spring:message code='Cache.msg_comtableManage01'/></p> <!-- mybatis xml형식으로 조회할 쿼리를 작성하세요. -->
		<p class="txt-mphasis"><spring:message code='Cache.msg_comtableManage02'/></p> <!-- 반드시 [쿼리확인] 버튼을 통해 결과확인 후 저장하시기 바랍니다. -->
		<p><spring:message code='Cache.msg_comtableManage03'/></p> <!-- 페이징은 자동으로 처리 됩니다. 검색 및 정렬은 아래 정의된 파라미터 키로 전송되므로 이에 맞게 구현하세요. -->
		<p> - <spring:message code='Cache.msg_comtableManage04'/></p> <!-- 로그인 사용자 정보 : 회사코드 CompanyCode , 다국어설정 lang -->
		<p> - <spring:message code='Cache.msg_comtableManage05'/></p> <!-- 정렬 : sortColumn(sort_조회된컬럼명) , sortDirection(ASC/DESC) -->
		<p> - <spring:message code='Cache.msg_comtableManage06'/></p> <!-- 검색 : SearchType(srch_조회된컬럼명) , SearchText(상세검색어) , icoSearch(상단 전체검색어) -->
		<p class="txt-mphasis"> - <spring:message code='Cache.msg_comtableManage07'/></p> <!-- mssql인경우 페이징도 구현 필요 : pageSize(페이지사이즈) , pageOffset(페이지번호) -->
	</div>
</div>
