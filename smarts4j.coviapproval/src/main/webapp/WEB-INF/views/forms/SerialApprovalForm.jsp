<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!DOCTYPE html>
<html>
<head>
	<!--CSS Include Start -->
	<!-- 공통 CSS  -->
	<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>
	<script type="text/javascript" src="/approval/resources/script/user/common/ApprovalUserCommon.js<%=resourceVersion%>"></script>
	<style>
		/* 연속결재 창 */
		.clearFloat:after, .slick-dots:after {display:block;content:'';clear:both;}
		.Appcon{}
		.AppconTop{padding: 30px; border-bottom: 1px solid #d3d3d3; position:absolute; z-index:11; width: 100%;}
		.Appcon_title{height: 31px; margin-bottom: 17px; }
		.At{ line-height: 31px; font-size: 20px; font-weight: bold; }
		.Appcon_title a{display: inline-block; float:right;}
		.Appcon_title a span{ height: 31px; line-height: 31px; display: inline-block; background:#4fbdde; padding: 0 10px; border-radius: 4px; color: #fff; } 
		.Appcon_title a span img{ padding-right: 30px;}
		.AppconTop .select2 {margin-top: 0px; width: 100%; height: 31px; float: none  !important;}
		.ApptabMenu {width:100%; margin:0; padding:0; list-style:none;border-bottom: 1px solid #d3d3d3; margin-bottom: 10px;}
		.ApptabMenu > li {position:relative;top:1px;left:-1px;padding-top:1px;float:left;height:31px;line-height:31px;z-index:1;background:#fff;border-top:1px solid #d3d3d3;border-bottom:1px solid #d3d3d3;border-left:1px solid #d3d3d3;}
		.ApptabMenu > li:first-child {left:0;}
		.ApptabMenu > li:last-child {border-right:1px solid #d3d3d3;}
		.ApptabMenu > li.active {z-index:2;padding-top:0;line-height:31px;border-left:1px solid #d3d3d3;border-right:1px solid #d3d3d3;border-bottom:1px solid #fff;}
		.ApptabMenu > li.active a {color:#000;}
		.ApptabMenu > li a {padding:0 21px;display:block;font-size:13px;color:#999;line-height:31px;}
		.ApptabMenu > li.active .Tabcolor_b{}
		.Tabcolor_b{margin-left: 5px;}
		.AppconContent{background-color: #f8f8f8;}
		.AppconContentBox{padding:30px; }
		.AppbgB{background-color:#fafeff !important;}
		.AppSelect_off{border: 1px solid #dedede; border-radius: 4px; background-color: #fff; margin-bottom: 10px;}
		.AppSelect_on{border: 1px solid #4abde1; border-radius: 4px; background-color: #fff; box-shadow: 0 2px 10px 0 rgba(0, 0, 0, 0.3);margin-bottom: 10px;}
		.AppSelect_complete{border: 1px solid #afe4f1; border-radius: 4px; background-color: #fff; margin-bottom: 10px;}
		.Acttop{height: 49px; line-height: 49px; font-size: 15px;font-weight: bold; padding: 0 20px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;}
		.Actbottom{height: 38px; line-height: 38px;  padding: 0 20px 0 12px;;}
		.AppSelect_off .Acttop{color: #222; border-bottom: 1px solid #dedede;}
		.AppSelect_on .Acttop{color: #4abde1; border-bottom: 1px solid #4abde1;}
		.AppSelect_complete .Acttop{color: #222; border-bottom: 1px solid #afe4f1;}
		.Actleft{float: left; font-weight: bold; color: #ff4747; font-size: 14px;}
		.Actleft img{margin-top:-2px; margin-right: 5px;}
		.Actright{float: right; color: #888; font-size: 12px;}
		.Actright strong{font-weight:normal; margin-right: 5px; font-size: 12px;}
		.ani_arrow{background: url(<%=cssPath%>/approval/resources/images/Approval/ani_arrow.gif) no-repeat 0 0;width: 17px;height: 13px;position: absolute;top: 42px;right: -25px;}
		.AppCmore a{ display: block; height: 50px; line-height: 50px; text-align: center; font-size: 15px; border: 1px solid #dedede; border-radius: 4px; background-color: #fff; }
				
		/*연속결재 레이아웃*/
		.AppconLeft {position:fixed; height:100%; width:441px;}
		.AppConTable {width:100%; padding:0px; margin:0px;}
		.AppConLeftTd {width:445px; vertical-align:top;}
		.AppConRightTd {vertical-align:top; position:relative;}
		.AppconContent {position:absolute; bottom:0px; top:185px; border-right:#d3d3d3; width:441px; height:auto !important;}
		.AppconRight {width:100%;}
		.AppconRight .conin_view{right:auto !important; position:relative; width:auto !important;}
		.AppconLeft {border-right: 1px solid #d3d3d3;}
		.AppconLeft .jquery-selectbox {width:379px !important;}
		.AppconLeft .jquery-selectbox-list {width:379px !important;}

		/* 연속결재 창 탭*/
		.ApptabMenu > li.active {border-top:2px solid #4abde1;}
		.ApptabMenu > li.active .Tabcolor_b{color: #4abde1;}
		
	</style>
</head>

<body>
	<div class="Appcon">
		<table class="AppConTable" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td class="AppConLeftTd">
					<div class="AppconLeft">
						<!-- 연속결재 좌측 상단 탭 영역 시작-->
						<div class="AppconTop">
							<!-- 타이틀 시작-->
							<div class="Appcon_title">
								<span class="At"><spring:message code='Cache.btn_apv_SerialApprove' /></span> <!-- 연속결재 -->
								<a id="approvalExecute"><span><img src="<%=cssPath%>/approval/resources/images/Approval/Arrow_conbtn.png"><spring:message code='Cache.lbl_apv_Run' /></span></a> <!-- 실행 -->
							</div>
                      		<!-- 타이틀 끝-->
							<!-- tab 시작-->
							<ul class="ApptabMenu clearFloat" id="leftTabs">
								<li id="btnAll" class="active"><a><spring:message code='Cache.btn_All' /><span class="Tabcolor_b"></span></a></li> <!-- 전체 -->
                       			<li id="btnDesignated"><a><spring:message code='Cache.btn_Designated' /><span class="Tabcolor_b">0</span></a></li> <!-- 지정 -->
                       			<li id="btnNotDesignated"><a><spring:message code='Cache.btn_NotDesignated' /><span class="Tabcolor_b"></span></a></li> <!-- 미지정 -->
							</ul>
 	                        <!-- tab 끝-->
                            <!-- select 시작-->
							<div class="select2" style="float:left;">
								<select id="selFormList" style="width: 100%;" class="JquerySelectApprovalBox">
									<option><spring:message code='Cache.btn_All' /> <spring:message code='Cache.lbl_apv_form' /></option>
								</select>
							</div>
							<!-- select 끝-->
						</div>
						<!-- 연속결재 좌측 상단 탭 영역 끝-->
						<!-- 연속결재 좌측 본문 시작 // AppconContent 높이 값은 연속결재창 지정 높이에 맞게 변경해 주시면 됩니다. //-->
						<div id="approvalContent" class="AppconContent" style="overflow-x: hidden; overflow-y: auto;">
							<div class="AppconContentBox">
								<div id="approvalList"></div>
								<div id="divMore" class="AppCmore" style="display: none"><a href="#"><spring:message code='Cache.lbl_MoreView' /></a></div> <!-- 더보기 -->
							</div>
							<div class="AppconContentBox" style="display: none">
								<div id="checkedList"></div>								
							</div>
						</div>	
						<!-- 연속결재 좌측 본문 끝-->
					</div>
				</td>
				<td class="AppConRightTd">
					<div class="AppconRight">
						<!-- 양식 Iframe 시작 -->
						<div id="divForm" class="conin_view" style="border: 0px; top:0px; -ms-overflow-style: auto;">
							<iframe name="IframeSerialApprovalFrm" width="100%;" height="auto" id="IframeSerialApprovalFrm" frameborder="0" scrolling="yes"></iframe>
							<input id="serialApprovalVal" type="hidden" value="" />
						</div>
						<!-- 양식 Iframe 끝 -->
					</div>
				</td>
			</tr>
		</table>
	</div>
</body>

<script type="text/javascript" language="javascript">
	var serial;
	var commonWritePopupOnload;
	var serialEvent = function(){		
		var data = {
			searchGroupType 	: 	"FormPrefix"
			,pageSize			:	10
			,mode				:	"APPROVAL"
			,bstored			:	"false"
			,userID				:	Common.getSession("USERID")
		};		
		var selectData = [];
		var checkedData = {};
		var _ajax = function(purl,param,type){
			var deferred = $.Deferred();			
			$.ajax({
				url: purl,
				type:"POST",
				data: param || {},	
				dataType : 'json',
				processData : type === undefined ? true : false,
		        contentType : type === undefined ? "application/x-www-form-urlencoded; charset=UTF-8" : false,						
				success:function (data) { deferred.resolve(data);},
				error:function(response, status, error){ deferred.reject(response, status, error); }
			});				
		 	return deferred.promise();	
		}
		var $approvalListBox = $("#approvalContent");
		var $tab = $("#approvalList");
		
	    location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(str, key, value) { data[key] = value; });
	    
		/*selectBox*/
		$("#selFormList option:eq(0)").data('item',{ fieldCnt : 0 });		
	    _ajax("/approval/user/getApprovalGroupListData.do",{
	    	searchGroupType	:	data.searchGroupType
			,mode			:	data.mode
			,bstored		:	data.bstored
			,businessData1	:	data.businessData1
			,userID			:	Common.getSession("USERID")
	    })
	    .done(function(data){
	    	var allCnt = 0;
	    	data.list.reduce(function( acc,cur,idx,arr ){
	    		allCnt += Number(cur.fieldCnt)
	    		return acc.append( $( "<option>",{ "text" : CFN_GetDicInfo(cur.fieldName) + " [" + cur.fieldCnt + "]" }).data('item',cur) )
	    	}, $( document.createDocumentFragment()) ).appendTo( $("#selFormList") );	    	
	    	$("#selFormList option:eq(0)").data('item',{ fieldCnt : allCnt, fieldID : "ALL" });
	    	$("#btnNotDesignated .Tabcolor_b, #btnAll .Tabcolor_b").text(allCnt);
	    })
		.fail(function(){ CFN_ErrorAjax("/approval/user/getApprovalGroupListData.do", response, status, error); });
	    
		this.setData = function(obj){ data = $.extend( data,obj ) };
		this.setSelectData = function(obj){ 
			var selectObj 	= $(".AppSelect_on",$tab);
			var fieldId		= $("#selFormList option:selected").data('item').fieldID;
			var listItem	= selectObj.data('item');
			var $cloneObj	= selectObj.clone().prop('class','AppSelect_off').data('item',listItem);	
			!checkedData["ALL"] && ( checkedData["ALL"] = [] );
			!checkedData[listItem.FormPrefix] && ( checkedData[listItem.FormPrefix] = [] );			
			
			if( checkedData["ALL"].filter( function(item){ return item.FormInstID === obj.FormInstID }).length === 0 ){
				$cloneObj.find('a > img').data('comment',obj.comment );
				$("#checkedList").append( $cloneObj );
				obj.targetObj = $cloneObj;
			}
			checkedData["ALL"] = checkedData["ALL"].filter( function(item){ return item.FormInstID !== obj.FormInstID }).concat( listItem );			
			checkedData[listItem.FormPrefix] = checkedData[listItem.FormPrefix].filter( function(item){ return item.FormInstID !== obj.FormInstID }).concat( listItem );			
			selectData = selectData.filter( function(item){ return item.FormInstID !== obj.FormInstID }).concat( obj );
			this.setTabStatus();
		};
		this.removeSelectData = function(obj){			
			checkedData["ALL"] = checkedData["ALL"].filter( function(item){ return item.FormInstID !== obj.FormInstID });
			checkedData[obj.FormPrefix] = checkedData[obj.FormPrefix].filter( function(item){ return item.FormInstID !== obj.FormInstID });
			selectData = selectData.filter( function(item){ return item.FormInstID !== obj.FormInstID });
			this.setTabStatus();
		}
		
		this.getCheckedData = function(){ return $.extend({},checkedData) };		
		this.getPageNo = function(){ return data.pageNo };
		this.getPageSize = function(){ return data.pageSize };
		this.getApprovalList = function(){ return _ajax("/approval/user/getApprovalListData.do",data) };
		
		this.approvalAllVw = function(){ 
			$(".AppconContentBox",$approvalListBox).hide().eq(0).show();
			$("#approvalList > div").show();
			$tab = $("#approvalList");
		};
		
		this.approvalChkVw = function(){ 
			$(".AppconContentBox",$approvalListBox).hide().eq(1).show();
			$tab = $("#checkedList");
		};
		
		this.approvalNotChkVw = function(){
			$(".AppconContentBox",$approvalListBox).hide().eq(0).show();
			var chkList = selectData.map( function(item){ return item.FormInstID });
			var obj = $("#approvalList > div");
			obj.hide().filter( function( idx,item ){ return chkList.indexOf( $(item).data('item').FormInstID ) === -1 }).show();
		};
		
		this.approvalListDraw = function(list){			
			var chkList = selectData.map( function(item){ return item.FormInstID });
			return list.reduce( function(acc,cur,idx,arr){		    		
			    		var $appSelect = $("<div>",{ "class" : "AppSelect_off" }).data("item",cur);
			    		var arrIdx = chkList.indexOf( cur.FormInstID );
			    		$("<a>")
			    			.append( $("<div>",{ "class" : "Acttop", name : "subject", text : cur.FormSubject }) )
			    			.append(   
			    					arrIdx > -1 && $.trim( selectData[arrIdx].comment ) &&
			    						$("<img>",{ "id" : selectData[arrIdx].FormInstID, "src" : "<%=cssPath%>/approval/resources/images/Approval/ico_comment.png", "style" : "float: right; margin-top: -35px; margin-right: 10px;" }).data('comment',selectData[arrIdx].comment)
			    			)
			    			.append(
			    				$("<div>",{ "class" : "Actbottom" })
			    					.append( 
			    						$("<span>",{ "class" : "Actleft" })
			    							.append( arrIdx > -1 && $("<img>",{ "src" : "<%=cssPath%>/approval/resources/images/Approval/ico_act"+selectData[arrIdx].imgIndex+".png" }) )
			    							.append( arrIdx > -1 && selectData[arrIdx].text )
			    					)
			    					.append( 
			    						$("<span>",{ "class" : "Actright" })
			    							.append( $("<strong>",{ "text" : CFN_GetDicInfo(cur.InitiatorName) }) )
			    							.append( cur.Created )
			    					)
			    			).appendTo( $appSelect );
			    		return acc.append( $appSelect );		    		
			    	}, $( document.createDocumentFragment()) );
		}
		
		this.popup = function(type, text, mode, consultReqItem){
			var selectObj 	= $(".AppSelect_on",$tab);
			var item		= selectObj.data('item');
			var popupUrl	= (item.BusinessData2 !== "APPROVAL") ? "/approval/CommentWrite.do?bSerial=true" : "CommentWrite.do?bSerial=true";
			//의견첨부 사용하지 않는 경우 크기 조절
			var popupHeight = (item.FormSubKind == "T023" || type == "btConsultReq" || type == "btConsultReqCancel" || (Common.getBaseConfig("useRejectCommentAttach") == "N" && (type == "btReject" || type == "btRejectedto" || type == "btRejectedtoDept" || type == "btRejectLast"))) ? 365 : 549;
			var commonWritePopup =	CFN_OpenWindow(popupUrl, "", 540, popupHeight, 'resize');
			var iframe = document.IframeSerialApprovalFrm;

        	iframe.commonWritePopupOnload = function(){
   	    		var $iframeDom = $("#IframeSerialApprovalFrm").contents(); 
   	    		var comment = $("#ACTIONCOMMENT",$iframeDom).val();
   	    		var comment_attach = $("#ACTIONCOMMENT_ATTACH",$iframeDom).val();
   	    		var img_index = "";	    
    			switch(type) {
    	            case "btReject": case "btRejectedto": img_index = "01"; break;
    	            case "btRejectedtoDept": img_index = "02"; break;
    	            case "btRec": img_index = "03"; break;
    	            case "btApproved": img_index = "03"; break;
    	            case "btHold": img_index = "04"; break;
    	            case "btCAgree": img_index = "03"; break;
    	            case "btCDisagree": img_index = "01"; break;
    	            case "btConsultReq": img_index = "03"; break;
    	            case "btConsultReqCancel": img_index = "02"; break;
    	            default: img_index = ""; break;
   	        	}			    			
    			var $listObj = $("#approvalContent div[class^=AppSelect]").filter(function(){ return $(this).data('item').FormInstID === item.FormInstID  });
    			
    			$(".Actleft",$listObj)
    				.empty()
    				.append( $("<img>",{ "src" : "<%=cssPath%>/approval/resources/images/Approval/ico_act"+img_index+".png" }) )
    				.append( text );
    			
    			$("a > img",$listObj).remove();			    			
    			$(".Acttop",$listObj)
    				.after( $.trim( comment ).length > 0 &&
    						$("<img>",{ "id" : item.FormInstID, "src" : "<%=cssPath%>/approval/resources/images/Approval/ico_comment.png", "style" : "float: right; margin-top: -35px; margin-right: 10px;" }).data('comment',comment) );
    			$("#btSerialCancel",$iframeDom).data('item',item).show();
    			
    			var sApvlist = iframe.$("#APVLIST").val();
    			var changeApvYn = 'N';
	    		if ((!(iframe.getInfo("ApprovalLine").replace("\r\n", "") == sApvlist) && sApvlist) || iframe.strApvLineYN == "Y") {
	    			changeApvYn = 'Y';
	    		}
	    		serial.setSelectData( $.extend( item , { 'text' : text, 'imgIndex' : img_index, 'comment' : comment, 'comment_attach' : comment_attach, 'mode' : mode, 'type' : type, 'apvList' : sApvlist, 'changeApvYn' : changeApvYn, '_g_authKey' : iframe._g_authKey 	|| "", '_g_password' : iframe._g_password 	|| "",'formDraftkey' : iframe.formDraftkey, 'consultReqItem' : consultReqItem} ));
	    	};
		}
		
		this.setTabStatus = function(){
			var fieldItem = $("#selFormList option:selected").data('item');			
			var checkedLength = checkedData[ fieldItem.fieldID ] ? checkedData[ fieldItem.fieldID ].length : 0;
			$("#btnDesignated .Tabcolor_b").text( checkedLength );
			$("#btnNotDesignated .Tabcolor_b").text( fieldItem.fieldCnt - checkedLength );
			$("#btnAll .Tabcolor_b").text( fieldItem.fieldCnt );
		}
		
		this.isChecked = function( obj ){ return selectData.filter( function(item){ return item.FormInstID === obj.FormInstID })[0] };
		this.approvalExecute = function(){
			var iframe = document.IframeSerialApprovalFrm;
			return function(){
				if( selectData.length > 0 ){
					$("#leftTabs li")[1].click();
					var execute = function(){
						var item = selectData.splice(0,1)[0];
						var sSignImage;						
						item.targetObj.css("position", "relative").append( $("<div>",{ 'class' : "ani_arrow" }) );						
						if(item.FormSubKind === "T023"){
							var saveData = {
									actionComment			:	item.comment
									,actionComment_Attach	: 	item.comment_attach
									,actionUser 			: 	item.UserCode
									,workitemID				:	item.WorkItemID
									,processID				:	item.ProcessID
									,parentprocessID		:	item.ParentProcessID
									,Subject				:	item.FormSubject
									,InitiatorID			:	item.InitiatorID
									,FormInstID				:	item.FormInstID
									,FormName				:	item.FormName
									,ApprovalLine			:	JSON.parse(item.apvList)
							};
							item.type === "btCAgree" &&	(saveData.actionMode = "AGREE");
							item.type === "btCDisagree" && (saveData.actionMode = "DISAGREE");
							
						    //3.결재
						    _ajax("/approval/consultation.do", {"formObj" : Base64.utf8_to_b64(JSON.stringify(saveData))})
						    	.done(function(res){
						    		if (res.status == "SUCCESS" || (res.status == "FAIL" && res.message.indexOf("NOTASK")>-1)) {
						    			if(res.status == "FAIL"){
											res.message = Common.getDic("msg_apv_notask").replace(/(<([^>]+)>)/gi, "");
										}
						    			if( selectData.length > 0 ){
						    				$("#btnAll .Tabcolor_b").text( $("#btnAll .Tabcolor_b").text()-1 );									    			
							    			$("#btnDesignated .Tabcolor_b").text( $("#btnDesignated .Tabcolor_b").text()-1 );
							    			item.targetObj.fadeOut();
											execute();
										}else{
											//완료														
											Common.Inform(Common.getDic("msg_apv_069"), "Information Dialog", function () {
								                window.location.reload();
								                
								                if(top.opener && !top.opener.closed && top.opener.ListGrid){
								                	top.opener.ListGrid.reloadList();
								                }
								            });
										}									    												    			
						    		}else{
						    			Common.Warning(Common.getDic("msg_apv_030") + " : " + res.message);			//오류가 발생했습니다.
										selectData.unshift(item);
									}
						    	}).fail( function(response, status, error){ CFN_ErrorAjax("/approval/consultation.do", response, status, error); });		
						} else if(item.type === "btConsultReq"){
							var saveData = {
									actionComment			:	item.comment
									,actionUser 			: 	item.UserCode
									,workitemID				:	item.WorkItemID
									,processID				:	item.ProcessID
									,parentprocessID		:	item.ParentProcessID
									,Subject				:	item.FormSubject
									,InitiatorID			:	item.InitiatorID
									,FormInstID				:	item.FormInstID
									,FormName				:	item.FormName
									,ApprovalLine			:	JSON.parse(item.apvList)
									,consultUsers			:	item.consultReqItem
							};
							
						    //3.결재
						    _ajax("/approval/consultationRequst.do", {"formObj" : Base64.utf8_to_b64(JSON.stringify(saveData))})
						    	.done(function(res){
						    		if (res.status == "SUCCESS" || (res.status == "FAIL" && res.message.indexOf("NOTASK")>-1)) {
						    			if(res.status == "FAIL"){
						    				res.message = Common.getDic("msg_apv_notask").replace(/(<([^>]+)>)/gi, "");
										}
						    			if( selectData.length > 0 ){
						    				$("#btnAll .Tabcolor_b").text( $("#btnAll .Tabcolor_b").text()-1 );									    			
							    			$("#btnDesignated .Tabcolor_b").text( $("#btnDesignated .Tabcolor_b").text()-1 );
							    			item.targetObj.fadeOut();
											execute();
										}else{
											//완료														
											Common.Inform(Common.getDic("msg_apv_069"), "Information Dialog", function () {
								                window.location.reload();
								                
								                if(top.opener && !top.opener.closed && top.opener.ListGrid){
								                	top.opener.ListGrid.reloadList();
								                }
								            });
										}									    												    			
						    		}else{
						    			Common.Warning(Common.getDic("msg_apv_030") + " : " + res.message);			//오류가 발생했습니다.
										selectData.unshift(item);
									}
						    	}).fail( function(response, status, error){ CFN_ErrorAjax("/approval/consultation.do", response, status, error); });	
						} else if(item.type === "btConsultReqCancel"){
							var saveData = {
									actionComment			:	item.comment
									,actionUser 			: 	item.UserCode
									,workitemID				:	item.WorkItemID
									,processID				:	item.ProcessID
									,parentprocessID		:	item.ParentProcessID
									,Subject				:	item.FormSubject
									,InitiatorID			:	item.InitiatorID
									,FormInstID				:	item.FormInstID
									,FormName				:	item.FormName
									,ApprovalLine			:	JSON.parse(item.apvList)
							};
							
						    //3.결재
						    _ajax("/approval/consultationRequstCancel.do", {"formObj" : Base64.utf8_to_b64(JSON.stringify(saveData))})
						    	.done(function(res){
						    		if (res.status == "SUCCESS" || (res.status == "FAIL" && res.message.indexOf("NOTASK")>-1)) {
						    			if(res.status == "FAIL"){
											res.message = Common.getDic("msg_apv_notask").replace(/(<([^>]+)>)/gi, "");
										}
						    			if( selectData.length > 0 ){
						    				$("#btnAll .Tabcolor_b").text( $("#btnAll .Tabcolor_b").text()-1 );									    			
							    			$("#btnDesignated .Tabcolor_b").text( $("#btnDesignated .Tabcolor_b").text()-1 );
							    			item.targetObj.fadeOut();
											execute();
										}else{
											//완료														
											Common.Inform(Common.getDic("msg_apv_069"), "Information Dialog", function () {
								                window.location.reload();
								                
								                if(top.opener && !top.opener.closed && top.opener.ListGrid){
								                	top.opener.ListGrid.reloadList();
								                }
								            });
										}									    												    			
						    		}else{
						    			Common.Warning(Common.getDic("msg_apv_030") + " : " + res.message);			//오류가 발생했습니다.
										selectData.unshift(item);
									}
						    	}).fail( function(response, status, error){ CFN_ErrorAjax("/approval/consultation.do", response, status, error); });	
						} else {
							var saveData = {
								mode 					: 	"APPROVAL"
								,subkind 				: 	item.FormSubKind
								,taskID					:	item.TaskID
								,FormInstID				:	item.FormInstID
								,usid					:	Common.getSession()["USERID"]
								,signimagetype			:	""
								,gloct 					: 	""
								,actionMode				: 	item.mode
								,actionComment			:	item.comment
								,actionComment_Attach	: 	item.comment_attach
								,processID				:	item.ProcessID
								,UserCode 				: 	item.UserCode
								,processName			: 	item.ProcessName
								,g_authKey				: 	iframe._g_authKey 	|| ""
								,g_password				: 	iframe._g_password 	|| ""	
								,formID					:	item.FormID
								,formDraftkey			: 	item.formDraftkey							
							}
		    
							//2. 사인 이미지 가져오기
							_ajax("/approval/user/getUserSignInfo.do",{ 'UserCode' : Common.getSession("USERID") })
								.done( function(res){										
								   if(res.status == 'SUCCESS'){
										saveData.signimagetype = res.data;
							    	} else if(res.status == 'FAIL'){
							    		Common.Error(res.message);
							    	}										
									item.type === "btApproved" 	&& (saveData.actionMode = ["T009","T004"].indexOf( item.FormSubKind ) > -1 ? "AGREE"	: "APPROVAL");
									item.type === "btReject" 	&& (saveData.actionMode = ["T009","T004"].indexOf( item.FormSubKind ) > -1 ? "DISAGREE"	: "REJECT"	);									    
									//mode값 정리
									if(item.FormSubKind == "T009" || item.FormSubKind == "T004"){		// 합의 및 협조
										saveData.mode = "PCONSULT";
									}else if(item.FormSubKind == "T016"){
										saveData.mode = "AUDIT";
									}
									if(item.ProcessName == "Sub"){
										saveData.mode = "SUBAPPROVAL";
									}											
									// 대결자가 결재하는 경우 결재선 변경 / 상세조회후 선택한 시점의 결재선정보를 사용.
									/*
									if(arrDomainDataList[item.ProcessID] != null && arrDomainDataList[item.ProcessID] != undefined) {
									    var apvList = setDeputyList(saveData.mode,saveData.subkind,saveData.taskId,saveData.actionMode,saveData.actionComment,saveData.FormInstID,false,saveData.processID,saveData.UserCode);									    
									    apvList !== arrDomainDataList[item.processID] && ( saveData['ChangeApprovalLine'] = apvList );
									}
								   */
									var sApvlist = item.apvList;
	  								if (item.changeApvYn == 'Y') {
	  									saveData['ChangeApprovalLine'] = sApvlist; // 최종 승인/반려시 설정된 결재선 정보(사용자 or 자동)
	  								}
								   
								    var formData = new FormData();
								    formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(saveData)));
								    
								    //3.결재
								    _ajax("/approval/draft.do", formData, false )
								    	.done(function(res){
								    		if (res.status == "SUCCESS" || (res.status == "FAIL" && res.message.indexOf("NOTASK")>-1)) {
								    			if(res.status == "FAIL"){
													res.message = Common.getDic("msg_apv_notask").replace(/(<([^>]+)>)/gi, "");
												}
								    			if( selectData.length > 0 ){
								    				$("#btnAll .Tabcolor_b").text( $("#btnAll .Tabcolor_b").text()-1 );									    			
									    			$("#btnDesignated .Tabcolor_b").text( $("#btnDesignated .Tabcolor_b").text()-1 );
									    			item.targetObj.fadeOut();
													execute();
												}else{
													//완료														
													Common.Inform(Common.getDic("msg_apv_069"), "Information Dialog", function () {
										                window.location.reload();
										                
										                if(top.opener && !top.opener.closed && top.opener.ListGrid){
										                	top.opener.ListGrid.reloadList();
										                }
										            });
												}									    												    			
								    		}else{
								    			Common.Warning(Common.getDic("msg_apv_030") + " : " + res.message);			//오류가 발생했습니다.
												selectData.unshift(item);
											}
								    	}).fail( function(response, status, error){ CFN_ErrorAjax("/approval/draft.do", response, status, error); });									     
								}).fail( function(response, status, error){ CFN_ErrorAjax("getUserSignInfo.do", response, status, error); });
						}
					}
					execute();
				} else {
					Common.Warning(Common.getDic("msg_apv_notExistSerialDoc"));
				}
			}			
		}
	}
	//문서보기
	var approvalView = function(item){		
		var url = "/approval/approval_Form.do?mode=APPROVAL";
		url += "&processID=" + item.ProcessID;
	    url += "&workitemID=" + item.WorkItemID;
	    url += "&performerID=" + item.PerformerID;
	    url += "&processdescriptionID=" + item.ProcessDescriptionID;
	    url += "&subkind=" + item.FormSubKind;
	    url += "&userCode=" + item.UserCode; // 빈값으로 넘기면, 병렬결재에서 대결자로 인식하여 수정함.		    
	    url += "&gloct=APPROVAL&formID=&forminstanceID=&formtempID=&forminstancetablename=&admintype=&archived=false&usisdocmanager=true&listpreview=N";
	    url += "&bserial=true";
	    url += "&ExpAppID=" + item.BusinessData2;
	    url += "&taskID=" + item.TaskID;
	    
	    $("#IframeSerialApprovalFrm").attr('src', url);
	    window.resizeTo(1600, window.screen.height);
	    
	    document.getElementById("IframeSerialApprovalFrm").onload = function() {
	    	var chkData = serial.isChecked( item );
	    	var $btn	= $("#IframeSerialApprovalFrm").contents().find("#btSerialCancel").data('item',chkData);
	    	$("#IframeSerialApprovalFrm").css("height", window.innerHeight + "px");
	        $("#IframeSerialApprovalFrm").contents().find("body").css("-ms-overflow-style", "none");
	        !chkData	&& $btn.hide();
	        chkData 	&& $btn.show();
	    }		
	}

	// 결재문서 버튼 callback
	var setStateSerialApprovalList = function(type, text, mode, consultReqItem) {		
		if(type !== "btSerialCancel") {
	        /* 의견입력 */
			serial.popup(type, text, mode, consultReqItem);
	    } else {
	    	/* 선택취소 */	    	
	    	var $btn = $("#IframeSerialApprovalFrm").contents().find("#btSerialCancel");
	    	var item = $btn.data('item');
	    	$("#checkedList > div").filter(function(){ return $(this).data('item').FormInstID === item.FormInstID  }).remove();	    	
	    	$("#approvalList > div").map(function(){ $(this).data('item').FormInstID === item.FormInstID && $('.Actleft',this).empty() && $('img',this).remove() });	    	
	    	$btn.hide();	    	
	    	serial.removeSelectData( $btn.data('item') );
	    }
	}
	
	$(document).ready(function () {
		
		serial = new serialEvent();
		
		/* 양식 이벤트 */
		$('#selFormList').on('change',function(){
			var _item = $("option:selected",this).data('item');			
			serial.setData({
				searchGroupWord 	:	_item.fieldName ? _item.fieldID : ""
				,searchGroupType 	:	_item.fieldName ? "FormPrefix" : ""
				,pageNo 			:	1
			});			
			serial.getApprovalList()
			    .done(function(data){	
			    	serial.approvalListDraw( data.list ).appendTo( $("#approvalList").empty() );
			    	var obj 	= $("#approvalList .AppSelect_off:eq(0)");
			    	var item 	= obj.data('item');
			    	var list 	= serial.getCheckedData()[_item.fieldID] || [];
			    	obj.prop('class',"AppSelect_on");
			    	item && approvalView(item);			    	
			    	$("#btnAll").trigger('click');
			    	serial.approvalListDraw( list ).appendTo( $("#checkedList").empty() );
			    	serial.setTabStatus();
			    	$("#btnAll .Tabcolor_b").text() > 10 	&& $("#divMore").show();
			    	$("#btnAll .Tabcolor_b").text() <= 10 	&& $("#divMore").hide();
			    })
			    .fail(function(response, status, error){ CFN_ErrorAjax("/approval/user/getApprovalListData.do", response, status, error); });
			
		}).trigger('change');
		
		/* 결재문서 선택 이벤트 */
		$("#approvalContent").on('click',function(){			
			if( $(event.target).data('comment') ){
				/* 의견 레이어 */
				var comment = Base64.b64_to_utf8( $(event.target).data('comment') ).replace(/\n/gi, "<br/>");
				 Common.openballoon( $(event.target).prop('id') , "BalloonDivPopupLayer", "", comment, "200px", "100px", null, null, "right", event);
			     if($("#BalloonDivPopupLayer_p").length > 0) {
				    $("#BalloonDivPopupLayer_p").css("left", Number($("#BalloonDivPopupLayer_p").css("left").replace("px", ""))+200+"px");
				    $("#BalloonDivPopupLayer_p").css("position", "absolute");
				    $("#BalloonDivPopupLayer_p").css("border", "1px solid #c2c5c7");
				    $("#BalloonDivPopupLayer_p").css("background-color", "white");
				    $("#BalloonDivPopupLayer_p").find("p").css("padding", "10px");
			    }			
			}else{
				/* 결재문서 열기 */
				var item = $(event.target).parents('a').parent().data('item');
				item && approvalView(item);
				item && $("#approvalContent .AppSelect_on").prop('class','AppSelect_off');
				$(event.target).parents('.AppSelect_off').prop('class','AppSelect_on');	
			}			
		});
		
		/* 문서 탭 */
		$("#leftTabs li").on('click',function(){
			var id =  this.id;
			switch( id ){
				case "btnAll" :
					serial.approvalAllVw();
					break;
				case "btnDesignated" :
					serial.approvalChkVw();
					break;	
				case "btnNotDesignated" :
					serial.approvalNotChkVw();
					break;
			}
			$(this).parent().find('li').removeClass('active').eq( $(this).index() ).addClass('active');
		});
		
		/* 더보기 */
		$("#divMore").on('click',function(){
			var nextPage = serial.getPageNo()+1;
			var pageSize = serial.getPageSize();
			var categoryCnt = $("#selFormList option:selected").data('item').fieldCnt;
			( nextPage*pageSize ) >= categoryCnt && $("#divMore").hide();
			
			serial.setData({ pageNo : nextPage });
			serial.getApprovalList()
			    .done(function(data){
			    	var loadInstIds = $("#divAppconContentBoxList > div").map( function(){ return $(this).data('item').FormInstID });			    	
			    	var filterList = data.list.filter( function(item){ return Array.prototype.indexOf.call(loadInstIds,item.FormInstID) === -1 });			    	
			    	serial.approvalListDraw( filterList ).appendTo( $("#approvalList") );
			    })
			    .fail(function(){ CFN_ErrorAjax("/approval/user/getApprovalListData.do", response, status, error); });
		});		
		//실행
		$('#approvalExecute').on('click', serial.approvalExecute() );
	});
</script>
</html>