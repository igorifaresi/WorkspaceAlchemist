package main

import "errors"

func AppendToError(err error, msg string) error {
	return errors.New(msg + " -> " + err.Error())
}