vows = require 'vows'
assert = require 'assert'

main = require '../lib/index'
specHelper = require './spec_helper'

vows.describe("integration_task")
  .addBatch
    "CLEANUP TEMP":
      topic: () ->
        specHelper.cleanTmpFiles ['test1.tar','test2.tar','afile.txt','anotherfile.txt']
      "THEN IT SHOULD BE CLEAN :)": () ->
        assert.isTrue true        
  .addBatch
    "SETUP HOOK" :
      topic: () -> 
        specHelper.setup @callback
        return
      "THEN IT SHOULD SET UP :)": () ->
        assert.isTrue true
  .addBatch 
    "WHEN archiving a single file": 
      topic:  () ->
        specHelper.hookMeUp @callback

        specHelper.hook.emit "tar::archive",
          source : [specHelper.fixturePath(specHelper.sourceFile1)]
          target : specHelper.tmpPath("test1.tar")
        return
      "THEN it must be complete": (err,event,data) ->
        assert.equal event,"tar::archive-complete" 
  .addBatch 
    "WHEN archiving a two files": 
      topic:  () ->
        specHelper.hookMeUp @callback

        specHelper.hook.emit "tar::archive",
          source : [specHelper.fixturePath(specHelper.sourceFile1),
                   specHelper.fixturePath(specHelper.sourceFile2)]
          target : specHelper.tmpPath("test2.tar")
        return
      "THEN it must be complete": (err,event,data) ->
        assert.equal event,"tar::archive-complete" 
  .addBatch 
    "WHEN unarchiving a file to a folder": 
      topic:  () ->
        specHelper.hookMeUp @callback
        specHelper.hook.emit "tar::unarchive",
          source : specHelper.fixturePath(specHelper.compressedFileMultiple)
          targetPath : specHelper.tmpPath("")
        return
      "THEN it must be complete": (err,event,data) ->
        assert.equal event,"tar::unarchive-complete" 
  .export module
