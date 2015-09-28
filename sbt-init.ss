

def createDirIfNeeded(f: java.io.File):Unit = {
	val parent = f.getParentFile()
	if(parent != null && !parent.exists()) {
		println("Creating directory " + parent.getName())
		if (parent.mkdirs()) 			println("\tDirectory is created!")
		else 			println("\tFailed to create directory!")
	}
}

def printToFile( name: String, content: String) = {
	println(s"Create $name")

	val file = new java.io.File(name)
	createDirIfNeeded(file)
	
	val p = new java.io.PrintWriter(name)
	try { p.println(content) } finally { p.close() }
}


printToFile("build.sbt","""
name := "Hello World"

version := "1.0"

scalaVersion := "2.11.2"

libraryDependencies ++= Seq(
  "com.novocode" % "junit-interface" % "0.11" % "test"
)
""")


printToFile(".gitignore","""
/bin/
.cache
.classpath
.project
project/
target/
""")

printToFile("src/test/java/XTest.java","""
import org.junit.*;
import static org.junit.Assert.*;

public class XTest {

	@Test
	public void a_test() {
		fail("auto generated test");
	}
}
""")

printToFile("src/main/scala/X.scala","""
object X extends App {
	println("Hello World")
}
""")

