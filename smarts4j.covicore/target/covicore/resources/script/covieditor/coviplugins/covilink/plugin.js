(function () {
    'use strict';

    tinymce.PluginManager.add('covilink', function(editor, url) {

        function isLink(elem) {
              return editor.dom.getParent(elem, "a[href]");
        }

        editor.ui.registry.addContextMenu('covilink', {
            update: function(element) {
                return (isLink(element) && !element.classList.contains('covi-insert-file')) ? 'link unlink openlink' : '';
            }
        });

        return {
        };
    });
}());