package main

import (
	"encoding/json"
	"errors"
	"log"
	"os"
)

type SourceKind string
const (
    SOURCE_KIND_SAI = "SAI"
)

type Connector interface {
    Connect(connectionData map[string]string) error
    Query(query map[string]string) (string, error)
    Name() string
}

type Source struct {
    Name           string            `json:"name"`
    ConnectionData map[string]string `json:"connection_data"`
    Kind           SourceKind        `json:"kind"`
    Connector      Connector         `json:"-"`
}

type SourcesLocationKind string
const (
    SOURCE_LOC_KIND_FILE = "file"
)

type SourcesLocation struct {
    Name     string              `json:"name"`
    Kind     SourcesLocationKind `json:"kind"`
    FilePath string              `json:"file_path"`
}

type Configuration struct {
    Port      int               `json:"port"`
    Locations []SourcesLocation `json:"locations"`
}

var Sources []Source
var Cfg Configuration

func PrepareSource(_source Source) (Source, error) {
    source := _source

    if len(source.Name) <= 0 {
        return Source{}, errors.New("the name must to exist")
    }

    for _, s := range Sources {
        if source.Name == s.Name {
            return Source{}, errors.New("a source with this name already exists")
        }
    }

    switch source.Kind {
    case SOURCE_KIND_SAI:
        source.Connector = &SAI{}
    default:
        return Source{}, errors.New("invalid source kind")
    }

    err := source.Connector.Connect(source.ConnectionData)
    if err != nil {
        return Source{}, AppendToError(err, "error connecting to source")
    }

    return source, nil
}

func AddSourceList(sourceList []Source) {
    for _, source := range sourceList {
        log.Println(`adding source "`+source.Name+`" of kind "`+string(source.Kind)+`"`)
        preparedSource, err := PrepareSource(source)
        if err != nil {
            log.Panicln("error adding source")
        }

        Sources = append(Sources, preparedSource)
    }
}

func main() {
    configJson, err := os.ReadFile("config.json")
    if err != nil {
        log.Panicln(AppendToError(err, "unable to read config.json"))
    }

    err = json.Unmarshal(configJson, &Cfg)
    if err != nil {
        log.Panicln(AppendToError(err, "invalid config.json"))
    }

    for _, location := range Cfg.Locations {
        log.Println(`reading sources from location "`+location.Name+`"`)

        switch location.Kind {
        case SOURCE_LOC_KIND_FILE:
            log.Println("reading from file")

            sourcesListJson, err := os.ReadFile(location.FilePath)
            if err != nil {
                log.Panicln(AppendToError(err, "unable to read "+location.FilePath))
            }

            var sourceList []Source
            err = json.Unmarshal(sourcesListJson, &sourceList)
            if err != nil {
                log.Panicln(AppendToError(err, "invalid "+location.FilePath))
            }

            AddSourceList(sourceList)
        default:
            log.Panicln("invalid sources location kind: "+location.Kind)
        }
    }

    InitWebServer(Cfg.Port)
}