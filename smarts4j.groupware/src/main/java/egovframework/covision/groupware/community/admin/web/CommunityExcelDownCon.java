package egovframework.covision.groupware.community.admin.web;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import net.sf.jxls.transformer.XLSTransformer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.community.admin.service.CommunitySvc;


@Controller
public class CommunityExcelDownCon{
	
	private Logger LOGGER = LogManager.getLogger(CommunityExcelDownCon.class);
	
	@Autowired
	CommunitySvc communitySvc;
	
	@RequestMapping(value = "layout/community/CommunityStaticCompileExcelFormatDownload.do")
	public void communityStaticExcelFormatDownload(HttpServletRequest request, HttpServletResponse response) {
		
		try {
			StringUtil func = new StringUtil();
			
			String FileName = "Community_"+func.getOutputId()+".xlsx";
			
			String sortKey = request.getParameter("sortKey");
			String sortDirec = request.getParameter("sortWay");
			
			
			String ExcelPath = request.getSession().getServletContext().getRealPath("WEB-INF//classes//excel//Community_templete.xlsx");
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+"\";");    
		    response.setHeader("Content-Description", "JSP Generated Data");  
			response.setContentType("application/vnd.ms-excel;charset=utf-8"); 
			response.getOutputStream().write(excelDownload(ExcelPath,request.getParameter("communityId"),sortKey,sortDirec));
			response.getOutputStream().flush();
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
	}
	 
	private byte[] excelDownload(String ExcelPath, String CU_ID, String sortKey, String sortDirec) throws Exception {
		ByteArrayOutputStream outputStream = null;
		InputStream is = null;
		FileInputStream fis = null;
		Workbook resultWorkbook = null;
		CoviMap excelMap= new CoviMap();
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		
		try {
			params.put("CU_ID", CU_ID);
			
			if(communitySvc.selectCommunityExcelInfoCount(params) > 0){
				excelMap = communitySvc.selectCommunityExcelInfo(params);
				
				excelMap.put("OutputYear", func.getOutputYear());
			}
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			List list = communitySvc.selectCommunityExcelLogDaily(params);
			excelMap.put("CommunityList",list);
			/*
			if(list != null && list.size() > 0){
				params.put("CommunityList",list);
			}else{
				List empty = new ArrayList();
				params.put("CommunityList", empty);
			}*/
			
			excelMap.put("Title","["+excelMap.get("CommunityName")+"] 커뮤니티 활동 현황");
			
			XLSTransformer transformer = new XLSTransformer();
			fis = new FileInputStream(ExcelPath);
			is = new BufferedInputStream(fis);
			resultWorkbook = transformer.transformXLS(is, excelMap);
	
			outputStream = new ByteArrayOutputStream();
			resultWorkbook.write(outputStream);
		} catch (IOException e) {
			LOGGER.debug(e);
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		} finally {
			if(outputStream != null) { try { outputStream.flush(); outputStream.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if(is != null) { try { is.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
			if(fis != null) { try { fis.close(); }catch(IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); }}
		}
		
		if(outputStream != null) {
			return outputStream.toByteArray();
		}else {
			return null;
		}
		
	}
	
	public String returnFileSize(int limitFileSize, int usedFileSize){
		String str = "";
		long num = 0;
		double usedSize = 0;
		int gubnKey = 0;
		String gubn[] = {"KB", "MB"}; 

		if(usedFileSize > 1024){
			
			num = usedFileSize;
			
			for( int x=0 ; (num / (double)1024 ) >0 ; x++, num/= (double) 1024 ){
				gubnKey = x;
				usedSize = num;
			}
			
			str = usedSize + gubn[gubnKey];
			
		}else{
			str = usedFileSize + "KB";
		}
		
		str = str +"/"+ limitFileSize+"MB";
		
		return str;
	}
	
	@RequestMapping(value = "layout/community/CommunityStaticStatusExcelFormatDownload.do")
	public ModelAndView messageListExcelDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap viewParams = new CoviMap();
		
		try {
			
			String DN_ID = request.getParameter("DN_ID");
			String CommunityType = request.getParameter("CommunityType");
			String sortKey = request.getParameter("sortKey");
			String sortDirec = request.getParameter("sortWay");
			String RegStatus = request.getParameter("RegStatus");
			String SearchOption = request.getParameter("SearchOption");
			String searchValue = request.getParameter("searchValue");
			String headerName = StringUtil.replaceNull(request.getParameter("headerName"), "");
			
			String[] headerNames = headerName.split("\\|");
			
			CoviMap params = new CoviMap();
			
			params.put("DN_ID", DN_ID);
			params.put("CommunityType", CommunityType);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("RegStatus", RegStatus);
			params.put("SearchOption", SearchOption);
			params.put("searchValue", ComUtils.RemoveSQLInjection(searchValue, 100));
			
			CoviMap resultList = communitySvc.selectCommunityStaticGridExcelList(params);
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			viewParams.put("title", "Community" );

			mav = new ModelAndView(returnURL, viewParams);
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return mav;
	}
}


