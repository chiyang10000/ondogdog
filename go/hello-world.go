package main

import "time"

func main() {
	println("hi")
	go hello()
	time.Sleep(time.Second * 1)
}

func hello() {
	println("Hello World")
}
