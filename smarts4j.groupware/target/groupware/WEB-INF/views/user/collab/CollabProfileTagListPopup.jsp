<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:360px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02 treeRadioPop">
			<div class="bottom">
			
				<div class="org_list_box mScrollV scrollVType01 mCustomScrollbar" style="height:105px;text-align: left;margin-bottom:20px;" id="profileTag"></div>
				
				<div class="popBottom">
					<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code="Cache.btn_Confirm"/></a>	<!-- 확인 -->
					<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code="Cache.btn_Cancel"/></a>				<!-- 취소 -->
				</div>
			</div>
		</div>
	</div>	
</div>

<script type="text/javascript">
var collabProfileTag= {
		objectInit : function(){
			
			$.each(parent.$('#subViewMember').find(".user_img"), function (i, v){
				var type = 'UR';
				var code = $(v).attr("code");
				var img = (img != undefined) ? $(v).find("img").attr("src") : "";
				var titleArr = $(v).attr("title").split(' | ');

				var cloned = collabUtil.drawProfile({"code":code,"type":type,"PhotoPath":img,"DisplayName":titleArr[1],"DeptName":titleArr[0]}, true);
				$('#profileTag').append(cloned);
			});
			
			this.addEvent();
		},
		addEvent : function(){
			
			//사용자나 부서/ 일자 삭제
			$(document).on('click', '.btn_del', function(e) {
				e.preventDefault();
				$(this).parent().remove();
			});
			
			//닫기
			$("#btnClose").on('click', function(){
				Common.Close();
			});
			
			//저장
			$("#btnSave").on('click', function(){
				var personCnt = $('#profileTag').find(".user_img").length;
				
				parent.$('#subViewMember').text("");
				$.each($('#profileTag').find(".user_img"), function (i, v){
					var type = 'UR';
					var code = $(v).attr("code");
					var img = (img != undefined) ? $(v).find("img").attr("src") : "";
					var titleArr = $(v).attr("title").split(' | ');

					var cloned = collabUtil.drawProfileOne({"code":code,"type":type,"PhotoPath":img,"DisplayName":titleArr[1],"DeptName":titleArr[0], "personCnt":personCnt}, true);
					parent.$('#subViewMember').append(cloned);
				});
				
				Common.Close();
			})
		}
}

$(document).ready(function(){
	collabProfileTag.objectInit();
});


</script>
