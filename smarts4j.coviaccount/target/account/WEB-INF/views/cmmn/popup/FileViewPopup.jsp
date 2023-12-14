<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>
	<input id="receiptID"	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:340px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">					
					<img src="" name="fileArea" alt="" style="width:300px;height:400px">
					<a onclick="FileViewPopup.zoomLayer()" class="btn_zoom" style="top:45%; left:50%;"></a>
				</div>
				<div class="bottom">
					<a onclick="FileViewPopup.closeLayer()"	id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
	
	if (!window.FileViewPopup) {
		window.FileViewPopup = {};
	}

	(function(window) {
		var FileViewPopup = {
				
				params: {},
				popupInit : function() {
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						me.params[paramKey] = paramValue
					}
					
					if(me.params.fileURL != null){
						$("[name=fileArea]").attr("src", me.params.fileURL)
					}
					else{
						me.getFileInfo();
					}
				},
				
				getFileInfo : function(){
					var me = this;
					$.ajax({
						url	:"/account/EAccountFileCon/getFileURLInfo.do?",
						type: "POST",
						data: {
							FileID : me.params.fileID
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								if(data.info != undefined) {
									var info = data.info;
									$("[name=fileArea]").attr("src", coviCmn.loadImage(info.URLPath));
									if(me.params.zoom == "Y") {
										$("[name=fileArea]").css("width", "450px");
										$("[name=fileArea]").css("height", "600px");
										$("#testpopup_p").css("width", "490px");
										$(".btn_zoom").hide();
									}
								}
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // data.message	
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
						}
					});
				},
				
				zoomLayer : function() {
					var me = this;
					
					me.closeLayer();
					var info = {
							'FileID' : me.params.fileID
					}
					
					try{
						accountCtrl.popupCallBackStr([info]);
					}catch (e) {
						coviCmn.traceLog(e);
						coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
					}
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.FileViewPopup = FileViewPopup;
	})(window);
	
	FileViewPopup.popupInit();
</script>