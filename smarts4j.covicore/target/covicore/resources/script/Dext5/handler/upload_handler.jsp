<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="java.util.Enumeration"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.RedisShardsUtil,egovframework.baseframework.util.SessionHelper,egovframework.baseframework.data.CoviMap"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="java.io.File"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@ page import="com.dext5.DEXT5Handler" %>
<%
	String key = SessionHelper.getSessionKey(request,false);
	RedisShardsUtil instance = RedisShardsUtil.getInstance();
	CoviMap userDataObj = CoviMap.fromObject(instance.get(key));
	
	if(userDataObj.isEmpty()){
		out.println("<script language='javascript'>location.href='/';</script>");
		return;
	}

	out.clear(); // Servlet으로 handler 작업을 하시려면 제거해주세요.
	
	String _allowFileExt = "gif, jpg, jpeg, png, bmp, wmv, asf, swf, avi, mpg, mpeg, mp4, txt, doc, docx, xls, xlsx, ppt, pptx, hwp, zip, pdf,flv";
	int upload_max_size = 2147483647;
	
	// Servlet으로 handler 작업을 하시려면 다음과 같이 작성해 주세요.
	// 만일 getServletContext()가 undefined 이면 request.getSession().getServletContext(); 으로 하시면 됩니다.
	// ServletContext application = getServletContext();
	
	DEXT5Handler DEXT5 = new DEXT5Handler();
	//DEXT5.SetDebugMode(true);
	
	// 환경설정파일 물리적 폴더 (서버 환경변수를 사용할 경우)
	//DEXT5.SetConfigPhysicalPath("C:/dext5/config");
	
	//DEXT5.SetJpegQuality(100); // JPG 품질 (1 ~ 100)
	// (저품질, 용량 축소) 1 ~ 100 (고품질, 용량 증가) - jdk 1.5 이상에서만 사용가능합니다.
	//DEXT5.SetAntialiasing(true); // 이미지 안티앨리어싱 활성화
	
	try{
		if(request.getParameter("dext") == null){  //test 호출이 아닐때만 아래 문장 실행하도록
			String strUploadPath = "";
			
			String rootPath; //실제 파일이 존재하는 위치
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
			
			if(osType.equals("UNIX")){
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("frontUNIX.path");
			}else{
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("frontWINDOW.path");
			}
			
			strUploadPath = rootPath + PropertiesUtil.getGlobalProperties().getProperty("gwStorageInlineAttach.path");
			
			DEXT5.SetTempRealPath(strUploadPath);
			DEXT5.SetRealPath(strUploadPath);
			
			// ***************보안 설정 : 업로드 가능한 경로 설정 - 이외의 경로로 업로드 불가능***************
			String[] allowUploadDirectoryPath = { strUploadPath };
			DEXT5.SetAllowUploadDirectoryPath(allowUploadDirectoryPath);
		}
	} catch(Exception ex) {
		out.print(ex);
	}
	
	String result = DEXT5.DEXTProcess(request, response, application, _allowFileExt, upload_max_size);
	result = result.replace("/covicore", "");
	
	// AWS S3 적용 시작
	String companyCode = userDataObj.optString("DN_Code");
	egovframework.coviframework.util.s3.AwsS3 awsS3 = egovframework.coviframework.util.s3.AwsS3.getInstance();
	if(awsS3.getS3Active(companyCode)){
		String strSourceFile = DEXT5.LastSaveFile();
		File frontFile = new File(strSourceFile); 
		
		if(frontFile != null && frontFile.exists()) {
			
			String ROOT_PATH = egovframework.coviframework.util.FileUtil.getFrontPath(companyCode)
					+ companyCode
					+ PropertiesUtil.getGlobalProperties().getProperty("gwStorageInlineAttach.path");
			ROOT_PATH = ROOT_PATH.replaceAll("//","/");
			
			String s3key = ROOT_PATH + frontFile.getName();
			if(s3key.startsWith("/")){
				s3key = s3key.substring(1);
			}
			awsS3.upload(frontFile, s3key);
			result =  "/covicore/common/photo/photo.do?img="+s3key;
			
			try {
				frontFile.delete();
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
	}
	// AWS S3 적용 끝
	
	if(DEXT5.IsImageUpload()) {
		/*
		// 동일 폴더에 이미지 썸네일 생성하기
		String strSourceFile = DEXT5.LastSaveFile();
		int rtn_value = DEXT5.ImageThumbnail(strSourceFile, "_thumb", 600, 0);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
	
		/*
		// 동일 폴더에 이미지 썸네일 생성하기 (변경된 파일경로 리턴)
		String strSourceFile = DEXT5.LastSaveFile();
		String strChangedFile = DEXT5.ImageThumbnailEx(strSourceFile, "_thumb", 600, 0);
		if (strChangedFile.equals("")) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 썸네일 파일 생성
		String strSourceFile = DEXT5.LastSaveFile();
		String strNewFileName = strSourceFile.replaceAll("\\\\image\\\\", "\\thumbnail\\");
		int rtn_value = DEXT5.GetImageThumbOrNewEx(strSourceFile, strNewFileName, 200, 0, 0);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 이미지 포멧 변경
		String strSourceFile = DEXT5.LastSaveFile();
		int rtn_value = DEXT5.ImageConvertFormat(strSourceFile, "png", 0);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
	
		/*
		// 이미지 포멧 변경 (변경된 파일경로 리턴)
		String strSourceFile = DEXT5.LastSaveFile();
		String strChangedFile = DEXT5.ImageConvertFormatEx(strSourceFile, "jpg", 0);
		if (strChangedFile.equals("")) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 이미지 크기 변환
		String strSourceFile = DEXT5.LastSaveFile();
		int rtn_value = DEXT5.ImageConvertSize(strSourceFile, 500, 30);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 비율로 이미지 크기 변환
		String strSourceFile = DEXT5.LastSaveFile();
		int rtn_value = DEXT5.ImageConvertSizeByPercent(strSourceFile, 50);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 비율로 이미지 크기 변환
		String strSourceFile = DEXT5.LastSaveFile();
		int rtn_value = DEXT5.ImageConvertSizeByPercent(strSourceFile, 50);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 이미지 회전
		String strSourceFile = DEXT5.LastSaveFile();
		int rtn_value = DEXT5.ImageRotate(strSourceFile, 90);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 이미지 워터마크
		String strSourceFile = DEXT5.LastSaveFile();
		String strWaterMarkFile = "C:\\Temp\\watermark.jpg";
		int rtn_value = DEXT5.ImageWaterMark(strSourceFile, strWaterMarkFile, "TOP", 10, "RIGHT", 10, 0);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
	
		/*
		// 텍스트 워터마크
		String strSourceFile = DEXT5.LastSaveFile();
		DEXT5.SetFontInfo("굴림", 50, "FF00FF");
		int rtn_value = DEXT5.TextWaterMark(strSourceFile, "DEXT5", "TOP", 10, "CENTER", 10, 0, 45);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
	    
	    /*
		// 다른 파일명.확장자 
		String strSourceFile = DEXT5.LastSaveFile();
	    String rtn_value = DEXT5.GetNewFileNameEx("jpg", "TIME");
		if (rtn_value.equals("")) {
			String strLastError = DEXT5.LastErrorMessage();
		}
	    */
	    
	    /*
	    // 이미지 가로(Width) 크기
	    String strSourceFile = DEXT5.LastSaveFile();
	    int rtn_value = DEXT5.GetImageWidth(strSourceFile);
	    if (rtn_value <= 0) {
	        String strLastError = DEXT5.LastErrorMessage();
	    }
	    */
		
		/*
		// 이미지 세로(Height) 크기
		String strSourceFile = DEXT5.LastSaveFile();
		int rtn_value = DEXT5.GetImageHeight(strSourceFile);
		if (rtn_value <= 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
	
		/*
		// 이미지 Format 정보
		String strSourceFile = DEXT5.LastSaveFile();
		String rtn_value = DEXT5.GetImageFormat(strSourceFile);
		if (rtn_value == "") {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 이미지 파일 크기
		String strSourceFile = DEXT5.LastSaveFile();
		long rtn_value = DEXT5.GetImageFileSize(strSourceFile);
		if (rtn_value <= 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
		
		/*
		// 파일 삭제
		String strSourceFile = DEXT5.LastSaveFile();
		int rtn_value = DEXT5.DeleteFile(strSourceFile);
		if (rtn_value != 0) {
			String strLastError = DEXT5.LastErrorMessage();
		}
		*/
	
		/*
		// 원본 파일명 가져오기
		String strOriginalFileName = DEXT5.OriginalFileName();
		*/
	}
	
	if(DEXT5.IsImageUpload()) {
		DEXT5.OriginalFileName();
	}
	
	if(!result.equals("")) {
		out.print(result);
	}
	
	// Servlet으로 handler 작업을 하시려면 다음과 같이 작성해 주세요.
	// Servlet으로 구성하실 때 해당 Function의 Return Type은 void로 선언 후 return 되는 값은 반드시 없어야합니다.
	/*
	if(!result.equals("")) {
		response.setContentType("text/html");
		ServletOutputStream out = response.getOutputStream();
		out.print(result);
		out.close();
	}
	*/
%>
