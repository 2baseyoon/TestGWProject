define([], function () {
	return {
		/**
		 * Class name define
		 * 1. attributeName : {attributeValue: className} // 특정 value
		 * 2. attributeName : className // value 와 무관
		 */
		XmlAttrToClassCommon: {
			size: {
				"small": "small_size",
				"medium": "medium_size",
				"large": "large_size",
				"xlarge": "xlarge_size",
				"full": "full_size",
				"fit": "fit_size"
			},
			textAlign: {
				"left": "text_align_left",
				"center": "text_align_center",
				"right": "text_align_right"
			}
		},
		XmlAttrToClass: {
			// Xml Tag 별로 정리. defaultClass 는 해당 Tag 라면 항상 삽입됨.
			Panel: {
				matchReverse: {
					"true": "match_reverse"
				}
			},
			NormalPanel: {
				defaultClass: "normal_panel",
				childHAlign: {
					"left": "justify_left",
					"center": "justify_center",
					"right": "justify_right"
				},
				childVAlign: {
					"top": "align_item_top",
					"center": "align_item_center",
					"bottom": "align_item_bottom"
				}
			},
			InlinePanel: {
				defaultClass: "inline_panel",
				childHAlign: {
					"left": "justify_left",
					"center": "justify_center",
					"right": "justify_right"
				},
				childVAlign: {
					"top": "align_item_top",
					"center": "align_item_center",
					"bottom": "align_item_bottom"
				},
				width: {
					"fit": "fit_size"
				}
			},
			Dropdown: {
				defaultClass: "btn_dropdown btn_wo btn_wo_fn",
				arrowVisible: {
					"false": "no_arrow"
				},
				direction: {
					"vertical": "direction_v"
				}
			},
			NormalDropdown: {
				defaultClass: "icon_combo"
			},
			TextDropdown: {
				defaultClass: "text_dropdown",
				icon: {
					"false": "no_icon"
				}
			},
			ColorDropdown: {
				defaultClass: "color_dropdown",
				icon: {
					"false": "no_icon"
				}
			},
			ColorWithIconDropdown: {
				defaultClass: "color_with_icon"
			},
			LineStyleDropdown: {
				defaultClass: "line_style_dropdown",
				icon: {
					"false": "no_icon"
				}
			},
			ArrowDropdown: {
				defaultClass: "arrow_dropdown"
			},
			Combo: {
				defaultClass: "btn_combo btn_wo btn_wo_fn",
				direction: {
					"vertical": "direction_v"
				}
			},
			NormalCombo: {
				defaultClass: "icon_combo"
			},
			InputCombo: {
				defaultClass: "text_dropdown input_wrap"
			},
			ResultButtonCombo: {
				defaultClass: "text_btn_combo"
			},
			ColorCombo: {
				defaultClass: "color_dropdown"
			},
			ColorWithIconCombo: {
				defaultClass: "color_with_icon"
			},
			LineStyleCombo: {
				defaultClass: "line_style_dropdown"
			},
			Checkbox: {
				defaultClass: "checkbox_wrap input_wrap"
			},
			Radio: {
				defaultClass: "radio_wrap input_wrap"
			},
			LocalFile: {
				defaultClass: "local_file_wrap input_wrap"
			},
			Input: {
				defaultClass: "input_text_wrap input_wrap",
				remainUiFocus: {
					"true": "remain_ui_focus"
				}
			},
			Button: {
				defaultClass: "",
				icon: {
					"false": "no_icon"
				},
				onLink: {
					"true": "on_link"
				},
				direction: {
					"vertical": "direction_v"
				}
			},
			Image: {
				defaultClass: "image_box"
			},
			Zoom: {
				defaultClass: "zoom_bar"
			},
			ListBox: {
				defaultClass: "list_box"
			},
			NormalListBox: {
				defaultClass: "normal_panel",
				childHAlign: {
					"center": "justify_center",
					"right": "justify_right"
				},
				childVAlign: {
					"center": "align_item_center",
					"bottom": "align_item_bottom"
				}
			},
			InlineListBox: {
				defaultClass: "inline_panel",
				childHAlign: {
					"center": "justify_center",
					"right": "justify_right"
				},
				childVAlign: {
					"center": "align_item_center",
					"bottom": "align_item_bottom"
				}
			},
			Data: {
				defaultClass: "dropdown_data",
				icon: {
					"false": "no_icon"
				}
			},
			TabGroup: {
				defaultClass: "tab_group normal_panel"
			},
			Tab: {
				defaultClass: "btn_tab"
			},
			Textarea: {
				defaultClass: "textarea_box"
			}
		},

		//container
		CONTAINER_CLASS: "container_view",

		//panel
		TITLE_PANEL_WRAP_CLASS: "title_panel",
		SUBTITLE_PANEL_WRAP_CLASS: "subtitle_panel",
		NORMAL_PANEL_CLASS: "normal_panel",
		INLINE_PANEL_CLASS: "inline_panel",
		PROPERTY_TITLE_CLASS: "property_title",
		BOX_ELEMENT_CLASS: "menu_box",
		BUTTON_BOX_ELEMENT_CLASS: "button_box",
		DIALOG_BOX_ELEMENT_CLASS: "dialog_box",
		PROPERTY_SUBTITLE_CLASS: "property_subtitle",
		SUB_BOX_ELEMENT_CLASS: "sub_box",
		SUB_GROUP_ELEMENT_CLASS: "sub_group",
		SUB_GROUP_TITLE_CLASS: "sub_group_title",
		SUB_GROUP_BOX_ELEMENT_CLASS: "sub_group_box",
		PROGRESS_BAR_AREA_CLASS: "progress_bar_area",
		PROGRESS_PERCENT_CLASS: "progress_percent",
		PROGRESS_BAR_CLASS: "progress_bar",
		TAB_GROUP_CLASS: "tab_group",
		PANEL_CLASS_ARR: ["normal_panel", "inline_panel", "title_panel", "subtitle_panel"],
		MESSAGE_BAR_CLASS: "message_bar",
		LIST_BOX_CLASS: "list_box",
		ALIGN_CENTER_CLASS: "justify_center",
		ALIGN_RIGHT_CLASS: "justify_right",

		// dialog
		DIALOG_WRAP_CLASS: "dialog_wrap",
		CLOSE_BTN_CLASS: "close_btn",
		MODAL_ERROR_CLASS: "modal_error",
		MESSAGE_CLASS: "message",
		ERROR_MSG_AREA_CLASS: "error_msg_area",
		UNABLE_CLOSE_DIALOG_ARR: ["dialog_error", "dialog_print", "dialog_viewer"],
		DIALOG_ICON_ARR: ["img_error", "img_info", "img_notice", "img_question"],
		DIALOG_SEARCH_DOC_NAME: "dialog_search_doc",

		// layer
		LAYER_MENU: "layer_menu",

		// tool
		TOOL_TOOLTIP: "tool_tooltip",
		TOOL_LOADING_PROGRESS: "tool_loading_progress",
		TOOL_TOAST_MSG: "tool_toast_message",
		TOOL_SCREEN: "tool_screen",
		TOOL_QUICK_MENU: "tool_quick_menu",
		TOOL_PASTE_OPTION: "tool_paste_option",
		TOOL_FILTER_DIALOG: "tool_filter_dialog",

		// progress
		AREA_LOADING_PROGRESS_CLASS: "area_loading_progress",

		// separator
		VERTICAL_LINE_SEPARATOR_WRAP_CLASS: "vertical_line_wrap",
		VERTICAL_LINE_SEPARATOR_CLASS: "col_line",
		HORIZONTAL_LINE_SEPARATOR_CLASS: "horizontal_line",
		HORIZONTAL_NO_LINE_SEPARATOR_CLASS: "title_separator",

		// combo
		COMBO_CLASS: "btn_combo",
		COMBO_ICON_STYLE: "icon_combo", // dropdown 공용

		//radio
		RADIO_WIDGET_CLASS: "radio_wrap",

		// dropdown
		DROPDOWN_CLASS: "btn_dropdown",
		DROPDOWN_TEXT_TYPE: "text_dropdown",
		DROPDOWN_COLOR_WITH_ICON_TYPE: "color_with_icon",
		DROPDOWN_LINE_STYLE_TYPE: "line_style_dropdown",
		DROPDOWN_COLOR_TYPE: "color_dropdown",
		DROPDOWN_ARROW_TYPE: "arrow_dropdown",
		DROPDOWN_BOX_WRAP_CLASS: "",
		DROPDOWN_COLOR_PICKER_WRAP_CLASS: "ui_color_picker",
		DROPDOWN_SELECT_LIST_WRAP_CLASS: "menu_select_list",
		DROPDOWN_LAYOUT_BUTTON_GRID_CLASS: "button_grid",
		DROPDOWN_LAYOUT_MULTI_LIST_ITEM_CLASS: "multi_list_item",
		DROPDOWN_LAYOUT_CUSTOM_CLASS: "custom_layout",
		DROPDOWN_DATA_CLASS: "dropdown_data",
		DROPDOWN_HOVER_CLASS: "dropdown_hover",

		// input
		INPUT_WRAP_CLASS: "input_wrap",
		INPUT_BOX_WRAP_CLASS: "input_text_wrap",
		INPUT_BOX_CLASS: "",
		CHECK_BOX_WRAP_CLASS: "checkbox_wrap",
		LOCAL_FILE_WRAP_CLASS: "local_file_wrap",
		RADIO_WRAP_CLASS: "radio_wrap",
		SPINNER_WRAP_CLASS: "spinner_wrap",
		UNIT_CLASS: "unit",
		SPINNER_UPPER_ARROW_CLASS: "spinner_upper_arrow",
		SPINNER_LOWER_ARROW_CLASS: "spinner_lower_arrow",
		REMAIN_UI_FOCUS: "remain_ui_focus",

		// textarea
		TEXTAREA_BOX_CLASS: "textarea_box",

		// button
		BUTTON_CLASS: "btn_wo",
		ON_LINK_CLASS: "on_link",
		BUTTON_TAB_CLASS: "btn_tab",
		NORMAL_BUTTON_CLASS: "btn_icon",
		RESULT_BUTTON_CLASS: "btn_text",
		TRANS_MODE_BUTTON_CLASS: "btn_trans_mode",
		TRANS_CLOSE_BUTTON_CLASS: "btn_trans_close",
		MENU_BAR_VIEW_MODE_BUTTON_CLASS: "btn_menu_bar_view_mode",
		SIDE_BAR_VIEW_MODE_BUTTON_CLASS: "btn_side_bar_view_mode",
		COMMENT_BAR_CLOSE_BUTTON_CLASS: "btn_comment_bar_close",
		TITLE_PANEL_VIEW_MODE_BUTTON_CLASS: "btn_title_panel_view_mode",
		SUBTITLE_PANEL_VIEW_MODE_BUTTON_CLASS: "btn_subtitle_panel_view_mode",
		BUTTON_PREV_ARROW_CLASS: "btn_prev",
		BUTTON_NEXT_ARROW_CLASS: "btn_next",
		FUNCTION_BUTTONS_CLASS: "btn_wo_fn",
		HAS_DESCRIPTION_CLASS: "has_desc",

		// scroll
		TAB_SCROLL_CLASS: "tab_scroll",
		TITLE_BAR_SCROLL_CLASS: "title_bar_scroll",
		MENU_BAR_SCROLL_CLASS: "menu_bar_scroll",
		STYLE_BAR_SCROLL_CLASS: "style_bar_scroll",
		BUTTON_PREV_NAV_CLASS: "btn_prev_nav",
		BUTTON_NEXT_NAV_CLASS: "btn_next_nav",
		HWP_MESSAGE_CLASS: "hwp_message",
		GUIDE_CLASS: "guide",

		// tab
		TAB_BOX_CLASS: "tab_box",

		// navigation box
		NAV_BOX_CLASS: "nav_box",

		// template
		TEMPLATE_WRAP_CLASS: "template_wrap",
		DATA_TEMPLATE_NAME: "data-template-name",
		DATA_TEMPLATE_GROUP_ITEM: "data-template-group-item",
		DATA_AREA_TYPE: "data-area-type",
		TEMPLATE_GROUP_CLASS: "template_group",

		// msg bar
		MSG_PROGRESS_CLASS: "progress",
		MSG_AREA_CLASS: "message",
		MSG_REFRESH_BUTTON_CLASS: "e_refresh",
		MSG_CLOSE_BUTTON_CLASS: "close",
		MSG_DONT_LOOK_AGAIN_BOX_CLASS: "dla_box",
		MSG_DONT_LOOK_AGAIN_BTN_CLASS: "dont_look_again_btn",
		MSG_ERROR_CLASS: "error_msg",
		MSG_SCREEN_CLASS: "screen_msg",
		MSG_ERROR_TYPE: "error",

		// command
		INPUT_TEXT_ICON_CLASS: "text_icon",
		BTN_INNER_ICON_CLASS: "btn_icon_inner",
		BTN_COMBO_ARROW_CLASS: "btn_combo_arrow",
		// Define
		HAS_TYPE_TAG_ARR: ["panel", "button", "dropdown", "combo", "listBox"],
		HAS_WIDGET_COMBO_TYPE_ARR: ["input", "resultButton"],
		LIST_TYPE_MENU_ARR: ["titleBar", "contextMenu"],

		// skin, param
		SKIN_DEFAULT: "default",
		SKIN_TYPE_A: "type_a",
		UI_OPTION: "uiOption",

		// color picker
		COLOR_PICKER_CLASS: "ui_color_picker",
		PALETTE_COLOR_CLASS: "palette_color",
		DEFAULT_COLOR_CONTENT_CLASS: "default_color_content",
		SPECTRUM_COLOR_CONTENT_CLASS: "spectrum_color_content",
		DETAIL_COLOR_CONTENT_CLASS: "color_picker_detail",
		EXTEND_COLOR_CONTENT_CLASS: "color_picker_extend",
		COLOR_MATRIX_CONTAINER_CLASS: "color_matrix_container",
		COLOR_SPECTRUM_CONTAINER_CLASS: "color_spectrum_container",
		COLOR_MATRIX_PICKER_CLASS: "color_matrix_picker",
		COLOR_SPECTRUM_PICKER_CLASS: "color_spectrum_picker",
		COLOR_MATRIX_POINTER_CLASS: "color_matrix_pointer",
		COLOR_SPECTRUM_POINTER_CLASS: "color_spectrum_pointer",
		SPECTRUM_COLOR_CONFIRM_CLASS: "spectrum_color_confirm",
		SPECTRUM_COLOR_INFO_CLASS: "spectrum_color_info",
		PREVIEW_COLOR_BLOCK_CLASS: "preview_color_block",
		PREVIEW_COLOR_TEXT_CLASS: "preview_color_text",
		//selected color
		SELECTED_COLOR_CLASS:"selected_color",
		//shortcut
		SHORTCUT_CLASS: "shortcut",
		//shortcut area
		SHORTCUT_AREA_NONE: "shortcut_area_none",

		//icon area
		ICON_AREA_NONE: "icon_area_none",
		NO_ICON_CLASS: "no_icon",

		// control
		VIEW_CONTROL_CLASS: "view_control",

		//border
		VIEW_BORDER_PREFIX: "view_border",

		//arrow
		ARROW_DIRECTION_PREFIX: "arrow_direction",

		// doing
		FOLD_VIEW_CLASS: "fold_view",
		BOTTOM_VIEW_CLASS: "bottom_view",

		// collaboration cursor
		DISPLAY_NAME_AT_CURSOR : "display_name_at_cursor",

		// match
		DATA_MATCH_TYPE_ATTR: "data-match-type",
		DATA_MATCH_ATTR: "data-match",
		DATA_MATCH_GROUP_ATTR: "data-match-group",
		MATCH_REVERSE_CLASS: "match_reverse",
		NO_NAME_MATCH_PREFIX: "no_name_match",

		// Layout id
		WRAP_ID: "wrap",
		TITLE_BAR_ID: "title_bar",
		MENU_BAR_ID: "menu_bar",
		STYLEBAR_ID: "style_bar",
		TOOLBAR_ID: "tool_bar",
		CONTAINER_ID: "container",
		SIDEBAR_ID: "side_bar",
		SHEET_TAB_BAR_ID: "sheet_tab_bar",
		STATUSBAR_ID: "status_bar",
		COMMENTBAR_ID: "comment_bar",
		TRANSLATE_ID: "translation",
		THUMBNAIL_ID: "thumbnail_view",
		CONTEXT_MENU_ID: "context_menu",
		DOCUMENT_MENU_ID: "document",
		MODAL_DIALOG_ID: "modal_dialog",
		MODELESS_DIALOG_ID: "modeless_dialog",
		TOOL_BOX_ID: "tool_box",
		DUMMY_WRAP_ID: "dummy_wrap",
		QUICK_MENU_ID: "quick_menu",

		// Layout class
		TRANSLATE_DIR_LEFT: "left",
		DISABLE_CLASS: "disable",
		PARENT_DISABLE_CLASS: "parent_disable",
		DISABLED_CLASS: "disabled",
		HIDE_VIEW_CLASS: "hide_view",
		HIDE_DESC_CLASS: "hide_desc",
		HIDE_FORCE_CLASS: "hide_force",
		DONT_CARE_CLASS: "dont_care",
		ARROWKEY_HOVER_CLASS: "arrowkey_hover",
		LAYER_KEY_FOCUS: "layer_key_focus",
		NO_SUCH_FONT_DATA_CLASS: "no_such_font",
		HIDDEN_ITEM_CLASS: "hidden_item",
		DIRECTION_VERTICAL: "direction_v",

		// dialog vertical scroll
		DIALOG_V_SCROLL_CLASS: "dialog_v_scroll",

		// Attributes
		DATA_APP_ATTR: "data-app",
		DATA_DEVICE_ATTR: "data-device",
		DATA_SKIN_ATTR: "data-skin",
		DATA_NLS_NAME_ATTR: "data-nls-name",
		DATA_NAME: "data-name",
		DATA_TITLE_ATTR: "title",
		DATA_PLACEHOLDER_ATTR: "placeholder",
		DATA_SWITCH_BUTTON: "data-switch-button",
		DATA_COMMAND: "data-command",
		DATA_UI_COMMAND: "data-ui-command",
		DATA_DBL_CLICK_COMMAND: "data-dbl-click-command",
		DATA_UI_VALUE: "data-ui-value",
		DATA_NON_EXEC: "data-non-exec",
		DATA_VALUE: "data-value",
		DATA_VALUE_KEY: "data-value-key",
		DATA_TAB_BUTTON_TARGET: "data-for",
		DATA_TOGGLE_CLASS_ATTR: "data-toggle-class",
		DATA_SAMPLE_NAME: "data-sample-name",
		DATA_SAMPLE_ITEM: "data-sample-item",
		DATA_SAMPLE_VALUE: "data-sample-value",
		DATA_SAMPLE_VALUE_KEY: "data-sample-value-key",
		DATA_SAMPLE_STYLE: "data-sample-style",
		DATA_SAMPLE_TITLE: "data-sample-title",
		DATA_ARROW_DIRECTION: "data-arrow-direction",
		DATA_CURRENT_THEME: "data-current-theme",
		DATA_DESC_CLASS_ATTR: "data-desc-class",
		DATA_UNIT_ATTR: "data-unit",
		DATA_ORIGIN_COLOR_VALUE: "data-org-color",
		DATA_ICON_SIZE_ATTR: "data-icon-size",
		DATA_ICON_SIZE_ATTR_VALUE_ARR: ["small", "medium", "large", "xlarge"],
		DATA_SCROLL_CONTENT_ATTR: "data-scroll-content",
		DATA_HSV_COLOR: "data-hsv-color",
		DATA_ALIGN_H: "data-align-h",
		DATA_BIND_WIDGET_ATTR: "data-bind-widget",
		DISABLED_ATTR: "disabled",
		STYLE_ATTR: "style",

		// select all
		SELECT_ALL_DEFAULT_VALUE: false,

		// Initialization value
		INIT_TITLE_BAR_MENU_CLASS: "format_view",
		DEFAULT_TAB_MOVE_HREF_VALUE: "javascript:;",

		// sampleItemGroup name
		GROUP_NAME_SAMPLE_ITEM: "sampleItemMap",
		SAMPLE_WRAP_CLASS: "sample_wrap",
		SAMPLE_ITEM_CLASS: "sample_item",

		//sample item
		SAMPLE_WRAP_POST_FIX: "sample_wrap",
		SAMPLE_VALUE: "sample_value",

		//dummy image
		DUMMY_IMG_COMMON_LIST: ["icon_weboffice.svg", "image_color_theme.png"],
		DUMMY_IMG_DEFAULT_SKIN_LIST : {
			"base" : ["image_line_arrow.png"],
			"en": ["icon_large.png", "icon_medium.png", "icon_small.png"],
			"ko": ["icon_large_ko.png", "icon_medium_ko.png", "icon_small_ko.png"]
		},
		DUMMY_IMG_TYPEA_SKIN_LIST: [
			"icon_large.svg", "icon_medium.svg", "icon_small.svg",
			"icon_small_hover.svg", "icon_medium_hover.svg", "icon_large_hover.svg",
			"icon_small_on.svg", "icon_medium_on.svg", "icon_large_on.svg",
			"icon_small_disable.svg", "icon_medium_disable.svg", "icon_large_disable.svg",
			"icon_line_and_arrow.svg", "icon_line_and_arrow_disable.svg", "icon_line_and_arrow_on.svg", "icon_weboffice.png"],
		DUMMY_IMG_LANG_LIST: {
			"en": ["image_group_shape.svg", "image_group_shape_hover.svg", "icon_gallery.svg"],
			"ko": ["image_group_shape_ko.svg", "image_group_shape_hover_ko.svg", "icon_gallery_ko.svg"]
		},
		DUMMY_IMG_MODULE_LIST: {
			"webword": [],
			"webcell": ["icon_chart_style.svg"],
			"webshow": [],
			"webhwp": []
		},

		// ot
		USER_COLOR_CLASS: "user_color",
		USER_NAME_CLASS: "user_name",
		NO_COLLABO_USERS_VIEW: "no_collaborationusers",
		COLLABO_USERS_VIEW: "collaborationusers",
		COLLABO_USERS_LIST: "collabo_user_list",

		// UI callback key
		UI_CALLBACK_KEY_DIALOG: "dialog",

		// special panel
		UI_OPTION_AREA: "ui_option_area",
		SIDEBAR_CATEGORY: "category",
		FORMULA_BAR_PARENT: "formula_bar_parent",
		FORMULA_BAR: "formula_bar",
		FORMULA_RESIZE: "formula_resize",
		WATCHER_MODE_MESSAGE: "watcher_mode_message",
		SECTION_PROPERTY: "section_property",
		EDIT_AREA: "edit_area",
		CUSTOM_STATUS: "custom_status",

		// iframe id
		IFRAME_STYLEBAR: "iframe_stylebar",
		IFRAME_SIDEBAR: "iframe_sidebar",
		IFRAME_MODELESS_DIALOG: "iframe_modeless_dlg",
		IFRAME_TOOLBOX: "iframe_toolbox",

		// input focus class
		WIDGET_FOCUS: "widget_focus",
		FOCUSABLE_CLASS: "focus",
		FOCUSABLE_PANEL_CLASS: "focusable_panel",

		//context menu - sheet tab color picker
		SHEET_TAB_COLOR: "sheet_tab_color",

		/**
		 * Constants define
		 */

		SIDEBAR_RIGHT_MARGIN: 18,
		MENU_WRAP_NAME: {
			WRAP: 0,
			TOOL_BAR: 1,
			CONTAINER: 2
		},
		MESSAGE_DIALOG_LIST: ["dialog_message_box", "dialog_alert", "dialog_error", "dialog_confirm", "dialog_print", "dialog_download", "dialog_rename", "dialog_viewer"],
		IGNORE_REF_TREE_KEY_ARR: ["ref", "parentItem", "no_collaborationusers", "collaborationusers", "category"],
		MULTI_LIST_ITEM_BUTTON_CUSTOM_PADDING: 34,
		NORMAL_BUTTON_CUSTOM_PADDING: 12,
		UI_FOCUS_TARGET: "uiFocusTarget",
		FIND_WIDGET_SELECTOR_FOR_HOVER: [
			"div[data-command]:not(.hide_view):not(.disable):not(.input_text_wrap):not(.btn_text)",
			"div[data-ui-command]:not(.hide_view):not(.disable)",
			"div[class*='sub_group']:not(.hide_view):not(.disable)",
			"div.btn_dropdown.color_theme:not(.hide_view):not(.disable)",
			"label[data-ui-command]:not(.hide_view):not(.disable)"
		],
		FIND_MOVABLE_BOX_FOR_HOVER: [
			".menu_select_list",
			".title_bar .menu_box",
			".context_menu",
			".tool_filter_dialog",
			".sub_group_box",
			".list_box",
			".focusable_panel",
			".tab_group"
		],
		FIND_ALL_DIR_MOVABLE_BOX_FOR_HOVER: [
			".button_grid",
			".custom_layout",
			".focusable_panel"
		],
		FORMULA_MIN_HEIGHT: 30,
		FORMULA_MAX_HEIGHT: 190,
		SEARCH_DOC_DLG_MIN_HEIGHT: 400,
		CLOSED_TYPE: {
			NONE: 0,
			DIALOG: 1,
			QUICK_MENU: 2,
			LAYER_MENU: 3
		},
		DROPDOWN_DATA_MARGIN: 4,
		OFFLINE_STATE_NLS_KEY_ARR: ["OT1Message", "OT1MessageCannotSync", "OT6Message", "SynchronizationInProgress", "SynchronizationFailMessage"],

		/**
		 * Context Menu Panel Names
		 */
		CONTEXT_MENU_PANEL_NAMES: {
			INSERT_ROW: "insert_row",
			INSERT_COL: "insert_col",
			DELETE_TABLE: "delete_table",
			SELECT_TABLE: "select_table",
			SLIDE_LAYOUT_MENU: "slide_layout_menu",
			GROUP: "group",
			ORDER: "order",
			ALIGN: "align",
			SHEET_INFO: "sheet_info"
		},

		UPDATE_CMD: "update",

		/**
		 * Event Action Names
		 */
		EVENT_ACTION_NAMES: {
			// all commands
			ALL_COMMANDS_NAME: "all_commands",

			//UI
			U_SHORTCUT: "shortcut",
			U_D_INFO: "d_info",
			U_TASKPANE: "taskpane",
			U_COMMENT: "comment",
			U_INSERT_IMAGE: "insert_image",
			U_INSERT_SHAPE: "insert_shape",
			U_INSERT_TABLE: "insert_table",
			U_FIND_REPLACE: "find_replace",
			U_HYPERLINK: "hyperlink",
			U_EDIT_LINK: "edit_link",
			U_D_PAGE_SETUP: "d_page_setup",
			U_SHOW_RULER: "show_ruler",
			U_TRANSLATE: "translate",
			U_HEADER_FOOTER: "header_footer",
			U_DATE_TIME: "date_time",
			U_SLIDE_NUMBER: "slide_number",
			U_INSERT_SYMBOLS: "symbols",
			U_BOOKMARK: "bookmark",
			U_FUNCTIONS: "functions",
			U_CHART: "chart",
			U_SLIDE_CHANGE: "slide_change",
			U_CHANGE_IMAGE: "change_image",
			U_D_SAVE_AS: "d_save_as_button",
			U_DIALOG_VIEWER: "dialog_viewer",
			U_FORMULABAR: "formulabar",
			U_GOTO_REFERENCE: "goto_reference",
			U_CHART_AXIS_TITLE: "chart_axis_title",
			U_FILTER_NOT_ALL_ITEMS_SHOWING: "filter_not_all_items_showing",
			U_FOUND_NOT_ALL_ITEMS_SHOWING: "found_not_all_items_showing",
			U_MANAGE_NAME: "manage_name",
			U_DATA_VALIDATION: "data_validation",

			//common
			E_HELP: "e_help",
			E_UNDO: "e_undo",
			E_REDO: "e_redo",
			FONT_NAME: "font_name",
			FONT_SIZE: "font_size",
			FONT_COLOR: "font_color",
			FONT_HIGHLIGHT_COLOR: "font_highlight_color",
			BOLD: "bold",
			ITALIC: "italic",
			UNDERLINE: "underline",
			DOUBLE_UNDERLINE: "double_underline",
			STRIKETHROUGH: "strikethrough",
			LETTER_SPACING: "letter_spacing",
			TEXT_SCRIPT: "text_script",
			P_DECREASE_INDENT: "p_decrease_indent",
			P_INCREASE_INDENT: "p_increase_indent",
			P_LINE_SPACING: "p_line_spacing",
			P_LIST: "p_list",
			P_ALIGN: "p_align",
			E_FORMAT_COPY: "e_format_copy",
			E_FORMAT_REMOVE: "e_format_remove",
			P_STYLE: "p_style",
			T_INSERT_ROW_ABOVE: "t_insert_row_above",
			T_INSERT_ROW_BELOW: "t_insert_row_below",
			T_INSERT_COL_LEFT: "t_insert_col_left",
			T_INSERT_COL_RIGHT: "t_insert_col_right",
			T_DELETE_COL: "t_delete_col",
			T_DELETE_ROW: "t_delete_row",
			C_MERGE: "c_merge",
			C_UNMERGE: "c_unmerge",
			C_HEIGHT_DISTRIBUTE: "c_height_distribute",
			C_WIDTH_DISTRIBUTE: "c_width_distribute",
			T_DELETE: "t_delete",
			T_MARGIN_LEFT: "t_margin_left",
			C_VALIGN: "c_valign",
			C_PADDING: "c_padding",
			C_BGCOLOR: "c_bgcolor",
			C_BGCOLOR_OPACITY: "c_bgcolor_opacity",
			S_VALIGN: "s_valign",
			S_BGCOLOR: "s_bgcolor",
			S_BGCOLOR_OPACITY: "s_bgcolor_opacity",
			S_BORDER_STYLE: "s_border_style",
			S_BORDER_WIDTH: "s_border_width",
			S_BORDER_COLOR: "s_border_color",
			S_BORDER_OPACITY: "s_border_opacity",
			S_ORDER: "s_order",
			S_ALIGN_LEFT: "s_align_left",
			S_ALIGN_CENTER: "s_align_center",
			S_ALIGN_RIGHT: "s_align_right",
			S_ALIGN_TOP: "s_align_top",
			S_ALIGN_MIDDLE: "s_align_middle",
			S_ALIGN_BOTTOM: "s_align_bottom",
			S_ALIGN_EVEN_HORIZONTAL: "s_align_even_horizontal",
			S_ALIGN_EVEN_VERTICAL: "s_align_even_vertical",
			S_SIZE: "s_size",
			S_POSITION: "s_position",
			S_TEXT_WRAPPING: "s_text_wrapping",
			I_BORDER_STYLE: "i_border_style",
			I_BORDER_WIDTH: "i_border_width",
			I_BORDER_COLOR: "i_border_color",
			I_POSITION: "i_position",
			I_SIZE: "i_size",
			E_COPY: "e_copy",
			E_CUT: "e_cut",
			E_PASTE: "e_paste",
			E_DUPLICATE_OBJ: "e_duplicate_obj",
			E_OPEN_LINK: "e_open_link",
			E_DELETE_LINK: "e_delete_link",
			S_ADD_TEXT: "s_add_text",
			S_EDIT_TEXT: "s_edit_text",
			E_SELECT: "e_select",
			E_SELECT_ALL: "e_select_all",
			S_INSERT_TEXTBOX: "s_insert_textbox",
			I_INSERT_IMAGE: "i_insert_image",
			I_CROP: "i_crop",
			E_INSERT_HYPERLINK: "e_insert_hyperlink",
			S_INSERT_SHAPE: "s_insert_shape",
			T_INSERT_TABLE: "t_insert_table",
			INSERT_SYMBOLS: "insert_symbols",
			E_TRANS_VIEW_CHANGE: "e_trans_view_change",
			E_TRANS_CLOSE: "e_trans_close",
			E_TRANS_LANG: "e_trans_lang",
			E_TRANS_RESULT: "e_trans_result",
			E_VIEW_SCALE: "e_view_scale",
			E_ZOOM: "e_zoom",
			E_MEMO: "e_memo",
			E_INSERT_MEMO: "e_insert_memo",
			E_EDIT_MEMO: "e_edit_memo",
			E_HIDE_MEMO: "e_hide_memo",
			E_SHOW_MEMO: "e_show_memo",
			E_DELETE_MEMO: "e_delete_memo",
			D_SAVE: "d_save",
			D_SAVE_AS: "d_save_as",
			D_DOWNLOAD: "d_download",
			D_PDF_DOWNLOAD: "d_pdf_download",
			D_PRINT: "d_print",
			E_DIALOG_RENAME: "e_dialog_rename",
			E_DIALOG_CONFIRM: "e_dialog_confirm",
			E_DIALOG_MESSAGE_BOX: "e_dialog_message_box",
			E_DIALOG_ERROR: "e_dialog_error",
			E_DIALOG_PRINT: "e_dialog_print",
			E_DIALOG_DOWNLOAD: "e_dialog_download",
			E_DIALOG_ALERT: "e_dialog_alert",
			E_DIALOG_VIEWER: "e_dialog_viewer",
			E_REFRESH: "e_refresh",
			E_DESKTOP_CONFIRM: "e_desktop_confirm",
			E_DESKTOP_EXECUTE: "e_desktop_execute",
			E_CHANGE_UI_MODE: "e_change_ui_mode",
			U_SEARCH_DOC: "u_search_doc",
			U_SEARCH_DOC_CONTEXT: "u_search_doc_context",

			// webword
			D_PAPER_TYPE: "d_paper_type",
			D_ORIENTATION: "d_orientation",
			D_BGCOLOR: "d_bgcolor",
			D_PAPER_MARGIN: "d_paper_margin",
			C_SELECT_CELL: "c_select_cell",
			T_SELECT_TABLE: "t_select_table",
			E_DELETE_FIELD: "e_delete_field",
			E_FOOT_NOTE: "e_foot_note",
			E_END_NOTE: "e_end_note",
			C_BACKGROUND_AND_BORDER: "c_background_and_border",
			E_HEADER: "e_header",
			E_FOOTER: "e_footer",
			P_PAGE_NUMBER: "p_page_number",
			P_PAGE_BREAK: "p_page_break",
			P_BEFORE: "p_before",
			P_AFTER: "p_after",
			E_RULER: "e_ruler",
			E_FIND_REPLACE: "e_find_replace",
			S_TEXTBOX_PADDING: "s_textbox_padding",
			T_ALIGN: "t_align",
			E_INSERT_BOOKMARK: "e_insert_bookmark",
			E_BOOKMARK_LIST: "e_bookmark_list",
			P_START_NEW_LIST: "p_start_new_list",
			E_COMMENT_ITEM: "e_comment_item",

			// webcell
			E_GRIDLINE: "e_gridline",
			C_WRAP_TEXT: "c_wrap_text",
			C_INSERT_ROW: "c_insert_row",
			C_INSERT_COL: "c_insert_col",
			C_DELETE_ROW: "c_delete_row",
			C_DELETE_COL: "c_delete_col",
			C_WIDTH: "c_width",
			C_HEIGHT: "c_height",
			C_WIDTH_DIALOG: "c_width_dlg",
			C_HEIGHT_DIALOG: "c_height_dlg",
			E_CURRENT_FREEZE: "e_current_freeze",
			E_SHEET_INFO: "e_sheet_info",
			E_CUSTOM_STATUS: "e_custom_status",
			E_ADD_SHEET: "e_add_sheet",
			E_SHEET: "e_sheet",
			CURRENCY: "currency",
			PERCENT: "percent",
			COMMA: "comma",
			DELETE_POINT: "delete_point",
			ADD_POINT: "add_point",
			NUMBER_FORMAT: "number_format",
			C_BORDER: "c_border",
			E_FILTERS: "e_filters",
			E_SORT: "e_sort",
			E_DELETE_SHEET: "e_delete_sheet",
			E_CHANGE_SHEET_NAME: "e_change_sheet_name",
			E_HIDE_SHEET: "e_hide_sheet",
			E_SHOW_SHEET: "e_show_sheet",
			E_DUPLICATE_SHEET: "e_duplicate_sheet",
			E_TAB_COLOR: "e_tab_color",
			C_HIDE_ROW: "c_hide_row",
			C_VIEW_ROW: "c_view_row",
			C_HIDE_COL: "c_hide_col",
			C_VIEW_COL: "c_view_col",
			E_FILL_DATA: "e_fill_data",
			C_ALIGN: "c_align",
			E_DELETE_CONTENTS: "e_delete_contents",
			E_FIRST_SHEET: "e_first_sheet",
			E_PREVIOUS_SHEET: "e_previous_sheet",
			E_NEXT_SHEET: "e_next_sheet",
			E_LAST_SHEET: "e_last_sheet",
			E_CHART_TYPE: "e_chart_type",
			E_INSERT_FUNCTION: "e_insert_function",
			E_SHEET_INFO_MENU: "e_sheet_info_menu",
			E_SHEET_DATA: "e_sheet_data",
			E_SWITCH_ROW_COL: "e_switch_row_col",
			E_CHART_TYPE_STYLE: "e_chart_type_style",
			E_CHART_LEGEND: "e_chart_legend",
			E_AUTOSUM: "e_autosum",
			E_PASTE_OPTION: "e_paste_option",
			E_GOTO: "e_goto",
			E_FILTER_DIALOG_SORT: "e_filter_dlg_sort",
			E_FILTER_DIALOG_FILTER: "e_filter_dlg_filter",
			E_FILTER_DIALOG_NUMBER: "e_filter_dlg_number",
			E_FILTER_DIALOG_TEXT: "e_filter_dlg_text",
			E_FILTER_DIALOG_CUSTOM_FILTER: "e_filter_dlg_custom_filter",
			E_FILTER_DIALOG_SEARCH_TEXT: "e_filter_dlg_search_text",
			E_FILTER_DIALOG_SELECT_ALL: "e_filter_dlg_select_all",
			E_FILTER_DIALOG_TOP_10_FILTER: "e_filter_dlg_top_10_filter",
			E_NAME_BOX: "e_name_box",
			E_CONDITIONAL_FORMATTING: "e_conditional_formatting",
			E_CONDITIONAL_FORMATTING_RULES: "e_conditional_formatting_rules",
			E_DATA_LABEL: "e_data_label",
			E_CHART_AXIS_TITLE: "e_chart_axis_title",
			E_HORIZONTAL_GRID_LINES: "e_horizontal_grid_lines",
			E_VERTICAL_GRID_LINES: "e_vertical_grid_lines",
			E_MANAGE_NAME: "e_manage_name",
			E_NAME: "e_name",
			E_DEFINE_NAME: "e_define_name",
			C_NUMBER_FORMAT: "c_number_format",
			C_NUMBER_FORMAT_TYPE: "c_number_format_type",
			C_NUMBER_FORMAT_TYPE_GENERAL: "c_number_format_type_general",
			C_NUMBER_FORMAT_TYPE_NUMBER: "c_number_format_type_number",
			C_NUMBER_FORMAT_TYPE_CURRENCY: "c_number_format_type_currency",
			C_NUMBER_FORMAT_TYPE_FINANCIAL: "c_number_format_type_financial",
			C_NUMBER_FORMAT_TYPE_DATE: "c_number_format_type_date",
			C_NUMBER_FORMAT_TYPE_TIME: "c_number_format_type_time",
			C_NUMBER_FORMAT_TYPE_PERCENT: "c_number_format_type_percent",
			C_NUMBER_FORMAT_TYPE_FRACTION: "c_number_format_type_fraction",
			C_NUMBER_FORMAT_TYPE_SCIENTIFIC: "c_number_format_type_scientific",
			C_NUMBER_FORMAT_TYPE_TEXT: "c_number_format_type_text",
			C_NUMBER_FORMAT_TYPE_SPECIAL: "c_number_format_type_special",
			C_NUMBER_FORMAT_TYPE_CUSTOM: "c_number_format_type_custom",
			E_SPARKLINE: "e_sparkline",
			E_EDIT_SPARKLINE: "e_edit_sparkline",
			E_DATA_VALIDATION: "e_data_validation",

			// webshow
			E_SLIDE_INSERT_IMAGE: "e_slide_insert_image",
			T_STYLE: "t_style",
			S_STROKE_ARROW_START_TYPE: "s_stroke_arrow_start_type",
			S_STROKE_ARROW_END_TYPE: "s_stroke_arrow_end_type",
			E_FIRST_SLIDE: "e_first_slide",
			E_PREVIOUS_SLIDE: "e_previous_slide",
			E_NEXT_SLIDE: "e_next_slide",
			E_LAST_SLIDE: "e_last_slide",
			E_SHOW_MODE: "e_show_mode",
			E_ADD_SLIDE: "e_add_slide",
			E_SLIDE_CHANGE: "e_slide_change",
			E_SHOW_MODE_START: "e_show_mode_start",
			E_DELETE_SLIDE: "e_delete_slide",
			E_DUPLICATE_SLIDE: "e_duplicate_slide",
			E_HIDE_SLIDE: "e_hide_slide",
			S_GROUP: "s_group",
			S_UNGROUP: "s_ungroup",
			S_STROKE_END_CAP: "s_stroke_end_cap",
			S_STROKE_JOIN_TYPE: "s_stroke_join_type",
			S_AUTOFIT: "s_autofit",
			E_SHOW_SLIDE: "e_show_slide",
			E_SLIDE_BACKGROUND: "e_slide_background",
			E_SLIDE_BGCOLOR_OPACITY: "e_slide_bgcolor_opacity",
			E_SLIDE_HIDE_GRAPHIC: "e_slide_hide_graphic",
			E_SLIDE_TEMPLATE: "e_slide_template",
			E_HEADER_FOOTER: "e_header_footer",
			E_RESET_SLIDE: "e_reset_slide",

			// webhwp
			E_DELETE: "e_delete",
			C_DELETE: "c_delete",
			E_EDIT_FIELD: "e_edit_field",
			E_CAPTION_DIRECTION_NONE: "e_caption_direction_none",
			S_INSERT_CAPTION: "s_insert_caption",
			S_SHAPE_ATTACH_TEXTBOX: "s_shape_attach_textbox",
			S_DETACH_TEXTBOX: "s_detach_textbox"
		},

		/**
		 * EventAction
		 */
		EVENT_ACTION_TYPE: {
			TEXT: "text",
			PARAGRAPH: "paragraph",
			SHAPE: "shape",
			IMAGE: "image",
			TABLE: "table",
			CELL: "cell",
			DOCUMENT: "document",
			EDIT: "edit",
			UI: "ui",
			HIDDEN: "hidden",
			VISIBLE: "visible",
			DISABLE: "disable",
			ENABLE: "enable",
			VISIBLE_ITEM: "visible_item",
			HIDDEN_ITEM: "hidden_item",
			INPUT: "input"
		},
		EVENT_ACTION_SPECIAL_TYPES: ["hidden", "visible", "disable", "enable", "visible_item", "hidden_item"],
		PREFIX_TO_TYPE: {
			p: "paragraph",
			s: "shape",
			i: "image",
			t: "table",
			c: "cell",
			d: "document",
			e: "edit",
			u: "ui"
		},
		SPINNER_TYPE: {
			UPPER: "upper",
			LOWER: "lower"
		},
		UI_COMMAND_NAME: {
			SHOW: "show",
			HIDE: "hide",
			TOGGLE: "toggle",
			FOLD: "fold",
			ITEM_SHOW: "item_show",
			DROPDOWN: "dropdown",
			TITLE_BAR: "title_bar",
			CLOSE_MENU: "close_menu",
			TAB: "tab",
			DESCRIPTION: "description",
			MENU_H_SCROLL: "menu_h_scroll",
			TOGGLE_UI_OPTION_VIEW: "toggle_ui_option_view",
			DONT_LOOK_AGAIN: "dont_look_again",
			COLOR_THEME: "color_theme"
		},

		// converting define
		DATA_DEFAULT_VALUE_ATTR: "data-default-value",
		USE_ITEM_NODE_NAMES : ["command", "panelGroup", "widgetGroup", "dataSet"],
		HCWO_CSS_LINK_TEMP_ID: "hcwo_css_temp",
		USE_CUSTOM_XML_MODULE_NAMES: ["webword", "webshow", "webcell", "webhwp", "webhwpctrl"],
		USE_ADD_TEMPLATE_FILE_MODULE_NAMES: ["webword", "webshow", "webcell", "webhwp", "webhwpctrl"],
		MODULE_NAME_WEBWORD: "webword",
		MODULE_NAME_WEBSHOW: "webshow",
		MODULE_NAME_WEBCELL: "webcell",
		MODULE_NAME_WEBHWP: "webhwp",
		MODULE_NAME_WEBHWP_CTRL: "webhwpctrl",
		// description 이 있는 상태로 dropdownListData container 위치에 오더라도 functionButtons 로 취급
		USE_DESC_FUNCTION_BUTTONS: ["slide_layout_item"],
		REPLACE_NLS_MAP: { // module 에 맞게 다른 nls 사용할 경우 정의 (현재 미사용중)
			//webhwp: {
			//	FirstLineIndent: "RulerIndentFirstLine",
			//	Outdent: "RulerOutdentLeft",
			//	Indent: "RulerIndentLeft",
			//	RightIndent: "RulerIndentRight"
			//}
		},

		/**
		 * Custom Event
		 */
		CUSTOM_EVENT_TYPE: {
			UI_RESIZE: "uiResize",
			UI_INPUT_FOCUS: "uiInputFocus",
			UI_CLOSE_DIALOG: "uiCloseDialog",
			UI_INPUT_CHANGE: "uiInputChange",
			UI_DIALOG_MOVE: "uiDialogMove"
		},
		CUSTOM_EVENT_KIND: {
			API: "api",
			WIDGET: "widget"
		},

		/**
		 * Custom Color
		 * TODO: 작성중
		 */
		CSS_COLOR_SELECTORS: {
			// normal selectors
			SEPARATOR_COLOR: [
				".vertical_line_wrap .col_line",
				".horizontal_line"
			],
			SEPARATOR_TEXT: [
				".container_view .title_separator"
			],
			TITLE_PANEL: [
				".container_view .property_title",
				".container_view .fold_view .property_title",
				".title_panel[class*='collaborationusers_view'] .property_title"
			],
			TITLE_PANEL_ARROW: [
				".container_view .property_title .view_control",
				".container_view .property_title .view_control:before",
				".container_view .property_title .view_control:after",
				".container_view .property_title .btn_title_panel_view_mode:before",
				".container_view .property_title .btn_title_panel_view_mode:after",
				".container_view .fold_view .property_title .view_control",
				".container_view .fold_view .property_title .view_control:before",
				".container_view .fold_view .property_title .view_control:after",
				".container_view .fold_view .property_title .btn_title_panel_view_mode:before",
				".container_view .fold_view .property_title .btn_title_panel_view_mode:after"
			],
			BUTTON: [
				".container_view .btn_wo_fn:not(.disable)",
				/*".menu_bar .btn_wo_fn:not(.disable) > a",*/
				".container_view .btn_combo:not(.disable):hover > a",
				".container_view div.input_wrap:not(.disable):not(.checkbox_wrap):not(.radio_wrap)",
				".sub_default_color",
				".container_view .btn_combo.input_wrap:not(.disable) > a:first-child:hover",
				".container_view .btn_combo.input_wrap:not(.disable) > a:first-child:active",
				".container_view .btn_combo.input_wrap:not(.disable):active",
				".ui_color_picker label:nth-of-type(1):after"
			],
			BUTTON_TEXT: [
				".container_view .btn_wo_fn > a",
				".container_view .input_wrap",
				".container_view .input_wrap > input",
				".sub_default_color",
				".ui_color_picker label"
			],
			BUTTON_ARROW: [
				".container_view .btn_combo:not(.disable) > a.btn_combo_arrow:before",
				".container_view .btn_dropdown:not(.disable) > a.btn_combo_arrow:before",
				".input_text_wrap > .spinner_wrap span.spinner_upper_arrow:before",
				".input_text_wrap > .spinner_wrap span.spinner_lower_arrow:before",
				".container_view .btn_combo:not(.disable) > a.btn_combo_arrow:after",
				".container_view .btn_dropdown:not(.disable) > a.btn_combo_arrow:after",
				".input_text_wrap > .spinner_wrap span.spinner_upper_arrow:after",
				".input_text_wrap > .spinner_wrap span.spinner_lower_arrow:after"
			],
			RESULT_BUTTON: [
				".container_view .btn_text:not(.disable)"
			],
			GUIDE_BUTTON: [
				".container_view .guide .btn_wo:not(.disable) svg"
			],
			CONTROL_BUTTON: [
				".container_view.menu_bar > .view_control svg",
				".container_view.menu_bar > .view_control:hover svg",
				".container_view.side_bar > .view_control .btn_side_bar_view_mode svg",
				".container_view.side_bar > .view_control .btn_side_bar_view_mode:hover svg",
				".title_panel[class*='collaborationusers_view'] .property_title .view_control svg",
				".title_panel[class*='collaborationusers_view'].fold_view .property_title .view_control svg"
			],
			// on selectors
			TITLE_PANEL_ON: [
				".container_view.on .title_panel.on .property_title"
			],
			BUTTON_ON: [
				".container_view .btn_wo_fn.on:not(.disable)",
				/*".menu_bar .btn_wo_fn.on:not(.disable) > a",*/
				".ui_color_picker input:nth-of-type(1):checked ~ label:nth-of-type(1)",
				".ui_color_picker input:nth-of-type(2):checked ~ label:nth-of-type(2)",
				".input_wrap.on:not(.disable):not(.checkbox_wrap):not(.radio_wrap)",
				".sub_default_color.on"
			],
			BUTTON_ON_TEXT: [
				".container_view .btn_wo_fn.on > a",
				".ui_color_picker input:nth-of-type(1):checked ~ label:nth-of-type(1)",
				".ui_color_picker input:nth-of-type(2):checked ~ label:nth-of-type(2)",
				".sub_default_color.on"
			],
			BUTTON_ARROW_ON: [
				".container_view .btn_combo:not(.disable) > a.btn_combo_arrow.on:before",
				".container_view .btn_dropdown:not(.disable) > a.btn_combo_arrow.on:before",
				".container_view .btn_combo:not(.disable) > a.btn_combo_arrow.on:after",
				".container_view .btn_dropdown:not(.disable) > a.btn_combo_arrow.on:after"
			],
			RESULT_BUTTON_ON: [
				".container_view .btn_text.on:not(.disable)",
				".container_view .btn_text.sheet_on"
			],
			CATEGORY_PANEL: [
				".container_view .category"
			],
			CONTENTS_BOX: [
				".modal_dialog .menu_box",
				".title_panel[class*='collaborationusers_view'] .menu_box"
			],
			DROPDOWN_BOX: [
				".title_bar .menu_box",
				".title_bar .menu_box .sub_group .sub_group_box",
				".context_menu",
				".context_menu .sub_group .sub_group_box",
				".container_view .menu_select_list",
				".container_view .menu_select_list > div > div:nth-child(n)"
			],
			INPUT_BOX: [
				".container_view div.input_wrap:not(.disable):not(.checkbox_wrap):not(.radio_wrap)",
				".container_view .btn_combo.input_wrap:not(.disable) > a",
				".container_view .btn_combo.input_wrap:not(.disable) > a:first-child:hover",
				".container_view .btn_combo.input_wrap:not(.disable) > a:first-child:active",
				".container_view .btn_combo.input_wrap:not(.disable):active"
			],
			INPUT_BOX_TEXT: [
				".container_view div.input_wrap:not(.disable):not(.checkbox_wrap):not(.radio_wrap) input"
			],
			// hover selectors
			TITLE_PANEL_HOVER: [".container_view .property_title:hover"],
			BUTTON_HOVER: [
				".container_view .btn_wo_fn:hover:not(.disable)",
				/*".menu_bar .btn_wo_fn:hover:not(.disable):not(.btn_combo) > a",*/
				".ui_color_picker input:nth-of-type(1):checked ~ label:nth-of-type(2):hover",
				".ui_color_picker input:nth-of-type(2):checked ~ label:nth-of-type(1):hover",
				".sub_default_color:hover",
				".container_view .btn_combo:not(.disable):hover > a:hover",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable):hover"
			],
			BUTTON_HOVER_BORDER: [
				".container_view .btn_wo_fn:hover:not(.disable)",
				".container_view .btn_combo:hover:not(.disable) > a:first-child:after",
				/*".menu_bar .btn_wo_fn:hover:not(.disable) > a",*/
				".ui_color_picker input:nth-of-type(1):checked ~ label:nth-of-type(2):hover",
				".ui_color_picker input:nth-of-type(2):checked ~ label:nth-of-type(1):hover",
				".sub_default_color:hover",
				"div.input_wrap:hover:not(.disable):not(.checkbox_wrap):not(.radio_wrap)",
				".input_text_wrap:not(.disable):hover > .spinner_wrap",
				".input_text_wrap:not(.disable):hover > .spinner_wrap:after"
			],
			BUTTON_HOVER_TEXT: [
				".container_view .btn_wo_fn:hover:not(.disable):not(.input_wrap) > a",
				".ui_color_picker input:nth-of-type(1):checked ~ label:nth-of-type(2):hover",
				".ui_color_picker input:nth-of-type(2):checked ~ label:nth-of-type(1):hover",
				".sub_default_color:hover"
			],
			BUTTON_ARROW_HOVER: [
				".btn_combo:not(.disable):hover > a.btn_combo_arrow:hover:before",
				".btn_dropdown:not(.disable):hover > a.btn_combo_arrow:before",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable).spinner_upper_arrow:hover:before",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable).spinner_lower_arrow:hover:before",
				".btn_combo:not(.disable):hover > a.btn_combo_arrow:hover:after",
				".btn_dropdown:not(.disable):hover > a.btn_combo_arrow:after",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable).spinner_upper_arrow:hover:after",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable).spinner_lower_arrow:hover:after"
			],
			RESULT_BUTTON_HOVER: [".container_view .btn_text:hover:not(.disable)"],
			INPUT_BOX_HOVER_BORDER: [
				"div.input_wrap:hover:not(.disable):not(.checkbox_wrap):not(.radio_wrap)",
				"div.input_wrap.btn_combo:hover:not(.disable) > a:first-child:after",
				".input_text_wrap:not(.disable):hover > .spinner_wrap",
				".input_text_wrap:not(.disable):hover > .spinner_wrap:after"
			],
			// push selectors
			TITLE_PANEL_PUSH: [".container_view .property_title:active"],
			BUTTON_PUSH: [
				".container_view .btn_wo_fn:not(.disable):active",
				/*".menu_bar .btn_wo_fn:hover:not(.disable):not(.btn_combo) > a:active",*/
				".ui_color_picker input:nth-of-type(1):checked ~ label:nth-of-type(2):active",
				".ui_color_picker input:nth-of-type(2):checked ~ label:nth-of-type(1):active",
				".sub_default_color:active",
				".container_view .btn_combo:hover:not(.disable) > a:active",
				".container_view .btn_combo:active:not(.disable):not(.input_wrap) > a:first-child:after",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable):active"
			],
			BUTTON_PUSH_TEXT: [
				".container_view .btn_wo_fn:not(.disable):not(.input_wrap):active a",
				".ui_color_picker input:nth-of-type(1):checked ~ label:nth-of-type(2):active",
				".ui_color_picker input:nth-of-type(2):checked ~ label:nth-of-type(1):active",
				".sub_default_color:active"
			],
			BUTTON_ARROW_PUSH: [
				".btn_combo:not(.disable):active > a.btn_combo_arrow:active:before",
				".btn_dropdown:not(.disable):active > a.btn_combo_arrow:before",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable).spinner_upper_arrow:active:before",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable).spinner_lower_arrow:active:before",
				".btn_combo:not(.disable):active > a.btn_combo_arrow:active:after",
				".btn_dropdown:not(.disable):active > a.btn_combo_arrow:after",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable).spinner_upper_arrow:active:after",
				".input_text_wrap:not(.disable) > .spinner_wrap span:not(.disable).spinner_lower_arrow:active:after"
			],
			RESULT_BUTTON_PUSH: [".container_view .btn_text:active:not(.disable)"],
			// disable selectors
			BUTTON_DISABLE: [
				".container_view .btn_wo_fn.disable",
				/*".menu_bar .btn_wo_fn.disable > a",*/
				".container_view div.input_wrap.disable:not(.checkbox_wrap):not(.radio_wrap)"
			],
			BUTTON_DISABLE_TEXT: [
				/**
				 * TODO:
				 * type_a의 기본 CSS에서 btn_wo.disable 의 color 색상을 important 로 적용되고 있는데,
				 * 수정시 사이드 이펙트 우려가 있어 known issue 로 두고 추후 코드 정리하면서 수정 필요.
				 */
				".container_view .btn_wo_fn.disable > a",
				".input_wrap.disable",
				".input_wrap.disable > input"
			],
			BUTTON_ARROW_DISABLE: [
				".container_view .btn_combo.disable > a.btn_combo_arrow:before",
				".container_view .btn_dropdown.disable > a.btn_combo_arrow:before",
				".container_view .input_text_wrap.disable > .spinner_wrap span.spinner_upper_arrow:before",
				".container_view .input_text_wrap.disable > .spinner_wrap span.spinner_lower_arrow:before",
				".container_view .btn_combo.disable > a.btn_combo_arrow:after",
				".container_view .btn_dropdown.disable > a.btn_combo_arrow:after",
				".container_view .input_text_wrap.disable > .spinner_wrap span.spinner_upper_arrow:after",
				".container_view .input_text_wrap.disable > .spinner_wrap span.spinner_lower_arrow:after"
			],
			RESULT_BUTTON_DISABLE: [
				".container_view .btn_text.disable"
			],
			INPUT_BOX_DISABLE: [
				".container_view div.input_wrap.disable:not(.checkbox_wrap):not(.radio_wrap)"
			],
			INPUT_BOX_DISABLE_TEXT: [
				".container_view div.input_wrap.disable:not(.checkbox_wrap):not(.radio_wrap) input"
			],
			DROPDOWN_DATA: [
				".title_bar .menu_box .btn_wo:not(.btn_wo_fn):not(.disable)",
				".context_menu .btn_wo:not(.btn_wo_fn):not(.disable)",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data:not(.disable)",
				".container_view .sub_group:not(.disable) a.sub_group_title"
			],
			DROPDOWN_DATA_TEXT: [
				".title_bar .menu_box .btn_wo:not(.btn_wo_fn):not(.disable) a",
				".context_menu .btn_wo:not(.btn_wo_fn):not(.disable) a",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data:not(.disable)",
				".container_view .sub_group:not(.disable) a.sub_group_title"
			],
			DROPDOWN_DATA_SHORTCUT_TEXT: [
				".container_view .btn_wo:not(.disable) a .shortcut"
			],
			DROPDOWN_DATA_ARROW: [
				".sub_group:not(.disable) > a.sub_group_title:before"
			],
			DROPDOWN_DATA_ON: [
				".title_bar .menu_box .btn_wo.on:not(.btn_wo_fn):not(.disable)",
				".context_menu .btn_wo.on:not(.btn_wo_fn):not(.disable)",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data.on:not(.disable)",
				".container_view .sub_group.on:not(.disable) a.sub_group_title"
			],
			DROPDOWN_DATA_ON_TEXT: [
				".title_bar .menu_box .btn_wo.on:not(.btn_wo_fn):not(.disable) a",
				".context_menu .btn_wo.on:not(.btn_wo_fn):not(.disable) a",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data.on:not(.disable)",
				".container_view .sub_group.on:not(.disable) a.sub_group_title"
			],
			DROPDOWN_DATA_ON_SHORTCUT_TEXT: [
				".container_view .btn_wo.on a .shortcut"
			],
			DROPDOWN_DATA_HOVER: [
				".title_bar .menu_box .btn_wo:not(.btn_wo_fn):not(.disable):hover",
				".title_bar .menu_box .btn_wo:not(.btn_wo_fn):not(.disable).on:hover",
				".context_menu .btn_wo:not(.btn_wo_fn):not(.disable):hover",
				".container_view .sub_group:not(.disable):hover > a.sub_group_title",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data:not(.disable):hover"
			],
			DROPDOWN_DATA_HOVER_TEXT: [
				".title_bar .menu_box .btn_wo:not(.btn_wo_fn):not(.disable):hover a",
				".context_menu .btn_wo:not(.btn_wo_fn):not(.disable):hover a",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data:not(.disable):hover",
				".container_view .sub_group:not(.disable):hover > a.sub_group_title > span"
			],
			DROPDOWN_DATA_HOVER_SHORTCUT_TEXT: [
				".container_view .btn_wo:not(.disable):hover a .shortcut"
			],
			DROPDOWN_DATA_ARROW_HOVER: [
				".sub_group:not(.disable):hover > a.sub_group_title:before"
			],
			DROPDOWN_DATA_PUSH: [
				".title_bar .menu_box .btn_wo:not(.btn_wo_fn):not(.disable):active",
				".title_bar .menu_box .btn_wo:not(.btn_wo_fn):not(.disable).on:active",
				".context_menu .btn_wo:not(.btn_wo_fn):not(.disable):active",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data:not(.disable):active"
			],
			DROPDOWN_DATA_PUSH_TEXT: [
				".title_bar .menu_box .btn_wo:not(.btn_wo_fn):not(.disable):active a",
				".context_menu .btn_wo:not(.btn_wo_fn):not(.disable):active a",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data:not(.disable):active"
			],
			DROPDOWN_DATA_PUSH_SHORTCUT_TEXT: [
				".container_view .btn_wo:active:not(.disable) a .shortcut"
			],
			DROPDOWN_DATA_DISABLE: [
				".title_bar .menu_box .btn_wo.disable:not(.btn_wo_fn)",
				".context_menu .btn_wo.disable:not(.btn_wo_fn)",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data.disable",
				".container_view .sub_group.disable a.sub_group_title"
			],
			DROPDOWN_DATA_DISABLE_TEXT: [
				".title_bar .menu_box .btn_wo.disable:not(.btn_wo_fn) a",
				".context_menu .btn_wo.disable:not(.btn_wo_fn) a",
				".container_view .menu_select_list:not(.button_grid) > .dropdown_data.disable",
				".container_view .sub_group.disable > a.sub_group_title > span"
			],
			DROPDOWN_DATA_ARROW_DISABLE: [
				".container_view .sub_group.disable > a.sub_group_title:before"
			],
			DROPDOWN_DATA_DISABLE_SHORTCUT_TEXT: [
				".container_view .btn_wo.disable a .shortcut"
			]
		},
		CSS_COLOR_STYLE_MAP: { // attribute 에서 "Color" 이전까지의 구분으로 대상 style name mapping
			bg: "background",
			border: "border-color",
			text: "color",
			arrow: "border-color",
			shortcutText: "color",
			separator: "border-color",
			separatorText: "color"
		},
		CSS_COLOR_SELECTOR_MAP: {
			containers: {
				bgColor: "CONTAINER",
				borderColor: "CONTAINER",
				textColor: "CONTAINER",
				separatorColor: "SEPARATOR_COLOR",
				separatorTextColor: "SEPARATOR_TEXT"
			},
			titlePanel: {
				bgColor: "TITLE_PANEL",
				textColor: "TITLE_PANEL",
				borderColor: "TITLE_PANEL",
				arrowColor: "TITLE_PANEL_ARROW",
				bgColorHover: "TITLE_PANEL_HOVER",
				textColorHover: "TITLE_PANEL_HOVER",
				borderColorHover: "TITLE_PANEL_HOVER",
				bgColorOn: "TITLE_PANEL_ON",
				textColorOn: "TITLE_PANEL_ON",
				borderColorOn: "TITLE_PANEL_ON",
				bgColorPush: "TITLE_PANEL_PUSH",
				textColorPush: "TITLE_PANEL_PUSH",
				borderColorPush: "TITLE_PANEL_PUSH"
			},
			functionButtons: {
				bgColor: "BUTTON",
				textColor: "BUTTON_TEXT",
				borderColor: "BUTTON",
				arrowColor: "BUTTON_ARROW",
				bgColorOn: "BUTTON_ON",
				textColorOn: "BUTTON_ON_TEXT",
				borderColorOn: "BUTTON_ON",
				arrowColorOn: "BUTTON_ARROW_ON",
				bgColorHover: "BUTTON_HOVER",
				textColorHover: "BUTTON_HOVER_TEXT",
				borderColorHover: "BUTTON_HOVER_BORDER",
				arrowColorHover: "BUTTON_ARROW_HOVER",
				bgColorPush: "BUTTON_PUSH",
				textColorPush: "BUTTON_PUSH_TEXT",
				borderColorPush: "BUTTON_PUSH",
				arrowColorPush: "BUTTON_ARROW_PUSH",
				bgColorDisable: "BUTTON_DISABLE",
				borderColorDisable: "BUTTON_DISABLE",
				textColorDisable: "BUTTON_DISABLE_TEXT",
				arrowColorDisable: "BUTTON_ARROW_DISABLE"
			},
			dropdownListData: {
				bgColor: "DROPDOWN_DATA",
				textColor: "DROPDOWN_DATA_TEXT",
				shortcutTextColor: "DROPDOWN_DATA_SHORTCUT_TEXT",
				borderColor: "DROPDOWN_DATA",
				arrowColor: "DROPDOWN_DATA_ARROW",
				bgColorOn: "DROPDOWN_DATA_ON",
				textColorOn: "DROPDOWN_DATA_ON_TEXT",
				shortcutTextColorOn: "DROPDOWN_DATA_ON_SHORTCUT_TEXT",
				borderColorOn: "DROPDOWN_DATA_ON",
				bgColorHover: "DROPDOWN_DATA_HOVER",
				textColorHover: "DROPDOWN_DATA_HOVER_TEXT",
				shortcutTextColorHover: "DROPDOWN_DATA_HOVER_SHORTCUT_TEXT",
				borderColorHover: "DROPDOWN_DATA_HOVER",
				arrowColorHover: "DROPDOWN_DATA_ARROW_HOVER",
				bgColorPush: "DROPDOWN_DATA_PUSH",
				textColorPush: "DROPDOWN_DATA_PUSH_TEXT",
				shortcutTextColorPush: "DROPDOWN_DATA_PUSH_SHORTCUT_TEXT",
				borderColorPush: "DROPDOWN_DATA_PUSH",
				bgColorDisable: "DROPDOWN_DATA_DISABLE",
				textColorDisable: "DROPDOWN_DATA_DISABLE_TEXT",
				shortcutTextColorDisable: "DROPDOWN_DATA_DISABLE_SHORTCUT_TEXT",
				borderColorDisable: "DROPDOWN_DATA_DISABLE",
				arrowColorDisable: "DROPDOWN_DATA_ARROW_DISABLE"
			},
			resultButtons: {
				bgColor: "RESULT_BUTTON",
				textColor: "RESULT_BUTTON",
				borderColor: "RESULT_BUTTON",
				bgColorOn: "RESULT_BUTTON_ON",
				textColorOn: "RESULT_BUTTON_ON",
				borderColorOn: "RESULT_BUTTON_ON",
				bgColorHover: "RESULT_BUTTON_HOVER",
				textColorHover: "RESULT_BUTTON_HOVER",
				borderColorHover: "RESULT_BUTTON_HOVER",
				arrowColorHover: "RESULT_BUTTON_HOVER",
				bgColorPush: "RESULT_BUTTON_PUSH",
				textColorPush: "RESULT_BUTTON_PUSH",
				borderColorPush: "RESULT_BUTTON_PUSH",
				bgColorDisable: "RESULT_BUTTON_DISABLE",
				textColorDisable: "RESULT_BUTTON_DISABLE",
				borderColorDisable: "RESULT_BUTTON_DISABLE"
			},
			guideButtons: {
				textColor: "GUIDE_BUTTON"
			},
			controlButtons: {
				textColor: "CONTROL_BUTTON"
			},
			inputBox: {
				bgColor: "INPUT_BOX",
				textColor: "INPUT_BOX_TEXT",
				borderColor: "INPUT_BOX",
				borderColorHover: "INPUT_BOX_HOVER_BORDER",
				bgColorDisable: "INPUT_BOX_DISABLE",
				textColorDisable: "INPUT_BOX_DISABLE_TEXT",
				borderColorDisable: "INPUT_BOX_DISABLE"
			},
			categoryPanel: {
				bgColor: "CATEGORY_PANEL",
				textColor: "CATEGORY_PANEL",
				borderColor: "CATEGORY_PANEL"
			},
			contentsBox: {
				bgColor: "CONTENTS_BOX",
				textColor: "CONTENTS_BOX",
				borderColor: "CONTENTS_BOX"
			},
			dropdownBox: {
				bgColor: "DROPDOWN_BOX",
				textColor: "DROPDOWN_BOX",
				borderColor: "DROPDOWN_BOX"
			}
		},
		CSS_COLOR_CONTAINER_SELECTOR: {
			"status_bar": [
				"#status_bar",
				"#wrap[data-app=webcell] #status_bar"
			],
			"modal_dialog": [
				"#modal_dialog .dialog_wrap"
			],
			"style_bar": [
				"#style_bar",
				".style_bar:before",
				".style_bar:after"
			]
		},
		STYLE_NODE_ID: "hcft_custom_color",
		INHIBIT_CHILD_NODE_LIST: ["titleBar", "menuBar", "styleBar", "sideBar", "statusBar", "thumbnail", "translate", "contextMenu",
			"modalDialog", "modelessDialog", "quickMenuBox"],
		COLOR_CUSTOM_NODE_LIST: ["titlePanel", "functionButtons", "resultButtons", "inputBox", "dropdownBox", "dropdownListData"],

		USE_DISABLE_CONTAINER_ID_LIST: ["context_menu"],

		VALIDATION_CHECK_RESULT: {
			SUCCESS: 1,
			EMPTY_VALUE: -1,
			UNDER_MIN: -2,
			OVER_MAX: -3,
			NOT_NUMBER: -4,
			OVER_DECIMAL_LENGTH: -5,
			HAS_SIGN: -6,
			WRONG_VALUE: -7,
			UNSUPPORTED_EXTENSION: -8,
			HAS_MINUS_NUMBER: -9,
			INVALID_SPECIAL_CHARACTER: -10,
			PROHIBITED_FILE_NAME: -11
		},

		IMAGE_FILE_TYPE: ["gif", "jpeg", "jpg", "png", "bmp"],
		IMAGE_FILE_MAX_SIZE: 5242880, //5MB

		SPINNER_HOLD_DELAY_TIME: 600,
		SPINNER_HOLD_TIMER: 100,

		HELP_URL_WEBWORD : "../cloud-office/help/Hword/{}/index.htm",
		HELP_URL_WEBCELL : "../cloud-office/help/Hcell/{}/index.htm",
		HELP_URL_WEBSHOW : "../cloud-office/help/Hshow/{}/index.htm",

		HWP_GUIDE_URL : "https://help.malangmalang.com/hc/{}/articles/204536330",

		FONT_DETECT_MODE: {
			GLOBAL: "global",
			GLOBAL_EXTEND: "global_extend",
			CHARACTER_SET: "character_set"
		},

		APP_UI_MODE: {
			EDITOR: 1,
			VIEWER: 2,
			WATCHER: 3
		},

		USE_CHANGE_UI_MODE_MODULE_NAMES: ["webcell"],

		ENABLE_COMMANDS_IN_WATCHER_MODE: [
			"d_pdf_download", "d_print", "d_info", "taskpane", "e_show_mode", "e_show_mode_start", "e_view_scale", "e_zoom",
			"e_dialog_rename", "e_dialog_confirm", "e_dialog_error", "e_dialog_print", "e_dialog_download", "e_dialog_alert",
			"e_sheet_info", "e_first_sheet", "e_previous_sheet", "e_next_sheet", "e_last_sheet",
			"e_first_slide", "e_previous_slide", "e_next_slide", "e_last_slide",
			"e_help", "shortcut", "close", "e_desktop_confirm", "e_desktop_execute"
		],

		ENABLE_CONTEXT_MENU_IN_WATCHER_MODE: [
			"watcher_mode_message", "sheet_info"
		],

		NOT_EXECUTED_BY_CHANGE_INPUT_LIST: {
			// module name : [command name, ...]
			"webcell": ["e_name_box"]
		},

		NEED_NETWORK_MENU_LIST: ["storage_search_doc", "u_search_doc_context"],

		SVG_ICON_HTML: {
			default: {
				VIEW_CONTROL_RIGHT: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' viewBox='0 0 13 13' xml:space='preserve' width='13' height='13'><polygon points='4.5,2.6 4.5,4.3 7.5,6.6 4.5,8.8 4.5,10.6 9.7,6.6'/></svg>",
				VIEW_CONTROL_TOP: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' viewBox='0 0 13 13' xml:space='preserve' width='15' height='13' style='transform:scaleY(-1);'><polygon points='10.5,4 8.8,4 6.5,7 4.3,4 2.5,4 6.5,9.2'/></svg>",
				E_HELP: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' viewBox='0 0 13 13' xml:space='preserve' width='13' height='13'><g><path d='M3.9,4.9c0-1.9,1.1-3.2,3-3.2c1.5,0,2.7,0.9,2.7,2.6c0,1.2-0.5,1.7-1.1,2.2C7.9,7,7.4,7.4,7.4,8.7H6.1 c0-1.5,0.3-2,1-2.6c0.5-0.5,1-0.8,1-1.7c0-1.1-0.8-1.4-1.2-1.4c-1,0-1.5,0.8-1.5,1.9H3.9z'/><rect x='5.8' y='9.6' transform='matrix(0.9999 -1.376945e-02 1.376945e-02 0.9999 -0.1445 9.420014e-02)' class='st0' width='1.9' height='1.8'/></g></svg>",
				SHORTCUT: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' viewBox='0 0 13 13' xml:space='preserve' width='13' height='13'><g><path d='M2.9,2.3h1.5v3.6h0.1L8,2.3h2l-4,3.9l4.2,4.6H8.2L4.5,6.7H4.4v4.2H2.9V2.3z'/></g></svg>"
			},
			type_a: {
				VIEW_CONTROL_RIGHT: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' viewBox='0 0 1000 1000' xml:space='preserve' width='10' height='10'><g><path d='M367.9,496.3l0.4-0.1l-0.4-0.1L26.1,138.3C-31,83.5,77.7-30.9,139,22.2l428.4,435.6c21.6,21.4,20.1,58.6,0,76.7L139,970.1C77.7,1023.2-31,908.8,26.1,854L367.9,496.3z'/><path d='M774.8,504l0.4-0.1l-0.4-0.1L433,146C375.9,91.2,484.6-23.2,545.9,29.9l428.4,435.6c21.6,21.4,20.1,58.6,0,76.7L545.9,977.8c-61.3,53.1-170.1-61.3-112.9-116.1L774.8,504z'/></g></svg>",
				VIEW_CONTROL_TOP: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' viewBox='0 0 1000 1000' xml:space='preserve' width='10' height='10' style='transform:rotate(-90deg);'><g><path d='M367.9,496.3l0.4-0.1l-0.4-0.1L26.1,138.3C-31,83.5,77.7-30.9,139,22.2l428.4,435.6c21.6,21.4,20.1,58.6,0,76.7L139,970.1C77.7,1023.2-31,908.8,26.1,854L367.9,496.3z'/><path d='M774.8,504l0.4-0.1l-0.4-0.1L433,146C375.9,91.2,484.6-23.2,545.9,29.9l428.4,435.6c21.6,21.4,20.1,58.6,0,76.7L545.9,977.8c-61.3,53.1-170.1-61.3-112.9-116.1L774.8,504z'/></g></svg>",
				E_HELP: "<svg version='1.1' ixmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' viewBox='-119 121 16 16' xml:space='preserve' width='16' height='16'><path d='M-111,121c-4.4,0-8,3.6-8,8c0,4.4,3.6,8,8,8s8-3.6,8-8C-103,124.6-106.6,121-111,121z M-111,136c-3.9,0-7-3.1-7-7c0-3.9,3.1-7,7-7s7,3.1,7,7C-104,132.9-107.1,136-111,136z'/><text transform='matrix(1 0 0 1 -113.6238 132.0002)'>?</text></svg>",
				SHORTCUT: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' viewBox='-119 121 16 16' xml:space='preserve' width='16' height='16'><path d='M-111,121c-4.4,0-8,3.6-8,8c0,4.4,3.6,8,8,8s8-3.6,8-8C-103,124.6-106.6,121-111,121z M-111,136c-3.9,0-7-3.1-7-7c0-3.9,3.1-7,7-7s7,3.1,7,7C-104,132.9-107.1,136-111,136z'/><text transform='matrix(1 0 0 1 -114.3203 132)'>K</text></svg>"
			}
		},

		COLOR_PICKER_DEFAULT_COLOR: "#FF0000",

		COLOR_PICKER_THEME: {
			default: [
				"#FFFFFF","#000000","#FAF3DB","#3A3C84","#6182D6","#FF843A","#B2B2B2","#FFD700","#289B6E","#9D5CBB", // 테마 색
				"#F2F2F2","#808080","#F4E5B2","#D3D3EB","#DFE6F7","#FFE7D8","#F0F0F0","#FFF7CC","#CDF2E4","#EBDEF1",
				"#D9D9D9","#595959","#ECD174","#A6A7D8","#C0CDEF","#FFCEB0","#E0E0E0","#FFEF99","#9BE5C8","#D8BEE4",
				"#BFBFBF","#404040","#CEA61D","#7A7CC4","#A0B4E6","#FFB689","#D1D1D1","#FFE766","#69D8AD","#C49DD6",
				"#A6A6A6","#262626","#67530E","#2B2D63","#3057B9","#EB5800","#858585","#BFA100","#1E7452","#783E94",
				"#808080","#0D0D0D","#292106","#1D1E42","#203A7B","#9C3B00","#595959","#806B00","#144E37","#502962"
			],
			office: [
				"#000000","#FF0000","#FF6600","#FFFF00","#008000","#0000FF","#333399","#800080","#1B1760","#834D00", // 테마 색
				"#808080","#FFCCCC","#FFE0CC","#E5E500","#B3FFB3","#8080FF","#D1D1F0","#FF40FF","#6660DA","#FFDFB3",
				"#595959","#FF9999","#FFC299","#BFBF00","#66FF66","#5A5AFF","#A2A2E1","#FF06FF","#3C32CD","#FFC267",
				"#404040","#FF6666","#FFA366","#808000","#1AFF1A","#4040FF","#7676D1","#DF00DF","#3129AF","#FFA01C",
				"#262626","#BF0000","#BF4D00","#404000","#006000","#2727FF","#262673","#B900B9","#282390","#623A00",
				"#0D0D0D","#800000","#803300","#1A1A00","#004000","#0C0CFF","#1A1A4D","#930093","#201B70","#422700"
			],
			afterimage: [
				"#F3F0F4","#7B4D7C","#5A3452","#888888","#CD1973","#3A3A3A","#5E2856","#525252","#841490","#4686BA", // 테마 색
				"#DDD4E0","#E8D8E8","#E5CFDF","#E7E7E7","#F9CDE3","#D8D8D8","#E9CAE3","#DCDCDC","#F0C2F7","#DAE7F1",
				"#BBAAC1","#CEB3D0","#C9A2C1","#CFCFCF","#F39BC7","#B0B0B0","#D395C7","#BABABA","#E486EE","#B5CFE4",
				"#82668C","#B88CB8","#AE73A1","#B8B8B8","#ED69AB","#898989","#BB61B0","#979797","#D748E6","#90B6D6",
				"#413346","#5C3A5D","#44273D","#666666","#9A1356","#2C2C2C","#471E41","#3E3E3E","#630F6C","#34658C",
				"#1A141C","#3E273E","#2D1A29","#444444","#670D3A","#1D1D1D","#2F142B","#292929","#420A48","#23435D"
			],
			light: [
				"#FFFFFF","#000000","#75736C","#3A3936","#CC0000","#820000","#FF6600","#FF8837","#FFC000","#DEA900", // 테마 색
				"#F2F2F2","#808080","#E3E3E2","#D9D6D6","#FF6666","#FF4141","#FFE0CC","#FFE7D7","#FFF2CC","#FFF2C5",
				"#D9D9D9","#595959","#C9C7C3","#B1B1AE","#FF3838","#FF0808","#FFC299","#FFCFAF","#FFE699","#FFE48C",
				"#BFBFBF","#404040","#ADABA6","#8D8982","#FF1A1A","#E10000","#FFA366","#FFB787","#FFD966","#FFD552",
				"#A6A6A6","#262626","#585651","#2C2B29","#FA0000","#BB0000","#BF4D00","#E95E00","#BF9000","#A67F00",
				"#808080","#0D0D0D","#3B3A36","#1D1D1B","#DC0000","#950000","#803300","#9B3F00","#806000","#6F5500"
			],
			orange: [
				"#FFFFFF","#FE6100","#F79015","#363636","#FF4546","#D8D8D8","#FFCC00","#823200","#858585","#993366", // 테마 색
				"#F2F2F2","#FFDFCC","#FDE9D1","#D7D7D7","#FFDADA","#F7F7F7","#FFF5CC","#FFD0B3","#E7E7E7","#F0D1E0",
				"#D9D9D9","#FFC099","#FBD3A3","#AFAFAF","#FFB5B6","#EFEFEF","#FFEB99","#FFA167","#CECECE","#E1A2C2",
				"#BFBFBF","#FFA065","#FABC72","#868686","#FF8F90","#E8E8E8","#FFE066","#FF731B","#B6B6B6","#D176A3",
				"#A6A6A6","#BE4900","#C26D07","#292929","#F30001","#A2A2A2","#BF9900","#622500","#646464","#73264D",
				"#808080","#7F3100","#824904","#1B1B1B","#A20001","#6C6C6C","#806600","#411900","#434343","#4D1A33"
			],
			yesterday: [
				"#F6F6F6","#000000","#F4D783","#4E3B30","#F0A22E","#A5644E","#BD7979","#C3986D","#A19574","#C17529", // 테마 색
				"#EAEAEA","#808080","#FDF7E6","#E2D6D0","#FCECD5","#EEE0DB","#F2E4E4","#F3EAE2","#ECEAE3","#F6E3D1",
				"#D1D1D1","#595959","#FBEFCD","#C4AFA0","#F9DAAC","#DDC0B6","#E5C9C9","#E7D6C4","#D9D4C8","#ECC8A3",
				"#B8B8B8","#404040","#F9E7B4","#A78371","#F6C781","#CBA193","#D8AEAE","#DBC1A7","#C6C0AC","#E2AC77",
				"#A0A0A0","#262626","#ECBB2D","#3B2C24","#C87D0E","#7C4B3B","#9C4D4D","#A27242","#7C7154","#91581F",
				"#7B7B7B","#0D0D0D","#AC840F","#271E18","#85540A","#533227","#683333","#6C4C2C","#534B38","#613B14"
			],
			spring: [
				"#B4B4B4","#F2F2F2","#FFE68B","#FFFAEB","#FFAE00","#FFCF1B","#FD8A03","#FF5509","#FF9566","#521B00", // 테마 색
				"#F0F0F0","#DADADA","#FFDE64","#FFF4D3","#FFEFCC","#FFF6D1","#FFE8CC","#FFDDCE","#FFEAE0","#FF7229",
				"#E1E1E1","#B5B5B5","#FFD128","#FFE8A1","#FFDF99","#FFECA4","#FED09B","#FFBC9D","#FFD5C2","#E74F00",
				"#D2D2D2","#797979","#C59B00","#FFDB70","#FFCE66","#FFE376","#FEB967","#FF996B","#FFBFA3","#BD3D00",
				"#878787","#3D3D3D","#634D00","#FFCF40","#BF8200","#D4A700","#BE6802","#C63D00","#FF570D","#933000",
				"#5A5A5A","#181818","#271F00","#F5B800","#805700","#8D6F00","#7F4501","#842900","#B23700","#682200"
			],
			dream: [
				"#FFFFFF","#082108","#E8F7CD","#263608","#339933","#9DDC29","#FFCC00","#4CCB3B","#4CC6A9","#606060", // 테마 색
				"#F2F2F2","#42D242","#D6F1A6","#A8E23C","#D1F0D1","#ECF8D4","#FFF5CC","#DBF4D8","#DBF4EE","#DFDFDF",
				"#D9D9D9","#27A527","#BBE76C","#89BF1B","#A2E1A2","#D7F1AA","#FFEB99","#B7EAB1","#B7E8DD","#BFBFBF",
				"#BFBFBF","#1F801F","#88C31F","#6C9816","#76D176","#C4EA7F","#FFE066","#94E089","#94DDCB","#A0A0A0",
				"#A6A6A6","#165916","#446110","#4E7011","#267326","#77A81C","#BF9900","#379B29","#329C83","#484848",
				"#808080","#0D330D","#1B2706","#34490B","#1A4D1A","#4F7012","#806600","#24681B","#216857","#303030"
			],
			forest: [
				"#FFFFFF","#000000","#D5E8B5","#538E2F","#7FA854","#1C4001","#838B33","#B3BE4E","#FD8A03","#000099", // 테마 색
				"#F2F2F2","#808080","#F7FAF1","#DCEFCE","#E5EEDD","#CFFFA6","#EBEED0","#F0F2DB","#FFE8CC","#4D4DFF",
				"#D9D9D9","#595959","#EEF6E1","#B7DF9F","#CCDCBB","#98FF4D","#D7DDA1","#E1E5B8","#FED09B","#1616FF",
				"#BFBFBF","#404040","#E6F1D3","#93CF6E","#B2CC97","#6AED06","#C4CB73","#D1D895","#FEB967","#0000F3",
				"#A6A6A6","#262626","#A8D066","#3E6B23","#5F7E3F","#153001","#626826","#8A9336","#BE6802","#0000CF",
				"#808080","#0D0D0D","#759E31","#294717","#40542A","#0E2000","#424619","#5C6224","#7F4501","#0000AB"
			],
			sea: [
				"#000000","#FFFFFF","#092E99","#0C86CB","#5377A1","#335C91","#334F73","#8796AA","#A0BFE5","#000D59", // 테마 색
				"#808080","#F2F2F2","#5A82F6","#C7E9FC","#DCE4ED","#D0DDEF","#CFDBEA","#E7EAEE","#ECF2FA","#2D49FF",
				"#595959","#D9D9D9","#295DF2","#90D3F8","#B8C9DB","#A1BDDF","#9FB8D5","#CFD5DD","#D8E5F5","#0021EC",
				"#404040","#BFBFBF","#0E48EB","#58BCF5","#96ADC9","#749BCE","#7192BF","#B7C0CC","#C6D8EF","#001DC3",
				"#262626","#A6A6A6","#0C3DCA","#096498","#3E5979","#26456D","#263B56","#5F7086","#548CD0","#001699",
				"#0D0D0D","#808080","#0A33A9","#064366","#2A3B51","#1A2E49","#1A283A","#3F4A59","#2A5C99","#00106F"
			],
			weightlessness: [
				"#000000","#FFFFFF","#466991","#C9D6E5","#477F9B","#A2AFB7","#434343","#00B0F0","#8495A0","#777777", // 테마 색
				"#808080","#F2F2F2","#D7E1EC","#F4F7FA","#D8E6ED","#ECEFF1","#D9D9D9","#C9F0FF","#E6EAEC","#E4E4E4",
				"#595959","#D9D9D9","#AFC3D9","#E9EFF5","#B0CEDC","#DADFE2","#B4B4B4","#93E2FF","#CED5D9","#C9C9C9",
				"#404040","#BFBFBF","#88A4C5","#DFE6EF","#8BB4C9","#C7CFD4","#8E8E8E","#5DD4FF","#B5BFC6","#ADADAD",
				"#262626","#A6A6A6","#354F6D","#809FC2","#355F74","#718591","#323232","#0084B4","#5F717C","#595959",
				"#0D0D0D","#808080","#233549","#466991","#243F4E","#4B5961","#222222","#005878","#404B52","#3C3C3C"
			],
			deepsea: [
				"#FFFFFF","#000000","#A5A5A5","#5F5F5F","#4D4D4D","#657991","#63C8D3","#278089","#8495A0","#777777", // 테마 색
				"#F2F2F2","#808080","#EDEDED","#DFDFDF","#DBDBDB","#E0E4E9","#E0F4F6","#CBEEF0","#E6EAEC","#E4E4E4",
				"#D9D9D9","#595959","#DBDBDB","#BFBFBF","#B8B8B8","#C0C9D4","#C0E9EE","#98DAE1","#CED5D9","#C9C9C9",
				"#BFBFBF","#404040","#C9C9C9","#9F9F9F","#949494","#A2AFBE","#A1DEE5","#62C9D3","#B5BFC6","#ADADAD",
				"#A6A6A6","#262626","#7C7C7C","#474747","#3A3A3A","#4C5B6D","#33A9B5","#1D6067","#5F717C","#595959",
				"#808080","#0D0D0D","#535353","#303030","#272727","#333D49","#227079","#144045","#404B52","#3C3C3C"
			]
		},

		CALLOUT_SHAPE_LIST: [
			"wedgeRectCallout", "wedgeRoundRectCallout", "wedgeEllipseCallout", "cloudCallout", "callout1", "callout2",
			"callout3", "accentCallout1", "accentCallout2", "accentCallout3", "borderCallout1", "borderCallout2",
			"borderCallout3", "accentBorderCallout1", "accentBorderCallout2", "accentBorderCallout3"],

		VALUE: {
			ON: "on",
			OFF: "off",
			TOGGLE_ON: "toggle_on",
			TOGGLE_OFF: "toggle_off",
			DONT_CARE: "dontCare",
			DEFAULT: "default",
			TRUE: "true",
			FALSE: "false",
			TOP: "top",
			RIGHT: "right",
			BOTTOM: "bottom",
			LEFT: "left",
			PREV: "prev",
			NEXT: "next",
			AUTO: "auto",
			ALL: "all",
			NOT_ALL: "notAll",
			FILTERED_ALL: "filteredAll",
			EXECUTE: "execute",
			PX: "px"
		}
	};
});
