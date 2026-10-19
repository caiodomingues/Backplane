import Base

# Who may use the hub's own listener without the pairing token, pure.
# Any page in the person's browser can open a WebSocket to 127.0.0.1 (the
# same-origin policy does not cover WebSockets) or reach the port under a DNS
# name it rebound to loopback. Such a page chooses neither the Host header nor
# the Origin the browser sends, so trust needs a Host that names this machine
# and, when an Origin is sent, one served from that same Host. Native clients
# (http.bend's Ws.request, curl, the tools) send no Origin. Host and Origin are
# compared as sent: browsers lower-case the host part, and lower-casing an
# untrusted header here would cost a walk per character.

def Gate.names() -> List<&2, String>:
  ["localhost", "127.0.0.1", "[::1]", "0.0.0.0"]

def Gate.named(ns: List<&2, String>, +host: String) -> Bool:
  match ns:
    case Nil{}:
      False{}
    case +n <> t:
      Bool.or(Bool.or(String.eq(host, n), String.starts_with(host, n ++ ":")), Gate.named(t, host))

def Gate.host.k(empty: Bool, +host: String) -> Bool:
  match empty:
    case True{}:
      True{}
    case False{}:
      Gate.named(Gate.names(), host)

# a Host header naming this machine; a client that sends none is no browser
def Gate.host(+host: String) -> Bool:
  Gate.host.k(String.is_empty(host), host)

def Gate.authority.k(http: Bool, https: Bool, +origin: String) -> String:
  match http https:
    case True{} True{}:
      String.drop(origin, 7n)
    case True{} False{}:
      String.drop(origin, 7n)
    case False{} True{}:
      String.drop(origin, 8n)
    case False{} False{}:
      ""

# an Origin's host and port ("" for "null" or any other scheme)
def Gate.authority(+origin: String) -> String:
  Gate.authority.k(String.starts_with(origin, "http://"), String.starts_with(origin, "https://"), origin)

def Gate.same.k(+auth: String, +host: String) -> Bool:
  Bool.and(Bool.not(String.is_empty(auth)), String.eq(auth, host))

# no Origin, or the Origin of a page this Host served
def Gate.same(+host: String, +origin: String) -> Bool:
  Bool.or(String.is_empty(origin), Gate.same.k(Gate.authority(origin), host))

# a request on the trusted listener that no other site's page could have made
def Gate.local(+host: String, +origin: String) -> Bool:
  Bool.and(Gate.host(host), Gate.same(host, origin))
