<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- <nav class="lnb"> -->
<!-- 	<h2 class="gnb_left_tit"><span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">전자결재</span></h2> -->
<!-- 	<ul class="lnb_list"> -->
<!-- 	</ul> -->
<!-- </nav> -->
 <div class="lmb_wrap">
   <h1 class="brand"><a onclick="leftmenu_goToPageMain(); window.sessionStorage.setItem('UserLeftID', '');"><img src="/approval/resources/images/Approval/logo.gif" alt="CoviFlow"></a></h1>
   <ul class="lmb_menu">
   </ul>
 </div>
<script type="text/javascript">
	var leftdata = ${userapprovalleft};
	var jobfunctionCnt;
	var BizDocListCnt;
	var approvalCnt; // 개인결재함-미결함
	var processCnt; // 개인결재함-진행함
	var tcInfoCnt; // 개인결재함-참조/회람함
	var receiveCnt; // 부서결재함-수신함
	var deptTcInfoCnt; // 부서결재함-참조/회람함

	function leftmenu_goToPageMain(){
		location.href = "/approval/approval_home.do";
	}

	$(document).ready(function (){
		getJobFunctionCount();
		getBizDocListCount();
		getApprovalListCount();
		drawuserleftmenu(leftdata);


		$(window).resize(function(){
			$('.lmb_menu').slimScroll({
		        height: ($(window).height()-80)+'px',
		        color: '#FFFFFF',
		        opacity : .3,
		        alwaysVisible: true
		    });
		}).resize();
		
		$("*[alias=audit]").css("display","none");
		$("*[alias=audit]").parent().css("display","none");

		if(jobfunctionCnt <= 0){
			$("*[alias=jobfunction]").css("display","none");
			$("*[alias=jobfunction]").parent().css("display","none");
		}
		if(BizDocListCnt <= 0){
			$("*[alias=bizdoc]").css("display","none");
			$("*[alias=bizdoc]").parent().css("display","none");
		}
		
	});

	function getJobFunctionCount(){
		$.ajax({
			type:"POST",
			url:"user/getJobFunctionCount.do",
			async: false, //jobfunctionCnt 값이 설정 안된 채로 메뉴목록을 그리는 현상 방지
			success:function (data) {
				if(data.result=="ok"){
					jobfunctionCnt = data.cnt;
				}
			},
			error:function (error){
				alert(error.message);
			}
		});
	}

	function getBizDocListCount(){
		$.ajax({
			type:"POST",
			url:"user/getBizDocCount.do",
			async: false, //BizDocListCnt 값이 설정 안된 채로 메뉴목록을 그리는 현상 방지
			success:function (data) {
				if(data.result=="ok"){
					BizDocListCnt = data.cnt;
				}
			},
			error:function (error){
				alert(error.message);
			}
		});
	}

	function getApprovalListCount(){
		//개인-미결함
		$.ajax({
			url:"user/getApprovalNotDocReadCnt.do",
			type:"post",
			async:false,
			success:function (data) {
				approvalCnt = data.cnt;
			}
		});
		//개인-진행함
// 		$.ajax({
// 			url:"user/getProcessNotDocReadCnt.do",
// 			type:"post",
// 			async:false,
// 			success:function (data) {
// 				processCnt = data.cnt;
// 			}
// 		});
		//개인-참조/회람함
		$.ajax({
			url:"user/getTCInfoNotDocReadCnt.do",
			type:"post",
			async:false,
			success:function (data) {
				tcInfoCnt = data.cnt;
			}
		});

		//부서-수신함
		$.ajax({
			url:"user/getDeptProcessNotDocReadCnt.do",
			type:"post",
			async:false,
			success:function (data) {
				receiveCnt = data.cnt;
			}
		});
		// 부서-참조/회람함
		$.ajax({
			url:"user/getDeptTCInfoNotDocReadCnt.do",
			type:"post",
			async:false,
			success:function (data) {
				deptTcInfoCnt = data.cnt;
			}
		});
	}
</script>
