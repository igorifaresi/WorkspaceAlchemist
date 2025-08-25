package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"
)

const SAI_URL = "https://sai-library.saiapplications.com"

type SAI struct {
	ApiKey string
	Template string
}

func (s *SAI) Name() string {
	return "SAI"
}

func (s *SAI) Connect(connectionData map[string]string) error {
	key, found := connectionData["api_key"]
	if !found {
		return errors.New("api_key required")
	}

	template, found := connectionData["template"]
	if !found {
		return errors.New("template required")
	}

	s.ApiKey = key
	s.Template = template

	return nil
}

func (s *SAI) Query(query map[string]string) (string, error) {
	client := &http.Client{}

	payload := map[string]interface{}{
		"inputs": query,
	}

	payloadData, err := json.Marshal(payload)
	if err != nil {
		return "", AppendToError(err, "err mashiling SAI payload json")
	}

	payloadReader := bytes.NewBuffer(payloadData)

	request, err := http.NewRequest("POST", SAI_URL+"/api/templates/"+s.Template+"/execute", payloadReader)
	if err != nil {
		return "", AppendToError(err, "unable to create connection")
	}

	request.Header.Set("X-Api-Key", s.ApiKey)
	request.Header.Set("content-type", "application/json")

	response, err := client.Do(request)
	if err != nil {
		return "", AppendToError(err, "unable to do the request")
	}

	data, err := io.ReadAll(response.Body)
	if err != nil {
		return "", errors.New("error reading response")
	}

	if response.StatusCode != 200 {
		return "", errors.New("SAI don't returned 200, instead "+response.Status)
	}

	str := string(data)

	return str, nil
}