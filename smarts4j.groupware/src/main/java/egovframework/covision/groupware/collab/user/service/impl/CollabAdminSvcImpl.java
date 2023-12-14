package egovframework.covision.groupware.collab.user.service.impl;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.collab.user.service.CollabAdminSvc;
import egovframework.covision.groupware.collab.user.web.CollabAdminCon;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


import net.sf.jxls.transformer.XLSTransformer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service("CollabAdminSvc")
public class CollabAdminSvcImpl extends EgovAbstractServiceImpl implements CollabAdminSvc {

    @Resource(name="coviMapperOne")
    private CoviMapperOne coviMapperOne;

    private Logger logger = LogManager.getLogger(CollabAdminCon.class);
    
    @Override
	@Transactional
	public void setSyncSetting(CoviMap jo) throws Exception {
    	CoviList configList = jo.getJSONArray("configList");

		for(int i=0;i<configList.size();i++){
			CoviMap config = configList.getJSONObject(i);
			
			CoviMap params = new CoviMap();
			params.put("SettingKey", config.getString("SettingKey"));
			params.put("SettingValue", config.getString("SettingValue"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode",SessionHelper.getSession("USERID"));

			coviMapperOne.update("collab.admin.setSyncSetting",params);
		}
    }
    
    //개인설정 조회
    @Override
	public CoviMap  getCollabUserConf(CoviMap params)	throws Exception  {
    	CoviMap resultList  = new CoviMap();
    	CoviMap resultData  = coviMapperOne.selectOne("collab.admin.getCollabUserConf",params);
    	
		resultList.put("userConf", resultData);
		return  resultList;
    }
    
    //개인설정 저장
    @Override
	public int saveCollabUserConf(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.update("collab.admin.saveCollabUserConf", params);
		return cnt;
	}
    
}
