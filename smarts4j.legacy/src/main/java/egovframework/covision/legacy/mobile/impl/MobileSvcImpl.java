package egovframework.covision.legacy.mobile.impl;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.legacy.mobile.MobileSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("mobileService")
public class MobileSvcImpl extends EgovAbstractServiceImpl implements MobileSvc{
	
	
	private Logger LOGGER = LogManager.getLogger(MobileSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	
	//mobile.searchPhoneNumber
	public CoviMap getPhoneNumberSearch(String phoneNumber) throws Exception{
		CoviMap resultList = new CoviMap();
		
		try{
			CoviMap params = new CoviMap();
			params.put("number", phoneNumber);
			
			CoviList list = coviMapperOne.list("mobile.searchPhoneNumber", params);
			
			String strColumn = "UserID,UserCode,LogonID,DisplayName,JobPositionName,JobTitleName,JobLevelName,DeptName,CompanyName,PhoneNumber,Mobile,PhoneNumberInter,PhoneNumberSearch,MobileSearch,PhotoPath";
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, strColumn));
			
		}catch(NullPointerException e){
			LOGGER.error("getPhoneNumberSearch", e);
		}catch(Exception e){
			LOGGER.error("getPhoneNumberSearch", e);
		}
		
		return resultList;
	}
		
		
	
	//mobile.selectPhoneNumberList
	public CoviMap getPhoneNumberList() throws Exception{
		CoviMap resultList = new CoviMap();
		
		try{
			CoviList list = coviMapperOne.list("mobile.selectPhoneNumberList", null);
			String strColumn = "UserID,UserCode,LogonID,DisplayName,JobPositionName,JobTitleName,JobLevelName,DeptName,CompanyName,PhoneNumber,Mobile,PhoneNumberInter,PhoneNumberSearch,MobileSearch";
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, strColumn));
			
		}catch(NullPointerException e){
			LOGGER.error("getPhoneNumberList", e);
		}catch(Exception e){
			LOGGER.error("getPhoneNumberList", e);
		}
		
		return resultList;
	}
	
}