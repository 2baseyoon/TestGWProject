<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
    
<script>
	function callACLPop(){
		CFN_OpenWindow("control/callacl.do?lang=en&allowedACL=_____V_&orgMapCallback=orgCallback&aclCallback=aclCallback","권한지정",1000,580,"");
	}
	
	var coviACL;
	function renderingACL(){
		//coviACL.init({'lang' : 'ko', 'hasItem' : 'false', 'orgMapCallback' : 'callOrgMapForACLCallBack'});
		//$('#con_acl').html(coviACL.render());	
		//coviACL.eventBind();
		
		var option = {
				lang : 'ko', 
				//hasItem : 'false', 
				//allowedACL : '_____V_',
				allowedACL : '',
				orgMapCallback : 'orgCallback',
				aclCallback : 'aclCallback'
				};
		
		coviACL = new CoviACL(option);
		coviACL.render('con_acl');
		
		//var coviACL1 = new CoviACL({'lang' : 'en', 'hasItem' : 'false', 'orgMapCallback' : 'callback1'});
		//coviACL1.render('con_acl1');
		
	}
	
	function orgCallback(data){
		coviACL.addSubjectRow(data);
	}
	
	function aclCallback(data){
		
	}
	
	function renderingDic(){
		var option = {
				lang : 'ko',
				hasTransBtn : 'true',
				allowedLang : 'ko,en,zh,lang1',
				useShort : 'false',
				dicCallback : 'dicCallback'
		};
				
		coviDic.render('con_dic', option);
	}
	
	function callDicPop(){
		var option = {
				lang : 'ko',
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh,lang1',
				useShort : 'false',
				dicCallback : 'dicCallback'
		};
		
		var url = "";
		url += "control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		
		CFN_OpenWindow(url,"권한지정",1000,580,"");
	}
	
	function dicCallback(data){
		Common.Inform(data);
	}
	
	function selectACL(){
		$.ajax({
			type:"POST",
			data:{
				"ObjectID" : "4",
				"ObjectType" : "MN"
			},
			url:"menu/getacl.do",
			success : function (res) {
				if(res.result == "ok"){
					coviACL.set(res.data);
				} else {
					Common.Error("Fail.");
				}
			},
			error : function(response, status, error){
				CFN_ErrorAjax("menu/getmenu.do", response, status, error);
			}
		});
	}
	
	function renderDomainSelect(){
		coviCtrl.renderDomainAXSelect('selectDomain', 'ko', null, null, 'ORGROOT');
	}
	
</script>
<form id="form1">
	<div>
		<a onclick="renderDomainSelect();">도메인 select call</a>
		<br/>
		<p>
			CoviCtrl.renderDomainAXSelect(target, lang, onchange, oncomplete, defaultVal);
			
		</p>
		<br/>
		<select class="AXSelect" id="selectDomain"></select>
	
		<h1>■ 권한 지정 Helper</h1>
		<ul>
			<li class="off over_non"><a onclick="callACLPop();">권한 PopUp</a></li>
			<li class="off over_non"><a onclick="selectACL();">data setting</a>	</li>
			<li class="off over_non"><a onclick="renderingACL();">권한 지정 rendering</a>	</li>
		</ul>
	</div>
	
	<div id="con_acl"></div>
	<br />
	<div id="con_acl1"></div>
	
	<div style="margin-top:20px;">
		<h1>■ 다국어 지정 Helper</h1>
		<ul>
			<li class="off over_non"><a onclick="callDicPop();">다국어 지정 popup</a></li>
			<li class="off over_non"><a onclick="renderingDic();">다국어 지정 창</a>	</li>
		</ul>
	</div>
	
	<div id="con_dic"></div>
	
	
</form>