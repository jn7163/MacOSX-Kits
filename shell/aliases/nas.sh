# NAS相关

alias nas.kits.update="kits.sync --protocol=30 --rsync-path /usr/bin/rsync -e 'ssh -p $JHOME_SSH_PORT -i $JKEY' $NASKITS/ root@$JHOME:/volume1/cellar/kits/"
alias nas.ip="ssh.home 'curl -s http://ip.3322.net'"
alias nas.ip.host="dig +short $JHOST"

# Download Station
alias nas.ds="$KITS/python/ds"
alias nas.ds.create="nas.ds create"
alias nas.ds.emule="nas.ds emule"
alias nas.ds.clean="nas.ds clean"

# 迅雷远程 下载
alias nas.tdd.start="ssh.home.root \"bash -ic 'tdd.start'\""
alias nas.tdd.stop="ssh.home.root \"bash -ic 'tdd.stop'\""
alias nas.tdd.restart="ssh.home.root \"bash -ic 'tdd.restart'\""
alias nas.tdd.alive="ssh.home.root \"bash -ic 'tdd.alive'\""
alias nas.tdd.keep-alive="ssh.home.root \"bash -ic 'tdd.keep-alive'\""