package egovframework.covision.coviflow.common.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.ContextStartedEvent;
import org.springframework.context.event.ContextStoppedEvent;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;


public class ChromeRenderManager {
	private static final Logger LOGGER = LogManager.getLogger(ChromeRenderManager.class);
	
	// SingleTon
	private volatile static ChromeRenderManager uniqueInstance;
	public static ChromeRenderManager getInstance() {
		return getInstance(true);
	}
	// No SingleTon
	public static ChromeRenderManager getNewInstance(boolean useChromeBrowser) {
		return new ChromeRenderManager(useChromeBrowser);
	}
	
	public static ChromeRenderManager getInstance(boolean useChromeBrowser) {
	      if(uniqueInstance == null) {
	          synchronized(ChromeRenderManager.class) {
	             if(uniqueInstance == null) {
					if(useChromeBrowser) {
						uniqueInstance = new ChromeRenderManager(true); 
					}else {
						uniqueInstance = new ChromeRenderManager(false);
					}

	             }
	          }
	       }
	       return uniqueInstance;
	}
	
	private ChromeRenderManager(boolean useChromeBrowser) {
		if(useChromeBrowser) {
			initialize();
		}
	}
	
	// Chrome instance 재사용.
	// Native process 를 사용하므로 Context 종료시 반드시 kill 되어야 함!!
	ChromeOptions options = null;
	WebDriver driver = null;
	WebDriverWait wait;
	JavascriptExecutor jsDriver = null;
	
	boolean reUseCookie = false;
	public boolean isReUseCookie() {
		return reUseCookie;
	}
	public void setReUseCookie(boolean reUseCookie) {
		this.reUseCookie = reUseCookie;
	}
	private void initialize() {
		try {
			String wxDir = PropertiesUtil.getGlobalProperties().getProperty("pdf.wxDir");
			if(System.getProperty("pdf.wxDir") != null && !"".equals(System.getProperty("pdf.wxDir"))) {
				wxDir = System.getProperty("pdf.wxDir");
			}
			//크롬드라이버 선언 되기전 미리 선행되야함.
			System.setProperty("webdriver.chrome.whitelistedIps", "");
			
			// 크롬 드라이버의 경로를 설정
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
			if(osType.equals("WINDOWS")){
				System.setProperty("webdriver.chrome.driver", wxDir+"chromedriver.exe");
			}else {
				System.setProperty("webdriver.chrome.driver", wxDir+"chromedriver");
			}
   
			ChromeOptions options = new ChromeOptions();
			options.addArguments("--headless");
			options.addArguments("--no-sandbox");
			options.addArguments("--disable-dev-shm-usage");
			
			/*options = new ChromeOptions();
			options.setHeadless(true);*/
			
			driver = new ChromeDriver(options);
			jsDriver = ((JavascriptExecutor)driver);
			wait = new WebDriverWait(driver, 10);
		} catch (NullPointerException npE) {
			//LOGGER.error(npE.getLocalizedMessage(), npE);
			LOGGER.error("chromedriver initialize failed. Please Check chrome-browser installed or chromedriver.", npE);
			close();
			driver = null;
			jsDriver = null;
			wait = null;
		} catch (Exception e) {
			//LOGGER.error(e.getLocalizedMessage(), e);
			LOGGER.error("chromedriver initialize failed. Please Check chrome-browser installed or chromedriver.", e);
			close();
			driver = null;
			jsDriver = null;
			wait = null;
		}
	}
	
