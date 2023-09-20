alias mongod="/c/Program\ files/MongoDB/Server/6.0/bin/mongod.exe"
alias mongo="/c/Program\ Files/MongoDB/Server/6.0/bin/mongosh.exe"
#COMMENT
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

function create() {
	 [[ "$1" ]] && touch -- "$1".{jsx,css}
}
