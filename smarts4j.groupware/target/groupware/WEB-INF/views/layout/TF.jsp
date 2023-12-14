<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>

<tiles:insertAttribute name="commonScripts" />
<body>	
	<div id="wrap" class="individualCommunityContainer mScrollVH">
	 	<div class="individualCommunity">
			<header>
				<tiles:insertAttribute name="header" />
			</header>
			<article class="individualVisitorCountCont">
				<tiles:insertAttribute name="subHeader" /> 
			</article>
			<section class="individualContent clearFloat" id="portContent">
				<section class="individualLeftCont">
					<tiles:insertAttribute name="left" /> 
				</section>
				<section class="individualRigntCont" id="content">
					<tiles:insertAttribute name="content" />				
				</section>
				
			</section>
		</div>
	</div>
</body>
