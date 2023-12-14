<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!-- URI Encoding 항목 삭제 -->
<%
	//String checkYn = request.getParameter("ListView");
	String checkYn = StringUtil.replaceNull(request.getParameter("ListView"),"N");;
%>
<script>
$(document).ready(function (){
	$("#detpNm").html(Common.getSession("DEPTNAME"));
	$("#userInfo").html(Common.getSession("USERNAME"));
	$("#jobPositionName").html(Common.getSession("UR_JobPositionName"));
	var userImg = Common.getBaseConfig('ProfileImagePath',1)+Common.getSession("USERID")+".jpg";
	$("#userImg").attr("src",userImg);
	
	//grid상단에 기본검색,상세검색에 포함되는 input항목에 Enter 조회
	$("#searchInput, div[class=searchInner] input").keydown(function (key) {
		  if (key.keyCode == 13) {
			  onClickSearchButton();
		  }
	});
	
	$("#userImg").error(function() {
        $("img").attr("src",  Common.getBaseConfig('ProfileImagePath',1)+"noimg.png");
    });

});


</script>
<div class="top_n_menu">
	<dl class="subUser">
		<dt>
			<a href="#none" class="mainPro"><img id="userImg" style="max-width: 100%; height: auto;" alt=""></a>
		</dt>
		<dd class="userName"><span id="userInfo"></span> <span id="jobPositionName"></span></dd>
		<dd class="userTeam" id="detpNm"></dd>
		<dd class="mainAdmin"><a href="/approval/approvaladmin_approvaladmin.do">admin</a></dd>
		<%
			if(checkYn.equals("Y")){
		%>
<!-- 		<dd><a class="AXButton" href="#ax" onclick="onClickListView();">미리보기</a></dd> -->
		<%
			}
		%>
		<dd>
			<ul class="rightMenu">			
				<li>현재세션 : <span id="txtCurrentSession"></span>(<span id="txtCurrentDept"></span>)</li>
				<li><select id="selUserID"><option value="bjlsm2" pw="1">이승목(경)</option><option value="bigkbhan2" pw="1">한기복(경)</option><option value="baejh2" pw="1">배종현(경)</option><option value="bsseo2" pw="1">서봉수(경)</option><option value="bkj8282" pw="1">배광진(비)</option><option value="bluejust2" pw="1">황인원(비)</option></select></li>
				<!-- <li><select id="selDeptID"><option value="U20000003">경영전략</option><option value="U20000002">비서실</option></select></li> -->
				<li><a href="#" onclick="changeSession(); return false;">세션변경</a></li>
				<li><a href="/approval/approvaladmin_approvaladmin.do">관리자</a></li>
				<li><a href="#" onclick="clearMenuCache(); return false;">캐시삭제</a></li>
				<li><a href="#">겸직변경</a></li>
				<li> 				
					<div class="selBox" style="width:61px;" >
	                    <span class="selTit" ><a id="selLangID" onclick="clickSelectBox(this);" value="ko" class="up">Korean</a></span> <!---->                    
	                    <div class="selList" style="width:77px;display: none;"> <!-- style="display:none;"-->
		         			<a class="listTxt select" value="ko" onclick="clickSelectBox(this);" id="Korean">Korean</a>
		                    <a class="listTxt" value="en" onclick="clickSelectBox(this);" id="English">English</a>
		         			<a class="listTxt" value="zh" onclick="clickSelectBox(this);" id="Chinese">chinese</a>
		                    <a class="listTxt" value="ja" onclick="clickSelectBox(this);" id="Japanese">japanese</a>
	         			</div>
				    </div>
				</li>
				<!-- <li><select id="selLangID"><option value="ko">한국어</option><option value="en">영어</option><option value="ja">일본어</option><option value="zh">중국어</option></select></li> -->
				<li><a href="javascript:XFN_LogOut();" class="topLogout">로그아웃</a></li>
			</ul>
		</dd>
	</dl>
</div>
