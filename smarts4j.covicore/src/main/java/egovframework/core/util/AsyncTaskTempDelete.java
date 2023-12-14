package egovframework.core.util;


import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;

import egovframework.coviframework.util.s3.AwsS3;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import com.amazonaws.services.s3.model.ListObjectsV2Result;
import com.amazonaws.services.s3.model.S3ObjectSummary;

import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.FileUtil;

/**
 * AsyncTaskTempDelete *
 */
@Service("asyncTaskTempDelete")
public class AsyncTaskTempDelete {
	
	private Logger log = LogManager.getLogger(AsyncTaskTempDelete.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	private int BACKUP_AFTER_DAYS = -1; 
	private int DELETE_AFTER_DAYS = -1; 
	private String DELETE_FILTER_EXT = null; 
	private String DELETE_FILTER_FILENAME = null; 
	
	AwsS3 awsS3 = AwsS3.getInstance();
	
	public AsyncTaskTempDelete() {
		String backupDays = PropertiesUtil.getExtensionProperties().getProperty("frontstorage.auto.delete.backup.days");
		String deleteDays = PropertiesUtil.getExtensionProperties().getProperty("frontstorage.auto.delete.delete.days");
			
		BACKUP_AFTER_DAYS = (backupDays != null && !"".equals(backupDays))? Integer.parseInt(backupDays) : -1;
		DELETE_AFTER_DAYS = (deleteDays != null && !"".equals(deleteDays))? Integer.parseInt(deleteDays) : -1;
		
		DELETE_FILTER_EXT = PropertiesUtil.getExtensionProperties().getProperty("frontstorage.auto.delete.filter.ext");
		DELETE_FILTER_FILENAME = PropertiesUtil.getExtensionProperties().getProperty("frontstorage.auto.delete.filter.filename");
	}
	
	@Async("executorTempDelete")
	public void execute() throws Exception{
		try {
			// 일반 스토리지
			deleteTemp();
			
			// AWS S3
			deleteTemp_S3();
		} 
		catch (NullPointerException ne) {
			log.error(ne.getLocalizedMessage(), ne);
		}
		catch (Exception ex) {
			log.error(ex.getLocalizedMessage(), ex);
		} 
	}
	
	private void deleteTemp() throws Exception{
		StringBuilder moveLogBuf = new StringBuilder();
		StringBuilder deleteLogBuf = new StringBuilder();
		File frontDir = null;
		File backupDir = null;
		try {
			long start = System.currentTimeMillis();
			long elapsed = 0L;
			String frontPath = StringUtil.replaceNull(FileUtil.getFrontPath(false), "");
			String frontBackupPath = frontPath + (frontPath.endsWith(File.separator) ? "" : File.separator) + "autodelete";
					
			if(StringUtil.isNotNull(frontPath)) {
				frontDir = new File(frontPath);
				if (!frontDir.exists()) {
					throw new FileNotFoundException(frontDir.getAbsolutePath());
				}
	
				backupDir = new File(frontBackupPath);
				if (!backupDir.exists()) {
					if(!backupDir.mkdirs()) {
						log.debug("Failed to make directories.");
					}
				}
				// 1. move files from front path to font backup directory.
				if(BACKUP_AFTER_DAYS > -1) {
					moveLogBuf.append("[ " + new java.util.Date() + " ] Moved file logs. \n\n");
					moveToBackup(frontDir, moveLogBuf, frontDir, backupDir);
				}
				elapsed = System.currentTimeMillis() - start;
				start = System.currentTimeMillis();
				log.info("Frontstorage temporary file move to backup complete. elapsed " + elapsed + "ms");
				
				// 2. delete files from backup directory
				if(DELETE_AFTER_DAYS > -1) {
					deleteLogBuf.append("[ " + new java.util.Date() + " ] Delete file logs. \n\n");
					deleteFromBackup(backupDir, deleteLogBuf, backupDir);
				}
				elapsed = System.currentTimeMillis() - start;
				start = System.currentTimeMillis();
				log.info("Frontstorage temporary file delete from backup Directory complete. elapsed " + elapsed + "ms");
			}
			
		} 
		catch (NullPointerException ne) {
			log.error("[deleteTemp] " + ne.getLocalizedMessage(), ne);
		}
		catch (Exception ex) {
			log.error("[deleteTemp] " + ex.getLocalizedMessage(), ex);
		} 
		finally {
			try {
				String format = DateHelper.getCurrentDay("yyyy-MM-dd-HHmmss");
				Files.write( new File(frontDir, format + ".log").toPath(), moveLogBuf.toString().getBytes("UTF-8"));
				Files.write( new File(backupDir, format + ".log").toPath(), deleteLogBuf.toString().getBytes("UTF-8"));
			}
			catch(IOException ie) {
				log.error("[IOException] " + ie.getLocalizedMessage(), ie);
			}
			catch(Exception e) {
				log.error(e.getLocalizedMessage(), e);
			}
		}
	}
	
	private void deleteTemp_S3() throws Exception{
		String frontPath_S3 = StringUtil.replaceNull(FileUtil.getFrontPath(true), ""); // FrontStorage/
		String frontBackupPath_S3 = frontPath_S3 + (frontPath_S3.endsWith("/") ? "" : "/") + "autodelete" + "/"; // FrontStorage/autodelete/
		
		StringBuilder moveLogBuf = new StringBuilder();
		StringBuilder deleteLogBuf = new StringBuilder();
		try {
			long start = System.currentTimeMillis();
			long elapsed = 0L;
			
			if(StringUtil.isNotNull(frontPath_S3)) {
				// 1. move files from front path to font backup directory.
				if(BACKUP_AFTER_DAYS > -1) {
					int backupDays = BACKUP_AFTER_DAYS;
					long now = System.currentTimeMillis();
					long offsetTime = 1L * backupDays * 24 * 60 * 60 * 1000;
					moveLogBuf.append("[ " + new java.util.Date() + " ] Moved file logs. \n\n");
					moveLogBuf.append("(backup days : " + backupDays + ")\n\n");
					moveLogBuf.append("(DELETE_FILTER_EXT : " + DELETE_FILTER_EXT + ")\n\n");
					moveLogBuf.append("(DELETE_FILTER_FILENAME : " + DELETE_FILTER_FILENAME + ")\n\n");
					
			        ListObjectsV2Result result = awsS3.getFileList(frontPath_S3);
			       
			        // 하위폴더 포함 모든 파일만 조회되며, 빈 디렉토리는 추가되지 않고 내부 파일이 모두 삭제되면 디렉토리는 자동삭제되므로 파일만 처리
			        List<S3ObjectSummary> s3Objects = result.getObjectSummaries();
			        
			        for (S3ObjectSummary obj : s3Objects) {
			        	String key = obj.getKey(); // 파일경로
			        	String filename = key.substring(key.lastIndexOf("/") + 1);
			    		String ext = FilenameUtils.getExtension(filename);
			    		if(filename.equals("")) { // 디렉토리는 패스
			    			continue;
			    		}
			        	if(key.startsWith(frontBackupPath_S3)) { // 백업폴더 내부파일은 패스
			        		continue;
			        	}
			        	if(isFilterFile(filename, ext)) { // 예외 파일명 및 확장자 패스
			        		continue;
			        	}
			        	Date lastModified = awsS3.getLastModified(key); // 파일 수정일자
						long modified = lastModified.getTime();
						
						if(modified < ( now - offsetTime )) {
							String relativePath = key.replace(frontPath_S3, "");
							String targetPath = frontBackupPath_S3 + relativePath;
							
							awsS3.move(key, targetPath);
							
							moveLogBuf.append("[Moved] " + key + " to " + targetPath + "( "+ new java.util.Date(modified) +" )" + "\n");
						}
			        }
			        
				}    
				elapsed = System.currentTimeMillis() - start;
				start = System.currentTimeMillis();
				log.info("Frontstorage S3 temporary file move to backup complete. elapsed " + elapsed + "ms");
				
				// 2. delete files from backup directory 
				if(DELETE_AFTER_DAYS > -1) {
					int deleteDays = DELETE_AFTER_DAYS;
					long now = System.currentTimeMillis();
					long offsetTime = 1L * deleteDays * 24 * 60 * 60 * 1000;
					deleteLogBuf.append("[ " + new java.util.Date() + " ] Delete file logs. \n\n");
					deleteLogBuf.append("(delete days : " + deleteDays + ")\n\n");
					deleteLogBuf.append("(DELETE_FILTER_EXT : " + DELETE_FILTER_EXT + ")\n\n");
					deleteLogBuf.append("(DELETE_FILTER_FILENAME : " + DELETE_FILTER_FILENAME + ")\n\n");
					
			        ListObjectsV2Result result = awsS3.getFileList(frontBackupPath_S3);
			        
			        // 하위폴더 포함 모든 파일만 조회되며, 빈 디렉토리는 추가되지 않고 내부 파일이 모두 삭제되면 디렉토리는 자동삭제되므로 파일만 처리
			        List<S3ObjectSummary> s3Objects = result.getObjectSummaries();
					
			        for (S3ObjectSummary obj : s3Objects) {
			        	String key = obj.getKey(); // 파일경로
			        	String filename = key.substring(key.lastIndexOf("/") + 1);
			    		String ext = FilenameUtils.getExtension(filename);
			        	if(isFilterFile(filename, ext)) { // 예외 파일명 및 확장자 패스
			        		continue;
			        	}
			        	
			        	Date lastModified = awsS3.getLastModified(key); // 파일 수정일자
			        	
						long modified = lastModified.getTime();
						
						if(modified < ( now - offsetTime )) {
							awsS3.delete(key);
							
							deleteLogBuf.append("[Deleted] " + key + "( "+ new java.util.Date(modified) +" )" + "\n");
						}
			        }
			        
				}
				elapsed = System.currentTimeMillis() - start;
				start = System.currentTimeMillis();
				log.info("Frontstorage S3 temporary file delete from backup Directory complete. elapsed " + elapsed + "ms");
			}
			
		} 
		catch (NullPointerException ne) {
			log.error("[deleteTemp_S3] " + ne.getLocalizedMessage(), ne);
		}
		catch (Exception ex) {
			log.error("[deleteTemp_S3] " + ex.getLocalizedMessage(), ex);
		} 
		finally {
			try {
				String format = DateHelper.getCurrentDay("yyyy-MM-dd-HHmmss");
				if(moveLogBuf != null) {
					String moveLog = moveLogBuf.toString();
					try(InputStream inMove = new ByteArrayInputStream(moveLog.getBytes("UTF-8"))){
						awsS3.upload(inMove, frontPath_S3 + format + ".log", "text/plain", moveLog.getBytes("UTF-8").length);
					}
				}
				if(deleteLogBuf != null) {
					String deleteLog = deleteLogBuf.toString();
					try(InputStream inDelete = new ByteArrayInputStream(deleteLog.getBytes("UTF-8"))){
						awsS3.upload(inDelete, frontBackupPath_S3 + format + ".log", "text/plain", deleteLog.getBytes("UTF-8").length);
					}
				}
			}
			catch(IOException ie) {
				log.error("[IOException] " + ie.getLocalizedMessage(), ie);
			}
			catch(Exception e) {
				log.error(e.getLocalizedMessage(), e);
			}
			finally {
			}
		}
	}
	
	private boolean moveToBackup(File file, StringBuilder moveLogBuf, File frontDir, File backupDir) throws IOException {
		if(file != null) {
			if(file.isFile()) {
				int backupDays = BACKUP_AFTER_DAYS;
				long modified = file.lastModified();
				long now = System.currentTimeMillis();
				long offsetTime = 1L * backupDays * 24 * 60 * 60 * 1000;
				if(modified < ( now - offsetTime )) {
					String frontPath = frontDir.toPath().toString();
					String relativePath = file.toPath().toString().replace(frontPath, "");
					
					Path targetPath = new File(backupDir.toPath().toString() + relativePath).toPath();
					try {
						Files.createDirectories(targetPath);
					} catch (FileAlreadyExistsException e) {
						log.debug(e);
					}
					Files.move(file.toPath(), targetPath, StandardCopyOption.REPLACE_EXISTING);
					moveLogBuf.append("[Moved] " + file.toPath() + " to " + targetPath + "\n");
				}
			}else {
				if(!file.equals(backupDir)) {
					File[] files = file.listFiles(new FileFilter() {
						@Override
						public boolean accept(File check) {
							return !isFilterFile(check);
						}
					});
					if(files != null) {
						for(File f : files) {
							// recursive call.
							moveToBackup(f, moveLogBuf, frontDir, backupDir);
						}
					}
					
					// 빈폴더 삭제
					if(!file.equals(frontDir) && file.list() != null && file.list().length == 0) {
						if(!file.delete()) {
							log.debug("Failed to delete directories.");
						}
					}
				}
			}
			return true;
		}
		return false;
	}
	
	private boolean deleteFromBackup(File file, StringBuilder deleteLogBuf, File backupDir) {
		if(file != null) {
			if(file.isFile()) {
				int backupDays = DELETE_AFTER_DAYS;
				long modified = file.lastModified();
				long now = System.currentTimeMillis();
				long offsetTime = 1L * backupDays * 24 * 60 * 60 * 1000;
				if(modified < ( now - offsetTime )) {
					if(file.delete()) {
						log.debug("Failed to delete file.");
					}
					deleteLogBuf.append("[Deleted] " + file.toPath() + "( "+ new java.util.Date(modified) +" )" + "\n");
				}
			}else {
				File[] files = file.listFiles(new FileFilter() {
					@Override
					public boolean accept(File check) {
						return !isFilterFile(check);
					}
				});
				if(files != null) {
					for(File f : files) {
						// recursive call.
						deleteFromBackup(f, deleteLogBuf, backupDir);
					}
				}
				
				// 빈폴더 삭제
				if(!file.equals(backupDir) && file.list() != null && file.list().length == 0) {
					if(!file.delete()) {
						log.debug("Failed to delete directories.");
					}
				}
			}
			return true;
		}
		return false;
	}
	
	private boolean isFilterFile(File file) {
		// Check file to ignore.
		String ext = FilenameUtils.getExtension(file.getName());
		String filename = file.getName();
		
		return isFilterFile(filename, ext);
	}
	
	private boolean isFilterFile(String filename, String ext) {
		if(DELETE_FILTER_EXT != null && !StringUtil.isEmpty(DELETE_FILTER_EXT)) {
			String [] excludeFileExt = StringUtils.split(DELETE_FILTER_EXT, ",");
			List<String> excludeFileExtList = Arrays.asList(excludeFileExt);
			if(excludeFileExtList.contains(ext)) {
				return true;
			}
		}
		
		if(DELETE_FILTER_FILENAME != null && !StringUtil.isEmpty(DELETE_FILTER_FILENAME)) {
			String [] excludeFileName = StringUtils.split(DELETE_FILTER_FILENAME, ",");
			if(excludeFileName != null) {
				for(String nameChk : excludeFileName) {
					if(filename.indexOf(nameChk) > -1) {
						return true;
					}
				}
			}
		}
		return false;
	}
}