	public synchronized CoviMap renderURLOnChrome(String url) {
		CoviMap returnObj = new CoviMap();
		
		try {
			long startTime = System.currentTimeMillis();
			// 드라이버 실행
			LOGGER.debug("locate url on Chrome headless.[{}]", url);
			if(!isReUseCookie()) {
				driver.manage().deleteAllCookies();
			}
        	//jsDriver.executeScript("location.href = '"+ url +"'");
        	driver.navigate().to(url);
			
			// Initialize and wait till element(link) became clickable - timeout in 10 seconds
        	LOGGER.debug("start wait until document loaded.");
			//wait.until(ExpectedConditions.presenceOfElementLocated(By.id("load_complete_s")));
			
			LOGGER.debug("page load elapsed {} ms", (System.currentTimeMillis() - startTime));
			LOGGER.debug("Complete DOM load. start execute getter Script function");
			driver.manage().timeouts().setScriptTimeout(1000, TimeUnit.MILLISECONDS);
			driver.manage().timeouts().pageLoadTimeout(10, TimeUnit.SECONDS);
			
			String executableScript = "return getPcSaveHtml();";
			
			String html = "";
			Object rtnObject = jsDriver.executeScript(executableScript);
			if(rtnObject == null) {
				LOGGER.debug("Return html is null (evel script : {})", executableScript);
			}else {
				html = (String)rtnObject;
				LOGGER.debug("Complete get Html String");
			}
			
			LOGGER.debug("Get parse elapsed {} ms", (System.currentTimeMillis() - startTime));
			
			returnObj.put("rtnHtml", html);
			returnObj.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", npE.getLocalizedMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getLocalizedMessage());
		}
		return returnObj;
	}
	
	
	public CoviMap createPdf(Map<String, String> paramMap) throws Exception {
		long startTime = System.currentTimeMillis();
		CoviMap returnObj = new CoviMap();
		String pdfCssDir = PropertiesUtil.getGlobalProperties().getProperty("pdf.css.dir");
		String pdfDir = PropertiesUtil.getGlobalProperties().getProperty("pdf.dir");
		String wxDir = PropertiesUtil.getGlobalProperties().getProperty("pdf.wxDir");
		
		String html = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">";
		html += "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"ko\" xml:lang=\"ko\"><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><style>";
		
		// css파일 내용 읽음
		byte[] encoded = Files.readAllBytes(Paths.get(FileUtil.checkTraversalCharacter(pdfCssDir + "pdf.css")));
		String cssStr = new String(encoded, StandardCharsets.UTF_8);
		cssStr = cssStr.replace(".header {position:fixed; top:0px; clear:both; width:100%; min-width:1280px; height:45px; background:#ffffff; border-bottom:1px solid #cccccc; z-index:30;}","");
		cssStr = cssStr.replace(".form_box { width:100%; overflow:auto; display:block; height:100%;}", ".form_box { width:100%; display:block; height:100%;}");
		
		html += cssStr;
		html += "</style></head><body>" + paramMap.get("txtHtml") + "</body></html>";
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
	        	File dir = new File(FileUtil.checkTraversalCharacter(pdfDir));
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
	        	
	        	String fileName = pdfDir + uniqueID;
	        	File file = new File(fileName + ".pdf");
	        	// 임시 htm 파일 생성, 내용 입력
	    		FileOutputStream fos = null;
	    		OutputStreamWriter osw = null;
	    		BufferedWriter bw = null;
	    				
    			try {
    				fos = new FileOutputStream(fileName + ".htm");
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
    		    String cmd = wxDir+"wkhtmltopdf --enable-local-file-access " + fileName + ".htm " + fileName + ".pdf";
    			
    			// wkhtmltopdf 실행
    			Process p = Runtime.getRuntime().exec(cmd);
				ReadStream rsIn = null;
				ReadStream rsErr = null;
    			try {
					// process hang 처리를 위한 작업
					rsIn = new ReadStream( p.getInputStream());
					rsErr = new ReadStream(p.getErrorStream());
					
					rsIn.start();
					rsErr.start();
					p.waitFor();
					
					returnObj.put("saveFileName", file.getName());
					returnObj.put("savePath", pdfDir);
					returnObj.put("fileSize", file.length());
    			} catch (NullPointerException npE) {
    				LOGGER.error(npE.getLocalizedMessage(), npE);
    			} catch (Exception e) {
    				LOGGER.error(e.getLocalizedMessage(), e);
    			} finally {
					if (p != null) {
						p.destroy();
					}
					rsIn = null;
					rsErr = null;
					
					// 임시 html 파일 삭제.
					File htmlFile = new File(fileName + ".htm");
					if(htmlFile != null && htmlFile.exists()) {
						if(!htmlFile.delete()) {
							LOGGER.error("Temporary html file delete fail. : " + htmlFile.getAbsolutePath());
						}
					}
    			}
	        }
	        LOGGER.debug(String.format("HTML to PDF elapsed %s ms", (System.currentTimeMillis() - startTime)));
		} catch (IOException ioE) {
			LOGGER.error(ioE.getLocalizedMessage(), ioE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
	
	// Local path 로 셋팅한다.
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
		return localPath;
	}
	
	public void close() {
		if(driver != null) {
			driver.close();
			driver.quit();
		}
	}
	
	private class ReadStream implements Runnable {
		private Object LOCK = new Object();
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
				InputStreamReader isr = null;
				BufferedReader br = null;
				
				try {
					isr = new InputStreamReader(is, StandardCharsets.UTF_8);
					br = new BufferedReader(isr);
					
					while(true) {
						String s = br.readLine();
						if (s == null) break;
					}
				} catch (IOException ioE) {
					LOGGER.error(ioE.getLocalizedMessage(), ioE);
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
					if(br != null) {
						try {
							br.close();
						}catch(IOException ioE) {
							LOGGER.error(ioE.getLocalizedMessage(), ioE);
						}catch(Exception e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						}
					}
					if(isr != null) {
						try {
							isr.close();
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
	
	public synchronized String renderURLOnChromeGen(String url) {
		try {
			long startTime = System.currentTimeMillis();
			// 드라이버 실행
			LOGGER.debug("locate url on Chrome headless.[{}]",url);
        	driver.manage().deleteAllCookies();
        	jsDriver.executeScript("location.href = '"+ url +"'");
			
			// Initialize and wait till element(link) became clickable - timeout in 10 seconds
        	LOGGER.debug("start wait until show element.");
			
        	driver.manage().timeouts().pageLoadTimeout(10, TimeUnit.SECONDS);
        	LOGGER.debug("page load elapsed {} ms", (System.currentTimeMillis() - startTime));
        	LOGGER.debug("Complete DOM load. start execute getter Script function");
			driver.manage().timeouts().setScriptTimeout(1000, TimeUnit.MILLISECONDS);
			String executableScript = "return document.body.innerHTML;";
			
			String html = "";
			Object rtnObject = jsDriver.executeScript(executableScript);
			if(rtnObject == null) {
				LOGGER.debug("Return html is null (evel script : {})", executableScript);
			}else {
				html = (String)rtnObject;
				LOGGER.debug("Complete get Html String");
			}
			
			LOGGER.debug("Get parse elapsed {} ms",(System.currentTimeMillis() - startTime));
			return html;
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			return npE.getLocalizedMessage();
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return e.getLocalizedMessage();
		}
	}
	
	@Service
	public static class ContextListener implements ApplicationListener<ApplicationEvent> {
		@Override
		public void onApplicationEvent(ApplicationEvent event) {
			if(event instanceof ContextClosedEvent || event instanceof ContextStoppedEvent) {
				getInstance(true).close();	
			}
			else if(event instanceof ContextStartedEvent || event instanceof ContextRefreshedEvent) {
				getInstance(true);
			}
		}
	}
}