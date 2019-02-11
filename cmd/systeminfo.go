// Copyright © 2018 moooofly <centos.sf@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package cmd

import (
	"fmt"

	"github.com/moooofly/harborctl/utils"
	"github.com/spf13/cobra"
)

var systeminfoURL string

// systeminfoCmd represents the systeminfo command
var systeminfoCmd = &cobra.Command{
	Use:   "systeminfo",
	Short: "'/systeminfo' API.",
	Long:  `The subcommand of '/systeminfo' hierarchy.`,
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		systeminfoURL = utils.URLGen("/api/systeminfo")
	},
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Use \"harborctl systeminfo --help\" for more information about this command.")
	},
}

func init() {
	rootCmd.AddCommand(systeminfoCmd)

	initSysteminfoGet()
}

// systeminfoGetCmd represents the get command
var systeminfoGetCmd = &cobra.Command{
	Use:   "get",
	Short: "Get general system info",
	Long:  `This API is for retrieving general system info, this can be called by anonymous request.`,
	Run: func(cmd *cobra.Command, args []string) {
		getSysteminfo()
	},
}

func initSysteminfoGet() {
	systeminfoCmd.AddCommand(systeminfoGetCmd)
}

func getSysteminfo() {
	targetURL := systeminfoURL
	utils.Get(targetURL)
}
