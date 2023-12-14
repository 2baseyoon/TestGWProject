package egovframework.coviframework.util;

import java.io.IOException;
import java.util.Locale;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.LocalizedResourceHelper;
import org.springframework.web.servlet.support.RequestContextUtils;
import org.springframework.web.servlet.view.AbstractView;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

public abstract class CoviAbstractExcelView extends AbstractView {

	private static final Logger LOGGER = LogManager.getLogger(CoviAbstractExcelView.class);
	/** The content type for an Excel response */
	private static final String CONTENT_TYPE = "application/octet-stream";

	/** The extension to look for existing templates */
	private static final String EXTENSION = ".xlsx";


	private String url;


	/**
	 * Default Constructor.
	 * Sets the content type of the view to "application/vnd.ms-excel".
	 */
	public CoviAbstractExcelView() {
		setContentType(CONTENT_TYPE);
	}

	/**
	 * Set the URL of the Excel workbook source, without localization part nor extension.
	 */
	public void setUrl(String url) {
		this.url = url;
	}


	@Override
	protected boolean generatesDownloadContent() {
		return true;
	}

	/**
	 * Renders the Excel view, given the specified model.
	 */
	@Override
	protected final void renderMergedOutputModel(
			Map<String, Object> model, HttpServletRequest request, HttpServletResponse response) throws Exception {

		HSSFWorkbook workbook = null;
		POIFSFileSystem fs = null;
		try {
			if (this.url != null) {
				// workbook = getTemplateSource(this.url, request);
				
				LocalizedResourceHelper helper = new LocalizedResourceHelper(getApplicationContext());
				Locale userLocale = RequestContextUtils.getLocale(request);
				Resource inputFile = helper.findLocalizedResource(url, EXTENSION, userLocale);

				// Create the Excel document from the source.
				if (logger.isDebugEnabled()) {
					logger.debug("Loading Excel workbook from " + inputFile);
				}
				fs = new POIFSFileSystem(inputFile.getInputStream());
				workbook = new HSSFWorkbook(fs);
			}
			else {
				workbook = new HSSFWorkbook();
				logger.debug("Created Excel Workbook from scratch");
			}
			
			buildExcelDocument(model, workbook, request, response);
			
			// Set the content type.
			response.setContentType(getContentType());
			
			// Should we set the content length here?
			// response.setContentLength(workbook.getBytes().length);
			
			// Flush byte array to servlet output stream.
			try(ServletOutputStream out = response.getOutputStream();){
				workbook.write(out);
				out.flush();
			}
		} finally {
			if(workbook != null) { try { workbook.close(); }catch(IOException ioe) {LOGGER.error(ioe);} }
			if(fs != null) { try { fs.close(); }catch(IOException ioe) {LOGGER.error(ioe);} }
		}
	}

	/**
	 * Subclasses must implement this method to create an Excel HSSFWorkbook document,
	 * given the model.
	 * @param model the model Map
	 * @param workbook the Excel workbook to complete
	 * @param request in case we need locale etc. Shouldn't look at attributes.
	 * @param response in case we need to set cookies. Shouldn't write to it.
	 */
	protected abstract void buildExcelDocument(
			Map<String, Object> model, HSSFWorkbook workbook, HttpServletRequest request, HttpServletResponse response)
			throws Exception;


	/**
	 * Convenient method to obtain the cell in the given sheet, row and column.
	 * <p>Creates the row and the cell if they still doesn't already exist.
	 * Thus, the column can be passed as an int, the method making the needed downcasts.
	 * @param sheet a sheet object. The first sheet is usually obtained by workbook.getSheetAt(0)
	 * @param row thr row number
	 * @param col the column number
	 * @return the HSSFCell
	 */
	protected HSSFCell getCell(HSSFSheet sheet, int row, int col) {
		HSSFRow sheetRow = sheet.getRow(row);
		if (sheetRow == null) {
			sheetRow = sheet.createRow(row);
		}
		HSSFCell cell = sheetRow.getCell(col);
		if (cell == null) {
			cell = sheetRow.createCell(col);
		}
		return cell;
	}

	/**
	 * Convenient method to set a String as text content in a cell.
	 * @param cell the cell in which the text must be put
	 * @param text the text to put in the cell
	 */
	protected void setText(HSSFCell cell, String text) {
		cell.setCellType(HSSFCell.CELL_TYPE_STRING);
		cell.setCellValue(text);
	}
	
	protected void setNumeric(HSSFCell cell, String text) {
		cell.setCellType(HSSFCell.CELL_TYPE_NUMERIC);
		cell.setCellValue(Integer.parseInt(text));
	}

}
