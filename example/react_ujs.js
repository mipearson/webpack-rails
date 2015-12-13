// Adapted from the react-rails gem

'use strict';
var React = require('react');
var ReactDOM = require('react-dom');

var ReactRailsUJS = {
  CLASS_NAME_ATTR: 'data-react-class',
  PROPS_ATTR: 'data-react-props',
  // helper method for the mount and unmount methods to find the
  // `data-react-class` DOM elements
  findDOMNodes: function (searchSelector) {
    // we will use fully qualified paths as we do not bind the callbacks
    var selector;
    if (typeof searchSelector === 'undefined') {
      selector = '[' + this.CLASS_NAME_ATTR + ']';
    } else {
      selector = searchSelector + ' [' + this.CLASS_NAME_ATTR + ']';
    }

    return document.querySelectorAll(selector);
  },

  mountComponents: function (searchSelector) {
    var nodes = this.findDOMNodes(searchSelector);

    for (var i = 0; i < nodes.length; ++i) {
      var node = nodes[i];
      var className = node.getAttribute(this.CLASS_NAME_ATTR);

      // Assume className is simple and can be found at top-level (window).
      // Fallback to eval to handle cases like 'My.React.ComponentName'.
      var constructor = window[className] || eval.call(window, className);
      var propsJson = node.getAttribute(this.PROPS_ATTR);
      var props = propsJson && JSON.parse(propsJson);

      ReactDOM.render(React.createElement(constructor, props), node);
    }
  },

  unmountComponents: function (searchSelector) {
    var nodes = this.findDOMNodes(searchSelector);

    for (var i = 0; i < nodes.length; ++i) {
      var node = nodes[i];

      ReactDOM.unmountComponentAtNode(node);
    }
  },

  setOnloadHooks: function (on) {
    var oldOnload = on.onload;
    on.onload = function () {
      this.mountComponents();
      if (oldOnload) {
        oldOnload();
      }
    }.bind(this);

    var oldOnunload = on.onunload;
    on.onunload = function () {
      this.unmountComponents();
      if (oldOnunload) {
        oldOnunload();
      }
    }.bind(this);
  }
};

ReactRailsUJS.setOnloadHooks(window);
module.exports = ReactRailsUJS;
