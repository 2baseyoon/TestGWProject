<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<head>
<title></title>
</head>
<body>
	<div class="layer_divpop ui-draggable schPopLayer" style="width:830px;">
		<div class="divpop_contents">
			<div class="pop_header">
				<h4 class="divpop_header ui-draggable-handle" id="popupTitle"><span class="divpop_header_ico">Help</span></h4>
			</div>
			<div>
				<div id="helpContent" style="margin: 5px;overflow: auto;height: 430px;">
					<div align="left" class="board_title" id="changeLanguage">
						&nbsp;&nbsp;<label><input name="LangType" onclick="changeLang()" type="radio" checked="" value="1"> Korean</label>
						&nbsp;&nbsp;<label><input name="LangType" onclick="changeLang()" type="radio" value="2"> English</label>
					</div>
					<div id="helpinfo">
					
					</div>
				</div>
				<div class="bottom">
					<a class="btnTypeDefault" href="javascript:Common.Close();">닫기</a>
				</div>
			</div>
		</div>	
	</div>
</body>

<script>
$(document).ready(function(){
	changeLang();
			
});


function Doc_Initialize() {
	$('#helpinfo').html("");
	var htmlstr = "";
	htmlstr += '<table class="tableStyle linePlus mt10">';
    htmlstr += '<tbody>';
    htmlstr += '<tr><th scope="row" style="text-align:center;padding-left:0px; padding-right:0px;">비공개 사유</th></tr>'; //<br/>&emsp;&emsp;&emsp;&nbsp;&nbsp;
    htmlstr += '<tr><td class="first" scope="row">제1호 : 다른 법률 또는 법률이 위임한 명령에 의하여 비밀 또는 비공개 사항으로 규정된 정보</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">제2호 : 국가 안전보장.국방.통일.외교관계 등에 관한 사항으로서 공개될 경우 국가의 중대한 이익을 현저히 해할 우려가 있다고 인정되는 정보</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">제3호 : 공개될 경우 국민의 생명.신체 및 재산의 보호에 현저한 지장을 초래할 우려가 있다고 인정되는 정보</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">제4호 : 진행 중인 재판에 관련된 정보와 범죄의 예방, 수사, 공소의 제기 및 유지, 형의 집행, 교정, 보안처분에 관한 사항으로서 공개될 경우 그<br/><p style="padding-right:42px;display:inline;"></p>직무수행을 현저히 곤란하게 하거나 형사피고인의 공정한 재판을 받을 권리를 침해한다고 인정할만한 상당한 이유가 있는 정보</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">제5호 : 감사.감독.검사.시험.규제.입찰계약.기술개발.인사관리.의사결정과정 또는 내부검토과정에 있는 사항 등으로서 공개될 경우 업무의 공정한<br/><p style="padding-right:42px;display:inline;"></p>수행이나 연구.개발에 현저한 지장을 초래한다고 인정할만한 상당한 이유가 있는 정보</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">제6호 : 당해 정보에 포함되어 있는 이름.주민등록번호 등 개인에 관한 사항으로서 공개될 경우 개인의 사생활의 비밀 또는 자유를 침해할 우려가<br/><p style="padding-right:42px;display:inline;"></p>있다고 인정되는 정보</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">제7호 : 법인.단체 또는 개인의 경영.영업상 비밀에 관한 사항으로서 공개될 경우 법인 등의 정당한 이익을 현저히 해할 우려가 있다고 인정되는 정보</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">제8호 : 공개될 경우 부동산 투기.매점매석 등으로 특정인에게 이익 또는 불이익을 줄 우려가 있다고 인정되는 정보</td></tr>';
    htmlstr += '</tbody>';
	htmlstr += '</table>';

	$('#helpinfo').append(htmlstr);
}

function Doc_Initialize_en() {
	$('#helpinfo').html("");
	var htmlstr = "";
	htmlstr += '<table class="tableStyle linePlus mt10">';
    htmlstr += '<tbody>';
    htmlstr += '<tr><th scope="row" style="text-align:center;padding-left:0px; padding-right:0px;">Reason</th></tr>';
    htmlstr += '<tr><td class="first" scope="row">1. Information which is stipulated as confidential or not to be disclosed under other related law or order</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">2. Information pertaining to national security, defense, unification, and international relations, etc. which can undermine Korea\'s national interest<br/><p style="padding-right:13px;display:inline;"></p>when disclosed</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">3. Information which can negatively affect the lives, health and properties of Korean citizens when disclosed</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">4. Information pertaining to trial, crime prevention, investigation indictment, sentence execution of a sentence, and securities measures	which can<br/><p style="padding-right:13px;display:inline;"></p>undermine the perfomance of one\'s duty or a defendant\'s right to have a fair trial</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">5. Information pertaining to audit, supervision, inspection, examination regulation, bidding, technolology development, human resources<br/><p style="padding-right:13px;display:inline;"></p>management, decision making process or internal review process that can undermine one\'s performance of duty or research and developemnt</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">6. Personal information such as name or resident identification numbers which can undermine individual freedom or privacy when disclosed</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">7. Confidential business information of a corporation, association or individual which can undermine one\'s legitimate profit when disclosed</td></tr>';
    htmlstr += '<tr><td class="first" scope="row">8. Information which can provide a person with an advantage or disadvantage as a result of real estate speculation or cornering and hoarding<br/><p style="padding-right:13px;display:inline;"></p>when disclosed</td></tr>';
    htmlstr += '</tbody>';
	htmlstr += '</table>';

	$('#helpinfo').append(htmlstr);
}

function changeLang(){
	if( $(':input:radio[name=LangType]:checked').val() == "1"){		// 한글
		Doc_Initialize();
	}else{		// 영문
		Doc_Initialize_en();
	}
}
</script>