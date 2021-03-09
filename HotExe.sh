sigint_handler()
{
  kill $(jobs -p)
  exit
}

trap sigint_handler SIGINT

TARGET_DIR=.
TARGET=proper-weather
CABAL_FILE=xmobar-proper-weather.cabal
CMD=$1
EXTRA_WATCH=''

while true; do
  # $@ &
  case $CMD in
      doc) cabal haddock $TARGET &
           # For haddocks; we canot rely on GHCID, so we need to add the src dir. to the 
           # watch list. 
           EXTRA_WATCH="-r $TARGET_DIR/src"
           ;; 
      ghcid)
          ghcid -l -c "cabal new-repl $TARGET --builddir dist-$TARGET" & 
          ;; 
      *) 
          echo "Unknown: '$CMD'; must be one of 'ghcid' or 'doc'" 
          break;
          ;;
      esac
 
  PID1=$!

  echo "Establishing watches."

  inotifywait \
      -e modify \
      -e move \
      -e create \
      -e delete \
      -e attrib \
      $EXTRA_WATCH \
      -r src \
      $TARGET_DIR/$CABAL_FILE \
      --exclude ".*flycheck.*|.*\#.*"
  kill $(jobs -p)
  sleep 3
done

