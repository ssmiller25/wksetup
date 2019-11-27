
if [ "$(uname)" = "Darwin" ]; then
  eval $(docker-machine env)
fi
