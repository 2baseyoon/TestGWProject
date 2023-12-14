(function () {
    'use strict';

    tinymce.PluginManager.add('covitable', function(editor, url) {
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var VALIGN_TYPE = {
            TOP: "top",
            MIDDLE: "middle",
            BASELINE: "baseline",
            BOTTOM: "bottom"
        };
        var HALIGN_TYPE = {
            LEFT: 'left',
            CENTER: 'center',
            RIGHT: 'right',
            JUSTIFY: 'justify'
        };
        var ALIGN_TYPE_MAP = {
            JustifyLeft: HALIGN_TYPE.LEFT,
            JustifyCenter: HALIGN_TYPE.CENTER,
            JustifyRight: HALIGN_TYPE.RIGHT,
            JustifyFull: HALIGN_TYPE.JUSTIFY
        };
        var CALC_TYPE = {
            ROW_SUM: 0,
            COL_SUM: 1,
            ROW_AVG: 2,
            COL_AVG: 3
        };
        var SELECTED_CELL = "data-mce-selected"
        var SELECTED_FIRST_CELL = "data-mce-first-selected";
        var SELECTED_LAST_CELL = "data-mce-last-selected";
        var _columnPropInitData = {
            align: '',
            width: '',
            borderstyle: '',
            bordercolor: '',
            backgroundcolor: ''
        }

        function checkTableSelected(api) {
            var tableEl = editor.selection.dom.$("table*[data-mce-selected*=1]")

            api.setDisabled(tableEl.length <= 0);
        }

        function checkInCell(api) {
            api.setDisabled(hasSelection() || !isInCell());
        }

        function isInCell() {
            var selectedNode = editor.selection.getNode();

            return (editor.dom.getParent(selectedNode, 'td,th') !== null);
        }

        function hasSelection() {
            var selectedItems = editor.selection.dom.$("td*[data-mce-selected*=1]");

            return (selectedItems.length > 0);
        }

        function isInColumn(api) {
            var selectedNode = editor.selection.getNode();
            var isNotCellOrRow = selectedNode.nodeName.toLowerCase() === 'table' || editor.dom.getParent(selectedNode, 'td,th') === null;

            api.setDisabled(isNotCellOrRow)
        }

        function checkInColumns(api) {
            var setValue = true;
            var selectedItems = editor.selection.dom.$("td*[data-mce-selected*=1]");

            if (selectedItems.length > 1) {
                if (selectedItems[0].parentNode === selectedItems[1].parentNode) {
                    setValue = false
                }
            }

            api.setDisabled(setValue)
        }

        function checkInRows(api) {
            var setValue = true;
            var selectedItems = editor.selection.dom.$("td*[data-mce-selected*=1]");

            if (selectedItems.length > 1) {
                var item0 = selectedItems[0];
                for (var i = 1; i < selectedItems.length; i++) {
                    if (item0.parentNode !== selectedItems[i].parentNode) {
                        setValue = false
                    }
                }
            }

            api.setDisabled(setValue)
        }

        function checkInColumnsAndRows(api) {
            var setValue = true;
            var selectedItems = editor.selection.dom.$("td*[data-mce-selected*=1]");

            if (selectedItems.length > 1) {
                if (selectedItems[0].parentNode === selectedItems[1].parentNode) {
                    var item0 = selectedItems[0];
                    for (var i = 1; i < selectedItems.length; i++) {
                        if (item0.parentNode !== selectedItems[i].parentNode) {
                            setValue = false
                        }
                    }
                }
            }

            api.setDisabled(setValue)
        }

        function calcRow(selNode) {
            var prevEl = selNode.previousElementSibling;
            var sum = 0;
            var count = 0;

            while (prevEl) {
                var text = (prevEl.innerText.length > 0 ? prevEl.innerText : (prevEl.textContent.length > 0 ? prevEl.textContent : ""));
                var val = parseInt(text);

                if (!isNaN(val)) {
                    sum += val;
                    count++;
                }

                prevEl = prevEl.previousElementSibling;
            }

            return {
                sum: sum,
                avg: (count > 0 ? sum / count : 0)
            }
        }

        function calcColumn(selNode) {
            var rowIndex = editor.dom.getParent(selNode, 'tr').rowIndex;
            var cellIndex = selNode.cellIndex;
            var tableEl = editor.dom.getParent(selNode, 'table', editor.dom.getRoot());
            var sum = 0;
            var count = 0;

            if (tableEl) {
                for (var i = 0; i < rowIndex; i++) {
                    var row = tableEl.rows[i];
                    var cell = row.cells[cellIndex];
                    var text = (cell.innerText.length > 0 ? cell.innerText : (cell.textContent.length > 0 ? cell.textContent : ""));
                    var val = parseInt(text);

                    if (!isNaN(val)) {
                        sum += val;
                        count++;
                    }
                }
            }

            return {
                sum: sum,
                avg: (count > 0 ? sum / count : 0)
            }
        }

        var applyStyleOrAttrToAllDescendants = function(node, propName, value, isStyle) {
            _tool.each(node.childNodes, function (childNode) {
                if (childNode.nodeType === 1) {
                    if (isStyle) {
                        editor.dom.setStyle(childNode, propName, value);
                    } else {
                        editor.dom.setAttrib(childNode, propName, value);
                    }
                    applyStyleOrAttrToAllDescendants(childNode, propName, value, isStyle);
                }
            });
        }

        var hasDescendants = function(node) {
            return (!editor.dom.isEmpty(node) && node.childElementCount > 0);
        }

        editor.addCommand('coviTableIndent', function(ui, v) {
            var blocks = editor.selection.getSelectedBlocks();
            if (blocks.length) {
                var tableEl = editor.dom.getParent(blocks[0], 'table', editor.dom.getRoot());

                if (tableEl) {
                    editor.dom.setStyle(tableEl, 'margin-left', (parseInt((tableEl.style.marginLeft) || parseInt(window.getComputedStyle(tableEl).marginLeft))) + 20 + 'px');
                }
            }
        });

        editor.addCommand('coviTableOutdent', function(ui, v) {
            var blocks = editor.selection.getSelectedBlocks();
            if (blocks.length) {
                var tableEl = editor.dom.getParent(blocks[0], 'table', editor.dom.getRoot());

                if (tableEl) {
                    editor.dom.setStyle(tableEl, 'margin-left', Math.max(0, (parseInt((tableEl.style.marginLeft) || parseInt(window.getComputedStyle(tableEl).marginLeft))) - 20) + 'px');
                }
            }
        });

        editor.addCommand('coviTableToText', function(ui, v) {
            var blocks = editor.selection.getSelectedBlocks();

            if (blocks.length) {
                var tableEl = editor.dom.getParent(blocks[0], 'table', editor.dom.getRoot());

                if (tableEl) {
                    var text = "";

                    for (var i = 0; i < tableEl.rows.length; i++) {
                        var row = tableEl.rows[i];

                        for (var j = 0; j < row.cells.length; j++) {
                            var cell = row.cells[j];

                            if (cell.innerText) {
                                text += cell.innerText;
                            } else if (cell.textContent) {
                                text += cell.textContent;
                            } else {
                                text += "";
                            }
                        }
                    }

                    var pEl = editor.dom.create("P");
                    pEl.innerHTML = text;

                    editor.dom.replace(pEl, tableEl, false);
                    editor.nodeChanged();
                }
            }
        });

        editor.addCommand('coviVerticalAlign', function(ui, alignType) {
            var selectedItems = editor.selection.dom.$("td*[data-mce-selected*=1]");

            if (selectedItems.length == 0) {
                var node = editor.selection.getNode();
                var parentCell = editor.dom.getParent(node, 'td,th');
                if (parentCell) {
                    selectedItems.push(parentCell);
                }
            }

            for (var i = 0; i < selectedItems.length; i++) {
                editor.dom.setStyle(selectedItems[i], 'vertical-align', alignType);
            }
        });

        editor.addCommand('coviTableCalc', function(ui, calcType) {
            var selNode = editor.dom.getParent(editor.selection.getNode(), 'td,th');

            if (selNode) {
                switch(calcType) {
                    case CALC_TYPE.ROW_SUM:
                    case CALC_TYPE.ROW_AVG:
                        var result = calcRow(selNode);
                        selNode.innerText = (calcType == CALC_TYPE.ROW_SUM) ? result.sum : result.avg;
                        break;
                    case CALC_TYPE.COL_SUM:
                    case CALC_TYPE.COL_AVG:
                        var result = calcColumn(selNode);
                        selNode.innerText = (calcType == CALC_TYPE.COL_SUM) ? result.sum : result.avg;
                        break;
                }
            }
        });

        editor.addCommand('coviTableInsertPara', function(ui, toAbove) {
            var blocks = editor.selection.getSelectedBlocks();
            if (blocks.length) {
                var tableEl = editor.dom.getParent(blocks[0], 'table', editor.dom.getRoot());

                if (tableEl) {
                    var newPara = editor.dom.create('P', null, '<br>');

                    if (toAbove) {
                        tableEl.parentElement.insertBefore(newPara, tableEl);
                    } else {
                        editor.dom.insertAfter(newPara, tableEl);
                    }

                    editor.selection.setCursorLocation(toAbove ? tableEl.previousSibling : tableEl.nextSibling, 0);
                    editor.nodeChanged();
                }
            }
        });


        editor.addCommand('coviTableAlign', function(ui, alignType) {
            var selectedEl = editor.selection.getNode();
            var tableEl = editor.dom.getParent(selectedEl, 'table', editor.dom.getRoot());

            if (tableEl) {
                editor.dom.setAttrib(tableEl, 'align', alignType);
            }
        });

        editor.addCommand('coviTableSameWidth', function() {
            var totalCols = 0;
            var totalWidth = 0;
            var averageWidth = 0;
            var blocks = editor.selection.getSelectedBlocks();
            var selectedItems = editor.selection.dom.$("td*[data-mce-selected*=1]");
            var cellIndexes = new Set()
            if (selectedItems.length > 1) {
                for(var i = 0; i < selectedItems.length; i++) {
                    var item = selectedItems[i];
                    var width = parseInt(editor.dom.getStyle(item, 'width', true));
                    var colSpan = item.colSpan
                    totalWidth += width;
                    if (colSpan > 1) {
                        totalCols += colSpan
                        for(var j = 0; j < colSpan; j++) {
                            cellIndexes.add(item.cellIndex + j)
                        }
                    } else {
                        totalCols += 1
                        cellIndexes.add(item.cellIndex)
                    }
                }
                averageWidth = totalWidth / totalCols;
                var tableEl = editor.dom.getParent(blocks[0], 'table', editor.dom.getRoot());
                if (tableEl) {
                    for (var i = 0; i < tableEl.rows.length; i++) {
                        var row = tableEl.rows[i];
                        for (var j = 0; j < row.cells.length; j++) {
                            if(cellIndexes.has(j)) {
                                var cell = row.cells[j];
                                var colSpan = cell.colSpan
                                if (colSpan > 1) {
                                    editor.dom.setStyle(cell, 'width', ((averageWidth * colSpan) + 'px'));
                                } else {
                                    editor.dom.setStyle(cell, 'width', (averageWidth + 'px'));
                                }
                            }
                        }
                    }
                }
            }
        });

        editor.addCommand('coviTableSameHeight', function() {
            var totalRows = 0;
            var totalHeight = 0;
            var averageHeight = 0;
            var blocks = editor.selection.getSelectedBlocks();
            var selectedItems = editor.selection.dom.$("td*[data-mce-selected*=1]");
            var rowIndexes = new Set()
            if (selectedItems.length > 1) {
                for(var i = 0; i < selectedItems.length; i++) {
                    var item = selectedItems[i];
                    var height = parseInt(editor.dom.getStyle(item, 'height', true));
                    var rowSpan = item.rowSpan;
                    totalHeight += height;
                    if (rowSpan > 1) {
                        totalRows += rowSpan;
                        for(var j = 0; j < rowSpan; j++) {
                            rowIndexes.add(item.parentElement.rowIndex + j)
                        }
                    } else {
                        totalRows += 1
                        rowIndexes.add(item.parentElement.rowIndex)
                    }
                }
                averageHeight = totalHeight / totalRows;
                var tableEl = editor.dom.getParent(blocks[0], 'table', editor.dom.getRoot());
                if (tableEl) {
                    for (var i = 0; i < tableEl.rows.length; i++) {
                        if(rowIndexes.has(i)) {
                            var row = tableEl.rows[i];
                            if (row) {
                                editor.dom.setStyle(row, 'height', (averageHeight + 'px'));
                                for (var j = 0; j < row.cells.length; j++) {
                                    var cell = row.cells[j];
                                    var rowSpan = cell.rowSpan;
                                    if (rowSpan > 1) {
                                        editor.dom.setStyle(cell, 'height', ((averageHeight*rowSpan) + 'px'));
                                    } else {
                                        editor.dom.setStyle(cell, 'height', (averageHeight + 'px'));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        });

        editor.addCommand('coviTableSameWidthHeight', function() {
            var totalCols = 0;
            var totalWidth = 0;
            var averageWidth = 0;
            var totalRows = 0;
            var totalHeight = 0;
            var averageHeight = 0;
            var blocks = editor.selection.getSelectedBlocks();
            var selectedItems = editor.selection.dom.$("td*[data-mce-selected*=1]");
            var cellIndexes = new Set()
            var rowIndexes = new Set()
            if (selectedItems.length > 1) {
                for (var i = 0; i < selectedItems.length; i++) {
                    var item = selectedItems[i];
                    var width = parseInt(editor.dom.getStyle(item, 'width', true));
                    var height = parseInt(editor.dom.getStyle(item, 'height', true));
                    var colSpan = item.colSpan
                    var rowSpan = item.rowSpan;

                    totalWidth += width;
                    if (colSpan > 1) {
                        totalCols += colSpan
                        for (var j = 0; j < colSpan; j++) {
                            cellIndexes.add(item.cellIndex + j)
                        }
                    } else {
                        totalCols += 1
                        cellIndexes.add(item.cellIndex)
                    }
                    totalHeight += height;
                    if (rowSpan > 1) {
                        totalRows += rowSpan;
                        for (var j = 0; j < rowSpan; j++) {
                            rowIndexes.add(item.parentElement.rowIndex + j)
                        }
                    } else {
                        totalRows += 1
                        rowIndexes.add(item.parentElement.rowIndex)
                    }
                }

                averageWidth = totalWidth / totalCols;
                averageHeight = totalHeight / totalRows;
                var tableEl = editor.dom.getParent(blocks[0], 'table', editor.dom.getRoot());
                if (tableEl) {
                    for (var i = 0; i < tableEl.rows.length; i++) {
                        var row = tableEl.rows[i];
                        //Width
                        for (var j = 0; j < row.cells.length; j++) {
                            if(cellIndexes.has(j)) {
                                var cell = row.cells[j];
                                var colSpan = cell.colSpan
                                if (colSpan > 1) {
                                    editor.dom.setStyle(cell, 'width', ((averageWidth * colSpan) + 'px'));
                                } else {
                                    editor.dom.setStyle(cell, 'width', (averageWidth + 'px'));
                                }
                            }
                        }
                        //Height
                        if (rowIndexes.has(i)) {
                            editor.dom.setStyle(row, 'height', (averageHeight + 'px'));
                            for (var j = 0; j < row.cells.length; j++) {
                                var cell = row.cells[j];
                                var rowSpan = cell.rowSpan;
                                if (rowSpan > 1) {
                                    editor.dom.setStyle(cell, 'height', ((averageHeight * rowSpan) + 'px'));
                                } else {
                                    editor.dom.setStyle(cell, 'height', (averageHeight + 'px'));
                                }
                            }
                        }
                    }
                }
            }
        });

        editor.ui.registry.addButton('coviinserttabledialog', {
            tooltip: 'Insert table...',
            icon: 'table',
            onAction: function() {
                return editor.execCommand('mceInsertTable');
            }
        });

        editor.ui.registry.addMenuItem('coviinserttabledialog', {
            text: 'Insert table...',
            icon: 'table',
            onAction: function() {
                return editor.execCommand("mceInsertTable");
            },
        });

        editor.ui.registry.addMenuItem('covitableindent', {
            text: 'Table increase indent',
            icon: 'indent',
            onAction: function() {
                return editor.execCommand("coviTableIndent");
            },
            onSetup: checkTableSelected
        });

        editor.ui.registry.addMenuItem('covitableoutdent', {
            text: "Table decrease indent",
            icon: 'outdent',
            onAction: function() {
                return editor.execCommand('coviTableOutdent');
            },
            onSetup: checkTableSelected
        });

        editor.ui.registry.addNestedMenuItem('covitableverticalalign', {
            text: "Vertical align",
            icon: 'covi-table-vertical-align',
            getSubmenuItems: function () {
                return [{
                    type: 'menuitem',
                    text: 'Align top',
                    icon: 'covi-table-vertical-align-top',
                    onAction: function () {
                        editor.execCommand("coviVerticalAlign", false, VALIGN_TYPE.TOP);
                    },
                    onSetup: checkTableSelected
                }, {
                    type: 'menuitem',
                    text: 'Align middle',
                    icon: 'covi-table-vertical-align-middle',
                    onAction: function () {
                        editor.execCommand("coviVerticalAlign", false, VALIGN_TYPE.MIDDLE);
                    },
                    onSetup: checkTableSelected
                }
                /* // 23.09.05, covision 자체수정 : BASELINE 미사용처리.
                , {
                    type: 'menuitem',
                    text: 'Align baseline',
                    onAction: function () {
                        editor.execCommand("coviVerticalAlign", false, VALIGN_TYPE.BASELINE);
                    },
                    onSetup: checkTableSelected
                }
                */
                , {
                    type: 'menuitem',
                    text: 'Align bottom',
                    icon: 'covi-table-vertical-align-bottom',
                    onAction: function () {
                        editor.execCommand("coviVerticalAlign", false, VALIGN_TYPE.BOTTOM);
                    },
                    onSetup: checkTableSelected
                }]
            }
        });

        editor.ui.registry.addNestedMenuItem('covitablecalc', {
            text: "Calcuration",
            icon: 'covi-table-calc',
            getSubmenuItems: function () {
                return [{
                    type: 'menuitem',
                    text: 'Row sum',
                    icon: 'table-calc-row-sum',
                    onAction: function () {
                        editor.execCommand("coviTableCalc", false, CALC_TYPE.ROW_SUM);
                    },
                    onSetup: checkInCell
                }, {
                    type: 'menuitem',
                    text: 'Column sum',
                    icon: 'table-calc-col-sum',
                    onAction: function () {
                        editor.execCommand("coviTableCalc", false, CALC_TYPE.COL_SUM);
                    },
                    onSetup: checkInCell
                }, {
                    type: 'menuitem',
                    text: 'Row average',
                    icon: 'table-calc-row-avg',
                    onAction: function () {
                        editor.execCommand("coviTableCalc", false, CALC_TYPE.ROW_AVG);
                    },
                    onSetup: checkInCell
                }, {
                    type: 'menuitem',
                    text: 'Column average',
                    icon: 'table-calc-col-avg',
                    onAction: function () {
                        editor.execCommand("coviTableCalc", false, CALC_TYPE.COL_AVG);
                    },
                    onSetup: checkInCell
                }]
            }
        });

        editor.ui.registry.addMenuItem('covitabletotext', {
            text: 'Table to text',
            icon: 'covi-table-to-text',
            onAction: function() {
                return editor.execCommand('coviTableToText');
            },
            onSetup: checkTableSelected
        });

        editor.ui.registry.addNestedMenuItem('covitableinsertpara', {
            text: "Insert paragraph",
            icon: 'covi-table-insert-para',
            getSubmenuItems: function () {
                return [{
                    type: 'menuitem',
                    text: 'Above table',
                    icon: 'covi-table-insert-para-above',
                    onAction: function () {
                        editor.execCommand("coviTableInsertPara", false, true);
                    },
                    onSetup: checkTableSelected
                }, {
                    type: 'menuitem',
                    text: 'Below table',
                    icon: 'covi-table-insert-para-below',
                    onAction: function () {
                        editor.execCommand("coviTableInsertPara", false, false);
                    },
                    onSetup: checkTableSelected
                }]
            }
        });

        editor.ui.registry.addMenuItem('covitableselectcell', {
            text: 'Select cell',
            onAction: function() {
                var selectedNode = editor.selection.getNode();
                var cell = editor.dom.getParent(selectedNode, 'td,th');

                cell.setAttribute(SELECTED_CELL, '1');
                cell.setAttribute(SELECTED_FIRST_CELL, "1");
                cell.setAttribute(SELECTED_LAST_CELL, "1");

                var copyRange = editor.dom.createRng();
                copyRange.selectNodeContents(cell);
                editor.selection.setRng(copyRange);

                editor.nodeChanged({ selectionChange: true });
                editor.focus();
            },
            onSetup: checkInCell
        });

        editor.ui.registry.addMenuItem('covitableselectrow', {
            text: 'Select row',
            onAction: function() {
                var row = editor.dom.getParent(editor.selection.getNode(), 'tr', editor.dom.getRoot());
                var cells = row.children;

                for (var i = 0; i < cells.length; i++) {
                    cells[i].setAttribute(SELECTED_CELL, '1');

                    if (i == 0) {
                        cells[i].setAttribute(SELECTED_FIRST_CELL, "1");
                    }

                    if (i == (cells.length - 1)) {
                        cells[i].setAttribute(SELECTED_LAST_CELL, "1");
                    }
                }

                var copyRange = editor.dom.createRng();
                copyRange.selectNodeContents(row);
                editor.selection.setRng(copyRange);

                editor.nodeChanged({ selectionChange: true });
                editor.focus();
            },
            onSetup: checkInCell
        });

        editor.ui.registry.addMenuItem('covitableselectcolumn', {
            text: 'Select column',
            onAction: function() {
                var selectedNode = editor.selection.getNode();
                var selectedCell = editor.dom.getParent(selectedNode, 'td,th');

                if (selectedCell) {
                    var tableEl = editor.dom.getParent(selectedCell, 'table', editor.dom.getRoot());
                    var selectedCellRect = selectedCell.getBoundingClientRect();

                    if (tableEl) {
                        var copyRange = editor.dom.createRng();

                        for (var i = 0; i < tableEl.rows.length; i++) {
                            var rowEl = tableEl.rows[i];

                            for (var j = 0; j < rowEl.cells.length; j++) {
                                var curCell = rowEl.cells[j];
                                var curCellRect = curCell.getBoundingClientRect();

                                if (curCellRect.left === selectedCellRect.left) {
                                    curCell.setAttribute(SELECTED_CELL, '1');
                                    copyRange.selectNode(curCell);

                                    if (i == 0) {
                                        curCell.setAttribute(SELECTED_FIRST_CELL, '1');
                                    }

                                    if (i == (tableEl.rows.length - 1)) {
                                        curCell.setAttribute(SELECTED_LAST_CELL, '1');
                                    }
                                }
                            }
                        }

                        editor.selection.setRng(copyRange);
                        editor.nodeChanged({selectionChange: true});
                        editor.focus();
                    }
                }
            },
            onSetup: checkInCell
        });
        
        editor.ui.registry.addMenuItem('covitablesamewidth', {
            text: 'Column same width',
            icon: 'column-same-width',
            onAction: function () {
                return editor.execCommand('coviTableSameWidth')
            },
            onSetup: checkInColumns
        });
        
        editor.ui.registry.addMenuItem('covitablesameheight', {
            text: 'Row same height',
            icon: 'row-same-height',
            onAction: function () {
                return editor.execCommand('coviTableSameHeight')
            },
            onSetup: checkInRows
        });

		editor.ui.registry.addMenuItem('covitablesamewidthheight', {
            text: 'cell same',
            icon: 'cell-same',
            onAction: function () {
                return editor.execCommand('coviTableSameWidthHeight')
            },
            onSetup: checkInColumnsAndRows
        });

        var getColumnCells = function() {
            var selectedNode = editor.selection.getNode();
            var selectedCell = editor.dom.getParent(selectedNode, 'td,th');
            var columnCells = [];

            var updateInitData = function(cell) {
                var align = editor.dom.getStyle(cell, 'textAlign');
                var width = parseInt(editor.dom.getStyle(cell, 'width')) + '';
                var borderstyle = editor.dom.getStyle(cell, 'borderStyle');
                var bordercolor = editor.dom.getStyle(cell, 'borderColor');
                var backgroundcolor = editor.dom.getStyle(cell, 'backgroundColor');

                if (bordercolor === undefined || bordercolor.length === 0) {
                    bordercolor = '';
                } else {
                    bordercolor = editor.dom.toHex(bordercolor);
                    var format = bordercolor.split(' ');
                    if (format && format.length > 1) {
                        bordercolor = '';
                    }
                }

                if (backgroundcolor === undefined || backgroundcolor.length === 0) {
                    backgroundcolor = '';
                } else {
                    backgroundcolor = editor.dom.toHex(backgroundcolor);
                }

                if (columnCells.length === 1) {
                    _columnPropInitData.align = align;
                    _columnPropInitData.width = width;
                    _columnPropInitData.borderstyle = borderstyle;
                    _columnPropInitData.bordercolor = bordercolor;
                    _columnPropInitData.backgroundcolor = backgroundcolor;
                } else {
                    _columnPropInitData.align = _columnPropInitData.align !== align ? '' : _columnPropInitData.align;
                    _columnPropInitData.width = _columnPropInitData.width !== width ? '' : _columnPropInitData.width;
                    _columnPropInitData.borderstyle = _columnPropInitData.borderstyle !== borderstyle ? '' : _columnPropInitData.borderstyle;
                    _columnPropInitData.bordercolor = _columnPropInitData.bordercolor !== bordercolor ? '' : _columnPropInitData.bordercolor;
                    _columnPropInitData.backgroundcolor = _columnPropInitData.backgroundcolor != backgroundcolor ? '' : _columnPropInitData.backgroundcolor;
                }
            }

            if (selectedCell) {
                var tableEl = editor.dom.getParent(selectedCell, 'table', editor.dom.getRoot());
                var selectedCellRect = selectedCell.getBoundingClientRect();

                if (tableEl) {
                    for (var i = 0; i < tableEl.rows.length; i++) {
                        var rowEl = tableEl.rows[i];

                        for (var j = 0; j < rowEl.cells.length; j++) {
                            var curCell = rowEl.cells[j];
                            var curCellRect = curCell.getBoundingClientRect();

                            if (curCellRect.left === selectedCellRect.left) {
                                columnCells.push(curCell);
                                updateInitData(curCell);
                            }
                        }
                    }
                }
            }

            return columnCells;
        }

        editor.ui.registry.addMenuItem('covitablecolumnprops', {
            text: 'Column properties',
            icon: 'covi-table-column-props',
            onAction: function() {
                var columnCells = getColumnCells();
                var initData = JSON.parse(JSON.stringify(_columnPropInitData));
                var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
                var processChangeInputTypeToNumber = function (editor) {
                    var items = document.querySelectorAll(".tox-dialog__body .tox-dialog__body-content .tox-form .tox-form__group > input.tox-textfield");
                    _tool.each(items, function(item) {
                        item.type = 'number';
                        item.min = 0;
                    });
                }

                editor.windowManager.open({
                    title: 'Column Properties',
                    size: 'normal',
                    body: {
                        type: 'tabpanel',
                        tabs: [{
                                title: 'General',
                                name: 'general',
                                items: [{
                                    type: 'listbox',
                                    name: 'align',
                                    label: 'Alignment',
                                    items: [
                                        {
                                            text: 'None',
                                            value: ''
                                        },
                                        {
                                            text: 'Left',
                                            value: 'left'
                                        },
                                        {
                                            text: 'Center',
                                            value: 'center'
                                        },
                                        {
                                            text: 'Right',
                                            value: 'right'
                                        }
                                    ]
                                }, {
                                    type: 'input',
                                    name: 'width',
                                    label: tinymce.util.I18n.translate('Width') + ' (px)'
                                }]
                        }, {
                            title: 'Border/Background',
                            name: 'advanced',
                            items: [{
                                    name: 'borderstyle',
                                    type: 'listbox',
                                    label: 'Border style',
                                    items: [{
                                            text: 'Select...',
                                            value: ''
                                            }, {
                                                text: 'Solid',
                                                value: 'solid'
                                            }, {
                                                text: 'Dotted',
                                                value: 'dotted'
                                            }, {
                                                text: 'Dashed',
                                                value: 'dashed'
                                            }, {
                                                text: 'Double',
                                                value: 'double'
                                            }, {
                                                text: 'Groove',
                                                value: 'groove'
                                            }, {
                                                text: 'Ridge',
                                                value: 'ridge'
                                            }, {
                                                text: 'Inset',
                                                value: 'inset'
                                            }, {
                                                text: 'Outset',
                                                value: 'outset'
                                            }, {
                                                text: 'None',
                                                value: 'none'
                                            }, {
                                                text: 'Hidden',
                                                value: 'hidden'
                                            }]
                                    }, {
                                        name: 'bordercolor',
                                        type: 'colorinput',
                                        label: 'Border color'
                                    }, {
                                        name: 'backgroundcolor',
                                        type: 'colorinput',
                                        label: 'Background color'
                                    }]
                        }]
                    },
                    buttons: [
                        {
                            type: 'cancel',
                            name: 'cancel',
                            text: 'Cancel'
                        },
                        {
                            type: 'submit',
                            name: 'save',
                            text: 'Save',
                            primary: true
                        }
                    ],
                    initialData: initData,
                    onTabChange: function(api, details) {
                        if (details && details.newTabName === 'general') {
                            processChangeInputTypeToNumber(editor);
                        }
                    },
                    onSubmit: function(api) {
                        var data = api.getData();
                        var isNumOnly = function(num) {
                            return /^\d+$/.test(num);
                        }

                        _tool.each(columnCells, function(cell) {
                            var width = isNumOnly(data.width) ? (data.width + 'px') : data.width;
                            var borderstyle = data.borderstyle.length === 0 ? 'none' : data.borderstyle;
                            var bordercolor = data.bordercolor.length === 0 ? '' : data.bordercolor;

                            if (data.align !== _columnPropInitData.align) {
                                editor.dom.setStyle(cell, 'textAlign', data.align);
                            }

                            if (data.width !== _columnPropInitData.width) {
                                editor.dom.setStyle(cell, 'width', width);
                            }

                            if (data.borderstyle !== _columnPropInitData.borderstyle) {
                                editor.dom.setStyle(cell, 'borderStyle', borderstyle);
                            }

                            if (data.bordercolor !== _columnPropInitData.bordercolor) {
                                editor.dom.setStyle(cell, 'borderColor', bordercolor);
                            }

                            if (data.backgroundcolor !== _columnPropInitData.backgroundcolor) {
                                editor.dom.setStyle(cell, 'backgroundColor', data.backgroundcolor);
                            }
                        });

                        api.close();
                    }
                });
                processChangeInputTypeToNumber(editor);
            },
            onSetup: isInColumn
        });

        editor.ui.registry.addMenuItem('covitableselectall', {
            text: 'Select table',
            icon: 'covi-table-select-all',
            onAction: function() {
                var selectedCell = editor.selection.getNode();
                var tableEl = editor.dom.getParent(selectedCell, 'table', editor.dom.getRoot());

                if (tableEl) {
                    for (var i = 0; i < tableEl.rows.length; i++) {
                        var cells = tableEl.rows[i].cells;

                        for (var j = 0; j < cells.length; j++) {
                            cells[j].setAttribute(SELECTED_CELL, '1');

                            if (i == 0 && j == 0) {
                                cells[j].setAttribute(SELECTED_FIRST_CELL, '1');
                            }

                            if (i == (tableEl.rows.length - 1) && (j == (cells.length - 1))) {
                                cells[j].setAttribute(SELECTED_LAST_CELL, '1');
                            }
                        }
                    }

                    editor.selection.select(tableEl);
                    editor.focus();
                }
            },
            onSetup: checkTableSelected
        });


        editor.ui.registry.addNestedMenuItem('covitablecell', {
            text: "Cell",
            getSubmenuItems: function () {
                return 'covitableselectcell tablecellprops tablemergecells tablesplitcells';
            }
        });

        editor.ui.registry.addNestedMenuItem('covitablerow', {
            text: "Row",
            getSubmenuItems: function () {
                return 'covitableselectrow tableinsertrowbefore tableinsertrowafter tabledeleterow tablerowprops | tablecutrow tablecopyrow tablepasterowbefore tablepasterowafter';
            }
        });

        editor.ui.registry.addNestedMenuItem('covitablecolumn', {
            text: "Column",
            getSubmenuItems: function () {
                return 'covitableselectcolumn tableinsertcolumnbefore tableinsertcolumnafter tabledeletecolumn covitablecolumnprops | tablecutcolumn tablecopycolumn tablepastecolumnbefore tablepastecolumnafter';
            }
        });

		editor.ui.registry.addNestedMenuItem('covitalbleresizingcell', {
            text: "Resizing cells",
            getSubmenuItems: function () {
                return 'covitablesamewidth covitablesameheight covitablesamewidthheight';
            }
        });

        editor.ui.registry.addButton('covitableindent', {
           tooltip: 'Table increase indent',
            icon: 'indent',
            onAction: function() {
               return editor.execCommand('coviTableIndent');
            }
        });

        editor.ui.registry.addButton('covitableoutdent', {
            tooltip: 'Table decrease indent',
            icon: 'outdent',
            onAction: function() {
                return editor.execCommand('coviTableOutdent');
            }
        });

        editor.ui.registry.addButton('covitablealignLeft', {
            tooltip: 'Table align left',
            icon: 'align-left',
            onAction: function() {
                return editor.execCommand('coviTableAlign', false, HALIGN_TYPE.LEFT);
            }
        });

        editor.ui.registry.addButton('covitablealigncenter', {
            tooltip: 'Table align center',
            icon: 'align-center',
            onAction: function() {
                return editor.execCommand('coviTableAlign', false, HALIGN_TYPE.CENTER);
            }
        });

        editor.ui.registry.addButton('covitablealignright', {
            tooltip: 'Table align right',
            icon: 'align-right',
            onAction: function() {
                return editor.execCommand('coviTableAlign', false, HALIGN_TYPE.RIGHT);
            }
        });

        editor.ui.registry.addButton('covitablealignjustify', {
            tooltip: 'Table justify',
            icon: 'align-justify',
            onAction: function() {
                return editor.execCommand('coviTableAlign', false, HALIGN_TYPE.JUSTIFY);
            }
        });

        editor.ui.registry.addButton('covitablesamewidth', {
            tooltip: 'Column same width',
            icon: 'column-same-width',
            onAction: function () {
                return editor.execCommand('coviTableSameWidth')
            },
            onSetup: checkInColumns
        });

        editor.ui.registry.addButton('covitablesameheight', {
            tooltip: 'Row same height',
            icon: 'row-same-height',
            onAction: function () {
                return editor.execCommand('coviTableSameHeight')
            },
            onSetup: checkInRows
        });

        editor.ui.registry.addButton('covitablesamewidthheight', {
            tooltip: 'cell same',
            icon: 'cell-same',
            onAction: function () {
                return editor.execCommand('coviTableSameWidthHeight')
            },
            onSetup: checkInColumnsAndRows
        });

        editor.ui.registry.addMenuButton('inserttable', {
            tooltip: 'Insert table',
            icon: 'table',
            fetch: function(callback) {
                var item = [{
                    type: 'fancymenuitem',
                    fancytype: 'inserttable',
                    onAction: function(data) {
                        editor.execCommand('mceInsertTable', false, { rows: data.numRows, columns: data.numColumns });
                    }
                }];
                callback(item);
            }
        });

        editor.ui.registry.addContextMenu('covitable', {
           update: function(element) {
               var contextMenu = editor.getParam('covi_table_context_menu', '');

               return editor.dom.getParent(element, 'td,th') === null ? '' : contextMenu;
           }
        });

        editor.on('ObjectResizeStart', function(e) {
            editor.settings.table_column_resizing = "preservetable";
        });

        editor.on('ObjectResized', function(e) {
            editor.settings.table_column_resizing = "resizetable";
        });

        var postProcessLineHeight = function() {
            var cells = editor.selection.dom.$("td*[data-mce-selected*=1],th*[data-mce-selected*=1]");

            _tool.each(cells, function(cell) {
                var lineHeight = editor.dom.getStyle(cell, 'line-height');

                if (lineHeight && lineHeight.length > 0 && hasDescendants(cell)) {
                    editor.dom.setStyle(cell, 'line-height', null);
                    applyStyleOrAttrToAllDescendants(cell, 'line-height', lineHeight, true);
                }
            });
        }

        var postProcessTableAlign = function(alignType) {
            var selectedBlocks = editor.selection.getSelectedBlocks();
            var selectedCellEls = editor.selection.dom.$("td*[data-mce-selected*=1],th*[data-mce-selected*=1]");
            var selectedTableEls = editor.selection.dom.$("table*[data-mce-selected*=1]");
            var tableList = _tool.grep(selectedBlocks, function (block) {
                return block.nodeName.toLowerCase() === 'table';
            });
            var isOnlyTable = (selectedBlocks.length === 1 && (tableList.length === 1 || selectedTableEls.length === 1));

            var applyAlignToAllCells = function(cells, alignType) {
                _tool.each(cells, function (cell) {
                    if (hasDescendants(cell)) {
                        applyStyleOrAttrToAllDescendants(cell, 'text-align', alignType, true);
                    } else {
                        editor.dom.setStyle(cell, 'text-align', alignType);
                    }
                });
            }

            if (tableList.length > 0) {
                _tool.each(tableList, function (table) {
                    if (!isOnlyTable) {
                        editor.dom.setAttrib(table, 'align', alignType);
                        editor.dom.setStyle(table, 'float', null);
                    }

                    _tool.each(table.rows, function (row) {
                        applyAlignToAllCells(row.cells, alignType);
                    })
                });
            } else {
                applyAlignToAllCells(selectedCellEls, alignType);
            }
        }

        editor.on('ExecCommand', function(e) {
            if (e.command === 'LineHeight') {
                postProcessLineHeight();
            }

            if (e.command === 'JustifyLeft' || e.command === 'JustifyCenter' || e.command === 'JustifyRight' || e.command === 'JustifyFull') {
                postProcessTableAlign(ALIGN_TYPE_MAP[e.command]);
            }

            if (e.command === 'mceTableMergeCells') {
                postProcessTableMergeCells();
            }
        });

        editor.on('TableModified', function(e) {
            if (editor.dom.get('mceResizeHandlenw') && editor.dom.get('mceResizeHandlene')) {
                var resizeHandlenwRect = editor.dom.get('mceResizeHandlenw').getBoundingClientRect();
                var resizeHandleneRect = editor.dom.get('mceResizeHandlene').getBoundingClientRect();
                var tableRect = e.table.getBoundingClientRect();
                var bodyMarginLeft = parseInt(editor.$(editor.getBody()).css('margin-left'));
                var resizeHandleMarginLeft = 3;
                var resizeHandleLeft = resizeHandlenwRect.left - resizeHandleMarginLeft;
                var tableLeft = tableRect.left - bodyMarginLeft;
                var isChangedTableMarginLeft = (tableRect.left - resizeHandlenwRect.left) === (tableRect.right - resizeHandleneRect.left);

                if ((tableLeft !== resizeHandleLeft) && isChangedTableMarginLeft) {
                    editor.dom.setStyle(e.table, 'margin-left', Math.abs(resizeHandleLeft - tableLeft));
                }
            }

            // var rows = e.table.getElementsByTagName('tr');
            // var cells = e.table.getElementsByTagName('td');
            // var trHeightArr = _tool.map(e.table.getElementsByTagName('tr'), function(row) { return editor.dom.getStyle(row, 'height', true); });
            // var tdHeightArr = _tool.map(e.table.getElementsByTagName('td'), function(cell) { return editor.dom.getStyle(cell, 'height', true); });
            //
            // _tool.each(cells, function(cell) {
            //     editor.dom.setStyle(cell, 'height', tdHeightArr.shift());
            // });
            //
            // _tool.each(rows, function(row) {
            //     editor.dom.setStyle(row, 'height', trHeightArr.shift());
            // });
            editor.nodeChanged();
        });

        // editor.on('newrow', function(e) {
        //     var prevRow = e.node.previousElementSibling;
        //
        //     editor.dom.setStyle(e.node, 'height', prevRow ? editor.dom.getStyle(prevRow, 'height') : '20px');
        // });

        editor.on('newcell', function(e) {
            var pEl = editor.dom.create('p', null, '<br>');

            if (e.node.firstElementChild) {
                if (!e.node.firstElementChild.innerHTML || e.node.firstElementChild.innerHTML === "") {
                    editor.dom.replace(pEl, e.node.firstElementChild, false);
                }
            } else {
                editor.dom.add(e.node, pEl);
            }
        });

        editor.on('keyup', function (e) {
            if (e.code === 'Delete' || e.code === 'Backspace') {
                var tables = editor.dom.select('table', editor.getBody());
                if (tables.length > 0) {
                    _tool.each(tables, function (table) {
                        _tool.each(table.rows, function (row) {
                            _tool.each(row.cells, function (cell) {
                                if (cell.nodeName.toLowerCase() === 'td' && cell.firstElementChild && cell.firstElementChild.nodeName.toLowerCase() === 'br') {
                                    if (!cell.firstElementChild.innerHTML || cell.firstElementChild.innerHTML === "") {
                                        var pEl = editor.dom.create('p', null, '<br>');
                                        editor.dom.replace(pEl, cell.firstElementChild, false);
                                    }
                                }
                            })
                        })
                    })
                }
            }
        });

        var applyListInTable = function(e) {
            if (hasSelection()) {
                e.preventDefault();
            }

            var cells = editor.selection.dom.$("td*[data-mce-selected*=1],th*[data-mce-selected*=1]");
            var unwrap = function(elem) {
                var parent = elem.parentNode;

                while (elem.firstChild) parent.insertBefore(elem.firstChild, elem);

                parent.removeChild(elem);
            }
            var isList = function(elem) {
                var name = elem.nodeName.toLowerCase();

                return (name === 'ul' || name === 'ol' || name === 'dl');
            }
            var isListItem = function(elem) {
                var name = elem.nodeName.toLowerCase();

                return (name === 'li' || name === 'dt' || name === 'dd');
            }
            var unwrapTopLevelListNode = function(elem) {
                _tool.each(elem.childNodes, function(listChild) {
                    if (isListItem(listChild)) {
                        editor.dom.replace(editor.dom.create('p'), listChild, true);
                    }
                });
                unwrap(elem);
            }
            var updateExistSubList = function(elem, listName) {
                var diffList = elem.querySelectorAll(listName === 'ol' ? 'ul' : 'ol');

                if (diffList.length > 0) {
                    _tool.each(diffList, function(listEl) {
                        editor.dom.replace(editor.dom.create(listName), listEl, true);
                    });
                }
            }
            var updateExistListItems = function(elem, style) {
                var listItems = elem.querySelectorAll('li,dt,dd');

                _tool.each(listItems, function(item) {
                    editor.dom.setStyle(item, 'list-style-type', style);
                });
            }
            var makeList = function(elem, noneListEls, listItemStyle) {
                var topLevelListEl = editor.dom.create(e.command === 'InsertOrderedList' ? 'ol' : 'ul');

                _tool.each(noneListEls, function(child) {
                    var item = editor.dom.create('li', listItemStyle ? { style: 'list-style-type:' + listItemStyle } : null);
                    topLevelListEl.appendChild(item);

                    if (child.nodeType === 3) {
                        item.innerHTML = child.nodeValue;
                    } else {
                        item.innerHTML = child.innerHTML;
                    }
                });
                elem.innerHTML = topLevelListEl.outerHTML;
                editor.nodeChanged();
            }
            var separateListOrNot = function(elem, listEls, noneListEls) {
                _tool.each(elem.childNodes, function(child) {
                    if (isList(child)) {
                        listEls.push(child);
                    } else {
                        noneListEls.push(child);
                    }
                });
            }
            var processList = function(listEls, noneListCount, listName) {
                var isListOnly = listEls.length > 0 && noneListCount === 0;
                var hasDiffList = _tool.grep(listEls, function(listEl) { return listEl.nodeName.toLowerCase() !== listName; }).length > 0;

                _tool.each(listEls, function(child) {
                    updateExistSubList(child, listName);

                    if (!isListOnly || (isListOnly && !hasDiffList)) {
                        unwrapTopLevelListNode(child);
                    } else if (child.nodeName.toLowerCase() !== listName) {
                        editor.dom.replace(editor.dom.create(listName), child, true);
                    }

                });
            }
            var processNoneList = function(elem, noneListEls, listName, listItemStyle) {
                if (noneListEls.length > 0) {
                    _tool.each(elem.childNodes, function(child) {
                        if (!isList(child)) {
                            editor.dom.replace(editor.dom.create('li', listItemStyle ? { style: 'list-style-type:' + listItemStyle } : null), child, true);
                        }
                    });

                    elem.innerHTML = '<' + listName + '>' + elem.innerHTML + '</' + listName + '>';
                }
            }

            _tool.each(cells, function(cell) {
                var listItemStyle = (e.value && e.value['list-style-type']) ? e.value['list-style-type'] : null;
                var topLevelListEl = editor.dom.create(e.command === 'InsertOrderedList' ? 'ol' : 'ul');

                if (cell.childNodes.length === 0) {
                    topLevelListEl.appendChild(editor.dom.create('li', listItemStyle ? { style: 'list-style-type:' + listItemStyle } : null));
                } else {
                    var listName = e.command === 'InsertOrderedList' ? 'ol' : 'ul';
                    var listEls = [];
                    var noneListEls = [];

                    separateListOrNot(cell, listEls, noneListEls);
                    updateExistListItems(cell, listItemStyle);

                    if (listEls.length === 0) {
                        updateExistSubList(cell, listName);
                        makeList(cell, noneListEls, listItemStyle);
                    } else {
                        processList(listEls, noneListEls.length, listName);
                        processNoneList(cell, noneListEls, listName, listItemStyle);
                    }
                }

                editor.nodeChanged();
            });
        }

        var preProcessTdHeightCheck = function() {
            var td = editor.dom.getParent(editor.selection.getStart(), 'td');
            if (td) {
                editor.dom.setStyle(td, 'height', '');
            }
        }

        var preProcessTableMergeCells = function() {
            var cells = editor.selection.dom.$("td*[data-mce-selected*=1],th*[data-mce-selected*=1]");
            _tool.each(cells, function (cell) {
                if (cell.innerHTML === "<p><br></p>" || cell.innerHTML === "<p><br/></p>") {
                    cell.innerHTML = '<br/>';
                }
            });
        }

        var postProcessTableMergeCells = function() {
            var td = editor.dom.getParent(editor.selection.getStart(), 'td');
            if (td) {
                if (td.innerHTML === '<br>' || td.innerHTML === '<br/>') {
                    td.innerHTML = "<p><br/></p>";
                    editor.selection.select(td.firstElementChild, true);
                }
            }
        }

        editor.on('BeforeExecCommand', function(e) {
            if (e.command === 'InsertOrderedList' || e.command === 'InsertUnorderedList') {
                applyListInTable(e);
            }

            if (e.command === 'mceTableSplitCells') {
                preProcessTdHeightCheck();
            }

            if (e.command === 'mceTableMergeCells') {
                preProcessTableMergeCells();
            }
        });
        return {
        };
    });
}());