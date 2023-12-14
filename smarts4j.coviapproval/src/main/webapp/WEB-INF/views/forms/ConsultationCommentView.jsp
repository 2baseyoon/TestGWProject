<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript" src="resources/script/forms/FormApvLine.js"></script>

<script type="text/javascript">
var ListGrid = new coviGrid();

$(document).ready(function (){
	var FormInstID = "${FormInstID}";
	var ProcessID = "${ProcessID}";
	var WorkItemID = "${WorkItemID}";
	var parentWorkItemID = "${ParentWorkItemID}";
	var archived = "${archived}";
	var subkind = "${Subkind}";
	var userCode = "${UserCode}";
	
	var bstored = "false";
	var ApprovalLine = {};
	var comments = "";
	
	if(ProcessID != "") {
		//ApprovalLine이랑 JWF_Comment 가져오기
		$.ajax({
			type:"POST",
			async:false,
			url:"getDataForCommentView.do",
			data:{
				"FormInstID": FormInstID,
				"ProcessID": ProcessID,
				"archived": archived,
				"bstored": bstored,
			},
			success:function (data) {
				if(data.result == "ok"){
					ApprovalLine = data.ApprovalLine;
				}
				else{
					Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
				}
			},
    		error:function(response, status, error){
				CFN_ErrorAjax("getApprovalLine.do", response, status, error);
			}
    	});
	} else {
		ApprovalLine = $.parseJSON(opener.getInfo("ApprovalLine"));
	}
	
	setGridHeader();
	setGridConfig();
	
	var requester;
	if(subkind === "T023"){
		requester = $$(ApprovalLine).find("step > ou").concat().find("[wiid='" +parentWorkItemID + "']").find("person").concat().find(">consultation[status!='canceled']").concat().find(">consultusers").concat().find("[wiid='"+WorkItemID+"']").parent().parent();
	} else {
		requester = $$(ApprovalLine).find("step > ou").concat().find("[wiid='" +WorkItemID+ "']").find("person").concat().find("[code='"+userCode+"']");
	}
	
	var jsonConsultation = requester.find(">consultation[status!='canceled']").concat().json();
	if(!$.isArray(jsonConsultation)){
		jsonConsultation = [].concat(jsonConsultation);
	}
	var ListData = [];
	for(i=0; i<jsonConsultation.length; i++){
		var item = jsonConsultation[i];
		var consultReqUser = {
			reqSeq : i+1,
			UserName : requester.json().name,
			DeptName : requester.json().ouname,
			result : "request",
			datecompleted : item.daterequested,
			WorkItemID : requester.parent().attr("wiid"),
			comment : $$(item.consultcomment).length > 0 ? Base64.b64_to_utf8($$(item.consultcomment).attr("#text")) : ""
		};
		ListData.push(consultReqUser);
		
		var pConsultUsers = $$(item).find(">consultusers").concat().json();
		if(!$.isArray(pConsultUsers)){
			pConsultUsers = [].concat(pConsultUsers);
		}
		for(j=0; j<pConsultUsers.length; j++){
			var jtem = pConsultUsers[j];
			var person = {
					reqSeq : i+1,
					UserName : $$(jtem).attr("name"),
					DeptName : $$(jtem).attr("ouname"),
					result : $$(jtem).find(">taskinfo").attr("result"),
					datecompleted : $$(jtem).find(">taskinfo").attr("datecompleted"),
					WorkItemID : $$(jtem).attr("wiid"),
					comment : $$(jtem).find(">taskinfo").find("comment").length > 0 ? Base64.b64_to_utf8($$(jtem).find(">taskinfo").find("comment").attr("#text")) : "",
					comment_fileinfo : $$(jtem).find(">taskinfo").find("comment_fileinfo").json()
			};
			ListData.push(person);
		}
	}
	
	ListGrid.bindGrid({page:{pageNo:1,pageSize:10,pageCount:1},list:ListData});
		
	/* 닫기 이벤트 등록 */
	$("#doClose").on('click',function(){ Common.Close(); })
	
});

