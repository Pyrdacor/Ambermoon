#!/bin/bash
# compare.sh <original dll> <port binary> <cases file>: runs each case "arguments|stdin" (stdin with printf escapes, e.g.
# "y\n") with the original and the port, each in a fresh copy of $COMPARE_DIR/in (default: the current folder), and
# compares the output (sorted: the order of some lines of the originals changes from run to run), the exit code and all
# files. Differences are shown with the first lines of both outputs.
B=${COMPARE_DIR:-$PWD}; W=$B/w
ok=0; bad=0
while IFS= read -r line; do
  [ -z "$line" ] && continue
  a="${line%%|*}"; input="${line#*|}"
  for side in r n; do rm -rf $W/$side; mkdir -p $W/$side; cp -r $B/in/* $W/$side/; done
  (cd $W/r && printf "$input" | eval "dotnet $1 $a" > ../r.out 2>&1; echo "exit $?" >> ../r.out)
  (cd $W/n && printf "$input" | eval "$2 $a" > ../n.out 2>&1; echo "exit $?" >> ../n.out)
  sort $W/r.out > $W/r.sorted; sort $W/n.out > $W/n.sorted
  if cmp -s $W/r.sorted $W/n.sorted && diff -r $W/r $W/n > /dev/null; then ok=$((ok+1)); else bad=$((bad+1)); echo "DIFF: $line"; diff $W/r.sorted $W/n.sorted | head -6; diff -rq $W/r $W/n | head -5; fi
done < $3
echo "ok $ok, diff $bad"
