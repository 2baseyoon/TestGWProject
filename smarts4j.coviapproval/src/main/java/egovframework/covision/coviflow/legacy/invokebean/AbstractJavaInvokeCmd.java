package egovframework.covision.coviflow.legacy.invokebean;

import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import egovframework.baseframework.data.CoviMap;
import net.sf.json.JSONObject;

@Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = { Throwable.class })
public abstract class AbstractJavaInvokeCmd {
	protected CoviMap legacyInfo;
	protected CoviMap legacyParams;
	protected CoviMap bodyContext;
	protected CoviMap formInstance;
	protected String processID;
	protected String formInstID;
	protected CoviMap logResult = new CoviMap();
	
	public CoviMap callJava(CoviMap plegacyInfo, CoviMap legacyParams) throws Exception {
		this.logResult.clear();
		this.legacyInfo = plegacyInfo;
		this.legacyParams = legacyParams;
		this.bodyContext = CoviMap.fromObject(legacyParams.getString("bodyContext"));
		this.formInstance = legacyParams.getJSONObject("formInstance");
		this.processID = legacyParams.getString("processID");
		this.formInstID = legacyParams.getString("formInstID");
		
		String apvMode = legacyParams.getString("apvMode");
		
		/* [[[[ apvMode 값 참고 ]]]]
		 * 
		 * 기안시 연동 - DRAFT - scLegacyDraft
		 * 완료(승인) 후 연동 - COMPLETE - scLegacyComplete
		 * 완료(배포처) 후 연동 - DISTCOMPLETE - scLegacyDistComplete
		 * 완료(반려) 후 연동 - REJECT - scLegacyReject
		 * 담당부서 처리 전 연동 - CHARGEDEPT - scLegacyChargeDept
		 * 진행 중 연동 - OTHERSYSTEM - scLegacyOtherSystem
		 * 회수 후 연동 - WITHDRAW - scLegacyWithdraw
		 * */
		if("DRAFT".equals(apvMode)) {
			onDraft();
		}else if("COMPLETE".equals(apvMode)) {
			onComplete();
		}else if("REJECT".equals(apvMode)) {
			onCancel();
		}else if("OTHERSYSTEM".equals(apvMode)) {
			onApp();
		}
		
		return this.logResult;
		// TODO .............
	}
	
	protected abstract void onDraft() throws Exception;
	protected abstract void onApp() throws Exception;
	protected abstract void onCancel() throws Exception;
	protected abstract void onComplete() throws Exception;
}
