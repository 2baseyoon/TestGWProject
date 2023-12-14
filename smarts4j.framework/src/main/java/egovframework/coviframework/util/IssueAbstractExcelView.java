package egovframework.coviframework.util;

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
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.Comment;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.LocalizedResourceHelper;
import org.springframework.web.servlet.support.RequestContextUtils;
import org.springframework.web.servlet.view.AbstractView;

public abstract class IssueAbstractExcelView extends AbstractView {

	/** The content type for an Excel response */
	private static final String CONTENT_TYPE = "application/octet-stream";

	/** The extension to look for existing templates */
	private static final String EXTENSION = ".xlsx";


	private String url;


	/**
	 * Default Constructor.
	 * Sets the content type of the view to "application/vnd.ms-excel".
	 */
	public IssueAbstractExcelView() {
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

		XSSFWorkbook workbook = null;
		try {
			if (this.url != null) {
				//workbook = getTemplateSource(this.url, request);
			}
			else {
				workbook = new XSSFWorkbook();
				logger.debug("Created Excel Workbook from scratch");
			}
			
			buildExcelDocument(model, workbook, request, response);
			
			// Set the content type.
			response.setContentType(getContentType());
			
			// Should we set the content length here?
			// response.setContentLength(workbook.getBytes().length);
			
			// Flush byte array to servlet output stream.
			try(ServletOutputStream out = response.getOutputStream();){
				if(workbook != null) {
					workbook.write(out);
				}
				out.flush();
			}
		} finally {
			if(workbook != null) { workbook.close(); }
		}
	}

	/**
	 * Creates the workbook from an existing XLS document.
	 * @param url the URL of the Excel template without localization part nor extension
	 * @param request current HTTP request
	 * @return the HSSFWorkbook
	 * @throws Exception in case of failure
	 */
	/*protected XSSFWorkbook getTemplateSource(String url, HttpServletRequest request) throws Exception {
		LocalizedResourceHelper helper = new LocalizedResourceHelper(getApplicationContext());
		Locale userLocale = RequestContextUtils.getLocale(request);
		Resource inputFile = helper.findLocalizedResource(url, EXTENSION, userLocale);

		// Create the Excel document from the source.
		if (logger.isDebugEnabled()) {
			logger.debug("Loading Excel workbook from " + inputFile);
		}
		POIFSFileSystem fs = new POIFSFileSystem(inputFile.getInputStream());
		return new XSSFWorkbook(fs);
	}*/

	/**
	 * Subclasses must implement this method to create an Excel HSSFWorkbook document,
	 * given the model.
	 * @param model the model Map
	 * @param workbook the Excel workbook to complete
	 * @param request in case we need locale etc. Shouldn't look at attributes.
	 * @param response in case we need to set cookies. Shouldn't write to it.
	 */
	protected abstract void buildExcelDocument(
			Map<String, Object> model, XSSFWorkbook workbook, HttpServletRequest request, HttpServletResponse response)
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
	protected XSSFCell getCell(XSSFSheet sheet, int row, int col) {
		XSSFRow sheetRow = sheet.getRow(row);
		if (sheetRow == null) {
			sheetRow = sheet.createRow(row);
		}
		XSSFCell cell = sheetRow.getCell(col);
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
	protected void setText(XSSFCell cell, String text) {
		cell.setCellType(XSSFCell.CELL_TYPE_STRING);
		cell.setCellValue(text);
	}
	
	protected void setInt(XSSFCell cell, int text) {
		cell.setCellType(XSSFCell.CELL_TYPE_NUMERIC);
		cell.setCellValue(text);
	}
	
	protected void addComment(XSSFWorkbook workbook, XSSFSheet sheet, int rowIdx, int colIdx, String author, String commentText) {
        CreationHelper factory = workbook.getCreationHelper();
        //get an existing cell or create it otherwise:
        XSSFCell cell = getCell(sheet, rowIdx, colIdx);

        ClientAnchor anchor = factory.createClientAnchor();
        //i found it useful to show the comment box at the bottom right corner
        anchor.setCol1(cell.getColumnIndex() + 1); //the box of the comment starts at this given column...
        anchor.setCol2(cell.getColumnIndex() + 3); //...and ends at that given column
        anchor.setRow1(rowIdx + 1); //one row below the cell...
        anchor.setRow2(rowIdx + 5); //...and 4 rows high

        Drawing drawing = sheet.createDrawingPatriarch();
        Comment comment = drawing.createCellComment(anchor);
        //set the comment text and author
        comment.setString(factory.createRichTextString(commentText));
        comment.setAuthor(author);

        cell.setCellComment(comment);
    }

}
