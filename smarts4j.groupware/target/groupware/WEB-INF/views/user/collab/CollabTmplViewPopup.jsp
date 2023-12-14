<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.card_cont {height:auto !important}
#collabTmplViewPopup .column {
     height: calc(100% - 10px); 
}

</style>
<div class="cRContCollabo mScrollVH" id="collabTmplViewPopup">
	<div class="cRConTop titType">
		<h2 class="title">${tmplName}</h2>
		<div class="searchBox02">
		</div>
	</div>
	<div class="tstab_cont active" style="height:calc(100% - 90px)">
			<div class="Project_top project_top_r ">
				<div class="Project_btn btn">
					<c:if test="${mode eq 'MDF'}">
					<a href="#" class="btnRefresh"></a>
					<a href="#" class="btnTypeDefault btnPlus" id="btnSecPlus"></a>
					</c:if>
				</div>
			</div>
			<div class="container-fluid active card-fluid" id="dttab-3">
				<div class="row"></div>
			</div>
		</div>
	</div>	
</div>
	<!-- 컨텐츠 끝 -->
<script>
var collabTmplViewPopup ={
		pageSize : 20,
		tmplSeq : "${tmplSeq}",
		objectInit:function(){//초기 세팅
			this.getTmplMain();
			this.addEvent("collabTmplViewPopup");
		},
		getTmplMain:function (){
			var params = {"tmplSeq":  collabTmplViewPopup.tmplSeq,"mode":"${mode}", "pageNo":1, "pageSize":collabTmplViewPopup.pageSize};
			
			$.ajax({
	    		type:"POST",
	    		data:params,
	    		url:"/groupware/collabTmpl/getTmplMain.do",
	    		success:function (data) {
	    			collabTmplViewPopup.loadTmplMain(data, params);
	    		},
	    		error:function (request,status,error){
	    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	    		}
	    	});
		},
		loadTmplMain:function(data, params ){
			<c:if test="${mode eq 'MDF'}">
			data["prjAdmin"] = "Y";
			$('#collabTmplViewPopup').data("prjAdmin", "Y");
			</c:if>
			//섹션 추가
			if (data.taskFilter.length >0){
				$('#collabTmplViewPopup .row').empty().append(
					data.taskFilter.map( function( item,idx ){
						return collabMain.drawSection(item, data);
					})
				);
			}
			
			//타스크 콕록
	    	collabMain.loadMyTask("collabTmplViewPopup", data, "N", params);
			
			<c:choose>
				<c:when test="${mode eq 'MDF'}">
				$('#collabTmplViewPopup .row .column .cardBox_area').sortable({
				    connectWith: ".cardBox_area",
				    handle: ".card_cont",
				    cancel: ".no-move",
				    placeholder: "card_placeholder",
			    	start: function(event, ui) {
			            ui.item.data('start_pos', ui.item.index());
			        },
			        stop: function(event, ui) {
			        	var ordTaskArr = new Array();
			        	var idx = ui.item.index();
			        	var workOrder = 0;
			        	var sectionSeq = ui.item.parents(".column").data("sectionseq");
			        	
			        	for (var i = 0; i< $("#section_"+sectionSeq + " .card_cont").length; i++){
			        		ordTaskArr.push({ "taskSeq":$("#section_"+sectionSeq + " .card_cont").eq(i).data("taskSeq"), "workOrder":workOrder++});
			        	}
						
			            $.ajax({
			            	type:"POST",
				        	contentType:'application/json; charset=utf-8',
				    		dataType   : 'json',
				    		data:JSON.stringify({"taskSeq": ui.item.find(".card_cont").data("taskSeq")
				    			,"tmplSeq": "${tmplSeq}"
			        			,"sectionSeq":sectionSeq
			        			,"workOrder":workOrder
			        			,"ordTask":ordTaskArr}),
			        		url:"/groupware/collabTmpl/changeTmplTaskOrder.do",
			        		success:function (data) {
			        			collabTmplViewPopup.getTmplMain();
			        		},
			        		error:function (request,status,error){
			        			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			        		}
			        	});
					}
				});
				$('.column_menu #btnSecMove').remove();
				</c:when>
				<c:otherwise>
		    	$('#collabTmplViewPopup .row .column01').css("pointer-events", "none");
				</c:otherwise>
			</c:choose>
		},
		addEvent:function(objId, aData){
			$(document).off('click','#'+objId+' #btnPrjFunc').on('click','#'+objId+' #btnPrjFunc',function(){
				$(this).siblings(".column_menu").toggleClass("active");
		    });

			
	        //삭제
	        $('#'+objId+' #btnDel').on( 'click',aData, function(e){
	        	$(this).parents(".column_menu").removeClass("active");
	        	Common.Confirm( Common.getDic("msg_RUDelete"), "Confirmation Dialog", function (confirmResult) {
	        		if (confirmResult) { 
	                	$.ajax({
	                		type:"POST",
	                		data:{"prjSeq":  aData.prjSeq},
	                		url:"/groupware/collabProject/deleteProject.do",
	                		success:function (data) {
	                			if(data.status == "SUCCESS"){
	                				Common.Inform(Common.getDic("msg_com_processSuccess"));	//
	            					$("#content #P_"+aData.prjSeq).remove();
	            					$("#tab_P_"+aData.prjSeq).remove();
	            					$("#list_P_"+aData.prjSeq).parent().remove();
	            					$("#fixTab").click();
	                			}
	                			else{
	                				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
	                			}
	                		},
	                		error:function (request,status,error){
	                			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	                		}
	                	});
		        	}
	        	});
	        });
	        
	        //새로고침
	        $('#'+objId+' .btnRefresh').on( 'click', function(e){
	        	collabTmplViewPopup.getTmplMain();
	        });
	        
			//세션변경
			$(document).off('click','#'+objId+' #btnSecFunc').on('click','#'+objId+' #btnSecFunc',function(){
				$(this).siblings(".column_menu").toggleClass("active");
			});
			
			$(document).off('mouseleave','#'+objId+' .column_menu').on('mouseleave','#'+objId+' .column_menu',function(){
				$(this).removeClass("active");
			});
			
			//리스트 숨기기 
			$(document).off('click','#'+objId+' .list_header .column_tit').on('click','#'+objId+' .list_header .column_tit',function(e){
			    $(this).parent('.list_header').toggleClass('active');
			    $(this).parent().parent('.column').toggleClass('active');
			});
			  
			
			//섹션 추가
			$(document).off('click', '#' + objId + ' #btnSecPlus').on('click', '#' + objId + ' #btnSecPlus', function () {
				var aData = [];
				var popupID = "CollabSectionPopup";
				var openerID = "CollabMain";
				var popupTit ="<spring:message code='Cache.lbl_AddSection' />";
				var popupYN = "N";
				var popupUrl = "/groupware/collabTmpl/CollabTmplSectionPopup.do?"
					+ "&tmplSeq=" + collabTmplViewPopup.tmplSeq
					+ "&popupID=" + popupID
					+ "&openerID=" + openerID
					+ "&popupYN=" + popupYN;
				Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);
				//CFN_OpenWindow(popupUrl, "", 350, 350, sSize);

			});

			//섹션명 변경
			$(document).off('click', '#' + objId + ' #btnSecChg').on('click', '#' + objId + ' #btnSecChg', function () {
				$(this).parents(".column_menu").toggleClass("active");

				var popupID = "CollabSectionPopup";
				var openerID = "CollabMain";
				var popupTit = "<spring:message code='Cache.btn_ModiSection' />";
				var popupYN = "N";
				var popupUrl = "/groupware/collabTmpl/CollabTmplSectionPopup.do?"
					+ "&tmplSeq=" + collabTmplViewPopup.tmplSeq
					+ "&sectionSeq=" + $(this).data("seq")
					+ "&sectionName=" + encodeURIComponent($(this).parent().parent().find(".column_tit").text())
					+ "&popupID=" + popupID
					+ "&openerID=" + openerID
					+ "&popupYN=" + popupYN;
				Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);

			});

			//섹션명 삭제
			$(document).off('click', '#' + objId + ' #btnSecDel').on('click', '#' + objId + ' #btnSecDel', function () {
				$(this).closest('.addFuncBox').removeClass('active');

				if ($(this).closest('.column').find('.card').size() > 0) {
					Common.Error(Common.getDic("msg_apv_existFolder")); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					return;
				}

				var objId = $(this).closest('.cRContBottom').attr("id");
				var aData = $(this).closest('.cRContBottom').data()

				$.ajax({
					type: "POST",
					data: {"sectionSeq": $(this).data("seq")},
					url: "/groupware/collabTmpl/deleteTmplSection.do",
					success: function (data) {
						collabTmplViewPopup.getTmplMain();
					},
					error: function (request, status, error) {
						Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error)
					}
				});
			});

			//타스크 추가
			$(document).off('click', '#' + objId + ' #task_add').on('click', '#' + objId + ' #task_add', function () {
//				var aData = $(this).closest('.cRContBottom').data();
//				collabUtil.openTaskAddPopup("CollabTaskAddPopup", objId, "", collabTmplViewPopup.tmplSeq, $(this).data("seq"), $(this).siblings(".column_tit").text());
				var seq = $(this).data("seq");
				$('#' + objId + ' .add_task').closest(".card").remove();

				$('#' + objId + ' .row #section_' + seq + ' .card_header').after($("<div>", {"class": "card type01"})
					.append($("<div>", {"class": "card_cont1"})
						.append($("<div>", {"class": "card_info"})
							.append(collabUtil.drawAddTask("resultViewMemberInput", "StartDate", "EndDate"))
						)));
				$('#' + objId + ' .row #section_' + seq + ' textarea').data({
					"tmplSeq": collabTmplViewPopup.tmplSeq,
					"sectionSeq": seq
				});

				$('#' + objId + ' .row #section_' + seq + ' textarea').focus();
				$('#' + objId + ' .row #section_' + seq + ' textarea').on('keydown', function (key) {
					if (key.keyCode == 13) {
						$.ajax({
							type: "POST",
							data: {
								"tmplSeq": collabTmplViewPopup.tmplSeq,
								"sectionSeq": seq,
								"taskName": $(this).val().replace(/\'/gi, "′").replace(/\"/gi, "″")
							},
							url: "/groupware/collabTmpl/addTmplTask.do",
							success: function (data) {
						    	$('#'+objId+' .btnRefresh').trigger('click');
//								$('#' + objId + ' .row #section_' + seq).append(collabUtil.drawTask(data));
//								$('#' + objId + ' .row #section_' + seq + ' .add_task').closest(".card").remove();
							},
							error: function (request, status, error) {
								Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error)
							}
						});

					}
				});
			});
			
			//카드 복사
			$(document).off('click', '#cardCopy').on('click', '#cardCopy', function () {
				var cardData = $(this).closest(".card_control").siblings(".card_cont").data();
				var popupID	= "CollabTaskCopyPopup";
				var openerID	= "";
				var popupTit	= "["+cardData.taskName + "] "+Common.getDic("ACC_btn_copy");//"<spring:message code='Cache.lbl_app_approval_extention' />";
				var popupYN		= "N";
				var callBack	= "";
				var popupUrl	= "/groupware/collabTmpl/CollabTmplTaskCopyPopup.do?"
								+ "&taskSeq="       +  cardData.taskSeq
								+ "&popupID="		+ popupID	
								+ "&openerID="		+ openerID	
								+ "&popupYN="		+ popupYN	
								+ "&callBackFunc="	+ "callbackTmplTaskSave"	;
				Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);
			});

			//카드 수정
			$(document).off('click', '#cardModify').on('click', '#cardModify', function () {
				var cardData = $(this).closest(".card_control").siblings(".card_cont").data();
		 		var popupYN		= "N";
		 		var openerID	= "";
		 		var popupUrl	= "/groupware/collabTmpl/CollabTmplTaskSavePopup.do?"
		 						+ "&taskSeq="    	+ cardData.taskSeq
		 						+ "&sectionSeq="    + cardData.sectionSeq
		 						+ "&prjName=" 		+ $(".title").text()
		 						+ "&sectionName=" 	+  $(this).closest(".column_tit").text()
		 						+ "&popupID="		+ ""	
		 						+ "&openerID="		+ ""	
		 						+ "&popupYN="		+ ""	
		 						+ "&callBackFunc="	+ "callbackTmplTaskSave"	;
				Common.open("", "callbackTaskSave", cardData.taskSeq==undefined?Common.getDic("btn_apv_AddTask"):Common.getDic("lbl_task_taskManage"), popupUrl, "700", "300", "iframe", true, null, null, true);
		 	});

			//카드 삭제
			$(document).off('click', '#cardDelete').on('click', '#cardDelete', function () {
				var cardData = $(this).closest(".card_control").siblings(".card_cont").data();
				Common.Confirm( Common.getDic("msg_RUDelete"), "Confirmation Dialog", function (confirmResult) {
	        		if (confirmResult) {
	                	$.ajax({
	                		type:"POST",
	                		data:{
	                			  "taskSeq"		: cardData.taskSeq
	                		},
	                		url:"/groupware/collabTmpl/deleteTmplTask.do",
	                		success:function (data) {
	                			if(data.status == "SUCCESS"){
	                				$('.btnRefresh').trigger('click');
	                			}
	                			else{
	                				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
	                			}
	                		},
	                		error:function (request,status,error){
	                			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	                		}
	                	});
		        	}
	        	});
			});

		},
		loadSection:function(retData){
			//섹션 추가
			var objId = retData.prjType+"_"+retData.prjSeq;
			$('#'+objId+' .row').append(collabMain.drawSection(retData));
		},
		changeSection:function(retData){
			//섹션명변경
			$('#section_'+retData.SectionSeq+' .column_tit').text(retData.SectionName);
		},

}		
$(document).ready(function(){
	collabTmplViewPopup.objectInit();
});

window.addEventListener( 'message', function(ev){
    // 부모창의 함수 실행
    switch (ev.data.functionName){
	    case "callbackTmplTaskSave":	
	    case "callbackTmplTaskSaveCopy":
	    	$('.btnRefresh').trigger('click');
	    	break;
    }
    
});


</script>