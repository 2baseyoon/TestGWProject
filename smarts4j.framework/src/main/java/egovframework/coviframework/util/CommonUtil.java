/*
 * Copyright yysvip.tistory.com.,LTD.
 * All rights reserved.
 * 
 * This software is the confidential and proprietary information
 * of yysvip.tistory.com.,LTD. ("Confidential Information").
 */
package egovframework.coviframework.util; 

import java.util.Set;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.Sha512;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.baseframework.base.StaticContextAccessor;



/**
 * <pre>
 * egovframework.coviframework.util 
 *    |_ CommonUtil.java
 * 
 * </pre>
 * @date : 2018. 9. 28. 오후 1:23:20
 * @version : 
 * @author : sjhong
 */
public class CommonUtil {

	/**
	 * 사진, 이름, 소속부서 정보조회 사용여부 체크
	 * 관리자 사이트 HTML 생성
	 * 
	 * @param authType
	 * @param adminAuth
	 * @return
	 * @throws Exception
	 */
	public CoviMap makeMyInfoData(CoviMap userDataObj) throws Exception{	
		return makeMyInfoData(userDataObj, "") ;
	}
	public CoviMap makeMyInfoData(CoviMap userDataObj, String ipaddress) throws Exception{		
		CoviMap myInfoObject = new CoviMap();
		CoviList baseGroupInfo = new CoviList();
		CoviMap jobPositionName = new CoviMap();
		CoviMap detpNm = new CoviMap();
		String photoPath = userDataObj.getString("PhotoPath");
		String authType = PropertiesUtil.getSecurityProperties().getProperty("admin.auth.type");
		
		myInfoObject.put("themeUsed", RedisDataUtil.getBaseConfig("useTheme"));
		
		myInfoObject.put("photoPath", photoPath);
		myInfoObject.put("name", userDataObj.getString("UR_Name"));
		if  (!StringUtil.replaceNull(userDataObj.get("UR_LicSeq"),"0").equals("0")){
			myInfoObject.put("licName", StringUtil.replaceNull(userDataObj.get("UR_LicName"),""));
		}	
		jobPositionName.put("jobPositionName",userDataObj.getString("UR_JobPositionName"));
		detpNm.put("detpNm",userDataObj.getString("DEPTNAME") );
		//detpNm.put("detpNm", SessionHelper.getSession("DEPTNAME") + "(" + SessionHelper.getSession("DN_Name") + ")");
		
		baseGroupInfo.add(jobPositionName);
		baseGroupInfo.add(detpNm);
		myInfoObject.put("baseGroupInfo", baseGroupInfo);
		
		String managerSite= "";
		String adminAuth= "N";
		if("Y".equals(userDataObj.getString("isAdmin")) && !ipaddress.equals("")){
			if(authType.equals("T")){	//two factor
				managerSite = "/covicore/control/admin/twoFector.do";
			}else{
				adminAuth = "Y";
				if (authType.equals("I")){	//ip제한이면
					CoviMap  params = new CoviMap(); 
					String[] ip = ipaddress.split("\\.");
					String partIPAddress = String.format("%03d.", Integer.parseInt(ip[0]))+String.format("%03d.", Integer.parseInt(ip[1]))+String.format("%03d.", Integer.parseInt(ip[2]))+String.format("%03d", Integer.parseInt(ip[3]));

					params.put("domainID", userDataObj.getString("DN_ID"));
					params.put("partIPAddress", partIPAddress);
					AuthorityService authSvc = StaticContextAccessor.getBean(AuthorityService.class);
					
					if(authSvc.selectTwoFactorIpCheck(params,"A") == 0){
						adminAuth = "N";
					}
				}
				
				if (adminAuth.equals("Y")){
					String adminContext = RedisDataUtil.getBaseConfig("AdminBaseContext", userDataObj.getString("DN_ID"));
					String cTempValue = SessionHelper.getExtensionSession(userDataObj.getString("USERID")+"_PSM","TEMP");
					managerSite =  adminContext+"&CSA_SC="+Sha512.encrypt("|"+userDataObj.getString("USERID")+"|"+cTempValue+"|"+"Y"+"|");
				}
			}
		}	
			/*
			StringUtil func = new StringUtil();
			
			String url = "/covicore/control/admin/twoFector.do";
			
			if(func.f_NullCheck(authType).equals("T")){
				String siteHTML = String.format("<p><a href='#' onclick=\"Common.open('','OTP','TWO FACTOR 인증','%s','520px','310px','iframe',true,null,null,true)\"; return false;>%s</a></p>",url,DicHelper.getDic("lbl_AdminDefaultURL"));
				myInfoObject.put("managerSite", siteHTML);
			}else{
				
				if(func.f_NullCheck(adminAuth).equals("Y")){
					String adminContext = RedisDataUtil.getBaseConfig("AdminBaseContext", userDataObj.getString("DN_ID"));
					
					String cTempValue = SessionHelper.getExtensionSession(userDataObj.getString("USERID")+"_PSM","TEMP");
					
					String siteHTML = String.format("<p><a href=\"%s\" target=\"_blank\">%s</a></p>", adminContext+"&CSA_SC="+Sha512.encrypt("|"+userDataObj.getString("USERID")+"|"+cTempValue+"|"+"Y"+"|"), DicHelper.getDic("lbl_AdminDefaultURL"));
					
					myInfoObject.put("managerSite", siteHTML);
				}else{
					myInfoObject.put("managerSite", "");
				}
			}
			
		} else {
			myInfoObject.put("managerSite", "");
		} */
		
		myInfoObject.put("managerSite", managerSite);
		myInfoObject.put("managerType", authType);
		Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "PT", "", "V");
		if (authorizedObjectCodeSet.size()>1)
		{
			myInfoObject.put("portalpage", authorizedObjectCodeSet);
		}
		
		
		return myInfoObject;
	}
	
}
