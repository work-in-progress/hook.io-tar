vows = require 'vows'
assert = require 'assert'

main = require '../lib/index'
specHelper = require './spec_helper'

vows.describe("integration_task")
  .addBatch
    "CLEANUP TEMP":
      topic: () ->
        specHelper.cleanTmpFiles ['test1.gz','test2.bz2','test3.txt','test4.txt']
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
    "WHEN archiving a file": 
      topic:  () ->
        specHelper.hookMeUp @callback

        specHelper.hook.emit "tar::archive",
          source : specHelper.fixturePath(specHelper.untared)
          target : specHelper.tmpPath("test1.gz")
          mode : 'gzip'
        return
      "THEN it must be complete": (err,event,data) ->
        assert.equal event,"tar::archive-complete" 
  .addBatch 
    "WHEN unarchiving a file": 
      topic:  () ->
        specHelper.hookMeUp @callback
        specHelper.hook.emit "tar::archive",
          source : specHelper.fixturePath(specHelper.untared)
          target : specHelper.tmpPath("test2.bz2")
          mode : 'bzip2'
        return
      "THEN it must be complete": (err,event,data) ->
        assert.equal event,"tar::archive-complete" 
  .export module
