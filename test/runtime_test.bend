import Base
import ./check.bend as C
import ../src/core/model.bend as M
import ../src/core/codec.bend as C2
import ../src/core/prompt.bend as P

def has(xs: List<&2, String>, +w: String) -> String:
  match xs:
    case Nil{}:
      "no"
    case +x <> t:
      Bool.pick(String, String.eq(x, w), "yes", has(t, w))

def hit(xs: List<&2, String>, +w: String) -> Bool:
  match xs:
    case Nil{}:
      False{}
    case x <> _:
      String.eq(x, w)

def after.go(xs: List<&2, String>, h: Bool, +w: String) -> String:
  match xs h:
    case +x <> +t True{}:
      Maybe.default(&2, String, List.head(&2, String, t), "")
    case +x <> +t False{}:
      after.go(t, hit(t, w), w)
    case Nil{} _:
      ""

def after(+xs: List<&2, String>, +w: String) -> String:
  after.go(xs, hit(xs, w), w)

def args(r: M.RuntimeMode, i: M.InteractionMode) -> List<&2, String>:
  P.Claude.args("", "", r, i, "p", Nil{})

def main() -> IO(Unit):
  do IO<Unit>:
    C.Check.str("full-access decodes auto", C2.Runtime.name(C2.Runtime.of("full-access")), "auto")
    C.Check.str("unknown decodes auto", C2.Runtime.name(C2.Runtime.of("garbage")), "auto")
    C.Check.str("auto mode", after(args(M.AutoMode{}, M.DefaultMode{}), "--permission-mode"), "auto")
    C.Check.str("auto prompt tool", after(args(M.AutoMode{}, M.DefaultMode{}), "--permission-prompt-tool"), "mcp__backplane__permission_prompt")
    C.Check.str("supervised mode", after(args(M.Supervised{}, M.DefaultMode{}), "--permission-mode"), "default")
    C.Check.str("accept edits mode", after(args(M.AcceptEdits{}, M.DefaultMode{}), "--permission-mode"), "acceptEdits")
    C.Check.str("plan mode", after(args(M.AutoMode{}, M.PlanMode{}), "--permission-mode"), "plan")
    C.Check.str("plan prompt tool", has(args(M.AutoMode{}, M.PlanMode{}), "--permission-prompt-tool"), "yes")
    C.Check.str("no bypass", has(args(M.AutoMode{}, M.DefaultMode{}), "bypassPermissions") ++ has(args(M.Supervised{}, M.DefaultMode{}), "bypassPermissions") ++ has(args(M.AcceptEdits{}, M.DefaultMode{}), "bypassPermissions") ++ has(args(M.AutoMode{}, M.PlanMode{}), "bypassPermissions"), "nononono")
