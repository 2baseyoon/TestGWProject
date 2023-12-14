package egovframework.coviaccount.user.service.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.invoke.MethodHandles;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.EACTaxSvc;
import egovframework.coviframework.util.ComUtils;


@Service("EACTaxSvc")
public class EACTaxSvcImpl extends EgovAbstractServiceImpl implements EACTaxSvc{
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @Method Name : EACTaxExcelUpload
	 * @Description : 전표 가져오기 엑셀 업로드
	 */
	@Override
	public CoviMap EACTaxExcelUpload(CoviMap params) throws Exception {
		CoviMap resultList			= new CoviMap();
		List<List<String>> dataList		= new ArrayList<>();
		MultipartFile mFile				= (MultipartFile) params.get("uploadfile");
		File file						= prepareAttachment(mFile);
		
		try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), "utf-8"))) {
		    String line;
		    while ((line = br.readLine()) != null) {
		        String[] values = line.split(",");
		        dataList.add(Arrays.asList(values));
		    }
		}
	    
	    if(dataList.size() > 1) dataList = dataList.subList(1, dataList.size());

	    for (List list : dataList) {
			String BUKRS = StringUtil.replaceNull(list.get(0).toString());
			String BELNR = StringUtil.replaceNull(list.get(1).toString());
			String BUPLA = StringUtil.replaceNull(list.get(2).toString());
			String BUDAT = StringUtil.replaceNull(list.get(3).toString());
			String KUNNR = StringUtil.replaceNull(list.get(4).toString());
			String STCD2 = StringUtil.replaceNull(list.get(5).toString());
			String NAME1 = StringUtil.replaceNull(list.get(6).toString());
			String BSTKD = StringUtil.replaceNull(list.get(7).toString());
			String FWBAS = StringUtil.replaceNull(list.get(8).toString());
			String FWSTE = StringUtil.replaceNull(list.get(9).toString());
			String HWBAS = StringUtil.replaceNull(list.get(10).toString());
			String HWSTE = StringUtil.replaceNull(list.get(11).toString());
			String SGTXT = StringUtil.replaceNull(list.get(12).toString());
			String MWSKZ = StringUtil.replaceNull(list.get(13).toString());
			String WAERS = StringUtil.replaceNull(list.get(14).toString());
			String KURSF = StringUtil.replaceNull(list.get(15).toString());
			String CREATE_DATE = StringUtil.replaceNull(list.get(16).toString());
			String CREATE_TIME = StringUtil.replaceNull(list.get(17).toString());

			CoviMap saveParams = new CoviMap();
			saveParams.put("BELNR", BELNR); 

			int taxMapCnt = (int) coviMapperOne.getNumber("account.eactax.getEACTaxMapCnt", saveParams);
			saveParams.put("BUKRS", BUKRS);
			saveParams.put("BUPLA", BUPLA);
			saveParams.put("BUDAT", BUDAT);
			saveParams.put("KUNNR", KUNNR);
			saveParams.put("STCD2", STCD2);
			saveParams.put("NAME1", NAME1);
			saveParams.put("BSTKD", BSTKD);
			saveParams.put("FWBAS", FWBAS);
			saveParams.put("FWSTE", FWSTE);
			saveParams.put("HWBAS", HWBAS);
			saveParams.put("HWSTE", HWSTE);
			saveParams.put("SGTXT", SGTXT);
			saveParams.put("MWSKZ", MWSKZ);
			saveParams.put("WAERS", WAERS);
			saveParams.put("KURSF", KURSF);
			saveParams.put("CREATE_DATE", CREATE_DATE);
			saveParams.put("CREATE_TIME", CREATE_TIME);
			
			if(taxMapCnt == 0){
				coviMapperOne.insert("account.eactax.insertEACTaxInfo", saveParams);
				String budat = (String)saveParams.get("BUDAT");

				insertTaxMapBind(budat);
			}else{
				resultList.put("state", "DUPLICATE");
				return resultList;
			}
		}
		
		resultList.put("state", "SUCCESS");
		return resultList;
	}
	
	/**
	 * @Method Name : getEACTaxMapList
	 * @Description : 건별 목록 가져오기
	 */
	@Override
	public CoviMap getEACTaxMapList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt		= (int) coviMapperOne.getNumber("account.eactax.getEACTaxMapCnt" , params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.eactax.getEACTaxMapList", params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList;
	}
	
	/**
	 * @Method Name : getEACTaxByCompanyList
	 * @Description : 거래처별 목록 가져오기
	 */
	@Override
	public CoviMap getEACTaxByCompanyList(CoviMap params) throws Exception {
		CoviMap resultList		= new CoviMap();
		
		int cnt						= 0;
		int pageNo					= Integer.parseInt(params.get("pageNo").toString());
		int pageSize				= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset				= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt		= (int) coviMapperOne.getNumber("account.eactax.getEACTaxByCompanyCnt" , params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.eactax.getEACTaxByCompanyList", params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList;
	}
	
	/**
	 * @Method Name : EACTaxAutoMapping
	 * @Description : 건별 목록 자동 맵핑
	 */
	@Override
	public CoviMap EACTaxAutoMapping(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		int resCnt				= 0;
		
		resCnt = coviMapperOne.insert("account.eactax.insertTaxMapBind", params);
		
		resultList.put("result", resCnt);
		return resultList;
	}
	
	/**
	 * @Method Name : EACTaxInitial
	 * @Description : 건별 목록 초기화
	 */
	@Override
	public CoviMap EACTaxInitial(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		int resCnt				= 0;
		
		coviMapperOne.delete("account.eactax.deleteTaxInfo", params);
		resCnt = coviMapperOne.delete("account.eactax.deleteTaxMap", params);
		
		resultList.put("result", resCnt);
		return resultList;
	}
	
	/**
	 * @Method Name : registTaxMap
	 * @Description : 전표&계산서 맵핑
	 */
	@Override
	public CoviMap registTaxMap(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		int resCnt				= 0;
		
		coviMapperOne.delete("account.eactax.deleteRegistTaxMap", params);
		resCnt = coviMapperOne.insert("account.eactax.insertRegistTaxMap", params);
		
		resultList.put("result", resCnt);
		return resultList;
	}
	
	/**
	 * @Method Name : searchTaxMapListExcelDownload
	 * @Description : 건별 목록 엑셀 다운로드
	 */
	@Override
	public CoviMap searchTaxMapListExcelDownload(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		String headerKey		= params.get("headerKey").toString();
		
		int cnt			= (int) coviMapperOne.getNumber("account.eactax.getEACTaxMapCnt", params);
		CoviList list	= coviMapperOne.list("account.eactax.getEACTaxMapList", params);
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list, headerKey));
		resultList.put("cnt",	cnt);
		
		return resultList;
	}
	
	/**
	 * @Method Name : searchTaxByCompanyListExcelDownload
	 * @Description : 거래처별 목록 엑셀 다운로드
	 */
	@Override
	public CoviMap searchTaxByCompanyListExcelDownload(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		String headerKey		= params.get("headerKey").toString();
		
		int cnt			= (int) coviMapperOne.getNumber("account.eactax.getEACTaxByCompanyCnt", params);
		CoviList list	= coviMapperOne.list("account.eactax.getEACTaxByCompanyList", params);
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list, headerKey));
		resultList.put("cnt",	cnt);
		
		return resultList;
	}
	
	public CoviMap insertTaxMapBind(String budat) throws Exception{
		CoviMap resultList	= new CoviMap();
		CoviMap params			= null;
		DateFormat dateFormat	= new SimpleDateFormat("yyyy-MM-dd");
		String budatArr[]		= budat.split(",");
		String userCode			= SessionHelper.getSession("UR_ID");

		for(int i = 0; i < budatArr.length; i++){
			params			= new CoviMap();
			Date budatDate	= dateFormat.parse(budatArr[i]);

			params.put("userCode", userCode);
			params.put("sDate", budatDate.getTime() < new Date(Long.MAX_VALUE).getTime() ? budatArr[i] : dateFormat.format(new Date(Long.MAX_VALUE)));
			params.put("eDate", budatDate.getTime() > new Date(0).getTime() ? budatArr[i]: dateFormat.format(new Date(0)));
			
			coviMapperOne.insert("account.eactax.insertTaxMapBind", params);
		}
		
		return resultList;
	}
	
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
			if (tmp != null) { 
				if(tmp.delete()) {
					logger.info("prepareAttachment : tmp delete();");
				}
			}	
			
	        throw ioE;
	    }
	}
}
