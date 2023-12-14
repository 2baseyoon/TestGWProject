package egovframework.coviframework.util;

import java.util.List;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.URLDecoder;
import java.net.UnknownHostException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.TimeZone;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.JWSSigner;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.LicenseHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.CoviService;
import egovframework.baseframework.util.RedisShardsUtil;

import org.apache.commons.codec.binary.Base64;


public class ComUtils {
	private static final Logger LOGGER = LogManager.getLogger(ComUtils.class);
	
	private static final String DELIMITER = "¶";
	private static final int GET_ID = 0;
	private static final int GET_CODE = 1;
	
	// 타임존 변수
	public static final String UR_DateFullFormat = "yyyy-MM-dd HH:mm:ss";
	public static final String UR_DateFormat = "yyyy-MM-dd HH:mm";
	public static final String UR_DateSimpleFormat = "yyyy-MM-dd";
	public static final String ServerDateFullFormat = "yyyy-MM-dd HH:mm:ss";
	public static final String ServerDateFormat = "yyyy-MM-dd HH:mm";
	public static final String ServerDateSimpleFormat = "yyyy-MM-dd";
	
	public static final String StandardTimeZoneValue = "";
	
	/**
	 * @param request pageNo, pageSize 현재 페이지와 화면에 보여줄 Row데이터 개수
	 * @param rowCount 목록 전체 Row 데이터 개수
	 * @return JSONObject
	 * @description 페이징처리 관련 메소드 분리 항목, request 및 페이징 처리를 위한 count parameter 별도 분리 
	 */
	
	public static CoviMap setPagingData(CoviMap pagingParam, int rowCount){
		int pageSize = 1;
		int pageNo =  pagingParam.getInt("pageNo");
		
		if (pagingParam.get("pageNo")!= null || pagingParam.get("pageSize") != null){
			pageSize = pagingParam.getInt("pageSize");
		}
		
		CoviMap page = new CoviMap();

		int pageCount = 1;
        if(rowCount>0 && pageSize>0) {
            pageCount = 1 + (rowCount / pageSize);

            if(rowCount > 0 && (rowCount % pageSize) == 0) {
                pageCount = pageCount - 1;
            }
        }

		
		if(pageNo > pageCount) {
			pageNo = pageCount;
		}

		int pageOffset = (pageNo - 1) * pageSize;
		int start =  (pageNo - 1) * pageSize + 1; 
		int end = start + pageSize -1;
		
		page.put("pageNo", pageNo);
		page.put("pageCount", pageCount);	//pageCount: 페이지 개수
		page.put("listCount", rowCount);	//rowCount: 전체 Row 갯수 
		page.put("pageSize", pageSize);		
		page.put("pageOffset", pageOffset);	//DB 스크립트 내부 처리용 param: LIMIT #{pageSize} OFFSET #{pageOffset} 
		page.put("rowStart", start);		//rowStart	: Oracle 페이징처리용
		page.put("rowEnd", end);			//rowEnd	: Oracle 페이징처리용
		
		return page;
	}
	
	public static CoviMap setPagingCoviData(CoviMap pagingParam, int rowCount){
		int pageSize = 1;
		int pageNo =  pagingParam.getInt("pageNo");
		
		if (pagingParam.get("pageNo")!= null || pagingParam.get("pageSize") != null){
			pageSize = pagingParam.getInt("pageSize");
		}
		
		CoviMap page = new CoviMap();

        int pageCount = 1;
        if(rowCount>0 && pageSize>0) {
            pageCount = 1 + (rowCount / pageSize);

            if(rowCount > 0 && (rowCount % pageSize) == 0) {
                pageCount = pageCount - 1;
            }
        }
		
		if(pageNo > pageCount) {
			pageNo = pageCount;
		}

		int pageOffset = (pageNo - 1) * pageSize;
		int start =  (pageNo - 1) * pageSize + 1; 
		int end = start + pageSize -1;
		
		page.put("pageNo", pageNo);
		page.put("pageCount", pageCount);	//pageCount: 페이지 개수
		page.put("listCount", rowCount);	//rowCount: 전체 Row 갯수 
		page.put("pageSize", pageSize);		
		page.put("pageOffset", pageOffset);	//DB 스크립트 내부 처리용 param: LIMIT #{pageSize} OFFSET #{pageOffset} 
		page.put("rowStart", start);		//rowStart	: Oracle 페이징처리용
		page.put("rowEnd", end);			//rowEnd	: Oracle 페이징처리용
		
		return page;
	}
	
	
	/**
	 * @param pType: DomainID, DomainCode(GroupCode) 구분 여부 
	 * @description AssignedDomain 양식: 0¶ORGROOT¶그룹사|1¶GENERAL¶코비젼|{DomainID}¶{DomainCode}¶{DomainDisplayName}| ...
	 * 				pType 0: DomainID
	 * 					  1: DomainCode
	 * 
	 * @return
	 */
	private static CoviList getAssignedDomainList(int pType){
		String assignedDomain = SessionHelper.getSession("AssignedDomain");
		CoviList domainList = new CoviList();
		
		//할당된 도메인 정보 존재 여부 확인
		//할당된 도메인 정보 없거나 그룹사(공용)이면 전체 출력
		if(!assignedDomain.equals("") && !assignedDomain.contains("ORGROOT")){
			String[] domainArray = assignedDomain.split("\\|");
			for(int i=0;i < domainArray.length;i++){
				domainList.add(domainArray[i].split(DELIMITER)[pType]);
			}
		}
		
		//간편관리자이면서 할당된 회사가 없으면 내회사로 
		if(assignedDomain.equals("") && SessionHelper.getSession("isEasyAdmin").equals("Y")){
			String sessionDomain = SessionHelper.getSession("DN_ID")+"¶"+SessionHelper.getSession("DN_Code")+"¶"+SessionHelper.getSession("DN_Name");
			domainList.add(sessionDomain.split(DELIMITER)[pType]);
		}
		
		return domainList;
	}
	
	/**
	 * 할당된 DomainID 목록을 조회
	 * @return
	 */
	public static CoviList getAssignedDomainID(){
		return getAssignedDomainList(GET_ID);
	}
	
	/**
	 * 할당된 DomainCode 목록을 조회
	 * @return
	 */
	public static CoviList getAssignedDomainCode(){
		return getAssignedDomainList(GET_CODE);
	}
	
	public static CoviList getLicenseInfo(String domainID)  throws Exception{
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		
		CoviList resultList = new CoviList();
		CoviMap params = new CoviMap();
		
		//SaaS 프로젝트 아닌 경우에는 최상위 도메인에서만 라이선스 관리 
		if(!isSaaS.equalsIgnoreCase("Y")){
			domainID ="0";
		}
		
		params.put("isSaaS", isSaaS) ;
		params.put("domainID", domainID);
		
        try
        {
			CoviService coviSvc = StaticContextAccessor.getBean(CoviService.class);
			CoviList clist  = coviSvc.list("framework.license.selectLicenseUserList", params);
	//		CoviList clist = coviMapperOne.list("framework.license.selectLicenseUserList", params);
			
			for (int i=0; i< clist.size(); i++){
				CoviMap licenseData = (CoviMap)clist.get(i);
	//			licenseData.addAll(clist.getMap(i));
				
				String licSeq = licenseData.getString("LicSeq");
				String domainUrl = licenseData.getString("DomainUrl");
				//한개짜리
				String LIC_USERCOUNT = LicenseHelper.getDecryptedProperty(LicenseHelper.getLicenseInfo("LicUserCount", domainID, licSeq), domainUrl, "LIUC");
				String LIC_EXUSERCOUNT = LicenseHelper.getDecryptedProperty(LicenseHelper.getLicenseInfo("LicExUserCount", domainID, licSeq), domainUrl, "LIExUC");
				String LIC_EXPIRED = LicenseHelper.getDecryptedProperty(LicenseHelper.getLicenseInfo("LicExpireDate", domainID, licSeq), domainUrl, "LIUP");
				String LIC_EX1DATE = LicenseHelper.getDecryptedProperty(LicenseHelper.getLicenseInfo("LicEx1Date", domainID, licSeq), domainUrl, "LIEx1UP");
				
				String nowDate = DateHelper.getCurrentDay("yyyyMMdd");	//오늘 날짜
				String notifyDate = StringUtil.replaceNull(LIC_EX1DATE, "00000000");					//임시 라이선스 기간: 알림 발송 시작 날짜 
				
				int nofifyCompare = nowDate.compareTo(notifyDate);
				int RemainCnt = Integer.parseInt(StringUtil.replaceNull(LIC_USERCOUNT,"0")) - Integer.parseInt(StringUtil.replaceNull(licenseData.get("LicUsingCnt"),"0"));
				if(nofifyCompare <= 0) {	//임시기간이 안지났으면
					RemainCnt = RemainCnt+Integer.parseInt(StringUtil.replaceNull(LIC_EXUSERCOUNT,"0"));
	//				LIC_EXUSERCOUNT = ""
				}
				else{
					LIC_EX1DATE = "";
					LIC_EXUSERCOUNT = "";
				}
				licenseData.put("ServiceUser", StringUtil.replaceNull(licenseData.get("ServiceUser"),"0"));
				licenseData.put("ServiceStart", StringUtil.replaceNull(licenseData.get("ServiceStart"),""));
				licenseData.put("LicExpireDate", LIC_EXPIRED);
				licenseData.put("LicUserCount", LIC_USERCOUNT);
				licenseData.put("LicExUserCount", LIC_EXUSERCOUNT);
				licenseData.put("LicEx1Date", LIC_EX1DATE);
				licenseData.put("RemainCnt", RemainCnt);
				
				licenseData.put("ServiceEnd", StringUtil.replaceNull(licenseData.get("ServiceEnd"),""));
				licenseData.put("ExtraServiceUser", StringUtil.replaceNull(licenseData.get("ExtraServiceUser"),"0"));
				licenseData.put("ExtraExpiredate", StringUtil.replaceNull(licenseData.get("ExtraExpiredate"),""));
				
				resultList.add(licenseData);
			}	
		} catch(NullPointerException e){	
			throw e;
        }catch(Exception ex) {
            throw ex;
    	}	
        return resultList;
	}
	
