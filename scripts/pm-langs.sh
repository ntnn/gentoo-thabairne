#!/usr/bin/env sh

uri=https://raw.githubusercontent.com/JustOff/pale-moon-localization/master/crowdin.sh
tmp=$(mktemp -d)
rm_tmp() {
	rm -rf $tmp
}
trap rm_tmp EXIT

get_langs() {
    curl "$uri" > $tmp/crowdin.sh
	awk '/^for lang in/ { $1=""; $2=""; $3=""; $0=$0; gsub(/^ +/, "", $0); print $0 }' < $tmp/crowdin.sh
}

test -f "$1" || exit 1
sed -Ei "s#^MOZ_LANGS=\(.*\)#MOZ_LANGS=($(get_langs))#" $1
