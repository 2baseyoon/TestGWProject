(function () {
   'use strict';

    tinymce.PluginManager.add("coviruler", function(editor, url) {
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var RULER_SELECTOR = "covi_ruler_line";
        var CURSOR_MAX_LEFT = 2500;
        var CURSOR_LEFT_OFFSET = 20;
        var CURSOR_LEFT_RIGHT_MARGIN = 50;
        var RULER_OFFSET = -4;
        var DOC_RECT_LEFT_OFFSET = 18;
        var TABLE_LEFT_OFFSET = 10;
        var TABLE_RIGHT_OFFSET = 7;

        var _rulerArea;
        var _rulerAreaLeft = 0;
        var _rulerLineEl;
        var _ruler_handler_left;
        var _ruler_handler_right;
        var _ruler_handler_indent;
        var _ruler_handler_both;
        var _ruler_handler_action = "";
        var _ruler_handler_min_left = 0;
        var _ruler_handler_max_left = CURSOR_MAX_LEFT;
        var _ruler_handler_both_left = 0;
        var _ruler_body_left_disabled;
        var _ruler_body_right_disabled;
        var _ruler_handler_moving = false;
        var _enableRuler = false;
        var _isScrollBarX = false;
        var _docRect;

        function removeRulerLine() {
            var rulerLineEl = editor.dom.$.find('.' + RULER_SELECTOR);
            _tool.each(rulerLineEl, function(el) { el.parentNode.removeChild(el); });
            _rulerLineEl = null
        }

        function showRulerLine() {
            removeRulerLine();

            var editAreaEl = editor.dom.$.find('.' + 'tox-edit-area');
            var rulerLineEl = editor.dom.create("div");
            var rulerLineStyle = "user-select: none; position: absolute; height: 100%; width: 0px; border-left: 1px dashed #f56363; z-index: 10000000;";

            rulerLineEl.classList.add(RULER_SELECTOR);
            rulerLineEl.setAttribute("style", rulerLineStyle);
            rulerLineEl.setAttribute("contenteditable", false);

            editAreaEl[0].appendChild(rulerLineEl);
            _rulerLineEl = rulerLineEl;
        }

        function moveRulerLine(left) {
            left = (left + _rulerAreaLeft + 8) + 'px';
            editor.dom.setStyle(_rulerLineEl, 'left', left);
        }
        
        function moveRulerHandler(clientX) {
            var left = clientX + Math.abs(_rulerAreaLeft) - CURSOR_LEFT_OFFSET;
            var position_left = editor.dom.getStyle(_ruler_handler_left, 'left', true);
            var position_right = editor.dom.getStyle(_ruler_handler_right, 'left', true);
            var position_indent = editor.dom.getStyle(_ruler_handler_indent, 'left', true);
            position_left = parseInt(position_left, 10) + Math.abs(RULER_OFFSET);
            position_right = parseInt(position_right, 10) + Math.abs(RULER_OFFSET);
            position_indent = parseInt(position_indent, 10) + Math.abs(RULER_OFFSET);

            if (left < _ruler_handler_min_left) {
                left = _ruler_handler_min_left;
            } else if (left > _ruler_handler_max_left) {
                left = _ruler_handler_max_left;
            }

            if (_ruler_handler_action === "ACTION_LEFT") {
                if (left > position_right - CURSOR_LEFT_RIGHT_MARGIN) {
                    left = position_right - CURSOR_LEFT_RIGHT_MARGIN;
                }
                editor.dom.setStyle(_ruler_handler_left, 'left', (left+RULER_OFFSET)+'px');
            } else if (_ruler_handler_action === "ACTION_RIGHT") {
                if (position_indent > position_left) {
                    if (left < position_indent + CURSOR_LEFT_RIGHT_MARGIN) {
                        left = position_indent + CURSOR_LEFT_RIGHT_MARGIN;
                    }
                } else {
                    if (left < position_left + CURSOR_LEFT_RIGHT_MARGIN) {
                        left = position_left + CURSOR_LEFT_RIGHT_MARGIN;
                    }
                }
                editor.dom.setStyle(_ruler_handler_right, 'left', (left+RULER_OFFSET)+'px');
            } else if (_ruler_handler_action === "ACTION_INDENT") {
                if (left > position_right - CURSOR_LEFT_RIGHT_MARGIN) {
                    left = position_right - CURSOR_LEFT_RIGHT_MARGIN;
                }
                editor.dom.setStyle(_ruler_handler_indent, 'left', (left+RULER_OFFSET)+'px');
            } else if (_ruler_handler_action === "ACTION_BOTH") {
                if (_ruler_handler_both_left > 0) {
                    if ((left + _ruler_handler_both_left) > (position_right - CURSOR_LEFT_RIGHT_MARGIN)) {
                        left = position_right - CURSOR_LEFT_RIGHT_MARGIN - _ruler_handler_both_left;
                    }
                } else {
                    if ((left + _ruler_handler_both_left) < _ruler_handler_min_left) {
                        left = _ruler_handler_min_left + Math.abs(_ruler_handler_both_left);
                    } else if (left > position_right - CURSOR_LEFT_RIGHT_MARGIN) {
                        left = position_right - CURSOR_LEFT_RIGHT_MARGIN;
                    }
                }
                editor.dom.setStyle(_ruler_handler_left, 'left', (left+RULER_OFFSET)+'px');
                editor.dom.setStyle(_ruler_handler_indent, 'left', (left+_ruler_handler_both_left+RULER_OFFSET)+'px');
            } else {
                return;
            }

            moveRulerLine(left);
        }

        function isTableSelection() {
            return !!editor.dom.getParent(editor.selection.getStart(), 'td[data-mce-selected],th[data-mce-selected]', editor.getBody());
        }

        function isInCell(selectedNode) {
            return (editor.dom.getParent(selectedNode, 'td,th') !== null);
        }

        function isInLiNode(selectedNode) {
            return (editor.dom.getParent(selectedNode, 'li') !== null);
        }
        
        function checkScrollBarX() {
            var LEFT_OFFSET = 5;
            var innerWidth = editor.contentWindow.innerWidth;
            var elemList = editor.dom.select('table', editor.getBody());
            if (elemList.length > 0) {
                for (var i = 0; i < elemList.length; i++) {
                    var elem = elemList[i];
                    var elemLeft = elem.offsetLeft + elem.offsetWidth;
                    if (innerWidth < (elemLeft + LEFT_OFFSET)) {
                        _isScrollBarX = true;
                        break;
                    } else {
                        _isScrollBarX = false;
                    }
                }
            }
        }

        function getRulerHandlerPosition() {
            var handler_left = editor.dom.getStyle(_ruler_handler_left, 'left', true);
            var handler_right = editor.dom.getStyle(_ruler_handler_right, 'left', true);
            var handler_indent = editor.dom.getStyle(_ruler_handler_indent, 'left', true);

            return {
                left: parseInt(handler_left, 10) + Math.abs(RULER_OFFSET),
                right: parseInt(handler_right, 10) + Math.abs(RULER_OFFSET),
                indent: parseInt(handler_indent, 10) + Math.abs(RULER_OFFSET),
            }
        }

        function styleValue() {
            var handlerPosition = getRulerHandlerPosition();
            var left = handlerPosition.left - Math.abs(_ruler_handler_min_left);
            var right = _ruler_handler_max_left - handlerPosition.right;
            var indent = handlerPosition.indent - handlerPosition.left;

            return {
                marginLeft: left + 'px',
                marginRight: right + 'px',
                textIndent: indent + 'px'
            }
        }

        function applyRulerPosition() {
            var toTableCell = function () {
                var cells = editor.dom.select('td[data-mce-selected]');
                var styleArg = styleValue();
                if (cells.length > 0) {
                    _tool.each(cells, function (cell) {
                        _tool.each(cell.childNodes, function (child) {
                            if (child.nodeName.toLowerCase() === 'ol' || child.nodeName.toLowerCase() === 'ul') {
                                _tool.each(child.childNodes, function (child) {
                                    editor.dom.setStyles(child, styleArg);
                                })
                            } else {
                                editor.dom.setStyles(child, styleArg);
                            }
                        })
                    })
                }
            };
            var toNormal = function () {
                var checkSkipTag = ['ol','ul','tbody','tr','td'];
                var blocks = editor.selection.getSelectedBlocks();
                var styleArg = styleValue();
                _tool.each(blocks, function (selectedNode) {
                    if (checkSkipTag.indexOf(selectedNode.nodeName.toLowerCase()) < 0) {
                        if (selectedNode.nodeName.toLowerCase() === 'li') {
                            if (selectedNode.firstChild.nodeName.toLowerCase() !== 'ol' && selectedNode.firstChild.nodeName.toLowerCase() !== 'ul') {
                                editor.dom.setStyles(selectedNode, styleArg);
                            }
                        } else {
                            editor.dom.setStyles(selectedNode, styleArg);
                        }
                    }
                })
            };

            if (isTableSelection()) {
                editor.undoManager.transact(function () {
                    toTableCell();
                });
            } else {
                editor.undoManager.transact(function () {
                    toNormal();
                });
            }

            _ruler_handler_action = "";
        }

        function addEventListener() {
            _ruler_handler_left.addEventListener('mousedown', function (e) {
                _ruler_handler_moving = true;
                _ruler_handler_action = "ACTION_LEFT";
                showRulerLine();
                var left = editor.dom.getStyle(_ruler_handler_left, 'left', true);
                moveRulerLine(parseInt(left, 10) + Math.abs(RULER_OFFSET));
            });
            _ruler_handler_right.addEventListener('mousedown', function (e) {
                _ruler_handler_moving = true;
                _ruler_handler_action = "ACTION_RIGHT";
                showRulerLine();
                var left = editor.dom.getStyle(_ruler_handler_right, 'left', true);
                moveRulerLine(parseInt(left, 10) + Math.abs(RULER_OFFSET));
            });
            _ruler_handler_indent.addEventListener('mousedown', function (e) {
                _ruler_handler_moving = true;
                _ruler_handler_action = "ACTION_INDENT";
                showRulerLine();
                var left = editor.dom.getStyle(_ruler_handler_indent, 'left', true);
                moveRulerLine(parseInt(left, 10) + Math.abs(RULER_OFFSET));
            });
            _ruler_handler_both.addEventListener('mousedown', function (e) {
                e.stopPropagation();
                _ruler_handler_moving = true;
                _ruler_handler_action = "ACTION_BOTH";
                showRulerLine();
                var left = editor.dom.getStyle(_ruler_handler_left, 'left', true);
                var indent = editor.dom.getStyle(_ruler_handler_indent, 'left', true);
                _ruler_handler_both_left = parseInt(indent, 10) - parseInt(left, 10);
                moveRulerLine(parseInt(left, 10) + Math.abs(RULER_OFFSET));
            });

            var container = editor.getContainer();
            // container.addEventListener('mouseleave', function () {
            //     removeRulerLine();
            //     _ruler_handler_moving = false
            // });
            container.addEventListener('mouseup', function () {
                if (_ruler_handler_moving) {
                    applyRulerPosition();
                }
                _ruler_handler_moving = false;
                removeRulerLine();
            });
            container.addEventListener('mousemove', function (e) {
                if (_ruler_handler_moving) {
                    moveRulerHandler(e.clientX);
                }
            });

            var covieditorContainerEl = editor.dom.$.find("#covieditorContainer_ifr");
            covieditorContainerEl[0].contentWindow.addEventListener('mousemove', function (e) {
                if (_ruler_handler_moving) {
                    moveRulerHandler(e.clientX );
                }
            });
            covieditorContainerEl[0].contentWindow.addEventListener('mouseup', function () {
                if (_ruler_handler_moving) {
                    applyRulerPosition();
                }
                _ruler_handler_moving = false;
                removeRulerLine();
            });
        }

        function changeHandlerPosition() {
            var blocks = editor.selection.getSelectedBlocks();

            _ruler_handler_min_left = 0;
            _ruler_handler_max_left = _docRect.width - DOC_RECT_LEFT_OFFSET;

            if (blocks.length > 0) {
                var selectedNode = blocks[blocks.length - 1];
                if (isInCell(selectedNode)) {
                    var node_left = editor.dom.getStyle(selectedNode, 'margin-left', true);
                    var node_right = editor.dom.getStyle(selectedNode, 'margin-right', true);
                    var clientRect = selectedNode.getBoundingClientRect();
                    var left = parseInt(clientRect.left) + Math.abs(_rulerAreaLeft) - parseInt(node_left, 10) - TABLE_LEFT_OFFSET;
                    var right = parseInt(clientRect.right) + Math.abs(_rulerAreaLeft) + parseInt(node_right, 10) - TABLE_RIGHT_OFFSET;

                    node_right = right - parseInt(node_right, 10);

                    _ruler_handler_min_left = left;
                    _ruler_handler_max_left = right;
                    editor.dom.setStyle(_ruler_handler_right, 'left', (node_right+RULER_OFFSET)+'px');
                } else {
                    var node_right = editor.dom.getStyle(selectedNode, 'margin-right', true);
                    node_right = parseInt(node_right, 10);
                    if (node_right > 0) {
                        node_right = _ruler_handler_max_left - node_right;
                    } else {
                        node_right = _ruler_handler_max_left;
                    }
                    editor.dom.setStyle(_ruler_handler_right, 'left', (node_right+RULER_OFFSET)+'px');
                }
            }
        }

        function nodeChangeHandlerPosition(selectedNode) {
            var node_left = editor.dom.getStyle(selectedNode, 'margin-left', true);
            var node_right = editor.dom.getStyle(selectedNode, 'margin-right', true);
            var node_text_indent = editor.dom.getStyle(selectedNode, 'text-indent', true);
            var left = 0;
            var right = CURSOR_MAX_LEFT;

            if (isInCell(selectedNode)) {
                var clientRect = selectedNode.getBoundingClientRect();
                left = parseInt(clientRect.left) + Math.abs(_rulerAreaLeft) - parseInt(node_left, 10) - TABLE_LEFT_OFFSET;
                right = parseInt(clientRect.right) + Math.abs(_rulerAreaLeft) + parseInt(node_right, 10) - TABLE_RIGHT_OFFSET;

                _ruler_handler_min_left = left;
                _ruler_handler_max_left = right;

                node_left = left + parseInt(node_left, 10);
                node_right = right - parseInt(node_right, 10);
                node_text_indent = node_left + parseInt(node_text_indent, 10);
            } else if (isInLiNode(selectedNode)) {
                left = selectedNode.offsetLeft - parseInt(node_left, 10);

                _ruler_handler_min_left = left;
                _ruler_handler_max_left = _docRect.width - DOC_RECT_LEFT_OFFSET;

                node_left = left + parseInt(node_left, 10);
                node_right = parseInt(node_right, 10);
                node_text_indent = node_left + parseInt(node_text_indent, 10);
                if (node_right > 0) {
                    node_right = _ruler_handler_max_left - node_right;
                } else {
                    node_right = _ruler_handler_max_left;
                }
            } else {
                _ruler_handler_min_left = left;
                _ruler_handler_max_left = _docRect.width - DOC_RECT_LEFT_OFFSET;

                node_left = parseInt(node_left, 10);
                node_right = parseInt(node_right, 10);
                node_text_indent = node_left + parseInt(node_text_indent, 10);
                if (node_right > 0) {
                    node_right = _ruler_handler_max_left - node_right;
                } else {
                    node_right = _ruler_handler_max_left;
                }
            }

            editor.dom.setStyle(_ruler_body_left_disabled, 'width', left+'px');
            editor.dom.setStyle(_ruler_body_right_disabled, 'left', right+'px');
            editor.dom.setStyle(_ruler_body_right_disabled, 'width', (CURSOR_MAX_LEFT - right)+'px');

            editor.dom.setStyle(_ruler_handler_left, 'left', (node_left+RULER_OFFSET)+'px');
            editor.dom.setStyle(_ruler_handler_right, 'left', (node_right+RULER_OFFSET)+'px');
            editor.dom.setStyle(_ruler_handler_indent, 'left', (node_text_indent+RULER_OFFSET)+'px');
        }

        function rulerHandlerClickable(isClickable) {
            if (isClickable) {
                _enableRuler = true;
                editor.dom.setStyle(_ruler_handler_left, 'pointer-events', '');
                editor.dom.setStyle(_ruler_handler_right, 'pointer-events', '');
                editor.dom.setStyle(_ruler_handler_indent, 'pointer-events', '');
            } else {
                _enableRuler = false;
                editor.dom.setStyle(_ruler_handler_left, 'pointer-events', 'none');
                editor.dom.setStyle(_ruler_handler_right, 'pointer-events', 'none');
                editor.dom.setStyle(_ruler_handler_indent, 'pointer-events', 'none');
            }
        }

        function makeRulerToolbar() {
            var RULER_WIDTH = 50;

            var ruler_text_style = "vertical-align: bottom; display: inline-block; zoom: 1; height: 10px; font: 9px Arial; color: rgb(0, 0, 0); border: 0px; position: absolute; text-align: center; top: -12px; width: 9px;left: -3px;";
            var ruler_text_line_style = "font-size: 0px; width: 9px; vertical-align: bottom; display: inline-block; zoom: 1; position: relative; border-left: 1px solid rgb(220, 220, 220); height: 10px;position: relative; border-left: solid 1px #868686; height: 10px;"
            var ruler_division_line_style = "font-size: 0px; border-left: 1px solid rgb(153, 153, 153); height: 5px; width: 9px; vertical-align: bottom; display: inline-block; zoom: 1;border-left: solid 1px #868686; height: 7px;";

            var ruler_container = editor.dom.create('div', { id: 'ruler_container', style: 'position: relative; padding-top: 1px; z-index: 1; left: 0px; width: 100%; height: 25px; box-sizing: initial; user-select: none;'});
            var ruler_body = editor.dom.create('div', { id: 'ruler_body', style:'padding-top : 10px; padding-right: 20px; width: 2500px; white-space: nowrap; overflow: hidden'});
            var ruler_body_left_disabled = editor.dom.create('div', { id: 'ruler_body_left_disabled', style:'position: absolute; top: 0px; width: 0px; height: 26px; left: 0px; background-color: rgb(196, 198, 200); opacity: 0.6'});
            var ruler_body_right_disabled = editor.dom.create('div', { id: 'ruler_body_right_disabled', style:'position: absolute; top: 0px; width: 0px; height: 26px; left: 1200px; background-color: rgb(196, 198, 200); opacity: 0.6'});
            var ruler_handler_left = editor.dom.create('div', { id: 'ruler_handler_left', style: "cursor: pointer; position: absolute; top: 11px; width: 9px; height: 10px; background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAkAAAAKCAYAAABmBXS+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QzZGQ0RGQjVDODVDMTFFODgxQjVEODUxMjc4QkIxOTgiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QzZGQ0RGQjZDODVDMTFFODgxQjVEODUxMjc4QkIxOTgiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpDNkZDREZCM0M4NUMxMUU4ODFCNUQ4NTEyNzhCQjE5OCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpDNkZDREZCNEM4NUMxMUU4ODFCNUQ4NTEyNzhCQjE5OCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Ply5mV8AAACySURBVHjaYvz//z8DDEyfPp0FSM0E4vTMzMw/MHEmBlRQysjImASikQWZkEzRYGVlrXN3d2cA0SA+iiKgAIiebWRkxCEmJsYAokF8qDhEEdCKbKCkjbq6OlgniAbxQeIgPrO4uLgCMzPzWhcXFzZ2dna4O0Am3r592/bs2bPLQSad0dfX5+Hj40PxAYgPEv/79+8ZkCJhbW1tBmwAKi4McxNWRTBxUOAxLFq0iAEfAAgwALUhKXm2ShKQAAAAAElFTkSuQmCC');"})
            var ruler_handler_both = editor.dom.create('div', { id: 'ruler_handler_both', style: "cursor: pointer; position: absolute; top: 11px; width: 9px; height: 5px; background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAkAAAAFCAIAAAAYMVE8AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QjYxNjE3NzVDODVDMTFFODlCODlDMUNDODk3RUE2Q0UiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QjYxNjE3NzZDODVDMTFFODlCODlDMUNDODk3RUE2Q0UiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpCNjE2MTc3M0M4NUMxMUU4OUI4OUMxQ0M4OTdFQTZDRSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpCNjE2MTc3NEM4NUMxMUU4OUI4OUMxQ0M4OTdFQTZDRSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PsXs/bMAAAAnSURBVHjaYpk2bRoDDsACxHFxcZgSixYtYmLADfDJsUC0Y5UDCDAAPYIGueXq3bYAAAAASUVORK5CYII=');"})
            var ruler_handler_right = editor.dom.create('div', { id: 'ruler_handler_right', style: "cursor: pointer; position: absolute; top: 16px; width: 9px; height: 10px; background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAkAAAAKCAYAAABmBXS+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QzZGQ0RGQjVDODVDMTFFODgxQjVEODUxMjc4QkIxOTgiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QzZGQ0RGQjZDODVDMTFFODgxQjVEODUxMjc4QkIxOTgiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpDNkZDREZCM0M4NUMxMUU4ODFCNUQ4NTEyNzhCQjE5OCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpDNkZDREZCNEM4NUMxMUU4ODFCNUQ4NTEyNzhCQjE5OCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Ply5mV8AAACySURBVHjaYvz//z8DDEyfPp0FSM0E4vTMzMw/MHEmBlRQysjImASikQWZkEzRYGVlrXN3d2cA0SA+iiKgAIiebWRkxCEmJsYAokF8qDhEEdCKbKCkjbq6OlgniAbxQeIgPrO4uLgCMzPzWhcXFzZ2dna4O0Am3r592/bs2bPLQSad0dfX5+Hj40PxAYgPEv/79+8ZkCJhbW1tBmwAKi4McxNWRTBxUOAxLFq0iAEfAAgwALUhKXm2ShKQAAAAAElFTkSuQmCC');"})
            var ruler_handler_indent = editor.dom.create('div', { id: 'ruler_handler_indent', style: "cursor: pointer; position: absolute; top: 1px; width: 9px; height: 10px; background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAkAAAAKCAYAAABmBXS+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6OTA2NDlGQzlDODVDMTFFODgxOEZDMkMzN0Q1OUQ5OTEiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OTA2NDlGQ0FDODVDMTFFODgxOEZDMkMzN0Q1OUQ5OTEiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo5MDY0OUZDN0M4NUMxMUU4ODE4RkMyQzM3RDU5RDk5MSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo5MDY0OUZDOEM4NUMxMUU4ODE4RkMyQzM3RDU5RDk5MSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PhG6GaUAAACjSURBVHjahJAxDgIhEEWBeBSPoNehsuEKa62FvWzPXdySUJFQaU2yDbGwQZxv2ASSNVIw89+8EIBrrQv7szbYpJQ/BWMME2hKWT9s4ZBm7/2qVPkMae+ce6aUOgEZnNqdUErdc87DNE2dhAxO84eo7BpjvIUQvgEVGXy5EyP7TeVgrX3RkKEiV854+7JxHAfO+YnYkYRz90/NupCwRW3hR4ABAOmdWnwZN/JjAAAAAElFTkSuQmCC');"})
            var ruler_division_container = editor.dom.create('div');
            for (var i = 0; i < RULER_WIDTH; i++) {
                var ruler_text_line = editor.dom.create("span");
                var text = (i*50) + '';
                var ruler_text = editor.dom.create("span", null, text);
                ruler_text_line.setAttribute("style", ruler_text_line_style);
                ruler_text.setAttribute("style", ruler_text_style);
                ruler_text_line.appendChild(ruler_text);
                ruler_division_container.appendChild(ruler_text_line);

                for (var j = 0; j < 4; j++) {
                    var rooler_division_line = editor.dom.create("span");
                    rooler_division_line.setAttribute("style",ruler_division_line_style);
                    ruler_division_container.appendChild(rooler_division_line);
                }

                if (i == RULER_WIDTH - 1) {
                    ruler_text_line = editor.dom.create("span");
                    text = ((i+1)*50) + '';
                    ruler_text = editor.dom.create("span", null, text);
                    ruler_text_line.setAttribute("style", ruler_text_line_style);
                    ruler_text.setAttribute("style", ruler_text_style);
                    ruler_text_line.appendChild(ruler_text);
                    ruler_division_container.appendChild(ruler_text_line);
                }
            }

            ruler_body.appendChild(ruler_division_container);
            ruler_body.appendChild(ruler_body_left_disabled);
            ruler_body.appendChild(ruler_body_right_disabled);
            ruler_handler_left.appendChild(ruler_handler_both);
            ruler_body.appendChild(ruler_handler_left);
            ruler_body.appendChild(ruler_handler_right);
            ruler_body.appendChild(ruler_handler_indent);
            ruler_container.appendChild(ruler_body);


            _ruler_handler_left = ruler_handler_left;
            _ruler_handler_right = ruler_handler_right;
            _ruler_handler_indent = ruler_handler_indent;
            _ruler_handler_both = ruler_handler_both;
            _ruler_body_left_disabled = ruler_body_left_disabled;
            _ruler_body_right_disabled = ruler_body_right_disabled

            var editorHeaderEl = editor.dom.$.find(".tox-editor-header")[0];
            var anchorbarEl = editor.dom.$.find(".tox-anchorbar")[0];
            var divEl = editor.dom.create("div", { style: 'display: none; position: relative; width: 2500px; padding-left: 8px; border-bottom: 1px solid #cbcbcb;'});
            divEl.classList.add("tox-toolbar__primary");
            divEl.classList.add("covi_ruler_area");
            divEl.appendChild(ruler_container);
            _rulerArea = divEl;
            
            if (editorHeaderEl && anchorbarEl) {
                editorHeaderEl.insertBefore(_rulerArea, anchorbarEl);
            }
        }

        editor.addCommand('coviRuler', function() {
            _enableRuler = !_enableRuler;
            if (_enableRuler) {
                editor.dom.setStyle(_rulerArea, 'display', 'block');
                _docRect = editor.getDoc().documentElement.getBoundingClientRect();
                _rulerAreaLeft = 0;
                var blocks = editor.selection.getSelectedBlocks();
                if (blocks.length > 0) {
                    var selectedNode = blocks[0];
                    nodeChangeHandlerPosition(selectedNode);
                }
                checkScrollBarX();
            } else {
                editor.dom.setStyle(_rulerArea, 'display', 'none');
            }
        });

        editor.addCommand('coviRulerShow', function (ui, isShow) {
            if (_enableRuler) {
                if (isShow) {
                    editor.dom.setStyle(_rulerArea, 'display', 'block');
                } else {
                    editor.dom.setStyle(_rulerArea, 'display', 'none');
                }
            }
        })

        editor.ui.registry.addButton('coviruler', {
            tooltip: 'Ruler',
            icon: 'ruler',
            onAction: function() {
                return editor.execCommand('coviRuler');
            }
        });

        editor.ui.registry.addMenuItem('coviruler', {
            text: 'Ruler',
            icon: 'ruler',
            onAction: function () {
                return editor.execCommand('coviRuler');
            }
        });

        editor.on('init', function() {
            makeRulerToolbar();
            addEventListener();
        });

        editor.on('NodeChange', function (e) {
            if (_enableRuler && _ruler_handler_moving == false) {
                var selectedNode = e.element;
                var blocks = editor.selection.getSelectedBlocks();
                if (blocks.length > 0) {
                    selectedNode = blocks[0];
                }
                nodeChangeHandlerPosition(selectedNode);
            }
        });

        editor.on('ResizeWindow', function (e) {
            if (_enableRuler) {
                checkScrollBarX();
                if (!_isScrollBarX) {
                    _docRect = editor.getDoc().documentElement.getBoundingClientRect();
                    changeHandlerPosition();
                }
            }
        });

        editor.on('ScrollContent', function (e) {
            if (_enableRuler) {
                var docRect = editor.getDoc().documentElement.getBoundingClientRect();
                _rulerAreaLeft = docRect.left;
                editor.dom.setStyle(_rulerArea, 'left', docRect.left+'px');
            }
        });

    });
}());