	/*********************XSS 함수 추가 **************************/

	/** HTML문자열에서 텍스트만 뽑아오는 함수 (HTML태그,스크립트,스타일태그 삭제) - 
     * 아래 메써드를 사용하세요.
     * @param pHtml
     * @return
     */
    public static String HtmlRemove(String pHtml)
    {
    	Pattern rgScript = Pattern.compile("<(no)?script[^>]*>.*?</(no)?script>", Pattern.DOTALL );  
    	Pattern rgStyle = Pattern.compile("<style[^>]*>.*</style>", Pattern.DOTALL );  
    	Pattern rgApplet = Pattern.compile("<(no)?applet[^>]*>.*?</(no)?applet>", Pattern.DOTALL );  
    	Pattern rgObject = Pattern.compile("<(no)?object[^>]*>.*?</(no)?object>", Pattern.DOTALL );  
    	Pattern rgForm = Pattern.compile("<(no)?form[^>]*>.*?</(no)?from>", Pattern.DOTALL );  
    	Pattern rgEmbed = Pattern.compile("<(no)?embed[^>]*>.*?</(no)?embed>", Pattern.DOTALL );  
    	Pattern rgIframe = Pattern.compile("<(no)?iframe.*?>", Pattern.DOTALL );  
    	Pattern rgTag = Pattern.compile("<(\"[^\"]*\"|\'[^\']*\'|[^\'\">])*>", Pattern.DOTALL );
        Pattern rgBlank = Pattern.compile("\\s+", Pattern.DOTALL );  
    	Pattern rgHead = Pattern.compile("<head>.*?</head>",Pattern.DOTALL );  
    	Pattern rgHtml = Pattern.compile("<html*?>", Pattern.DOTALL );  

        pHtml = rgScript.matcher(pHtml).replaceAll("");
        pHtml = rgStyle.matcher(pHtml).replaceAll("");
        pHtml = rgApplet.matcher(pHtml).replaceAll("");
        pHtml = rgObject.matcher(pHtml).replaceAll("");
        pHtml = rgForm.matcher(pHtml).replaceAll("");
        pHtml = rgEmbed.matcher(pHtml).replaceAll("");
        pHtml = rgIframe.matcher(pHtml).replaceAll("");
        pHtml = rgHead.matcher(pHtml).replaceAll("");
        pHtml = rgHtml.matcher(pHtml).replaceAll("");
        pHtml = rgTag.matcher(pHtml).replaceAll("");
        pHtml = pHtml.replaceAll("&nbsp;", " ");
        pHtml = rgBlank.matcher(pHtml).replaceAll("");

        return pHtml;
    }

    /** HTML문자열에서 텍스트만 뽑아오는 함수 (HTML태그,스크립트,스타일태그 삭제)
     * 
     * @param pHtml
     * @return
     */
    public static String RemoveHTML(String pHtml)
    {
        return HtmlRemove(pHtml);
    }

    /** 스크립트만 제거
     * 
     * @param pHtml
     * @return
     */
    public static String RemoveScript(String pHtml)
    {
    	Pattern rgScript = Pattern.compile("<(no)?script[^>]*>.*?</(no)?script>", Pattern.DOTALL ); 
        pHtml = rgScript.matcher(pHtml).replaceAll("");
        return pHtml;
    }

    /** 스크립트와 스타일 제거(CSRF 취약점 거부)
     * @param pHtml
     * @return
     */
    public static String RemoveScriptAndStyle(String pHtml)
    {
        String sTempHtml = "";

        //style 및 script 제거
    	Pattern rgStyle = Pattern.compile("<style[^>]*>.*</style>", Pattern.DOTALL );   
    	Pattern rgMeta = Pattern.compile("<(no)?meta.*?>", Pattern.DOTALL );   
    	Pattern rgLink = Pattern.compile("<(no)?link.*?>", Pattern.DOTALL );   
    	Pattern rgScript = Pattern.compile("<(no)?script[^>]*>.*?</(no)?script>", Pattern.DOTALL );   //<(no)?script.*?script>
        //src Attribute를 사용하는 html 태그 제거   (img태그는 제외)
    	Pattern rgAudio = Pattern.compile("<(no)?audio[^>]*>.*?</(no)?audio>", Pattern.DOTALL );   
    	Pattern rgEmbed = Pattern.compile("<(no)?embed[^>]*>.*?</(no)?embed>", Pattern.DOTALL );   
    	Pattern rgIframe = Pattern.compile("<(no)?iframe[^>]*>.*?</(no)?iframe>", Pattern.DOTALL );   
    	Pattern rgInput = Pattern.compile("<(no)?input[^>]*>.*?</(no)?input>", Pattern.DOTALL );   
    	Pattern rgsource = Pattern.compile("<(no)?source[^>]*>.*?</(no)?source>", Pattern.DOTALL );   
    	Pattern rgTrack = Pattern.compile("<(no)?track[^>]*>.*?</(no)?track>", Pattern.DOTALL );   
    	Pattern rgVideo = Pattern.compile("<(no)?video[^>]*>.*?</(no)?video>", Pattern.DOTALL );   
        //href Attribute를 사용하는 html 태그 제거   (a태그는 제외)
    	Pattern rgBase = Pattern.compile("<(no)?base[^>]*>.*?</(no)?base>", Pattern.DOTALL );   
    	Pattern rgArea = Pattern.compile("<(no)?area[^>]*>.*?</(no)?area>", Pattern.DOTALL );   
    	Pattern rgApplet = Pattern.compile("<(no)?applet[^>]*>.*?</(no)?applet>", Pattern.DOTALL );   
    	Pattern rgObject = Pattern.compile("<(no)?object[^>]*>.*?</(no)?object>", Pattern.DOTALL );   
        Pattern rgFrameset = Pattern.compile("<(no)?frameset[^>]*>.*?</(no)?frameset>", Pattern.DOTALL );   
        Pattern rgIlayer = Pattern.compile("<(no)?ilayer[^>]*>.*?</(no)?ilayer>", Pattern.DOTALL );   
        Pattern rgLayer = Pattern.compile("<(no)?layer[^>]*>.*?</(no)?layer>", Pattern.DOTALL );   
        Pattern rgCookie = Pattern.compile("document.*?cookie", Pattern.DOTALL );   
        Pattern rgEval = Pattern.compile("eval(.*?)", Pattern.DOTALL );   
        Pattern rgAlert = Pattern.compile("alert(.*?)", Pattern.DOTALL );   

        pHtml = rgStyle.matcher(pHtml).replaceAll("");
        pHtml = rgMeta.matcher(pHtml).replaceAll("");
        pHtml = rgLink.matcher(pHtml).replaceAll("");
        sTempHtml = pHtml;
        pHtml = rgScript.matcher(pHtml).replaceAll("");
        pHtml = rgAudio.matcher(pHtml).replaceAll("");
        pHtml = rgEmbed.matcher(pHtml).replaceAll("");
        pHtml = rgIframe.matcher(pHtml).replaceAll("");
        pHtml = rgInput.matcher(pHtml).replaceAll("");
        pHtml = rgsource.matcher(pHtml).replaceAll("");
        pHtml = rgTrack.matcher(pHtml).replaceAll("");
        pHtml = rgVideo.matcher(pHtml).replaceAll("");
        pHtml = rgBase.matcher(pHtml).replaceAll("");
        pHtml = rgArea.matcher(pHtml).replaceAll("");
        pHtml = rgFrameset.matcher(pHtml).replaceAll("");
        pHtml = rgIlayer.matcher(pHtml).replaceAll("");
        pHtml = rgLayer.matcher(pHtml).replaceAll("");
        pHtml = rgApplet.matcher(pHtml).replaceAll("");
        pHtml = rgObject.matcher(pHtml).replaceAll("");
        pHtml = rgCookie.matcher(pHtml).replaceAll("");
        pHtml = rgEval.matcher(pHtml).replaceAll("");
        pHtml = rgAlert.matcher(pHtml).replaceAll("");
        
        pHtml = pHtml.replace("onerror=", "xonerror=").replace("onclick=", "xonclick=").replace("onblur=", "xonblur=").replace("onfocus=", "xonfocus=");
        pHtml = pHtml.replace("onselect=", "xonselect=").replace("onload=", "xonload=").replace("onsubmit=", "xonsubmit=").replace("onunload=", "xonunload=");
        pHtml = pHtml.replace("onabort=", "xonabort=").replace("onmouseout=", "xonmouseout=").replace("onreset=", "xonreset=").replace("ondbclick=", "xondbclick=");
        pHtml = pHtml.replace("ondragdrop=", "xondragdrop=").replace("onkeydown=", "xonkeydown=").replace("onkeypress=", "xonkeypress=").replace("onkeyup=", "xonkeyup=");
        pHtml = pHtml.replace("onmousedown=", "xonmousedown=").replace("onmousemove=", "xonmousemove=").replace("onmousedown=", "xonmousedown=").replace("onmouseup=", "xonmouseup=");
        pHtml = pHtml.replace("onmove=", "xonmove=").replace("onresize=", "xonresize=");
        pHtml = pHtml.replace(";&#x6", "").replace(";&#x7", "").replace(";&#x2", "").replace("xss:expr", "");

        // 플래시 엑션 스크립트 제한 처리
        pHtml = pHtml.replace("x-shockwave-flash", "_flash_");
        pHtml = pHtml.replace("shockwave-flash", "");
        pHtml = pHtml.replace("_flash_", "shockwave-flash allowscriptaccess='never' invokeurls='false' allownetworking='internal' enablehtmlaccess='false' allowhtmlpopupwindow='false'");

        //XSS 로그 기록
        if (!sTempHtml.equals(pHtml))
        {
            //로그기록
        }

        return pHtml;
    }

