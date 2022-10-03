package main

import (
	"fmt"
	hello "github.com/JasonkayZK/re-tinykv/proto/pkg/hello"
)

func main() {
	req := hello.HelloRequest{}
	fmt.Println(req.String())
}
