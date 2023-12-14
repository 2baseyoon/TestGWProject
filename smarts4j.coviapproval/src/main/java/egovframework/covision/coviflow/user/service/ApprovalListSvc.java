package egovframework.covision.coviflow.user.service;




import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspWriter;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ApprovalListSvc {
	public CoviMap selectApprovalList(CoviMap params) throws Exception;
	public CoviMap selectHomeApprovalList(CoviMap params) throws Exception;
	public CoviMap selectHomeApprovalListCnt(CoviMap params) throws Exception;
	public CoviMap getHomeApprovalDelayCnt(CoviMap params) throws Exception;
	public CoviMap selectApprovalGroupList(CoviMap params) throws Exception;
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception;
	public int delete(CoviMap params)throws Exception;
	public int update(CoviMap params)throws Exception;
	public int selectApprovalCnt(CoviMap params)throws Exception;
	public int selectProcessCnt(CoviMap params)throws Exception;
	public int selectApprovalNotDocReadCnt(CoviMap params)throws Exception;
	public int selectProcessNotDocReadCnt(CoviMap params)throws Exception;
	public int selectTCInfoNotDocReadCnt(CoviMap params)throws Exception;
	public int selectApprovalTCInfoSingleDocRead(CoviMap params)throws Exception;
	public int insertDocReadHistory(CoviMap params)throws Exception;
	public int updateTCInfoDocReadHistory(CoviMap params)throws Exception;
	public CoviList selectProfileImagePath(CoviMap params) throws Exception;
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception;
	public int updateHandoverUser(CoviMap params)throws Exception;
	public int executePdfConvert(CoviMap target, String requestUrl)throws Exception;
	public void transferCollabLink(HttpServletRequest request, HttpServletResponse response, Map<String, String> param, JspWriter out)throws Exception;
	public CoviMap selectFormExtInfo(CoviMap params)throws Exception;
	public CoviMap selectDocTypeList(CoviMap params) throws Exception;
	public int selectUserBoxListCnt(CoviMap params)throws Exception;
	public CoviList selectHomeSectionSort(CoviMap params)throws Exception;
	public int updateHomeSectionSort(CoviMap params)throws Exception;
	public int updateHomeListTabSort(CoviMap params)throws Exception;
	public CoviMap transferPdfCollab(Map<String, String> params) throws Exception;
}
