# Tests for GraalVM/FreePascal UTF-8 string passing
A test for passing UTF-8 strings from Object Pascal/FreePascal to GraalVM and back

# Prerequisites

* A GraalVM installation. Last used: [GraalVM 22.3.3 Java 17 CE](https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-22.3.3)
  * Download the ZIP, unzip it to `C:\Program Files\Java\graalvm-ce-java17-22.3.3`
  * Starter cmd script `C:\Program Files\Java\graalvm-ce-java17-22.3.3\graal-cmd-17.cmd`:
  ```cmd
  set JAVA_HOME=C:\Program Files\Java\graalvm-ce-java17-22.3.3
  :: [...]
  set PATH=%JAVA_HOME%\bin;%PATH%
  ```
  * Install native-image as [documented](https://www.graalvm.org/22.3/reference-manual/native-image/)
  ```cmd
  gu install native-image
  ```
* [Visual Studio Build Tools (Last used: 2017)](https://my.visualstudio.com/Downloads?q=visual%20studio%20build%20tools%202017&wt.mc_id=o~msft~vscom~older-downloads)
* [Lazarus IDE 64-bit (Last used: 2.2.6)](https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2064%20bits/Lazarus%202.2.6/lazarus-2.2.6-fpc-3.2.2-win64.exe/download)

# Building the DLL

1. Start the `x64 Native Tools Command Prompt for VS 2017` from the start menu.
2. In that command prompt start `C:\Program Files\Java\graalvm-ce-java17-22.3.3\graal-cmd-17.cmd`
3. ```cmd
   javac Main.java
   ```
4. ```cmd
   chcp 65001
   native-image -H:Name=libtestutf8 -J-Dfile.encoding=UTF-8 --shared
   ```
   _Note_: To see some encoding problems remove the `-J-D...` parameter and or compile with `chcp 1252`

# Building the FreePascal test program

Open the Project `graalutf8.lpi` in `Lazarus IDE` and hit run.
To use the resulting `graalutf8.exe` as a pure console program add at `-ci` parameter.
