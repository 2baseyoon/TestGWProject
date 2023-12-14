<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.inPerView{width:100%}
</style>
    <!-- 상단 끝 -->
    <div class="cRConTop titType">
        <h2 class="title"><spring:message code='Cache.lbl_PersonalPreference' /></h2> <!-- 개인환경 설정 -->
    </div>
    
    <div class="cRContCollabo mScrollVH">
<form id="frm">
        <!-- 컨텐츠 시작 -->
        
        <div id="contentDiv" class="PsettingContent">
			<section class="PsettingContTop">
				<article>
					<h3><spring:message code='Cache.msg_collab13' /></h3>	<!-- 대쉬보드 테마 설정 -->
					<div class="settingListcheck">
						<input type="radio" name="theme" id="radio01" value="CLASSIC" class="setting_check" checked="">
							<label for="scheck1" id="scheck1Lb">
								<h4><spring:message code='Cache.msg_collab14' /></h4>	<!-- 클래식 테마 -->
								<p>(<spring:message code='Cache.msg_collab15' />)</p>	<!-- 대쉬보드 표시 창이 솔리드 한 컬러로 표현됩니다. 시인성이 보다 개선됩니다. -->
							</label>
						</div>
						<div class="settingListcheck">
							<input type="radio" name="theme" id="radio02" value="MODERN" class="setting_check">
								<label for="scheck1" id="scheck2Lb">
									<h4><spring:message code='Cache.msg_collab16' /></h4>	<!-- 모던 테마 -->
									<p>(<spring:message code='Cache.msg_collab17' />)</p>	<!-- 대쉬보드 표시 창의 라인에만 컬러가 표현됩니다. 눈이 덜 피로합니다. -->
								</label>
							</div>
				</article>
				<article>
				<h3><spring:message code='Cache.msg_collab18' /></h3>	<!-- 업무카드 표시 형식 설정 -->
				<div class="settingListcheck">
					<input type="radio" name="menu" id="radio03" value="POPUP" class="setting_check" checked="">
						<label for="scheck3" id="scheck3Lb">
							<h4><spring:message code='Cache.msg_collab19' /></h4>	<!-- 팝업 메뉴 -->
							<p>(<spring:message code='Cache.msg_collab20' />)</p>	<!-- 업무카드 클릭 시 별도 팝업 창으로 표시됩니다. -->
						</label>
					</div>
					<div class="settingListcheck">
						<input type="radio" name="menu" id="radio04" value="SLIDING" class="setting_check">
							<label for="scheck4" id="scheck4Lb">
								<h4><spring:message code='Cache.msg_collab21' /></h4>	<!-- 슬라이딩 메뉴 -->
								<p>(<spring:message code='Cache.msg_collab22' />)</p>	<!-- 업무카드 클릭 시 업무카드가 화면 왼쪽에서 오른쪽으로 슬라이딩 되며 표시됩니다. -->
							</label>
						</div>
				</article>
			</section>
		</div>
        
		<!-- 컨텐츠 끝 -->
</form>
    </div>

 
<script type="text/javascript">   
<!--

//개인 설정
var collabUserConf = {
		objectInit : function(){
			this.addEvent();
			this.searchData();
		}	,
		addEvent : function(){
			//저장
			$(".settingListcheck").on('click',function(){
				collabUserConf.saveCollabUserConf();
			});
		},
		searchData:function(){
			
			$.ajax({
				type:"POST",
				url:"/groupware/collabAdmin/getCollabUserConf.do",
				success:function (data) {
					
					if(data.status == "SUCCESS"){
						var result = data.data;
						
						//대쉬테마
						if(result.DashThema == "CLASSIC"){
							$("#radio01").attr("checked", true);
							$("#radio02").attr("checked", false);
						} else if(result.DashThema == "MODERN"){
							$("#radio01").attr("checked", false);
							$("#radio02").attr("checked", true);
						}
						
						//업무표시
						if(result.TaskShowCode == "POPUP"){
							$("#radio03").attr("checked", true);
							$("#radio04").attr("checked", false);
						} else if(result.TaskShowCode == "SLIDING"){
							$("#radio03").attr("checked", false);
							$("#radio04").attr("checked", true);
						}
					}
					
				} 
			});
		},
		saveCollabUserConf : function(){
			var data = $("#frm").serializeObject();
			
			$.ajax({
				url:"/groupware/collabAdmin/saveCollabUserConf.do",
				type:"post",
				data:data,
				dataType:"json",
				success : function(res) { 
					if (res.status == "SUCCESS") {
						Common.Inform("<spring:message code='Cache.msg_Processed' /><br><spring:message code='Cache.msg_dashboardChg' />","Information",function(){
							collabMenu.myConf = {"dashThema":$("input[name='theme']:checked").val(),"taskShowCode":$("input[name='menu']:checked").val()};
			    		});
					}else {
						Common.Warning("<spring:message code='Cache.msg_apv_030' />");
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/adminSetting/setCompanySetting.do", response, status, error);
				}
			});
		}
}

$(document).ready(function(){
	collabUserConf.objectInit();
});

//-->
</script>
    
    
    
    