    /** HTML에서 특정 패턴의 테그를 제거
     * 
     * @param pHtml
     * @param pPattern
     * @return
     */
    public static String RemoveTag(String pHtml, String pPattern)
    {
    	String strReturn = "";
        try
        {
        	Pattern rgDeclare = Pattern.compile(pPattern, Pattern.DOTALL );            	
        	strReturn = rgDeclare.matcher(pHtml).replaceAll("");
            
            //strReturn = Regex.replace(pHtml, pPattern, "", RegexOptions.Singleline | RegexOptions.IgnoreCase);
		} catch(NullPointerException e){	
			throw e;
		} catch (Exception ex)   {
            throw ex;
        }
        return strReturn;
    }

    /**  텍스트모드에서 작성한 문자열을 HTML 문자열로 변환
    * 
    */
    public static String ConvertContents(String pContents)
    {
        pContents = pContents.replaceAll(" ", "&nbsp;");
        pContents = pContents.replaceAll("\n", "<br />");

        return pContents;
    }

    /** Input 데이터를 DB에 넣을 때 특수문자 처리
    *
    ***/
    public static String ConvertInputValue(String pValue)
    {
        pValue = pValue.replaceAll("&", "&amp;");
        pValue = pValue.replaceAll("<", "&lt;");
        pValue = pValue.replaceAll(">", "&gt;");
        pValue = pValue.replaceAll("\"", "&quot;");
        pValue = pValue.replaceAll("'", "&apos;");
        pValue = pValue.replaceAll("\\\\", "&#x2F;");
        pValue = pValue.replaceAll(" ", "&nbsp;");
        pValue = pValue.replaceAll("\n", "<br />");

        return pValue;
    }

    /**
    * 수정화면으로 데이터를 불러올때 특수문자 처리
    *
    */
    public static String ConvertOutputValue(String pValue)
    {
        pValue = pValue.replaceAll("&amp;", "&");
        pValue = pValue.replaceAll("&lt;", "<");
        pValue = pValue.replaceAll("&gt;", ">");
        pValue = pValue.replaceAll("&quot;", "\"");
        pValue = pValue.replaceAll("&apos;", "'");
        pValue = pValue.replaceAll("&#x2F;", "\\");
        pValue = pValue.replaceAll("&nbsp;", " ");
        pValue = pValue.replaceAll("<br />", "\n");

        return pValue;
    }
	
	
	/**
	 * 파라메터의 SQL Injection 문구 제거
	 * 
	 */
	public static String RemoveSQLInjection(String pParam, int pMax){
		String strResult = null;
		if(pParam != null){
			strResult = pParam.toLowerCase();
			//2019.06.19 구분자 | --> //로 변경
			String strBasicString = "declare//0x4445434//sysdatabases//sysobjects//cast(0x//lcxmarcos//cmd.exe//command.com//gb2312//sp_oa//master.dbo//addextendedproc//is_srvrolemember//savetofile//drop //db_name//wscript.shell//xp_cmdshell//sp_adduser//xp_regwrite//sp_makewebtask//xp_dirtree//xp_regdeletekey//xp_regenumvalues//xp_regread//createobject//adodb.stream//char(124)";
	
	        if (strResult.length() > pMax && pMax != 0)
	        {
	            strResult = strResult.substring(0, pMax);
	        }
	
	        try
	        {
	            // DB 연결에 오류가 있을 경우를 대비하여 처리함. 로그인전 등
	            strBasicString += RedisDataUtil.getBaseConfig("SqlInjectInfo","0");
			} catch(NullPointerException e){	
	        	LOGGER.debug(e);
	        } catch (Exception ex) {
	        	LOGGER.debug(ex);
	        }
	        String[] arrSQLInjection = strBasicString.split("//");
	
	        for(String str : arrSQLInjection)
	        {
	            if (!str.equals("") && strResult.indexOf(str) > -1)
	            {
	            	//2019.06.19 문제가 되는 문자열이 포함된 파라미터 값을 빈값으로 처리함
	            	//Pattern rgDeclare = Pattern.compile(str, Pattern.DOTALL );            	
	                //pParam = rgDeclare.matcher(pParam).replaceAll("");
	            	pParam = "";
	            	break;
	            }
	        }
	
	        //SQL Injection 로그 기록
	        //추가할것
	
	        strResult = pParam;	
		}
		return strResult;
	}
	
	// 날짜 형식 Dash(-) 로 바꾸기
	// 2019/10/08 => 2019-10-08 (/ => -)
	// 2019.10.08 => 2019-10-08 (. => -)
	public static String ConvertDateToDash(String str) {
		if(str != null) {
			str = str.replaceAll("/", "-");
			str = str.replaceAll("\\.", "-");
		}
		
		return str;
	}
	
	// 타임존 적용 start
	
