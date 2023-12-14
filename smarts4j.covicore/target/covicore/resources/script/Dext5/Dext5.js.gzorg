document.write('<div id="hDivEditor" style="width: 100%; height:100%;"></div>');
document.write('<script type="text/javascript">');

// 에디터 초기값 설정 후 로드
//-----------------------------------------------------------------------------------
var l_drowEditor = ''

//switch (Common.getSession("LanguageCode")) {
//    case "en":
//        l_drowEditor += ' DEXT5.config.InitLang = "en-us"; ';
//        break;
//    case "ko":
//        l_drowEditor += ' DEXT5.config.InitLang = "ko-kr"; ';
//        break;
//    case "ja":
//        l_drowEditor += ' DEXT5.config.InitLang = "ja-jp"; ';
//        break;
//    case "zh":
//        l_drowEditor += ' DEXT5.config.InitLang = "zh-cn"; ';
//        //l_drowEditor += ' DEXT5.Lang = "zh-tw"; ';
//        break;
//    default:
//        l_drowEditor += ' DEXT5.config.InitLang = "ko-kr"; ';
//        break;
//}
	l_drowEditor += ' DEXT5.config.InitLang = "ko-kr"; ';
	
	
// FrontStorage 경로 설정
var dt = new Date();
var year = dt.getFullYear() + "";
var month = (dt.getMonth() + 1) < 10 ? "0" + (dt.getMonth() + 1) : (dt.getMonth() + 1) + "";
var day = dt.getDate() < 10 ? "0" + dt.getDate() : dt.getDate() + "";
//var sFrontStorageURL = "/FrontStorage/" + (year + month + day) + "/" + "Dext5Inline";

l_drowEditor += ' DEXT5.config.InitXml = "dext_editor.xml";';
l_drowEditor += ' DEXT5.config.SkinName = "blue";';
//l_drowEditor += ' DEXT5.config.ToSavePathURL = "' + sFrontStorageURL + '";';
// 에디터가 로드된 후 설정한 아이디를 가진 객체에 포커스를 줌.
l_drowEditor += ' DEXT5.config.focusInitObjId = "title";';
l_drowEditor += ' DEXT5.config.NextTabElementId = "nextInput";';
l_drowEditor += ' DEXT5.config.IgnoreSameEditorName = "1";';
l_drowEditor += ' DEXT5.config.Width = "100%";';
l_drowEditor += ' DEXT5.config.Height = "' + g_heigth + 'px";';
l_drowEditor += 'var ' + gx_id + ' = new Dext5editor("' + gx_id + '");';

document.write(l_drowEditor);

document.write('</script>');

    document.write('<table style="width:100%;background:#F0EEEF;margin-top:-6px;border-top:1px solid #FFFFFF">');
    document.write('    <tr>');
    document.write('        <td  style="height:15px;; text-align:center;">');
    document.write('            <table class="editor_size" cellpadding="0" cellspacing="0" align="center">');
    document.write('			  <tr">');
    document.write('                <td style="height:11px; text-align:center;vertical-align:middle"><a href=\'javascript:PlusMinusEditorHeight("minus");\'><img src="/HtmlSite/smarts4j_n/approval/resources/images/Approval/editor_minus.gif" alt="minus" title="minus"  /></a></td>');
    document.write('                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>');
    document.write('                <td style="height:11px; text-align:center;vertical-align:middle"><a href=\'javascript:PlusMinusEditorHeight("plus");\'><img src="/HtmlSite/smarts4j_n/approval/resources/images/Approval/editor_plus.gif" alt="plus" title="plus"  /></a></td></tr>');
    document.write('            </table>');
    document.write('        </td>');
    document.write('    </tr>	');
    document.write('</table>');
    document.write('</div>');


function PlusMinusEditorHeight(pMode) {
    if (pMode == "plus" && $("#dext_frame_holder" + gx_id).height() <= 1000) {
        DEXT5.setSize("100%", ($("#dext_frame_holder" + gx_id).height() + 200) + "" + "px", gx_id);
    }

    if (pMode == "minus" && $("#dext_frame_holder" + gx_id).height() > 400) {
        DEXT5.setSize("100%", ($("#dext_frame_holder" + gx_id).height() - 200) + "" + "px", gx_id);
    }
}