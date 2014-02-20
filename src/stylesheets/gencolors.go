package main

import (
	"fmt"
	"os"
)

var cssClasses = []string{
	`.gas`,
	`.coal`,
	`.oil`,
	`.bioenergy`,
	`.environmentalheat`,
	`.geothermal`,
	`.h2`,
	`.hydro`,
	`.nuclear`,
	`.offshorewind`,
	`.onshorewind`,
	`.solar`,
	// `text.solar`,
	`.tidal`,
	`.wave`,
	`.wind`,
	`.ccs`,

	// Specific to electricty supply chart
	`.conventional`,
	`.tidalandwave`,
	`.electricity`,

	// Specific to the energy demand chart
	`.transport`,
	`.heatingcooling`,
	`.industry`,
	`.lightingappliances`,
	// `text.lightingappliances`,

	// The emissions chart
	`.carboncapture`,
	`.lulucf`,
	`.fuelcombustion`,
	`.aviationandshipping`,
	`.waste`,

	// Not yet used?
	`.commercialheat`,
	`.commerciallight`,
	`.districtheating`,
	`.domesticfreight`,
	`.domesticlight`,
	`.domesticpassengertransport`,
	`.domesticheat`,
}

func main() {
	out, err := os.Create("colors.css.scss")
	if nil != err {
		panic(err)
	}
	defer out.Close()
	fmt.Fprintln(out, "// Generated by gencolors.go - DO NOT EDIT")
	// fmt.Fprintln(out, "$start0: #464;")
	fmt.Fprintln(out, "$start0: darken(#ced, 0%);")
	fmt.Fprintln(out, "$start1: #bec8b7;")
	fmt.Fprintln(out, "$start2: #363;")
	fmt.Fprintln(out, "$start3: #366;")
	perc := 0
	colour := 0
	for _, c := range cssClasses {
		fmt.Fprintf(out,
			"%s { fill: lighten($start%d, %d%%); }\n",
			c, colour, perc,
		)
		perc += 5
		if perc >= 25 {
			perc -= 23
			if 6 == perc {
				perc = 0
				colour++
			}
			//colour++
		}
	}
}
