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
        target : item.target
    
util.inherits Tar, Hook

Tar.prototype._runCommand = (cmd,args,eventName,data) ->
  fd = fs.openSync data.target, "w", 0644

  zip = spawn(cmd,args)

  zip.stdout.on "data", (data) =>
    fs.writeSync fd, data, 0, data.length, null

  zip.stderr.on "data", (data) =>
    console.log "ERROR: #{data}"
  
  zip.on "exit", (code) =>
    fs.closeSync fd

    #console.log "EXIT #{code}"
    if code != 0  
      try
        fs.unlinkSync data.target  # cleanup
      catch ignore
      
      @emit "tar::error", 
        source: data.source
        target: data.target
        code: code
    else    
      @emit eventName, 
        source: data.source
        target: data.target

Tar.prototype._archive = (data) ->
  console.log "Archiving #{data.source} to #{data.target}".cyan

  data.target = path.normalize data.target
  @_runCommand "tar",[ "-c", data.source ],"tar::archive-complete",data

      
Tar.prototype._unarchive = (data) ->
  console.log "Unarchiving for #{data.source}".cyan
  
  data.target = path.normalize data.target

  @_runCommand "untar",[ "-dc", data.source ],"tar::unarchive-complete",data    
  
