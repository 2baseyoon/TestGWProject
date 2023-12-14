(function () {
  'use strict';

  tinymce.PluginManager.add('covipaste', function(editor, url) {
    var _tempDoc = null;
    var _serializer = tinymce.util.Tools.resolve('tinymce.html.Serializer');
    var _parser = tinymce.util.Tools.resolve('tinymce.html.DomParser')({validate: true}, editor.schema);
    var _env = tinymce.util.Tools.resolve('tinymce.Env');
    var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
    var _delay = tinymce.util.Tools.resolve('tinymce.util.Delay');
    var _unwantedTagsExp = /<(\/)*(\\?xml:|meta|link|del|ins|st1:|[ovwmxp]:)((.|\s)*?)>/gi;
    var _commentsExp = /(<!--.*?-->)|(<!--[\w\W\n\s]+?-->)/gi;
    var _msoAttrExp1 = /s*mso-[^:]+:\s*?"[^;]+";?/gi;
    var _msoAttrExp2 = /s*mso-[^:]+:[^;"]+;?/gi;
    var _blankLineExp = /^\s*\n/gm;
    var _numClassExp = /[A-Za-z][.]\d/g;
    var _officeType = null;
    var _OFFICE_TYPE = {
      DOC: "Word",
      XLS: "Excel",
      PPT: "PowerPoint",
      HWP: "Hwp"
    }
    var _hexImageArray = [];
    var _rtfPictCtrlExp = {
      START: /\{\\pict[\s\S]+?/,
      TAG: /\\bliptag\-?\d+/,
      UNIT_PER_INCH: /(\\blipupi\-?\d+)?/,
      UID: /(\{\\\*\\blipuid\s?[\da-fA-F]+)?[\s\}]*?/
    }
    var _rtfPictType = {
      PNG: "image/png",
      JPEG: "image/jpeg"
    }
    var _localImagTagExp = /<img[^>]+file:\/\/[^>]+>/gi;
    var _internalMimeType = 'x-tinymce/html';

    var checkOfficeType = function(html) {
      _officeType = null;

      if (html.indexOf('<meta name=ProgId content=Word.Document>') > -1 || html.indexOf('<meta name=Generator content="Microsoft Word') > -1) {
        _officeType = _OFFICE_TYPE.DOC;
      } else if (html.indexOf('<meta name=ProgId content=Excel.Sheet>') > -1 || html.indexOf('<meta name=Generator content="Microsoft Excel') > -1) {
        _officeType = _OFFICE_TYPE.XLS;
      } else if ((html.indexOf('<meta name=ProgId content=PowerPoint.Slide>') > -1 || html.indexOf('<meta name=Generator content="Microsoft PowerPoint') > -1) ||
          (html.indexOf('xmlns:m="http://schemas.microsoft.com/office') > -1 && html.indexOf('mso-'))) {
        _officeType = _OFFICE_TYPE.PPT;
      } else if (html.indexOf('<!--[data-hwpjson]') > -1 || html.indexOf('{behavior:url(#default#vml);}') > -1  || html.indexOf('{behavior:url(#default#VML);}') > -1) {
        _officeType = _OFFICE_TYPE.HWP;
      }
    }

    var getRtfPicType = function(hexPicture) {
      return hexPicture.indexOf("\\pngblip") > -1 ? _rtfPictType.PNG : (hexPicture.indexOf("\\jpegblip") > -1 ? _rtfPictType.JPEG : null);
    }

    var initHexImageArray = function(rtfData) {
      _hexImageArray = [];

      if (!rtfData || rtfData.length <= 0) {
        return;
      }

      var hexPictureHeaderPattern = new RegExp(_rtfPictCtrlExp.START.source + _rtfPictCtrlExp.TAG.source + _rtfPictCtrlExp.UNIT_PER_INCH.source + _rtfPictCtrlExp.UID.source);
      var hexPictureAllPattern = new RegExp("(?:(" + hexPictureHeaderPattern.source + "))([\\da-fA-F\\s]+)\\}","g");
      var hexPictureList = rtfData.match(hexPictureAllPattern);

      if (hexPictureList) {
        for (var i = 0; i < hexPictureList.length; i++) {
          var type = null;

          if (hexPictureHeaderPattern.test(hexPictureList[i])) {
            type = getRtfPicType(hexPictureList[i]);
          }

          if (type !== null) {
            _hexImageArray.push({
              data: type ? hexPictureList[i].replace(hexPictureHeaderPattern, "").replace(/[^\da-fA-F]/g, "") : null,
              type: type
            });
          }
        }
      }
    }

    // prevent bookmark symbol appear
    var preventBookmarkSymbol = function(rootNode) {
      var anchors = rootNode.getAll('a');

      for (var i = 0; i < anchors.length; i++) {
        if (!anchors[i].attr('href')) {
          anchors[i].attr('href', "#");
        }
      }
    }

    var processTextStyle = function(rootNode) {
      var textNodes = rootNode.getAll('#text');
      var styleParser = new tinymce.html.Styles();
      var STYLE_TYPE = {
        BOLD: 0,
        ITALIC: 1,
        UNDERLINE: 2
      }

      var applyParentStyle = function(node, type) {
        var parentNode = node.parent;

        while (parentNode) {
          var parentStyles = styleParser.parse(parentNode.attr('style'));

          if (type === STYLE_TYPE.BOLD) {
            if (parentStyles['font-weight'] && (parentStyles['font-weight'] === 'bold' || parentStyles['font-weight'] === '700')) {
              parentStyles['font-weight'] = undefined;
              node.wrap(new tinymce.html.Node('strong', 1));
              parentNode.attr('style', styleParser.serialize(parentStyles));
              break;
            }
            break;
          } else if (type === STYLE_TYPE.ITALIC) {
            if (parentStyles['font-style'] && (parentStyles['font-style'] === 'italic' || parentStyles['font-style'] === 'oblique')) {
              parentStyles['font-style'] = undefined;
              node.wrap(new tinymce.html.Node('em', 1));
              parentNode.attr('style', styleParser.serialize(parentStyles));
              break;
            }
          } else if (type === STYLE_TYPE.UNDERLINE) {
            if (parentStyles['text-decoration'] && parentStyles['text-decoration'].indexOf('underline') > -1) {
              var spanNode = new tinymce.html.Node('span', 1);

              spanNode.attr('style', 'text-decoration: underline');
              parentStyles['text-decoration'] = parentStyles['text-decoration'].replace('underline', '').trim();
              parentStyles['text-decoration'] = parentStyles['text-decoration'].length === 0 ? undefined : parentStyles['text-decoration'];
              node.wrap(spanNode);
              parentNode.attr('style', styleParser.serialize(parentStyles));
              break;
            }
          }

          parentNode = parentNode.parent;
        }
      }

      for (var i = 0; i < textNodes.length; i++) {
        var node = textNodes[i];

        applyParentStyle(node, STYLE_TYPE.BOLD);
        applyParentStyle(node, STYLE_TYPE.ITALIC);
        applyParentStyle(node, STYLE_TYPE.UNDERLINE);
      }
    }

    var genId = function() {
      return 'blobid' + (new Date()).getTime();
    }

    var pasteImage = function(image, size) {
      var reader = new FileReader();
      reader.onload = function (e) {
        var url = e.target.result;
        var imageData = /data:([^;]+);base64,([a-z0-9\+\/=]+)/i.exec(url);

        if (imageData) {
          var blobCache = editor.editorUpload.blobCache;
          var blobInfo = null;
          var id = genId();

          blobInfo = blobCache.create(id, image, imageData[2], id);
          blobCache.add(blobInfo);

          if (size) {
            editor.insertContent('<img src="' + blobInfo.blobUri() + '" width="' + size.width + '" height="' + size.height + '">');
          } else {
            editor.insertContent('<img src="' + blobInfo.blobUri() + '">');
          }
        }
      };
      reader.readAsDataURL(image);
    }

    function pasteHtmlOrImageDlg(image, html, imgSize) {
      var initData = {
        imageData: image,
        imageSize: imgSize,
        htmlData: html
      };

      var innerHTML = '<div style="font-size: 14px">' +
                     '<div style="width: 200px; padding: 10px">' +
                     '<input type="radio" id="html" name="pasteType" value="html" style="padding: 5px; margin-top: -1px; vertical-align: middle" checked>' +
                     '<label style="padding: 5px">' + tinymce.util.I18n.translate("paste as html") + '</label>' +
                     '</div>' +
                     '<div style="padding: 10px">' +
                     '<input type="radio" id="image" name="pasteType" value="image" style="padding: 5px; margin-top: -1px; vertical-align: middle">' +
                     '<label style="padding: 5px">'+ tinymce.util.I18n.translate("paste as image") + '</label>' +
                     '<fieldset style="margin-left: 20px; padding: 0 10px 10px 10px; border: 1px solid #ccc;">' +
                     '<legend style="padding: 5px">' + tinymce.util.I18n.translate("Size") + '</legend>' +
                     '<div style="float: left"><label>' + tinymce.util.I18n.translate("image width") + '</label>' +
                     '<input type="number" id="covi_img_width" value="'+initData.imageSize.width+'" style="width: 100px; border: 1px solid #ccc; margin: 5px; padding: 3px"></div>' +
                     '<div style="float: left; margin-left: 10px"><label>' + tinymce.util.I18n.translate("Height") + '</label>' +
                     '<input type="number" id="covi_img_height" value="'+initData.imageSize.height+'" style="width: 100px; border: 1px solid #ccc; margin: 5px; padding: 3px"></div>' +
                     '</fieldset>'+
                     '</div>' +
                     '</div>'

      return {
        title: 'paste method',
        body: {
          type: 'panel',
          items: [{
            type: 'bar',
            items: [{
              name: 'pasteImage',
              type: 'htmlpanel',
              html: innerHTML
            }]
          }]
        },
        initialData: initData,
        onSubmit: function(api) {
          var value = document.querySelector('input[name=pasteType]:checked').value;

          if (value === 'html') {
            doPasteHTML(initData.htmlData);
          } else if (value === 'image') {
            var width = document.getElementById('covi_img_width').value;
            var height = document.getElementById('covi_img_height').value;
            pasteImage(initData.imageData, {width, height});
          }

          api.close();
        },
        buttons: [{
          type: 'submit',
          text: 'ok',
          name: 'ok'
        }]
      };
    }

    var openPopup = function (image, html) {
      var img = new Image();
      var url = window.URL.createObjectURL(image);

      img.onload = function () {
        var imgSize = {width: img.width, height: img.height}
        editor.windowManager.open(pasteHtmlOrImageDlg(image, html, imgSize));
      }
      img.onerror = function () {
        doPasteHTML(html);
      }
      img.src = url;
    }

    var _parseHTML = function(html) {
      var _parser = tinymce.util.Tools.resolve('tinymce.html.DomParser')({validate: true}, editor.schema);
      _parser.addNodeFilter('img', function(nodes) {
        for (var i = 0; i < nodes.length; i++) {
          var node = nodes[i];
          var src = node.attr('src');
          var dataMceSrc = node.attr('data-mce-src');
          if (src != undefined && dataMceSrc != undefined) {
            if (src !== dataMceSrc) {
              node.attr('data-mce-src', src);
            }
          }
        }
      })

      var rootNode = _parser.parse(html, {
        forced_root_block: false,
        isRootContent: true
      });

      preventBookmarkSymbol(rootNode);
      processTextStyle(rootNode);

      return _serializer({ validate: editor.getParam('validate') }, editor.schema).serialize(rootNode);
    }

    var doPasteHTML = function(html) {
      var cssRules = null;
      var parser = tinymce.util.Tools.resolve('tinymce.html.DomParser')({validate: true}, editor.schema);

      var parseHTML = function(html) {
        var rootNode = parser.parse(html, {
          forced_root_block: false,
          isRootContent: true
        });

        preventBookmarkSymbol(rootNode);
        processTextStyle(rootNode);

        return _serializer({ validate: editor.getParam('validate') }, editor.schema).serialize(rootNode);
      }

      var getTempDoc = function() {
        if (!_tempDoc) {
          var iframe = document.createElement("IFRAME");
          iframe.style.display = "none",
              document.body.appendChild(iframe);
          var doc = iframe.contentWindow.document;
          doc.open();
          doc.write("<html><head></head><body></body></html>");
          doc.close();
          _tempDoc = doc;
        }

        return _tempDoc;
      }

      var extractCSSStyleRule = function(styleRules) {
        var cssStyleRule = {};

        for (var i = 0; i < styleRules.length; i++) {
          if (styleRules[i].type == CSSRule.STYLE_RULE) {
            cssStyleRule[styleRules[i].selectorText.replaceAll('.covieditor', '.')] = styleRules[i].style;
          }
        }

        return cssStyleRule;
      }

      var getCSSRule = function(selector) {
        if (cssRules == null) {
          return null;
        }

        if (cssRules[selector]) {
          return cssRules[selector];
        } else {
          var pattern1 = new RegExp("\\." + selector + "\\b\\s*(,)");
          var pattern2 = new RegExp("\\." + selector + "$");

          for (var key in cssRules) {
            if (pattern1.test(key) || pattern2.test(key)) {
              return cssRules[key];
            }
          }
        }
        return null;
      }

      var hasImportant = function(cssText) {
        return cssText.replace(/\s/g,'').indexOf("!important") > -1;
      }

      // check style overwrite condition
      var isOverwrite = function(style1, style2) {
        var isOverwrite = false;

        // if (style1 == 'none' && style2 != 'none') {
        //   isOverwrite = true;
        // }

        // if (style1 == 'initial' && (style2 != 'none' && style2 != 'initial')) {
        //   isOverwrite = true;
        // }

        if (!hasImportant(style1) && hasImportant(style2)) {
          isOverwrite = true;
        }

        return isOverwrite;
      }

      // merge class style to inline style
      var mergeStylesToInline = function(node, cssRule) {
        var tempEl = document.createElement('div');
        tempEl.style.cssText = node.attr('style');

        for (var i = 0; i < cssRule.length; i++) {
          var styleName = cssRule[i];

          if (tempEl.style[styleName]) {
            if (isOverwrite(tempEl.style[styleName], cssRule[styleName])) {
              tempEl.style[styleName] = cssRule[styleName];
            }
          } else {
            tempEl.style[styleName] = cssRule[styleName];
          }
        }
        node.attr('style', tempEl.style.cssText);
        tempEl.remove();
      }

      // merge tag style to class style
      var mergeStylesToClassStyle = function(tagRule, classRule) {
        for (var i = 0; i < tagRule.length; i++) {
          var styleName = tagRule[i];

          if (classRule[styleName]) {
            if (isOverwrite(classRule[styleName], tagRule[styleName])) {
              classRule[styleName] = tagRule[styleName];
            }
          } else {
            classRule[styleName] = tagRule[styleName];
          }
        }
      }

      var cleanMSOfficeHtml = function(html) {
        // remove MS office tags
        html = html.replace(_unwantedTagsExp, '');

        // remove multiline comments
        html = html.replace(_commentsExp, '');

        // remove blank lines
        html = html.replace(_blankLineExp, '');

        return html.trim();
      }

      var cleanHwpHtml = function (html) {
        var a = /<!-- \[if gte vml 1\]>/gi;
        var b = /<!-- \[if !supportEmptyParas\]>&nbsp;<!\[endif\]-->/gi;
        var c = /<!\[endif\]>/gi;
        var d = /<!\[endif\]--> <!-- \[if !vml\]>/gi;
        var e = /<!\[endif\]-->/gi;

        html = html.replace(a, '');
        html = html.replace(b, '');
        html = html.replace(c, '');
        html = html.replace(d, '');
        html = html.replace(e, '');

        html = html.replace(_localImagTagExp, "");

        return html.trim();
      }

      var removeParsingErrorPhrase = function (html) {
        var err1 = /\s[가-힝]+=""\s*"[,;:]=""\s*([a-z0-9-.()]+[,;:]?=""\s*)*"=""/gi;
        html = html.replace(err1, '');

        return html.trim();
      }

      var hex2Bytes = function(hexStr) {
        if (!hexStr) {
          return null;
        }

        var byteArray = [];

        for (var i = 0, len = hexStr.length; i < len; i+=2) {
          byteArray.push(parseInt(hexStr.substr(i, 2), 16));
        }

        return byteArray;
      }

      // Converts an ArrayBuffer directly to base64, without any intermediate 'convert to string then
      // use window.btoa' step. According to my tests, this appears to be a faster approach:
      // http://jsperf.com/encoding-xhr-image-data/5

      /*
      MIT LICENSE
      Copyright 2011 Jon Leighton
      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
      */
      var bytes2Base64 = function(arrayBuffer) {
        var base64    = ''
        var encodings = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

        var bytes         = new Uint8Array(arrayBuffer)
        var byteLength    = bytes.byteLength
        var byteRemainder = byteLength % 3
        var mainLength    = byteLength - byteRemainder

        var a, b, c, d
        var chunk

        // Main loop deals with bytes in chunks of 3
        for (var i = 0; i < mainLength; i = i + 3) {
          // Combine the three bytes into a single integer
          chunk = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]

          // Use bitmasks to extract 6-bit segments from the triplet
          a = (chunk & 16515072) >> 18 // 16515072 = (2^6 - 1) << 18
          b = (chunk & 258048)   >> 12 // 258048   = (2^6 - 1) << 12
          c = (chunk & 4032)     >>  6 // 4032     = (2^6 - 1) << 6
          d = chunk & 63               // 63       = 2^6 - 1

          // Convert the raw binary segments to the appropriate ASCII encoding
          base64 += encodings[a] + encodings[b] + encodings[c] + encodings[d]
        }

        // Deal with the remaining bytes and padding
        if (byteRemainder == 1) {
          chunk = bytes[mainLength]

          a = (chunk & 252) >> 2 // 252 = (2^6 - 1) << 2

          // Set the 4 least significant bits to zero
          b = (chunk & 3)   << 4 // 3   = 2^2 - 1

          base64 += encodings[a] + encodings[b] + '=='
        } else if (byteRemainder == 2) {
          chunk = (bytes[mainLength] << 8) | bytes[mainLength + 1]

          a = (chunk & 64512) >> 10 // 64512 = (2^6 - 1) << 10
          b = (chunk & 1008)  >>  4 // 1008  = (2^6 - 1) << 4

          // Set the 2 least significant bits to zero
          c = (chunk & 15)    <<  2 // 15    = 2^4 - 1

          base64 += encodings[a] + encodings[b] + encodings[c] + '='
        }

        return base64;
      }

      var replaceLocalImageTag = function(localImgageTagList) {
        if (_hexImageArray.length == localImgageTagList.length) {
          for (var i = 0; i < localImgageTagList.length; i++) {
            var byteArray = hex2Bytes(_hexImageArray[i].data);
            var base64 = bytes2Base64(byteArray);
            var imageSrcPattern = /<img[^>]*src=["']?([^>"']+)["']?[^>]*>/;

            if (imageSrcPattern.test(localImgageTagList[i])) {
              var newImageTag = localImgageTagList[i].replace(RegExp.$1, "data:" + _hexImageArray[i].type + ";base64," + base64);
              html = html.replace(localImgageTagList[i], newImageTag);
            }
          }
        }
      }

      var adjustTableStyle = function(node) {
        var widthAttr = node.attr('width');
        var heightAttr = node.attr('height');
        var styleParser = new tinymce.html.Styles();
        var isNumOnly = function(num) {
          return /^\d+$/.test(num);
        }

        var convertPt2Px = function(style) {
          if (style.indexOf('pt') > -1) {
            style = Math.round(4 * parseFloat(style) / 3);
            style = style === 0 ? 1 : style;
            style = style + 'px';
          }
          return style;
        }

        var tableStyles = styleParser.parse(node.attr('style'));

        if (_officeType === _OFFICE_TYPE.HWP) {
          if (node.name === 'table') {
            if (tableStyles['table-layout'] && tableStyles['table-layout'].length > 0) {
              tableStyles['table-layout'] = null;
            }
          }
        }

        if (widthAttr && widthAttr.length > 0) {
          tableStyles['width'] = isNumOnly(widthAttr) ? (widthAttr + 'px') : widthAttr;
          node.attr('width', null);
        } else {
          if (_officeType === _OFFICE_TYPE.HWP) {
            if (tableStyles['width'] && tableStyles['width'].length > 0) {
              widthAttr = tableStyles['width'];
              tableStyles['width'] = isNumOnly(widthAttr) ? (widthAttr + 'px') : convertPt2Px(widthAttr);
            }
          }
        }
        if (heightAttr && heightAttr.length > 0) {
          tableStyles['height'] = isNumOnly(heightAttr) ? (heightAttr + 'px') : heightAttr;
          node.attr('height', null);
        } else {
          if (_officeType === _OFFICE_TYPE.HWP) {
            if (tableStyles['height'] && tableStyles['height'].length > 0) {
              heightAttr = tableStyles['height'];
              tableStyles['height'] = isNumOnly(heightAttr) ? (heightAttr + 'px') : convertPt2Px(heightAttr);
            }
          }
        }

        node.attr('style', styleParser.serialize(tableStyles));
      };

      var extractStyleRules = function(html) {
		var styleExp = /<style[^>]*>((\n|\r|.)*?)<\/style>/gmi;
        var headExp = /<head[^>]*>((\n|\r|.)*?)<\/head>/gmi;
        var styles = null, temp = null;

        while((temp = styleExp.exec(html)) !== null) {
          styles = temp;

          if (styles.length >= 2) {
			var tempDoc = getTempDoc();
          	var head = tempDoc.getElementsByTagName("HEAD")[0];
          	var style = tempDoc.createElement("STYLE");

          	style.innerHTML = styles[1].replaceAll('hairline', 'dotted')
            style.innerHTML = style.innerHTML.replace(_numClassExp, function (numClass) {
              return numClass.replace('.', '.covieditor')
            });
            head.appendChild(style);
            // cssRules = extractCSSStyleRule(style.sheet.cssRules);
            if (cssRules == null) {
				cssRules = extractCSSStyleRule(style.sheet.cssRules);
			} else {
				Object.assign(cssRules, extractCSSStyleRule(style.sheet.cssRules))
			}
			style.parentNode.removeChild(style);

			// html = html.replace(styleExp, '');
            // html = html.replace(headExp, '');
            
          }
        }
		html = html.replace(styleExp, '');
		html = html.replace(headExp, '');
		
		return html;
        
      };

		var unwrapBody = function(html) {
        var result = html;
        var bodyExp = /<body[^>]*>((\n|\r|.)*?)<\/body>/gmi;

        var matched = bodyExp.exec(html);

        if (matched && matched.length >= 2) {
          result = matched[1];
		}
		
		return result;
	};
	
	// extract style rules from "<style> ... </style>"
	  // parser.addNodeFilter('style', function(nodes) {
	  //   for (var i = 0; i < nodes.length; i++) {
	  //     var tempDoc = getTempDoc();
	  //     var head = tempDoc.getElementsByTagName("HEAD")[0];
	  //     var style = tempDoc.createElement("STYLE");
	  //
	  //     if (nodes[i].firstChild && nodes[i].firstChild.value) {
	  //       style.innerHTML = nodes[i].firstChild.value.replaceAll('hairline', 'dotted')
	  //       style.innerHTML = style.innerHTML.replace(_numClassExp, function (numClass) {
	  //         return numClass.replace('.', '.covieditor')
	  //       });
	  //       head.appendChild(style);
	  //       cssRules = extractCSSStyleRule(style.sheet.cssRules);
	  //       style.parentNode.removeChild(style);
	  //
	  //       if (nodes[i].parent.name === 'head') {
	  //         nodes[i].parent.remove();
	  //       } else {
	  //         nodes[i].remove();
	  //       }
	  //     }
	  //   }
	  // });

      // apply tag styles
		parser.addNodeFilter('style', function(nodes) {
          var addDummyAfterLastTable = function() {
            var hasNextSibling = false;
            var nextNode = node.next;

            while(nextNode) {
              if (nextNode.type === 1 || nextNode.type === 3) {
                hasNextSibling = true;
                break;
              }

              nextNode = nextNode.next;
            }

            if (!hasNextSibling) {
              var dummyNode = new tinymce.html.Node('p', 1);
              node.parent.append(dummyNode);
            }
          }

        for (var i = 0; i < nodes.length; i++) {
          var node = nodes[i];

          if (!node.attr('class') || (getCSSRule(node.attr('class')) == null)) {
            var css = cssRules ? getCSSRule(node.name) : null;

            if (css) {
              if (node.attr('style')) {
                mergeStylesToInline(node, css);
              } else {
                node.attr('style', css.cssText);
              }
            }
          }

          if (node.name === 'table' || node.name === 'td') {
            adjustTableStyle(node);

              if (node.name === 'table') {
                addDummyAfterLastTable();
              }

          }
        }
      });

      // parser.addNodeFilter('body', function(nodes) {
      //   _tool.each(nodes, function(node) { node.unwrap(); });
      // });

      // apply class style
      parser.addAttributeFilter('class', function(nodes, name) {
        for (var i = 0; i < nodes.length; i++) {
          var node = nodes[i];
          var value = node.attr('class');

          if (value) {
            var css = cssRules ? getCSSRule(value) : null;

            if (css) {
              if (getCSSRule(node.name)) {
                var tagRule = getCSSRule(node.name);
                mergeStylesToClassStyle(tagRule, css);
              }

              if (node.attr('style')) {
                mergeStylesToInline(node, css);
              } else {
                node.attr('style', css.cssText);
              }
            }

            node.attr('class', null);
          }
        }
      });

      // remove "mso-xxx" properties
      parser.addAttributeFilter('style', function(nodes, name) {
        var styleParser = new tinymce.html.Styles();
        var convertPt2Px = function(styles) {
          var borderStyles = _tool.grep(Object.keys(styles), function(obj) { return obj.indexOf('border') > -1; } );

          _tool.each(borderStyles, function(styleName) {
            if (styles[styleName].indexOf('pt') > -1) {
              var props = styles[styleName].split(' ');

              for (var i = 0; i < props.length; i++) {
                if (props[i].indexOf('pt') > -1) {
                  var styleValue = Math.round(4 * parseFloat(props[i]) / 3);
                  if (styleValue === 0) {
                    styleValue = 1;
                  }
                  props[i] = styleValue + 'px';
                }
              }
              styles[styleName] = props.join(' ');
            }
          });
        }
        var procSpan = function (node, styles) {
          if (node.name === 'p' && node.parent.name === 'td' && node.firstChild.name === 'span') {
            if (styles && styles['font-size'] === undefined) {
              var spanStyle = styleParser.parse(node.firstChild.attr('style'));
              if (spanStyle && spanStyle['font-size']) {
                styles['font-size'] = spanStyle['font-size'];
              }
            }
          }
        }

        for (var i = 0; i < nodes.length; i++) {
          var node = nodes[i];
          var value = node.attr('style');

          value = value.replace(_msoAttrExp1, '');
          value = value.replace(_msoAttrExp2, '');

          var styles = styleParser.parse(value);
          convertPt2Px(styles);
          // for table td height modification when pasting table in power point
          if (_officeType == _OFFICE_TYPE.PPT) {
            procSpan(node, styles);
          }
		  node.attr('style', styleParser.serialize(styles));
        }
      });

      var localImageTagList = html.match(_localImagTagExp);

      if (localImageTagList) {
        replaceLocalImageTag(localImageTagList);
      }

      if (_officeType == _OFFICE_TYPE.XLS) {
        var colLen = html.indexOf("<col ");
        if (colLen > -1) {
          html = html.slice(0, colLen) + "\n<colgroup>\n" + html.slice(colLen, html.length + 1);
        }
      }

      if (_officeType == _OFFICE_TYPE.HWP) {
        html = cleanHwpHtml(html);
      }

      html = removeParsingErrorPhrase(html);

	  html = extractStyleRules(html);

	  html = parseHTML(html);
      
	  html = unwrapBody(html);

	  html = cleanMSOfficeHtml(html);

      editor.insertContent(html, {paste: true});
    };

    var doPasteText = function(text) {
      var nbsp = '\xA0';
      var serializer = tinymce.util.Tools.resolve('tinymce.html.Serializer');
      var domParser = tinymce.util.Tools.resolve('tinymce.html.DomParser');
      var entities = tinymce.util.Tools.resolve('tinymce.html.Entities');
      var tools = tinymce.util.Tools.resolve('tinymce.util.Tools');

      var isCollapsibleWhitespace = function (c) {
        return ' \f\t\x0B'.indexOf(c) !== -1;
      };
      var isNewLineChar = function (c) {
        return c === '\n' || c === '\r';
      };
      var isNewline = function (text, idx) {
        return idx < text.length && idx >= 0 ? isNewLineChar(text[idx]) : false;
      };
      var getForcedRootBlock = function () {
        return editor.getParam('forced_root_block');
      };
      var getForcedRootBlockAttrs = function () {
        return editor.getParam('forced_root_block_attrs');
      };
      var getValidate = function () {
        return editor.getParam('validate');
      };
      var getTabSpaces = function () {
        return editor.getParam('paste_tab_spaces', 4, 'number');
      };

      var hasOwnProperty = Object.hasOwnProperty;
      var has = function (obj, key) {
        return hasOwnProperty.call(obj, key);
      };
      var toBRs = function (text) {
        return text.replace(/\r?\n/g, '<br>');
      };
      var openContainer = function (rootTag, rootAttrs) {
        var attrs = [];
        var tag = '<' + rootTag;
        if (typeof rootAttrs === 'object') {
          for (var key in rootAttrs) {
            if (has(rootAttrs, key)) {
              attrs.push(key + '="' + entities.encodeAllRaw(rootAttrs[key]) + '"');
            }
          }
          if (attrs.length) {
            tag += ' ' + attrs.join(' ');
          }
        }
        return tag + '>';
      };
      var toBlockElements = function (text, rootTag, rootAttrs) {
        var blocks = text.split(/\n\n/);
        var tagOpen = openContainer(rootTag, rootAttrs);
        var tagClose = '</' + rootTag + '>';
        var paragraphs = tools.map(blocks, function (p) {
          return p.split(/\n/).join('<br />');
        });
        var stitch = function (p) {
          return tagOpen + p + tagClose;
        };
        return paragraphs.length === 1 ? paragraphs[0] : tools.map(paragraphs, stitch).join('');
      };
      var convert = function (text, rootTag, rootAttrs) {
        return rootTag ? toBlockElements(text, rootTag === true ? 'p' : rootTag, rootAttrs) : toBRs(text);
      };

      var each = function (xs, f) {
        for (var i = 0, len = xs.length; i < len; i++) {
          var x = xs[i];
          f(x, i);
        }
      };
      var foldl = function (xs, f, acc) {
        each(xs, function (x, i) {
          acc = f(acc, x, i);
        });
        return acc;
      };
      var repeat = function (s, count) {
        return count <= 0 ? '' : new Array(count + 1).join(s);
      };
      var preProcess = function (html) {
        var parser = domParser({}, editor.schema);
        parser.addNodeFilter('meta', function (nodes) {
          tools.each(nodes, function (node) {
            node.remove();
          });
        });
        var fragment = parser.parse(html, {
          forced_root_block: false,
          isRootContent: true
        });
        return serializer({ validate: getValidate() }, editor.schema).serialize(fragment);
      };

      var normalizeWhitespace = function (text) {
        var tabSpace = repeat(' ', getTabSpaces());
        var normalizedText = text.replace(/\t/g, tabSpace);
        var result = foldl(normalizedText, function (acc, c) {
          if (isCollapsibleWhitespace(c) || c === nbsp) {
            if (acc.pcIsSpace || acc.str === '' || acc.str.length === normalizedText.length - 1 || isNewline(normalizedText, acc.str.length + 1)) {
              return {
                pcIsSpace: false,
                str: acc.str + nbsp
              };
            } else {
              return {
                pcIsSpace: true,
                str: acc.str + ' '
              };
            }
          } else {
            return {
              pcIsSpace: isNewLineChar(c),
              str: acc.str + c
            };
          }
        }, {
          pcIsSpace: false,
          str: ''
        });
        return result.str;
      };

      var encodedText = editor.dom.encode(text).replace(/\r\n/g, '\n');
      var normalizedText = normalizeWhitespace(encodedText);
      var html = convert(normalizedText, getForcedRootBlock(), getForcedRootBlockAttrs());
      html = preProcess(html);
      editor.insertContent(html, {paste: true});
    };

    editor.on('copy', function(e) {
      var blocks = editor.selection.getSelectedBlocks();
      var removeTableHeight = function(html) {
        var parser = tinymce.util.Tools.resolve('tinymce.html.DomParser')({validate: true}, editor.schema);

        parser.addNodeFilter('table', function(nodes) {
          for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i];
            var style = node.attr('style');

            if (style) {
              style = style.replace(/\s*height:[^;"]+;?/g, '');
              node.attr('style', style);
              style = style.replace(/\s*width:[^;"]+;?/g, '');
              node.attr('style', style);
            }
          }
        });

        var rootNode = parser.parse(html);

        return _serializer({ validate: editor.getParam('validate') }, editor.schema).serialize(rootNode);
      };

      if (blocks.length) {
        var tableEl = editor.dom.getParent(blocks[0], 'table', editor.dom.getRoot());

        if (tableEl) {
          if (!_env.iOS && (e.clipboardData && (typeof e.clipboardData.setData === "function"))) {
            var selTableHtml = editor.selection.getContent({format: 'raw', contextual: true});
            var selTableText = editor.selection.getContent({format: 'text'});

            selTableHtml = removeTableHeight(selTableHtml);

            try {
              e.clipboardData.clearData();
              e.clipboardData.setData('text/html', selTableHtml);
              e.clipboardData.setData('text/plain', selTableText);
              e.clipboardData.setData(_internalMimeType, selTableHtml);
              e.preventDefault();
            } catch(e) {
            	coviCmn.traceLog("Failed to set table html to clipboard");
            }
          } else {
            var selTableHtml = '<!-- ' + _internalMimeType + ' -->' + editor.selection.getContent({format: 'raw', contextual: true});
            selTableHtml = removeTableHeight(selTableHtml);

            var bogusEl = editor.dom.create('div', {
              'contenteditable': 'false',
              'data-mce-bogus': 'all'
            });
            var selTableEl = editor.dom.create('div', { contenteditable: 'true' }, selTableHtml);
            var invisibleStyle = {
              position: 'fixed',
              top: '-1000px',
              left: '-4000px',
              width: '999em',
              overflow: 'hidden'
            }

            editor.dom.setStyles(bogusEl, invisibleStyle);
            bogusEl.appendChild(selTableEl);
            editor.dom.add(editor.getBody(), bogusEl);
            var backupRange = editor.selection.getRng();
            selTableEl.focus();

            var copyRange = editor.dom.createRng();
            copyRange.selectNodeContents(selTableEl);
            editor.selection.setRng(copyRange);

            _delay.setTimeout(function () {
              editor.selection.setRng(backupRange);
              bogusEl.parentNode.removeChild(bogusEl);
            }, 0);
          }
        }
      }
    });

    editor.on('paste', function(e) {
      if (!_env.ie) {
        initHexImageArray(e.clipboardData.getData("text/rtf"));

        if (e.clipboardData.types.indexOf("text/html") > -1) {
          var html = e.clipboardData.getData("text/html");
		  var files = e.clipboardData.files;

          if (html && html.length > 0) {
            checkOfficeType(html);

            if (_officeType) {
              e.preventDefault();
              if (files != null && files.length > 0) {
                openPopup(files[0], html);
              } else {
	              doPasteHTML(html);
              }
            } else {
			  var hasImageSrc = /<img[^>]*src=["']?([^>"']+)["']?[^>]*style=["']?outline[^>]*>/;
				
              if ( !hasImageSrc.test(html) && editor.selection.getNode().nodeName.toLowerCase() !== 'li') {
                e.preventDefault();

                // _parser.addNodeFilter('meta', function(nodes) {
                //   _tool.each(nodes, function (node) {
                //     node.remove();
                //   });
                // });
				var metaExp = /<meta[^>]*>((\n|\r|.)*?)<\/meta>/gmi;
				
				html = html.replaceAll(metaExp, '');
                html = _parseHTML(html);
                editor.insertContent(html, {paste: true});
              }
            }
          }
        } else if (e.clipboardData.types.indexOf("text/plain") > -1) {
          var isPlainText = function (text) {
            return !/<(?:\/?(?!(?:div|p|br|span)>)\w+|(?:(?!(?:span style="white-space:\s?pre;?">)|br\s?\/>))\w+\s[^>]+)>/i.test(text);
          };
          var text = e.clipboardData.getData("text/plain")
          if (text && text.length > 0 && isPlainText(text)) {
            e.preventDefault()
            doPasteText(text)
          }
        }
      }
    });

    editor.on('drop', function(e) {
      if (!e.dataTransfer) {
        return;
      }

      var data = e.dataTransfer.files;
      var images = [];

      for (var i = 0; i < data.length; i++) {
        if (data[i].type.match('^image/')) {
          images.push(data[i]);
        }
      }

      if (images.length > 0) {
        e.stopPropagation();
        e.preventDefault();

        for (var i = 0; i < images.length; i++) {
          pasteImage(images[i]);
        }
      }
    });

    editor.ui.registry.addMenuItem('covipaste', {
      text: 'paste',
      icon: 'paste',
      onAction: function() {

      }
    });

    return {
      getMetadata: function () {
        return  {
          name: 'Paste',
          url: 'https://www.covision.co.kr/'
        };
      }
    };
  });
}());