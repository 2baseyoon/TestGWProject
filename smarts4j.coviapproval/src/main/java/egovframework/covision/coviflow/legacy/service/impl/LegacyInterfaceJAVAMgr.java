package egovframework.covision.coviflow.legacy.service.impl;

import org.springframework.stereotype.Service;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviMap;
import egovframework.covision.coviflow.legacy.invokebean.AbstractJavaInvokeCmd;
import egovframework.covision.coviflow.legacy.service.LegacyInterfaceSvc;

/**
 * AOP TransactionManager 우회하도록 Class 명을 *Impl.java 로 하지 않음. 
 * @author hgsong
 */
@Service
public class LegacyInterfaceJAVAMgr extends LegacyInterfaceCommon implements LegacyInterfaceSvc {

	@Override
	public void call() throws Exception {
		String className = this.legacyInfo.get().getString("InvokeJavaClassName");
		this.logParam.get().put("ActionValue", className);
		
		// FIXME , Test
		//className = "egovframework.covision.coviflow.legacy.invokebean.impl.WF_FORM_DRAFT";
		
		Class<?> clazz = Class.forName(className);
		AbstractJavaInvokeCmd cmd = (AbstractJavaInvokeCmd)StaticContextAccessor.getBean(clazz);
		CoviMap logResult = cmd.callJava(legacyInfo.get(), legacyParams.get()); // JAVA 타입만 legacyParams 대신 spParams(전체데이터) 사용
		this.logParam.get().putAll(logResult); // ResultCode,ResultMessage
		
	}

}
