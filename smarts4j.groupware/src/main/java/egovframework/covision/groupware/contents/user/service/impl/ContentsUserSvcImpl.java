package egovframework.covision.groupware.contents.user.service.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.contents.user.service.ContentsUserSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("ContentsUserSvc")
public class ContentsUserSvcImpl extends EgovAbstractServiceImpl implements ContentsUserSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	private static Logger LOGGER = LogManager.getLogger(ContentsUserSvcImpl.class);
	
	//컨텐츠 앱 목록 조회
	@Override
	public CoviMap selectContentsList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.contents.selectContentsList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		return resultList;
	}
	
	//즐겨찾기
	@Override
	public int addContentsFavorite(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.contents.addContentsFavorite", params);
	}

	//즐겨찾기 해제
	@Override
	public int deleteContentsFavorite(CoviMap params) throws Exception {
		return coviMapperOne.delete("user.contents.deleteContentsFavorite", params);
	}
	
	//컨텐츠 앱 이름변경 조회
	@Override
	public CoviMap selectContentsName(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("desc", coviMapperOne.select("user.contents.selectContentsName", params));
		return result;
	}
	
	//컨텐츠 앱 이름변경 처리
	@Override
	public int updateContentsNameChange(CoviMap params) throws Exception {
		return coviMapperOne.update("user.contents.updateContentsNameChange", params);
	}
	
	//사용자 정의 폼 추가 UserFormID 조회
	@Override
	public int selectUserFormKey(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.contents.selectUserFormKey", params);
	}
	
	//사용자 정의 폼 현재 UserFormData 조회
	@Override
	public CoviMap selectUserFormData(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("desc", coviMapperOne.select("user.contents.selectUserFormData", params));
		return result;
	}
	
	// 사용자 정의 필드 옵션 추가 및 수정
	@Override
	public int updateUserDefField(CoviMap params, List formList) throws Exception {
		params.put("userFormList", formList);
		return coviMapperOne.update("user.contents.updateUserDefField", params);
	}
	
	//연결링크 수정
	@Override
	public int updateUserformGotoLink(CoviMap params) throws Exception {
		return coviMapperOne.update("user.contents.updateUserformGotoLink", params);
	}
	
	@Override
	public int insertFolderChart(CoviMap params)  throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		
		return coviMapperOne.insert("user.contents.insertFolderChart",params);
	}
	
	@Override
	public int updateFolderChart(CoviMap params)  throws Exception {
		return coviMapperOne.insert("user.contents.updateFolderChart",params);
	}
	
	@Override
	public int deleteFolderChart(CoviMap params)  throws Exception {
		return coviMapperOne.insert("user.contents.deleteFolderChart",params);
	}

	@Override
	public CoviList getFolderChartList(CoviMap params)  throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList chartList = coviMapperOne.list("user.contents.getFolderChart",params);
		return chartList;
	}
	
	@Override
	public CoviList getChartData(CoviMap params)  throws Exception {
		
		//CoviList resultList = new CoviList();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList chartList = coviMapperOne.list("user.contents.getFolderChart",params);
		
		for (int i = 0; chartList.size() > i; i++) {
			CoviMap fieldObj = chartList.getJSONObject(i);
			if (fieldObj.getString("ChartCol").indexOf("_")>-1  ){
				params.put("chartCol", fieldObj.getString("ChartCol").split("_")[0]);
				params.put("chartColID", fieldObj.getString("ChartCol").split("_")[1]);
			}
			else{
				params.put("chartCol", fieldObj.getString("ChartCol"));
			}
			
			params.put("chartMethod", fieldObj.getString("ChartMethod"));
			if (fieldObj.get("ChartSubCol") != null && !fieldObj.getString("ChartSubCol").equals("")  ){
				params.put("chartSubCol", fieldObj.getString("ChartSubCol").split("_")[1]);
			}
			CoviList listChartData = coviMapperOne.list("user.contents.getFolderChartData",params);
			
			fieldObj.put("ChartData", listChartData);
		}
		
//		resultList.put("list", fieldList);
		return chartList;
		
		
//		params.put("userFormList", formList);
//		return coviMapperOne.update("user.contents.updateUserDefField", params);
	}
	
	//아이콘 조회
	@Override
	public CoviMap selectBoardConfigIcon(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("desc", coviMapperOne.select("user.contents.selectBoardConfigIcon", params));
		return result;
	}
	
	// 아이콘 수정
	@Override
	public int updateBoardConfigIcon(CoviMap params) throws Exception {
		return coviMapperOne.update("user.contents.updateBoardConfigIcon", params);
	}
	
	// 본문 수정
	@Override
	public int updateBoardConfigBody(CoviMap params) throws Exception {
		return coviMapperOne.update("user.contents.updateBoardConfigBody", params);
	}
	// 컨텐츠 앱 폴더 메뉴 조회 
	@Override
	public CoviMap selectContentsFolderMenu(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		resultList.put("list", coviMapperOne.list("user.contents.selectContentsFolderMenu", params));
				  
		return resultList;
	}
	
	//이동할 폴더 조회
	@Override
	public CoviMap selectTargetFolder(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("desc", coviMapperOne.select("user.contents.selectTargetFolder", params));
		return result;
	}
	
	// 컨텐츠 앱 폴더 이동 처리
	@Override
	public int updateTargetFolder(CoviMap params) throws Exception {
		return coviMapperOne.update("user.contents.updateTargetFolder", params);
	}
	// 컨텐츠 앱 순서 저장
	@Override
	public int updateBoardConfigSort(CoviMap params) throws Exception {
		//기존 리스트 제거
		coviMapperOne.update("user.contents.deleteUserDefFieldIsList", params);
		//리스트 여부 저장
		coviMapperOne.update("user.contents.updateUserDefFieldIsList", params);
		//순서 저장
		coviMapperOne.update("user.contents.updateBoardConfigSort", params);
		return 1;
	}
	
	//사용자 정의 폼 삭제전 image 유무 조회
	@Override
	public CoviMap selectUserFormImageData(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("desc", coviMapperOne.select("user.contents.selectUserFormImageData", params));
		return result;
	}
	
	//사용자 정의 필드 Grid 데이터 조회
	@Override
	public CoviMap selectUserDefFieldGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.contents.selectUserDefFormGridList",params);
		
		resultList.put("list",list);
		return resultList;
	}
	
	//대상 폴더 테이블의 데이터로 추가
	@Override
	public int insertSaveFolder(CoviMap params)  throws Exception {
		return coviMapperOne.insert("user.contents.insertSaveFolder",params);
	}
	
	//대상 게시판 설정 테이블의 데이터로 추가
	@Override
	public int insertBoardConfig(CoviMap params)  throws Exception {
		return coviMapperOne.insert("user.contents.insertBoardConfig",params);
	}
	
	/**
	 * 파일 복사
	 * @param sourceFile 복사하려는 파일
	 * @param targetFile 복사될 위치의 파일
	 * @return <code>true</code>: 복사 성공, <code>false</code>: 복사 실패
	 * @throws Exception
	 */
	@Override
	public boolean copy(File sourceFile, File targetFile) throws Exception {
		FileInputStream inputStream = null;
		FileOutputStream outputStream = null;
		
		FileChannel inChannel = null;
		FileChannel outChannel = null;
		
		long size = 0;
		
		try {
			inputStream = new FileInputStream(sourceFile);
			outputStream = new FileOutputStream(targetFile);
			
			inChannel =  inputStream.getChannel();
			outChannel = outputStream.getChannel();
			
			size = inChannel.size();
	
			inChannel.transferTo(0, size, outChannel);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} finally {
			if (outChannel != null) try { outChannel.close(); }catch(IOException ioe){LOGGER.error(ioe.getLocalizedMessage(), ioe);}
			if (inChannel != null) try { inChannel.close(); }catch(IOException ioe){LOGGER.error(ioe.getLocalizedMessage(), ioe);}
			if (outputStream != null) try { outputStream.close(); }catch(IOException ioe){LOGGER.error(ioe.getLocalizedMessage(), ioe);}
			if (inputStream != null) try { inputStream.close(); }catch(IOException ioe){LOGGER.error(ioe.getLocalizedMessage(), ioe);}
		}
		
		return true;
	}
	
}
