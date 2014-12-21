package main

import (
	"flag"
	"fmt"
	"os"
	"log"

	"decc"

	"github.com/craigmj/commander"
)

var helpText = `deccgem v0.0.2
USAGE: deccgem CMD

COMMANDS:
namegem		Return the version name to use for the gem
find		Return the latest DECC gem installed
gemfile 	Write the twenty-fifty Gemfile to Stdout
whichgem 	Find the latest .gem file in current directory
`

func findCommand() *commander.Command {
	return commander.NewCommand("find","Return the latest DECC gem installed", nil,
		func(args []string) error {
			fmt.Println(decc.TheDeccGem())
			return nil
			})
}
func gemfileCommand() *commander.Command {
	return commander.NewCommand("getfile", "Output the twenty-fifty Gemfile", nil,
		func(args []string) error {
			decc.WriteGemFile(os.Stdout)
			return nil
			})
}
func whichgemCommand() *commander.Command {
	return commander.NewCommand("whichgem", "Find the latest .gem file in the current directory",
		nil, 
		func(args []string) error {
			wdir, err := os.Getwd()
			if nil != err {
				fmt.Fprintln(os.Stderr, err.Error())
				os.Exit(1)
			}
			g, err := decc.WhichGem(wdir)
			if nil != err {
				fmt.Fprintln(os.Stderr, err.Error())
				os.Exit(1)
			}
			if nil == g {
				fmt.Fprintln(os.Stderr, "No .gem files found")
				os.Exit(1)
			}
			fmt.Println(g.Filename)			
			return nil
			})
}
func parseCommand() *commander.Command {
	return commander.NewCommand("listgems", "List applicable gems", nil,
		func(args []string) error {
			decc.GemLister()
			return nil
			})
}
func namegemCommand() *commander.Command {
	fs := flag.NewFlagSet("namegem", flag.ExitOnError)
	d := flag.String("dir", ".", "Directory of decc_2050_model")
	return commander.NewCommand("namegem", "Provide a name for the latest gem to build", fs,
		func(args []string) error {
			n, err := decc.NameGem(*d, os.Stdout)
			fmt.Println(n)
			return err
		})
}

func main() {
	if err := commander.Execute(nil, findCommand, gemfileCommand, whichgemCommand, parseCommand, namegemCommand);
		nil!=err {
		log.Fatal(err)
	}
}
