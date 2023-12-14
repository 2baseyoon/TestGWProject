<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="resources/script/forms/FormApvLine.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/forms/FormAttach.js<%=resourceVersion%>"></script>

<script type="text/javascript">

var FormInstID = "${FormInstID}";
var ProcessID = "${ProcessID}";
var archived = "${archived}";
var bstored = "${bstored}";

$(document).ready(function (){
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
					ParseComments.parse(ApprovalLine, JSON.stringify(data.JWF_Comment));	
					comments = ParseComments.comment();
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
		opener.ParseComments.parse(ApprovalLine, opener.getInfo("JWF_Comment"));	
		comments = opener.ParseComments.comment();
	}
	var $tabfragment = $( document.createDocumentFragment());
	var $contents = $( document.createDocumentFragment());
	var personIds="";		
	var arr = Object.keys( comments ).reduce( function( acc, cur, item, arr ){
		var rtn = {data : []};
		
		$(comments[cur]).each(function(idx, comment){
			var rtn2 = comment.general || ( comment && { title : comment.title, data : comment.data } );
			
			if(rtn && rtn.data.length > 0) {
				(rtn2 && rtn2.data.length > 0) && ( rtn.data = rtn.data.concat(rtn2.data) );
			} else {
				rtn = rtn2;
			}
		});	
		(rtn && rtn.data.length > 0) && ( acc = acc.concat(rtn) );	
		
		return acc;		
	},[]);	
	
	arr.length === 0 && $("<div>",{ "class" : "commHigh", "style" : "height:300px;" })
							.append("<div style='text-align: center;'><br/><br/><spring:message code='Cache.msg_NoDataList' /></div>").appendTo( $contents );
	
	arr.length > 0 && arr.map( function( item,idx ){
		var $div = $("<div>",{ "class" : "commHigh", "style" : "height:300px;" });
		/* 탭 생성 */
		$tabfragment.append( item && $("<a>",{ "class" : "AXTab", "href" : "javascript:void(0);", "text" : item.title }) );
		/* 컨텐츠 */
		$div.append(
			item.data.reverse().map(function( item,idx ){
				personIds += item.personId+";"
				return $("<dl>",{ "class" : "commentPop" })
							.append( 
								$("<dt>",{ "class" : "cirPosition" })
									.append( $("<a>",{ "href" : "javascript:void(0);", "class" : "cirPro" }).append( $("<img>") ) )
							)
							.append( 
								$("<dd>")
									.append(
										$("<div>",{ "class" : "comm_box" })
											.append( $("<span>",{ "class" : "comArr", "text" : "icn" }) )
											.append(
												$("<dl>",{ "class" : "comTit tpl-dynamic" })
													.append(
														(item.comment_fileinfo && item.comment_fileinfo.length > 0) ? 
															($("<dt>",{"text" : item.type })
																.append( 
																	$("<div>",{ "class" : "fClip" })
																		.append( $("<a>",{ "class" : "mClip", "text" : "<spring:message code='Cache.lbl_attach'/>" }).data('item',item) )
																)
															) : ( $("<dt>",{"text" : item.type }) )
													)
													.append( $("<dd>",{ "html" : item.comment }) )
													.append( 
														$("<dd>",{ "html" : setUserFlowerName(item.personId, item.person) })
															.append( $("<span>",{ "class" : "comDate", "text" : item.date }) )												
													)
											)
									)
							).data('item', item )
			})
		).appendTo( $contents );				
	});
		
	/* 탭 그리기 및 이벤트 */
	$("#AXTabsTray")
		.append( $tabfragment )
		.on('click','a',function(){
			event.preventDefault();
			$("#AXTabsTray > a").removeClass('on').eq( $(this).index() ).addClass('on');
			$("#tabCont .commHigh").hide().eq( $(this).index() ).show();			
		});
	
	/* 코맨트 그리기 및 이벤트 */
	$("#tabCont")
		.append( $contents )
		.on('click','.mClip',function(){
			event.preventDefault();
			var obj = $(this).data('item');
			var parent = $(this).parent(); 			
			/* toggle */
			if( parent.find('.file_box').length === 1 ){
				$('.file_box',parent).remove();
			}else{
				$("#tabCont .file_box").remove();	
				/* fileBox */				
				var $ul = $("<ul>",{ "class" : "file_box" });
				$ul.append( $("<li>",{ "class" : "boxPoint" }) )
				   .append(  obj.comment_fileinfo.map(function(item, idx){  return $("<li>").append( $("<a>",{ "text" : item.name }).data('file', item ) ) }) )
				   .on('click','a',function(){
					   var file = $(this).data('file');				   
					  Common.fileDownLoad(file.id, file.savedname, file.FileToken); 
				   })
				$(this).parent().append( $ul );
			}
		});
			
	/* 코맨트 이미지 변경 */
	var photoPathObj = getProfileImagePath(personIds);
	$(photoPathObj).each(function(){
		var path = this.PhotoPath
		var pt_person = this.UserCode
		$("#tabCont .commentPop").map(function(idx, item){ $(this).data('item').personId === pt_person && $('img',this).prop('src', path).on('error', function(){ coviCmn.imgError(this, true); }); })
	});	
	
	/* 탭 이벤트 실행 */
	$("#AXTabsTray a:eq(0)").trigger('click');
	/* 닫기 이벤트 등록 */
	$("#doClose").on('click',function(){ Common.Close(); })
	
});
</script>

<body>
<form>
<div class="layer_divpop ui-draggable" id="testpopup_p" style="min-width: 540px; width:100%; z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
  <div class="divpop_contents">
    <div class="pop_header" id="testpopup_ph">
      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico"><spring:message code='Cache.lbl_apv_comment_view'/></span></h4> <!-- 의견보기 -->
<!--       <a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a><a class="divpop_window" id="testpopup_LayertoWindow" style="cursor: pointer;" onclick="Common.LayerToWindow('layerpopuptest.do?as=ads', 'testpopup', '331px', '270px', 'both')"></a><a class="divpop_full" style="cursor: pointer;" onclick="Common.ScreenFull('testpopup', $(this))"></a><a class="divpop_mini" style="cursor: pointer;" onclick="Common.ScreenMini('testpopup', $(this))"></a></div> -->
</div>
<!-- 팝업 Contents 시작 -->
    <div class="popBox" id="tabCont">    	
       <div class="AXTabsLarge">
         <div class="AXTabsTray" id="AXTabsTray"></div>
       </div>
    </div>
      <!-- 하단버튼 시작 -->
      <div class="popBtn borderNon"> 
      <a class="owBtn mr30" href="javascript:void(0);" id="doClose"><spring:message code='Cache.btn_apv_close'/></a> 
      <!-- 하단버튼 끝 -->  
    </div>        
    <!-- 팝업 Contents 끝 --> 
  </div>
</div>
</body>
</html>