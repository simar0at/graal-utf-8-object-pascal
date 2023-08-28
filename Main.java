import org.graalvm.nativeimage.IsolateThread;
import org.graalvm.nativeimage.c.function.CEntryPoint;
import org.graalvm.nativeimage.c.type.CCharPointer;
import org.graalvm.nativeimage.c.type.CTypeConversion;
 
public class Main {
    public static void main(String[] args) {
        System.out.println("file.encoding:" + System.getProperty("file.encoding"));
        System.out.println("UTF-8 text with some international chars:");
        System.out.println("äëïöü áéíóú àèiòù Ññ Çç € تيست");
    }
    @CEntryPoint(name = "print_and_return")
    static CCharPointer print_and_return(IsolateThread thread, CCharPointer _in) {
        String in = CTypeConversion.toJavaString(_in);
        System.out.println("file.encoding:" + System.getProperty("file.encoding"));
        System.out.println("String passed as input is:");
        System.out.println(in);
        return CTypeConversion.toCString(in).get();
    }
    @CEntryPoint(name = "add_utf8_print_and_return")
    static CCharPointer add_utf8_print_and_return(IsolateThread thread, CCharPointer _in) {
        String in = CTypeConversion.toJavaString(_in);
        System.out.println("file.encoding:" + System.getProperty("file.encoding"));
        System.out.println("String passed as input is:");
        System.out.println(in);
        return CTypeConversion.toCString("“" + in  + "”").get();
    }
}