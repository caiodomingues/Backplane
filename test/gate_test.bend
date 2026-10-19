import Base
import ./check.bend as C
import ../src/core/gate.bend as GTE

def main() -> IO(Unit):
  do IO<Unit>:
    C.Check.str("own page", Bool.show(GTE.Gate.local("127.0.0.1:3787", "http://127.0.0.1:3787")), "True")
    C.Check.str("localhost page", Bool.show(GTE.Gate.local("localhost:3787", "http://localhost:3787")), "True")
    C.Check.str("ipv6 page", Bool.show(GTE.Gate.local("[::1]:3787", "http://[::1]:3787")), "True")
    C.Check.str("https page", Bool.show(GTE.Gate.local("localhost:3787", "https://localhost:3787")), "True")
    C.Check.str("any-address window", Bool.show(GTE.Gate.local("0.0.0.0:3787", "")), "True")
    C.Check.str("no port", Bool.show(GTE.Gate.local("localhost", "http://localhost")), "True")
    C.Check.str("native client", Bool.show(GTE.Gate.local("127.0.0.1:3787", "")), "True")
    C.Check.str("no host no origin", Bool.show(GTE.Gate.local("", "")), "True")
    C.Check.str("foreign origin", Bool.show(GTE.Gate.local("127.0.0.1:3787", "https://evil.example")), "False")
    C.Check.str("other port", Bool.show(GTE.Gate.local("127.0.0.1:3787", "http://127.0.0.1:5173")), "False")
    C.Check.str("other loopback name", Bool.show(GTE.Gate.local("127.0.0.1:3787", "http://localhost:3787")), "False")
    C.Check.str("null origin", Bool.show(GTE.Gate.local("127.0.0.1:3787", "null")), "False")
    C.Check.str("file origin", Bool.show(GTE.Gate.local("127.0.0.1:3787", "file://")), "False")
    C.Check.str("origin without host", Bool.show(GTE.Gate.local("", "http://127.0.0.1:3787")), "False")
    C.Check.str("rebound host", Bool.show(GTE.Gate.local("evil.example:3787", "")), "False")
    C.Check.str("rebound page", Bool.show(GTE.Gate.local("evil.example:3787", "http://evil.example:3787")), "False")
    C.Check.str("name prefix", Bool.show(GTE.Gate.local("localhost.evil.example:3787", "")), "False")
    C.Check.str("address prefix", Bool.show(GTE.Gate.local("127.0.0.1.evil.example", "")), "False")
    C.Check.str("tailnet address", Bool.show(GTE.Gate.local("100.64.0.7:3787", "http://100.64.0.7:3787")), "False")
    C.Check.str("authority http", GTE.Gate.authority("http://a:1"), "a:1")
    C.Check.str("authority https", GTE.Gate.authority("https://a:1"), "a:1")
    C.Check.str("authority other scheme", GTE.Gate.authority("chrome-extension://abc"), "")
