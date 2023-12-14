package egovframework.core.interfaces.impl;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.coviframework.util.RedisDataUtil;
import egovframework.core.interfaces.HRInterface;

public class HRInterfaceImpl implements HRInterface {
	private Logger LOGGER = LogManager.getLogger(HRInterfaceImpl.class);
	
	private Class<?> cls;
	private Object obj;
	private Method mth;
	
	@SuppressWarnings("unchecked")
	@Override
	public Map<String, Object> getHRData() throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		
		LOGGER.debug("Get interfaced dataset in map...");
		returnMap = (Map<String, Object>) mth.invoke(obj);
		
		return returnMap;
	}

	@Override
	public void init() throws Exception {
		String clsName = RedisDataUtil.getBaseConfig("HRInterfaceClassName");
		String mthName = RedisDataUtil.getBaseConfig("HRInterfaceMethodName");
		
		cls	= Class.forName(clsName);
		obj	= cls.newInstance();
		mth	= cls.getMethod(mthName);
	}
}
