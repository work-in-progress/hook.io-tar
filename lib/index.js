(function() {
  var Hook, Tar, colors, fs, path, spawn, util;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Hook = require('hook.io').Hook;
  util = require('util');
  colors = require('colors');
  path = require('path');
  fs = require("fs");
  spawn = require("child_process").spawn;
  require('pkginfo')(module, 'version', 'hook');
  Tar = exports.Tar = function(options) {
    var self;
    self = this;
    Hook.call(self, options);
    return self.on("hook::ready", function() {
      var item, _i, _j, _len, _len2, _ref, _ref2, _results;
      self.on("tar::archive", function(data) {
        return self._archive(data);
      });
      self.on("tar::unarchive", function(data) {
        return self._unarchive(data);
      });
      _ref = self.archive || [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        self.emit("tar::archive", {
          source: item.source,
          target: item.target
        });
      }
      _ref2 = self.unarchive || [];
      _results = [];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        item = _ref2[_j];
        _results.push(self.emit("tar::unarchive", {
          source: item.source,
          targetPath: item.targetPath
        }));
      }
      return _results;
    });
  };
  util.inherits(Tar, Hook);
  Tar.prototype._runCommand = function(cmd, args, eventName, data) {
    var zip;
    zip = spawn(cmd, args);
    zip.stdout.on("data", __bind(function(data) {}, this));
    zip.stderr.on("data", __bind(function(data) {
      return console.log("ERROR: " + data);
    }, this));
    return zip.on("exit", __bind(function(code) {
      if (code !== 0) {
        data.code = code;
        return this.emit("tar::error", data);
      } else {
        return this.emit(eventName, data);
      }
    }, this));
  };
  Tar.prototype._archive = function(data) {
    var fileName, params, _i, _len, _ref;
    console.log(("Archiving " + data.source.length + " files to " + data.target).cyan);
    params = ["-cf", data.target];
    _ref = data.source;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      fileName = _ref[_i];
      params.push(fileName);
    }
    data.target = path.normalize(data.target);
    return this._runCommand("tar", params, "tar::archive-complete", data);
  };
  Tar.prototype._unarchive = function(data) {
    console.log(("Unarchiving for " + data.source).cyan);
    if (data.TargetPath) {
      data.targetPath = path.normalize(data.targetPath);
    }
    if (data.targetPath) {
      return this._runCommand("tar", ["-xf", data.source, "-C", data.targetPath], "tar::unarchive-complete", data);
    } else {
      return this._runCommand("tar", ["-xf", data.source], "tar::unarchive-complete", data);
    }
  };
}).call(this);
