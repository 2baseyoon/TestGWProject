<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!-- 컨텐츠 해더 Start -->
<div class="content_header">
	<h3 class="left">댓글</h3>
	<div class="right"></div>
</div>
<!-- 컨텐츠 해더 End -->
<!-- 컨텐츠 Start -->
<div class="cRContBottom mScrollVH">
	<div class="scheduleContentType02">
		<p class="link_figure"><img class="thumb_g" dmcf-mid="LZnxJgHWJq" dmcf-mtype="image" height="297" src="https://img2.daumcdn.net/thumb/R658x0.q70/?fname=https://t1.daumcdn.net/news/201709/22/SpoChosun/20170922135754510xmxr.jpg" width="260" /></p>
		<br/>
		<div>[스포츠조선 정준화 기자] 라붐 율희가 FT아일랜드 민환과 사진을 페이스북 계정에 올려 열애설이 불거진 가운데, 양 측이 열애 사실을 인정했다.</div>
		<br/><br/><br/>
		<div id="targetSocial"></div>
	</div>
</div>
<!-- 컨텐츠 End -->
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.editor.js<%=resourceVersion%>"></script>
<script type="text/javascript">
	initContent();
	
	function initContent(){
		coviComment.load('targetSocial', 'Social', '11');
	}
	
</script>
