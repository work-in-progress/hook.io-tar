Hook = require('hook.io').Hook
util = require 'util'
colors = require 'colors'
path = require 'path'
fs = require "fs"
spawn = require("child_process").spawn

require('pkginfo')(module,'version','hook')
  
Tar = exports.Tar = (options) ->
  self = @
  Hook.call self, options
  
  self.on "hook::ready", ->  
  
    self.on "tar::archive", (data)->
      self._archive(data)

    self.on "tar::unarchive", (data)->
      self._unarchive(data)
      
    for item in (self.archive || [])
      self.emit "tar::archive",
        source : item.source
        target : item.target

    for item in (self.unarchive || [])
      self.emit "tar::unarchive",
        source : item.source
        targetPath : item.targetPath
    
util.inherits Tar, Hook

Tar.prototype._runCommand = (cmd,args,eventName,data) ->

  zip = spawn(cmd,args)

  zip.stdout.on "data", (data) =>
    # NOTHING

  zip.stderr.on "data", (data) =>
    console.log "ERROR: #{data}"
  
  zip.on "exit", (code) =>
    if code != 0  
      data.code = code
      
      @emit "tar::error", data
    else    
      @emit eventName, data

Tar.prototype._archive = (data) ->
  console.log "Archiving #{data.source.length} files to #{data.target}".cyan

  params = [ "-cf", data.target ]
  params.push fileName for fileName in data.source

  data.target = path.normalize data.target
  @_runCommand "tar",params,"tar::archive-complete",data

      
Tar.prototype._unarchive = (data) ->
  console.log "Unarchiving for #{data.source}".cyan
  
  data.targetPath = path.normalize data.targetPath if data.TargetPath

  if data.targetPath
    @_runCommand "tar",[ "-xf", data.source, "-C",data.targetPath ],"tar::unarchive-complete",data    
  else
    @_runCommand "tar",[ "-xf", data.source ],"tar::unarchive-complete",data    
  
