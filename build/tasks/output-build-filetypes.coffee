asar = require 'asar'
path = require 'path'

module.exports = (grunt) ->
  grunt.registerTask 'output-build-filetypes', 'Log counts for each filetype in the built application', ->
    shellAppDir = grunt.config.get('atom.shellAppDir')

    types = {}
    registerFile = (filePath) ->
      extension = path.extname(filePath) or path.basename(filePath)
      types[extension] ?= 0
      types[extension]++

      if extension is '.asar'
        asar.listPackage(filePath).forEach (archivePath) ->
          archivePath = archivePath.substring(1)
          unless asar.statFile(filePath, archivePath, true).files
            registerFile(archivePath)

    grunt.file.recurse shellAppDir, (absolutePath, rootPath, relativePath, fileName) -> registerFile(absolutePath)

    extensions = Object.keys(types).sort (extension1, extension2) ->
      diff = types[extension2] - types[extension1]
      if diff is 0
        extension1.toLowerCase().localeCompare(extension2.toLowerCase())
      else
        diff

    extensions.forEach (extension) ->
      grunt.log.error "#{extension}: #{types[extension]}"
