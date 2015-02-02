package main

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	in, err := http.Get(os.Args[1])
	if nil != err {
		log.Fatal(err)
	}
	defer in.Body.Close()
	b, err := ioutil.ReadAll(in.Body)
	if nil != err {
		log.Fatal(err)
	}

	var out bytes.Buffer
	json.Indent(&out, b, "", "\t")
	out.WriteTo(os.Stdout)
}
