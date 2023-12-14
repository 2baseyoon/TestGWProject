package egovframework.covision.groupware.bizcard.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.groupware.bizcard.user.service.BizCardUtilService;
import egovframework.covision.groupware.bizcard.user.util.BizCardUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BizCardUtilService")
public class BizCardUtilServiceImpl extends EgovAbstractServiceImpl implements BizCardUtilService{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap selectBizCardExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		String sField = ""; // 항목 설정
		CoviList list = null;
		int cnt = 0;
		
		sField = params.get("sField").toString();
		sField = sField.replace("\"", "");
		list = coviMapperOne.list("selectBizCardExportList",params);
		cnt = (int) coviMapperOne.getNumber("selectBizCardExportListCnt", params);
		
		resultList.put("list",BizCardUtils.coviSelectJSONForExcel(list, sField));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	@Override
	public CoviMap selectBizCardCSVList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		String sField = ""; // 항목 설정
		String fileType = ""; // 파일 형식
		
		CoviList list = null;
		int cnt = 0;
		
		sField = params.get("sField").toString();
		sField = sField.replace("\"", "");
		
		fileType = params.get("fileType").toString();
		
		list = coviMapperOne.list("selectBizCardExportList",params);
		cnt = (int) coviMapperOne.getNumber("selectBizCardExportListCnt", params);
		
		resultList.put("sb",BizCardUtils.coviSelectJSONForCSV(list, sField, fileType).toString());
		resultList.put("cnt", cnt);
		return resultList;
	}

	@Override
	public CoviMap selectBizCardVCFList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		int cnt = 0;
		
		list = coviMapperOne.list("selectBizCardExportList",params);
		cnt = (int) coviMapperOne.getNumber("selectBizCardExportListCnt", params);
		
		resultList.put("sb",BizCardUtils.coviSelectJSONForVCF(list).toString());
		resultList.put("cnt", cnt);
		return resultList;
	}
}
