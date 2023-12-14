/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2017.11.29</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///공통 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/

if (!window.coviCmn) {
    window.coviNoti = {};
}

(function(window) {
	
	var coviNoti = {
			working : function(){
				//Common.warning("개발 진행중 입니다.");
				$.alerts.warning("서비스 준비중입니다.", "Working Dialog", function(){});
			}
			
	};
	
	window.coviNoti = coviNoti;
	
})(window);

