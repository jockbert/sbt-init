# sbt-init
Scala script to generate a SBT project template. The script generates template files for `build.sbt`, `.gitignore`, an example test specification (using Specs2 and ScalaCheck) and a Scala application file. 

The created SBT project is prepared for using sbteclipse plugin. The project name is set to the same name as the project folder.

## Usage to create new project

     $ cd /my/new/project/directory
     $ scala path/to/sbt-init.ss
