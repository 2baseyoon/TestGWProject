<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>
	<div class="layer_divpop ui-draggable resourcePopLayer" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="resPopContent">
					<div class="top clearFloat resTopPhotoView">
						<div class="photoViewBox">
							<img id="resourceImage" style="width: 128px; height:109px" onerror="coviCmn.imgError(this)">
						</div>
						<div>
							<p id="ParentFolderName"></p>
							<h2 id="ResourceName" class="mt10"></h2>											
						</div>						
					</div>
					<div class="middle mt20">
						<div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_Res_Admin' /></span></div>
								<div id="ManagerList" class="textBox">
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_ReservationProc' /></span></div><!-- 예약절차 -->
								<div>
									<p id="BookingType" class="textBox"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_resource_rentalTime' /></span></div><!-- 대여 시간 -->
								<div>
									<p id="LeastRentalTime" class="textBox"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_Equipment' /></span></div><!-- 지원장비 -->
								<div id="EquipmentList" class="textBox"></div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_DescriptionURL' /></span></div><!-- 부가설명URL -->
								<div>
									<a id="DescriptionURL" class="textBox"></a>
								</div>
							</div>
							<div id="AttributeBottom" class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_Description' /></span></div><!-- 설명 -->
								<div>
									<p id="Description" class="textBox"></p>
								</div>
							</div>
						</div>
					</div>
					<div class="bottom mt20">
						<a onclick="Common.Close();" class="btnTypeDefault"><spring:message code='Cache.btn_Close' /></a><!-- 닫기 -->
					</div>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

initContent();

function initContent(){
	$.ajax({
	    url: "/groupware/resource/getResourceData.do",
	    type: "POST",
	    data: {
	    	"FolderID" : CFN_GetQueryString("folderID")
		},
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		
	    		// Folder Data
	    		if(res.data.folderData){
	    			var folderData = res.data.folderData;
	    			
	    			$("#ResourceName").html(folderData.ResourceName);
	    			
	    			if(folderData.PlaceOfBusiness != "" && folderData.PlaceOfBusiness != undefined){
	    				var placeOfBusinessStr = "";
	    				var placeOfBusinessArr = folderData.PlaceOfBusiness.split(";");
	    				
	    				for(var i=0; i<placeOfBusinessArr.length-1; i++){
	    					placeOfBusinessStr = CFN_GetDicInfo($$(Common.getBaseCode("PlaceOfBusiness")).find("CacheData[Code="+placeOfBusinessArr[i]+"]").attr("MultiCodeName"), parent.lang);
	    					
	    					$("#PlaceOfBusiness").append(placeOfBusinessStr);
	    					
	    					if(placeOfBusinessArr.length-2 != i)
	    						$("#PlaceOfBusiness").append(", ");
	    				}
	    			}else{
	    				$("#PlaceOfBusiness").hide();
	    			}
	    			
	    			$("#ParentFolderName").html(checkNoData(folderData.ParentFolderName));
	    			
	    			$("#Description").html(checkNoData(folderData.Description).replace(/(\r\n|\n|\n\n)/gi, '<br />'));
	    			
	    			// 배경이미지
		    		if(folderData.ResourceImage != "" && folderData.ResourceImage != undefined){
		    			$(".photoViewBox").css("background", "none");
/*		    			$("#resourceImage").attr("onerror", coviCmn.imgError());*/
		    			$("#resourceImage").attr("src", "/covicore/common/view/Resource/"+folderData.ResourceImage+".do");
		    		}
	    		}
	    		
	    		// Resource Data
	    		if(res.data.resourceData){
	    			var resourceData = res.data.resourceData;
	    			
	    			$("#BookingType").html(checkNoData(resourceData.BookingType));
	    			
	    			$("#DescriptionURL").html(checkNoData(resourceData.DescriptionURL));
	    			
	    			if(resourceData.DescriptionURL != "" && resourceData.DescriptionURL != null && resourceData.DescriptionURL != undefined){
	    				$("#DescriptionURL").attr('href', resourceData.DescriptionURL);
	    				$("#DescriptionURL").attr('target', '_blank');
	    			}
	    			
	    			$("#LeastRentalTime").html("<spring:message code='Cache.lbl_resource_leastMin'/>".replace("{0}", resourceData.LeastRentalTime));		//최소 {0}분 이상
	    		}
	    		
	    		if(res.data.managerList.length>0){
	    			var managerStr = "";
	    			$(res.data.managerList).each(function(i){
	    				var subjectName = this.SubjectName;
	    				
	    				if(i != 0){
	    					managerStr += '<span>,</span>';
	    				}
	    				
	    				managerStr += '<div class="personBox">';
	    				
	    				if(this.UserType == "User"){
	    					managerStr += '<div class="perPhoto">';
		    				managerStr += '<img src="'+coviCmn.loadImage(this.PhotoPath)+'" style="width:100%;height:100%;" alt="<spring:message code="Cache.lbl_ProfilePhoto" />">';		//프로필사진
		    				managerStr += '</div>';
		    				
		    				subjectName = subjectName + " " + this.UserPositionName + " (" + this.UserDeptName + ")";
	    				}
	    				
	    				managerStr += '<p class="name">';
	    				managerStr += '<span>'+subjectName+'</span>';
	    				managerStr += '</p>';
	    				managerStr += '</div>';
	    			});
	    			$("#ManagerList").html(managerStr);
	    		}else{
	    			$("#ManagerList").html("<spring:message code='Cache.lbl_noexists' />");		//없음
	    		}
	    		
	    		// Attribute List
	    		if(res.data.attributeList.length>0){
	    			var attributeStr = "";
	    			$(res.data.attributeList).each(function(){
	    				attributeStr += '<div class="inputBoxSytel01 type03">';
	    				attributeStr += '<div><span>'+this.AttributeName+'</span></div>';
	    				attributeStr += '<div class="textBox">'+this.AttributeValue+'</div>';
	    				attributeStr += '</div>';
	    			});
	    			$(attributeStr).insertBefore("#AttributeBottom");
	    		}
	    		
	    		// Equipment List
	    		if(res.data.equipmentList.length>0){
	    			$(res.data.equipmentList).each(function(){
	    				$("#EquipmentList").append('<span class="btnType02 btnNormal">'+this.EquipmentName+'</span>');
	    			});
	    		}else{
	    			$("#EquipmentList").html("<spring:message code='Cache.lbl_noexists' />");		//없음
	    		}
	    		//컨텐츠에 맞춰 레이어 크기 조정
	    		Common.toResizeDynamic("resourceInfo_Popup","testpopup_p");
	    		
	    	} else {
				Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
			}
	    },
	    error:function(response, status, error){
			CFN_ErrorAjax("/groupware/schedule/getThemeList.do", response, status, error);
		}
	});
}

function checkNoData(value){
	if(value == "" || value == undefined)
		return "<spring:message code='Cache.lbl_noexists' />";		//없음
	else
		return value;
}
</script>