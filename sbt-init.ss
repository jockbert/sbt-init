
import java.io._

def currentDir = new File(".").getCanonicalPath().split(File.separator).last
println("Name " + currentDir)


printToFile("build.sbt",s"""
	|name := "$currentDir"
	|
	|version := "0.1"
	|
	|scalaVersion := "2.11.2"
	|
	|libraryDependencies ++= Seq(
	|	"org.specs2" %% "specs2-core" % "3.6.4" % "test",
	|	// "org.specs2" %% "specs2-mock" % "3.6.4" % "test",
	|	"org.specs2" %% "specs2-scalacheck" % "3.6.4" % "test"
	|)
	|
	|// *** avoid java source directories ***
	|unmanagedSourceDirectories in Compile <<= (scalaSource in Compile)(Seq(_))
	|
	|unmanagedSourceDirectories in Test <<= (scalaSource in Test)(Seq(_))
	|
	|""".stripMargin)


printToFile(".gitignore","""
	|/bin/
	|.cache
	|.classpath
	|.project
	|project/
	|target/
	|""".stripMargin)

printToFile("src/test/scala/TriangleSpec.scala",s"""
import org.specs2._
import org.scalacheck.Gen
import org.scalacheck.Arbitrary

class TriangelSpec extends Specification with ScalaCheck {

  def is = s2\"\"\"
    Specification for a triangle
      (A) A triangle side must be positive and non-zero
         (A1) A side is valid when > 0 $$a1
         (A2) A side is invalid when <= 0 $$a2
      (B) A side can not be longer or equal than the sum of
      the two other sides $$b
      (C) A triangle is only valid vhen (A) and (B) is
      applicable for all sides. $$c

      The cirumference of a triangel is larger than 3 times the shortest side  $$e1
      The cirumference of a triangel is smaller than 3 times the longest side  $$e2
      The circumference of the sides 3, 4 and 5 is 12 $$e3

      The area of a triangel is smaller than the half square of the middle length side $$f1
      The area of the sides 3, 4 and 5 is 6 $$f2
      The area of the sides 40, 30 and 50 is 600 $$f3
    \"\"\"

  def a1 = prop { (side: Int) => side > 0 ==> Triangle.isPositive(side) }
  def a2 = prop { (side: Int) => side <= 0 ==> !Triangle.isPositive(side) }

  def b = prop { (a: Int, b: Int, c: Int) =>
    Triangle.isNotToLong(a)(b, c) mustEqual
      (b.toLong + c.toLong - a.toLong) > 0
  }

  def c = prop { (a: Int, b: Int, c: Int) =>
    import Triangle._
    Triangle.isValid(a, b, c) mustEqual (
      isPositive(a) &&
      isPositive(b) &&
      isPositive(c) &&
      isNotToLong(a)(b, c) &&
      isNotToLong(b)(a, c) &&
      isNotToLong(c)(b, a))
  }

  implicit val orderedSidesTriangle = Arbitrary {
    def validSide(n: Int) = for (x <- Gen.choose(n, Integer.MAX_VALUE)) yield x

    for {
      a <- validSide(1)
      b <- validSide(a)
      c <- validSide(b)
      if Triangle.isValid(a, b, c)
    } yield Triangle(a, b, c)
  }

  def e1 = prop { (t: Triangle) => t.circumference() >= 3 * t.a.toLong }
  def e2 = prop { (t: Triangle) => t.circumference() <= 3 * t.c.toLong }
  def e3 = Triangle(4, 3, 5).circumference() must_== 12

  def f1 = prop { (t: Triangle) => t.area() <= (t.b.toDouble * t.b) / 2 }
  def f2 = Triangle(3, 4, 5).area() must_== 6
  def f3 = Triangle(40, 30, 50).area() must_== 600
}
""")

printToFile("src/main/scala/Triangle.scala","""
object Triangle extends App {
  val t = Triangle(3, 4, 5)

  println("Given a " + t)
  println(" The circumference is " + t.circumference())
  println(" The area is " + t.area())

  def isPositive(side: Int): Boolean =
    side > 0

  def isNotToLong(a: Int)(b: Int, c: Int): Boolean =
    b.toLong + c - a > 0

  def isValid(a: Int, b: Int, c: Int): Boolean = {
    isPositive(a) && isPositive(b) && isPositive(c) && isNotToLong(a)(b, c) && isNotToLong(c)(b, a) && isNotToLong(b)(a, c)
  }
}

case class Triangle(a: Int, b: Int, c: Int) {
  def circumference(): Long = a.toLong + b + c

  def area(): Double = {
    val s = circumference().toDouble / 2
    Math.sqrt(s * (s - a) * (s - b) * (s - c))
  }
}
""")

def printToFile(name: String, content: String) = {
	println(s"Create $name")

	val file = new File(name)
	createDirIfNeeded(file)

	val p = new PrintWriter(name)
	try { p.println(content) } finally { p.close() }
}

def createDirIfNeeded(f: File):Unit = {
	val parent = f.getParentFile()
	if(parent != null && !parent.exists()) {
		print("\tCreating directory " + parent.getCanonicalPath())
		if (parent.mkdirs()) println("\t (success)")
		else println("\t (failed)")
	}
}
