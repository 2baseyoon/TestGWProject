/* 프로그램 저작권 정보
// 이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
// (주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
// (주)코비젼의 지적재산권 침해에 해당됩니다.
// (Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
// You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
// as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
// owns the intellectual property rights in and to this program.
// (Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>김형복(k96mi005@covision.co.kr)</creator> 
///<createDate>2013.02.01</createDate> 
///<lastModifyDate>2014.06.26</lastModifyDate> 
///<version>1.1.0</version>
///<summary> 
///
///</summary>
///<ModifySpc>
///2014.06.26 ( 임소희 shlim@covision.co.kr) : Copyright, ID Block 추가(작성자 Admin -> 김형복)
///</ModifySpc>
*/

//var HwpCtrl = document.getElementById(g_id);

//HwpCtrl.SetClientName("DEBUG");
//InitToolBarJS();
//HwpCtrl.SetToolBar(-1, "#1;1:TOOLBAR_MENU");
//HwpCtrl.SetToolBar(1, "#2;1:기본 도구 상자,FileSaveAs, FilePreview, Print, Separator, Undo, Redo, Separator, Cut, Copy, Paste,"
//	+ "Separator, ParaNumberBullet, MultiColumn, SpellingCheck, HwpDic, Separator, PictureInsertDialog, MacroPlay1");
//HwpCtrl.ReplaceAction("FileSaveAs", "HwpCtrlFileSaveAsAutoBlock");
//HwpCtrl.ReplaceAction("ReplaceDlg", "HwpCtrlReplaceDlg");

/*HwpCtrlBody.SetClientName("DEBUG");
HwpCtrlBody.SetToolBar(-1, "TOOLBAR_MENU");
HwpCtrlBody.SetToolBar(-1, "TOOLBAR_STANDARD");
HwpCtrlBody.ShowToolBar(1);
*/

//BasePath = _GetBasePath();

//var MinVersion = 0x05050115;

//// 설치확인
//if (HwpCtrl.getAttribute("Version") == null) alert("한글 2002 컨트롤이 설치되지 않았습니다.");
////버젼 확인
//CurVersion = HwpCtrl.Version;
//if (CurVersion < MinVersion) {
//    alert("HwpCtrl의 버젼이 낮아서 정상적으로 동작하지 않을 수 있습니다.\n" +
//			"최신 버젼으로 업데이트하기를 권장합니다.\n\n" +
//			"현재 버젼: 0x" + CurVersion.toString(16) + "\n" +
//			"권장 버젼: 0x" + MinVersion.toString(16) + " 이상"
//			);
//}

function _GetBasePath() {
    //BasePath를 구한다.
    var loc = unescape(document.location.href);
    var lowercase = loc.toLowerCase(loc);
    if (lowercase.indexOf(document.location.protocol + "//") == 0) {
        return loc.substr(0, loc.lastIndexOf("/") + 1); //BasePath 생성
    } else {// local
        var path;
        path = loc.replace(/.{2,}:\/{2,}/, ""); // file:/// 를 지워버린다.
        return path.substr(0, path.lastIndexOf("/") + 1); //BasePath 생성
    }
}

function HwpCtrl_NotifyMessage(msg, wparam, lparam) {
    //if (OnFieldNotify && (msg == "FieldClickHereClicked"))
    //{
    //	OnFieldNotify = false;
    //	setTimeout(PutSignPicture, 200); // PostMessage emulation
    //}

    //if (msg == "FieldClickHereClicked"){  
    //	var sfield = HwpCtrl.GetCurFieldName(2);
    //	switch(sfield) {
    //		case "title":		SetHwpCtrl(sfield, 0, 1);break; //편집 (0 편집가능, 1: 편집불가)
    //		case "bodycontext":		SetHwpCtrl(sfield, 0, 1);break; //편집
    //		default:
    //			SetHwpCtrl(sfield, 1, 0);break; //읽기 전용
    //	}
    //}
}

function SetHwpCtrl(sfieldname, removeproperty, addproperty) {//  제목, 본문내용만 수정가능하게 설정
    HwpCtrl.ModifyFieldProperties(sfieldname, removeproperty, addproperty);
}

function InitToolBarJS() {

    HwpCtrl.SetToolBar(-1, "TOOLBAR_MENU");
    HwpCtrl.SetToolBar(-1, "TOOLBAR_DRAW");
    HwpCtrl.SetToolBar(-1, "TOOLBAR_FORMAT");

    HwpCtrl.ShowToolBar(true);

    HwpCtrl.Run("ViewOptionPaper");
    HwpCtrl.Run("ViewZoomNormal");
    
    InitPageSetup(HwpCtrl);
}

