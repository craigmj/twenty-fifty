#!/bin/bash
export GOPATH=`pwd`
for d in "github.com/craigmj/commander";
	do 
	if [ ! -d src/$d ]; then
		go get $d
	fi
done
go build src/cmd/deccgem.go