    /// <summary>
    /// 서버시간을 자신의 타임존 시간으로 (로컬포멧으로)변환하여 반환함. 
    /// </summary>
    /// <param name="pServerTime">변환할 시간 문자열(형식- 날짜(2011-01-04)와 시간(09:12, 08:12:12))</param>
    /// <returns>변환된 시간 문자열</returns>
    public static String TransLocalTime(String pServerTime)
    {
    	if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
    		return pServerTime;
    	} else {
    		return TransLocalTime(pServerTime, UR_DateFullFormat);
    	}
    }
    /// <summary>
    /// 서버시간을 자신의 타임존 시간으로 (로컬포멧으로)변환하여 반환함. 
    /// </summary>
    /// <param name="pServerTime">변환할 서버시간</param>
    /// <returns>변환된 시간 문자열</returns>
    public static String TransLocalTime(Date pServerTime)
    {
    	if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
    		SimpleDateFormat format = new SimpleDateFormat(UR_DateFullFormat);
        	return format.format(pServerTime);
    	} else {
    		SimpleDateFormat format = new SimpleDateFormat(ServerDateFullFormat);
        	return TransLocalTime(format.format(pServerTime), UR_DateFullFormat);
    	}
    }
    /// <summary>
    /// 서버시간을 자신의 타임존 시간으로 (로컬포멧으로)변환하여 반환함. 
    /// </summary>
    /// <param name="pServerTime">변환할 서버시간</param>
    /// <param name="pLocalFormat">로컬시간 포멧(지정하기 않을경우 표준시간으로 변환함.)</param>
    /// <returns>변환된 시간 문자열</returns>
    public static String TransLocalTime(Date pServerTime, String pLocalFormat)
    {
    	if (pLocalFormat.equals(""))
        {
            pLocalFormat = UR_DateFullFormat;
        }
    	
    	if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
    		SimpleDateFormat format = new SimpleDateFormat(pLocalFormat);
        	return format.format(pServerTime);
    	} else {
	    	SimpleDateFormat format = new SimpleDateFormat(ServerDateFullFormat);
	    	return TransLocalTime(format.format(pServerTime), pLocalFormat);
    	}
    }
    /// <summary>
    /// 서버시간을 자신의 타임존 시간으로 (로컬포멧으로)변환하여 반환함. 
    /// </summary>
    /// <param name="pServerTime">변환할 시간 문자열(형식- 날짜(2011-01-04)와 시간(09:12, 08:12:12))</param>
    /// <param name="pLocalFormat">로컬시간 포멧(지정하기 않을경우 표준시간으로 변환함.)</param>
    /// <returns>변환된 시간 문자열</returns>
    @SuppressWarnings("deprecation")
	public static String TransLocalTime(String pServerTime, String pLocalFormat)
    {
        if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
	    	return TransDateLocalFormat(pServerTime, pLocalFormat);
        }    
  
    	String pUrTimeZone =SessionHelper.getSession("UR_TimeZone");
    	return TransLocalTime(pServerTime, pLocalFormat, pUrTimeZone);
    }	
    
    /// <summary>
    /// 서버시간을 자신의 타임존 시간으로 (로컬포멧으로)변환하여 반환함. 
    /// </summary>
    /// <param name="pServerTime">변환할 시간 문자열(형식- 날짜(2011-01-04)와 시간(09:12, 08:12:12))</param>
    /// <param name="pLocalFormat">로컬시간 포멧(지정하기 않을경우 표준시간으로 변환함.)</param>
    /// <param name="pUrTimeZone">사용자 타임존</param>
    /// <returns>변환된 시간 문자열</returns>
    @SuppressWarnings("deprecation")
   	public static String TransLocalTime(String pServerTime, String pLocalFormat, String pUrTimeZone)
   	{
    	int l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS;  // 입력 년월일시분초
        String l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus;  // 타임존 시분초 +- 여부
        String l_StringDate, l_StringTime, l_DateFormat = "";
        int l_DateFormatCount;  // 입력 날짜, 입력 시간, 입력날짜 형식, 입력한 값 길이

        if(!"Y".equalsIgnoreCase(RedisDataUtil.getBaseConfig("useTimeZone")) || (pServerTime != null && pServerTime.indexOf("9999") > -1)) {
        	return TransDateServerFormat(pServerTime, pLocalFormat);
        }
        
        if (pServerTime == null){
            pServerTime = "";
        }

        l_DateFormatCount = pServerTime.length();

        // 1. 날짜(2011-01-04)와 시간(09:12, 08:12:12)이 같이 들어와야 한다. 
        if (pServerTime.indexOf(" ") == -1) {
            if (pServerTime.length() == 10)
            {
                return TransDateLocalFormat(pServerTime);
            }
            else
            {
                return pServerTime;
            }
        }

        l_StringDate = pServerTime.split(" ")[0];
        l_StringTime = pServerTime.split(" ")[1];

        // 2. 날짜 형식은 "-", ".", "/"을 받는다.
        // 입력 포멧 확인
        if (l_StringDate.indexOf(".") > -1) { l_DateFormat = "."; }
        if (l_StringDate.indexOf("-") > -1) { l_DateFormat = "-"; }
        if (l_StringDate.indexOf("/") > -1) { l_DateFormat = "/"; }

        if (l_DateFormat.equals(""))
        {
            return pServerTime;
        }
        l_StringDate = l_StringDate.replace("-", "");
        l_StringDate = l_StringDate.replace(".", "");
        l_StringDate = l_StringDate.replace("/", "");
        l_StringTime = l_StringTime.replace(":", "");

        // 3. 시간은 시분까지는 들어와야 한다.(초는 없어도 됨.)
        if (l_StringDate.length() != 8 || l_StringTime.length() < 4)
        {
            return pServerTime;
        }

        // 형식에 맞게 숫자를 체워줌
        l_StringTime = (l_StringTime + "000000").substring(0, 6);

        // 입력받은 일시 분해
        l_InputYear = Integer.parseInt(l_StringDate.substring(0, 4));
        l_InputMonth = Integer.parseInt(l_StringDate.substring(4, 6));
        l_InputDay = Integer.parseInt(l_StringDate.substring(6, 8));
        l_InputHH = Integer.parseInt(l_StringTime.substring(0, 2));
        l_InputMM = Integer.parseInt(l_StringTime.substring(2, 4));
        l_InputSS = Integer.parseInt(l_StringTime.substring(4, 6));
 
        // 시간 형식 체크
        Calendar c = Calendar.getInstance();
        c.set(l_InputYear, l_InputMonth-1, l_InputDay, l_InputHH, l_InputMM, l_InputSS);
        
        if (c.get(Calendar.YEAR) != l_InputYear || (c.get(Calendar.MONTH)+1) != l_InputMonth || c.get(Calendar.DAY_OF_MONTH) != l_InputDay ||
        	c.get(Calendar.HOUR_OF_DAY) != l_InputHH || c.get(Calendar.MINUTE) != l_InputMM || c.get(Calendar.SECOND) != l_InputSS)
        {
            return pServerTime;
        }

        // 자신의 타임존 시간 가져오기(세션에 정의된 타임존 값을 가져옴.)
        l_Minus = pUrTimeZone.substring(0, 1);
        l_TimeZone = pUrTimeZone.replace("-", "").replace(":", "").replace(":", "");

        l_ZoneHH = l_TimeZone.substring(0, 2);
        l_ZoneMM = l_TimeZone.substring(2, 4);
        l_ZoneSS = l_TimeZone.substring(4, 6);

        long l_TimeZoneTime = (Integer.parseInt(l_ZoneHH, 10) * 3600000) + (Integer.parseInt(l_ZoneMM, 10) * 60000) + (Integer.parseInt(l_ZoneSS, 10) * 1000);

        if (l_Minus.equals("-"))
        {
        	c.add(Calendar.MILLISECOND, (int) -l_TimeZoneTime);
        }
        else
        {
        	c.add(Calendar.MILLISECOND, (int) l_TimeZoneTime);
        }
        String l_ReturnString = "";
        if (pLocalFormat.equals(""))
        {
            // 포멧을 지정하지 않을 경우 원래 요청한 (로컬 표준포멧의)형식으로 반환
            pLocalFormat = UR_DateFullFormat;
            l_ReturnString = pLocalFormat
            .replace("yyyy", PadLeft(Integer.toString(c.get(Calendar.YEAR)), 4, "0"))
            .replace("MM", PadLeft(Integer.toString(c.get(Calendar.MONTH)+1), 2, "0"))
            .replace("dd", PadLeft(Integer.toString(c.get(Calendar.DAY_OF_MONTH)), 2, "0"))
            .replace("HH", PadLeft(Integer.toString(c.get(Calendar.HOUR_OF_DAY)), 2, "0"))
            .replace("mm", PadLeft(Integer.toString(c.get(Calendar.MINUTE)), 2, "0"))
            .replace("ss", PadLeft(Integer.toString(c.get(Calendar.SECOND)), 2, "0").substring(0, 2));
            l_ReturnString = l_ReturnString.substring(0, l_DateFormatCount);
        }
        else // 사용자가 포멧을 지정하여 요청하면 요청한 데로 반환
        {
            l_ReturnString = pLocalFormat
            .replace("yyyy", PadLeft(Integer.toString(c.get(Calendar.YEAR)), 4, "0"))
            .replace("MM", PadLeft(Integer.toString(c.get(Calendar.MONTH)+1), 2, "0"))
            .replace("dd", PadLeft(Integer.toString(c.get(Calendar.DAY_OF_MONTH)), 2, "0"))
            .replace("HH", PadLeft(Integer.toString(c.get(Calendar.HOUR_OF_DAY)), 2, "0"))
            .replace("mm", PadLeft(Integer.toString(c.get(Calendar.MINUTE)), 2, "0"))
            .replace("ss", PadLeft(Integer.toString(c.get(Calendar.SECOND)), 2, "0").substring(0, 2));
        }

        return l_ReturnString;
    }

    /// <summary>
    /// 로컬시간을 서버 표준시간으로 변환하여줌
    /// </summary>
    /// <param name="pLocalTime">서버시간으로 변환할 로컬시간 문자열</param>
    /// <returns>서버 표준시간</returns>
    public static String TransServerTime(String pLocalTime)
    {
    	if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
        	return TransDateServerFormat(pLocalTime, ServerDateFullFormat);
        }
    	else {
    		return TransServerTime(pLocalTime, ServerDateFullFormat);	
    	}
    }

    /// <summary>
    /// 로컬시간을 서버 표준시간으로 변환하여줌
    /// </summary>
    /// <param name="pLocalTime">서버시간으로 변환할 로컬시간</param>
        /// <returns>서버 표준시간</returns>
    public static String TransServerTime(Date pLocalTime)
    {
    	if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
    		SimpleDateFormat format = new SimpleDateFormat(UR_DateFullFormat);
        	return TransDateServerFormat(format.format(pLocalTime), UR_DateFullFormat);
    	} else {
    		SimpleDateFormat format = new SimpleDateFormat(UR_DateFullFormat);
            return TransServerTime(format.format(pLocalTime), ServerDateFullFormat);
    	}
    }

    /// <summary>
    /// 로컬시간을 서버 표준시간으로 변환하여줌
    /// </summary>
    /// <param name="pLocalTime">서버시간으로 변환할 로컬시간</param>
    /// <param name="pServerFormat">서버시간 포멧(지정하지 않으면 표준포멧으로 변환)</param>
    /// <returns>서버 표준시간</returns>
    public static String TransServerTime(Date pLocalTime, String pServerFormat)
    {
    	if (pServerFormat.equals(""))
        {
    		pServerFormat = ServerDateFullFormat;
        }
    	
    	if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
	    	SimpleDateFormat format = new SimpleDateFormat(pServerFormat);
	        return TransDateServerFormat(format.format(pLocalTime), pServerFormat);
    	} else {
    		SimpleDateFormat format = new SimpleDateFormat(UR_DateFullFormat);
	        return TransServerTime(format.format(pLocalTime), pServerFormat);
    	}
    }

    /// <summary>
    /// 로컬시간을 서버 표준시간으로 변환하여줌
    /// </summary>
    /// <param name="pLocalTime">서버시간으로 변환할 로컬시간 문자열</param>
    /// <param name="pServerFormat">서버시간 포멧(지정하지 않으면 표준포멧으로 변환)</param>
    /// <returns>서버 표준시간</returns>
    @SuppressWarnings("deprecation")
	public static String TransServerTime(String pLocalTime, String pServerFormat)
    {
        if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
        	return TransDateServerFormat(pLocalTime, pServerFormat);
        }
        
        String pUrTimeZone =SessionHelper.getSession("UR_TimeZone");
        return TransServerTime(pLocalTime, pServerFormat, pUrTimeZone);
    }
    
    /// <summary>
    /// 로컬시간을 서버 표준시간으로 변환하여줌
    /// </summary>
    /// <param name="pLocalTime">서버시간으로 변환할 로컬시간 문자열</param>
    /// <param name="pServerFormat">서버시간 포멧(지정하지 않으면 표준포멧으로 변환)</param>
    /// <param name="pUrTimeZone">사용자 타임존</param>
    /// <returns>서버 표준시간</returns>
    @SuppressWarnings("deprecation")
	public static String TransServerTime(String pLocalTime, String pServerFormat, String pUrTimeZone)
    {
        int l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS;  // 입력 년월일시분초
        String l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus;  // 타임존 시분초 +- 여부
        String l_StringDate, l_StringTime, l_DateFormat = "";
        int l_DateFormatCount;  // 입력 날짜, 입력 시간, 입력날짜 형식, 입력한 값 길이
        boolean l_UserFormat = true;

        if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y") || pLocalTime.indexOf("9999") > -1 || pLocalTime.indexOf("0000") > -1) {
        	return TransDateServerFormat(pLocalTime, pServerFormat);
        }
        
        l_DateFormatCount = pLocalTime.length();

        // 1. 날짜(2011-01-04)와 시간(09:12, 08:12:12)이 같이 들어와야 한다. 
        if (pLocalTime.indexOf(" ") == -1) // 시분이 들어오지 않은 것으로 보고 시분을 붙여준다.
        {
            if (pLocalTime.length() == 10)
            {
                return TransDateServerFormat(pLocalTime);
            }
            else
            {
                return pLocalTime;
            }
        }

        l_StringDate = pLocalTime.split(" ")[0];
        l_StringTime = pLocalTime.split(" ")[1];

        // 2. 날짜 형식은 "-", ".", "/"을 받는다.
        // 입력 포멧 확인
        if (l_StringDate.indexOf(".") > -1) { l_DateFormat = "."; }
        if (l_StringDate.indexOf("-") > -1) { l_DateFormat = "-"; }
        if (l_StringDate.indexOf("/") > -1) { l_DateFormat = "/"; }

        if (l_DateFormat.equals(""))
        {
            return pLocalTime;
        }

        l_StringDate = l_StringDate.replace("-", "");
        l_StringDate = l_StringDate.replace(".", "");
        l_StringDate = l_StringDate.replace("/", "");
        l_StringTime = l_StringTime.replace(":", "");

        // 3. 시간은 시분까지는 들어와야 한다.(초는 없어도 됨.)
        if (l_StringDate.length() != 8 || l_StringTime.length() < 4)
        {
            return pLocalTime;
        }

        // 형식에 맞게 숫자를 체워줌
        l_StringTime = (l_StringTime + "000000").substring(0, 6);
        // 로컬 데이트 포멧
        String strLocalFormat = UR_DateSimpleFormat;

        // 입력받은 일시 분해
        l_InputYear = Integer.parseInt(pLocalTime.substring(strLocalFormat.indexOf("yyyy"), 4));
        l_InputMonth = Integer.parseInt(pLocalTime.substring(strLocalFormat.indexOf("MM"), 7));
        l_InputDay = Integer.parseInt(pLocalTime.substring(strLocalFormat.indexOf("dd"), 10));

        l_InputHH = Integer.parseInt(l_StringTime.substring(0, 2));
        l_InputMM = Integer.parseInt(l_StringTime.substring(2, 4));
        l_InputSS = Integer.parseInt(l_StringTime.substring(4, 6));

        // 시간 형식 체크
        Calendar c = Calendar.getInstance();
        c.set(l_InputYear, l_InputMonth-1, l_InputDay, l_InputHH, l_InputMM, l_InputSS);
        
        if (c.get(Calendar.YEAR) != l_InputYear || (c.get(Calendar.MONTH)+1) != l_InputMonth || c.get(Calendar.DAY_OF_MONTH) != l_InputDay ||
            c.get(Calendar.HOUR_OF_DAY) != l_InputHH || c.get(Calendar.MINUTE) != l_InputMM || c.get(Calendar.SECOND) != l_InputSS)
        {
            return pLocalTime;
        }

        // 자신의 타임존 시간 가져오기(세션에 정의된 타임존 값을 가져옴.)
        if (pUrTimeZone == null || pUrTimeZone.equals("")) pUrTimeZone = "00:00:00";
        l_Minus = pUrTimeZone.substring(0, 1);
        l_TimeZone = pUrTimeZone.replace("-", "").replace(":", "").replace(":", "");

        l_ZoneHH = l_TimeZone.substring(0, 2);
        l_ZoneMM = l_TimeZone.substring(2, 4);
        l_ZoneSS = l_TimeZone.substring(4, 6);

        long l_TimeZoneTime = (Integer.parseInt(l_ZoneHH, 10) * 3600000) + (Integer.parseInt(l_ZoneMM, 10) * 60000) + (Integer.parseInt(l_ZoneSS, 10) * 1000);

        if (l_Minus.equals("-"))
        {
        	c.add(Calendar.MILLISECOND, (int) l_TimeZoneTime);
        }
        else
        {
        	c.add(Calendar.MILLISECOND, (int) -l_TimeZoneTime);
        }
        // 서버포멧 미지정시 기본값 지정
        if (pServerFormat.equals(""))
        {
            pServerFormat = ServerDateFullFormat;
            l_UserFormat = false;
        }

        String l_ReturnString = pServerFormat.replace("yyyy", PadLeft(Integer.toString(c.get(Calendar.YEAR)), 4, "0"))
									        .replace("MM", PadLeft(Integer.toString(c.get(Calendar.MONTH)+1), 2, "0"))
									        .replace("dd", PadLeft(Integer.toString(c.get(Calendar.DAY_OF_MONTH)), 2, "0"))
									        .replace("HH", PadLeft(Integer.toString(c.get(Calendar.HOUR_OF_DAY)), 2, "0"))
									        .replace("mm", PadLeft(Integer.toString(c.get(Calendar.MINUTE)), 2, "0"))
									        .replace("ss", PadLeft(Integer.toString(c.get(Calendar.SECOND)), 2, "0").substring(0, 2));

        // 사용자가 포멧을 적용하여 보내주지 않은 경우는 원래 보내온 형식에 맞춰 반환함.
        if (!l_UserFormat)
        {
        	l_ReturnString = l_ReturnString.substring(0, l_DateFormatCount);
        }
        return l_ReturnString;
    }
    
    /// <summary>
    /// CoviMap Date를 서버타임으로 변환
    /// </summary>
    /// <param name="pLocalDate">시작(StartDate)/종료(EndDate)일자, 시간(StartTime/EndTime)이 들어있는 코비맵 </param>
    /// <param name="pServerFormat">변환할 서버포멧</param>
    /// <returns>서버타임으로 변환된 Date CoviMap 반환</returns>
	public static CoviMap TransServerTimeCoviMapDate(CoviMap pLocalDate, String pServerFormat)
    {
    	CoviMap newDate = pLocalDate; 
    	
    	if(RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) 
    	{
    		if (pServerFormat.equals(""))
            {
        		pServerFormat = ServerDateFormat; //yyyy-MM-dd HH:mm
            }
            
    		String startDateTime = TransServerTime(pLocalDate.getString("StartDate") +" " + pLocalDate.getString("StartTime"), ComUtils.ServerDateFormat);
    		String endDateTime = TransServerTime(pLocalDate.getString("EndDate") +" " +pLocalDate.getString("EndTime"), ComUtils.ServerDateFormat);
    		
    		newDate.put("StartDate", startDateTime.split(" ")[0]);
    		newDate.put("StartTime",  startDateTime.split(" ")[1]);
    		newDate.put("StartDateTime",  startDateTime);
    		newDate.put("EndDate",  endDateTime.split(" ")[0]);		
    		newDate.put("EndTime",  endDateTime.split(" ")[1]);
    		newDate.put("EndDateTime",  endDateTime);
        } else {
        	newDate.put("StartDateTime",  pLocalDate.getString("StartDate") +" " + pLocalDate.getString("StartTime"));
        	newDate.put("EndDateTime",  pLocalDate.getString("EndDate") +" " + pLocalDate.getString("EndTime"));
        }
    			
        return newDate;
    }

    /// <summary>
    /// Local포멧을 표준 Server포멧으로 변환
    /// </summary>
    /// <param name="pLocalDate">포멧을 변경</param>
    /// <returns>포멧이 변환된 값 날짜시간 값</returns>
    public static String TransDateServerFormat(String pLocalDate)
    {
    	return TransDateServerFormat(pLocalDate, "");
    }

    public static String TransDateServerFormat(String pLocalDate, String pServerFormat)
    {
    	String strResult = "";
    	
    	if (pServerFormat.equals(""))
        {
        	pServerFormat = ServerDateSimpleFormat;
        }
        
        if (StringUtil.isNotBlank(pLocalDate) && pLocalDate.indexOf("0000") == -1) // 빈값인 경우도 체크하기 위해 조건 변경함.
        {           
            String p_DateFormat = "";   //입력 포맷 연결자

            if (UR_DateFullFormat.indexOf(".") > -1) { p_DateFormat = "."; }
            if (UR_DateFullFormat.indexOf("-") > -1) { p_DateFormat = "-"; }
            if (UR_DateFullFormat.indexOf("/") > -1) { p_DateFormat = "/"; }
            if (StringUtil.isNull(p_DateFormat)) p_DateFormat = "-";
            
            
        	SimpleDateFormat format_local = null;
        	
        	if(pLocalDate.length() == 10) { // 날짜만
        		format_local = new SimpleDateFormat(UR_DateSimpleFormat);
        	}
        	else if(pLocalDate.length() == 16) { // 날짜+시:분
        		format_local = new SimpleDateFormat(UR_DateFullFormat.substring(0, UR_DateFullFormat.length()-3));
        	}
        	else if(pLocalDate.length() == 19) { // 날짜+시:분:초
        		format_local = new SimpleDateFormat(UR_DateFullFormat);
        	}
        	else {
        		format_local = new SimpleDateFormat(UR_DateSimpleFormat);
        	}
        	
        	Date dt = null;
			try {
				pLocalDate = ConvertDateToDash(pLocalDate);
				
				dt = format_local.parse(pLocalDate);
			} catch (ParseException e) {LOGGER.debug(e);}
        	
			SimpleDateFormat format_server = new SimpleDateFormat(pServerFormat);
        	strResult = format_server.format(dt);
        }

        return strResult;
    }

    /// <summary>
    /// 날짜시간을 포멧에 맞게 반환
    /// </summary>
    /// <param name="pDateTime">포멧을 변환할 시간</param>
    /// <param name="pFormat">변환할 날짜 포멧</param>
    /// <returns>포멧에 맞게 변환한 시간</returns>
    public static String TransDateFormat(Calendar pDateTime, String pFormat)
    {
        pFormat = pFormat.replace("yyyy", Integer.toString(pDateTime.get(Calendar.YEAR)));
        pFormat = pFormat.replace("MM", PadLeft(Integer.toString(pDateTime.get(Calendar.MONTH)+1), 2, "0"));
        pFormat = pFormat.replace("dd", PadLeft(Integer.toString(pDateTime.get(Calendar.DAY_OF_MONTH)), 2, "0"));
        pFormat = pFormat.replace("HH", PadLeft(Integer.toString(pDateTime.get(Calendar.HOUR_OF_DAY)), 2, "0"));
        pFormat = pFormat.replace("mm", PadLeft(Integer.toString(pDateTime.get(Calendar.MINUTE)), 2, "0"));
        pFormat = pFormat.replace("ss", PadLeft(Integer.toString(pDateTime.get(Calendar.SECOND)), 2, "0").substring(0, 2));
        pFormat = pFormat.replace("yy", Integer.toString(pDateTime.get(Calendar.YEAR)).substring(2,4));
        pFormat = pFormat.replace("M", Integer.toString(pDateTime.get(Calendar.MONTH)+1));
        pFormat = pFormat.replace("d", Integer.toString(pDateTime.get(Calendar.DAY_OF_MONTH)));
        pFormat = pFormat.replace("H", Integer.toString(pDateTime.get(Calendar.HOUR_OF_DAY)));
        pFormat = pFormat.replace("m", Integer.toString(pDateTime.get(Calendar.MINUTE)));
        pFormat = pFormat.replace("s", Integer.toString(pDateTime.get(Calendar.SECOND)));

        return pFormat;
    }



    /// <summary>
    /// 표준 Server포멧을 Local포멧으로 변환
    /// </summary>
    /// <param name="pDate">변환할 서버시간 문자열</param>
    /// <returns>Local 포멧으로 변환된 날짜시간 문자열</returns>
    public static String TransDateLocalFormat(String pServerDate)
    {
    	return TransDateLocalFormat(pServerDate, "");
    }

    public static String TransDateLocalFormat(String pServerDate, String pLocalFormat)
    {
    	String strResult = "";
        
        if (pLocalFormat.equals(""))
        {
            pLocalFormat = UR_DateSimpleFormat;
        }

        if (StringUtil.isNotBlank(pServerDate)) // 빈값인 경우도 체크하기 위해 조건 변경함.
        {
        	String s_DateFormat = "";   //입력 포맷 연결자

            if (ServerDateFullFormat.indexOf(".") > -1) { s_DateFormat = "."; }
            if (ServerDateFullFormat.indexOf("-") > -1) { s_DateFormat = "-"; }
            if (ServerDateFullFormat.indexOf("/") > -1) { s_DateFormat = "/"; }
            if (StringUtil.isNull(s_DateFormat)) s_DateFormat = "-";
        	
        	SimpleDateFormat format_server = null;
        	
        	if(pServerDate.length() == 10) { // 날짜만
        		format_server = new SimpleDateFormat(ServerDateSimpleFormat);
        	}
        	else if(pServerDate.length() == 16) { // 날짜+시:분
        		format_server = new SimpleDateFormat(ServerDateFullFormat.substring(0, ServerDateFullFormat.length()-3));
        	}
        	else if(pServerDate.length() == 19) { // 날짜+시:분:초
        		format_server = new SimpleDateFormat(ServerDateFullFormat);
        	}
        	else {
        		format_server = new SimpleDateFormat(ServerDateSimpleFormat);
        	}
        	
        	Date dt = null;
			try {
				pServerDate = ConvertDateToDash(pServerDate);
				
				dt = format_server.parse(pServerDate);
			} catch (ParseException e) {LOGGER.debug(e);}
        	
			SimpleDateFormat format_local = new SimpleDateFormat(pLocalFormat);
        	strResult = format_local.format(dt);
        }

        return strResult;
    }

    // 문자열을 특정 문자로 채움
    public static String PadLeft(String pString, int pCount, String pPadChar)
    {
        StringBuilder l_PadString = new StringBuilder();

        if (pString.length() < pCount)
        {
            for (int i = 0; i < pCount - pString.length(); i++)
            {
            	l_PadString.append(pPadChar);
            }
        }
        return l_PadString.toString() + pString;
    }


    /// <summary>
    /// 오늘 날짜에 해당하는 Local시간 문자열을 리턴
    /// </summary>
    /// <param name="pDateFormat"></param>
    /// <param name="pAddDay"></param>
    /// <returns></returns>
    public static String GetLocalCurrentDate(String pDateFormat, int pAddDay)
    {
        return GetLocalCurrentDate(pDateFormat, pAddDay, SessionHelper.getSession("UR_TimeZone"));
    }
    
    /// <summary>
    /// 오늘 날짜에 해당하는 Local시간 문자열을 리턴
    /// </summary>
    /// <param name="pDateFormat"></param>
    /// <param name="pAddDay"></param>
    /// <returns></returns>
	public static String GetLocalCurrentDate(String pDateFormat, int pAddDay, String pUrTimeZone) {
		String l_LocalDate = "";
		Calendar c = Calendar.getInstance();

		if (RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
    	// 시간 형식 체크
			String l_StandardTimeZoneValue = RedisDataUtil.getBaseConfig("StandardTimeZoneValue"); // UTC - 표준시에 해당하는 시간
																									// 차이
        String l_UrTimeZoneValue = pUrTimeZone;
        String l_TimeZone = "";
        String l_Minus = "";
        String l_ZoneHH = "";
        String l_ZoneMM = "";
        String l_ZoneSS = "";
        
			c = Calendar.getInstance(TimeZone.getTimeZone("GMT"));
        
        if(StringUtil.isBlank(l_StandardTimeZoneValue)) { // 세션값 없는 경우 기초설정 따라감
        	l_StandardTimeZoneValue = "-09:00:00";
        }
        
        l_Minus = l_StandardTimeZoneValue.substring(0, 1);
        l_TimeZone = l_StandardTimeZoneValue.replace("-", "").replace(":", "").replace(":", "");

        l_ZoneHH = l_TimeZone.substring(0, 2);
        l_ZoneMM = l_TimeZone.substring(2, 4);
        l_ZoneSS = l_TimeZone.substring(4, 6);

			long l_TimeZoneTime = (Integer.parseInt(l_ZoneHH, 10) * 3600000) + (Integer.parseInt(l_ZoneMM, 10) * 60000)
					+ (Integer.parseInt(l_ZoneSS, 10) * 1000);

			// 시스템 표준시와의 GMT의 차이 계산
			if (l_Minus.equals("-")) {
				c.add(Calendar.MILLISECOND, (int) l_TimeZoneTime); // StandardTimeZoneValue -09
			} else {
				c.add(Calendar.MILLISECOND, (int) -l_TimeZoneTime);
        }
        
			if (StringUtil.isBlank(l_UrTimeZoneValue)) { // 세션값 없는 경우 기초설정 따라감
				l_UrTimeZoneValue = RedisDataUtil.getBaseConfig("defaultTimeZoneValue");
		}
        
			l_Minus = l_UrTimeZoneValue.substring(0, 1); // 0 - Reserved1
            l_TimeZone = l_UrTimeZoneValue.replace("-", "").replace(":", "").replace(":", "");

            l_ZoneHH = l_TimeZone.substring(0, 2);
            l_ZoneMM = l_TimeZone.substring(2, 4);
            l_ZoneSS = l_TimeZone.substring(4, 6);

			l_TimeZoneTime = (Integer.parseInt(l_ZoneHH, 10) * 3600000) + (Integer.parseInt(l_ZoneMM, 10) * 60000)
					+ (Integer.parseInt(l_ZoneSS, 10) * 1000);
            
			// 사용자 타임존과 시스템 표준시와의 차이 계산
			if (l_Minus.equals("-")) {
                c.add(Calendar.MILLISECOND, (int) -l_TimeZoneTime);
			} else {
            	c.add(Calendar.MILLISECOND, (int) l_TimeZoneTime);
            }
       }

        
        c.add(Calendar.DAY_OF_MONTH, pAddDay);
		l_LocalDate = TransDateFormat(c, pDateFormat);

        return l_LocalDate;
    }

    /// <summary>
    /// 오늘 날짜에 해당하는 Local시간 문자열을 리턴
    /// </summary>
    /// <param name="pDateFormat"></param>
    /// <returns></returns>
    public static String GetLocalCurrentDate(String pDateFormat)
    {
        return GetLocalCurrentDate(pDateFormat, 0);
    }

    /// <summary>
    /// 오늘 날짜에 해당하는 Local시간 문자열을 리턴
    /// </summary>
    /// <returns></returns>
    public static String GetLocalCurrentDate()
    {
        return GetLocalCurrentDate(UR_DateSimpleFormat, 0);
    }
    
	/**
	 * 09:00:00 → (GMT+9) 와 같은 형식변경을 지원합니다. 
	 * 
	 * @param timezone
	 * @return retTimeZoneDisplay
	 */
	public static String ConvertToTimeZoneDisplay(String timezone) {
		StringUtil func = new StringUtil();
		String retTimeZoneDisplay = "(GMT+9)";
		
		if(!func.f_NullCheck(timezone).equals("")) {
			String flag = "";
			String hour = "";
			String minute = "";
			
			if(timezone.charAt(0) == '-') { 
				flag = "-";
				hour = timezone.substring(1,3);
				minute = timezone.substring(4,6);
			} else {
				flag = "+";
				hour = timezone.substring(0,2);
				minute = timezone.substring(3,5);
			}
			
			retTimeZoneDisplay = "(GMT"; 
			retTimeZoneDisplay += flag; 
			retTimeZoneDisplay += Integer.parseInt(hour); 

			if(Integer.parseInt(minute) > 0) {
				retTimeZoneDisplay += (":" +Integer.parseInt(minute));
			}
		
			retTimeZoneDisplay += ")"; 
			
			
		}
		
		return retTimeZoneDisplay;
	}
    // 타임존 적용 end
	
	public static String getServerTitle() {
		String serverTitle= PropertiesUtil.getGlobalProperties().getProperty("front.title") ;
		return serverTitle;
	}
	// 날짜 형식 Dash(-) 로 바꾸기
	// 2019/10/08 => 2019-10-08 (/ => -)
	// 2019.10.08 => 2019-10-08 (. => -)
	public static String ConvertDateFormat(String str, String replaceStr) {
		if(str != null) {
			str = removeMaskAll(str);
			if (str.length() < 4) return str;
			if (replaceStr == null || replaceStr.equals("")) replaceStr=".";

			if (str.length() == 4)
			{
				return str.substring(0, 2) + replaceStr+ str.substring(2, 4);
			}
			else if (str.length() == 6)
			{
				return str.substring(0, 4) + replaceStr + str.substring(4, 6);
			}
			else if (str.length() == 8)
			{
				return str.substring(0, 4) + replaceStr + str.substring(4, 6) + replaceStr + str.substring(6, 8);
			}

			
			str = str.replaceAll("/", "-");
			str = str.replaceAll("\\.", "-");
		}
		
		return str;
	}
 	
	public static Object nullToString(Object value, String mov)
    {
    	// MODIFY [2019-01-06] value type 이 Integer 인 경우 추가
        if (value == null )
            return mov;
        
        return value;
    }
	
	 public static String removeMaskAll(Object sVal){
		if (sVal == null) return "";
   	 	String match = "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]";
   	 	String sOrg = (String)sVal;
    	String sRet =sOrg.replaceAll(match,"");
    	return sRet;
    }
	 
	 //public static String getImageFilePath(String serviceType,String filePath, String savedName){
	 public static String getImageFilePath(String fileID,String filePath, String savedName) throws Exception{
		 //String orgFilePath= RedisDataUtil.getBaseConfig("BackStoragePath").replace("{0}", SessionHelper.getSession("DN_Code")) +  serviceType +'/' + filePath + savedName;
		 CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileID);
		 CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID);
		 String companyCode = fileStorageInfo.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : fileStorageInfo.optString("CompanyCode");
		 String orgFilePath= fileStorageInfo.optString("StorageFilePath").replace("{0}", companyCode) + fileStorageInfo.optString("FileFilePath") + fileStorageInfo.optString("SavedName");
		 
		 return RedisDataUtil.getBaseConfig("ImageLoadURL") + java.net.URLEncoder.encode(orgFilePath);
	 }
	 
	 public static String convertEnc(String planText) throws Exception{
	    	String AES_KEY =  PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	    	AES aes = new AES(AES_KEY, "N");

	    	String userCode = SessionHelper.getSession("UR_Code");
	    	
			String nowTime = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss"); //GMT+0 기준
			String decFileToken = String.format("%s|%s|%s", planText, userCode, nowTime);
			
			return  aes.encrypt(decFileToken);
	    }

	 
    public static String convertDec(String encText) throws Exception{
    	String AES_KEY =  PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
    	
    	try {
    		
    		if(!encText.isEmpty() ) {
    	    	String userCode = SessionHelper.getSession("UR_Code");
        		AES aes = new AES(AES_KEY, "N");
        		
        		String decFileMToken = aes.decrypt(encText);
        		String[] splitFileMToken = decFileMToken.split("[|]");
        		
        		if(splitFileMToken.length == 3) {
        			if(splitFileMToken[1].equals(userCode)) {
    					String nowTime = ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss", 0, "00:00:00"); //GMT+0 기준
        				
        				Date nowDate =  DateHelper.strToDate(nowTime, "yyyy-MM-dd HH:mm:ss");
        				Date createDate =  DateHelper.strToDate(splitFileMToken[2], "yyyy-MM-dd HH:mm:ss");
        				
        				int diffMinute = DateHelper.diffMinute(nowDate, createDate);
        				
        				if(diffMinute <= 120) {
        					return splitFileMToken[0];
        				}
        			}
        		}
        	}
    		
		} catch(NullPointerException e){	
    		LoggerHelper.errorLogger(e, "egovframework.coviframework.util.isValidToken", "Error");
    		return encText;
    	}catch(Exception ex) {
    		LoggerHelper.errorLogger(ex, "egovframework.coviframework.util.isValidToken", "Error");
    		return encText;
    	}
    	
    	return "";
    	
    }
    
    public static String convertBase64Dec(String encText) throws Exception{
   		return new String(Base64.decodeBase64(encText), StandardCharsets.UTF_8);
    }
    //한글 바이트에 맞게 자르기
    public static String substringBytes(String str, int length) { 
		if (str == null || length < 4) return str;
				
		int len	= str.length();
		int cnt = 0, index = 0;
		
		while (index < len && cnt < length)
		{
			// 1바이트 문자라면(영문)
			if (str.charAt(index++) < 256)
				cnt ++;
			else
				cnt += 3;
		}
		
		if (index < len && length >= cnt)
			str = str.substring(0, index);
		else if (index < len && length < cnt)
			str = str.substring(0, index - 1);
		
		return str;
    }
    
	public static CoviMap requestToCoviMap(HttpServletRequest request)
	{ 
		CoviMap coviMap = new CoviMap();
		Enumeration en 			= request.getParameterNames();

		while (en.hasMoreElements())
		{
			String key = (String)en.nextElement();
			String value = request.getParameter(key);
			
			if (key != null && value != null){
				coviMap.put(key, value);
			}
		}
		
		String sortColumn		= "";
		String sortDirection	= "";	
		if(request.getParameter("sortBy") != null ){
			String sortBy = request.getParameter("sortBy");
			String[] sortArray = sortBy.split(" ");
			sortColumn		= sortArray[0];
			if (sortArray.length>1)			sortDirection	= sortArray[1];
			coviMap.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
			coviMap.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
		}
		
		return coviMap;
	}	

	private static Map<String, Properties> properties;
	public static Properties getProperties(String filename) {
		try {
			if (properties == null || properties.get(filename) == null) {		
				Properties p = new Properties();							
				File file = new File( System.getProperty("DEPLOY_PATH")+"/covi_property/" + FileUtil.checkTraversalCharacter(filename) );
				try(FileInputStream fis = new FileInputStream( file );
						InputStreamReader isr = new InputStreamReader(fis, Charset.forName("UTF-8"));
						){
					p.load(isr);
				}
				if(properties == null) {
					properties = new HashMap<String, Properties>();
				}
				properties.put(filename, p);
			}
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);LOGGER.error(e.getLocalizedMessage(), e);
			return new Properties();
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);LOGGER.error(e.getLocalizedMessage(), e);
			return new Properties();
		}
		
		return properties.get(filename);
	}
	
	public static void reloadProperties(String filename) {
		if(properties != null) {
			properties.remove(filename);
		}
		getProperties(filename);
	}

    public static String convertDateFormatV2(String date, String format){
        if(!date.contains("-")){
            return date;
        }
        String[] dateArr = date.split("-");
        String rtn = format;
        if(format.contains("YYYY")){
            rtn = rtn.replace("YYYY", dateArr[0]);
        }
        if(format.contains("MM")){
            rtn = rtn.replace("MM", dateArr[1]);
        }
        if(format.contains("DD")){
            rtn = rtn.replace("DD", dateArr[2]);
        }
        return rtn;
    }
    
    public static boolean getAssignedBizSection(String bizSection){
    	String[] arrBizSection=StringUtil.toTokenArray(SessionHelper.getSession("UR_AssignedBizSection"),"|");

    	if (java.util.Arrays.asList(arrBizSection).contains(bizSection)){ 
    		return true;
    	}
    	return false;
    }
    //css resource version
    public static String getResourceVer(){
    	String resourceVersion = PropertiesUtil.getGlobalProperties().getProperty("resource.version", ""); 
    	
    	if (!RedisDataUtil.getBaseConfig("ResourceVersion","0").equals("")){
    		resourceVersion = RedisDataUtil.getBaseConfig("ResourceVersion","0");
    	}
    	
    	resourceVersion = resourceVersion.equals("") ? "" : ("?ver=" + resourceVersion);
    	return resourceVersion;

    }
    
  //css resource version
    public static String getBaseConfigSyncKey(){
    	String strKey = RedisDataUtil.PRE_BASECONFIG + "SYNC_KEY";
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		return instance.get(strKey)==null?"00000000-0000-0000-0000-000000000000":instance.get(strKey);
    }
    
  //css resource version
    public static String getDictionarySyncKey(){
    	String strKey = RedisDataUtil.PRE_DICTIONARY + "SYNC_KEY";
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		return instance.get(strKey)==null?"00000000-0000-0000-0000-000000000000":instance.get(strKey);
    }
    
    /** 패턴 매칭
    * 2022.11.21 추가
    *
    * @param patten, string
    * @return string
    */
    public static String patternReplace(String patten, String pHtml) {
    	Pattern pattenCompile = Pattern.compile(patten, Pattern.DOTALL );
    	pHtml = pattenCompile.matcher(pHtml).replaceAll("");
    	return pHtml;
    }
    
    /** 스크립트 태그 제거
    * 2022.11.21 추가
    *
    * @param pHtml
    * @return
    */
    public static String RemoveScriptTag(String pHtml) {
	    // 제거 패턴 List 세팅
	    List<String> patternArr = new ArrayList<String>();
	    
	    // 스크립트 제거
	    patternArr.add("<(no)?script[^>]*>.*?</(no)?script>");
	    patternArr.add("<(no)?script[^>]*>");
	    
	    //src Attribute를 사용하는 html 태그 제거 (img태그는 제외)
	    patternArr.add("<(no)?audio[^>]*>.*?</(no)?audio>");
	    patternArr.add("<(no)?audio[^>]*>");
	    patternArr.add("<(no)?embed[^>]*>.*?</(no)?embed>");
	    patternArr.add("<(no)?embed[^>]*>");
	    patternArr.add("<(no)?iframe[^>]*>.*?</(no)?iframe>");
	    patternArr.add("<(no)?iframe[^>]*>");
	    patternArr.add("<(no)?input[^>]*>.*?</(no)?input>");
	    patternArr.add("<(no)?input[^>]*>");
	    patternArr.add("<(no)?source[^>]*>.*?</(no)?source>");
	    patternArr.add("<(no)?source[^>]*>");
	    patternArr.add("<(no)?track[^>]*>.*?</(no)?track>");
	    patternArr.add("<(no)?track[^>]*>");
	    patternArr.add("<(no)?video[^>]*>.*?</(no)?video>");
	    patternArr.add("<(no)?video[^>]*>");
	    
	    //href Attribute를 사용하는 html 태그 제거 (a태그는 제외)
	    patternArr.add("<(no)?base[^>]*>.*?</(no)?base>");
	    patternArr.add("<(no)?base[^>]*>");
	    patternArr.add("<(no)?area[^>]*>.*?</(no)?area>");
	    patternArr.add("<(no)?area[^>]*>");
	    patternArr.add("<(no)?applet[^>]*>.*?</(no)?applet>");
	    patternArr.add("<(no)?applet[^>]*>");
	    patternArr.add("<(no)?object[^>]*>.*?</(no)?object>");
	    patternArr.add("<(no)?object[^>]*>");
	    patternArr.add("<(no)?frameset[^>]*>.*?</(no)?frameset>");
	    patternArr.add("<(no)?frameset[^>]*>");
	    patternArr.add("<(no)?ilayer[^>]*>.*?</(no)?ilayer>");
	    patternArr.add("<(no)?ilayer[^>]*>");
	    patternArr.add("<(no)?layer[^>]*>.*?</(no)?layer>");
	    patternArr.add("<(no)?layer[^>]*>");
	    patternArr.add("document(\\s*).(\\s*)cookie");
	    patternArr.add("eval\\((.*?)");
	    patternArr.add("alert\\((.*?)");
	    
	    // 패턴과 일치하는 텍스트 제거
	    for(String patternStr : patternArr) {
	    	pHtml = patternReplace(patternStr,pHtml);
	    }
	    
	    pHtml = pHtml.replace("onerror=", "xonerror=").replace("onclick=", "xonclick=").replace("onblur=", "xonblur=").replace("onfocus=", "xonfocus=");
		pHtml = pHtml.replace("onselect=", "xonselect=").replace("onload=", "xonload=").replace("onsubmit=", "xonsubmit=").replace("onunload=", "xonunload=");
		pHtml = pHtml.replace("onabort=", "xonabort=").replace("onmouseout=", "xonmouseout=").replace("onreset=", "xonreset=").replace("ondbclick=", "xondbclick=");
		pHtml = pHtml.replace("ondragdrop=", "xondragdrop=").replace("onkeydown=", "xonkeydown=").replace("onkeypress=", "xonkeypress=").replace("onkeyup=", "xonkeyup=");
		pHtml = pHtml.replace("onmousedown=", "xonmousedown=").replace("onmousemove=","xonmousemove=").replace("onmousedown=", "xonmousedown=").replace("onmouseup=", "xonmouseup=");
		pHtml = pHtml.replace("onmove=", "xonmove=").replace("onresize=", "xonresize=");
		pHtml = pHtml.replace(";&#x6", "").replace(";&#x7", "").replace(";&#x2", "").replace("xss:expr", "");
		
	    return pHtml;
	}
	
	/**
     * jwt Token 생성
     * 
     * */
    public static String jwtToken(CoviMap param) throws Exception {

		// 토큰 발급 데이터 세팅 ID, Mail, 사번
		String userID = param.getString("userID");
		String LogonID = param.getString("LogonID");
		String UserCode = param.getString("UserCode");
		String isAdmin = param.getString("isAdmin");
		String newPass = param.getString("newPass");
		String SamAccountName = param.getString("SamAccountName");
		String lang = StringUtil.replaceNull(param.getString("lang"),"ko"); //언어코드
		
		// 만료 시간 설정. 기초 설정 jwtAccessExpirationTime
				long jwtAccExpireTime = Long
						.parseLong(StringUtil.replaceNull(RedisDataUtil.getBaseConfig("jwtAccessExpirationTime"), "3600"));
				jwtAccExpireTime = jwtAccExpireTime * 1000;

				// JWT 발급키. 기초 설정 jwtSetKey
				String jwtKey = RedisDataUtil.getBaseConfig("jwtSetKey");
				String jwtIss = PropertiesUtil.getSecurityProperties().getProperty("jwt.iss"); // 토큰 발급자
				JWSSigner signer = new MACSigner(jwtKey);
				JWTClaimsSet claimsSet = new JWTClaimsSet.Builder().subject(userID) // 토큰 제목
						.issuer(jwtIss) // 토큰 발급자
						.issueTime(new Date()) // 발급 시간
						.expirationTime(new Date(System.currentTimeMillis() + jwtAccExpireTime)) // 만료 시간
						.claim("LogonID", LogonID) // LogonID
						.claim("UserCode", UserCode) // UserCode
						.claim("isAdmin", isAdmin) // 관리자여부
						.claim("newPW", newPass) // 패스워드 변경시 패스워드
						.claim("SamAccountName", SamAccountName) // 패스워드 변경용
						.claim("lang", lang) // 언어코드
						.build();
				SignedJWT signedJWT = new SignedJWT(new JWSHeader(JWSAlgorithm.HS256), claimsSet);
				signedJWT.sign(signer);
				String jwtString = signedJWT.serialize();
		return jwtString;
	}
    
    public static CoviList sortCoviList(CoviList orgList, String key) {

		CoviList sortedJsonArray = new CoviList();
		//정렬
		List<CoviMap> jsonValues = new ArrayList<CoviMap>();
	    for (int i = 0; i < orgList.size(); i++) {
	        jsonValues.add(orgList.getJSONObject(i));
	    }
	    
	    Collections.sort( jsonValues, new Comparator<CoviMap>() {
	        //private static final String KEY_NAME = key;

	        @Override
	        public int compare(CoviMap a, CoviMap b) {
	        	int compare = 0;
                int valA = a.getInt(key);
                int valB = b.getInt(key);

                compare = Integer.compare(valA, valB);
	        	return compare;
	        }
	    });
		
	    for (int i = 0; i < jsonValues.size(); i++) {
	        sortedJsonArray.add(jsonValues.get(i));
	    }
	    
	    return sortedJsonArray;
    }
}
