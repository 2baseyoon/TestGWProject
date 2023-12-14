package egovframework.covision.coviflow.legacy.invokebean.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.covision.coviflow.legacy.invokebean.AbstractJavaInvokeCmd;
//import egovframework.covision.coviflow.legacy.util.CoviMapperLegacy;
//import egovframework.covision.coviflow.legacy.util.CoviMapperLegacyFramework;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;

@Service
public class WF_FORM_DRAFT extends AbstractJavaInvokeCmd {

	// non-XA
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	// XA - GW
	/*
	@Resource(name="coviMapperLegacyFramework")
	CoviMapperLegacyFramework coviMapperLegacyFramework;
	*/
	
	// XA - Legacy
	/*
	@Resource
	CoviMapperLegacy coviMapperLegacy;
	*/
	
	// ... 이기종 DB 2개이상 XA 처리해야 할 경우 egovframework.covision.coviflow.legacy.util.CoviMapperXXX.java 추가하여 사용.
	/*
	 *  1) egovframework.covision.coviflow.legacy.util.CoviMapperXXX.java 추가
	 *  2) WAS datasource 추가 ( context.xml 또는 Global XA Datasource 추가 )
	 *  3) /covi_property/db.properties 에 JNDI 추가
	 *  4) /smarts4j.coviapproval/src/main/resources/spring/context-datasource.xml 에 설정 추가
	 *  5) /smarts4j.coviapproval/src/main/resources/spring/context-mapper.xml 에 설정 추가
	 *  6) /smarts4j.coviapproval/src/main/resources/spring/context-transaction.xml 에 설정 추가
	 *  7) egovframework.covision.coviflow.legacy.invokebean.impl.XXX.java 1번 생성한 Mapper Resource 추가하여 쿼리
	 *  8) 쿼리 작성은 /sqlmap/sql/legacy/*.xml 에 추가하여 사용.
	 */
	// 연동데이터 : this.legacyInfo,this.legacyParams,this.bodyContext,this.formInstance,this.processID,this.formInstID
	// 리턴값 : this.logResult.ResultCode,ResultMessage
	
	@Override
	protected void onDraft() throws Exception {
		// TODO Auto-generated method stub
		callSample();
	}

	@Override
	protected void onApp() throws Exception {
		// TODO Auto-generated method stub
		callSample();
	}

	@Override
	protected void onCancel() throws Exception {
		// TODO Auto-generated method stub
		
	}

	@Override
	protected void onComplete() throws Exception {
		// TODO Auto-generated method stub
		callSample();
	}

	private void callSample() throws Exception {
		// this.legacyInfo,this.legacyParams,this.bodyContext,this.formInstance,this.processID,this.formInstID
		
		int chksum;
		// 그룹웨어 기본 mapper사용 (이후 오류시 롤백안됨)
		chksum = coviMapperOne.update("legacy.sample.update_one",new CoviMap());
		
		/* 
		 * saas oracle(77)은 java_xa 설치가안되서 불가 
		 * asis oracle(155)로 테스트 진행
		*/
		
		// JTA(Transaction) 관련 소스 주석처리
		/*
		// legacy mapper사용(이후 오류시 같이 롤백)
		// GW DB
		//coviMapperLegacyFramework.update("legacy.sample.update_gw", new CoviMap()); 			// oracle
		//coviMapperLegacyFramework.update("legacy.sample.update_gw_err", new CoviMap()); 		// oracle error
		chksum = coviMapperLegacyFramework.update("legacy.sample.updateMaria_gw", new CoviMap()); 		// maria
		//coviMapperLegacyFramework.update("legacy.sample.updateMaria_gw_err", new CoviMap()); 	// maria error
		
		// Legacy DB
		chksum = coviMapperLegacy.update("legacy.sample.update_legacy"); 			// oracle
		//coviMapperLegacy.update("legacy.sample.update_legacy_err"); 		// oracle error
		//coviMapperLegacy.update("legacy.sample.updateMaria_legacy_err"); 	// maria
		//coviMapperLegacy.update("legacy.sample.update_legacy_err"); 		// maria error
		*/
		
		this.logResult.put("ResultCode", "S");
		this.logResult.put("ResultMessage", "성공");
		
	}
}
