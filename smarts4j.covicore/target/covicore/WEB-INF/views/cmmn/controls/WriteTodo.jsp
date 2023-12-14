<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="todoLayerPopContent">
	<div class="top">						
		<div class="ulList ">
			<ul>							
				<li class="listCol">
					<div><strong><spring:message code='Cache.lbl_Contents'/></strong></div>
					<div>
						<input type="text" class="inpFullSize HtmlCheckXSS ScriptCheckXSS" id="title" placeholder="<spring:message code='Cache.msg_EnterContent'/> <spring:message code='Cache.msg_TodoTitleMaxChar'/>" maxlength="100">
					</div>
				</li>			
				<li class="listCol">
					<div><strong><spring:message code='Cache.lbl_Completed'/></strong></div>
					<div>
						<div class="chkStyle04  chkType01">
							<input type="checkbox" id="isComplete"><label for="isComplete"><span></span></label>
						</div>
					</div>
				</li>			
				<li class="listCol">
					<div><strong><spring:message code='Cache.lbl_Description'/></strong></div>
					<div>
						<textarea placeholder="<spring:message code='Cache.msg_enterDesc'/> <spring:message code='Cache.msg_TodoDecMaxChar'/>" id="description" class="HtmlCheckXSS ScriptCheckXSS" maxlength="2000"></textarea>
					</div>									
				</li>									
			</ul>							
		</div>
	</div>								
	<div class="bottom mt20" style="text-align: center;">
		<a class="btnTypeDefault btnTypeChk" onclick="saveTodo()"><spring:message code='Cache.lbl_Save'/></a>
		<a class="btnTypeDefault" onclick="delectTodo()"><spring:message code='Cache.lbl_delete'/></a>
		<a class="btnTypeDefault" onclick="Common.Close()"><spring:message code='Cache.lbl_Cancel'/></a>
	</div>
</div>

<script>
	$(document).ready(function(){
	    $('#title').keyup(function(){
	        if ($(this).val().length > $(this).attr('maxlength')) {
	            $(this).val($(this).val().substr(0, $(this).attr('maxlength')));
	        }
	    });
	    
	    $('#description').keyup(function(){
	        if ($(this).val().length > $(this).attr('maxlength')) {
	            $(this).val($(this).val().substr(0, $(this).attr('maxlength')));
	        }
	    });
	});

	var param = location.search.substring(1).split('&');
	var todoId = CFN_GetQueryString("todoId") == 'undefined' ? 0 : CFN_GetQueryString("todoId");

	initContent();
	
	function initContent() {
		if (todoId != 0) {
	 		$.ajax({
				type : "POST",
				data : {todoId : todoId},
				async: false,
				url : "/covicore/todo/getList.do",
				success:function (list) {
					var data = list.list[0];
					
					$('#title').val(data.Title);
					if (data.IsComplete == 'Y') $('#isComplete').prop('checked', true);
					$('#description').val(data.Description);
					
				},
				error:function(response, status, error) {
					CFN_ErrorAjax(url, response, status, error);
				}
			});
		}
	}
	
	// 저장
	function saveTodo() {
		var url = '';

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if($('#title').val() == "" || $('#title').val() == null){
			Common.Warning("<spring:message code='Cache.lbl_EnterContents'/>");
			return;
		}
		
		var params = new Object();
		params.messageType = 'Tab';
		params.title = $('#title').val();
		params.url = '';
		params.description = $('#description').val(); 
		if (todoId == 0) {	// 신규
			url = '/covicore/subscription/insertTodo.do';
		} else {	// 수정
			url = '/covicore/subscription/updateTodo.do';
			params.todoId = todoId;
		}
		params.isComplete = ($('#isComplete').is(":checked") == true) ? 'Y' : 'N';
		
  		$.ajax({
			type : "POST",
			data : params,
			url : url,
			success:function (list) {
				parent.coviCtrl.getTodoList();	// TODO 조회 및 그리기
				
				Common.Close();
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});			
	}
	
	function delectTodo() {
		coviCtrl.callDeleteTodo(todoId);
		
	}
	
</script>