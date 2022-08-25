package main

import (
	"fmt"
	"bytes"
    "log"
    "os/exec"

	"github.com/elastic/beats/libbeat/beat"
	"github.com/elastic/beats/libbeat/common"
	"github.com/elastic/beats/libbeat/processors"
)

const ShellToUse = "bash"

func init() {
	processors.RegisterPlugin("myplugin", New)
}

type Myplugin struct {
}

func (f Myplugin) String() string {
	return "Myplugin="
}

func New(c *common.Config) (processors.Processor, error) {
	return &Myplugin{
	}, nil
}

func (f *Myplugin) Run(event *beat.Event) (*beat.Event, error) {
	imageName, err := event.GetValue("container.image.name")
	if err != nil {
		return nil, fmt.Errorf("fail getting container.image.name", err)
	}
	err, out, _ := Shellout(fmt.Sprintf("docker images --no-trunc --quiet %v",imageName))
    if err != nil {
        log.Printf("error: %v\n", err)
    }
    fmt.Println(out)

	event.PutValue("event.container.image.digest", out)
	return event, nil
}

func Shellout(command string) (error, string, string) {
    var stdout bytes.Buffer
    var stderr bytes.Buffer
    cmd := exec.Command(ShellToUse, "-c", command)
    cmd.Stdout = &stdout
    cmd.Stderr = &stderr
    err := cmd.Run()
    return err, stdout.String(), stderr.String()
}

func main() {}