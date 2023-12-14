package egovframework.covision.coviflow.common.web;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.UUID;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.io.FilenameUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.service.FileEncryptor;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.SessionCommonHelper;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;
import egovframework.covision.coviflow.common.service.EdmsTransferSvc;
import egovframework.covision.coviflow.common.service.impl.EdmsTransferSvcImpl;
import egovframework.covision.coviflow.common.util.AsyncTaskEdmsTransfer;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.legacy.service.ForLegacySvc;



@Controller
public class ComPdfCon {

	private final static Logger LOGGER = LogManager.getLogger(ComPdfCon.class);
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	@Autowired
	private ForLegacySvc forLegacySvc;
	
	@Autowired
	private EdmsTransferSvc edmsTransferService;

	@Resource(name = "asyncTaskEdmsTransfer")
	private AsyncTaskEdmsTransfer asyncTaskEdmsTransfer;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	@Autowired
	private FormSvc formSvc;
	   
	// pdf 저장 시 사용
	@RequestMapping(value = "common/printPdf.do", method=RequestMethod.POST)
	public @ResponseBody void printPdf(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		String PDF_DIR = PropertiesUtil.getGlobalProperties().getProperty("pdf.dir");
		String WX_DIR = PropertiesUtil.getGlobalProperties().getProperty("pdf.wxDir");
		String PDF_CSS_DIR = PropertiesUtil.getGlobalProperties().getProperty("pdf.css.dir");
		
		String html = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">";
		html += "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"ko\" xml:lang=\"ko\"><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><style>";
		
		// css파일 내용 읽음
		byte[] encoded = Files.readAllBytes(Paths.get(FileUtil.checkTraversalCharacter(PDF_CSS_DIR + "pdf.css")));
		String cssStr = new String(encoded, StandardCharsets.UTF_8);
		cssStr = cssStr.replace(".header {position:fixed; top:0px; clear:both; width:100%; min-width:1280px; height:45px; background:#ffffff; border-bottom:1px solid #cccccc; z-index:30;}","");
		cssStr = cssStr.replace(".form_box { width:100%; overflow:auto; display:block; height:100%;}", ".form_box { width:100%; display:block; height:100%;}");
		
		html += cssStr;
		html += "</style></head><body>" + paramMap.get("txtHtml") + "</body></html>";
		String name = URLEncoder.encode(paramMap.get("filename"),"UTF-8").replace("\\+", "%20");
		String uniqueID = UUID.randomUUID().toString();

		Document doc = Jsoup.parseBodyFragment(html);
		Elements imgTags = doc.getElementsByTag("img");
		for(Element img : imgTags) {
			if(img.hasAttr("src") && img.attr("src").indexOf("/covicore/common/photo/photo.do") > -1) {
				String imgSrc = img.attr("src");
				if(imgSrc.startsWith("http")) {
					UriComponents uriComponents = UriComponentsBuilder.fromUriString(imgSrc).build();
					String imgPath = uriComponents.getQueryParams().getFirst("img");
					String base64Url = getImageData(imgPath);
					img.attr("src", base64Url);
				}
			}
		}
		Element content = doc.getElementById("bodytable_content");
		content.attr("style", ""); // overflow:auto 제거.
		html = doc.html();
		
		try {
	        if (html != null) {
	        	// 임시 htm, pdf파일을 서버에 저장
	        	File dir = new File(FileUtil.checkTraversalCharacter(PDF_DIR));
	        	boolean bdirmake = false;
	        	
				if(!dir.exists()) {
				    if(dir.mkdirs()) {
				    	bdirmake = true;
				    } else {
				    	bdirmake = false;
				    }
				} else {
					bdirmake = true;
				}
	        	
	        	String fileName = PDF_DIR + uniqueID;
	        	File file = new File(FileUtil.checkTraversalCharacter(fileName + ".pdf"));
	        	// 임시 htm 파일 생성, 내용 입력
	    		FileOutputStream fos = null;
	    		OutputStreamWriter osw = null;
	    		BufferedWriter bw = null;
	    				
    			try {
    				fos = new FileOutputStream(FileUtil.checkTraversalCharacter(fileName + ".htm"));
    				osw = new OutputStreamWriter(fos, StandardCharsets.UTF_8);
    				bw = new BufferedWriter(osw);
    				if(bdirmake) {
	    				bw.write(html);
	    				bw.flush();
    				}
    			} catch (IOException e) {
    				LOGGER.error(e.getLocalizedMessage(), e);
    			} finally {
    				if(osw != null) {
    					try{
    						osw.close();
    					}catch(NullPointerException npE) {
							LOGGER.error(npE.getLocalizedMessage(), npE);
    					}catch(Exception e) {
    						LOGGER.error(e.getLocalizedMessage(), e);
						}
    				}
    				if(fos != null) {
    					try {
    						fos.close();
    					}catch(NullPointerException npE) {
							LOGGER.error(npE.getLocalizedMessage(), npE);
    					}catch(Exception e) {
    						LOGGER.error(e.getLocalizedMessage(), e);
						}
    				}
    				if(bw != null) {
    					try {
    						bw.close();
    					}catch(NullPointerException npE) {
							LOGGER.error(npE.getLocalizedMessage(), npE);
    					}catch(Exception e) {
    						LOGGER.error(e.getLocalizedMessage(), e);
						}
    				}
    			}
    			
    			// [2019-02-28 MOD] gbhwang PC 저장 시 여백으로 인하여 결재 문서 스타일 틀어짐 현상 처리
    			//String cmd = WX_DIR+"wkhtmltopdf --disable-smart-shrinking " + fileName + ".htm " + fileName + ".pdf";
    		    String cmd = WX_DIR+"wkhtmltopdf --enable-local-file-access " + fileName + ".htm " + fileName + ".pdf";
    			
    			// wkhtmltopdf 실행
    			Process p = Runtime.getRuntime().exec(cmd);
    			
    			try {
    				// process hang 처리를 위한 작업
    				ReadStream rsIn = new ReadStream(p.getInputStream());
    				ReadStream rsErr = new ReadStream(p.getErrorStream());
    				
    				rsIn.start();
    				rsErr.start();
    				int status = p.waitFor();
    				
    				// 파일 다운로드
    				if(System.getProperty("os.name").toLowerCase().indexOf("win") > -1) status = 0;
    				if (status == 0) {
    					response.setContentType("application/octect-stream");
    					response.setContentLength((int)file.length());   
    					response.setHeader("Content-Disposition", FileUtil.getDisposition(URLDecoder.decode(name, "UTF-8") + ".pdf", request));
    					FileInputStream fis = null;
    					try {
    						fis = new FileInputStream(file);
    						StreamUtils.copy(fis, response.getOutputStream());
    					}finally {
    						if(fis != null) {
    							try {
    								fis.close();
    								
    								// 로컬파일 바로삭제.
    								File pdffile = new File(FileUtil.checkTraversalCharacter(fileName + ".pdf"));
    								File htmlfile = new File(FileUtil.checkTraversalCharacter(fileName + ".htm"));
    								if(!htmlfile.delete()) {
    									LOGGER.warn("htmlfile File delete failed.");
    								}
    								if(!pdffile.delete()) {
    									LOGGER.warn("pdffile File delete failed.");
    								}
    							}catch(NullPointerException npE) {
    								LOGGER.error(npE.getLocalizedMessage(), npE);
    	    					}catch(Exception e) {
    	    						LOGGER.error(e.getLocalizedMessage(), e);
    							}
    						}
    					}
    				}
    			} catch (IOException ioE) {
    				LOGGER.error(ioE.getLocalizedMessage(), ioE);
    			} catch (NullPointerException npE) {
    				LOGGER.error(npE.getLocalizedMessage(), npE);
    			} catch (Exception e) {
    				LOGGER.error(e.getLocalizedMessage(), e);
    			} finally {
    				if (p != null) {
    					p.destroy();
    				}
    			}
	        }
		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}	
	
	// 메일보내기에서 저장한 pdf 정보 리턴받는 용도로 사용함
	@RequestMapping(value = "common/createPdf.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap createPdf(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		String PDF_DIR = PropertiesUtil.getGlobalProperties().getProperty("pdf.dir");
		String WX_DIR = PropertiesUtil.getGlobalProperties().getProperty("pdf.wxDir");
		String PDF_CSS_DIR = PropertiesUtil.getGlobalProperties().getProperty("pdf.css.dir");
		CoviMap returnObj = new CoviMap();
		
		String html = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">";
		html += "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"ko\" xml:lang=\"ko\"><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><style>";
		
		// css파일 내용 읽음
		byte[] encoded = Files.readAllBytes(Paths.get(FileUtil.checkTraversalCharacter(PDF_CSS_DIR + "pdf.css")));
		String cssStr = new String(encoded, StandardCharsets.UTF_8);
		cssStr = cssStr.replace(".header {position:fixed; top:0px; clear:both; width:100%; min-width:1280px; height:45px; background:#ffffff; border-bottom:1px solid #cccccc; z-index:30;}","");
		cssStr = cssStr.replace(".form_box { width:100%; overflow:auto; display:block; height:100%;}", ".form_box { width:100%; display:block; height:100%;}");
		
		html += cssStr;
		html += "</style></head><body>" + paramMap.get("txtHtml") + "</body></html>";
		
		Document doc = Jsoup.parseBodyFragment(html);
		Elements imgTags = doc.getElementsByTag("img");
		for(Element img : imgTags) {
			if(img.hasAttr("src") && img.attr("src").indexOf("/covicore/common/photo/photo.do") > -1) {
				String imgSrc = img.attr("src");
				if(imgSrc.startsWith("http")) {
					UriComponents uriComponents = UriComponentsBuilder.fromUriString(imgSrc).build();
					String imgPath = uriComponents.getQueryParams().getFirst("img");
					String base64Url = getImageData(imgPath);
					img.attr("src", base64Url);
				}
			}
		}
		Element content = doc.getElementById("bodytable_content");
		content.attr("style", ""); // overflow:auto 제거.
		html = doc.html();
		
		String name = paramMap.get("filename");
		String uniqueID = UUID.randomUUID().toString();

		try {
	        if (html != null) {
	        	// 임시 htm, pdf파일을 서버에 저장
	        	File dir = new File(FileUtil.checkTraversalCharacter(PDF_DIR));
	        	
	        	boolean bdirmake = false;
	        	
				if(!dir.exists()) {
				    if(dir.mkdirs()) {
				    	bdirmake = true;
				    } else {
				    	bdirmake = false;
				    }
				} else {
					bdirmake = true;
				}	        	
	        	
	        	String fileName = PDF_DIR + uniqueID;
	        	File file = new File(FileUtil.checkTraversalCharacter(fileName + ".pdf"));
	        	// 임시 htm 파일 생성, 내용 입력
	    		FileOutputStream fos = null;
	    		OutputStreamWriter osw = null;
	    		BufferedWriter bw = null;
	    				
    			try {
    				fos = new FileOutputStream(FileUtil.checkTraversalCharacter(fileName + ".htm"));
    				osw = new OutputStreamWriter(fos, StandardCharsets.UTF_8);
    				bw = new BufferedWriter(osw);
    				if(bdirmake) {
	    				bw.write(html);
	    				bw.flush();
    				}
    			} catch (IOException e) {
    				LOGGER.error(e.getLocalizedMessage(), e);
    			} finally {
    				if(osw != null) {
    					try {
    						osw.close();
    					}catch(NullPointerException npE) {
							LOGGER.error(npE.getLocalizedMessage(), npE);
    					}catch(Exception e) {
    						LOGGER.error(e.getLocalizedMessage(), e);
						}
    				}
    				if(fos != null) {
    					try {
    						fos.close();
    					}catch(NullPointerException npE) {
							LOGGER.error(npE.getLocalizedMessage(), npE);
    					}catch(Exception e) {
    						LOGGER.error(e.getLocalizedMessage(), e);
						}
    				}
    				if(bw != null) {
    					try {
    						bw.close();
    					}catch(NullPointerException npE) {
							LOGGER.error(npE.getLocalizedMessage(), npE);
    					}catch(Exception e) {
    						LOGGER.error(e.getLocalizedMessage(), e);
						}
    				}
    			}
    			
    			// [2019-02-28 MOD] gbhwang PC 저장 시 여백으로 인하여 결재 문서 스타일 틀어짐 현상 처리
    			//String cmd = WX_DIR+"wkhtmltopdf --disable-smart-shrinking " + fileName + ".htm " + fileName + ".pdf";
    		    String cmd = WX_DIR+"wkhtmltopdf --enable-local-file-access " + fileName + ".htm " + fileName + ".pdf";
    			
    		    // wkhtmltopdf 실행
    			Process p = Runtime.getRuntime().exec(cmd);
    			
    			try {
    				// process hang 처리를 위한 작업
    				ReadStream rsIn = new ReadStream( p.getInputStream());
    				ReadStream rsErr = new ReadStream(p.getErrorStream());
    				
    				rsIn.start();
    				rsErr.start();
    				int status = p.waitFor();
    				
    				if(System.getProperty("os.name").toLowerCase().indexOf("win") > -1) status = 0;
    				if (status == 0) {
    					returnObj.put("fileName", name+".pdf");
    	    			returnObj.put("saveFileName", file.getName());
    					returnObj.put("savePath", PDF_DIR);
    					returnObj.put("fileSize", file.length());
    					
    	    	        if(paramMap.containsKey("useFileID") && paramMap.containsKey("fiid") && paramMap.get("useFileID").equals("Y")) {
    	    	        	List<MultipartFile> mf = new ArrayList<>();
    	    	        	mf.add(FileUtil.makeMockMultipartFile(PDF_DIR + file.getName(), name + ".pdf"));
    	    	        	CoviList uploadFiles = fileUtilSvc.uploadToBack(null, mf, "" , "Approval", "0", "PDF", paramMap.get("fiid"), true);
    	    	        	returnObj.put("fileID", uploadFiles.getJSONObject(0).optString("FileID"));
    	    	        }
    				}
    			} catch (NullPointerException npE) {
    				LOGGER.error(npE.getLocalizedMessage(), npE);
    			} catch (Exception e) {
    				LOGGER.error(e.getLocalizedMessage(), e);
    			} finally {
    				if (p != null) {
    					p.destroy();
    				}
    				// 변환시 사용한 HTML 은 바로 삭제처리한다.
    				File htmlfile = new File(FileUtil.checkTraversalCharacter(fileName + ".htm"));
					if(!htmlfile.delete()) {
						LOGGER.warn("htmlfile File delete failed.");
					}
    				
    			}
				
				returnObj.put("status", Return.SUCCESS);
	        }
		} catch (NullPointerException npE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (IOException ioE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?ioE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			
		}
		
		return returnObj;
	}
	
	private void makeTempSession(HttpServletRequest request, HttpServletResponse response, String empno, String userCode) throws Exception {
		try {
			CoviMap logonUserInfo = forLegacySvc.selectLogonID(userCode);// by UserCode
			String legacyLogonId = logonUserInfo.getString("LogonID");
			
			if( !legacyLogonId.equals("") ){
				HttpSession session = request.getSession();
				setFormLegacyLogin(legacyLogonId, session, request, response);
			}else {
				throw new IllegalArgumentException("User Not Found!! Request UserCode is " + userCode);
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			throw npE;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw e;
		}

	}
	
	private String setFormLegacyLogin(String legacyLogonId, HttpSession session, HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CookiesUtil cUtil = new CookiesUtil();
		TokenParserHelper tokenParserHelper = new TokenParserHelper();
		TokenHelper tokenHelper = new TokenHelper();
		
		String paramId = legacyLogonId;
		String authType = "SSO"; 
		String paramPwd = "";
		String paramLang = "";
		String status = "";
		
		String urNm = "";
		String urCode = "";
		String urEmpNo = "";
		String samlID= "";
		
		resultList = forLegacySvc.checkAuthetication(authType, paramId, paramPwd, paramLang);
		status = resultList.optString("status");
		CoviMap account = (CoviMap) resultList.get("account");
		
		//인증 성공 시
		if (status.equals("OK")) {
			
			String date = forLegacySvc.checkSSO("DAY");
			String key = tokenHelper.setTokenString(paramId,date,paramPwd,paramLang,account.optString("UR_Mail"),account.optString("DN_Code"),account.optString("UR_EmpNo"),account.optString("DN_Name"),account.optString("UR_Name"),account.optString("UR_Mail"),account.optString("GR_Code"),account.optString("GR_Name"),account.optString("Attribute"),account.optString("DN_ID"));
			
			String accessDate = tokenHelper.selCookieDate(date,"");

			// DB에서 Subdomain 사용하지 않는 경우를 고려하여 설정값 가져오도록 수정
			//cUtil.setCookies(response, key, accessDate,account.optString("SubDomain"));
			cUtil.setCookies(response, key, accessDate,PropertiesUtil.getSecurityProperties().getProperty("token.cok.domain"));
			
			String decodKey = tokenHelper.getDecryptToken(key);
		    String maxAge = tokenParserHelper.parserJsonMaxAge(decodKey);
		    
			//Token 저장.
			if(forLegacySvc.insertTokenHistory(key, samlID, urNm, urCode, urEmpNo, maxAge, "I", "")){
				status = "SUCCESS";
				
				CookiesUtil funcCookies = new CookiesUtil();
				String tokenStr = funcCookies.getCooiesValue(request);
				session.setAttribute("KEY", tokenStr);
				
				session.setAttribute("USERID", account.optString("UR_ID"));
				session.setAttribute("LOGIN", "Y");
				
				urNm = account.optString("UR_Name");
				urCode = account.optString("UR_Code");
				urEmpNo = account.optString("UR_EmpNo");
				//urId = account.optString("UR_ID");
				samlID = account.optString("LogonID");
				
				SessionCommonHelper.makeSession(account.optString("UR_ID"), account, false, key);
				
				// 일회성으로 세션 생성&유지
				SessionHelper.setSession("OneTimeLogon", "Y", false);
			}
		}
		return status;
	}
	
	/**
	 * 결재완료 후 문서이관시 본문추출용 Controller.
	 * 세션이 없는 상태이므로 강제세션을 생성해 준다.(기안자)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @param locale
	 * @param model
	 * @throws Exception
	 */
	@RequestMapping(value = "/pdfTransferView.do", method= {RequestMethod.GET, RequestMethod.POST})
	public void pdfTransferView(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		String userCode = StringUtil.replaceNull(request.getParameter("logonId"), "");
		
		// make Temporary Session.
		if(!userCode.equals(SessionHelper.getSession("UR_Code"))) {
			makeTempSession(request, response, "", userCode);
		}
		
		//구어논 쿠키가 다시 넘어가야 해서 dispatch 대신 sendRedirect 사용한다.
		StringBuilder paramBuf = new StringBuilder();
		Iterator<Map.Entry<String, String>> it = paramMap.entrySet().iterator();
		
		while(it.hasNext()) {
			Map.Entry<String, String> entry = it.next();
			String key = entry.getKey();
			String val = entry.getValue();
			
			if(paramBuf.length() > 0)paramBuf.append("&");
			paramBuf.append(key + "=").append(val);
		}
		paramBuf.append("&callMode=PDF");
		
		// processID.
		String url = "/approval/approval_Form.do?" + paramBuf.toString();
		response.sendRedirect(url);
		
		//if(paramMap.get("ReUseCookie") != null && paramMap.get("ReUseCookie") instanceof String && paramMap.get("ReUseCookie").toString().equals("Y")) {
		if(paramMap.get("ReUseCookie") != null && "Y".equals(paramMap.get("ReUseCookie"))) {
			// Cookie 를 지우지 않음.
		}else {
			CookiesUtil cUtil = new CookiesUtil();
			String key = cUtil.getCooiesValue(request);
			cUtil.removeCookies(response, request, key, "D", "N", "");
		}
	}
	
	/**
	 * processID, logonId parameter 기준 문서를 PDF 변환생성한다. (스케쥴러 호출)
	 * Call EDMS API - wkhtmltopdf (URL call type)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @throws Exception
	 */
	@RequestMapping(value = "/common/transferEdms.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap transferPdf(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		// 작업시간이 있으므로  스케쥴러에게 응답은 주고 백그라운드로 수행한다.
		try {
			String url = request.getScheme() + "://";
			url += request.getServerName() + ":";
			url += request.getServerPort();
			
			final String serverUrl = url;
			CoviMap param = new CoviMap();
			final CoviList targetList = edmsTransferService.getEdmsTrasferTarget();
			List<String> updateIdList = new ArrayList<>(); 
			if(targetList != null && !targetList.isEmpty()) {
				CoviMap target = null;
				for(int i = 0;  i < targetList.size(); i++) {
					target = targetList.getJSONObject(i);
					updateIdList.add(target.getString("DocId"));// PK
				}
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
					sdf.setTimeZone(TimeZone.getTimeZone("GMT"));	
				}
				param.put("EndFlag", EdmsTransferSvcImpl.STATUS_PROGRESS);
				param.put("FlagDate", sdf.format(new Date()));
				param.put("pkList", updateIdList);
				edmsTransferService.setFlagMulti(param);
				
				// 여기서부터 오래걸리는 작업이므로 비동기처리.
				asyncTaskEdmsTransfer.executeEdmsTransfer(targetList, serverUrl);
				
			}
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			
		}catch(NullPointerException npE){
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(npE.getLocalizedMessage(), npE);
		}catch(Exception e){
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return result;
	}
	
	private class ReadStream implements Runnable {
		private final Object LOCK = new Object();
		InputStream is;
		Thread thread;
		
		public ReadStream(InputStream is) {
			this.is = is;
		}

		public void start() {
			thread = new Thread(this);
			thread.start();
		}
		
		@Override
		public void run() {
			synchronized (LOCK) {
				try(InputStreamReader isr = new InputStreamReader(is, StandardCharsets.UTF_8);
						BufferedReader br = new BufferedReader(isr)) {
						while(true) {
							String s = br.readLine();
							if (s == null) break;
						}
					} catch (NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					} catch (Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					} finally {
						if(is != null) {
							try {
								is.close();
							}catch(IOException ioE) {
								LOGGER.error(ioE.getLocalizedMessage(), ioE);
							}catch(Exception e) {
								LOGGER.error(e.getLocalizedMessage(), e);
							}
						}
					}
			}
		}
	}
	
	// pdf 및 첨부파일 zip 파일로 내려받기
	@RequestMapping(value = "common/createPCSaveZip.do", method=RequestMethod.POST)
	public void createPCSaveZip(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		try {
			// 1. pdf 변환
			CoviMap pdf = createPdf(request, response, paramMap);
			
			String formInstID = paramMap.get("fiid");
			String bStroed = paramMap.get("bstored");
			
			//String savePath = RedisDataUtil.getBaseConfig("ApprovalAttach_SavePath");
			String companyCode = SessionHelper.getSession("DN_Code");
			//String backPath = ""; //FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1)
								//+ RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
			String serviceType = "";
			
			// 2. 파일 정보 조회
			CoviList files = null;
			
			CoviMap params = new CoviMap();
			
			if(bStroed.equalsIgnoreCase("true")) {
				serviceType = "ApprovalMig";
				params.put("ServiceType", serviceType);
				params.put("ObjectType", "DEPT");
				params.put("FormInstID", formInstID);
				files = (CoviList)(formSvc.selectStoreFiles(params)).get("list");
			} else {
				serviceType = "Approval";
				params.put("ServiceType", serviceType);
				params.put("ObjectType", "DEPT");
				params.put("FormInstID", formInstID);
				files = (CoviList)(formSvc.selectFiles(params)).get("list");
			}
			CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
			String backPath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
					
			// 3. zip 파일 생성
			String zipPath = backPath + "PCSaveZip/" + DateHelper.getCurrentDay("yyyy/MM/dd");
			String zipFileName = paramMap.get("filename").replaceAll("/", "_") + ".zip";
			String zipFilePath = zipPath + "/" + zipFileName;
			
			//압축 파일 생성
			File zipPathFile = new File(FileUtil.checkTraversalCharacter(zipPath));
			if(!zipPathFile.exists()){
				if(zipPathFile.mkdirs()) {
					LOGGER.info("zipPathFile : " + zipPathFile + " mkdirs();");
				}
			}
			
			FileInputStream pdfin = null;
			try (FileOutputStream zfout = new FileOutputStream(FileUtil.checkTraversalCharacter(zipFilePath)); ZipOutputStream out = new ZipOutputStream(zfout);) 
			{
				// pdf 파일
				{
					String filePath = pdf.getString("savePath");
					String savedName = pdf.getString("saveFileName");
					String fileName = pdf.getString("fileName").replaceAll("/", "_");
					
					ZipEntry ze = new ZipEntry(fileName);
					out.putNextEntry(ze);
	
					try {
						pdfin = new FileInputStream(filePath + savedName);
						
						byte[] buf = new byte[8192];
		            	int bytesread =0;
		            	int bytesBuffered=0;
		            	while ( (bytesread = pdfin.read(buf)) > -1){
			            	out.write(buf,0, bytesread);
			            	bytesBuffered += bytesread;
			            	if(bytesBuffered > 1024 * 1024){ //flush after 1M
			            		bytesBuffered = 0;
			            		out.flush();
			            	}
		            	}
	            	} catch (IOException ioE) {
						throw ioE;
					} catch (NullPointerException npE) {
						throw npE;
					} catch (Exception e) {
						throw e;
					} finally {
						//JSYun:Memory분산처리 종료
						if (pdfin != null) {
							try {
								pdfin.close();
							}catch(NullPointerException npE) {
								LOGGER.error(npE.getLocalizedMessage(), npE);
	    					}catch(Exception e) {
	    						LOGGER.error(e.getLocalizedMessage(), e);
							}
						}
					}
					
					out.closeEntry();
				}
				// 파일명  none utf 문자열 제거.
				//CharsetDecoder utf8Decoder = StandardCharsets.UTF_8.newDecoder();
				//utf8Decoder.onMalformedInput(CodingErrorAction.IGNORE);
				//utf8Decoder.onUnmappableCharacter(CodingErrorAction.IGNORE);
				
				// 첨부파일 
				for(Object o : files) {
					if(o instanceof CoviMap) {
						CoviMap file = (CoviMap) o;
						
						String fileCompanyCode = file.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : file.optString("CompanyCode");
						String fileBackPath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + file.optString("StorageFilePath").replace("{0}", companyCode);
						
						String filePath = fileBackPath +file.getString("FilePath");
						String savedName = file.getString("SavedName");
						String fileName = file.getString("FileName");
						
	
						//CharBuffer parsed = utf8Decoder.decode(ByteBuffer.wrap(fileName.getBytes(StandardCharsets.UTF_8)));
						fileName = StringUtil.removeNonUnicodeCharacters(fileName);
						
						ZipEntry ze = new ZipEntry(fileName);
						out.putNextEntry(ze);
	
						
						File srcFile = new File(FileUtil.checkTraversalCharacter(filePath + savedName));
			            if(PropertiesUtil.getGlobalProperties().getProperty("drm.encode.mode").equalsIgnoreCase("Y")){
			            	srcFile = fileUtilSvc.callDRMEncoding(srcFile, filePath + savedName);
			            }
			            
			            File decrypted = srcFile;
			            if("Y".equals(file.optString("Encrypted"))) {
			            	decrypted = FileEncryptor.getInstance().decrypt(srcFile, companyCode);
			            }
			            
						InputStream in = null;
						try {
							if(AwsS3.getInstance().getS3Active(companyCode)) {
								AwsS3Data s3data = AwsS3.getInstance().downData(FileUtil.checkTraversalCharacter(filePath + savedName));
								in = s3data.getContentStream();
							}else {
								in = new FileInputStream(decrypted);
							}
							
							byte[] buf = new byte[8192];
			            	int bytesread =0;
			            	int bytesBuffered=0;
			            	while ( (bytesread = in.read(buf)) > -1){
				            	out.write(buf,0, bytesread);
				            	bytesBuffered += bytesread;
				            	if(bytesBuffered > 1024 * 1024){ //flush after 1M
				            		bytesBuffered = 0;
				            		out.flush();
				            	}
			            	}
		            	} catch (IOException ioE) {
							throw ioE;
						} catch (NullPointerException npE) {
							throw npE;
						} catch (Exception e) {
							throw e;
						} finally {
							//JSYun:Memory분산처리 종료
							if (in != null) {
								try {
									in.close();
								}catch(NullPointerException npE) {
									LOGGER.error(npE.getLocalizedMessage(), npE);
		    					}catch(Exception e) {
		    						LOGGER.error(e.getLocalizedMessage(), e);
								}
							}
						}
						
						out.closeEntry();
					}
				}
			} catch (IOException ioE) {
				throw ioE;
			} catch (NullPointerException npE) {
				throw npE;
			} catch (Exception e) {
				throw e;
			} finally {
				if(pdfin != null) {
					try {
						pdfin.close();
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
			}
			
			
			// 4. 다운로드
			// 파일 다운로드 헤더 지정
			OutputStream os = null;
			File file = null;
			InputStream in = null;
			
			// 파일을 읽어 스트림에 담기
	        try{
	            file = new File(FileUtil.checkTraversalCharacter(zipFilePath));
	            
	            long fileLength = file.length();
	            in = new FileInputStream(file);
	            
		        response.reset() ;
		        response.setContentType("application/octet-stream");
		        response.setHeader("Content-Description", "JSP Generated Data");
		
		        String disposition = FileUtil.getDisposition(zipFileName, FileUtil.getBrowser(request));
		
		    	response.setHeader("Content-Disposition", disposition);
		        response.setHeader("Content-Type", "application/octet-stream; charset=utf-8");
		        response.setHeader("Content-Length", ""+fileLength );
		
		        os = response.getOutputStream();
		        byte[] b = new byte[8192];
		        int leng = 0;
		        
		        int bytesBuffered=0;
		        while ( (leng = in.read(b)) > -1){
		        	os.write(b,0, leng);
		        	bytesBuffered += leng;
		        	if(bytesBuffered > 1024 * 1024){ //flush after 1M
		        		bytesBuffered = 0;
		        		os.flush();
		        	}
		        }
		        //JSYun:Memory분산처리 종료
		        
		        os.flush();
		        
	        }catch(FileNotFoundException fe){
	        	throw fe;
	        } finally {
		        if(in != null){
		        	try{
		        		in.close();
		        	} catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
		        }
		        if(os != null){ 
		        	try{
		        		os.close(); 
		        	}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
		        }
		        // zip file 삭제.
		        if(file != null) {
		        	if(!file.delete()) {
		        		LOGGER.warn("File delete failed.["+ file.getAbsolutePath() +"]");
		        	}
		        }
		        // pdf file 삭제
				String filePath = pdf.getString("savePath");
				String savedName = pdf.getString("saveFileName");
				File pdfFile = new File(filePath + savedName);
		        if(pdfFile != null) {
		        	if(!pdfFile.delete()) {
		        		LOGGER.warn("File delete failed.["+ pdfFile.getAbsolutePath() +"]");
		        	}
		        }
	        }   
		} catch (IOException ioE) {
			LOGGER.error("ComPdfCon", ioE);
			
        	response.setContentType("text/html;charset=UTF-8");
        	try(PrintWriter pw = response.getWriter();){
        		pw.println("<script language='javascript'>alert('Zip Download Error');history.back();</script>");
        	}
		} catch (Exception e) {
			LOGGER.error("ComPdfCon", e);
			
        	response.setContentType("text/html;charset=UTF-8");
        	try(PrintWriter pw = response.getWriter();){
        		pw.println("<script language='javascript'>alert('Zip Download Error');history.back();</script>");
        	}
		}
	}
	
	private String getImageData(String img) throws IOException {
		final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		String companyCode =  SessionHelper.getSession("DN_Code");
		String filePath = "";
		
		if(StringUtil.isNotBlank(img)) {
			img = ComUtils.ConvertOutputValue(StringUtil.replaceNull(img));
			String[] imgArray= img.split("/");
			//권한 체크
			if (imgArray.length>0)
			{
				if (isSaaS.equalsIgnoreCase("Y")){
					if(imgArray[0].equals("Groupware")) {
						img = "/"+companyCode+"/covistorage/"+img;
					}
				}
			}
		}

		filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) +  img;
		if(filePath.indexOf("GWStorage/FrontStorage/")>-1){
			filePath = filePath.replace("GWStorage/FrontStorage/","FrontStorage/");
		}
		String localPath = filePath;
		if(AwsS3.getInstance().getS3Active(companyCode)) {
			AwsS3Data s3data = AwsS3.getInstance().downData(filePath);
			try(InputStream is = s3data.getContentStream();) {
				byte[] fileContent = StreamUtils.copyToByteArray(is);
				String encodedString = Base64.getEncoder().encodeToString(fileContent);
				String ext = FilenameUtils.getExtension(filePath);
				localPath = "data:image/"+ext+";base64," + encodedString;
			}
		}
		return localPath;
	}
}