function InitToolBarJS_Read() {

    HwpCtrl.ReplaceAction("FileSave", "HwpCtrlFileSave");
    HwpCtrl.ReplaceAction("FileSaveAs", "HwpCtrlFileSaveAs");

    HwpCtrl.SetToolBar(0, "FilePreview, Print, FileSaveAs");

    HwpCtrl.ShowToolBar(true);

    HwpCtrl.Run("ViewOptionPaper");
    HwpCtrl.Run("ViewZoomNormal");

    InitPageSetup(HwpCtrl);
}

function InitPageSetup(margin, pHwpCtrl) {
    var act;
    var set;
    var pset;
    act = pHwpCtrl.CreateAction("PageSetup"); // 액션 생성
    set = act.CreateSet(); // parameter set 생성
    act.GetDefault(set); // parameter set 초기화

    set.SetItem("ApplyTo", 3);
    var vSubset = set.Item("PageDef");
    // vSubset.SetItem("Landscape", 1); // 가로
    //vSubset.SetItem("PaperWidth", 48000);
    
    // 1mm = 283.465 HWPUNITs
    var unit = 283.465;
    if(margin == undefined)
    	margin = 0;
    
    vSubset.SetItem('TopMargin', margin*unit);
    vSubset.SetItem('BottomMargin', margin*unit);
    vSubset.SetItem('LeftMargin', margin*unit);
    vSubset.SetItem('RightMargin', margin*unit);
    vSubset.SetItem('HeaderLen', 0);
    vSubset.SetItem('FooterLen', 0);
    vSubset.SetItem('GutterLen', 0);

    act.Execute(set); // 액션 실행

    // 폰트변환
    act = pHwpCtrl.CreateAction("CharShape");
    set = act.CreateSet();
    act.GetDefault(set);

    set.SetItem("Height", 1100);
    set.SetItem("FaceNameHangul", "휴먼명조");
    set.SetItem("FaceNameLatin", "휴먼명조");
    set.SetItem("FaceNameHanja", "휴먼명조");
    set.SetItem("FaceNameJapanese", "휴먼명조");
    set.SetItem("FaceNameOther", "휴먼명조");
    set.SetItem("FaceNameSymbol", "휴먼명조");
    set.SetItem("FaceNameUser", "휴먼명조");

    act.Execute(set); // 액션 실행
}

function InitScan() {
    HwpCtrl.InitScan(0xff, 0xFF, 0, 0, 0, 0);
}

function GetText() {
    var TextSet;
    var ret;
    var retmsg;
    var txt;
    TextSet = HwpCtrl.CreateSet("GetText");
    txt = "";
    ret = HwpCtrl.GetTextBySet(TextSet);
    switch (ret) {
        case 0:
            retmsg = "텍스트정보 없음";
            break;
        case 1:
            retmsg = "리스트의 끝";
            break;
        case 2:
            retmsg = "일반 텍스트";
            txt = TextSet.Item("Text");
            break;
        case 3:
            retmsg = "다음 문단";
            txt = TextSet.Item("Text");
            break;
        case 4:
            retmsg = "제어문자 내부로 들어감";
            txt = "{\n";
            break;
        case 5:
            retmsg = "제어 문자를 빠져 나옴";
            txt = "}\n";
            break;
        case 101:
            retmsg = "초기화 안됨. (InitScan() 실패 또는 InitScan()를 실행하지 않은 경우.)";
            break;
        case 102:
            retmsg = "텍스트 변환 실패";
            break;
    }
    //	alert(retmsg + "\n" + TextSet.Item("Text"));
    msg.value = retmsg;
    txtarea.value += txt;
    txtarea.doScroll("scrollbarPageDown");
    HwpCtrl.MovePos(201, 0, 0);
    return ret;

}
function ReleaseScan() {
    HwpCtrl.ReleaseScan();
}
function MoveToScanPos() {
    HwpCtrl.MovePos(201, 0, 0);
    HwpCtrl.focus();
}
function ClearMsg() {
    msg.value = "";
    txtarea.value = "";
}
function GetPos() {
    pos = HwpCtrl.GetPosBySet();
    list.value = pos.Item("List");
    para.value = pos.Item("Para");
    pos.value = pos.Item("Pos");
}
function SetPos() {
    pos = HwpCtrl.CreateSet("ListParaPos");
    pos.SetItem("List", 0 + new Number(list.value));
    pos.SetItem("Para", 0 + new Number(para.value));
    pos.SetItem("Pos", 0 + new Number(pos.value));
    HwpCtrl.SetPosBySet(pos);
    HwpCtrl.focus();
}