function setGridHeader(){
	 var headerData =[
					{key:'reqSeq', label:"<spring:message code='Cache.lbl_Number'/>",  width:'5', align:'center', addClass:"black", sort:false, formatter:function(){
						return this.item.reqSeq
					}},
					{key:'UserName', label:"<spring:message code='Cache.lbl_apv_reviewer'/>",  width:'14', align:'center', addClass:"black", sort:false, formatter:function(){
						if(this.item.DeptName ==undefined || this.item.DeptName == "")
							return CFN_GetDicInfo(this.item.UserName);
						else
							return "("+CFN_GetDicInfo(this.item.DeptName)+")"+" "+CFN_GetDicInfo(this.item.UserName);
					}},
					{key:'result', label:"<spring:message code='Cache.lbl_apv_state'/>",  width:'8', align:'center', addClass:"black", sort:false, formatter: function(){
						var strResult = "";
						switch(this.item.result)
						{
						case "disagreed":
							strResult = "<spring:message code='Cache.lbl_apv_disagree'/>"; // 거부
							break;
						case "agreed":
							strResult = "<spring:message code='Cache.lbl_apv_agree'/>";  // 동의
							break;
						case "request":
							strResult = "<spring:message code='Cache.lbl_Request'/>";  // 요청
							break;
						default:
							strResult = "<spring:message code='Cache.lbl_apv_inactive'/>"; // 대기
							break;
						}
						return "<span>"+strResult+"</span>";
					}},
					{key:'datecompleted', label:"<spring:message code='Cache.lbl_apv_approvdate'/>",  width:'15', align:'center', sort:false, addClass:"black"},
					{key:'comment', label:"<spring:message code='Cache.lbl_apv_comment'/>",  width:'30', align:'left', addClass:"black", sort:false, formatter: function(){
						var strResult = "<span class=\"tableTxt\" style=\"width:90%; text-overflow:ellipsis; overflow:hidden; vertical-align:middle;\" title='"+this.item.comment+"'>"+this.item.comment+"</span>";
						if(this.item.comment_fileinfo && Object.keys(this.item.comment_fileinfo).length > 0){
							strResult += "<div class=\"fClip\" style=\"display: inline-block; float: none; vertical-align:middle;\"><a class=\"mClip\" onclick='openFileList(this)'><spring:message code='Cache.lbl_attach'/></a></div>";
							strResult += "<input type='hidden' value='" + JSON.stringify(this.item.comment_fileinfo) + "'/> ";
						}						
						return strResult;
					}}];
	 ListGrid.setGridHeader(headerData);	
}

function setGridConfig(){
	var configObj = {
			targetID : "ListGrid",
			height:"280",
            page: {
            	display: false,
				paging: false
            },
            overflowCell : [4]
	};
	
	ListGrid.setGridConfig(configObj);
}


function openFileList(pObj){
	event.preventDefault();
	var parent = $(pObj).parent();
	var obj = $.parseJSON($(pObj).closest("td").find("input").val()); 			
	/* toggle */
	if( parent.find('.file_box').length === 1 ){
		$('.file_box',parent).remove();
	}else{
		$("#ListGrid .file_box").remove();	
		/* fileBox */				
		var $ul = $("<ul>",{ "class" : "file_box" });
		$ul.append( $("<li>",{ "class" : "boxPoint" }) )
		   .append(  obj.map(function(item, idx){  return $("<li>").append( $("<a>",{ "text" : item.name }).data('file', item ) ) }) )
		   .on('click','a',function(){
			  var file = $(this).data('file');				   
			  Common.fileDownLoad(file.id, file.savedname, file.FileToken); 
		   })
		$(pObj).parent().append( $ul );
	}
}

</script>

<body>
	<div class="layer_divpop ui-draggable" id="testpopup_p" style="width: 100%; z-index: 51;" source="iframe" modallayer="false" layertype="iframe">
		<div class="divpop_contents">
			<div class="pop_header" id="testpopup_ph">
				<h4 class="divpop_header ui-draggable-handle" id="testpopup_Title">
					<span class="divpop_header_ico"><spring:message	code='Cache.lbl_apv_consult_comment_view' /></span>
				</h4>
			</div>			
			<!-- 팝업 Contents 시작 -->
			<div class="review_popup_wrap">
				<!-- 테이블 영역 -->
				<div class="coviGrid">
					<div id="ListGrid"></div>
				</div>
				<!-- 버튼영역 -->
				<div class="center mt20">
					<a class="btnTypeDefault" id="doClose"><spring:message code='Cache.btn_apv_close' /></a>
				</div>
			</div>
		</div>
	</div>
</body>